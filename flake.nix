{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
  inputs.parts.url = "github:hercules-ci/flake-parts";

  outputs = {parts, ...} @ inputs:
    parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
      imports = [./packages];

      perSystem = {
        inputs',
        self',
        pkgs,
        ...
      }: {
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShellNoCC {
          packages = builtins.attrValues {
            inherit (pkgs) gnumake;
            inherit (self'.packages) texCombined;
          };
        };
      };
    };
}
