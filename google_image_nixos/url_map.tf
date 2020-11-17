# DON'T EDIT, run $0 instead
variable "url_map" {
  type = map(string)

  default = {
    "14.12"  = "https://nixos-cloud-images.storage.googleapis.com/nixos-14.12.471.1f09b77-x86_64-linux.raw.tar.gz"
    "15.09"  = "https://nixos-cloud-images.storage.googleapis.com/nixos-15.09.425.7870f20-x86_64-linux.raw.tar.gz"
    "16.03"  = "https://nixos-cloud-images.storage.googleapis.com/nixos-image-16.03.847.8688c17-x86_64-linux.raw.tar.gz"
    "17.03"  = "https://nixos-cloud-images.storage.googleapis.com/nixos-image-17.03.1082.4aab5c5798-x86_64-linux.raw.tar.gz"
    "18.03"  = "https://nixos-cloud-images.storage.googleapis.com/nixos-image-18.03.132536.fdb5ba4cdf9-x86_64-linux.raw.tar.gz"
    "18.09"  = "https://nixos-cloud-images.storage.googleapis.com/nixos-image-18.09.1228.a4c4cbb613c-x86_64-linux.raw.tar.gz"
    "latest" = "https://nixos-cloud-images.storage.googleapis.com/nixos-image-18.09.1228.a4c4cbb613c-x86_64-linux.raw.tar.gz"
  }

  description = "A map of release series to actual releases"
}
