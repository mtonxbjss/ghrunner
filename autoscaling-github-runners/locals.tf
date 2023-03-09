locals {
  resource_tags = merge(
    {
      "TfModule" : "mtonxbjss/ghrunner/ec2-github-runner",
    },
    var.resource_tags
  )

  launch_template_ami_id = length(var.ec2_imagebuilder_image_arn) > 0 ? tolist(data.aws_imagebuilder_image.github_latest[0].output_resources[0].amis)[0].image : var.ec2_ami
}
