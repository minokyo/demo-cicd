/*
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "network_name" {
  default = "rga-demo"
}

variable "project" {
  default = ""
}

provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  version     = "1.19.0"
}

resource "google_compute_network" "default" {
  name                    = "${var.network_name}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "default" {
  name                     = "${var.network_name}"
  ip_cidr_range            = "10.125.0.0/20"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = true
}

resource "google_compute_instance" "vm_instance" {
  name         = "jenkins"
  machine_type = "n1-standard-2"
  zone         = "${var.zone}"
  tags         = ["${var.network_name}-ssh","${var.network_name}-https","${var.network_name}-http"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1604-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    subnetwork    = "${google_compute_subnetwork.default.self_link}"
    access_config = {
    }
  }
}

resource "google_compute_firewall" "vm-ssh" {
  name    = "${var.network_name}-ssh"
  network = "${google_compute_subnetwork.default.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.network_name}-ssh"]
}

resource "google_compute_firewall" "vm-http" {
  name    = "${var.network_name}-http"
  network = "${google_compute_subnetwork.default.name}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.network_name}-http"]
}

resource "google_compute_firewall" "vm-https" {
  name    = "${var.network_name}-https"
  network = "${google_compute_network.default.name}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.network_name}-https"]
}

output "group_region" {
  value = "${var.region}"
}
