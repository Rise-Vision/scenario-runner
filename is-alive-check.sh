#!/usr/bin/env bash
cd ~
RECENT_RUN=0

read -a LOGFILES <<< $(find . -maxdepth 1 -iname "*.log")

for logfile in "${LOGFILES[@]}"
do
  CHECK_RECENT_RUN=$(date --date="$(tail $logfile -n 1 |awk '{$(NF--)="";print}')" +%s)
  if [ $CHECK_RECENT_RUN -gt $RECENT_RUN ]; then RECENT_RUN=$CHECK_RECENT_RUN;fi
done

NOW=`date +%s`
DIFF=$(($NOW-$RECENT_RUN))

if [ $DIFF -gt 600 ]; then
  TOKEN=$(curl -s "http://metadata/computeMetadata/v1/instance/service-accounts/default/token?alt=text" -H "Metadata-Flavor: Google" |grep access_token |awk '{print $2}')
  curl -X POST -H "Content-Length: 0" -H "Authorization: Bearer $TOKEN" "http://logger-dot-rvaserver2.appspot.com/queue?task=submit&logger_version=1&token=scenario-runner&environment=prod&severity=alert&error_message=not-running&error_details=Scenario-Runner is not running"
fi
