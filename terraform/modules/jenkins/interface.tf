variable "vpc_id" {
  type = "string"
}

variable "public_subnet_ids" {
  type = "list"
}

variable "availability_zones" {
  type = "list"
}

variable "ami_id" {
  type = "string"
}

variable "instance_type" {
  type    = "string"
  default = "m3.medium"
}

variable "key_name" {
  type = "string"
}

variable "volume_size" {
  type    = "string"
  default = "50"
}

variable "min_size" {
  type    = "string"
  default = "1"
}

variable "max_size" {
  type    = "string"
  default = "1"
}

variable "desired_capacity" {
  type    = "string"
  default = "1"
}

output "elb_address" {
  value = "${aws_elb.jenkins_master_elb.dns_name}"
}

output "jenkins_ip" {
  value = "${aws_instance.jenkins.public_ip}"
}
