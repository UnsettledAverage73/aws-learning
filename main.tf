provider "aws" {
  region = "us-east-1"
}

# 1. Create the Key Pair in AWS (using the key you just generated)
resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
  # This points to the public key file on your Mac/Linux machine
  public_key = file("~/.ssh/terraform_key.pub")
}

# 1. create an security group or firewall
resource "aws_security_group" "web_sg" {
  name        = "learning-sg"
  description = "Allow HTTP and SSH"
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
    cidr_blocks = ["0.0.0.0/0"] #open to the world for learning-sg
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. create the server
resource "aws_instance" "my_server" {
  ami           = "ami-0c7217cdde317cfec" #amazon linux 23 (free tier for us-east-1)
  instance_type = "t2.micro"
  # ATTACH THE KEY HERE
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  # INSTALL WEB SERVER ON STARTUP
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform!</h1>" > /var/www/html/index.html
              EOF
  tags = {
    Name = "My-Learning-Box"
  }
}

# 3. Output the IP address 
output "server_ip" {
  value = aws_instance.my_server.public_ip
}

