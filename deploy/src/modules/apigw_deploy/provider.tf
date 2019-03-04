provider "aws" {
  version = "2.0"
  region  = "${var.aws_region}"
}

provider "null" {
  version = "2.1"
}