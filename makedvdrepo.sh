#!/bin/bash -f
# Description: This script will add a DVD loaded into attached drive as a yum repository
# Author: A.J.Amabile
# Date: 9th April 2021
# Original idea from https://access.redhat.com/soltions/1355683

OSver="rhel7"
DVDMount="/media/${OSver}"
repoName="${OSver}dvd"
repofile="${repoName}.repo"
#
# test if already run
#
[[ -d "${DVDMount}" ]]  ||  sudo mkdir -p "${DVDMount}" 
$(mount | grep -E "^/dev/sr0 on ${DVDMount}" -q) || \
   sudo mount -o ro /dev/sr0 "${DVDMount}" || exit "Cant mount DVD"

[[ -f /etc/yum.repos.d/${repofile} ]] && exit 0
sed -e 's/gpgcheck=0/gpgcheck=1/' "${DVDMount}/media.repo" > ~/${repofile}
#
# function to add line to file is not already in the file
#
testnset () {
  key=$1
  val=$2
  grep "${key}=${val}" ~/${repofile} || echo "${key}=${val}" >> ~/${repofile}
  return $?
}

testnset "enabled" "1"
testnset "baseurl" "file://${DVDMount}"
testnset "gpgkey" "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release"

sudo cp ~/${repofile} /etc/yum.repos.d/.
sudo chmod 644 /etc/yum.repos.d/${repofile}

sudo yum clean all
sudo yum repolist enabled
