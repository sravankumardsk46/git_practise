provider "aws" {
  region = "us-east-1"
}

# Security Group for Docker
resource "aws_security_group" "docker_sg" {
  name        = "docker_sg"
  description = "Allow SSH and Docker applications"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance for Docker
resource "aws_instance" "docker" {
  ami           = "ami-08a52ddb321b32a8c"  # Ubuntu 22.04 AMI (Check latest in AWS)
  instance_type = "t2.micro"              # Free tier eligible (modify as needed)
  key_name      = "your-key"              # Replace with your key pair name
  security_groups = [aws_security_group.docker_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker’s official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add Docker repository
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    sudo apt update -y
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    # Start and enable Docker
    sudo systemctl start docker
    sudo systemctl enable docker

    # Add ubuntu user to docker group
    sudo usermod -aG docker ubuntu

    # Verify Docker installation
    docker --version
  EOF

  tags = {
    Name = "Docker-Server"
  }
}
