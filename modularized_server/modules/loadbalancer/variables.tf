variable "subnet_ids" {
  description = "ids of subnets where we have to create loadbalancer"
  type        = set(string)
}

variable "instance_ids" {
  description = "ids of EC2 instances"
  type        = list(string)
}

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

variable "environment" {
  description = "Name of the environment to deploy"
  type = string
  default = ""
}