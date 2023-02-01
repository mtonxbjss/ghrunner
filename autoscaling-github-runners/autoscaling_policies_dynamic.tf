# #@filename_check_ignore - file contains multiple policies of equal importance so plural filename is ok

resource "aws_autoscaling_policy" "dynamic_scale_out" {
  count                     = var.ec2_dynamic_scaling_enabled ? 1 : 0
  name                      = "${var.unique_prefix}-dynamic-scale-out"
  autoscaling_group_name    = aws_autoscaling_group.github_runner.name
  adjustment_type           = "ChangeInCapacity"
  policy_type               = "StepScaling"
  metric_aggregation_type   = "Average"
  estimated_instance_warmup = 300

  step_adjustment {
    scaling_adjustment          = 2
    metric_interval_upper_bound = ""
    metric_interval_lower_bound = -5
  }
  step_adjustment {
    scaling_adjustment          = 4
    metric_interval_upper_bound = -5
    metric_interval_lower_bound = -15
  }
  step_adjustment {
    scaling_adjustment          = 6
    metric_interval_upper_bound = -15
    metric_interval_lower_bound = ""
  }
}

resource "aws_autoscaling_policy" "dynamic_scale_in" {
  count                  = var.ec2_dynamic_scaling_enabled ? 1 : 0
  name                   = "${var.unique_prefix}-dynamic-scale-in"
  scaling_adjustment     = -1
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 600
  autoscaling_group_name = aws_autoscaling_group.github_runner.name
}

resource "aws_cloudwatch_metric_alarm" "dynamic_scale_out_free_capacity" {
  count               = var.ec2_dynamic_scaling_enabled ? 1 : 0
  alarm_name          = "${var.unique_prefix}-${var.ec2_github_runner_name}-dynamic-scale-out-fc"
  alarm_description   = "AUTOSCALING: Drives the dynamic scaling out (adding instances) of the github runners based on the amount of free capacity"
  evaluation_periods  = "5"                                    // within the 5 most recent periods
  comparison_operator = "LessThanThreshold"                    // scale out if the "free capacity" metric is less than
  threshold           = var.ec2_maximum_concurrent_github_jobs // the concurrency of a single runner
  datapoints_to_alarm = "2"                                    // in 2 of those 5 evaluated periods
  treat_missing_data  = "notBreaching"                         // (treat missing data as free capacity = 0)

  actions_enabled = "true"
  ok_actions      = []
  alarm_actions = [
    aws_autoscaling_policy.dynamic_scale_out.0.arn
  ]

  metric_query {
    id          = "fc"
    expression  = "(ar*${var.ec2_maximum_concurrent_github_jobs})-(rj+qj)"
    label       = "Free GitHub Capacity"
    return_data = "true"
  }

  metric_query {
    id    = "ar"
    label = "Active Runners"
    metric {
      stat        = "Average"                 // the average of
      namespace   = "AWS/AutoScaling"         // the AWS/AutoScaling
      metric_name = "GroupInServiceInstances" // GroupInServiceInstances metric
      period      = "60"                      // over 60 seconds (1 min)
      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.github_runner.name
      }
    }
  }

  metric_query {
    id    = "rj"
    label = "Running Jobs"
    metric {
      stat        = "Maximum"                                      // the average of
      namespace   = local.cloudwatch_logs_metric_filters_namespace // the custom
      metric_name = "githubRunning"                                // githubRunning metric
      period      = "60"                                           // over 60 seconds (1 min)
      dimensions = {
        Tag = var.ec2_github_runner_tag_list
      }
    }
  }

  metric_query {
    id    = "qj"
    label = "Queued Jobs"
    metric {
      stat        = "Maximum"                                      // the average of
      namespace   = local.cloudwatch_logs_metric_filters_namespace // the custom
      metric_name = "githubQueued"                                 // githubPending metric
      period      = "60"                                           // over 60 seconds (1 min)
      dimensions = {
        Tag = var.ec2_github_runner_tag_list
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "dynamic_scale_in_free_capacity" {
  count               = var.ec2_dynamic_scaling_enabled ? 1 : 0
  alarm_name          = "${var.unique_prefix}-${var.ec2_github_runner_name}-dynamic-scale-in-fc"
  alarm_description   = "AUTOSCALING: Drives the dynamic scaling in (removing instances) of the github runners based on the amount of free capacity"
  evaluation_periods  = "6"                                        // within the 6 most recent periods
  comparison_operator = "GreaterThanOrEqualToThreshold"            // scale in if the "free capacity" metric is greater than or equal to
  threshold           = var.ec2_maximum_concurrent_github_jobs * 3 // 3x the concurrency of a single runner
  datapoints_to_alarm = "6"                                        // in all 6 of those 6 evaluated periods
  treat_missing_data  = "notBreaching"                             // (treat missing data as free capacity = 0)

  actions_enabled = "true"
  ok_actions      = []
  alarm_actions = [
    aws_autoscaling_policy.dynamic_scale_in.0.arn
  ]

  metric_query {
    id          = "fc"
    expression  = "(ar*${var.ec2_maximum_concurrent_github_jobs})-(rj+qj)"
    label       = "Free GitHub Capacity"
    return_data = "true"
  }

  metric_query {
    id    = "ar"
    label = "Active Runners"
    metric {
      stat        = "Average"                 // the average of
      namespace   = "AWS/AutoScaling"         // the AWS/AutoScaling
      metric_name = "GroupInServiceInstances" // GroupInServiceInstances metric
      period      = "300"                     // over 300 seconds (5 mins)
      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.github_runner.name
      }
    }
  }

  metric_query {
    id    = "rj"
    label = "Running Jobs"
    metric {
      stat        = "Maximum"                                      // the average of
      namespace   = local.cloudwatch_logs_metric_filters_namespace // the custom
      metric_name = "githubRunning"                                // githubRunning metric
      period      = "300"                                          // over 300 seconds (5 mins)
      dimensions = {
        Tag = var.ec2_github_runner_tag_list
      }
    }
  }

  metric_query {
    id    = "qj"
    label = "Queued Jobs"
    metric {
      stat        = "Sum"                                          // the average of
      namespace   = local.cloudwatch_logs_metric_filters_namespace // the custom
      metric_name = "githubQueued"                                 // githubPending metric
      period      = "300"                                          // over 300 seconds (5 mins)
      dimensions = {
        Tag = var.ec2_github_runner_tag_list
      }
    }
  }
}
