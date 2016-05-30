/etc/zypp/zypp.conf:
  file.managed:
    - source: salt://zypp/zypp.conf
    - user: root
    - group: root
    - mode: 644

