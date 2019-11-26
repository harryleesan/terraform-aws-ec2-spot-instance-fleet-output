output "id" {
  description = "List of EC2 IDs"
  value       = ["${module.ec2_spot.id}"]
}

output "private_dns" {
  description = "List of EC2 private_dns"
  value       = ["${module.ec2_spot.private_dns}"]
}
