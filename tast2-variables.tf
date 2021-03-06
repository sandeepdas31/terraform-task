variable "region" {
 
  default="ap-south-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "inst_count" {
  default = "2"
}

variable "azs" {
  
  default="ap-south-1a"
}

variable "inst_ami" {
  type = "map"

  default = {
    us-east-2  = "ami-083ebc5a49573896a"
    ap-south-1 = "ami-005956c5f0f757d37"
  }
}
