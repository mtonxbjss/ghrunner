## github-RUNNER Module

#### Purpose
This module contains all resources to launch a generic github actions runner instance. It is not specific to any project/deployment and can be re-used.

During bootstrapping the instance will register itself with the github Server identified by the parameters (URL and Personal Access Token).

The instance will be deployed into a self-healing autoscaling group by default, although the min/max/desired settings can be amended to increase the size of the ASG. Multiple instances should be able to operate in this ASG with no load balancer and have the effect of being multiple independent and fully functional runners.

A single project can run this module multiple times if different runners with different characteristics are required (e.g. runners with different registrations, different tags, etc.)

Autoscaling is provided using optional scheduled scale up/down at the start/end of each day, and also dynamic scaling based on github metrics for the number of running and queued jobs, and the number of runner EC2 instances and their number of concurrent runner agents.

