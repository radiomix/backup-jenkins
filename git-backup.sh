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

set -e

# get jenkins default variables
source /etc/default/jenkins

usage() {
  echo "USAGE: "
  echo "$0 GIT_REPO GIT_ACCOUNT"
}


syncToBackup() {
  echo "Syncing $JENKINS_HOME to $BACKUP_DIR"
  rsync -avHx $JENKINS_HOME $BACKUP_DIR
}

# Set env var
GIT_REPO=$1
GIT_ACCOUNT=$2
GIT_PASSWORD=$3

if [[ "$GIT_REPO" == "" ]]; then
  echo "Missing parameter"
  usage
fi


REPO_NAME=$(basename "$GIT_REPO" ".${GIT_REPO##*.}")
BACKUP_DIR="/var/lib/jenkins-backup/"
# Time format YYYY-MM-DD
COMMIT_MESSAGE="Backup for $JENKINS_HOME $(date +'%F')"
echo GIT_REPO:$GIT_REPO GIT_ACCOUNT:$GIT_ACCOUNT
echo REPO_NAME:$REPO_NAME BACKUP_DIR:$BACKUP_DIR COMMIT_MESSAGE:$COMMIT_MESSAGE
echo


return

# Remove old repository
if [ -d $REPO_NAME ]; then
	rm -rf $REPO_NAME
fi

# Create config file without credentials
cp $JENKINS_HOME/jobs/$JOB_NAME/config.xml $BACKUP_FILE_RAW
sed -i 	-e "s@JOB_REPOSITORY=.*@JOB_REPOSITORY=@" \
		-e "s@^REPOSITORY_ACCOUNT=.*@REPOSITORY_ACCOUNT=@" \
		-e "s@^REPOSITORY_PASSWORD=.*@REPOSITORY_PASSWORD=@" $BACKUP_FILE_RAW

# Clone repository
git clone https://$GIT_ACCOUNT:$GIT_PASSWORD@$GIT_REPO

cd $REPO_NAME

if [ ! -f $BACKUP_FILE ] || [[ -n $(diff -u ../$BACKUP_FILE_RAW $BACKUP_FILE) ]]; then
    cp ../$BACKUP_FILE_RAW $BACKUP_FILE
    git add $BACKUP_FILE
    git commit -m "$COMMIT_MESSAGE"
    git push origin master
fi



