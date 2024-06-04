resource "yandex_compute_instance" "vm" {
    count = 2

     # create four similar EC2 instances
    name = "vm${count.index}"
    zone = var.zone 
    
    resources {
    cores = 2
    memory = 2
    core_fraction = 20 //использование процессора 20% (делимся ресурсами) - для экономии
    }
    boot_disk {
    initialize_params {
    image_id = "fd8aadpj5i9mrmu5bit1" //id образа (из стандартных настроек (см. скриншот))
    //name = "Ubuntu-yandexcloud-netology"
    size = 10
    }
    }
    network_interface {
    subnet_id = yandex_vpc_subnet.subnet1.id
    nat       = true
    }

    metadata = {
    user-data = "#cloud-config\nusers:\n  - name: root\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHLanzNhJDiwRU+sn88wSOxulsvVIPqx9c0h2IUaxs1g2G2ocTmE7oiJhCs/8cQGcPlGPGH5j8O6YbYT2vi0xxzP5fr//jane09gNfLymUyd/JxaNknA3lQgtNiriY/7NZl6lzI0ZLWXZb4Rfs1b3hqgkAaH2c6xQrS1IsIBjnLsj9DyCwnbxPUKMFu95DicBDt9pvg6FnjJN4hGRNwp17x3VcYY0Kgq9iN0IQ6W8s9leCf68QWy8yxX5wFfGbtQIxjXfcpeVLpXOLg9TKvEa9AuIiHSP2ui2ZzDVhGJEfTP+bpj6Hq43UVlUlq11oy63JWwTet+OlOPFDBY8gDok1kmIQ8DDR6LS4zWpRH6PvVuZXKPmi0nuFP685jj4K3MQ+k6gkuNv9ccjl284N6cL7lhnG2prmaiSaFnxJS49ZGl0D15MDkEs/rzOPTJBr9bpZ+LKZ5iHoSmn9tf79jImB7D1H+60u4uFNZ5bfho6W6VGbjBeax9FBLvpyTocWEgM= gekasologub@pop-os"
    }

    //прерывания для экономии ресурсов
    scheduling_policy {
        preemptible = true
    }
    
}



resource "yandex_iam_service_account" "sa" {
  name        = "gekasologub"
  description = "сервисный_аккаунт"
}
resource "yandex_organizationmanager_os_login_settings" "my_os_login_settings" {
  organization_id = "bpfpdag5mt7qc7keeb58"
  ssh_certificate_settings {
    enabled = true
  }
  user_ssh_key_settings {
    enabled               = true
    allow_manage_own_keys = true
  }
}


resource "yandex_vpc_network" "network1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet1" {
  name           = "subnet1"
  zone           = var.zone
  network_id     =  yandex_vpc_network.network1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}


// yandex_lb_target_group

resource "yandex_lb_target_group" "traget_foo" {
  name      = "my-target-group"
  region_id = "ru-central1"

  target {
    subnet_id = yandex_vpc_subnet.subnet1.id
    address   = yandex_compute_instance.vm[0].network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet1.id
    address   = yandex_compute_instance.vm[1].network_interface.0.ip_address
  }
}

//yandex network balancer

resource "yandex_lb_network_load_balancer" "balancer_foo" {
  name = "my-network-load-balancer"
  deletion_protection = "false"

  listener {
    name = "my-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.traget_foo.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/ping"
      }
    }
  }
}
