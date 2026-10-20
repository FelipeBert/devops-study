# This resource creates an AWS EC2 key pair that can be used to connect to
# EC2 instances over SSH. The public key is uploaded to AWS, while the
# corresponding private key remains on the client side and should never be
# committed to source control.
resource "aws_key_pair" "dove-key" {
  # Logical name used in AWS; this is the identifier shown in the EC2 console.
  key_name = "dove-key"

  # Public SSH key material. In production, prefer sourcing this value from a
  # secure variable, secret manager, or a generated keypair instead of hardcoding
  # it directly in the Terraform file.
  public_key = ""
}
