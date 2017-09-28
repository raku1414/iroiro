#!/bin/bash
sudo cat << EOF | sudo tee /etc/sysctl.d/redis.conf
vm.overcommit_memory = 1
net.core.somaxconn = 1024
EOF
sudo systemctl start postgresql && sudo systemctl enable $_
sudo -iu postgres eval "psql -c \"CREATE USER $user CREATEDB;\""
sed -i.org '/shared_preload_libraries/ s/^#//' /var/lib/postgres/data/postgresql.conf
sed -i "/shared_preload_libraries/ s/''/'pg_stat_statements'/" /var/lib/postgres/data/postgresql.conf
sed -i "/shared_preload_libraries/a pg_stat_statements.track = all" /var/lib/postgres/data/postgresql.conf


echo 'add kernel parameter "transparent_hugepage=never"
and
sudo systemctl start redis && sudo systemctl enable $_'
