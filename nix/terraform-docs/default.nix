{ lib, buildGoPackage, fetchFromGitHub }:
buildGoPackage rec {
  name = "${pname}-${version}";
  pname = "terraform-docs";
  version = "0.8.2";

  goPackagePath = "github.com/segmentio/${pname}";

  src = fetchFromGitHub {
    owner  = "segmentio";
    repo   = pname;
    rev    = "v${version}";
    sha256 = "0g85j43l6v2cwmymc1knbziyay8rarr9ynlsa7imjvwn4ib1926s";
  };

  preBuild = ''
    buildFlagsArray+=("-ldflags" "-X main.version=${version}")
  '';

  meta = with lib; {
    description = "A utility to generate documentation from Terraform modules in various output formats.";
    homepage = "https://${goPackagePath}/";
    license = licenses.mit;
    maintainers = with maintainers; [ zimbatm ];
  };
}
