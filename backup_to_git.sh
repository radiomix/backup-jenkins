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
  alert "ERROR: Missing repo "
  usage
fi

if [[ "$GIT_ACCOUNT" == "" ]]; then
  alert "ERROR: Missing parameter"
  usage
fi

BACKUP_DIR="/var/lib/jenkins-backup/"
# Time format YYYY-MM-DD
COMMIT_MESSAGE="Backup for $JENKINS_HOME $(date +'%F %T')"
#echo GIT_REPO:$GIT_REPO GIT_ACCOUNT:$GIT_ACCOUNT
#echo BACKUP_DIR:$BACKUP_DIR COMMIT_MESSAGE:$COMMIT_MESSAGE
#echo

if [[ -d $BACKUP_DIR && -O $BACKUP_DIR ]]; then
# rsync to backup dir 
  syncToBackup
else 
  alert "ERROR: Directory $BACKUP_DIR does not exist or is not writable!"
  exit -1 
fi

cd $BACKUP_DIR
## add a date file, so we have anything to commit
date >> date.txt
set +e
GIT_STATUS=$(git status -s)
set -e
echo $GIT_STATUS
if  [[ $GIT_STATUS ]]; then
## pushing it all to the git repo
  gitCommitPUsh
else 
  alert "ERROR: Directory $BACKUP_DIR is not under git control!"
  echo "       Please initialize a git repo in $BACKUP_DIR"
  exit -1 
fi
git status
echo_task "DONE "

