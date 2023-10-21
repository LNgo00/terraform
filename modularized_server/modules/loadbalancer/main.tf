
resource "aws_lb" "alb" {
    load_balancer_type = "application"
    name               = "terraform-alb-${var.environment}"
    security_groups    = [aws_security_group.alb.id]
    #subnets = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]

    subnets = var.subnet_ids
}

resource "aws_security_group" "alb" {
    name = "alb-sg-${var.environment}"

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
data "aws_vpc" "default" {
  default = true
}

resource "aws_lb_target_group" "this" {
    name = "terraform-alb-target-group-${var.environment}"
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
    count = length(var.instance_ids) # Use count because instance_ids are from ec2_instances module and is not visible until it's created

    target_group_arn = aws_lb_target_group.this.arn # arn is Amazon Resource Name
    target_id = element(var.instance_ids, count.index) # element creates an access point to the mod of the list so it not use out of bounds indexes
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
