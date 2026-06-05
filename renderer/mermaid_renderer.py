from __future__ import annotations

import re
import tempfile
from pathlib import Path

from common import extract_mermaid_blocks, find_command, iter_markdown_files, run, slugify


def find_mmdc() -> str:
    return find_command(["mmdc"])


def normalize_heading(heading: str, source_root_name: str) -> str:
    clean = heading.strip()
    clean = re.sub(r"^\d+(?:\.\d+)*\.?\s*", "", clean)

    if source_root_name == "context-mapping":
        return "context-mapping"

    if "unified" in clean.lower():
        return "unified"

    if clean.lower().startswith("context mapping"):
        return "context-mapping"

    if clean.lower().endswith("layer"):
        label = re.sub(r"\s+Layer$", "", clean, flags=re.IGNORECASE).strip()
        return f"{slugify(label)}-layer"

    return slugify(clean) or "diagram"


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


def render_markdown_file(source_root: Path, output_root: Path, source: Path, mmdc: str) -> bool:
    relative = source.relative_to(source_root)
    blocks = extract_mermaid_blocks(source)
    if not blocks:
        return False

    source_scope = source_root.name
    file_dir = output_root / source_scope / relative.parent / source.stem
    used_names: dict[str, int] = {}

    for block in blocks:
        base_name = normalize_heading(block.heading, source_scope)
        count = used_names.get(base_name, 0) + 1
        used_names[base_name] = count
        if count > 1:
            base_name = f"{base_name}-{count:02d}"

        render_mermaid_block(mmdc, block.text, file_dir / f"{base_name}.svg")

    return True


def render_mermaid_sources(source_roots: list[Path], output_root: Path, mmdc: str) -> bool:
    rendered_any = False
    for source_root in source_roots:
        if not source_root.exists():
            print(f"Skipping {source_root} because it does not exist.")
            continue
        for source in iter_markdown_files(source_root):
            rendered_any |= render_markdown_file(source_root, output_root, source, mmdc)
    return rendered_any
