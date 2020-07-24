variable "aws_account_number_devops" {
  default = {}
}

variable "aws_account_number_env" {
  default = {}
}
variable "aws_profile_code" {
  default = {}
}

variable "aws_profile_dev" {
  default = {}
}

variable "project_app_group" {
  default = {}
}

variable "project_ledger" {
  default = {}
}

variable "environment" {
  default = {}
}

variable "site" {
  default = {}
}

variable "tier" {
  default = {}
}

variable "zone" {
  default = {}
}

variable "code_source_branch" {
  default = {}
}
variable "common_modules_source_branch" {
  default = {}
}

variable "source_owner" {
  default = "BrightMLS"
}

variable "source_repo" {
  default = "Web.PublicRecords"
}

variable "github_oauth_token" {
  default = "9150bd901b101fb3d3ed1a83a8ff4f05b5daec24"
}
variable "webhook_secret" {
  default = "605812603917560193610923547392852355725138094023586509155804202647131765766268547419324037557721"
}

#timeout variables
variable "timeout_for_build" {
  default = {}
}

variable "timeout_for_provision" {
  default = {}
}

#Code Bild Env Properties
variable "compute_type" {
  default = {}
}

variable "image" {
  default = {}
}

variable "type" {
  default = {}
}

variable "image_pull_credentials_type" {
  default = {}
}