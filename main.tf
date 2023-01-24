terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("/Users/tayo/Downloads/neat-resolver-375409-5fd9d9efce1c.json")

  project = "neat-resolver-375409"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_instance" "vm_instance" {
  name         = "vminstance"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  tags         = ["allow-ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    #network = google_compute_network.vpc_network.name
    network = "default"

    access_config {
    }
  }

  metadata = {
    startup-script = <<EOF
#!/bin/bash

sudo apt-get update
sudo apt-get install python3-pip -y

pip3 install --upgrade pip
pip3 install --upgrade flask
pip3 install -r requirements.txt

python3 app.py
EOF
  }
}



resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = "default"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "flask" {
  name    = "flask-app-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
  source_ranges = ["0.0.0.0/0"]
}

// A variable for extracting the external IP address of the VM
output "Web-server-URL" {
 value = join("",["http://",google_compute_instance.default.network_interface.0.access_config.0.nat_ip,":5000"])
}