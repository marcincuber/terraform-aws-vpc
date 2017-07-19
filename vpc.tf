resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = true
  tags {
    Name = "VPC NAME"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags {
    Name = "main"
  }
}

resource "aws_egress_only_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

/*
  Public Subnet
*/
resource "aws_subnet" "eu-west-1a-public" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.public_subnet_cidr_a}"
  availability_zone = "eu-west-1a"

  tags {
    Name = "Public Subnet 1a"
  }
}

resource "aws_subnet" "eu-west-1b-public" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.public_subnet_cidr_b}"
  availability_zone = "eu-west-1b"

  tags {
    Name = "Public Subnet 1b"
  }
}

resource "aws_subnet" "eu-west-1c-public" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.public_subnet_cidr_c}"
  availability_zone = "eu-west-1c"

  tags {
    Name = "Public Subnet 1c"
  }
}

resource "aws_route_table" "eu-west-1-public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "Public Subnets"
  }
}

resource "aws_route_table_association" "eu-west-1-public-a" {
  subnet_id = "${aws_subnet.eu-west-1a-public.id}"
  route_table_id = "${aws_route_table.eu-west-1-public.id}"
}

resource "aws_route_table_association" "eu-west-1-public-b" {
  subnet_id = "${aws_subnet.eu-west-1b-public.id}"
  route_table_id = "${aws_route_table.eu-west-1-public.id}"
}

resource "aws_route_table_association" "eu-west-1-public-c" {
  subnet_id = "${aws_subnet.eu-west-1c-public.id}"
  route_table_id = "${aws_route_table.eu-west-1-public.id}"
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${var.elastic_ip_allocation_id}"
  subnet_id = "${aws_subnet.eu-west-1a-public.id}"

  depends_on = ["aws_internet_gateway.default","aws_subnet.eu-west-1a-public"]
}

/*
  Private Subnet
*/
resource "aws_subnet" "eu-west-1a-private" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.private_subnet_cidr_a}"
  availability_zone = "eu-west-1a"

  tags {
    Name = "Private Subnet 1a"
  }
}

resource "aws_subnet" "eu-west-1b-private" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.private_subnet_cidr_b}"
  availability_zone = "eu-west-1b"

  tags {
    Name = "Private Subnet 1b"
  }
}

resource "aws_subnet" "eu-west-1c-private" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "${var.private_subnet_cidr_c}"
  availability_zone = "eu-west-1c"

  tags {
    Name = "Private Subnet 1c"
  }
}

resource "aws_route_table" "eu-west-1-private" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  route {
    ipv6_cidr_block = "::/0"
    egress_only_gateway_id = "${aws_egress_only_internet_gateway.default.id}"
  }

  tags {
    Name = "Private Subnets"
  }
}

resource "aws_route_table_association" "eu-west-1-private-a" {
  subnet_id = "${aws_subnet.eu-west-1a-private.id}"
  route_table_id = "${aws_route_table.eu-west-1-private.id}"
}

resource "aws_route_table_association" "eu-west-1-private-b" {
  subnet_id = "${aws_subnet.eu-west-1b-private.id}"
  route_table_id = "${aws_route_table.eu-west-1-private.id}"
}

resource "aws_route_table_association" "eu-west-1-private-c" {
  subnet_id = "${aws_subnet.eu-west-1c-private.id}"
  route_table_id = "${aws_route_table.eu-west-1-private.id}"
}

/*
  Default security group
*/
resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_flow_log" "test_flow_log" {
  log_group_name = "${aws_cloudwatch_log_group.test_log_group.name}"
  iam_role_arn   = "${aws_iam_role.test_role.arn}"
  vpc_id         = "${aws_vpc.default.id}"
  traffic_type   = "ALL"
}

resource "aws_cloudwatch_log_group" "test_log_group" {
  name = "test_log_group"
}

resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.test_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

/*
  Outputs
*/
output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "public_subnet_id_1a" {
  value = "${aws_subnet.eu-west-1a-public.id}"
}

output "public_subnet_id_1b" {
  value = "${aws_subnet.eu-west-1b-public.id}"
}

output "public_subnet_id_1c" {
  value = "${aws_subnet.eu-west-1c-public.id}"
}

output "private_subnet_id_1a" {
  value = "${aws_subnet.eu-west-1a-private.id}"
}

output "private_subnet_id_1b" {
  value = "${aws_subnet.eu-west-1b-private.id}"
}

output "private_subnet_id_1c" {
  value = "${aws_subnet.eu-west-1c-private.id}"
}

output "security_group_default" {
  value = "${aws_default_security_group.default.id}"
}
