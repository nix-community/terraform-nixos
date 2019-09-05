{ pkgs ? import ./nix {} }:
let
  inherit (pkgs) nix-pre-commit-hooks gitignoreSource;
in
{
  # This can run on CI to catch
  #  - interactions between files that were missed due to pre-commit's incremental checks
  #     (if applicable to the selected rules
  #  - contributors that haven't installed pre-commit (by opening nix-shell)
  pre-commit-check =
    nix-pre-commit-hooks.run { src = gitignoreSource ./.; };
}
