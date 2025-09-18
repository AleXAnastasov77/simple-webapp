# webserver.pkr.hcl
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.0"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  region            = "eu-central-1"
  instance_type     = "t3.micro"
  ssh_username      = "ubuntu"
  ami_name          = "cs1-webserver-{{timestamp}}"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"] # Canonical
    most_recent = true
  }
}

build {
  name    = "cs1-webserver"
  sources = ["source.amazon-ebs.ubuntu"]

  # Step 1: install Ansible in the temporary EC2
   provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y software-properties-common",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt-get install -y ansible"
    ]
  }

  # Step 2: run your playbook
  provisioner "ansible-local" {
    playbook_file = "./playbooks/webserver.playbook.yaml"
  }
  post-processor "manifest" {
    output = "manifest.json"
  }
}
