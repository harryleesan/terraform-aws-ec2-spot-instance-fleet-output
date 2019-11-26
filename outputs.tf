output "id" {
  description = "List of IDs of instances"
  value       = ["${data.aws_instance.spot_instance.*.id}"]
}

output "private_dns" {
  description = "List of private DNS names"
  value       = ["${data.aws_instance.spot_instance.*.private_dns}"]
}
