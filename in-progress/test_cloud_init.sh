#cloud-config
users:
-name: akbar
ssh-authorized-keys:

sudo: ['ALL=(ALL) NOPASSWD:ALL']
groups: sudo
shell: /bin/bash
runcmd:
- sed -i -e '/^Port/s/^.*$/Port 22/' /etc/ssh/sshd_config
- sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
- sed -i -e '$aAllowUsers demo' /etc/ssh/sshd_config
- restart ssh
chpasswd:
list: |
root: P@ssword1
expire: False