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


resource "google_compute_instance" "confidential_instance" {
  name             = "vm"
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





