data "http" "myPublicIpv4" {
  url = "http://ipv4.icanhazip.com"
}

variable "public_key" {
  type        = string
  description = "File path of public key."
  default     = "~/.ssh/id_rsa.pub"
}
