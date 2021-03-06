#!/bin/bash
edit_user="mastodon"
exec_user="mastodonx"
user_home=$(sudo -iu $user pwd)
node_env=$(sudo -iu $user eval 'nvm which 6 | sed -E s@/bin/node@/bin@g | cat')

mastodon_domain="mstdn.meltytempo.tk"
mastodon_public_dir="$home_for_user/mastodon/public"
mastodon_crt="/etc/letsencrypt/live/mstdn.meltytempo.tk/fullchain.pem"
mastodon_key="/etc/letsencrypt/live/mstdn.meltytempo.tk/privkey.pem"
#sudo mkdir -p /etc/nginx/ssl

cat << EOF | sudo tee  /etc/systemd/system/mastodon-web.service
[Unit]
Description=mastodon-web
After=network.target

[Service]
Type=simple
User=$user_for_run
WorkingDirectory=$home_for_user/mastodon
Environment="RAILS_ENV=production"
Environment="PORT=3000"
Environment=PATH=$node_env:$home_for_user/.rbenv/shims:$home_for_user/.rbenv/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=$home_for_user/.rbenv/shims/bundle exec puma -C config/puma.rb
TimeoutSec=15
Restart=always
EOF

cat << EOF | sudo tee /etc/systemd/system/mastodon-sidekiq.service
[Unit]
Description=mastodon-sidekiq
After=network.target

[Service]
Type=simple
User=$user_for_run
WorkingDirectory=$home_for_user/mastodon
Environment="RAILS_ENV=production"
Environment="DB_POOL=5"
Environment=PATH=$node_env:$home_for_user/.rbenv/shims:$home_for_user/.rbenv/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=$home_for_user/.rbenv/shims/bundle exec sidekiq -c 5 -q default -q mailers -q pull -q push
TimeoutSec=15
Restart=always

[Install]
WantedBy=multi-user.target
EOF

cat << EOF | sudo tee /etc/systemd/system/mastodon-streaming.service
[Unit]
Description=mastodon-streaming
After=network.target

[Service]
Type=simple
User=$user_for_run
WorkingDirectory=$home_for_user/mastodon
Environment="NODE_ENV=production"
Environment="PORT=4000"
ExecStart=$home_for_user/.nvm/nvm-exec npm run start
TimeoutSec=15
Restart=always
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload


sed -e "s@mastodon_domain@$mastodon_domain@g" \
    -e "s@mastodon_public_dir@$mastodon_public_dir@g" \
    -e "s@mastodon_crt@$mastodon_crt@g" \
    -e "s@mastodon_key@$mastodon_key@g" nginx_mastodon_template.conf > nginx_mastodon.conf

sudo mkdir -p /etc/nginx/conf.d/
sudo cp nginx_mastodon.conf /etc/nginx/conf.d/
