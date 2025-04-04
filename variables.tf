variable "ami" {
  description = "The AMI ID to use for the EC2 instances; expect this to be the output of the Packer build, fallback below"
  type        = string
  default     = "ami-0fa75d35c5505a879" # Amazon Linux 2023 AMI 64-bit x86
}

variable "instance_prefix" {
  description = "A prefix for the Name tag for the EC2 instance cluster"
  type        = string
  default     = "cs486-assignment9-edwardshturman"
}

variable "worker_count" {
  description = "Number of worker EC2 instances to create"
  type        = number
  default     = 2
}

variable "manager_count" {
  description = "Number of manager EC2 instances to create"
  type        = number
  default     = 3
}

variable "vpc_name" {
  description = "Name of the VPC to use for the EC2 instance cluster"
  type        = string
  default     = "cs486-assignment9-edwardshturman-vpc"
}

variable "allow_ssh_ip" {
  description = "An IPv4 address from which SSH access is allowed"
  type        = string
  default     = ""
}

variable "public_key" {
  description = "Public key for SSH access to the bastion host"
  type        = string
  default     = ""
}
