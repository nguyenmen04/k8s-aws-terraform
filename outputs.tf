output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer to access the Mini Dashboard"
  value       = "http://${aws_lb.app_alb.dns_name}"
}

output "instructions" {
  description = "Next steps after apply completes"
  value       = "Wait about 3-4 minutes for EC2 to finish installing Docker, Kind, and building the dashboard image. Then visit the alb_dns_name above."
}
