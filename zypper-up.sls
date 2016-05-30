zypper_refresh:
  cmd.run:
    - name: zypper --gpg-auto-import-keys ref
    - user: root

zypper_update:
  cmd.run:
    - name: zypper -n up
    - user: root

