locals {
  bootstrap_script = file("${path.module}/templates/userdata.sh")
}