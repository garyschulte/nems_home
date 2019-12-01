#NEMS / Nagios Tips for home ARM64 monitoring

## todo:
* k8s/k3s monitoring
* try to get pi-hole on nems
* armbian monitor stats
* rpi temp stats


##pushover 
 * see pushover.creds

##pi-hole tricks to resolve for a local domain:
* /etc/dnsmasq.d 
** add a file like `02-local.conf` with contents:
	domain=home
	expand-hosts
	local=/home/

## backup nems config from rock64a SBC:
```echo -n "user: "; read user ; echo -n "pass "; read pass; curl -O $user:$pass@rock64a.home/backup/snapshot/backup.nems```

##install nems remote plugin (nrpe):

* do not use apt or repos, they are out of date, nems manual build script via curl instead:
`wget -O - https://raw.githubusercontent.com/Cat5TV/nems-admin/master/build/047-nrpe | bash`
** the above is broken in various ways for ARM64, but you can use it as a guide
** ./configure --enable-command-args --with-ssl-lib=/usr/lib/aarch64-linux-gnu/
** need to install gawk for custom_check_mem also
** these changes are made in `nrpe-arm64.sh`

** in `/usr/local/nagios/etc/nrpe.cfg` ensure nems server is in there:
allowed_hosts=127.0.0.1,192.168.0.240

** restart nems
`sudo systemctl restart nrpe`
  - OR -
`sudo /etc/init.d/nagios-nrpe-server restart`


## setup raspberry pi cpu temp monitoring:
* copy rpi-temp.sh to nagios plugins lib
** `cp rpit-temp.sh /usr/lib/nagios/plugins/custom_check_sbc_temp`
** `chmod 755 /usr/lib/nagios/plugins/custom_check_sbc_temp`
** `sudo usermod -a -G video nagios`
* add check_sbc_temp to `/usr/local/nagios/etc/nrpe.cfg`
** ```command[check_sbc_temp]=/usr/lib/nagios/plugins/custom_check_sbc_temp $ARG1$```
** chmod 755 /usr/lib/nagios/plugins/custom_check_sbc_temp
* `sudo systemctl restart nrpe`
