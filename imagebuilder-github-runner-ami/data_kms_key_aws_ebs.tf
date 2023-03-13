data "aws_kms_key" "aws_ebs" {
  key_id = "alias/aws/ebs"
}
