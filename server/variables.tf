variable "server_port" { # 8080
    description = "EC2 server port"
    type = number

    default = 8080
    validation {
      condition = var.server_port > 0 && var.server_port <= 65535
      error_message = "value must be between 1 and 65535."
    }
}

variable "loadbalancer_port" { # 80
    description = "Loadbalancer port"
    type = number

    default = 80
}

variable "instance_type" { # t3.micro
    description = "EC2 instance type"
    type = string

    default = "t3.micro"
}

variable "ubuntu_ami" {
    description = "Ubuntu AMI for each region"
    type = map(string)

    default = {
      "eu-west-1" = "ami-0694d931cee176e7d" #Dublin
      "eu-west-2" = "ami-0505148b3591e4c07" #London
    }
}

variable "servers" {
    description = "Maps of server with its names and AZs"

    type = map(object({
      name = string,
      az   = string
    }))

    default = {
      "server_1" = {
        name = "yusuke-server-1",
        az   = "a"
      },
      "server_2" = {
        name = "yusuke-server-2",
        az   = "b"
      }
    }
}

# terraform apply -var "server_port=8080" -var "loadbalancer_port=80" -var "instance_type=t3.micro"