#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path


MERMAID_FENCE_START = "```mermaid"
FENCE_END = "```"
HEADING_RE = re.compile(r"^(#{2,6})\s+(.*\S)\s*$")


@dataclass(frozen=True)
class MermaidBlock:
    heading: str
    order: int
    text: str


def run(cmd: list[str]) -> None:
    print("+", " ".join(cmd))
    subprocess.run(cmd, check=True)


def find_mmdc() -> str:
    path = shutil.which("mmdc")
    if path:
        return path
    raise SystemExit("Could not find `mmdc` in PATH.")


def slugify(text: str) -> str:
    text = text.lower()
    text = re.sub(r"[^a-z0-9]+", "-", text)
    return text.strip("-")


def normalize_heading(heading: str, source_root_name: str) -> str:
    clean = heading.strip()

    if source_root_name == "context-mapping":
        return "context-mapping"

    if "unified" in clean.lower():
        return "unified"

    match = re.match(r"^\d+\.\s*(.+?)\s+Layer$", clean, re.IGNORECASE)
    if match:
        return f"{slugify(match.group(1))}-layer"

    match = re.match(r"^(.+?)\s+Layer$", clean, re.IGNORECASE)
    if match:
        return f"{slugify(match.group(1))}-layer"

    return slugify(clean) or "diagram"


def iter_markdown_files(root: Path) -> list[Path]:
    files: list[Path] = []
    for current_root, dirnames, filenames in os.walk(root):
        dirnames[:] = sorted(
            d for d in dirnames
            if d not in {".git", "assets", "node_modules"}
        )
        current = Path(current_root)
        for filename in sorted(filenames):
            path = current / filename
            if path.suffix.lower() == ".md":
                files.append(path)
    return sorted(files)


def extract_mermaid_blocks(source: Path) -> list[MermaidBlock]:
    lines = source.read_text(encoding="utf-8").splitlines()
    blocks: list[MermaidBlock] = []
    last_heading = ""
    order = 0
    i = 0

    while i < len(lines):
        line = lines[i]
        heading_match = HEADING_RE.match(line)
        if heading_match:
            last_heading = heading_match.group(2).strip()
            i += 1
            continue

        if line.strip().lower() == MERMAID_FENCE_START:
            block_lines: list[str] = []
            i += 1
            while i < len(lines) and lines[i].strip() != FENCE_END:
                block_lines.append(lines[i])
                i += 1
            order += 1
            blocks.append(
                MermaidBlock(
                    heading=last_heading,
                    order=order,
                    text="\n".join(block_lines).strip(),
                )
            )
        i += 1

    return blocks


def render_mermaid_block(mmdc: str, block_text: str, output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", suffix=".mmd", delete=False) as temp_file:
        temp_path = Path(temp_file.name)
        temp_file.write(block_text.strip() + "\n")
        temp_file.flush()
    try:
        run([mmdc, "-i", str(temp_path), "-o", str(output_path), "-b", "transparent"])
    finally:
        temp_path.unlink(missing_ok=True)


def render_file(source_root: Path, output_root: Path, source: Path, mmdc: str) -> None:
    relative = source.relative_to(source_root)
    blocks = extract_mermaid_blocks(source)
    if not blocks:
        return

    source_scope = source_root.name
    file_dir = output_root / source_scope / relative.parent / source.stem

    used_names: dict[str, int] = {}
    for block in blocks:
        base_name = normalize_heading(block.heading, source_scope)
        count = used_names.get(base_name, 0) + 1
        used_names[base_name] = count
        if count > 1:
            base_name = f"{base_name}-{count:02d}"

        output_name = f"{base_name}.svg"
        render_mermaid_block(mmdc, block.text, file_dir / output_name)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Render Mermaid blocks from Markdown into ordered SVG assets."
    )
    parser.add_argument(
        "--source-root",
        nargs="*",
        default=["class-diagrams", "context-mapping"],
        help="Source directories to scan. Defaults to class-diagrams and context-mapping.",
    )
    parser.add_argument(
        "--output-root",
        default="assets",
        help="Output directory. Defaults to assets.",
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Remove the output directory before rendering.",
    )
    args = parser.parse_args()

    source_roots = [Path(root).resolve() for root in args.source_root]
    output_root = Path(args.output_root).resolve()

    if args.clean and output_root.exists():
        shutil.rmtree(output_root)

    mmdc = find_mmdc()
    rendered_any = False

    for source_root in source_roots:
        if not source_root.exists():
            print(f"Skipping {source_root} because it does not exist.")
            continue

        for source in iter_markdown_files(source_root):
            render_file(source_root, output_root, source, mmdc)
            rendered_any = True

    if not rendered_any:
        print("No Markdown files with Mermaid blocks were found.")
        return 0

    print(f"SVGs generated in: {output_root}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
