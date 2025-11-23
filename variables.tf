variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "us-west-2"
}

variable "project_name" {
  default = "personal-book"
}

variable "mongo_uri" {
  description = "Connection string for MongoDB Atlas"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "Secret key for JWT signing"
  type        = string
  sensitive   = true
}

variable "sender_email_address" {
  description = "Sender email configured in AWS SES"
  type        = string
  sensitive   = true
}
