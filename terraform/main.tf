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

module "jenkins_server" {
  source = "./modules/jenkins"

  vpc_id = "${module.jenkins_vpc.vpc_id}"
  public_subnet_ids = ["${module.jenkins_vpc.public_subnets}"]
  availability_zones = ["${module.jenkins_vpc.public_availability_zones}"]

  ami_id   = "${data.aws_ami.jenkins_ami.id}"
  key_name = "${aws_key_pair.jenkins.key_name}"
}

resource "aws_key_pair" "jenkins" {
  key_name = "jenkins"
  public_key = "${file("ssh/jenkins.pub")}"
}

data "aws_ami" "jenkins_ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu-jenkins-master*"]
  }
}

output "jenkins_address" {
  value = "${module.jenkins_server.elb_address}"
}

output "jenkins_ssh_instructions" {
  value = "${format("ssh -i ssh/%s ubuntu@%s", aws_key_pair.jenkins.key_name, module.jenkins_server.jenkins_ip)}"
}
