from __future__ import annotations

import os
import shutil
import tempfile
from pathlib import Path

from common import find_command, run, slugify


def find_structurizr() -> str:
    return find_command(["structurizr", "structurizr-cli", "structurizr.sh"])


def find_plantuml() -> str:
    return find_command(["plantuml"])


def render_plantuml_file(plantuml: str, source_file: Path, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    run([plantuml, "-tsvg", "--output-dir", str(output_dir), str(source_file)])


def render_structurizr_dsl(source_root: Path, output_root: Path, source: Path, structurizr: str, plantuml: str) -> bool:
    relative = source.relative_to(source_root)
    export_root = Path(tempfile.mkdtemp(prefix="structurizr-export-"))
    rendered = False
    try:
        run(
            [
                structurizr,
                "export",
                "-workspace",
                str(source),
                "-format",
                "plantuml/c4plantuml",
                "-output",
                str(export_root),
            ]
        )

        for puml_file in sorted(export_root.rglob("*.puml")):
            relative_export = puml_file.relative_to(export_root)
            temp_svg_dir = Path(tempfile.mkdtemp(prefix="plantuml-export-"))
            try:
                render_plantuml_file(plantuml, puml_file, temp_svg_dir)
                final_dir = output_root / "c4" / relative.parent / source.stem / relative_export.parent
                final_dir.mkdir(parents=True, exist_ok=True)

                for svg_file in sorted(temp_svg_dir.glob("*.svg")):
                    final_name = f"{slugify(svg_file.stem) or 'diagram'}.svg"
                    shutil.move(str(svg_file), str(final_dir / final_name))
                    rendered = True
            finally:
                shutil.rmtree(temp_svg_dir, ignore_errors=True)
    finally:
        shutil.rmtree(export_root, ignore_errors=True)

    return rendered


def render_structurizr_sources(source_roots: list[Path], output_root: Path, structurizr: str, plantuml: str) -> bool:
    rendered_any = False
    for source_root in source_roots:
        if not source_root.exists():
            print(f"Skipping {source_root} because it does not exist.")
            continue

        for current_root, dirnames, filenames in os.walk(source_root):
            dirnames[:] = sorted(d for d in dirnames if d not in {".git", "assets", "node_modules"})
            current = Path(current_root)
            for filename in sorted(filenames):
                source = current / filename
                if source.suffix.lower() != ".dsl":
                    continue
                rendered_any |= render_structurizr_dsl(source_root, output_root, source, structurizr, plantuml)
    return rendered_any
