terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 2.70"
			}
	}
}


provider "aws" {
	region = "us-east-2"
	access_key = "AKIAJ5VIQRS4YHQLPKGQ" #Use your own access key
	secret_key = "F/Hx+1UuKEu1Z1zCliabWZxopvec3y6KbKhZ/kOd" #Use your own secret key
}

resource "aws_vpc" "VPC_ACKLEN" {
	cidr_block	     = "10.0.0.0/16"
	instance_tenancy     = "default"
	enable_dns_support   = "true"
	enable_dns_hostnames = "true"

	tags = {
		Name = "VPC_ACKLEN"
		}

}

resource "aws_subnet" "ACKLEN_SUBN_1" {
	vpc_id			= aws_vpc.VPC_ACKLEN.id
	cidr_block 		= "10.0.1.0/24"
	map_public_ip_on_launch = "true"
	availability_zone 	= "us-east-2a"

	tags = {
		Name = "ACKLEN_SUBN_1"
		}
}

resource "aws_subnet" "ACKLEN_SUBN_2" {
	vpc_id			= aws_vpc.VPC_ACKLEN.id
	cidr_block 		= "10.0.2.0/24"
	map_public_ip_on_launch = "true"
	availability_zone 	= "us-east-2b"

	tags = {
		Name = "ACKLEN_SUBN_2"
		}
}

resource "aws_internet_gateway" "AKN_GW" {
	vpc_id	= aws_vpc.VPC_ACKLEN.id
	
	tags = {
		Name = "AKN_GW"
		}		
}

resource "aws_route_table" "AKN_ROUTE" {
	vpc_id	= aws_vpc.VPC_ACKLEN.id

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.AKN_GW.id
		}

	tags = {
		Name = "AKN_ROUTE"
		}
}

resource "aws_main_route_table_association" "Principal" {
	vpc_id		= aws_vpc.VPC_ACKLEN.id
	route_table_id	= aws_route_table.AKN_ROUTE.id
}

resource "aws_security_group" "AKN_SG" {
	name 		= "AKN_SG"
	description 	= "Acklen Security Group"
	vpc_id		= aws_vpc.VPC_ACKLEN.id

	ingress {
		description 	= "All Trafic"
		from_port 	= 0
		to_port 	= 0
		protocol 	= -1
		cidr_blocks 	= ["181.115.62.122/32"] #Use your public IP
		}

	ingress {
		description 	= "TCP App"
		from_port 	= 5000
		to_port 	= 5000
		protocol 	= "tcp"
		cidr_blocks 	= ["0.0.0.0/0"]
		}

	ingress {
		description 	= "TCP App"
		from_port 	= 80
		to_port 	= 80
		protocol 	= "tcp"
		cidr_blocks 	= ["0.0.0.0/0"]
		}

		egress {		
			from_port 	= 0
			to_port 	= 0
			protocol 	= "-1"
			cidr_blocks 	= ["0.0.0.0/0"]
			}

	tags = {
		Name = "AKN_SG"
		}
}

resource "aws_instance" "AKN_I1" {
	ami 		= "ami-0996d3051b72b5b2c" #This is for ubuntu 20
	instance_type 	= "t3.micro"
	subnet_id 	= aws_subnet.ACKLEN_SUBN_1.id
	security_groups = [aws_security_group.AKN_SG.id]
	key_name 	= "AKN_KEY" #Generate your key name and use it instead of this

	credit_specification {
		cpu_credits = "unlimited"
	}

	tags = {
		name = "AKN_1"
	}
}

resource "aws_instance" "AKN_I2" {
	ami 		= "ami-0996d3051b72b5b2c" #This is for ubuntu 20
	instance_type 	= "t3.micro"
	subnet_id 	= aws_subnet.ACKLEN_SUBN_1.id
	security_groups = [aws_security_group.AKN_SG.id]
	key_name 	= "AKN_KEY" #Generate your key name and use it instead of this

	credit_specification {
		cpu_credits = "unlimited"
	}

	tags = {
		name = "AKN_2"
	}
}

resource "aws_lb" "AKNP" {
	name 		   = "AKNP"
	internal 	   = false
	load_balancer_type = "application"
	security_groups	   = [aws_security_group.AKN_SG.id]
	subnets		   = [aws_subnet.ACKLEN_SUBN_1.id,aws_subnet.ACKLEN_SUBN_2.id]
	enable_deletion_protection = false

tags = {
	environment = "AKN_LB"
	}	
}

resource "aws_lb_target_group" "AKN_TG" {
	name 	 = "AKNTG"
	port 	 = 80
	protocol = "HTTP"
	vpc_id	 = aws_vpc.VPC_ACKLEN.id

	stickiness {
		type = "lb_cookie"
		}
}

resource "aws_lb_target_group_attachment" "AKN_RTG1" {
	target_group_arn = aws_lb_target_group.AKN_TG.arn
	target_id 	 = aws_instance.AKN_I1.id
	port 		 = 5000
}

resource "aws_lb_target_group_attachment" "AKN_RTG2" {
	target_group_arn = aws_lb_target_group.AKN_TG.arn
	target_id 	 = aws_instance.AKN_I2.id
	port 	 	 = 5000
}

resource "aws_lb_listener" "AKNP_Listener" {
	load_balancer_arn = aws_lb.AKNP.arn
	port 		  = "80"
	protocol          = "HTTP"

		default_action {
			type = "forward"
			target_group_arn = aws_lb_target_group.AKN_TG.arn
		}
}