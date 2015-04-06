#!/bin/bash
#
#
#


nocolor='\e[0m'
green='\e[0;32m'
red='\e[0;31m'
blue='\e[0;34m'

# echo in green
function echo_green() {
    echo -e "${green}[$(date)] $@ ${nocolor}"
}

#echo in blue
function echo_blue() {
    echo -e "${blue}[$(date)] $@ ${nocolor}"
}
#echo in red
function echo_red() {
    echo -e "${red}[$(date)] $@ ${nocolor}"
}


## usage
usage() {
  echo_blue "USAGE: "
  echo_blue  " $0 GIT_REPO GIT_ACCOUNT"
}


## rsync to back directory
syncToBackup() {
  echo_green "Syncing $JENKINS_HOME to $BACKUP_DIR"
  echo_green "$(rsync -avHx $JENKINS_HOME/* $BACKUP_DIR)"
}

## pushing it all to the git repo
gitCommitPUsh() {
    ## add a date file, so we have anything to commit
    echo $COMMIT_MESSAGE >> backup.log 

    git config --global user.name "$GIT_USER"
    git config --global user.email "$GIT_EMAIL"
    echo_green "Adding new files to git"
    echo -ne "${green}"; git  add --verbose  --all $BACKUP_DIR/; echo -ne "${nocolor}"
    ### commit message must be quoted with double quotes, otherwise: ERROR! fatal  
    echo_green "Commiting into local git $(pwd)"
    echo -ne "${green}"
    git commit --verbose -m "$COMMIT_MESSAGE"
    echo -ne "${nocolor}"

    echo_green "Pushing into master git"
    echo -ne "${green}"; $(git push --verbose origin master); echo -ne "${nocolor}"
}
