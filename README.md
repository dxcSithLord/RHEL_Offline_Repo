# RHEL_Offline_Repo
Scripts to download Red Hat packages into a custom repository for distribution to offline systems

Needs the RHEL media mounted and the repo.xml file from that for makedvdrepo to create a local repository for the (source) media, that can then be re-used for the custom media, based on RHEL repository subset(s).  This has been tested on RHEL 7 and RHEL 8.


It is assumed that you are running the script from a RHEL 7 machine and the following directory structure is created:
sudo mkdir -p /data/repo/
- ideally with enough disk space to hold the packages and ISO creation - at least 13GiB free space for a RHEL server/workstation.

If you want a FULL repo, you can use the command reposync that will synchronise a complete repository.  This command is to download the packages that are used by the current RHEL build.

Two files are created :
installed.list - a complete list of installed packages, and what is used to create the repo subset.
updates.list   - a list of updates identified by yum.

makedvdrepo.sh will attempt to mount the RHEL ISO (used to build the RHEL machine you are running from) onto /media/rhel8repo (The RHEL version number is appropriate for each instance.

To execute:
~~~
./makedvdrepo.sh
sudo sh ./sh-rhel-get-updates.sh 
~~~

You will be prompted if there are any updates that require additional dependencies - they will need to be applied before running again to download all required packages.
