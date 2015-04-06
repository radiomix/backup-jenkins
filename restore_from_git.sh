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

## KEEP VARIABLE IN SYNC WITH backup_to_git.sh
BACKUP_DIR="/var/lib/jenkins-backup"
# Time format YYYY-MM-DD
echo_blue "Starting to restore Service Jenkins on AMI $AMI_ID"


cd $BACKUP_DIR
set +e
GIT_STATUS=$(git status -s)
set -e
echo_green $GIT_STATUS 
if  [[ ! "$GIT_STATUS " == "" ]]; then
## pushing it all to the git repo
  gitCheckoutCommit
else 
  echo_red "ERROR: Directory $BACKUP_DIR is not under git control!"
  echo_blue "Please initialize a git repo in $BACKUP_DIR"
  exit -1 
fi

# rsync from backup dir 
syncFromBackup
echo_blue "DONE "

