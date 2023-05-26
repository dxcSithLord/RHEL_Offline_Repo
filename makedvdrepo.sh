#!/bin/bash -f
# Description: This script will add a DVD loaded into attached drive as a yum repository
# Author: A.J.Amabile
# Date: 9th April 2021
# Original idea from https://access.redhat.com/soltions/1355683
# Updated for RHEL8 25th May 2023

OSver="rhel8"
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
# added change to InstallMedia name
sed -e 's/gpgcheck=0/gpgcheck=1/' \
    -e 's/InstallMedia/InstallMedia_BaseOS/' "${DVDMount}/media.repo" > ~/${repofile}
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

# Add blank line and duplicate the file, with a change from BaseOS to AppStream
# This allows both BaseOS and AppStream repositories on base DVD to be available
# when mounted
echo "" >> ~/${repofile}
sed -e 's/BaseOS/AppStream/' ~/${repofile} >> ~/${repofile}

sudo cp ~/${repofile} /etc/yum.repos.d/.
sudo chmod 644 /etc/yum.repos.d/${repofile}

sudo yum clean all
sudo yum repolist enabled
