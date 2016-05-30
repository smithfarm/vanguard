Salt states for vanguard cluster
================================

Salt Master setup
-----------------

*  Here's what you do

   1.  add Salt repos
   1.  zypper in python-pygit2

1. zypper in salt-master

1. edit /etc/salt/master::

   fileserver_backend:
     - git

   gitfs_provider: pygit2

   gitfs_remotes:
     - git://github.com/smithfarm/vanguard.git
