output "public_dns_serv_1" {
    description = "public DNS of server"
    value = "http://${aws_instance.yusuke_server_1.public_dns}:${var.server_port}"
}

output "public_dns_serv_2" {
    description = "public DNS of server"
    value = "http://${aws_instance.yusuke_server_2.public_dns}:${var.server_port}"
}

output "public_dns_loadbalancer" {
    description = "public DNS of server"
    value = "http://${aws_lb.alb.dns_name}:${var.loadbalancer_port}"
}