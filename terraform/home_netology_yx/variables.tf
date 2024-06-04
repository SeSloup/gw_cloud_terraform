variable "yandex_cloud_token" {
  type = string
  description = "Данная переменная потребует ввести секретный токен в консоли при запуске terraform plan/apply"
}

variable "zone" {
  default = "ru-central1-b"
  type = string
  description = "Zone"
}

