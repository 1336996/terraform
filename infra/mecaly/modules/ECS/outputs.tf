output "ecs_id" {
    value=aws_ecs_cluster.dp_insight_ecs.id
}

output "repository_url" {
    value= aws_ecr_repository.dp_insight_ecr.repository_url
}