/etc/zypp/zypp.conf:
  file.managed:
    - source: salt://zypp/zypp.conf
    - user: root
    - group: root
    - mode: 644

/etc/zypp/repos.d/SLE-12-WS-POOL.repo:
  file.managed:
    - source: salt://zypp/repos.d/SLE-12-WS-POOL.repo
    - user: root
    - group: root
    - mode: 644

/etc/zypp/repos.d/SLE-12-WS-UPDATES.repo:
  file.managed:
    - source: salt://zypp/repos.d/SLE-12-WS-UPDATES.repo
    - user: root
    - group: root
    - mode: 644

/etc/zypp/repos.d/SLE-Module-ASM-POOL.repo:
  file.managed:
    - source: salt://zypp/repos.d/SLE-Module-ASM-POOL.repo
    - user: root
    - group: root
    - mode: 644

/etc/zypp/repos.d/SLE-Module-ASM-UPDATES.repo:
  file.managed:
    - source: salt://zypp/repos.d/SLE-Module-ASM-UPDATES.repo
    - user: root
    - group: root
    - mode: 644

/etc/zypp/repos.d/SLE-SDK-POOL.repo:
  file.managed:
    - source: salt://zypp/repos.d/SLE-SDK-POOL.repo
    - user: root
    - group: root
    - mode: 644

/etc/zypp/repos.d/SLE-SDK-UPDATES.repo:
  file.managed:
    - source: salt://zypp/repos.d/SLE-SDK-UPDATES.repo
    - user: root
    - group: root
    - mode: 644

/etc/zypp/repos.d/SLE-SERVER-POOL.repo:
  file.managed:
    - source: salt://zypp/repos.d/SLE-SERVER-POOL.repo
    - user: root
    - group: root
    - mode: 644

/etc/zypp/repos.d/SLE-SERVER-UPDATES.repo:
  file.managed:
    - source: salt://zypp/repos.d/SLE-SERVER-UPDATES.repo
    - user: root
    - group: root
    - mode: 644

/etc/zypp/repos.d/SUSE:CA.repo:
  file.managed:
    - source: salt://zypp/repos.d/SUSE:CA.repo
    - user: root
    - group: root
    - mode: 644

/etc/zypp/repos.d/NON_Public_infrastructure.repo:
  file.managed:
    - source: salt://zypp/repos.d/NON_Public_infrastructure.repo
    - user: root
    - group: root
    - mode: 644

/etc/zypp/repos.d/Virtualization_containers.repo:
  file.managed:
    - source: salt://zypp/repos.d/Virtualization_containers.repo
    - user: root
    - group: root
    - mode: 644

no_systemsmanagement_saltstack_repo:
  file.absent:
    - name: /etc/zypp/repos.d/systemsmanagement_saltstack.repo

zypper_refresh:
  cmd.run:
    - name: zypper --gpg-auto-import-keys ref
    - user: root

basepackages:
  pkg.installed:
    - pkg:
      - ca-certificates-suse
      - git
      - vim

