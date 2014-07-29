install
text
# System keyboard
keyboard uk
# System language
lang en_GB.UTF-8
# System timezone
timezone --isUtc Etc/UTC
# Firewall configuration
firewall --disabled
# SELinux configuration
selinux --enforcing
# Shut off First Boot
firstboot --disabled
# System authorization information
authconfig --enableshadow --passalgo=sha512 
# Select Repos
repo --name="repo0" --mirrorlist="http://mirrorlist.centos.org/?release=6&arch=x86_64&country=gb&repo=os"
repo --name="repo1" --mirrorlist="http://mirrorlist.centos.org/?release=6&arch=x86_64&country=gb&repo=updates"
#repo --name="repo0" --baseurl=http://mirrors.kernel.org/centos/6/os/x86_64
#repo --name="repo1" --baseurl=http://mirrors.kernel.org/centos/6/updates/x86_64
repo --name="repo2" --mirrorlist="http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=x86_64&country=gb"
# Install root password - removed and locked in post.
rootpw --iscrypted **LOCKED**
# Installation logging level
logging --level=info
# Shutdown for snapshot after installation.
poweroff
# System services
services --disabled="avahi-daemon,iscsi,iscsid,firstboot,kdump"
# Network information
network  --bootproto=dhcp --device=eth0 --onboot=on --hostname='localhost'
# System bootloader configuration
# Disengage the framebuffer from the console.
bootloader --location=mbr --driveorder="vda" --timeout=1 --append="fbcon=map:1 quiet"
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all  --initlabel
# Disk partitioning information
part / --fstype="ext4" --size=500 --grow --maxsize=2000 --asprimary

%post

# bz705572
ln -s /boot/grub/grub.conf /etc/grub.conf

#Switch off ZEROCONF. 
cat <<EOF > /etc/sysconfig/network
NETWORKING=yes
NOZEROCONF=yes
EOF

#Bug 1011013 - add PERSISTENT_DHCLIENT=1 to ifcfg-eth0
cat <<EOF >/etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
PERSISTENT_DHCLIENT=1
EOF

#setup Fedora style cloud-init config
#Required until cloud-init packaging is updated
cat <<EOL > /etc/cloud/cloud.cfg
users:
 - default

disable_root: 1
ssh_pwauth:   0

locale_configfile: /etc/sysconfig/i18n
mount_default_fields: [~, ~, 'auto', 'defaults,nofail', '0', '2']
resize_rootfs_tmp: /dev
ssh_deletekeys:   0
ssh_genkeytypes:  ~
syslog_fix_perms: ~

cloud_init_modules:
 - migrator
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - rsyslog
 - users-groups
 - ssh

cloud_config_modules:
 - mounts
 - locale
 - set-passwords
 - yum-add-repo
 - package-update-upgrade-install
 - timezone
 - puppet
 - chef
 - salt-minion
 - mcollective
 - disable-ec2-metadata
 - runcmd

cloud_final_modules:
 - rightscale_userdata
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - phone-home
 - final-message

system_info:
  default_user:
    name: centos
    lock_passwd: true
    gecos: CentOS Cloud User
    groups: [wheel, adm]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
  distro: rhel
  paths:
    cloud_dir: /var/lib/cloud
    templates_dir: /etc/cloud/templates
  ssh_svcname: sshd

# vim:syntax=yaml
EOL

# lock root password
passwd -d root
passwd -l root

#Reset hostname
hostnamectl set-hostname ""
rm -rf /etc/hostname

# this is installed by default but we don't need it in virt
echo "Removing linux-firmware package."
yum -q -C -y remove linux-firmware

# Remove firewalld; was supposed to be optional in F18+, but is required to
# be present for install/image building.
echo "Removing firewalld."
yum -q -C -y remove firewalld --setopt="clean_requirements_on_remove=1"

# Another one needed at install time but not after that, and it pulls
# in some unneeded deps (like, newt and slang)
echo "Removing authconfig."
yum -q -C -y remove authconfig --setopt="clean_requirements_on_remove=1"

# clean up installation logs
yum history new
yum clean all
truncate -c -s 0 /var/log/yum.log
rm -rf /var/lib/yum/*
rm -rf /var/lib/random-seed
rm -rf /root/install.log
rm -rf /root/install.log.syslog
rm -rf /root/anaconda-ks.cfg
rm -rf /var/log/anaconda*

echo "Zeroing out empty space."
# This forces the filesystem to reclaim space from deleted files
dd bs=1M if=/dev/zero of=/var/tmp/zeros || :
rm -f /var/tmp/zeros
echo "(Don't worry -- that out-of-space error was expected.)"
%end

%packages --excludedocs --nobase
@Core
yum-utils
wget
acpid
attr
audit
authconfig
cloud-init
cloud-utils-growpart
device-mapper
dracut
dracut-modules-growroot
#heat-cfntools
kpartx
man
net-tools
nfs-utils
openssh-clients
parted
rsync
#sendmail
#syslinux
tar
tuned
yum-metadata-parser
-alsa-lib
-avahi
-avahi-autoipd
-avahi-libs
-NetworkManager*
-b43-openfwwf
-biosdevname
-dracut-config-rescue
-firewalld
-fprintd
-fprintd-pam
-gtk2
-libfprint
-mcelog
-nfs-utils
-plymouth
-plymouth-*
-postfix
-procmail
-redhat-support-tool
-system-config-*
-wireless-tools
-*-firmware
-iprutils

%end
