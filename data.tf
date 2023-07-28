data "aws_ami" "ami" {
  most_recent      = true
  name_regex       = "Ansible"
  owners           = ["637261222008"]
}