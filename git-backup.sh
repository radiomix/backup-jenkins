#!/bin/bash
#
# backup script to add/commit/push $JENKINS_HOME into a git repo.
# Idea: https://github.com/nghiant2710/jenkins-backup and
#       https://github.com/luisalima/backup_jenkins_config
#

set -e

# Set env var
GIT_REPO=$1
GIT_ACCOUNT=$2
GIT_PASSWORD=$3
REPO_NAME=$(basename "$GIT_REPO" ".${GIT_REPO##*.}")
BACKUP_FILE="Jenkins_Config_$REPO_NAME-backup.xml"
BACKUP_FILE_RAW="Jenkins_Config_$REPO_NAME-backup-RAW.xml"
# Time format YYYY-MM-DD
COMMIT_MESSAGE="Build Configuration Backup for $REPO_NAME $(date +'%F')"

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



