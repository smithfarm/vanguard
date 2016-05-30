Salt states for vanguard cluster
================================

Salt Master setup
-----------------

1.  add the right Salt repo(s) - the ones that contain python-pygit2
2.  ``zypper in python-pygit2 salt-master``
3.  edit /etc/salt/master::

        fileserver_backend:
          - git

        gitfs_provider: pygit2
 
        gitfs_remotes:
          - git://github.com/smithfarm/vanguard.git

4.  ``systemctl enable salt-master.service``
5.  ``systemctl start salt-master.service``
