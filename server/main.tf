provider "aws" {
  region = "eu-west-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "yusuke_server" {
    ami           = "ami-0694d931cee176e7d"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.yusuke_security_group.id]
    user_data = <<-EOF
                #!/bin/bash
                echo "Hola terraform" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF

    tags = {
        Name = "yusuke_server"
    }
}

resource "aws_security_group" "yusuke_security_group" {
    name = "first_server_sg"
    vpc_id = data.aws_vpc.default.id
    ingress {
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "Allow all traffic from the internet"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
    }

}