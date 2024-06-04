terraform {
required_providers {
yandex = {
source = "yandex-cloud/yandex"
}
}
}
provider "yandex" {
token = var.yandex_cloud_token
cloud_id = "b1g7gf91qfu0eksuhopl"
folder_id = "b1g4f73qtp3tnt39eta9"
zone = "ru-central1-a"
}

