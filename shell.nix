{ pkgs ? import <nixpkgs> {} }:

let
  rendererSupport = pkgs.runCommand "renderer-support" { } ''
    mkdir -p "$out/renderer"
    cp ${./renderer/common.py} "$out/renderer/common.py"
    cp ${./renderer/mermaid_renderer.py} "$out/renderer/mermaid_renderer.py"
    cp ${./renderer/structurizr_renderer.py} "$out/renderer/structurizr_renderer.py"
    cp ${./renderer/render-mermaid-assets.py} "$out/renderer/render-mermaid-assets.py"
  '';

  render-mermaid-assets = pkgs.writeShellApplication {
    name = "render-mermaid-assets";
    runtimeInputs = [
      pkgs.mermaid-cli
      pkgs.plantuml
      pkgs.structurizr-cli
      pkgs.python3
    ];
    text = ''
      export PYTHONPATH="${rendererSupport}/renderer${PYTHONPATH:+:$PYTHONPATH}"
      exec python3 ${rendererSupport}/renderer/render-mermaid-assets.py "$@"
    '';
  };
in
pkgs.mkShell {
  packages = [
    pkgs.mermaid-cli
    pkgs.plantuml
    pkgs.structurizr-cli
    pkgs.python3
    render-mermaid-assets
  ];

  shellHook = ''
    echo "Vanana diagram rendering shell ready."
    echo
    echo "What this shell provides:"
    echo "  - Mermaid CLI for Markdown Mermaid blocks"
    echo "  - Structurizr CLI for C4 .dsl files"
    echo "  - PlantUML for SVG generation"
    echo
    echo "How to generate everything:"
    echo "  1. Enter the shell: nix-shell"
    echo "  2. Render all diagrams: render-mermaid-assets --clean"
    echo
    echo "Output:"
    echo "  - Mermaid SVGs: assets/class-diagrams/... and assets/context-mapping/..."
    echo "  - C4 SVGs: assets/c4/..."
  '';
}
