output "public_dns_servers" {

    description = "public DNS of server"
    value = [for server in aws_instance.servers : "http://${server.public_dns}:${var.server_port}"]
}


output "public_dns_loadbalancer" {
    description = "public DNS of server"
    value = "http://${aws_lb.alb.dns_name}:${var.loadbalancer_port}"
}