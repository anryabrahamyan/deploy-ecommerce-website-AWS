# output "webserver_link" {
#   description = "Link to the webserver"
#   value       = "http://${module.ec2-instance.public_ip}"
# }

# output "instance_id" {
#   description = "ID of the webserver"
#   value       = module.ec2-instance.id
# }

#output elb dns name
output "elb_dns_name" {
  description = "DNS name of the ELB"
  value       = module.elb_http.elb_dns_name
}