#iam policy
resource "aws_iam_policy" "policy" {
  name        = "${var.component}-${var.env}-ssm-policy"
  path        = "/"
  description = "${var.component}-${var.env}-ssm-policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "kms:Decrypt"
        ],
        "Resource" : concat([
          "arn:aws:ssm:us-east-1:637261222008:parameter/roboshop.${var.env}.${var.component}.*"
          var.kms_arn
        ], var.extra_param_access)
      }
      }
    ]
  })
}
#role
resource "aws_iam_role" "role" {
  name = "${var.component}-${var.env}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}
#plociy attach
resource "aws_iam_role_policy_attachment" "role_attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}
#instance profile
resource "aws_iam_instance_profile" "profile" {
  name = "${var.component}-${var.env}-ssm-profile"
  role = aws_iam_role.role.name
}