#!/bin/bash
#
# bootstrap-minion.sh
#
# (script should produce no output)

master_fqdn=$1

systemctl stop salt-minion.service
systemctl disable salt-minion.service
zypper -n remove salt
rm /etc/salt/minion 2>/dev/null

rm -rf /etc/zypp/repos.d/*

set -e

cat << EOM > /etc/zypp/repos.d/NON_Public_infrastructure.repo
[NON_Public_infrastructure]
name=Additional packages for our infrastructure servers (SUSE_SLE_12_SP1_GA)
enabled=1
autorefresh=0
baseurl=http://download.suse.de/ibs/NON_Public:/infrastructure/SUSE_SLE_12_SP1_GA/
type=rpm-md
gpgcheck=1
gpgkey=http://download.suse.de/ibs/NON_Public:/infrastructure/SUSE_SLE_12_SP1_GA//repodata/repomd.xml.key
EOM

zypper --no-gpg-checks refresh

zypper --non-interactive install salt-minion

echo "Setting master to $master_fqdn in /etc/salt/minion"
sed -i -e "s/^#master:.*$/master:\ $master_fqdn/" /etc/salt/minion

systemctl enable salt-minion.service
systemctl start salt-minion.service

exit 0
