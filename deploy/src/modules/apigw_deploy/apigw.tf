data "aws_api_gateway_rest_api" "api_gw_endpoint" {
  name = "ehr-translate-${var.environment}"
}

resource "aws_api_gateway_deployment" "api_gw_deployment" {
  depends_on = [ "null_resource.depends_on" ]

  rest_api_id = "${data.aws_api_gateway_rest_api.api_gw_endpoint.id}"
  stage_name  = "${var.environment}"
}
