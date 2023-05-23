{self, ...}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: let
    version = "1.04pre";
    texCombined = pkgs.texlive.combine {
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

        nativeBuildInputs = [texCombined];

        makeFlags = ["PREFIX=$(out)" "LATEX=${engine}" "SUDO="];

        configurePhase = ''
          export TEMP=$(pwd)
          export HOME=$(pwd)
        '';
      };
  in {
    packages = {
      inherit texCombined;

      xelatex = builder "xelatex";
      lualatex = builder "lualatex";
      pdflatex = builder "pdflatex";

      default = self'.packages.xelatex;

      zip = stdenvNoCC.mkDerivation {
        pname = "listlbls";
        inherit version;

        src = "${self}";

        nativeBuildInputs = [pkgs.zip texCombined];

        makeFlags = ["zip" "VERS=$(version)"];

        installPhase = ''
          mkdir $out
          install --mode 444 $pname-$version.zip $out/$pname-$version.zip
        '';
      };
    };
  };
}
