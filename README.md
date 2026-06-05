# Vanana C4 Model

This repository contains the Mermaid diagram sources for the Vanana platform.

## Diagram Rendering

The project uses a plain `shell.nix` so you can enter a reproducible environment and generate Mermaid diagrams to SVG.

### Tools included

- Mermaid CLI for Markdown files with Mermaid blocks
- Python renderer that extracts Mermaid blocks and writes SVG assets

### Output layout

- Mermaid diagrams go to `assets/class-diagrams/...`
- Context maps go to `assets/context-mapping/...`

### Usage

```bash
nix-shell
render-diagrams --clean
```

`--clean` removes the previous `assets/` directory before regenerating everything.
