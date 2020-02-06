{ pkgs ? import ./nix {} }:
{
  inherit (pkgs) pre-commit-check;
}
