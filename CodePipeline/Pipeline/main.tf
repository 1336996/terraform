provider "aws" {
  version = ">= 2.31.0"
  region = "us-east-1"
  shared_credentials_file = "/Users/mirzaa/.aws/credentials"
  profile = var.aws_profile_code
}

provider "aws" {
  alias = "code"
  version = ">= 2.31.0"
  region = "us-east-1"
  shared_credentials_file = "/Users/mirzaa/.aws/credentials"
  profile = var.aws_profile_code
}

provider "aws" {
  alias = "dev"
  version = ">= 2.31.0"
  region = "us-east-1"
  shared_credentials_file = "/Users/mirzaa/.aws/credentials"
  profile = var.aws_profile_dev
}

provider "github" {
  token        = var.github_oauth_token
  organization = var.source_owner
}

module "base_naming" {
  source = "../common_modules_terraform/bright_naming_conventions"
  app_group = var.project_app_group
  env = var.environment
  ledger = var.project_ledger
  site = var.site
  tier = var.tier
  zone = var.zone
}

# ------------------------------------------------------------------------------
# Defining names for Resources
# ------------------------------------------------------------------------------
module "s3b_primary_bucket_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "s3b"
  purpose = "primary"
}

module "s3b_failover_bucket_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "s3b"
  purpose = "failover"
}

module "s3b_cloudfront_logs" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "s3b"
  purpose = "cloudfrontlogs"
}

# ------------------------------------------------------------------------------
# Create Code Bucket
# ------------------------------------------------------------------------------
module "s3b_output_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "s3b"
  purpose = "finwebcodeoutput"
}

resource "aws_s3_bucket" "output" {
  bucket = module.s3b_output_naming.name
  acl = "private"
  provider = aws.code
  tags = module.s3b_output_naming.tags
}

# ------------------------------------------------------------------------------
# IAM Role  And Policy for Primary Bucket Replication
# ------------------------------------------------------------------------------

module "iro_primary_bucket_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "iro"
  purpose = "replication"
}

data "aws_iam_policy_document" "iro_primary_bucket" {
  statement {
    #sid = "s3ReplicationAssume"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_role_for_s3_replication" {
  provider    = aws.dev
  name = module.iro_primary_bucket_naming.name
  description = "Allow S3 to assume the role for replication"
  assume_role_policy = data.aws_iam_policy_document.iro_primary_bucket.json
  tags = module.iro_primary_bucket_naming.tags
}

module "irp_primary_bucket_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "irp"
  purpose = "replication"
}

data "aws_iam_policy_document" "data_policy_for_replication" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources = ["arn:aws:s3:::${module.s3b_primary_bucket_naming.name}"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl"
    ]
    resources = ["arn:aws:s3:::${module.s3b_primary_bucket_naming.name}/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete"
    ]
    resources = [ "arn:aws:s3:::${module.s3b_failover_bucket_naming.name}/*"]
  } 
}

resource "aws_iam_policy" "iam_policy_for_s3_replication" {
  provider = aws.dev
  name = module.irp_primary_bucket_naming.name
  description = "Allows reading for replication."
  policy = data.aws_iam_policy_document.data_policy_for_replication.json

}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  provider = aws.dev
  role = aws_iam_role.iam_role_for_s3_replication.name
  policy_arn = aws_iam_policy.iam_policy_for_s3_replication.arn
}

# ------------------------------------------------------------------------------
# Create Role for Dev Account for Deployments
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "assume_dev_deploy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_number_devops}:root"]
    }
  }
}


data "aws_iam_policy_document" "dev_deploy" {
  statement {
    effect = "Allow"
    actions = [
	  "elasticbeanstalk:*",
	  "ec2:*",
	  "ecs:*",
	  "ecr:*",
	  "elasticloadbalancing:*",
	  "autoscaling:*",
	  "cloudwatch:*",
	  "s3:*",
	  "sns:*",
	  "cloudformation:*",
	  "dynamodb:*",
	  "rds:*",
	  "sqs:*",
	  "logs:*",
	  "iam:GetPolicyVersion",
	  "iam:GetRole",
	  "iam:PassRole",
	  "iam:ListRolePolicies",
	  "iam:ListAttachedRolePolicies",
	  "iam:ListInstanceProfiles",
	  "iam:ListRoles",
	  "iam:ListServerCertificates",
	  "acm:DescribeCertificate",
	  "acm:ListCertificates",
	  "codebuild:CreateProject",
	  "codebuild:DeleteProject",
	  "codebuild:BatchGetBuilds",
	  "codebuild:StartBuild",
	  "iam:CreateRole",
      "iam:TagRole",
      "iam:AddRoleToInstanceProfile",
      "iam:CreateInstanceProfile",
      "iam:CreateServiceLinkedRole",
      "iam:CreatePolicy",
      "iam:AttachRolePolicy",
      "iam:DeleteRole",
      "iam:DeleteInstanceProfile",
      "iam:DeletePolicy",
      "iam:Get*",
      "iam:DeleteServiceLinkedRole",
      "iam:Remove*",
	  "route53:*",
	  "route53domains:*",
	  "iam:DetachRolePolicy",
	  "iam:ListInstanceProfilesForRole",
	]
    resources = "*"
  }
}

module "irp_dev_deployment_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "irp"
  env = var.environment                            
  purpose = "deployment"
}

resource "aws_iam_policy" "dev_deployment" {
  name = module.irp_dev_deployment_naming.name
  policy = data.aws_iam_policy_document.dev_deploy.json
  provider = aws.dev                                      
}

module "iro_dev_deployment_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.irp_dev_deployment_naming
  type = "iro"
}

resource "aws_iam_role" "dev_deployment" {
  name = module.iro_dev_deployment_naming.name
  provider = aws.dev                                      
  assume_role_policy = data.aws_iam_policy_document.assume_dev_deploy.json
  tags = module.iro_dev_deployment_naming.tags
}

resource "aws_iam_role_policy_attachment" "dev_deployment" {
  role = aws_iam_role.dev_deployment.name
  policy_arn = aws_iam_policy.dev_deployment.arn
  provider = aws.dev                                     
}

# ------------------------------------------------------------------------------
# Create Assume CodeBuild Assume Role Polcy
# ------------------------------------------------------------------------------

module "iro_cbd_assume_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "iro"
  purpose = "cbdassume"
}
module "iro_cbd_provision_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "iro"
  purpose = "cbdprovision"
}

data "aws_iam_policy_document" "assume_cbd_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cbd_build" {
  name = module.iro_cbd_assume_naming.name
  provider = aws.code
  assume_role_policy = data.aws_iam_policy_document.assume_cbd_role.json
  tags = module.iro_cbd_assume_naming.tags
}
resource "aws_iam_role" "cbd_provision" {
  name = module.iro_cbd_provision_naming.name
  provider = aws.code
  assume_role_policy = data.aws_iam_policy_document.assume_cbd_role.json
  tags = module.iro_cbd_provision_naming.tags
}

# ------------------------------------------------------------------------------
# Create Assume CodePipeline Assume Role Polcy
# ------------------------------------------------------------------------------
module "iro_cpl_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "iro"
  purpose = "cpl"
}
data "aws_iam_policy_document" "assume_cpl_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cpl_access" {
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [
      aws_codebuild_project.build.arn,
      aws_codebuild_project.provision.arn
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "${aws_iam_role.dev_deployment.arn}*"
    ]
  }
}

module "ipl_cpl_access_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.iro_cpl_naming
  type = "ipl"
  purpose = "cplaccess"
}

resource "aws_iam_policy" "cpl_access" {
  name = module.ipl_cpl_access_naming.name
  policy = data.aws_iam_policy_document.cpl_access.json
}

resource "aws_iam_role" "cpl_role" {
  name = module.iro_cpl_naming.name
  provider = aws.code
  assume_role_policy = data.aws_iam_policy_document.assume_cpl_role.json
  tags = module.iro_cpl_naming.tags
}


resource "aws_iam_role_policy_attachment" "cpl_access" {
  role = aws_iam_role.cpl_role.name
  policy_arn = aws_iam_policy.cpl_access.arn
}

# ------------------------------------------------------------------------------
# Create Regular Access controls for all Builds
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "cbd_build" {
  statement {
    effect = "Allow"
    actions = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [ "s3:*" ]
    resources = [ aws_s3_bucket.output.arn,
                 "${aws_s3_bucket.output.arn}/*"
               ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:GetParametersByPath"
     ]
    resources = [ "arn:aws:ssm:*:${var.aws_account_number_devops}:parameter/secure/aue1/c1/codebuild/*" ]
  }
  /*statement {                                                    
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "${aws_iam_role.dev_deployment.arn}*"
    ]
  }*/
}

module "irp_cbd_build_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "irp"
  purpose = "cdbbuild"
}

resource "aws_iam_policy" "cbd_build" {
  name = module.irp_cbd_build_naming.name
  description = join(" ", ["Standard Build Access policy for", module.irp_cbd_build_naming.name])
  policy = data.aws_iam_policy_document.cbd_build.json
}

resource "aws_iam_role_policy_attachment" "cdb_build_access" {
  role = aws_iam_role.cbd_build.name
  policy_arn = aws_iam_policy.cbd_build.arn
}

resource "aws_iam_role_policy_attachment" "cdb_provision_access" {
  role = aws_iam_role.cbd_provision.name
  policy_arn = aws_iam_policy.cbd_build.arn
}

resource "aws_iam_role_policy_attachment" "cdb_cpl_access" {
  role = aws_iam_role.cbd_provision.name
  policy_arn = aws_iam_policy.cpl_access.arn
}

resource "aws_iam_role_policy_attachment" "cpl_build_access" {
  role = aws_iam_role.cpl_role.name
  policy_arn = aws_iam_policy.cbd_build.arn
}

# ------------------------------------------------------------------------------
# Create Codepipeline
# ------------------------------------------------------------------------------

module "cpl_project_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "cpl"        
  purpose = "finweb"        
}
resource "aws_codepipeline" "codepipeline" {
  name = module.cpl_project_naming.name
  role_arn = aws_iam_role.cpl_role.arn
  provider = aws.code
  tags = module.cpl_project_naming.tags

  artifact_store {
    location = aws_s3_bucket.output.bucket
    type = "S3"
  }

  stage {
    name = "Source"
    action {
      name = "Source"
      category = "Source"
      owner = "ThirdParty"
      provider = "GitHub"
      version = "1"
      output_artifacts = ["sourceOutput"]
      run_order = "1"
      configuration = {
        Owner = var.source_owner
        Repo = var.source_repo
        Branch = var.code_source_branch
        OAuthToken = var.github_oauth_token
        PollForSourceChanges = "false"
      }
    }
	
	action {
       name = "Source_commonModules"
       category = "Source"
       owner = "ThirdParty"
       provider = "GitHub"
       version = "1"
       output_artifacts = ["commonModulesTerraform"]
       run_order = "1"
       configuration = {
         Owner = "BrightMLS"
         Repo = "common_modules_terraform"
         Branch = var.common_modules_source_branch
         OAuthToken = var.github_oauth_token
         PollForSourceChanges = "false"
       }
     }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["sourceOutput"]
      output_artifacts = ["buildOutput"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.cbdfinweb.name
      }
    }
  }

  stage {
    name = "Provision"
    action {
      name = "Provision"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["sourceOutput", "buildOutput", "commonModulesTerraform"]
      version = "1"
      configuration = {
        ProjectName = aws_codebuild_project.provision.name
        PrimarySource = "sourceOutput"
      }
    }
  }
  
  stage {
    name = "AllowDeployment"

    action {
      name = "Approval"
      category = "Approval"
      owner = "AWS"
      version = "1"
      provider = "Manual"
    }
  }
  
  stage {
    name = "Deploy"

    action {
      name = "Deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "ElasticBeanstalk"
      input_artifacts = ["buildOutput"]
      version = "1"	  
	  role_arn = aws_iam_role.dev_deployment.arn

      configuration = {
        ApplicationName = var.ApplicationName
        EnvironmentName = var.EnvironmentName
      }
    }
}

resource "aws_codepipeline_webhook" "codepipeline_webhook" {
  name            = "${aws_codepipeline.codepipeline.name}-webhook-codepipeline"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.codepipeline.name

  authentication_configuration {
    secret_token = var.webhook_secret
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/${var.code_source_branch}"
  }
}

resource "github_repository_webhook" "github_webhook" {
  repository = var.source_repo
  configuration {
    url          = aws_codepipeline_webhook.codepipeline_webhook.url
    content_type = "json"
    insecure_ssl = false
    secret       = var.webhook_secret
  }

  events = ["push"]
}

# ------------------------------------------------------------------------------
# Create Codebuild
# ------------------------------------------------------------------------------
module "cbd_build_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "cbd"                        
  purpose = "finweb"
}

resource "aws_codebuild_project" "build" {
  name = module.cbd_build_naming.name
  provider = aws.code
  description = module.cbd_build_naming.name
  build_timeout = var.timeout_for_build
  service_role = aws_iam_role.cbd_build.arn
  tags = module.cbd_build_naming.tags

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "S3"
    location = aws_s3_bucket.output.bucket
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/build/${module.cbd_build_naming.name}"
      stream_name = module.cbd_build_naming.name
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

# ------------------------------------------------------------------------------
# Create Provisioning
# ------------------------------------------------------------------------------
module "cbd_provision_naming" {
  source = "../../common_modules_terraform/bright_naming_conventions"
  base_object = module.base_naming
  type = "cbd"                       
  purpose = "finweb"
}

resource "aws_codebuild_project" "provision" {
  name = module.cbd_provision_naming.name
  provider = aws.code
  description = module.cbd_provision_naming.name
  build_timeout = var.timeout_for_provision
  service_role = aws_iam_role.cbd_provision.arn
  tags = module.cbd_provision_naming.tags

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "S3"
    location = aws_s3_bucket.output.bucket
  }

  environment {
    compute_type = var.compute_type
    image = var.image
    type = var.type
    image_pull_credentials_type = var.image_pull_credentials_type
  
  environment_variable {
      name  = "S3_FOR_TERRAFORM_STATE"
      value =  join("", ["s3://", aws_s3_bucket.output.bucket, "/terraform_state"]) 
    }
    environment_variable {
      name  = "TERRAFORM_DEPLOYMENT_ROLE"
      value = aws_iam_role.dev_deployment.arn
    }   
    
    environment_variable {
      name  = "TERRAFORM_WORKSPACE"
      value = var.environment
    }  

    environment_variable {
      name  = "S3_PRIMARY_BUCKET"
      value = join("", ["s3://", module.s3b_primary_bucket_naming.name])
    } 

    environment_variable {
      name  = "S3_FAILOVER_BUCKET"
      value = join("", ["s3://", module.s3b_failover_bucket_naming.name])
    } 
    environment_variable {
      name  = "env_build"
      value =  var.env_build
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/provisioning/${module.cbd_provision_naming.name}"
      stream_name = module.cbd_provision_naming.name
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspecTerraform.yml"
  }
}