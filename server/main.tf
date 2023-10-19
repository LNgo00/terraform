provider "aws" {
  region = "eu-west-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "az_a" {
    availability_zone = "eu-west-1a"
}

data "aws_subnet" "az_b" {
    availability_zone = "eu-west-1b"
}

resource "aws_instance" "yusuke_server_1" {
    ami           = "ami-0694d931cee176e7d"
    instance_type = "t3.micro"
    subnet_id = data.aws_subnet.az_a.id
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

resource "aws_instance" "yusuke_server_2" {
    ami           = "ami-0694d931cee176e7d"
    instance_type = "t3.micro"
    subnet_id = data.aws_subnet.az_b.id
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
        security_groups = [ aws_security_group.alb.id ]
        description = "Allow all traffic from the internet"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
    }

}

resource "aws_lb" "alb" {
    load_balancer_type = "application"
    name               = "terraform-alb"
    security_groups    = [aws_security_group.alb.id]
    subnets = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]
}

resource "aws_security_group" "alb" {
    name = "alb-sg"

    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all traffic from the internet"
        from_port = 80
        to_port = 80
        protocol = "TCP"
    }

    egress {
        to_port = 8080
        from_port = 8080
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow access to our servers from port 8080"
    }
}

resource "aws_lb_target_group" "this" {
    name = "terraform-alb-target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id

    health_check {
        enabled = true
        matcher = "200"
        path = "/"
        port = "8080"
        protocol = "HTTP"
    }
}

resource "aws_lb_target_group_attachment" "yusuke_server_1" {
    target_group_arn = aws_lb_target_group.this.arn # arn is Amazon Resource Name
    target_id = aws_instance.yusuke_server_1.id
    port = 8080
}

resource "aws_lb_target_group_attachment" "yusuke_server_2" {
    target_group_arn = aws_lb_target_group.this.arn # arn is Amazon Resource Name
    target_id = aws_instance.yusuke_server_2.id
    port = 8080
}

resource "aws_lb_listener" "this" {
    load_balancer_arn = aws_lb.alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
      target_group_arn = aws_lb_target_group.this.arn
      type             = "forward"
    }
}