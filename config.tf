terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}


# provider properties
provider "yandex" {
  #my autorization tocken
  token = "MY_YANDEX_TOKEN"

  #my yandex cloud identifier
  cloud_id  = "b1gogrmv0lhpqnt6hqu1"

  #my yandex folder identifier (default)
  folder_id = "b1g5ks1opqq9pgacsaoo"

  # YANDEX ZONE: ru-central1-a, ru-central1-b, ru-central1-d
  zone = "ru-central1-a"
}




#############################################################
### VM "assembly"
#############################################################
# vm "assembly" resource configurations
resource "yandex_compute_instance" "vm-assembly" {
  name = "assembly"
  allow_stopping_for_update = true
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.assembly_ubuntu2004_15GB.id
  }
  network_interface {
    subnet_id = "e9buvssk2htbkq921avo"
    nat       = true
  }
  metadata = {
    user-data = "${file("./public_keys.yml")}"
  }
  scheduling_policy {
    preemptible = true 
  }


  # init vm-assembly -------------------------
  connection {
    type     = "ssh"
    user     = "spring"
    #private_key = file("/root/.ssh/id_rsa") >>> copy to
    private_key = file("/var/lib/jenkins/id_rsa")
    host = yandex_compute_instance.vm-assembly.network_interface.0.nat_ip_address
  }

  #provisioner "file" {
  #  source      = "./Dockerfile"
  #  destination = "/tmp/Dockerfile"
  #}

  # first init for Ansible -------------------------
  provisioner "remote-exec" {
    inline = [
      "sudo apt update", 
      "sudo apt install python -y",
    ]
  }

}




#############################################################
### VM "prod"
#############################################################
# vm "prod" resource configurations
resource "yandex_compute_instance" "vm-prod" {
  name = "prod"
  allow_stopping_for_update = true
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.prod_ubuntu2004_15GB.id
  }
  network_interface {
    subnet_id = "e9buvssk2htbkq921avo"
    nat       = true
  }
  metadata = {
    user-data = "${file("./public_keys.yml")}"
  }
  scheduling_policy {
    preemptible = true 
  }


  # init vm-prod -------------------------
  connection {
    type     = "ssh"
    user     = "spring"
    #private_key = file("/root/.ssh/id_rsa") >>> copy to
    private_key = file("/var/lib/jenkins/id_rsa")
    host = yandex_compute_instance.vm-prod.network_interface.0.nat_ip_address
  }
  # first init for Ansible -------------------------
  provisioner "remote-exec" {
    inline = [
      "sudo apt update", 
      "sudo apt install python -y",
    ]
  }

  # ALLOW to make together
  # run after vm-assembly -------------------------
  #depends_on = [
  #  yandex_compute_instance.vm-assembly
  #]

}





output "external_ip_address_vm_assembly" {
  value = yandex_compute_instance.vm-assembly.network_interface.0.nat_ip_address
}
output "external_ip_address_vm_prod" {
  value = yandex_compute_instance.vm-prod.network_interface.0.nat_ip_address
}









#############################################################
### VM DISKS DECLARATION
#############################################################
# boot disk template with ubuntu 20.04
data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2004-lts"
}

# boot disk for vm-assembly = ubuntu 20.04 with 15GB
resource "yandex_compute_disk" "assembly_ubuntu2004_15GB" {
  type     = "network-ssd"
  zone     = "ru-central1-a"
  image_id = data.yandex_compute_image.ubuntu_image.id
  size = 15
}
# boot disk for vm-prod = ubuntu 20.04 with 15GB
resource "yandex_compute_disk" "prod_ubuntu2004_15GB" {
  type     = "network-ssd"
  zone     = "ru-central1-a"
  image_id = data.yandex_compute_image.ubuntu_image.id
  size = 15
}




#############################################################
### Yandex Docker Registry: mydockerregistry
#############################################################
resource "yandex_container_registry" "my-reg" {
  name = "mydockerregistry"
  folder_id = "b1g5ks1opqq9pgacsaoo"
  labels = {
    my-label = "it-is-mysite1"
  }
}
resource "yandex_container_registry_iam_binding" "puller" {
  registry_id = yandex_container_registry.my-reg.id
  role        = "container-registry.images.puller"
  members = [
    "system:allUsers",
  ]
}
resource "yandex_container_registry_iam_binding" "pusher" {
  registry_id = yandex_container_registry.my-reg.id
  role        = "container-registry.images.pusher"
  members = [
    "system:allUsers",
  ]
}
