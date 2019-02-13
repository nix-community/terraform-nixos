{ modulesPath, config, pkgs, lib, ... }:

let
  cfg = config;

  hydraPort = 3000;
  hydraAdmin = "admin";
  hydraAdminPassword = "VZE9uRiM4r0";

  createDeclarativeProjectScript = pkgs.stdenv.mkDerivation {
    name = "create-declarative-project";
    unpackPhase = ":";
    buildInputs = [ pkgs.makeWrapper ];
    installPhase = "install -m755 -D ${./create-declarative-project.sh} $out/bin/create-declarative-project";
    postFixup = ''wrapProgram "$out/bin/create-declarative-project" --prefix PATH ":" ${pkgs.stdenv.lib.makeBinPath [ pkgs.curl ]}'';
  };

in
{
  imports = [ "${toString modulesPath}/../maintainers/scripts/openstack/openstack-image.nix" ];

  config =  {
    networking.firewall.allowedTCPPorts = [ hydraPort ];

    services.hydra = {
      enable = true;
      hydraURL = "example.com";
      notificationSender = "root@localhost";
      port = hydraPort;
    };

    nix = {
      buildMachines = [{
        hostName = "localhost";
        systems = [ "x86_64-linux" ];
      }];
    };

    # Create a admin user and configure a declarative project
    systemd.services.hydra-post-init = {
      serviceConfig = {
        Type = "oneshot";
        TimeoutStartSec = "60";
      };
      wantedBy = [ "multi-user.target" ];
      after = ["hydra-server.service" ];
      requires = [ "hydra-server.service" ];
      environment = {
        inherit (cfg.systemd.services.hydra-init.environment) HYDRA_DBI;
      };
      path = with pkgs; [ hydra netcat ];
      script = ''
        set -e
        hydra-create-user ${hydraAdmin} --role admin --password ${hydraAdminPassword}
        while ! nc -z localhost ${toString hydraPort}; do
          sleep 1
        done

        export HYDRA_ADMIN_PASSWORD=${hydraAdminPassword}
        export URL=http://localhost:${toString hydraPort} 
        export DECL_VALUE="https://github.com/shlevy/declarative-hydra-example"
        ${createDeclarativeProjectScript}/bin/create-declarative-project
      '';
    };
  };
}
