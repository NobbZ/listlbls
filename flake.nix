{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
  inputs.parts.url = "github:hercules-ci/flake-parts";

  outputs = {parts, ...} @ inputs:
    parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

      perSystem = {
        self,
        inputs',
        self',
        pkgs,
        ...
      }: {
        formatter = pkgs.alejandra;

        packages = let
          version = "1.04pre";
          tl = pkgs.texlive.combine {
            inherit
              (pkgs.texlive)
              scheme-minimal
              collection-luatex
              babel-english
              caption
              dtxdescribe
              etoolbox
              fancyvrb
              geometry
              graphics
              hypdoc
              hyperref
              infwarerr
              kvoptions
              latex-bin
              microtype
              newfloat
              pdftexcmds
              pict2e
              tools
              translations
              xcolor
              xetex
              xstring
              ;
          };
          inherit (pkgs) stdenvNoCC;
          builder = engine:
            stdenvNoCC.mkDerivation {
              pname = "listllbls";
              version = "${version}-${engine}";

              src = "${self}";

              nativeBuildInputs = [tl];

              makeFlags = ["PREFIX=$(out)" "LATEX=${engine}" "SUDO="];

              configurePhase = ''
                export TEMP=$(pwd)
                export HOME=$(pwd)
              '';
            };
        in {
          inherit tl;

          xelatex = builder "xelatex";
          lualatex = builder "lualatex";
          pdflatex = builder "pdflatex";

          zip = stdenvNoCC.mkDerivation {
            pname = "listlbls";
            inherit version;

            src = "${self}";

            nativeBuildInputs = [pkgs.zip tl];

            makeFlags = ["zip" "VERS=$(version)"];

            installPhase = ''
              mkdir $out
              install --mode 444 $pname-$version.zip $out/$pname-$version.zip
            '';
          };
        };

        devShells.default = let
          inherit (self'.packages) tl;
        in
          pkgs.mkShellNoCC {
            packages = builtins.attrValues {
              inherit (pkgs) gnumake;
              inherit tl;
            };
          };
      };
    };
}
