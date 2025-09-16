# Get all available AZs in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

output "az_names" {
  value = data.aws_availability_zones.available.names
}

output "az_ids" {
  value = data.aws_availability_zones.available.zone_ids
}