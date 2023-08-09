variable "ec2_count" {
  type    = number
}

variable "instance_type" {
  type    = string
  default = "t2.nano"
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