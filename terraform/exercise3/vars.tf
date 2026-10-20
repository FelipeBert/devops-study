variable "region" {
  default = "sa-east-1"
}

variable "zone" {
  default = "sa-east-1a"
}

variable "amiID" {
  type = map(string)
  default = {
    sa-east-1 = "ami-05401e1394491333f"
    us-east-1 = "ami-0b6d9d3d33ba97d99"
  }
}