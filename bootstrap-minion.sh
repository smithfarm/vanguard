#!/bin/bash
#
# bootstrap-minion.sh
#
# (script should produce no output)

set -e

cat << EOM > /etc/zypp/repos.d/NON_Public-infrastructure.repo
[FATE]
name=SUSE Feature Tracking (openSUSE_13.2)
enabled=1
autorefresh=0
baseurl=http://download.opensuse.org/repositories/FATE/openSUSE_13.2/
type=rpm-md
gpgcheck=1
gpgkey=http://download.opensuse.org/repositories/FATE/openSUSE_13.2//repodata/repomd.xml.key
EOM

zypper --no-gpg-checks refresh

zypper install salt-minion

hn=$(hostname --fqdn)
sed -i -e \'s/^# master:.*$/master: $fn/\'

systemctl enable salt-minion.service
systemctl start salt-minion.service

exit 0
