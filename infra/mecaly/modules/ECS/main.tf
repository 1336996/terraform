

resource "aws_ecr_repository" "dp_insight_ecr" {
  name                 = var.repo_name
}

#ECS

resource "aws_ecs_cluster" "dp_insight_ecs" {
  name = var.cluster_name
  #capacity_providers = var.capacity_providers
}


data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

#ECS worker Service

resource "aws_ecs_service" "worker_service" {
  name            = var.worker_service_name
  cluster         = aws_ecs_cluster.dp_insight_ecs.id
  task_definition = aws_ecs_task_definition.worker_task.arn
  desired_count   = var.count1
  launch_type      = var.launch_type
  network_configuration {
    security_groups = var.security_group
    subnets = var.subnet_ids
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = var.target_group
    container_name   = var.worker_app_name 
    container_port   = 8080
  }
  depends_on = [null_resource.script_call,aws_ecs_task_definition.worker_task]
  
}


# container worker template
data "template_file" "worker_app" {
  template = file("./modules/ECS/task/service.json")
# template = file("./task/service.json")

  vars = {
    app_name = var.worker_app_name
    app_image = "${aws_ecr_repository.dp_insight_ecr.repository_url}/dp-insight:image1"

    #host_port = var.host_port
    #container_port = var.worker_container_port
    #fargate_cpu = var.fargate_cpu
    #fargate_memory = var.fargate_memory
  }
}

#ECS worker Task Defination

resource "aws_ecs_task_definition" "worker_task" {
  family                   = "task1"
  network_mode             = "awsvpc"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = data.template_file.worker_app.rendered
}


###########null resource##########

resource "null_resource" "rep_url_name" {
  
    provisioner "local-exec" {
    
        command = "echo ${aws_ecr_repository.dp_insight_ecr.repository_url} > rep_url.txt"
        #interpreter = ["/bin/bash"]

  }
	depends_on = [aws_ecr_repository.dp_insight_ecr]

}

resource "null_resource" "script_call" {
  
    provisioner "local-exec" {
        command = "script_call.sh"
        interpreter = ["/bin/bash"]
	
  }
depends_on = [null_resource.rep_url_name]
}

#####################API################

# container api template


data "template_file" "api_app" {
  template = file("./modules/ECS/task/service.json")
  vars = {
    app_name = var.api_app_name
    app_image = "${aws_ecr_repository.dp_insight_ecr.repository_url}/dp-insight:image2"
    
    #host_port = var.host_port
    #container_port = var.api_container_port
    #fargate_cpu = var.fargate_cpu
    #fargate_memory = var.fargate_memory
    
  }
}

#ECS api Task Defination

resource "aws_ecs_task_definition" "api_task" {
  family                   = "task2"
  network_mode             = "awsvpc"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = data.template_file.api_app.rendered
}

#ECS api Service


resource "aws_ecs_service" "api_service" {
  name            = var.api_service_name
  cluster         = aws_ecs_cluster.dp_insight_ecs.id
  task_definition = aws_ecs_task_definition.api_task.arn
  desired_count   = var.count1
  launch_type      = var.launch_type
  network_configuration {
    security_groups = var.security_group
    subnets = var.subnet_ids
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = var.target_group
    container_name   = var.api_app_name 
    container_port   = 8080
  }
  depends_on = [null_resource.script_call,aws_ecs_task_definition.api_task]
  
}

