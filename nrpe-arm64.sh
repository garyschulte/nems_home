#!/bin/bash

# Set the version (see git releases)
nrpeVer="3.2.1"

APT_LISTCHANGES_FRONTEND=cat
echo $0 > /var/www/html/userfiles/nems-build.cur
/bin/systemctl stop nrpe
# these plugins shouldn't even exist anymore since they were pulled from packages.add and 045-nagios
yes | apt remove --purge nagios-nrpe-plugin
yes | apt remove --purge nagios-nrpe-server
yes | apt autoremove
apt update

yes | apt install libssl-dev dpatch debhelper libwrap0-dev autotools-dev gawk

apt -y install --reinstall monitoring-plugins-common
apt -y install --reinstall monitoring-plugins-basic
apt -y install --reinstall monitoring-plugins-standard

tmpdir=`mktemp -d -p /tmp/`
file="https://github.com/NagiosEnterprises/nrpe/archive/nrpe-$nrpeVer.tar.gz"
cd $tmpdir
wget -O $tmpdir/nrpe.tar.gz $file
tar xvzf nrpe.tar.gz
cd nrpe-*
./configure --enable-command-args --with-ssl-lib=/usr/lib/aarch64-linux-gnu/
make all
make install-groups-users
make install-plugin
make install-daemon
make install-config
make install-init

/bin/systemctl stop nrpe

wget -O /usr/local/nagios/etc/nrpe.cfg https://raw.githubusercontent.com/Cat5TV/nems-migrator/master/data/1.5/nagios/misc/nrpe.cfg

# Install custom_check_mem
  yes | apt install bc
  yes | apt install dc
  wget -O /usr/lib/nagios/plugins/custom_check_mem https://raw.githubusercontent.com/Cat5TV/nems-migrator/master/data/1.5/nagios/plugins/custom_check_mem
  chmod +x /usr/lib/nagios/plugins/custom_check_mem

/bin/systemctl start nrpe
/bin/systemctl enable nrpe
/bin/systemctl status nrpe --no-pager

if ! grep -q "PATCH-000007" /var/log/nems/patches.log; then
  echo "PATCH-000007" >> /var/log/nems/patches.log
fi

# so error code on failure doesn't fail run-parts
echo "Done."