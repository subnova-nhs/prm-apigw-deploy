module "apigw_deploy" {
    source = "../modules/apigw_deploy"

    aws_region = "${var.aws_region}"
    environment = "${var.environment}"
}
