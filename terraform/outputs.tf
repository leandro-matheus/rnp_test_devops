output "db_container_id" {
  value = docker_container.db.id
}

output "agent_container_id" {
  value = docker_container.agent.id
}

output "grafana_url" {
  value = "http://localhost:${var.grafana_port}"
}
