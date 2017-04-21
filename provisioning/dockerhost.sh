#! /usr/bin/bash
#
# Provisioning script for srv010

#----------------------------------------------------------------------------
# Bash settings
#----------------------------------------------------------------------------

# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't mask errors in piped commands
set -o pipefail

#----------------------------------------------------------------------------
# Variables
#----------------------------------------------------------------------------

# Location of provisioning scripts and files
export readonly provisioning_scripts="/vagrant/provisioning/"
# Location of files to be copied to this server
export readonly provisioning_files="${provisioning_scripts}/files/${HOSTNAME}"

# The name of the user that is going to manage the Docker service
readonly docker_admin=vagrant

#----------------------------------------------------------------------------
# "Imports"
#----------------------------------------------------------------------------

# Utility functions
source ${provisioning_scripts}/util.sh

#----------------------------------------------------------------------------
# Provision server
#----------------------------------------------------------------------------

info "Starting provisioning tasks on ${HOSTNAME}"

# Workaround for an issue where the IP address Vagrant assigns to enp0s8 is
# actually not applied. This affects Vagrant 1.9.1.
#systemctl restart network

#---------- Docker ----------------------------------------------------------

info "Installing Docker, Cockpit and utilities"

dnf -y install \
  cockpit \
  cockpit-docker \
  docker \
  docker-compose \
  git \
  nano \
  patch

info "Allow ${docker_admin} to use Docker without sudo"

ensure_group_exists docker
assign_groups "${docker_admin}" docker

info "Enabling services"

systemctl enable docker.service
# The following 
#systemctl enable cockpit.service

info "Configuring firewall"

ensure_service_started firewalld.service
firewall-cmd --add-port=9090/tcp --permanent
firewall-cmd --reload

info "Starting services"

ensure_service_started docker.service
ensure_service_started cockpit.service

info "Installing aliases for managing Docker"

copy_if_different \
  "${provisioning_files}/docker-aliases.sh" \
  /etc/profile.d/docker-aliases.sh

