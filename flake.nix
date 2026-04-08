{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.writeShellApplication {
          name = "gitlab-mirror";
          runtimeEnv.PATH = null;
          excludeShellChecks = [ "SC2123" ];
          runtimeInputs = with pkgs; [ coreutils-full util-linux gitMinimal openssh curl gnugrep gawk jq ];
          text = builtins.readFile ./gitlab-mirror.sh;
        };

        apps.default = {
          type = "app";
          program = pkgs.lib.getExe self.packages.${system}.default;
        };
      }
    );
}
