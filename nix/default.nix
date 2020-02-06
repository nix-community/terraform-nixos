{ sources ? import ./sources.nix }:
with
  { overlay = self: pkgs:
      { inherit (import sources.niv {}) niv;
        inherit (import sources."gitignore.nix" { inherit (pkgs) lib; }) gitignoreSource;
        nix-pre-commit-hooks = import sources.nix-pre-commit-hooks;
        pre-commit-check =
          self.nix-pre-commit-hooks.run {
            src = self.gitignoreSource ../.;
            hooks.shellcheck.enable = true;
            hooks.terraform-format.enable = true;
          };
      };
  };
import sources.nixpkgs
  { overlays = [ overlay ] ; config = {}; }
