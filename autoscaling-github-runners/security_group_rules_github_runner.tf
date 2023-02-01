resource "aws_security_group_rule" "egress_http" {
  description = "Allow egress from github runners to the Internet on port 80 (http)"
  type        = "egress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.github_runner.id
}

resource "aws_security_group_rule" "egress_https" {
  description = "Allow egress from github runners to the Internet on port 443 (https)"
  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.github_runner.id
}

resource "aws_security_group_rule" "egress_icmp" {
  description = "Allow ping traffic egress from github runners to the Internet" # required for github healthchecks
  type        = "egress"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.github_runner.id
}
