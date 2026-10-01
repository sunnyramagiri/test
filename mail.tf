

########## creating the EC2_instance#########

resource "aws_instance" "multi_ec2" {
    ami = "ami-0a717262ea9adab3f"
    count = 3
    instance_type = "t3.micro"
    tags = {
      "name" = "test"
    }
  
}


##########creating_s3_bucket######
resource "aws_s3_bucket" "test_bucket" {
    bucket = "test-bucket-20342301-12345"
}

#######create_user########

resource "aws_iam_group" "s3_user" {
    name = "sunny_ramagiri"
  
}


resource "aws_iam_user" "s3_user" {
    name = "software_tranee"
    
  
}

resource "aws_iam_user_group_membership" "s3_user" {
    user = aws_iam_user.s3_user.name
    groups = [
        aws_iam_group.s3_user.name
    ]
  
}