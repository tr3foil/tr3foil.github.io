{

description = "pyrosite: my personal website";

inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  yip.url = "github:tr3foil/yip/main";
  phosphor.url = "github:tr3foil/phosphor/main";
};

outputs = { self, nixpkgs, yip, phosphor }: let
  supportedSystems = nixpkgs.lib.systems.flakeExposed;
  allSystems = output: nixpkgs.lib.genAttrs supportedSystems
    (system: output nixpkgs.legacyPackages.${system});
in {
  packages = allSystems (pkgs: {
    default = pkgs.stdenv.mkDerivation {
      name = "static site";
      src = ./site;
      buildInputs = [
        pkgs.fd
        yip.packages.${pkgs.system}.default
      ];
      buildPhase = ''
        fd -t d -E assets/ -E templates/ -x mkdir -p out/{};
        fd -t f -E assets/ -E templates/ -e html -e css -x sh -c 'yip {} > out/{}';
      '';
      installPhase = ''
        mkdir -p $out/site;
        cp -r out/* $out/site;
        cp -r assets/ $out/site;
        cp ${phosphor.packages.${pkgs.system}.css} $out/site/styles/colors.css
      '';
    };
  });
};

}
