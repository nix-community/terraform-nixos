{ sources ? import ./sources.nix }:
with
  { overlay = _: pkgs:
      { inherit (import sources.niv {}) niv;
        inherit (import sources.gitignore { inherit (pkgs) lib; }) gitignoreSource;
        nix-pre-commit-hooks = import sources.nix-pre-commit-hooks;
      };
  };
import sources.nixpkgs
  { overlays = [ overlay ] ; config = {}; }
