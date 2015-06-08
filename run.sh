#!/usr/bin/env bash
cd ~
export DISPLAY=:10
export PATH=$PATH:/usr/bin:/usr/local/bin

curl "http://metadata/computeMetadata/v1/instance/attributes/" -H "Metadata-Flavor: Google" > metadata_keys

while read key; do
  export $key=$(curl "http://metadata/computeMetadata/v1/instance/attributes/$key" -H "Metadata-Flavor: Google")
done < metadata_keys

export E2E_TARGETS=$(echo $E2E_TARGETS |sed 's/|/ /g')

read -a targets <<< $(echo $E2E_TARGETS)

for targetUrl in "${targets[@]}"
do
  TARGET_DIR=$(echo $targetUrl|awk 'BEGIN { FS = "/" } ; { print $5 }' | awk 'BEGIN { FS = "." } ; { print $1}')
  if [ ! -d "$TARGET_DIR" ]; then
    git clone $targetUrl;
  fi

  cd $TARGET_DIR;

  git checkout master;
  git fetch origin;
  MERGERESULT=$(git merge origin/master -X theirs -m "merge");

  if [ -f E2E_OUTFILE ]; then
    exit 0
  fi

  PASSFAIL=--FAIL--
  if npm run e2e >E2E_OUTFILE 2>&1; then
    PASSFAIL=pass
  fi

  cd ~
  echo -n $(date) >> $TARGET_DIR.log
  echo -n " " >> $TARGET_DIR.log
  echo $PASSFAIL >> $TARGET_DIR.log

  if [ $PASSFAIL == "--FAIL--" ]; then
    mv $TARGET_DIR/E2E_OUTFILE "$TARGET_DIR/E2E_ERROR_$(date)" || true
    mv $TARGET_DIR/uncaught-exception.png "$TARGET_DIR/uncaught-exception-$(date).png" || true
    if [ $(tail -n 3 $TARGET_DIR.log |grep FAIL |wc -l) = 3 ]; then
      TOKEN=$(curl -s "http://metadata/computeMetadata/v1/instance/service-accounts/default/token?alt=text" \
      -H "Metadata-Flavor: Google" |grep access_token |awk '{print $2}')
      curl -X POST -H "Content-Length: 0" -H "Authorization: Bearer $TOKEN" \
      "http://logger-dot-rvaserver2.appspot.com/queue?task=submit&logger_version=1&token=scenario-runner&environment=prod&severity=alert&error_message=e2e-scenario-failed&error_details=$TARGET_DIR"
    fi
  else
    rm $TARGET_DIR/E2E_OUTFILE
  fi
done
