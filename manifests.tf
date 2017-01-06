#
## Compute Manifest
#

# Notes: why does each compute module have it own manifest? the reasoning behind this is to
# multiple version of the compute group to exist within the same Kuberneres cluster, you might
# have one for a dedicated up, or

## Template
data "gotemplate_file" "kube_proxy" {
  template = "${file("${path.module}/assets/manifests/kube-proxy.yml")}"
  vars = {
    aws_region               = "${var.aws_region}"
    kmsctl_image             = "${var.kmsctl_image}"
    kubeapi_dns_name         = "${var.kubeapi_dns}"
    kubernetes_image         = "${var.kubernetes_image}"
    name                     = "${var.compute_name}"
    secrets_bucket_name      = "${var.secrets_bucket_name}"
  }
}

## S3 Object
resource "aws_s3_bucket_object" "kube_proxy" {
  bucket     = "${var.secrets_bucket_name}"
  key        = "manifests/compute/${var.compute_name}/kube-proxy.yml"
  content    = "${data.gotemplate_file.kube_proxy.rendered}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.caller.account_id}:key/${var.kms_master_id}"
}
