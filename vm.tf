variable "image" { type = string }
variable "region" { type = string }
variable "instance" { type = string }
variable "name" { type = string }

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_key_pair" "key" {
  key_name   = "same_for_all"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "test_vm_muthu" { 
  ami           = var.image
  instance_type = var.instance
  tags = {
    Name = var.name
  }
  key_name      = "same_for_all"
  associate_public_ip_address   = true
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = aws_instance.test_vm_muthu.public_ip
  }
  provisioner "file" {
    source      = "./script.sh"
    destination = "/home/ubuntu/script.sh"
  }
  provisioner "file" {
    source      = "./openvpn-install.sh"
    destination = "/home/ubuntu/openvpn-install.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo sh script.sh",
      "sudo apt-get -y update",
      "printf '${aws_instance.test_vm_muthu.public_ip}\n2\n\n\ntest_client\n' | sudo bash openvpn-install.sh"
      ]
  }
}
