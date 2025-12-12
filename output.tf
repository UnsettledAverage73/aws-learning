output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.my_server.public_ip
}

output "website_url" {
  description = "Click here to see your server"
  value       = "http://${aws_instance.my_server.public_ip}"
}
