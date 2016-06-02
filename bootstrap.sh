#!/bin/bash
#
# Install pssh and salt-master packages before running.
#

echo "Deleting all minion keys"
sudo salt-key -Dy || exit $?

echo "Initializing temporary file"
tmpfile=$(mktemp /tmp/vanguard-bootstrap.XXXXXX)
touch $tmpfile

echo "Writing minion FQDNs to $tmpfile"
for x ; do
    echo $x >> $tmpfile
done

echo "Copying minion-bootstrap.sh to minions"
pscp -v -h $tmpfile -A -l root -O StrictHostKeyChecking=no bootstrap-minion.sh bootstrap-minion.sh

echo "Removing $tmpfile"
rm $tmpfile

