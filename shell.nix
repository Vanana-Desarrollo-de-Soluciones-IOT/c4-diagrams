{ pkgs ? import <nixpkgs> {} }:

let
  rendererSupport = pkgs.runCommand "renderer-support" { } ''
    mkdir -p "$out/renderer"
    cp ${./renderer/common.py} "$out/renderer/common.py"
    cp ${./renderer/mermaid_renderer.py} "$out/renderer/mermaid_renderer.py"
    cp ${./renderer/render-mermaid-assets.py} "$out/renderer/render-mermaid-assets.py"
  '';

  renderCommand = ''
    export PYTHONPATH="${rendererSupport}/renderer${PYTHONPATH:+:$PYTHONPATH}"
    exec python3 ${rendererSupport}/renderer/render-mermaid-assets.py "$@"
  '';

  render-mermaid-assets = pkgs.writeShellApplication {
    name = "render-mermaid-assets";
    runtimeInputs = [
      pkgs.mermaid-cli
      pkgs.python3
    ];
    text = renderCommand;
  };

  render-diagrams = pkgs.writeShellApplication {
    name = "render-diagrams";
    runtimeInputs = [
      pkgs.mermaid-cli
      pkgs.python3
    ];
    text = renderCommand;
  };
in
pkgs.mkShell {
  packages = [
    pkgs.mermaid-cli
    pkgs.python3
    render-mermaid-assets
    render-diagrams
  ];

  shellHook = ''
    echo "Vanana diagram rendering shell ready."
    echo
    echo "What this shell provides:"
    echo "  - Mermaid CLI for Markdown Mermaid blocks"
    echo "  - Python renderer for Mermaid assets"
    echo
    echo "How to generate diagrams:"
    echo "  1. Enter the shell: nix-shell"
    echo "  2. Render all diagrams: render-mermaid-assets --clean"
    echo "     or: render-diagrams --clean"
    echo
    echo "Output:"
    echo "  - Mermaid SVGs: assets/class-diagrams/... and assets/context-mapping/..."
  '';
}
