provider "aws" {
  region = "${var.aws_cluster_region}"
}

data "aws_ami" "distro" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_iam_policy_document" "spot-fleet-role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["spotfleet.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "spot-instances" {
  name               = "spot-instances"
  assume_role_policy = data.aws_iam_policy_document.spot-fleet-role.json
}

resource "aws_iam_role_policy_attachment" "spot-instance-tagging" {
  role       = "${aws_iam_role.spot-instances.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

resource "aws_spot_fleet_request" "ec2_spot_fleet_request" {
  iam_fleet_role                      = "${aws_iam_role.spot-instances.arn}"
  target_capacity                     = 1
  allocation_strategy                 = "lowestPrice"
  terminate_instances_with_expiration = true

  launch_specification {
    instance_type = "t3.small"
    ami           = "${data.aws_ami.distro.id}"

    root_block_device {
      volume_type = "gp2"
      volume_size = "10"
    }
  }

  lifecycle {
    ignore_changes = [
      valid_until,
      valid_from
    ]
  }
}

module "ec2_spot" {
  source          = "../"
  spot_request_id = "${aws_spot_fleet_request.ec2_spot_fleet_request.id}"
}
