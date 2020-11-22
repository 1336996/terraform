/*output "ns-servers" {
    value="aws_route53_zone.hosted_zone.name-servers"
}
*/

output "subnet_id1" {
    value=aws_subnet.private_subnet_1.id
}

output "subnet_id2" {
    value=aws_subnet.private_subnet_2.id
}

output "vpc_id" {
    value=aws_vpc.vpc.id
}


output "security_group_id" {
    value=aws_security_group.alb_sg.id
}

output "trgt_grp_arn" {
    value=aws_lb_target_group.alb_trgt_grp.arn
}

