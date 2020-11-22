family = "postgres12"
allocated_storage    = 80
storage_type         = "gp2"
engine               = "postgres"
engine_version       = "12.3"
instance_class       = "db.t2.micro"
dbname               = "dpinsightdb"
username             = "rohit"
password             = "agarwal2108"
vpc_cidr             = "10.0.0.0/16"
public_cidr          = "10.0.1.0/24"
private_cidr         = ["10.0.2.0/24","10.0.3.0/24"]
data_bucket_name     = "dp-insight-data"
frontend_bucket_name = "dp-insight-frontend"
cluster_name         = "dp-insight"
repo_name            = "dp-insight"
identifier           = "dp-insight-db"
name                 = "dp-insight"
app_port             = "80"
worker_app_name      = "dp-insight-worker"
worker_service_name   = "dp-insight-worker_service"
count1                = 1
launch_type           = "FARGATE"    
api_app_name          = "dp-insight-api"
api_service_name      = "dp-insight-api_service"
#host_port            = "80"
#worker_container_port = "8080"
#fargate_cpu          = "256"
#fargate_memory       = "256"
#capacity_providers   = "FARGATE" 




