#!/bin/bash
#
# Automatically archive logs and clean up files 7 days ago.
#
# Crontab: 0 3 * * * log_auto_handle.sh &> /dev/null

# The variable WORKDIR is Log file storage directory
WORKDIR=/data/logs
DATE=$(date +%F)

MainProcess (){
  for DIRS in $(ls $WORKDIR)
  do
    cd $WORKDIR/"$DIRS" || continue
    ls *.log &> /dev/null
    if [ $? -eq 0 ];then
      for FILES in $(ls *.log)
      do
        cp -a $FILES "${FILES%.*}"-"$DATE".log
        echo > "$FILES"
      done
      tar -zcf logs-"$DATE".tar.gz *"$DATE".log
      rm -f *"$DATE".log
      find . -type f -mtime +7 -name "*.tar.gz" -exec rm -f {} \;
    fi
    #Clear java accesslogs
    find . -type f -mtime +7 -name "access*.txt" -exec rm -f {} \;
  done
}


MainProcess
