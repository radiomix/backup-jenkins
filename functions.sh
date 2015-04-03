#!/bin/bash
#
#
#


# echo in green
function echo_task {
    green='\e[0;32m'
    nocolor='\e[0m'
    echo -e "${green}[$(date)] $@ ${nocolor}"
}

echo in red
function alert {
    red='\e[0;31m'
    nocolor='\e[0m'
    echo -e "${red}[$(date)] $@ ${nocolor}"
}


## usage
usage() {
  echo "USAGE: "
  echo "$0 GIT_REPO GIT_ACCOUNT"
}


## rsync to back directory
syncToBackup() {
  echo_task "Syncing $JENKINS_HOME to $BACKUP_DIR"
  rsync -avHx $JENKINS_HOME/* $BACKUP_DIR
}

## pushing it all to the git repo
gitCommitPUsh() {
    git config --global user.name "$GIT_USER"
    git config --global user.name "$GIT_EMAIL"
    echo_task "Adding new files to git"
    git add -v --all ./*
    echo_task "Commiting into local git"
    git commit -m "$COMMIT_MESSAGE"
    echo_task "Pushing into master git"
    git push origin master
}

