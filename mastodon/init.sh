#!/bin/bash

edit_user="mastodon"
edit_user_home="/opt/mstdn"
exec_user="mastodonx"
nvm_sh_url="https://raw.githubusercontent.com/creationix/nvm/v0.33.4/install.sh"

##add user and group for mastodon
sudo useradd --system --user-group --shell /bin/bash --create-home --home $edit_user_home $edit_user
sudo useradd --shell /bin/false -g $edit_user $exec_user
sudo install -Dm2775 -o $edit_user -g $edit_user -d $edit_user_home
sudo cp -a mstdn/. $edit_user_home
sudo chown -R $edit_user:$edit_user $edit_user_home
##run as $edit_user
function erun() {
    sudo -iu $edit_user eval "$1"
}

erun 'git clone https://github.com/rbenv/rbenv.git ~/.rbenv'
erun 'cd ~/.rbenv && src/configure && make -C src'
erun 'git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build'
erun "curl -sL $nvm_sh_url | bash -"

erun 'git clone https://github.com/tootsuite/mastodon'
erun 'cd mastodon ; git checkout $(git tag -l | sort -V | tail -n 1)'

#sudo install -m644 -o $edit_user -g $edit_user .env.production $edit_user_home/mastodon/.env.production
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

