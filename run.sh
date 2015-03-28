#!/usr/bin/env bash
cd ~

if [ ! -d "node_modules/selenium-webdriver" ]; then
  npm install selenium-webdriver
fi

if [ ! -d "private-keys" ]; then
  git clone git@github.com:Rise-Vision/private-keys.git
fi

JENKINS_PASS=$(cat private-keys/jenkins-pass/jenkins-pass)

export DISPLAY=:10

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

  if [ $PASSFAIL == "fail" ]; then
    TOKEN=curl "http://metadata/computeMetadata/v1/instance/service-accounts/default/token" \
    -H "Metadata-Flavor: Google" |sed 's/{//g' |sed 's/"//g' |awk 'BEGIN { FS = ":" } ; {print $2 }' \
    |awk 'BEGIN { FS = "," } ; {print $1}'
    curl -X POST -H "Content-Length: 0" -H "Authorization: Bearer $TOKEN" \
    "http://logger-dot-rvaserver2.appspot.com/queue?task=submit&logger_version=1&token=scenario-runner&environment=prod&severity=alert&error_message=e2e-scenario-failed&error_details=$DIR"
  fi
done
