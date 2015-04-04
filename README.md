# Backup Script for Jenkins
We backup the jenkins home directory `$JENKINS_HOME` by syncing it to 
a backup directory and pushing the diffs into a git repository.


## What it does?
 - sync the jenkins home directory into a backup directory
 - add the current date to file `date.txt` 
 - adds new files to git
 - commit new files
 - push delta into git repo 

## Variables
 - `JENKINS_HOME` jenkins home directory, set in `/etc/default/jenkins`
 - `GIT_USER` name of the commiter
 - `GIT_EMAIL` email of the commiter
 - `BACKUP_DIR` keeps a synced copy of `JENKINS_HOME`, gets pushed into the git repository
 - `COMMIT_MESSAGE` 

## Usage

```sh
sudo ./backup_to_git.sh
```

### Sources
The orginal idea is from 
 - https://github.com/nghiant2710/jenkins-backup and
 - https://github.com/luisalima/backup_jenkins_config 


### Files
- functions.sh provides functions 
- backup_to_git.sh does `rsync` from `JENKINS_HOME` to `BACKUP_DIR` and pushes new files into the git repo
