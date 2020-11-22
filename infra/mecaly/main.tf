module "network" {
    source="./modules/network/"
    vpc_cidr=var.vpc_cidr
    public_cidr=var.public_cidr
    private_cidr=var.private_cidr
    app_port=var.app_port
}

module "ECS" {
    source="./modules/ECS/"
    repo_name=var.repo_name
    cluster_name=var.cluster_name
    worker_app_name = var.worker_app_name
    worker_service_name  = var.worker_service_name
    api_app_name = var.api_app_name
    api_service_name  = var.api_service_name
    count1  = var.count1
    launch_type = var.launch_type
    target_group = module.network.trgt_grp_arn
    security_group = [module.network.security_group_id]
    subnet_ids = [module.network.subnet_id1,module.network.subnet_id2]
    depends_on = [module.network]

}


module "database" {
    source="./modules/database/"
    identifier=var.identifier
    storage_type=var.storage_type
    allocated_storage=var.allocated_storage
    engine=var.engine
    engine_version=var.engine_version
    instance_class=var.instance_class
    family=var.family
    username=var.username
    password=var.password
    subnet_ids=[module.network.subnet_id1,module.network.subnet_id2]
    vpc_id=module.network.vpc_id
    vpc_cidr=var.vpc_cidr
    name=var.name
    dbname=var.dbname
}   

module "s3" {
    source="./modules/s3/"
    frontend_bucket_name=var.frontend_bucket_name
    data_bucket_name=var.data_bucket_name
}
