#! /usr/bin/bash
#
# Utility functions that are useful in all provisioning scripts.

#----------------------------------------------------------------------------
# Variables
#----------------------------------------------------------------------------

bats_archive="v0.4.0.tar.gz"
bats_url="https://github.com/sstephenson/bats/archive/${bats_archive}"
bats_install_dir="/opt"
bats_executable="${bats_install_dir}/bats/libexec/bats"

#----------------------------------------------------------------------------
# Logging and debug output
#----------------------------------------------------------------------------

# Color definitions
readonly reset='\e[0m'
readonly cyan='\e[0;36m'
readonly red='\e[0;31m'
readonly yellow='\e[0;33m'

# Usage: info [ARG]...
#
# Prints all arguments on the standard output stream
info() {
  printf "${yellow}>>> %s${reset}\n" "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard output stream
debug() {
  printf "${cyan}### %s${reset}\n" "${*}"
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf "${red}!!! %s${reset}\n" "${*}" 1>&2
}

#----------------------------------------------------------------------------
# Useful tests
#----------------------------------------------------------------------------

# Usage: files_differ FILE1 FILE2
#
# Tests whether the two specified files have different content
#
# Returns with exit status 0 if the files are identical, a nonzero exit status
# if they differ
files_differ() {
  local file1="${1}"
  local file2="${2}"

  # If the second file doesn't exist, it's considered to be different
  if [ ! -f "${file2}" ]; then
    return 0
  fi

  local -r checksum1=$(md5sum "${file1}" | cut -c 1-32)
  local -r checksum2=$(md5sum "${file2}" | cut -c 1-32)

  [ "${checksum1}" != "${checksum2}" ]
}

copy_if_different() {
  local source_file="${1}"
  local destination_file="${2}"

  if files_differ "${source_file}" "${destination_file}"; then
    info "Copying ${source_file} -> ${destination_file}"
    cp "${source_file}" "${destination_file}"
  fi
}

#----------------------------------------------------------------------------
# BATS
#----------------------------------------------------------------------------

ensure_bats_installed() {
  pushd "${bats_install_dir}" > /dev/null
  if [[ ! -d "${bats_install_dir}/bats" ]]; then
    info "Installing BATS"
    wget "${bats_url}"
    tar xf "${bats_archive}"
    mv bats-* bats
    rm "${bats_archive}"
    ln -s "${bats_executable}" /usr/local/bin/bats
  fi
  popd > /dev/null
}

#----------------------------------------------------------------------------
# SELinux
#----------------------------------------------------------------------------

# Usage: ensure_sebool VARIABLE
#
# Ensures that an SELinux boolean variable is turned on
ensure_sebool()  {
  local -r sebool_variable="${1}"
  local -r current_status=$(getsebool "${sebool_variable}")

  if [ "${current_status}" != "${sebool_variable} --> on" ]; then
    setsebool -P "${sebool_variable}" on
  fi
}

#----------------------------------------------------------------------------
# User management
#----------------------------------------------------------------------------

# Usage: ensure_user_exists USERNAME
#
# Create the user with the specified name if it doesn’t exist
ensure_user_exists() {
  local user="${1}"

  info "Ensure user ${user} exists"
  if ! is_user_present "${user}"; then
    info " -> user added"
    useradd "${user}"
  else
    info " -> already exists"
  fi
}

# Usage: ensure_group_exists GROUPNAME
#
# Creates the group with the specified name, if it doesn’t exist
ensure_group_exists() {
  local group="${1}"

  info "Ensure group ${group} exists"
  if ! is_group_present "${group}"; then
    info " -> group added"
    groupadd "${group}"
  else
    info " -> already exists"
  fi
}


# Usage: assign_groups USER GROUP...
#
# Adds the specified user to the specified groups
assign_groups() {
  local user="${1}"
  shift
  info "Adding user ${user} to groups: ${*}"
  while [ "$#" -ne "0" ]; do
    usermod -aG "${1}" "${user}"
    shift
  done
}

# Usage: is_user_present USERNAME
#
# Predicate that checks whether the specified user exists on the system
is_user_present() {
  local user_name="${1}"
  getent passwd "${user_name}" > /dev/null 2>&1
}

# Usage: is_group_present GROUPNAME
#
# Predicate that checks whether the specified group exists on the system
is_group_present() {
  local group_name="${1}"
  getent group "${group_name}" > /dev/null 2>&1
}

#---------------------------------------------------------------------------
# Service management
#---------------------------------------------------------------------------

# Usage: ensure_service_started SERVICE
#
# Attempts to start the specified service if it is not running currently
ensure_service_started() {
  local service="${1}"

  if ! is_service_active "${service}"; then
    info "Starting service ${service}"
    systemctl start "${service}"
  fi
}

# Usage is_service_active SERVICE
#
# Predicate that checks whether the specified service is running
is_service_active() {
  systemctl is-active "${service}" > /dev/null 2>&1
}
