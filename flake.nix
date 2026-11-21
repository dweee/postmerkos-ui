{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs@{ self, ... }:
    inputs.utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages.default = pkgs.buildNpmPackage {
          pname = "postmerkos-ui";
          version = (builtins.fromJSON (builtins.readFile ./package.json)).version;
          src = self;
          npmDeps = pkgs.importNpmLock { npmRoot = self; };
          npmConfigHook = pkgs.importNpmLock.npmConfigHook;
          installPhase = "cp -r build $out";
        };
        devShells.default = with pkgs; mkShell {
          packages = [
            nodejs_22
            zip
            claude-code
          ];
        };
      }
    );
}
