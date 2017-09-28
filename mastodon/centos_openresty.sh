#!/bin/bash

#ログ
exec 1> >(tee -a nginx.log)
exec 2> >(tee -a nginxerr.log >&2)

#--------------------------------------------------------------------#
static_domain=bobcent.tr
nginxuser=nginx

sftpgroup=sftponly
sftpuser=ishi
pass=kurowasan8916
pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQB3ee7mPpQOz\
p1domhPeHeBDgyIy7So5BbFsqS2X9U+f1js1AxwP1y2KVQK9XWnFMM\
fS5fWKG3ozbzfhzZ5dWp4IhIuXsAIEdcnYGxwl/KBamyC6d7I8y4NGzeUjf\
ZKBW6yembDT8zsH2D5qefGIyOfNIP2hrhOJ5c3WE5ckS2T1dEtHJHxypxNEyqZ\
ooQPYqJwPPvkd+1Uzk9w2wTSL6UdPVksJSFyJamA4cCSzGVDatPC54uAitjZauD1\
3iRzyP/MYwURbkNHP0qNUuwGClpaACbCZvCdpdv2yCId5pW1bya4e\
Be2EjWsLjtf4E//x/GP5VAMcPGFsH8Dk8K5A3gJ rsa-key-20140617"

#oreore
oreorekey="/usr/local/ssl/certs/nginxDefault.pem" #作るkeyの場所
oreorekeyDH="/usr/local/ssl/certs/nginxDefaultDH.pem" #作るcsrの場所
oreorecrt="/usr/local/ssl/certs/nginxDefault.crt" #作るcrtの場所
mkdir -p /usr/local/ssl/certs

#----------------------------------------------------------------------#
#create user for sftp
groupadd -g 103 ${sftpgroup}
useradd -g 103 -d /home/${sftpuser} -s /bin/false ${sftpuser}
yum -y install expect
expect -c "
set timeout 20
spawn passwd ${sftpuser}
expect -re \"新しい|New\"
send \"${pass}\n\"
expect -re \"再入力|Retype\"
send \"${pass}\n\"
interact
"
chown root:${sftpgroup} /home/${sftpuser}
chmod 750 /home/${sftpuser}
mkdir /home/${sftpuser}/Upload
chown ${sftpuser}:${sftpgroup} /home/${sftpuser}/Upload

mkdir /home/${sftpuser}/.ssh
chown ${sftpuser}:${sftpgroup} /home/${sftpuser}/.ssh
chmod 700 /home/${sftpuser}/.ssh
echo ${pubkey} > /home/${sftpuser}/.ssh/authorized_keys
chown ${sftpuser}:${sftpgroup} /home/${sftpuser}/.ssh/authorized_keys
chmod 600 /home/${sftpuser}/.ssh/authorized_keys

sed -i -e "s%Subsystem       sftp    /usr/libexec/openssh/sftp-server\
%Subsystem sftp internal-sftp # /usr/libexec/openssh/sftp-server%g" /etc/ssh/sshd_config
echo "Match Group ${sftpgroup}
  ForceCommand internal-sftp
  ChrootDirectory %h
  AllowTcpForwarding no
  X11Forwarding no
" >> /etc/ssh/sshd_config
systemctl reload sshd
#---------------------------------------------------------------------#
#オレオレ証明書作成
expect -c "
set timeout 20
spawn openssl req -days 3650 -new -nodes -newkey rsa:2048 -x509 -keyout ${oreorekey} -out ${oreorekey}
expect \"Country Name\"
send \"\n\"
expect \"State or Province Name\"
send \"\n\"
expect \"Locality Name\"
send \"\n\"
expect \"Organization Name\"
send \"\n\"
expect \"Organizational Unit Name\"
send \"\n\"
expect \"Common Name\"
send \"\n\"
expect \"Email Address\"
send \"\n\"
expect \"Please enter the following\"
send \"\n\"
expect \"A challenge\"
send \"\n\"
expect \"An optional company\"
send \"\n\"
interact
"

openssl dhparam -out ${oreorekeyDH} 2048
#--------------------------------------------------------------------#
yum install -y yum-utils
yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo
yum install -y openresty
yum install -y openresty-resty

sed -i '$c include /usr/local/openresty/nginx/conf/conf.d/*.conf\n}' /usr/local/openresty/nginx/conf/nginx.conf
sed -i -e "s/#user  nobody;/user ${nginxuser};/g" /usr/local/openresty/nginx/conf/nginx.conf
mkdir /usr/local/openresty/nginx/conf/conf.d/
cat << EOF > /usr/local/openresty/nginx/conf/conf.d/server.conf
    server {
        listen       80;
        server_name  ${static_domain};
        location / {
            root   /home/${sftpuser}/Upload/html;
            index  index.html index.htm;
        }
    }

     server {
        listen       443 ssl http2;
        server_name ${static_domain};
        ssl_certificate ${oreorekey};
        ssl_certificate_key ${oreorekey};
        ssl_session_timeout 5m;
        ssl_session_cache shared:SSL:10m;
        ssl_dhparam ${oreorekeyDH};
        ssl_protocols TLSv1.2;
        ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';
        ssl_prefer_server_ciphers on;
    root /home/${sftpuser}/Upload/php;
		index index.html;
    }
EOF

#nginxuserを作成してsftpユーザーのディレクトリにアクセスできるようにする
useradd -s /bin/false ${nginxuser}
usermod -G ${sftpgroup},${nginxuser} ${nginxuser}

firewall-cmd --permanent --add-service=http --add-service=https
firewall-cmd --reload

systemctl start openresty
