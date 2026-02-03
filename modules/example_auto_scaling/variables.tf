variable "server_port" {
  description = "The port that the server will use to handle HTTP request"
  type = number
  default     = 8080
  /*
    
  validation {
    condition = var.server_port > 0 && var.server_port < 65536
    error_message = "The port must be between 1-65536"
  } */
}


