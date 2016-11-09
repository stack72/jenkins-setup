resource "aws_security_group" "jenkins_master" {
  name        = "jenkins-master-sg"
  description = "Jenkins Security Group"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = ["${aws_security_group.jenkins_master_elb.id}"]
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "jenkins_master_elb" {
  name        = "jenkins-master-sg-elb-sg"
  description = "Jenkins ELB Security Group"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.jenkins_master.id}"]
  monitoring = false
  subnet_id = "${var.public_subnet_ids[0]}"

  root_block_device {
    volume_size = "${var.volume_size}"
  }
}

resource "aws_elb" "jenkins_master_elb" {
  name = "jenkins-master-elb"
  subnets = ["${var.public_subnet_ids}"]
  security_groups = ["${aws_security_group.jenkins_master_elb.id}"]
  cross_zone_load_balancing = true
  connection_draining = true
  instances = ["${aws_instance.jenkins.id}"]
  internal = false

  listener {
    instance_port = 8080
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 10
    target = "TCP:8080"
    timeout = 5
  }
}
