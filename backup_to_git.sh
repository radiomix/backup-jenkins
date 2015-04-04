#!/bin/bash
#
# backup script to add/commit/push $JENKINS_HOME into a git repo.
# Idea: https://github.com/nghiant2710/jenkins-backup and
#       https://github.com/luisalima/backup_jenkins_config
#

#
# We rsync $JENKINS_HOME to a different directory 
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

if [[ "$GIT_REPO" == "" ]]; then
  echo_red "ERROR: Missing repo "
  usage
fi
if [[ "$GIT_ACCOUNT" == "" ]]; then
  echo_red "ERROR: Missing parameter"
  usage
fi

BACKUP_DIR="/var/lib/jenkins-backup"
# Time format YYYY-MM-DD
COMMIT_MESSAGE="\"Backup for $JENKINS_HOME $(date +'%F %T')\""
echo_blue "Starting to backup Service Jenkins"
if [[ -d $BACKUP_DIR && -O $BACKUP_DIR ]]; then
  echo_green "Stoping Service Jenkins" 
  echo_green "$(service jenkins stop)"
# rsync to backup dir 
  syncToBackup
  echo_green "Starting Service Jenkins" 
  echo_green "$(service jenkins start)"
else 
  echo_red "ERROR: Directory $BACKUP_DIR does not exist or is not writable!"
  exit -1 
fi

cd $BACKUP_DIR
## add a date file, so we have anything to commit
date >> date.txt
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

