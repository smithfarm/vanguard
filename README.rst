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
``salt-master.service`` unit has to be restarted. (FIXME: reload?)

Typically, the first time you apply a state after restarting the Salt Master
service, nothing will happen and the command will time out. It is unclear
whether this is a bug in Salt or the default timeout is too short. Just repeat
the command when this happens - Salt is designed to be idempotent.


Minion setup - introduction
---------------------------

Salt is a remote execution tool. Its purpose is to automate system
administration tasks in a way that they can be run in parallel (and
idempotently) across a group of minion machines.

A single master machine/daemon can be configured to control a single group of
machines, or multiple groups.

The minion machines in each group (e.g. Ceph cluster) should have similar
hardware configurations. For example, on the vanguard cluster, each machine has
four disks, ``/dev/sd[abcd]``. The first disk, ``/dev/sda`` is a spinner with
two partitions (swap and root). The second disk, ``/dev/sdb`` is an SSD for
Ceph journals. The third and fourth disks are OSD spinners. The master
configuration for vanguard assumes that the minions will be configured in this
way.

Another assumption we make is that we are starting from a "clean slate" - i.e.,
that the minions will have fresh, vanilla OS installations on their root
filesystem, and that they all have the same root password. 

Minion setup - bootstrapping
----------------------------

Before minion machines can be controlled, the minion daemon must be running
on them and the minion keys must be accepted by the master daemon.

This requirement introduces a "chicken and egg" problem because the minion
machines start with a clean, vanilla OS installation and this, by definition,
does not include any Salt packages.

To bootstrap the minion daemons, a number of clearly defined steps must be
taken on each machine. 

1. add Salt repo
2. zypper ref
3. zypper install salt-minion


These steps are always the same, and since each machine
will have the same root password, they can be automated and run in parallel.

The tool of choice for this task is ``pssh`` (short of "Parallel SSH), which is
distributed in the ``python-pssh`` package.

1.  ``zypper in python-pssh``
2.  copy/paste the ``minion-bootstrap.sh`` script from this git repo to the
Salt Master (machine)
3.  ``minion-bootstrap.sh $MINION1 $MINION2 $MINION3`` where ``$MINION1`` etc.
is a list of FQDNs (or IP addresses) of the minions

The ``minion-bootstrap.sh`` script automates the following steps by running
them in parallel on all the minions via ``pssh``:

1.  add the correct repo
2.  run ``zypper ref``
3.  install the ``salt-minion`` package
4.  configure the minions to treat the current host (using ``hostname --fqdn``) as the Salt Master
5.  enable the ``salt-minion.service`` systemd unit
6.  start the ``salt-minion.service`` systemd unit

The script also takes care of deleting and accepting the minion keys.

Apply states
------------

The "highstate", i.e. the state defined in ``top.sls``, is applied on the
minions using the command::

    salt '*' state.apply

Any other state defined in the same directory as ``top.sls`` can be applied by
writing its name after ``state.apply``. For example, to apply the state
``foo.sls``, say::

    salt '*' state.apply foo

