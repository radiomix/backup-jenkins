#!/bin/bash
#
#
#

export AMI_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id/)

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
  echo_blue "Starting to backup Service Jenkins on AMI $AMI_ID"
  if [[ -d $BACKUP_DIR && -O $BACKUP_DIR ]]; then
    echo_green "Stoping Service Jenkins" 
    echo_green "$(service jenkins stop)"
    # rsync to backup dir 
    echo_green "Syncing $JENKINS_HOME to $BACKUP_DIR"
    echo_green "$(rsync -avHx $JENKINS_HOME/* $BACKUP_DIR)"
    echo_green "Starting Service Jenkins" 
    echo_green "$(service jenkins start)"
  else 
    echo_red "ERROR: Directory $BACKUP_DIR does not exist or is not writable!"
    return -1 
  fi
}
## rsync from back directory
syncFromBackup() {
  echo_blue "Starting to restore Service Jenkins on AMI $AMI_ID"
  if [[ -d $BACKUP_DIR && -O $BACKUP_DIR ]]; then
    echo_green "Stoping Service Jenkins" 
    echo_green "$(service jenkins stop)"
    # rsync from backup dir
    echo_green "Syncing $JENKINS_HOME from $BACKUP_DIR"
    echo_green "$(rsync -avHx $BACKUP_DIR/* $JENKINS_HOME)"
    echo_green "Starting Service Jenkins" 
    echo_green "$(service jenkins start)"
  else 
    echo_red "ERROR: Directory $BACKUP_DIR does not exist or is not writable!"
    return -1 
  fi
}

## pushing it all to the git repo
gitCommitPUsh() {
    ## add a date file, so we have anything to commit
    echo $COMMIT_MESSAGE >> $LOGFILE

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

gitCheckoutCommit(){
    git config --global user.name "$GIT_USER"
    git config --global user.email "$GIT_EMAIL"
    echo_green "Showing you available git commits"
    echo; git  log --oneline; echo
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
        git checkout $SHA
      else
        echo_blue "Keeping it unchanged!"
        exit -1
      fi
    else
      echo_red "ERROR: $SHA is not a correct git commit!"
      exit -1
    fi
}
