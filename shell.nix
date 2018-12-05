with import <nixpkgs> {};
let
  tf = terraform.withPlugins(p: with p; [
    external
    google
    p.null
    random
  ]);
  # https://github.com/NixOS/nixpkgs/pull/51579
  terraform-docs = callPackage ./nix/terraform-docs {};
in
mkShell {
  buildInputs = [
    tf
    terraform-docs
  ];
}
