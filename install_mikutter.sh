#!/bin/sh

current=$(pwd)

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

cat << "EOF" >> ~/.$(echo $0)rc
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"
EOF

source ~/.$(echo $0)rc
rbenv install 2.4.2
rbenv global 2.4.2

cd $current

git clone https://github.com/mikutter/mikutter
cd mikutter && gem install bundler

cat << EOF > ~/.local/share/applications/mikutter.desktop
[Desktop Entry]
Name=Mikutter
Exec=$(which ruby) $(pwd)/mikutter/mikutter.rb
Terminal=false
Type=Application
Icon=$(pwd)/mikutter/core/skin/data/icon.png
EOF
