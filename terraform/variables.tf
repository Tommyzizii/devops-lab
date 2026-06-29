variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "docker_image" {
  description = "Docker image on Docker Hub"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair Name"
  type        = string
}