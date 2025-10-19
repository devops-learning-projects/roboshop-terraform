resource "aws_iam_role" "main" {
  name = var.is_tool ? "${var.name}-ec2-role" : "${var.name}-${var.env}-ec2-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# iam role instance profile. without it we cann't add the role with any instance
resource "aws_iam_instance_profile" "main" {
  name = var.is_tool ? "${var.name}-ec2-role" : "${var.name}-${var.env}-ec2-role"
  role = aws_iam_role.main.name
}