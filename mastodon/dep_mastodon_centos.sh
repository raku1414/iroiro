#!/bin/bash
yum groupinstall "Development Tools"
yum install -y kernel-devel kernel-headers libffi-devel gdbm-devel gdbm libyaml-devel readline-devel ncurse-devel libxml2-devel libxslt-devel pkgconfig autoconf bison bison-devel protobuf protobuf-compiler protobuf-devel libidn-devel libicu-devel openssl-devel readline-devel zlib-devel gcc gcc-c++ bzip2 git ImageMagick ffmpeg redis postgresql-contrib postgresql-server postgresql postgresql-devel
systemctl start redis && sudo systemctl enable $_
postgresql-setup initdb
systemctl start postgresql && systemctl enable $_
sudo su - postgres -c 'psql -c "CREATE USER mastodon CREATEDB;"'
sed -i.org '/shared_preload_libraries/ s/^#//' /var/lib/pgsql/data/postgresql.conf
sed -i "/shared_preload_libraries/ s/''/'pg_stat_statements'/" /var/lib/pgsql/data/postgresql.conf
sed -i "/shared_preload_libraries/a pg_stat_statements.track = all" /var/lib/pgsql/data/postgresql.conf

systemctl restart postgresql

