#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path

from mermaid_renderer import find_mmdc, render_mermaid_sources


def main() -> int:
    allowed_roots = ["class-diagrams", "context-mapping"]
    parser = argparse.ArgumentParser(description="Render Mermaid diagrams into SVG assets.")
    parser.add_argument(
        "--source-root",
        nargs="*",
        choices=allowed_roots,
        default=allowed_roots,
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
        import shutil

        shutil.rmtree(output_root)

    c4_output = output_root / "c4"
    if c4_output.exists():
        import shutil

        shutil.rmtree(c4_output)

    mmdc = find_mmdc()
    rendered_mermaid = render_mermaid_sources(source_roots, output_root, mmdc)

    if not rendered_mermaid:
        print("No Mermaid sources were found.")
        return 0

    print(f"SVGs generated in: {output_root}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
