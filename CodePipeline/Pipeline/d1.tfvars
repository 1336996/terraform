#profile and account no for devops and environment
aws_profile_code = "build_code"
aws_profile_dev = "dev"

aws_account_number_env = "714767054201"
aws_account_number_devops = "522857095635"

#common_modules_naming
project_app_group = "fin"
project_ledger = "ABC123"
environment = "d1"
site = "aue1"
tier = "CountyTaxRates"
zone = "z1"



code_source_branch = "master"
common_modules_source_branch = "develop"

#timeout variables
timeout_for_build = "120"
timeout_for_provision = "60"

#CodeBuild Env Properties
compute_type = "BUILD_GENERAL1_MEDIUM"
image = "aws/codebuild/standard:3.0"
type = "LINUX_CONTAINER"
image_pull_credentials_type = "CODEBUILD"
