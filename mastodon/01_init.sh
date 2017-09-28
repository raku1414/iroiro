#!/bin/bash

. mastodon_env.sh

##add user and group for mastodon
sudo useradd --system --user-group --shell /bin/bash --create-home --home $home_for_user $user
sudo useradd --shell /bin/false -g $user $exec_user
sudo install -Dm2775 -o $user -g $user -d $home_for_user
sudo cp -a mstdn/. $home_for_user
sudo chown -R $user:$user $home_for_user
##run as $user
function erun() {
    sudo -iu $user eval "$1"
}

erun 'git clone https://github.com/rbenv/rbenv.git ~/.rbenv'
erun 'cd ~/.rbenv && src/configure && make -C src'
erun 'git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build'
erun "curl -sL $nvm_sh_url | bash -"

erun 'git clone https://github.com/tootsuite/mastodon'
erun 'cd mastodon ; git checkout $(git tag -l | sort -V | tail -n 1)'

#sudo install -m644 -o $user -g $user .env.production $home_for_user/mastodon/.env.production
erun 'cd mastodon ; cp .env.production.sample .env.production'

erun 'nvm install 6'
erun 'cd mastodon ; npm install -g yarn'
erun 'cd mastodon ; yarn install --pure-lockfile'

erun 'rbenv install 2.4.1'
erun 'rbenv global 2.4.1'
erun 'cd mastodon ; gem install bundler'
erun 'cd mastodon ; bundle install --deployment --without development test'


#erun 'cd mastodon ; RAILS_ENV=production bundle exec rails db:setup'
#erun 'cd mastodon ; RAILS_ENV=production bundle exec rails assets:precompile'
