# A simple, hermetic NixOS configuration for an AWS EC2 instance that
# uses a nixpkgs pinned to a specific Git revision with an integrity
# hash to ensure that we construct a NixOS system as purely as
# possible.
#
# i.e. we explicitly specify which nixpkgs to use instead of relying
# on the nixpkgs supplied on the NIX_PATH.
#
# The primary benefit of this is that it removes deployment surprises
# when other developers supply a different nix-channel in the NIX_PATH
# of their environment (even if you only add the 20.09 channel,
# nix-channel --update can mutate that channel to a 20.09 with
# backported changes).
#
# The secondary benefit is that you guard the `nixpkgs` you use, with
# an integrity hash.
let
  nixpkgs =
    let
      rev = "cd63096d6d887d689543a0b97743d28995bc9bc3";
      sha256 = "1wg61h4gndm3vcprdcg7rc4s1v3jkm5xd7lw8r2f67w502y94gcy";
    in
      builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
        inherit sha256;
      };

  system = "x86_64-linux";

  configuration = { config, pkgs, ... }: {
    imports = [
      "${nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
    ];

    ec2.hvm = true;

    networking.firewall.allowedTCPPorts = [ 22 80 ];

    environment.systemPackages = [
      pkgs.cloud-utils
    ];

    services.nginx = {
      enable = true;
      virtualHosts = {
        "_" = {
          root = pkgs.writeTextDir "html/index.html" ''
            <html>
              <body>
                <h1>This is a hermetic NixOS configuration!</h1>
              </body>
            </html>
          '';
        };
      };
    };
  };

in
  import "${nixpkgs}/nixos" { inherit system configuration; }
