output "public_dns" {
    description = "public DNS of server"
    value = "http://${aws_instance.yusuke_server.public_dns}:8080"
}

output "public_ipv4" {
    description = "public ipv4 of server"
    value = aws_instance.yusuke_server.public_ip
}