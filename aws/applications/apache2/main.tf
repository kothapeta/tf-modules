module "apache2" {
       source = "../../resources/asg"
       app_name = var.app_name
       
       private_subnets = var.private_subnets
       vpc_id   = var.vpc_id
       
       ami      = var.ami
       env      = var.env      
       max_size = var.max_size
       min_size = var.min_size
       desired_capacity = var.desired_capacity
       ebs_type   = var.ebs_type
       ebs_size   = var.ebs_size
       ebs_delete = var.ebs_delete
       ssh_key    = var.ssh_key
       health_check_type = var.health_check_type

      
       instance_type  = var.instance_type
       instance_profile = module.apache2_iam.instance_profile_arn
}
module "apache2_lb" {
  source = "../../resources/lb"

  app_name      = var.app_name
  vpc_id        = var.vpc_id
  subnets       = var.private_subnets
  env           = var.env

  type            =  var.lb_type
  internal        = "true"
  apache2_lb      = var.apache2_lb

  listener_lb = [
    {
      port      = var.apache2_ports["inbound"]
      dest_port = tonumber(var.apache2_ports["inbound"])
    },
  ]

  listener_srv = [
    {
      "port" = var.apache2_ports["inbound"]
    },
  ]
}

resource "aws_autoscaling_attachment" "apache2_healthcheck_lb" {
  count                  = var.apache2_lb == "true" ? 0 : 1
  autoscaling_group_name = element(module.apache2.asg_id, 0)
  elb                    = module.apache2_lb.lb_id
}

