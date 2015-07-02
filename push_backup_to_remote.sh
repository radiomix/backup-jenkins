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

check_repo
echo_blue "Starting to push commits on AMI $AMI_ID"


## push as user jenkins into log file
echo $COMMIT_MESSAGE | sudo -u $JENKINS_USER tee -a $LOGFILE >/dev/null
## pushing it all to the git repo
gitPush

echo_blue "DONE $0"
echo -ne "${nocolor}"

