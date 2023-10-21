variable "server_port" { # 8080
    description = "EC2 server port"
    type = number

    default = 8080
    validation {
      condition = var.server_port > 0 && var.server_port <= 65535
      error_message = "value must be between 1 and 65535."
    }
}

variable "instance_type" { # t3.micro
    description = "EC2 instance type"
    type = string

    default = "t3.micro"
}

variable "ami_id" {
  description = "ami id"
  type = string
}

variable "servers" {
    description = "Maps of server with its names and subnet_id"

    type = map(object({
      name        = string,
      subnet_id   = string
    }))
}

variable "environment" { # In AWS we can't have two instances with the same name, so we will use this variable to differentiate them
  description = "Name of the environment to deploy"
  type = string
  default = ""
}