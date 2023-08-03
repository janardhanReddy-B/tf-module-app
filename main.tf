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
  iam_instance_profile = aws_iam_instance_profile.profile.name

  tags = merge ({
    Name = "${var.component}-${var.env}"
  },
  var.tags)
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
