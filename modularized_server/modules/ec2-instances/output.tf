output "instances_ids" {
  description = "values of instances ids"
  value = [for instance in aws_instance.servers : instance.id]
}