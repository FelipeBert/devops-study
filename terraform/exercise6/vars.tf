# AWS region used for resource placement and AMI selection.
variable "region" {
  default = "sa-east-1"
}

# Availability Zone must belong to the selected region.
variable "zone" {
  default = "sa-east-1a"
}

# SSH login name for the AMI; Ubuntu images commonly use "ubuntu".
variable "webuser" {
  default = "ubuntu"
}

# Maps each supported AWS region to an AMI ID. AMI IDs are region-specific,
# so the selected region must have a matching entry.
variable "amiID" {
  type = map(string)
  default = {
    sa-east-1 = "ami-05401e1394491333f"
    us-east-1 = "ami-0b6d9d3d33ba97d99"
  }
}