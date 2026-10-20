# Configures the AWS provider plugin. The region variable also determines which
# AMI is selected from the map in vars.tf.
provider "aws" {
  region = var.region
}