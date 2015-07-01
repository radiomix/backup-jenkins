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

set +u
COMMIT_MESSAGE="\"[$(date)]'$1': push $JENKINS_HOME on ami $AMI_ID to remote\""
set -u

if [[ "$GIT_REPO" == "" ]]; then
  echo_red "ERROR: Missing repo "
  usage
fi
if [[ "$GIT_ACCOUNT" == "" ]]; then
  echo_red "ERROR: Missing parameter"
  usage
fi


# git work
cd $BACKUP_DIR
set +e
GIT_STATUS=$(git status -s)
set -e
echo_green $GIT_STATUS 
if  [[ ! "$GIT_STATUS " == "" ]]; then
## push as user jenkins into log file
  echo $COMMIT_MESSAGE | sudo -u $JENKINS_USER tee -a $LOGFILE >/dev/null
## pushing it all to the git repo
  gitPush
else 
  echo_red "ERROR: Directory $BACKUP_DIR is not under git control!"
  echo_blue "Please initialize a git repo in $BACKUP_DIR"
  echo -ne "${nocolor}"
  exit -1 
fi
echo_blue "DONE $0"
echo -ne "${nocolor}"

