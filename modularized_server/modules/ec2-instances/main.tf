resource "aws_instance" "servers" {
    for_each = var.servers

    ami           = var.ami_id
    instance_type = var.instance_type #t3.micro
    subnet_id = each.value["subnet_id"]
    vpc_security_group_ids = [aws_security_group.yusuke_security_group.id]


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
    name = "server_sg_${var.environment}"
    #vpc_id = data.aws_vpc.default.id Don't know why this doesn't work when is also present in aws_lb_target_group TODO
    ingress {
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "Allow all traffic from the internet"
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
    }

}