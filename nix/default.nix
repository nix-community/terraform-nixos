{ sources ? import ./sources.nix }:
with
  { overlay = _: pkgs:
      { inherit (import sources.niv {}) niv;
        inherit (import sources.nix-pre-commit-hooks) pre-commit-check;
      };
  };
import sources.nixpkgs
  { overlays = [ overlay ] ; config = {}; }
