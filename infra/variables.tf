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
    region      = "eu-central-1"
  }
}

variable "db_username" {
  description = "The username for the mysql db."
  type        = string
  default     = "eu-central-1"
  sensitive = true
}

variable "db_password" {
  description = "The password for the mysql db."
  type        = string
  default     = "eu-central-1"
  sensitive = true
}