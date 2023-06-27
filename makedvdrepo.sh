#!/bin/bash -f
# Description: This script will add a DVD loaded into attached drive as a yum repository
# Author: A.J.Amabile
# Date: 9th April 2021
# Original idea from https://access.redhat.com/soltions/1355683
# Updated for RHEL8 25th May 2023
# Updated with comments and frendly user info

OSver="rhel8"
DVDMount="/media/${OSver}"
repoName="${OSver}dvd"
repofile="${repoName}.repo"
#
# test if already run
#
/bin/echo "Checking for media mount point at ${DVDMount}"
[[ -d "${DVDMount}" ]]  ||  sudo mkdir -p "${DVDMount}" 
/bin/echo "Mounting media (sudo required)"
$(mount | grep -E "^/dev/sr0 on ${DVDMount}" -q) || \
   sudo mount -o ro /dev/sr0 "${DVDMount}" || exit "Cant mount DVD"

/bin/echo "Media mounted on ${DVDMount}"

[[ -f /etc/yum.repos.d/${repofile} ]] \
  && /bin/echo "Repositories file already in place, exiting" \
  && exit 0
#
# DVD mounted and repofile does not yet exist, so create one from the DVD media.repo file
# which is formatted for RHEL7 on RHEL8 DVD, without reference to new BaseOS and AppStream 
# repositories.
#
/bin/echo "Creating new DVD repository file ${repofile}, with repositories:"
/bin/echo "InstallMedia_BaseOS and InstallMedia_AppStream"
# added change to InstallMedia name for RHEL8
/bin/sed -e 's/gpgcheck=0/gpgcheck=1/' \
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
/bin/echo "To use the DVD repositories, use :"
/bin/echo "dnf --enablerepo=InstallMedia_* ..."
/bin/echo "Re-run this command to re-mount media"
