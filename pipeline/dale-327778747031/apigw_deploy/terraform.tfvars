terragrunt = {
  terraform {
    source = "../../src//apigw_deploy"
  }

  remote_state {
    backend = "s3"
    config {
      bucket = "prm-327778747031-terraform-states"
      key = "dale/pipeline/apigw_deploy/terraform.tfstate"
      region = "eu-west-2"
      encrypt = true
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

aws_region = "eu-west-2"
environment = "dale"
iam_role = "arn:aws:iam::327778747031:role/codebuild"
github_token_name = "/NHS/dale-327778747031/tf/github_token"
