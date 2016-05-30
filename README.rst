Salt states for vanguard cluster
================================

Salt Master setup
-----------------

1.  add Salt repos
2.  zypper in python-pygit2
3.  zypper in salt-master
4.  edit /etc/salt/master

::

    fileserver_backend:
      - git

    gitfs_provider: pygit2
 
    gitfs_remotes:
      - git://github.com/smithfarm/vanguard.git

More text follows here.
