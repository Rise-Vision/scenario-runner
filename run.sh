#!/usr/bin/env bash
echo "running"
cd ~

if ! which git; then
  sudo apt-get update
  sudo apt-get -y install git-core
  git config --global user.name "jenkins"
  git config --global user.email "jenkins@risevision.com"
fi

if ! which node; then
  curl -sL https://deb.nodesource.com/setup_0.12 |sudo bash -
  sudo apt-get install -y nodejs
fi

if [ ! -d "private-keys" ]; then
  git clone git@github.com:Rise-Vision/private-keys.git
fi

JENKINS_PASS=$(cat private-keys/jenkins-pass/jenkins-pass)

readarray -t TARGETS < config/targets.txt

for i in "${TARGETS[@]}"
do
  DIR=$(echo $i|awk 'BEGIN { FS = "/" } ; { print $2 }' | awk 'BEGIN { FS = "." } ; { print $1}')
  if [ ! -d "$DIR" ]; then
    git clone $i;
  fi

  cd $DIR; git fetch origin master;MERGERESULT=$(git merge origin/master -X theirs);
  if [ "$MERGERESULT" != "Already up-to-date." ]; then
    npm install; bower install;
  fi

  PASSFAIL=fail
  if npm run e2e; then
    PASSFAIL=pass
  fi

  cd ~
  echo -n $(date) >> $DIR.log
  echo -n " " >> $DIR.log
  echo $PASSFAIL >> $DIR.log
done
