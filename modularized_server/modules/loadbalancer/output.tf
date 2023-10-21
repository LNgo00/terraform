output "public_dns_loadbalancer" {
    description = "public DNS of server"
    value = "http://${aws_lb.alb.dns_name}:${var.loadbalancer_port}"
}

