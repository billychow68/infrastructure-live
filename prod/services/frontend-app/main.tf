
module "frontend" {
  #source   = "/Users/billy/git/infrastructure-modules//modules/frontend-app"
  source = "git::git@github.com:billychow68/infrastructure-modules.git//modules//frontend-app?ref=v0.0.1"
  min_size = 2
  max_size = 4
}

# THIS BREAKS THE MIN_SIZE, MAX_SIZE VARIABLE INPUT, WHY?
# Modules can also have output variables. For example, in production, you may
# want to add an auto scaling policy that increases the number of EC2 Instances
# in the ASG when CPU usage is over 85%. To do that, you need to be able to
# access the name of the ASG that’s defined in the frontend-app module, so we’ll
# add it as an output variable in /modules/frontend-app/outputs.tf
# resource "aws_autoscaling_policy" "scale_out" {
#   name                    = "scale-out-frontend-app"
#   autoscaling_group_name  = "${module.frontend.asg_name}"
#   adjustment_type         = "ChangeInCapacity"
#   policy_type             = "SimpleScaling"
#   scaling_adjustment      = 1
#   cooldown                = 200
# }
