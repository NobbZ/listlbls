{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
    ...
  }: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    packages.x86_64-linux = let
      version = "1.04pre";
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
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

    devShells.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      inherit (self.packages.x86_64-linux) tl;
    in
      pkgs.mkShellNoCC {
        packages = builtins.attrValues {
          inherit (pkgs) gnumake;
          inherit tl;
        };
      };
  };
}
