output "webserver_link" {
  description = "Link to the webserver"
  value       = "http://${module.ec2-instance.public_ip}"
}

output "instance_id" {
  description = "ID of the webserver"
  value       = module.ec2-instance.id
}