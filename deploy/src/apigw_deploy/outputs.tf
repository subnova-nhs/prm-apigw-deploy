output "completed" {
    value = "${uuid()}"
}

output "invoke_endpoint" {
    value = "${module.apigw_deploy.invoke_endpoint}"
}