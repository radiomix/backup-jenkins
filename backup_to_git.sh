#!/bin/bash
#
# backup script to add/commit/push $JENKINS_HOME into a git repo.
# Idea: https://github.com/nghiant2710/jenkins-backup and
#       https://github.com/luisalima/backup_jenkins_config
#

#
# We rsync $JENKINS_HOME to BACKUP_DIR directory 
# and push these files into a git repo
#

# exit on all errors: commands, unset variables, piped commands
set -euo pipefail

# get jenkins default variables
source /etc/default/jenkins
source $(dirname $0)/functions.sh


NO_ARGS=0
E_OPTERROR=85

if [ $# -eq "$NO_ARGS" ]
then
      echo "Usage: `basename $0` Commit Message"
      echo "EXIT"
      exit $E_OPTERROR

fi
exit
check_repo
echo_blue "Starting to backup Service Jenkins on AMI $AMI_ID"
if [ $# -eq 0 ]; then
  echo_blue  "No commit message added, using:" 
  echo_green  $COMMIT_MESSAGE
  echo -n "Using above commit message? [Y|n]"
  read input
  if [[ "$input" == "n" ]]; then
     echo_blue " If you want a commit message type:"
     echo "    $0 \"MY COMMIT MESSAGE\""
     echo_blue " Not doing nothing!"
     echo_red " EXIT due to user input!"
     exit -1
  fi
fi
# rsync to backup dir 
syncToBackup

## write commit as user jenkins into log file
echo $COMMIT_MESSAGE | sudo -u $JENKINS_USER tee -a $LOGFILE >/dev/null
## pushing it all to the git repo
gitCommit

echo $COMMIT_MESSAGE
echo_blue "DONE "

