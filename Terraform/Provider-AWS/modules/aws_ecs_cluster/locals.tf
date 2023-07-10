locals {
  prefix = "${var.project}-${var.stack}-${var.cluster_revision}"
  cp = "${var.project}-${var.stack}-${var.cluster_revision}-cp"
}