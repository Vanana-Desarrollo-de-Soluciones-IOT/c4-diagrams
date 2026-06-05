from __future__ import annotations

import os
import re
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


def camel_to_kebab(text: str) -> str:
    text = text.replace("_", "-")
    text = text.replace(" ", "-")
    text = text.replace("/", "-")
    text = re.sub(r"(?<!^)(?=[A-Z])", "-", text).lower()
    text = re.sub(r"-+", "-", text)
    return text.strip("-")


def source_output_dir(source_root: Path, source: Path) -> Path:
    relative_parent = source.parent.relative_to(source_root)
    if str(relative_parent) == ".":
        return Path(source.stem)
    return relative_parent


def export_output_name(puml_file: Path) -> str:
    stem = puml_file.stem
    if stem.startswith("structurizr-"):
        stem = stem.removeprefix("structurizr-")
    stem = camel_to_kebab(stem)
    return slugify(stem) or "diagram"


def render_structurizr_dsl(source_root: Path, output_root: Path, source: Path, structurizr: str, plantuml: str) -> bool:
    source_dir = source_output_dir(source_root, source)
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
            temp_svg_dir = Path(tempfile.mkdtemp(prefix="plantuml-export-"))
            try:
                render_plantuml_file(plantuml, puml_file, temp_svg_dir)
                final_dir = output_root / "c4" / source_dir
                final_dir.mkdir(parents=True, exist_ok=True)

                rendered_svgs = sorted(temp_svg_dir.glob("*.svg"))
                for index, svg_file in enumerate(rendered_svgs, start=1):
                    suffix = "" if len(rendered_svgs) == 1 else f"-{index:02d}"
                    final_name = f"{export_output_name(puml_file)}{suffix}.svg"
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
