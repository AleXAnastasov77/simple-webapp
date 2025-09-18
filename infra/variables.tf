variable "region" {
  description = "The region where resources are going to be deployed."
  type        = string
  default     = "eu-central-1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    environment = "Development"
    project     = "Case Study 1"
    owner       = "Aleks Anastasov"
  }
}
variable "custom_ami" {
  description = "Custom AMI image to use for the webservers"
  type        = string
  default     = "ami-06e8e64396022f397"
}
variable "DB_USERNAME" {
  description = "The username for the mysql db."
  type        = string
  sensitive   = true
}

variable "DB_PASSWORD" {
  description = "The password for the mysql db."
  type        = string
  sensitive   = true
}

variable "DB_HOST" {
  description = "The host for the mysql db."
  type        = string
}

variable "DB_NAME" {
  description = "The name for the mysql db."
  type        = string
}