#!/bin/bash

current=$(pwd)

if [ $(echo $SHELL | grep zsh) ] ; then
	rcfile="$HOME/.zshrc"
elif [ $(echo $SHELL | grep bash) ] ; then
	rcfile="$HOME/.bashrc"
fi
echo $rcfile
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

cat << "EOF" >> $rcfile
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"
EOF

export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"
source $rcfile
rbenv install 2.4.2
rbenv global 2.4.2

cd $current

git clone https://github.com/mikutter/mikutter
cd mikutter && gem install bundler
bundle install

mkdir -p ~/.local/share/applications
cat << EOF > ~/.local/share/applications/mikutter.desktop
[Desktop Entry]
Name=Mikutter
Exec=$(which ruby) $(pwd)/mikutter.rb
Terminal=false
Type=Application
Icon=$(pwd)/core/skin/data/icon.png
EOF

