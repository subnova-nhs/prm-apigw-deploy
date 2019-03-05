resource "aws_s3_bucket" "artifacts" {
  bucket = "prm-${data.aws_caller_identity.current.account_id}-apigw-deploy-pipeline-artifacts-${var.environment}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

# Role to use for running pipeline
data "aws_iam_policy_document" "codepipeline_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pipeline_role" {
  name               = "prm-apigw-deploy-pipeline-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.codepipeline_assume.json}"
}

data "aws_iam_policy_document" "pipeline_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:DeleteObject*",
      "s3:GetObject*",
      "s3:PutObject*",
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.artifacts.arn}/*",
      "arn:aws:s3:::prm-${data.aws_caller_identity.current.account_id}-send-lambda-pipeline-artifacts-${var.environment}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketVersioning",
    ]

    resources = [
      "${aws_s3_bucket.artifacts.arn}",
      "arn:aws:s3:::prm-${data.aws_caller_identity.current.account_id}-send-lambda-pipeline-artifacts-${var.environment}"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = [
      "${aws_codebuild_project.deploy.arn}",
    ]
  }
}

resource "aws_iam_role_policy" "pipeline_role_policy" {
  name   = "prm-apigw-deploy-pipeline"
  role   = "${aws_iam_role.pipeline_role.id}"
  policy = "${data.aws_iam_policy_document.pipeline_role_policy.json}"
}

# Pipeline
data "aws_ssm_parameter" "github_token" {
  name = "${var.github_token_name}"
}

resource "aws_codepipeline" "pipeline" {
  name     = "prm-apigw-deploy-${var.environment}"
  role_arn = "${aws_iam_role.pipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.artifacts.bucket}"
    type     = "S3"
  }

  stage {
    name = "source"

    action {
      name             = "source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        Owner      = "subnova-nhs"
        Repo       = "prm-apigw-deploy"
        Branch     = "master"
        OAuthToken = "${data.aws_ssm_parameter.github_token.value}"
      }
    }

    action {
      name             = "send_lambda"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["send_lambda"]
      run_order        = 1

      configuration {
        S3Bucket = "prm-${data.aws_caller_identity.current.account_id}-send-lambda-pipeline-artifacts-${var.environment}"
        S3ObjectKey = "prm-send-lambda-${var.environment}/outputs/output.json"     
      }
    }
  }

  stage {
    name = "deploy"

    action {
      name            = "deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      output_artifacts = ["terraform"]

      configuration {
        ProjectName = "${aws_codebuild_project.deploy.name}"
        PrimarySource = "source"
      }
    }
  }

  stage {
    name = "notify"

    action {
      name = "notify"
      category = "Deploy"
      owner = "AWS"
      provider = "S3"
      version = "1"
      input_artifacts = ["terraform"]

      configuration {
        BucketName = "${aws_s3_bucket.artifacts.bucket}"
        Extract = "true"
        ObjectKey = "prm-apigw-deploy-${var.environment}/outputs"
      }
    }
  }
}

