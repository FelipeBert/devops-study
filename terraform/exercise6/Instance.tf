# Launches the EC2 web server. References to variables and other resources
# create Terraform dependencies, so the key pair and security group are ready
# before the instance is created.
resource "aws_instance" "web" {
  # Select the AMI (machine image) for the configured AWS region.
  ami = var.amiID[var.region]
  # t3.micro is a small instance type; confirm its availability and cost for your account.
  instance_type = "t3.micro"
  # Attach the AWS key pair and security group created in the other files.
  key_name               = aws_key_pair.dove-key.key_name
  vpc_security_group_ids = [aws_security_group.dove-sg.id]
  # Pin the instance to the configured Availability Zone within the region.
  availability_zone = var.zone

  # Tags are metadata used for identification, organization, and cost reporting.
  tags = {
    Name    = "Dove-web"
    Project = "Dove"
  }

  # Terraform uses this SSH connection for the provisioners below.
  # The private key file must exist locally and match the public key registered in AWS.
  connection {
    type        = "ssh"
    user        = var.webuser
    private_key = file("dovekey")
    host        = self.public_ip
  }

  # Copy the local setup script to the instance before running it remotely.
  provisioner "file" {
    source      = "web.sh"
    destination = "/tmp/web.sh"
  }

  # Make the copied script executable, then run it with elevated privileges.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/web.sh",
      "sudo /tmp/web.sh"
    ]
  }

  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }
}

# Explicitly manage the instance's power state. This does not create another
# instance; it refers to the EC2 instance declared above.
resource "aws_ec2_instance_state" "web-state" {
  instance_id = aws_instance.web.id
  state       = "running"
}

# Outputs expose useful values after `terraform apply` and can also be read by
# other Terraform configurations when this module is used as a child module.
# The public IP is reachable from the internet only if the network and security
# group rules allow it; it may change if the instance is replaced.
output "web_public_ip" {
  # A human-readable description appears in the output metadata.
  description = "Public Ip"
  # Reference the instance attribute directly; Terraform resolves it after creation.
  value = aws_instance.web.public_ip
}

# The private IP is used for communication inside the VPC and is not generally
# reachable directly from the public internet. `terraform output` displays it
# after the instance has been created.
output "web_private_ip" {
  # Keep descriptions concise and use consistent capitalization in real projects.
  description = "Private Ip"
  # This value is computed by AWS for the created instance.
  value = aws_instance.web.private_ip
}