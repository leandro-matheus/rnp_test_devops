variable "db_user" {
  type    = string
  default = "monitor"
}

variable "db_password" {
  type    = string
  default = "monitor_pass"
}

variable "db_name" {
  type    = string
  default = "monitor_db"
}

variable "db_port" {
  type    = number
  default = 5433
}

variable "targets" {
  type    = string
  default = "google.com,youtube.com,rnp.br"
}

variable "interval" {
  type    = number
  default = 30
}

variable "grafana_admin_password" {
  type    = string
  default = "admin"
}

variable "grafana_port" {
  type    = number
  default = 3000
}
