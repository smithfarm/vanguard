#!/bin/bash
#
# Install pssh and salt-master packages before running.
#

echo "Deleting all minion keys"
sudo salt-key -Dy

echo "Initializing temporary file"
tmpfile=$(mktemp /tmp/vanguard-bootstrap.XXXXXX)
touch $tmpfile

echo "Writing minion FQDNs to $tmpfile"
for x ; do
    echo $x >> $tmpfile
done

echo "Copying bootstrap-minion.sh to minions"
pscp -v -h $tmpfile -A -l root -O StrictHostKeyChecking=no bootstrap-minion.sh bootstrap-minion.sh

echo "Running bootstrap-minion.sh on minions"
hn=$(hostname --fqdn)
pssh -v -h $tmpfile -A -i -l root -O StrictHostKeyChecking=no -t 0 sh bootstrap-minion.sh $hn

echo "Removing $tmpfile"
rm $tmpfile

