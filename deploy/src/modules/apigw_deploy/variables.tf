variable "aws_region" {
  description = "The region in which the infrastructure will be deployed"
}

variable "environment" {
  description = "The name of the environment being deployed"
}

variable "depends_on" {
  description = "List of values to use for creating terraform dependencies to control ordering"
  type = "list"
  default = []
}

variable "depends_on_count" {
  description = "The number of elements in the depends_on list"
  default = 0
}