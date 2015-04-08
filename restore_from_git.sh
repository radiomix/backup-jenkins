#!/bin/bash
#
# restore script to checkout and rsync $JENKINS_HOME from a git repo.
#

#
# We present git commits from the git repo and let the user checkout a version
# We rsync $JENKINS_HOME from the checked out version in the backup directory 
#

# exit on all errors: commands, unset variables, piped commands
set -euo pipefail

# get jenkins default variables
source /etc/default/jenkins
source functions.sh

# Set script parameter
GIT_REPO=test-repo
GIT_ACCOUNT=test-account
GIT_USER="Jenkins Backup Script"
GIT_EMAIL="build-engeneer@my-company.com"

if [[ "$GIT_REPO" == "" ]]; then
  echo_red "ERROR: Missing repo "
  usage
fi
if [[ "$GIT_ACCOUNT" == "" ]]; then
  echo_red "ERROR: Missing parameter"
  usage
fi

echo_blue "Starting to restore Service Jenkins on AMI $AMI_ID"


cd $BACKUP_DIR
set +e
GIT_STATUS=$($gitu status -s)
set -e
echo_green $GIT_STATUS 
if  [[ ! "$GIT_STATUS " == "" ]]; then
## pushing it all to the git repo
  gitCheckoutCommit
  COMMIT_MESSAGE="\"[$(date)]restore $JENKINS_HOME with commit $COMMIT_SHA on ami $AMI_ID\""
## write commit is user jenkins into log message
  echo $COMMIT_MESSAGE | sudo -u $JENKINS_USER tee -a $LOGFILE >/dev/null
else 
  echo_red "ERROR: Directory $BACKUP_DIR is not under git control!"
  echo_blue "Please initialize a git repo in $BACKUP_DIR"
  exit -1 
fi

# rsync from backup dir 
syncFromBackup

# cleanup backup dir to point to master
cd $BACKUP_DIR
gitCheckoutMaster
echo_blue "DONE "

