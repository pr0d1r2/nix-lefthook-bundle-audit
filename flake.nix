{
  description = "Lefthook-compatible bundle-audit check";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";
    nix-dev-shell-agentic = {
      url = "github:pr0d1r2/nix-dev-shell-agentic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-bats-unit-src = {
      url = "github:pr0d1r2/nix-lefthook-bats-unit";
      flake = false;
    };
    nix-lefthook-commit-msg-lint-src = {
      url = "github:pr0d1r2/nix-lefthook-commit-msg-lint";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-dev-shell-agentic,
      nix-lefthook-bats-unit-src,
      nix-lefthook-commit-msg-lint-src,
      ...
    }@inputs:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (
        pkgs:
        let
          shells = nix-dev-shell-agentic.lib.mkShells {
            inherit pkgs inputs;
            ciPackages = [
              (pkgs.writeShellApplication {
                name = "lefthook-bats-unit";
                runtimeInputs = [
                  pkgs.bats
                  pkgs.coreutils
                  pkgs.parallel
                ];
                text = builtins.readFile "${nix-lefthook-bats-unit-src}/lefthook-bats-unit.sh";
              })
              (pkgs.writeShellApplication {
                name = "lefthook-commit-msg-lint";
                runtimeInputs = [
                  pkgs.coreutils
                  pkgs.gnused
                ];
                text = builtins.readFile "${nix-lefthook-commit-msg-lint-src}/lefthook-commit-msg-lint.sh";
              })
            ];
            shellHook = builtins.replaceStrings [ "@BATS_LIB_PATH@" ] [ "${shells.batsWithLibs}" ] (
              builtins.readFile ./dev.sh
            );
          };
        in
        shells
      );
    };
}
