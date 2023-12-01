{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      myTex = pkgs.buildPackages.texlive.combine {
        inherit (pkgs.buildPackages.texlive)
          scheme-small

          # From usepackages
          babel
          datetime
          fmtcount

          capt-of
          svg
          trimspaces
          catchfile
          transparent
          totpages
          environ
          hyperxmp
          ncctools # for manyfoot
          acronym
          wrapfig
          preprint
          xstring
          ifmtarg
          comment
          minted
          bigfoot
          todonotes
          libertine
          inconsolata
          newtx
          enumitem

          biber
          latexmk
        ;
      };
    in {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.bashInteractive ];
        buildInputs = with pkgs; [ R
                                   rPackages.tidyverse
                                   rPackages.languageserver
                                   rPackages.svglite
                                   rPackages.ggridges
                                   rPackages.rstatix
                                   rPackages.tables
                                   pandoc
                                   myTex
                                   neofetch
                                 ];
       };
    });
}
