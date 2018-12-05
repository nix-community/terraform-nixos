{ modulesPath, ... }:
{
  imports = [
    # Make sure to have this in all your configurations
    "${toString modulesPath}/virtualisation/google-compute-image.nix"
  ];

  # Bake the deploy's SSH key into the image. This is not
  # kosher Nix.
  users.users.root.openssh.authorizedKeys.keyFiles = [
    (/. + builtins.getEnv("HOME") + "/.ssh/id_rsa.pub")
  ];
}
