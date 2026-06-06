variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type (needs at least 2GB RAM for Kubernetes/Kind)"
  type        = string
  default     = "t3.small"
}
