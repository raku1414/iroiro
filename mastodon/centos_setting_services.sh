#!/bin/bash
systemctl start redis && sudo systemctl enable $_
postgresql-setup initdb
systemctl start postgresql && systemctl enable $_
sudo su - postgres -c 'psql -c "CREATE USER mastodon CREATEDB;"'
sed -i.org '/shared_preload_libraries/ s/^#//' /var/lib/pgsql/data/postgresql.conf
sed -i "/shared_preload_libraries/ s/''/'pg_stat_statements'/" /var/lib/pgsql/data/postgresql.conf
sed -i "/shared_preload_libraries/a pg_stat_statements.track = all" /var/lib/pgsql/data/postgresql.conf
