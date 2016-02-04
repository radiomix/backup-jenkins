#!/bin/bash
#

############################################
## common parameters/settings
# Set script parameter
GIT_REPO=test-repo
GIT_ACCOUNT=test-account
GIT_USER="Jenkins Backup Script"
GIT_EMAIL="mkl@im7.de"

## exclude files from syncing
# each pattern needs option "--exclude "
RSYNC_EXCLUDE="--exclude '.git*' --exclude '.ssh*' --exclude '.bash*' --exclude 'jobs/*/builds*'"

##
## for testing purpose, we let ubuntu do the git work,
## because ubuntu does have the credentials
gitu='sudo -u ubuntu git '
## if user jenkins has got the crendentials, out comment next line
#gitu="sudo -u $JENKINS_USER git "

## AMI id
export AMI_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id/)

## log file, base dir from /etc/default/jenkins
LOGFILE=$(dirname $JENKINS_LOG)"/backup.log"

##
## the backup directory, should contain
## a valid git repo with the changes
BACKUP_DIR="/var/lib/jenkins-backup"
#BACKUP_DIR="/home/ubuntu/jenkins-plugin-backup"
############################################



set +u
# add input argument to standard commit message
COMMIT_MESSAGE="\"[$(date)]'$1': backup $JENKINS_HOME on ami $AMI_ID \""
set -u


## colors
nocolor='\e[0m'
green='\e[0;32m'
red='\e[0;31m'
blue='\e[0;34m'
#
echo  "LOGGING TO $LOGFILE"

function check_repo() {
# git repo set?
if [[ "$GIT_REPO" == "" ]]; then
  echo_red "ERROR: Missing repo "
  usage
fi
# git account set?
if [[ "$GIT_ACCOUNT" == "" ]]; then
  echo_red "ERROR: Missing parameter"
  usage
fi
# git repo existent?
cd $BACKUP_DIR
set +e
GIT_STATUS=$(git status -s)
set -e
echo_green $GIT_STATUS
if  [[  "$GIT_STATUS " == "" ]]; then
  echo_red "ERROR: Directory $BACKUP_DIR is not under git control!"
  echo_blue "Please initialize a git repo in $BACKUP_DIR"
  echo -ne "${nocolor}"
  exit -1
fi
}

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
  echo_blue "Starting to backup Service Jenkins on AMI $AMI_ID"
  user=$(stat -c %U $BACKUP_DIR) #check ownership of backup dir
  if [[ -d $BACKUP_DIR  ]]; then #test write permission
    echo_green "Stoping Service Jenkins" 
    echo_green "$(sudo service jenkins stop)"
    # rsync to backup dir 
    echo_green "Syncing $JENKINS_HOME to $BACKUP_DIR"
    echo_green "$(sudo rsync -avHx --chown=ubuntu:ubuntu --delete $RSYNC_EXCLUDE $JENKINS_HOME/ $BACKUP_DIR )"
    echo_green "Starting Service Jenkins" 
    echo_green "$(sudo service jenkins start)"
  else 
    echo_red "ERROR: Directory $BACKUP_DIR does not exist or is not writable!"
    echo -ne "${nocolor}"
    return [-1] 
  fi
}
## rsync from back directory
syncFromBackup() {
  echo_blue "Starting to restore Service Jenkins on AMI $AMI_ID"
  user=$(stat -c %U $BACKUP_DIR) #check ownership of backup dir
  if [[ -d $BACKUP_DIR ]]; then #test write permission
    echo_green "Stoping Service Jenkins" 
    echo_green "$(sudo service jenkins stop)"
    # rsync from backup dir
    echo_green "Syncing $JENKINS_HOME from $BACKUP_DIR"
    echo_green "$(sudo rsync -avHx --chown=jenkins:jenkins --delete $RSYNC_EXCLUDE $BACKUP_DIR/ $JENKINS_HOME )"
    echo_green "$(sudo chown -R jenkins:jenkins $JENKINS_HOME)"
    echo_green "Starting Service Jenkins" 
    echo_green "$(sudo service jenkins start)"
  else 
    echo_red "ERROR: Directory $BACKUP_DIR does not exist or is not writable!"
    echo -ne "${nocolor}"
    return [-1] 
  fi
}

## commit changes in backup dir to git repo
gitCommit() {
    echo_green "Adding new files to git"
    $gitu add --verbose  --all .
    echo_green "Commiting into local git $(pwd)"
    ### commit message must be quoted with double quotes, otherwise: ERROR! fatal  
    echo -ne "${green}"; $gitu commit --verbose -m "$COMMIT_MESSAGE"; echo -ne "${nocolor}"
}

## push changes in backup dir to remote git repo
gitPush() {
    echo_green "Pushing into remote git"
    echo -ne "${green}"; $($gitu push --verbose origin master); echo -ne "${nocolor}"
}

## show commits, let user input a commit, check it out and 
## rsync it from backup dir to jenkins home dir 
gitCheckoutCommit(){
    echo_green "Showing you available git commits"
    echo; git  log --oneline| more -7; echo
    echo -n "Enter your commit: "
    read SHA
    #check if SHA is a valid commit:
    set +e
    gitlog=$(git log $SHA)
    set +e
    if [[ ! "$gitlog" == "" ]]; then
      echo -e "${blue}"; git  log $SHA -1; echo -ne "${nocolor}"
      echo -n "Do you want to revert to the commit $SHA ? [n|Y]"    
      read input
      if [[ "$input" == "y" || "$input" == "Y" ]]; then
        echo_green "Reverting to commit $SHA"
        export COMMIT_SHA=$SHA
        $gitu checkout $SHA
      else
        echo_blue "Keeping it unchanged!"
        echo -ne "${nocolor}"
        exit -1
      fi
    else
      echo_red "ERROR: $SHA is not a correct git commit!"
      echo -ne "${nocolor}"
      exit -1
    fi
}

## check out master again to be ok with remote git repo
gitCheckoutMaster() {
    echo_green "Checking out master again"
    $gitu checkout master
}
