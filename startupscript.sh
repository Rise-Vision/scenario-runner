#!/usr/env bash

#to automatically run this at intance startup specify instance metadata as follows
#startup-script-url https://raw.githubusercontent.com/Rise-Vision/scenario-runner/master/startupscript.sh
#see https://cloud.google.com/compute/docs/startupscript#googlecloudstorage

sudo apt-get update

if [ ! -f /swapfile ]; then
  sudo dd if=/dev/zero of=/swapfile bs=1024 count=4194304
  sudo echo "/swapfile none swap sw 0 0" >> /etc/fstab
  sudo swapon -a
fi

if ! which git; then
  sudo apt-get -y install git-core
  git config --global user.name "jenkins"
  git config --global user.email "jenkins@risevision.com"
fi

if ! which node; then
  curl -sL https://deb.nodesource.com/setup_0.12 |sudo bash -
  sudo apt-get install -y nodejs
fi

#if ! which phantomjs; then
#  sudo apt-get install build-essential g++ flex bison gperf ruby perl \
#  libsqlite3-dev libfontconfig1-dev libicu-dev libfreetype6 libssl-dev \
#  libpng-dev libjpeg-dev
#
#  git clone git://github.com/ariya/phantomjs.git
#  cd phantomjs
#  git checkout master
#  ./build.sh --confirm --jobs 1
#fi

if ! which unzip; then
  sudo apt-get install -y unzip
fi

if ! which chromium; then
  sudo apt-get install -y chromium
fi

if ! which chromedriver; then
  curl -O "http://chromedriver.storage.googleapis.com/2.12/chromedriver_linux64.zip"
  unzip chromedriver_linux64.zip
  rm chromedriver_linux64.zip
  sudo mv chromedriver /usr/local/bin;
  sudo chmod a+x /usr/local/bin/chromedriver;
fi

if ! which Xvfb; then
  sudo apt-get install -y xvfb
fi

export DISPLAY=:10
if ! pidof Xvfb ; then
  Xvfb :10 -screen 0 1024x768x24 &
fi
