terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.13.0"
    }
  }
}

provider "docker" {}

# Rede Docker
resource "docker_network" "monitor_net" {
  name = "prova_net"
}

# Volume de dados do Postgres
resource "docker_volume" "db_data" {
  name = "prova_devops_db_data"
}

# Imagem e container do Postgres
resource "docker_image" "postgres" {
  name         = "postgres:13"
  keep_locally = false
}

resource "docker_container" "db" {
  name = "prova-db"
  # usa image_id em vez de .latest
  image   = docker_image.postgres.image_id
  restart = "unless-stopped"

  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}",
  ]

  ports {
    internal = 5432
    external = var.db_port
  }

  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = docker_network.monitor_net.name
  }
}

# Imagem e container do Agent Python
resource "docker_image" "agent" {
  name = "${path.module}/agent"
  build {
    context = "${path.module}/agent"
  }
}

resource "docker_container" "agent" {
  name = "prova-agent"
  # usa image_id em vez de .latest
  image   = docker_image.agent.image_id
  restart = "unless-stopped"

  env = [
    "DB_HOST=${docker_container.db.name}",
    "DB_PORT=5432",
    "DB_NAME=${var.db_name}",
    "DB_USER=${var.db_user}",
    "DB_PASSWORD=${var.db_password}",
    "TARGET_HOSTS=${var.targets}",
    "INTERVAL=${var.interval}",
  ]

  networks_advanced {
    name = docker_network.monitor_net.name
  }

  depends_on = [
    docker_container.db
  ]
}

# Imagem e container do Grafana
resource "docker_image" "grafana" {
  name = "grafana/grafana:latest"
}

resource "docker_container" "grafana" {
  name = "prova-grafana"
  # usa image_id em vez de .latest
  image   = docker_image.grafana.image_id
  restart = "unless-stopped"

  env = [
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}",
  ]

  ports {
    internal = 3000
    external = var.grafana_port
  }

  networks_advanced {
    name = docker_network.monitor_net.name
  }

  depends_on = [
    docker_container.db
  ]
}
