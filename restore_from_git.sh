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
source $(dirname $0)/functions.sh

check_repo
echo_blue "Starting to restore Service Jenkins on AMI $AMI_ID"

## pushing it all to the git repo
gitCheckoutCommit
COMMIT_MESSAGE="\"[$(date)]'$COMMIT_SHA': restore $JENKINS_HOME on ami $AMI_ID\""
## write commit is user jenkins into log message
echo $COMMIT_MESSAGE | sudo -u $JENKINS_USER tee -a $LOGFILE >/dev/null

# rsync from backup dir
syncFromBackup

# cleanup backup dir to point to master
cd $BACKUP_DIR
gitCheckoutMaster
echo_blue "DONE "
echo -ne "${nocolor}"

