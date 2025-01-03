output "etcd_rule_id" {
  value = grafana_rule_group.etcd_rules[count.index].id
}

output "etcd_rule_slow_query_uid" {
  value = grafana_rule_group.etcd_slow_requests[count.index].id
}

output "config_reloader_rule_id" {
  value = grafana_rule_group.config_reloader_rules[count.index].id 
}