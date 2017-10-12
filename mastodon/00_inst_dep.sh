#!/bin/bash

. /etc/os-release

if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
	sudo apt -y install imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file git-core g++ libprotobuf-dev protobuf-compiler pkg-config  gcc autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev nginx redis-server redis-tools postgresql postgresql-contrib libidn11-dev libicu-dev
	sudo apt -y install expect
elif [ "$ID" = "centos" ] || [ "$ID" = "fedora" ]; then
	yum groupinstall "Development Tools"
	yum install -y kernel-devel kernel-headers libffi-devel gdbm-devel gdbm libyaml-devel readline-devel ncurse-devel libxml2-devel libxslt-devel pkgconfig autoconf bison bison-devel protobuf protobuf-compiler protobuf-devel libidn-devel libicu-devel openssl-devel readline-devel zlib-devel gcc gcc-c++ bzip2 git ImageMagick ffmpeg redis postgresql-contrib postgresql-server postgresql postgresql-devel
	yum install -y expect
elif [ "$ID" = "arch" ]; then
	sudo pacman -S ffmpeg imagemagick libjpeg-turbo libpng libtiff libpqxx libxslt git gcc protobuf pkg-config autoconf bison openssl libyaml readline zlib ncurses libffi gdbm nginx redis postgresql postgresql-libs libidn icu
	sudo pacman -S expect
fi
