variable "public_key_path" {
  default = ".ssh/aws-multi.pub"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.public_key_path)
}
