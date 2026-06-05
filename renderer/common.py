from __future__ import annotations

import os
import re
import shutil
import subprocess
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


def find_command(candidates: list[str]) -> str:
    for candidate in candidates:
        path = shutil.which(candidate)
        if path:
            return path
    raise SystemExit(f"Could not find any of these commands in PATH: {', '.join(candidates)}")


def slugify(text: str) -> str:
    text = text.lower()
    text = re.sub(r"[^a-z0-9]+", "-", text)
    return text.strip("-")


def iter_markdown_files(root: Path) -> list[Path]:
    files: list[Path] = []
    for current_root, dirnames, filenames in os.walk(root):
        dirnames[:] = sorted(d for d in dirnames if d not in {".git", "assets", "node_modules"})
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
            blocks.append(MermaidBlock(heading=last_heading, order=order, text="\n".join(block_lines).strip()))
        i += 1

    return blocks
