variable "server_port" { # 8080
    description = "EC2 server port"
    type = number

}

variable "loadbalancer_port" { # 80
    description = "Loadbalancer port"
    type = number
}

variable "instance_type" { # t3.micro
    description = "EC2 instance type"
    type = string

}

# terraform apply -var "server_port=8080" -var "loadbalancer_port=80" -var "instance_type=t3.micro"