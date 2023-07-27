data "aws_ami" "ami" {

  most_recent      = true
  name_regex       = "Centos-8-DevOps-Practice"
  owners           = ["637261222008"]
}