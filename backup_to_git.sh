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
source functions.sh

# Set script parameter
GIT_REPO=test-repo
GIT_ACCOUNT=test-account
GIT_USER="Jenkins Backup Script"
GIT_EMAIL="build-engeneer@my-company.com"
BACKUP_DIR="/var/lib/jenkins-backup"
# Time format YYYY-MM-DD
COMMIT_MESSAGE="\"[$(date)]backup $JENKINS_HOME \""
LOGFILE=$BACKUP_DIR"/backup.log"


if [[ "$GIT_REPO" == "" ]]; then
  echo_red "ERROR: Missing repo "
  usage
fi
if [[ "$GIT_ACCOUNT" == "" ]]; then
  echo_red "ERROR: Missing parameter"
  usage
fi

# rsync to backup dir 
syncToBackup

# git work
cd $BACKUP_DIR
set +e
GIT_STATUS=$(git status -s)
set -e
echo_green $GIT_STATUS 
if  [[ ! "$GIT_STATUS " == "" ]]; then
## pushing it all to the git repo
  gitCommitPUsh
else 
  echo_red "ERROR: Directory $BACKUP_DIR is not under git control!"
  echo_blue "Please initialize a git repo in $BACKUP_DIR"
  exit -1 
fi
echo_blue "DONE "

