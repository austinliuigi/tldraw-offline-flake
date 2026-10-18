{
  description = "flake for tldraw-offline appimage";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      tldraw-offline = pkgs.callPackage ./. {};
    in {
      inherit tldraw-offline;
      default = tldraw-offline;
    });

    overlays.default = final: prev: {
      tldraw-offline = final.callPackage ./. {};
    };
  };
}
