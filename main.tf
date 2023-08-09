module "my_vpc" {
  source = "./modules/module1"
  
  instance_type = var.instance_type
  ec2_count = var.ec2_count
  ec2_count_fe = var.ec2_count_fe
  ec2_count_be = var.ec2_count_be
  ec2_count_ms = var.ec2_count_ms
}

terraform {
  backend "s3" {
    bucket = "nikhil-terraform-bucket-79"
    key = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}
