
# AＭI filter for Linux2
#data "aws_ami_ids" "amazon-linux-2" {
# owners = ["amazon"]

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Security Group
resource "aws_security_group" "allow_jira" {
  name        = "allow_jira_sg"
  description = "Allow Http/Https inbound connection"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_jira_sg"
  }
}

# EC2
resource "aws_instance" "jira_instances" {
  count         = length(var.subnets_pri)
  subnet_id     = element(aws_subnet.private.*.id, count.index)
  ami           = data.aws_ami.ami.id
  instance_type = "t2.micro"
  key_name      = "use-1"
  # vpc_security_group_ids = aws_security_group.allow_jira.id
  # source_dest_check = false
}

/*
# EBS volume and attachment
resource "aws_ebs_volume" "ebs" {
  count             = length(var.subnets_pri)
  availability_zone = length(var.azs)
  size              = 20
  
  tags = {
    Name = "ebs-${count.index + 1}"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  count       = length(var.subnets_pri)
  volume_id   = element(aws_ebs_volume.ebs.*.id, count.index)
  instance_id = element(aws_instance.jira_instances.*.id, count.index)
}
*/

