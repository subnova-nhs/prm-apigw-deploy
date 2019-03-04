resource "null_resource" "depends_on" {
    count = "${var.depends_on_count}"

    triggers = {
        depends_on = "${element(var.depends_on, count.index)}"
    }
}