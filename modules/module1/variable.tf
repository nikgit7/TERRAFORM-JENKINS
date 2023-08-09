variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "cidr_block_public_subnet" {
  type    = string
  default = "10.0.1.0/24"
}
variable "cidr_block_private_subnet" {
  type    = string
  default = "10.0.2.0/24"
}

variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "ami_id" {
  type    = string
  default = "ami-053b0d53c279acc90"
}

variable "ec2_count" {
  type    = number
  
}
variable "ec2_count_fe"{
  type = number
}

variable "ec2_count_be"{
  type = number
}

variable "ec2_count_ms" {
  type = number
  
}
variable "instance_type" {
  type    = string
  
}

variable "enable_public_ip" {
  type    = bool
  default = true
}