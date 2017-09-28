#!/bin/bash

hostname="fefe.com"
myusr="hogeeee"
pw="fafa"
#for ssh
myport="52454"
pubkey=$(cat hoge.pub)

#disable selinux
setenforce 0
##disable selinux constantly
#sed -i -e "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux
#sed -i -e "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

#hostname
hostnamectl set-hostname ${hostname} --static
#timezone
timedatectl set-timezone Asia/Tokyo
#set locale to japan
localectl set-locale LANG=ja_JP.UTF-8

#NO bluetooth
systemctl disable bluetooth.service

#for this script
yum -y install expect
yum -y install deltarpm
#change root password
expect -c "
set timeout 20
spawn passwd
expect -re \"新しい|New\"
send \"${pw}\n\"
expect -re \"再入力|Retype\"
send \"${pw}\n\"
interact
"
#make wheel user
useradd -m ${myusr}
expect -c "
set timeout 20
spawn passwd ${myusr}
expect -re \"新しい|New\"
send \"${pw}\n\"
expect -re \"再入力|Retype\"
send \"${pw}\n\"
interact
"
usermod -G wheel ${myusr}
sed -i 's/Defaults.*requiretty/#Default\trequiretty/g' /etc/sudoers
sed -i 's/^#\s%wheel\s*ALL=(ALL)\s*ALL$/%wheel\tALL=(ALL)\tALL/g' /etc/sudoers
sed -i 's/^#\s*\(%wheel\s*ALL=(ALL)\s*NOPASSWD:\s*ALL\)/\1/' /etc/sudoers
sed -i 's/# Defaults        requiretty/Defaults        requiretty/g' /etc/sudoers

#make public key for wheel user
mkdir -p /home/${myusr}/.ssh
chown ${myusr}:${myusr} /home/${myusr}/.ssh
chmod 700 /home/${myusr}/.ssh
echo ${pubkey} > /home/${myusr}/.ssh/authorized_keys
chown ${myusr}:${myusr} /home/${myusr}/.ssh/authorized_keys
chmod 600 /home/${myusr}/.ssh/authorized_keys
#sed -i -e "s/LANG="C"/LANG="ja_JP.UTF-8/g" /etc/sysconfig/i18n

#config for ssh
sed -i -e "s/#Port 22/Port ${myport}/g" -e "s/#PermitRootLogin yes/PermitRootLogin no/g" \
-e "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
systemctl restart sshd

#config firewalld
firewall-cmd --permanent --remove-service=ssh
firewall-cmd --permanent --add-port=${myport}/tcp
firewall-cmd --reload

#add epel repo
yum install epel-release
yum update -y
yum install vim-enhanced -y


cd
echo "
alias ls='ls --color=tty -a'
function cdls() {
 \\cd \$1;
 ls;
}
alias cd=cdls
" >> .bash_profile
source .bash_profile
