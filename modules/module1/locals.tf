locals {
  vpc = "${terraform.workspace}-vpc"
}

locals {
  subnet = "${terraform.workspace}-subnet"
}

locals {
  ig = "${terraform.workspace}-ig"
}

locals {
  rt = "${terraform.workspace}-rt"
}

locals {
  instance_ws = "${terraform.workspace}-instance-webserver"
}

locals {
  instance_fe = "${terraform.workspace}-instance-frontend"
}

locals {
  instance_be = "${terraform.workspace}-instance-backend"
}

locals {
  instance_ms = "${terraform.workspace}-instance-mysql"
}
