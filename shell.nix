{ pkgs ? import <nixpkgs> {} }:

let
  render-mermaid-assets = pkgs.writeShellApplication {
    name = "render-mermaid-assets";
    runtimeInputs = [
      pkgs.mermaid-cli
      pkgs.python3
    ];
    text = ''
      exec python3 ${./renderer/render-mermaid-assets.py} "$@"
    '';
  };
in
pkgs.mkShell {
  packages = [
    pkgs.mermaid-cli
    pkgs.python3
    render-mermaid-assets
  ];

  shellHook = ''
    echo "Mermaid Nix shell ready."
    echo "Run: render-mermaid-assets --help"
  '';
}
