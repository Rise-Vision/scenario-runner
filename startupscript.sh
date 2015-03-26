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

if ! which phantomjs; then
  sudo apt-get install build-essential g++ flex bison gperf ruby perl \
  libsqlite3-dev libfontconfig1-dev libicu-dev libfreetype6 libssl-dev \
  libpng-dev libjpeg-dev

  git clone git://github.com/ariya/phantomjs.git
  cd phantomjs
  git checkout master
  ./build.sh --confirm --jobs 1
fi
