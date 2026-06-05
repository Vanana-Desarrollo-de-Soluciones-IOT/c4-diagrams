#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path

from mermaid_renderer import find_mmdc, render_mermaid_sources
from structurizr_renderer import find_plantuml, find_structurizr, render_structurizr_sources


def main() -> int:
    parser = argparse.ArgumentParser(description="Render Mermaid and Structurizr diagrams into SVG assets.")
    parser.add_argument(
        "--source-root",
        nargs="*",
        default=["class-diagrams", "context-mapping", "c4"],
        help="Source directories to scan. Defaults to class-diagrams, context-mapping, and c4.",
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

    mmdc = find_mmdc()
    structurizr = find_structurizr()
    plantuml = find_plantuml()

    rendered_mermaid = render_mermaid_sources([root for root in source_roots if root.name in {"class-diagrams", "context-mapping"}], output_root, mmdc)
    rendered_structurizr = render_structurizr_sources([root for root in source_roots if root.name == "c4"], output_root, structurizr, plantuml)

    if not rendered_mermaid and not rendered_structurizr:
        print("No Mermaid or Structurizr sources were found.")
        return 0

    print(f"SVGs generated in: {output_root}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
