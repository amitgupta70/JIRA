variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnets_pub" {
  type    = list
 default = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "subnets_pri" {
  type    = list
  default = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "azs" {
  type    = list
  default = ["us-east-1a", "us-east-1b"]
}

variable "alarms_email" {
  default = ["amitgupta784@gmail.com"]
  }
