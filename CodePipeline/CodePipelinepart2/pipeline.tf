resource "aws_codepipeline" "pipeline" {
  name     = "incredible-website-pipeline"
  role_arn = "${aws_iam_role.build.arn}"

  artifact_store {
    location = "${aws_s3_bucket.artifacts.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        Owner      = "${var.github_organization}"
        Repo       = "${var.github_repository}"
        Branch     = "${var.github_branch}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["source"]
      output_artifacts = ["artifact"]
      version = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.build.name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name = "Deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "ElasticBeanstalk"
      input_artifacts = ["artifact"]
      version = "1"

      configuration {
        ApplicationName = "${aws_elastic_beanstalk_application.app.name}"
        EnvironmentName = "${aws_elastic_beanstalk_environment.production.name}"
      }
    }
  }
}


resource "aws_s3_bucket" "artifacts" {
  bucket = "incredible-website-artifacts"
  acl    = "private"
}

resource "aws_codebuild_project" "build" {
  name = "incredible-website-project"
  description = "Builds the client files for the incredible-website environment."
  build_timeout = "5"
  service_role = "${aws_iam_role.build.arn}"

  artifacts = {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/nodejs:7.0.0"
    type = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "S3_BUCKET"
      "value" = "${aws_s3_bucket.artifacts.bucket}"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}