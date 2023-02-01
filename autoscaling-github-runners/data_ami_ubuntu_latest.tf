data "aws_ami" "ubuntu_latest" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/*focal*amd64*"]
  }
}
