# This data source looks up the latest Amazon Machine Image (AMI) that matches
# the criteria below. Terraform will then use the returned AMI ID for an EC2
# instance or any other resource that needs an image.
#
# In AWS, an AMI is a template for a VM image. The "aws_ami" data source lets
# us search the AWS account catalog for valid AMIs instead of hardcoding an ID.
data "aws_ami" "amiId" {
  # "most_recent = true" tells AWS: "give me the newest matching AMI".
  # This is useful when you want to automatically pick the latest Ubuntu image.
  most_recent = true

  # The "filter" block narrows the search using AWS AMI metadata.
  # Here we filter by the AMI name pattern. The value below matches Ubuntu 22.04
  # LTS (Jammy) official server images built for x86_64.
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  # Another filter: only keep AMIs that use hardware virtualization type "hvm".
  # This is the standard virtualization type used by modern EC2 AMIs.
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # "owners" tells AWS which account(s) are allowed to be searched for the AMI.
  # For Ubuntu public images, the owner is Canonical's AWS account:
  # "099720109477". This is the official account that publishes Ubuntu AMIs.
  #
  # IMPORTANT:
  # - If you leave this empty (""), AWS will not know which account to search.
  # - You must provide a valid AWS account ID or a list of IDs.
  # - In Terraform, this is a list of strings, so the syntax is ["..."]
  #
  # Why is this needed?
  # AWS does not let you search all accounts globally for AMIs. The "owners"
  # field restricts the search to trusted publishers such as Amazon, Canonical,
  # or your own AWS account.
  owners = ["099720109477"]
}

output "instance_id" {
  description = "AMI ID of Ubuntu Instance"
  value       = data.aws_ami.amiId.id
}