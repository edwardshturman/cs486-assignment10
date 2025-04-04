packer {
  required_plugins {
    amazon = {
      version = "1.3.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "cs486-assignment9-edwardshturman"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "aws_region" {
  type    = string
  default = "us-west-1"
}

locals {
  timestamp = regex_replace(timestamp(), "[-TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  region        = var.aws_region
  source_ami    = "ami-05e1c8b4e753b29d3" # Ubuntu 22.04 LTS x86
  instance_type = var.instance_type
  ssh_username  = "ubuntu"
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
}

build {
  name = "cs486-assignment9-edwardshturman"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [<<EOF
echo "Installing Docker"
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl enable docker
sudo systemctl start docker
sudo docker run hello-world
sudo usermod -aG docker ubuntu
echo "Docker installed"
EOF
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }

  post-processor "shell-local" {
    inline = [<<EOF
echo "ami = \"$(cat manifest.json | jq -r .builds[0].artifact_id |  cut -d':' -f2)\"" >> terraform.tfvars
echo "Added AMI ID to terraform.tfvars"
EOF
    ]
  }
}
