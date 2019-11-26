data "aws_instances" "spot_instances" {
  instance_tags = {
    "aws:ec2spot:fleet-request-id" = var.spot_request_id
  }
  filter {
    name   = "tag:aws:ec2spot:fleet-request-id"
    values = [var.spot_request_id]
  }
  instance_state_names = ["running", "pending"]
}

data "aws_instance" "spot_instance" {
  count       = length(data.aws_instances.spot_instances.ids)
  instance_id = data.aws_instances.spot_instances.ids[count.index]
}
