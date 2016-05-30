Salt states for vanguard cluster
================================

Salt Master setup
-----------------

# add Salt repos
# zypper in python-pygit2
# zypper in salt-master
# edit /etc/salt/master

    fileserver_backend:
      - git

    gitfs_provider: pygit2

    gitfs_remotes:
      - git://github.com/smithfarm/vanguard.git
