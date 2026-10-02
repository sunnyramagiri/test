provider "aws" {
    region = "ap-south-2"
    access_key = ""
    secret_key = ""
  
}


############################################################
# EC2 KEY PAIR
############################################################

resource "aws_key_pair" "sunny_key" {
  key_name   = "sunny-key"
  public_key = file("${path.module}/sunny-key.pub")
}


############################################################
# SSH SECURITY GROUP
############################################################

resource "aws_security_group" "ssh_access" {
  name        = "terraform-ssh-access"
  description = "Allow SSH access to EC2 instances"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    # Testing only.
    # For production, use your public IP/32.
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-ssh-access"
  }
}


############################################################
# EC2 INSTANCES
############################################################

resource "aws_instance" "multi_ec2" {
  count = 3

  ami           = "ami-0a717262ea9adab3f"
  instance_type = "t3.micro"

  # Use the key pair created above
  key_name = aws_key_pair.sunny_key.key_name

  # Attach SSH security group
  vpc_security_group_ids = [
    aws_security_group.ssh_access.id
  ]

  # Give the instances public IP addresses
  associate_public_ip_address = true

  tags = {
    Name = "test-${count.index + 1}"
  }
}


############################################################
# S3 BUCKET
############################################################

resource "aws_s3_bucket" "test_bucket" {
  bucket = "test-bucket-20342301-12345"

  tags = {
    Name = "test-bucket"
  }
}


############################################################
# IAM GROUP
############################################################

resource "aws_iam_group" "s3_user" {
  name = "sunny_ramagiri"
}


############################################################
# IAM USER
############################################################

resource "aws_iam_user" "s3_user" {
  name = "software_tranee"
}


############################################################
# ADD USER TO GROUP
############################################################

resource "aws_iam_user_group_membership" "s3_user" {
  user = aws_iam_user.s3_user.name

  groups = [
    aws_iam_group.s3_user.name
  ]
}


############################################################
# OUTPUTS
############################################################

output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = aws_instance.multi_ec2[*].public_ip
}

output "instance_public_dns" {
  description = "Public DNS names of the EC2 instances"
  value       = aws_instance.multi_ec2[*].public_dns
}

output "ssh_command" {
  description = "SSH command for the first EC2 instance"
  value       = "ssh -i sunny-key ec2-user@${aws_instance.multi_ec2[0].public_ip}"
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.test_bucket.bucket
}

output "iam_user_name" {
  description = "IAM user name"
  value       = aws_iam_user.s3_user.name
}
