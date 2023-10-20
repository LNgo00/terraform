provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"
  ami    = var.ubuntu_ami[local.region]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "public_subnets" {
    for_each = var.servers

    availability_zone = "${local.region}${each.value["az"]}"
}

resource "aws_instance" "servers" {
    ami           = local.ami
    instance_type = var.instance_type #t3.micro
    subnet_id = data.aws_subnet.public_subnets[each.key].id
    vpc_security_group_ids = [aws_security_group.yusuke_security_group.id]

    for_each = var.servers
    user_data = <<-EOF
                #!/bin/bash
                echo "Hola terraformer ${each.value["name"]}" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF

    tags = {
        Name = each.value["name"]
    }
}


resource "aws_security_group" "yusuke_security_group" {
    name = "first_server_sg"
    #vpc_id = data.aws_vpc.default.id Don't know why this doesn't work when is also present in aws_lb_target_group TODO
    ingress {
        security_groups = [ aws_security_group.alb.id ]
        description = "Allow all traffic from the internet"
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
    }

}

resource "aws_lb" "alb" {
    load_balancer_type = "application"
    name               = "terraform-alb"
    security_groups    = [aws_security_group.alb.id]
    #subnets = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]

    subnets = [for subnet in data.aws_subnet.public_subnets : subnet.id]
}

resource "aws_security_group" "alb" {
    name = "alb-sg"

    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all traffic from the internet"
        from_port = var.loadbalancer_port
        to_port = var.loadbalancer_port
        protocol = "TCP"
    }

    egress {
        to_port = var.server_port
        from_port = var.server_port
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow access to our servers from port 8080"
    }
}

resource "aws_lb_target_group" "this" {
    name = "terraform-alb-target-group"
    port = var.loadbalancer_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id

    health_check {
        enabled = true
        matcher = "200"
        path = "/"
        port = "${var.server_port}"
        protocol = "HTTP"
    }
}

resource "aws_lb_target_group_attachment" "servers" {
    for_each = var.servers

    target_group_arn = aws_lb_target_group.this.arn # arn is Amazon Resource Name
    target_id = aws_instance.servers[each.key].id
    port = var.server_port
}


resource "aws_lb_listener" "this" {
    load_balancer_arn = aws_lb.alb.arn
    port              = "${var.loadbalancer_port}"
    protocol          = "HTTP"

    default_action {
      target_group_arn = aws_lb_target_group.this.arn
      type             = "forward"
    }
}

#TODO diagram that explains the relation between different resources