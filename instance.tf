#my zone
provider "aws" {
  region     = "${var.region}"
  }

#my vpc
resource "aws_vpc" "vpchome" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "vpchome"
  }
}

# S3 config

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "s3-buckets-bucket"
  acl    = "private"

  tags {
    Name        = "tf-bucket-bucket"
    Environment = "terraform"
  }
}

#security group

resource "aws_security_group" "allow_tls" {
  name        = "allow ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = "${aws_vpc.vpchome.id}"

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "allow_ssh"
  }
}

# security group2

resource "aws_security_group" "allow_tls1" {
  name        = "allow http"
  description = "Allow http inbound traffic"
  vpc_id      = "${aws_vpc.vpchome.id}"

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tcp"
  }
}


#key-pair

resource "aws_key_pair" "tf_demo" {
  key_name   = "tf_demo"
  public_key = "${file("tf-demo.pub")}"
}

#my instance
resource "aws_instance" "webservers" {
  count             = "${var.inst_count}"
  ami               = "${lookup(var.inst_ami,var.region)}"
  instance_type     = "t2.micro"
  availability_zone = "${var.azs}"
  key_name          = "${aws_key_pair.tf_demo.key_name}"

  tags {
    Name = "Server-${count.index +1}"
  }
}


#volumes

resource "aws_ebs_volume" "tf-volume" {
  availability_zone = "${var.azs}"
  size              = 8

  tags {
    Name = "tf-volume"
  }
}

#connecting instance with ebs_volume

resource "aws_volume_attachment" "tf-attach-vol" {
 device_name = "/dev/sdc"
 volume_id = "${aws_ebs_volume.tf-volume.id}"
 instance_id = "${element(aws_instance.webservers.*.id,count.index)}"
}

