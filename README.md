# Vanana C4 Model

This repository contains the C4 model for the Vanana platform.

## Diagram Rendering

The project uses a plain `shell.nix` so you can enter a reproducible environment and generate all diagrams to SVG.

### Tools included

- Mermaid CLI for Markdown files with Mermaid blocks
- Structurizr CLI for `.dsl` files under `c4/`
- PlantUML for SVG generation from Structurizr exports

### Output layout

- Mermaid diagrams go to `assets/class-diagrams/...`
- Context maps go to `assets/context-mapping/...`
- Structurizr C4 diagrams go to `assets/c4/...`

### Usage

```bash
nix-shell
render-mermaid-assets --clean
```

`--clean` removes the previous `assets/` directory before regenerating everything.
