#iam plociy
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
          "ssm:GetParameter"
        ],
        "Resource": "arn:aws:ssm:us-east-1:637261222008:parameter/roboshop.dev.frontend.*"
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
#plociy attch
resource "aws_iam_role_policy_attachment" "role_attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}
#instance profile
resource "aws_iam_instance_profile" "profile" {
  name = "${var.component}-${var.env}-ssm-profile"
  role = aws_iam_role.role.name
}
#sg
resource "aws_security_group" "sg" {
  name        = "${var.component}-${var.env}-sg"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
}
#ec2
resource "aws_instance" "ec2" {
  ami           = data.aws_ami.ami.id
  instance_type = "t3.small"
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "${var.component}-${var.env}"
  }
}
#dns
resource "aws_route53_record" "web" {
  zone_id = "Z03052753T4U1K1QH805F"
  name    = "${var.component}-dev"
  type    = "A"
  ttl     = 30
  records = [aws_instance.ec2.private_ip]
}
#null resource

resource "null_resource" "roboshop" {
  depends_on = [aws_instance.ec2, aws_route53_record.web]
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "centos"
      password = "DevOps321"
      host     = aws_instance.ec2.public_ip

    }
    inline = [
      "sudo labauto ansible",
      "ansible-pull -i localhost, -U https://github.com/janardhanReddy-B/roboshop-ansible-b roboshop.yml -e env=${var.env} -e role_name=${var.component}",
    ]
  }
}