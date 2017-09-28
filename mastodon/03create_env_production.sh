#!/bin/bash
. mastodon_env.sh

sudo -iu $user eval "cd mastodon ; sed -e s/^PAPERCLIP_SECRET=/PAPERCLIP_SECRET=\$(RAILS_ENV=production bundle exec rake secret)/g \
    -e s/^SECRET_KEY_BASE=/SECRET_KEY_BASE=\$(RAILS_ENV=production bundle exec rake secret)/g \
    -e s/^OTP_SECRET=/OTP_SECRET=\$(RAILS_ENV=production bundle exec rake secret)/g \
    -e /VAPID_PUBLIC_KEY=/d \
    -e /VAPID_PRIVATE_KEY=/d \
       .env.production.sample > .env.production"

sudo -iu $user eval 'cd mastodon ; RAILS_ENV=production bundle exec rake mastodon:webpush:generate_vapid_key  >> .env.production'
