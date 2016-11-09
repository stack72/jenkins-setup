variable "aws_region" {
  type = "string"
  default = "us-west-2"
}

provider "aws" {
  region = "${var.aws_region}"
}

data "aws_availability_zones" "zones" {}

module "jenkins_vpc" {
  source = "./modules/vpc"

  cidr = "10.70.0.0/16"
  private_subnets = ["10.70.160.0/19"]
  public_subnets = ["10.70.0.0/21"]

  availability_zones = ["${data.aws_availability_zones.zones.names}"]
}
