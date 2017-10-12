#!/bin/sh

current=$(pwd)
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

cat << 'EOF' >> ~/.zshrc
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"
EOF

source ~/.zshrc
rbenv install 2.4.2
rbenv global 2.4.2

cd $current

git clone https://github.com/mikutter/mikutter
cd mikutter && gem install bundler

cat << EOF > ~/.local/share/applications/mikutter.desktop
[Desktop Entry]
Name=Mikutter
Exec=$(which ruby) $(pwd)/mikutter.rb
Terminal=false
Type=Application
Icon=$(pwd)/core/skin/data/icon.png
EOF

