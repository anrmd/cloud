resource "google_compute_network" "vpc" {
  name = "vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "subnetwork"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west1"
  network    = google_compute_network.vpc.id

}


resource "google_compute_instance" "vm" {
  count         = 2
  name = "vm-${count.index}"
  zone = "europe-west1-b"
  machine_type     = "n2d-standard-2"


  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }


  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {
      // Ephemeral public IP
    }
  }
}



resource "google_sql_database_instance" "main" {
  name             = "bdd"
  database_version = "POSTGRES_15"
  region           = "europe-west1"

  settings {

    tier = "db-f1-micro"
  }
}





resource "google_dns_record_set" "frontend" {
  name = "vm.${google_dns_managed_zone.prod.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.prod.name

  rrdatas = google_compute_instance.vm[*].network_interface[0].access_config[0].nat_ip
}



resource "google_dns_managed_zone" "prod" {
  name     = "prod-zone"
  dns_name = "prod.mydomain.com."
}
