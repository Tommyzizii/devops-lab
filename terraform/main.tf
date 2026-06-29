data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_security_group" "web" {
  name        = "devops-lab-sg"
  description = "Allow HTTP and SSH inbound traffic"

  ingress {
    description = "HTTP"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  user_data = <<-EOF
                #!/bin/bash
                dnf update -y
                dnf install docker -y
                systemctl enable docker
                systemctl start docker
                docker pull ${var.docker_image}
                docker run -d --name devops-container -p 80:80 ${var.docker_image}
                EOF

  tags = {
    Name = "DevOpsLab"
  }
}