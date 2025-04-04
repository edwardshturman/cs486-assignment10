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
  default = "cs486-assignment10-edwardshturman"
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

source "amazon-ebs" "amazon-linux" {
  region        = var.aws_region
  source_ami    = "ami-0fa75d35c5505a879" # Amazon Linux 2023 AMI 64-bit x86
  instance_type = var.instance_type
  ssh_username  = "ec2-user"
  ami_name      = "${var.ami_prefix}-amazon-linux-${local.timestamp}"
}

source "amazon-ebs" "ubuntu" {
  region        = var.aws_region
  source_ami    = "ami-05e1c8b4e753b29d3" # Ubuntu 22.04 LTS x86
  instance_type = var.instance_type
  ssh_username  = "ubuntu"
  ami_name      = "${var.ami_prefix}-ubuntu-${local.timestamp}"
}

build {
  name = "cs486-assignment10-edwardshturman"
  sources = [
    "source.amazon-ebs.amazon-linux",
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    only = ["amazon-ebs.amazon-linux"]
    inline = [
      "echo \"Upgrading packages\"",
      "sudo yum update -y",
      "echo \"Upgraded packages\""
    ]
  }

  provisioner "shell" {
    only = ["amazon-ebs.amazon-linux"]
    inline = [
      "echo \"Installing Docker\"",
      "sudo yum install -y docker",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo docker run hello-world",
      "echo \"Docker installed\""
    ]
  }

  provisioner "shell" {
    only = ["amazon-ebs.ubuntu"]
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
    only = ["amazon-ebs.amazon-linux"]
    inline = [<<EOF
echo "amazon_linux_ami = \"$(jq -r '.builds[] | select(.name == "amazon-linux") | .artifact_id' manifest.json | cut -d':' -f2)\"" >> terraform.tfvars
echo "Added Amazon Linux-based AMI ID to terraform.tfvars"
EOF
    ]
  }

  post-processor "shell-local" {
    only = ["amazon-ebs.ubuntu"]
    inline = [<<EOF
echo "ubuntu_ami = \"$(jq -r '.builds[] | select(.name == "ubuntu") | .artifact_id' manifest.json | cut -d':' -f2)\"" >> terraform.tfvars
echo "Added Ubuntu-based AMI ID to terraform.tfvars"
EOF
    ]
  }
}
