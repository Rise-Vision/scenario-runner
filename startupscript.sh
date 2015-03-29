#!/usr/env bash

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

if ! gcloud auth list |grep 452091732215@developer.gserviceaccount.com; then
  git clone git@github.com:Rise-Vision/private-keys.git
  cd private-keys
  gcloud auth activate-service-account 452091732215@developer.gserviceaccount.com --key-file storage-server/65bd1c5e62dadd4852c8b04bf5124749985e8ff8-privatekey.p12
  cd ..
fi

if ! which node; then
  curl -sL https://deb.nodesource.com/setup_0.12 |sudo bash -
  sudo apt-get install -y nodejs
fi

if ! which bower; then
  sudo npm install -g bower
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
