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
    from_port = 8080
    to_port = 8080
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

resource "aws_launch_configuration" "jenkins_master_launch_config" {
  image_id = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.jenkins_master.id}"]
  enable_monitoring = false

  root_block_device {
    volume_size = "${var.volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "jenkins_master_elb" {
  name = "jenkins-master-elb"
  subnets = ["${var.public_subnet_ids}"]
  security_groups = ["${aws_security_group.jenkins_master_elb.id}"]
  cross_zone_load_balancing = true
  connection_draining = true
  internal = false

  listener {
    instance_port = 8080
    instance_protocol = "tcp"
    lb_port = 8080
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

resource "aws_autoscaling_group" "jenkins_master_autoscale_group" {
  name = "jenkins-master-autoscale-group"
  availability_zones = ["${var.availability_zones}"]
  vpc_zone_identifier = ["${var.private_subnet_ids}"]
  launch_configuration = "${aws_launch_configuration.jenkins_master_launch_config.id}"
  min_size = "${var.min_size}"
  max_size = "${var.max_size}"
  desired_capacity = "${var.desired_capacity}"
  health_check_type = "EC2"
  load_balancers = ["${aws_elb.jenkins_master_elb.name}"]
}
