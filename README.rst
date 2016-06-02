Salt states for vanguard cluster
================================

Salt has a client-server architecture, where a number of "minions" are
controlled by a single "master". When discussing Salt, it is not always clear
whether the terms "master" and "minion" refer to the Salt daemons, or to the
machines where said daemons are running.

Master setup
------------

The master machine should be in the same network with all the minion machines.

When daemons start, they typically load configuration from files in the
filesystem. While Salt can do this (``/etc/salt``), too, much more interesting
is its capability to load configuration from a git repo. Here's how to set that
up.

1.  add the right Salt repo(s) - the ones that contain python-pygit2
2.  ``zypper in python-pygit2 salt-master``
3.  edit ``/etc/salt/master`` and change the following values::

        fileserver_backend:
          - git

        gitfs_provider: pygit2
 
        gitfs_remotes:
          - git://github.com/smithfarm/vanguard.git

4.  ``systemctl enable salt-master.service``
5.  ``systemctl start salt-master.service``

Since all the master daemon configuration is in this git repository, no further
configuration is needed. 


Making changes to the Master configuration
------------------------------------------

The master daemon configuration files housed in this repository can be changed
by pushing commits to it (or to a fork).

When modifications are made, they do not take effect until the
``salt-master.service`` unit is restarted. (FIXME: reloaded?)

Typically, the first time you apply a state after restarting the Salt Master
service, nothing will happen and the command will time out. It is unclear
whether this is a bug in Salt or the default timeout is too short. When this
happens, just issue the same command again - Salt is designed to be idempotent.


Minion setup
------------

Salt is a remote execution tool. Its purpose is to automate system
administration tasks in a way that they can be run in parallel (and
idempotently) across a group of minion machines.

A single master machine/daemon can be configured to control multiple groups of
machines, or just one group.


Assumptions
~~~~~~~~~~~

The minion machines in each group (e.g. Ceph cluster) should have similar
hardware configurations. For example, on the vanguard cluster, each machine has
four disks, ``/dev/sd[abcd]``. The first disk, ``/dev/sda`` is a spinner with
two partitions (swap and root). The second disk, ``/dev/sdb`` is an SSD for
Ceph journals. The third and fourth disks are OSD spinners. The master
configuration for vanguard assumes that the minions will be configured in this
way.

Another assumption we make is that we are starting from a "clean slate" - i.e.,
that the minions will have fresh, vanilla OS installations on their root
filesystem, and that they all have the same root password. If the minions are
physical machines, one way to automate their reimaging is via PXE and autoyast2
profiles. If the minions are in a public/private cloud (OpenStack, AWS), some
other tooling is needed to create the VMs there.


Bootstrapping
~~~~~~~~~~~~~

Before minion machines can be controlled, the minion daemon must be installed,
configured, and started. Also, the minion keys must be accepted by the master
daemon.

This requirement introduces a "chicken and egg" problem because we are assuming
the minion machines start with a clean, vanilla OS installation -- this, by
definition, does not include any Salt packages.

To bootstrap the minion daemons, a number of clearly defined steps must be
taken on each machine. 

1. add Salt repo
2. zypper ref
3. zypper install salt-minion
4. edit /etc/salt/minion and change ``master`` value to point to the 
   FQDN of the master machine
5. systemctl enable salt-minion.service
6. systemctl start salt-minion.service

Also, if the master accepted keys from the same machines before, these keys
must be deleted first, before running these steps.

After these steps have been completed on all the minions, then the (new) minion
keys need to be accepted on the master. Then the cluster is ready to accept
Salt.


Minion bootstrap script
~~~~~~~~~~~~~~~~~~~~~~~

Now, the minion bootstrapping steps are always the same, so they can be
automated by a trivial script. Even better, since each minion machine has the
same root password, the script can be run in parallel on all the minions.

The ``bootstrap.sh`` script included here implements the steps described in the
previous section. It is designed to be run from a clone of this git repo on the
master machine. Here's how it works.

The script takes a list of minion FQDNs.

After deleting all the minion keys, it copies the ``minion-bootstrap.sh``
script to all the minions using ``pscp`` (which on openSUSE is distributed in
the ``pssh`` package). Then it runs the script in parallel on all the minions.
Finally, it waits for the minions to register their new keys with the master
daemon and then it accepts the minion keys.


Apply states
------------

The "highstate", i.e. the state defined in ``top.sls``, is applied on the
minions using the command::

    salt '*' state.apply

Any other state defined in the same directory as ``top.sls`` can be applied by
writing its name after ``state.apply``. For example, to apply the state
``foo.sls``, say::

    salt '*' state.apply foo

