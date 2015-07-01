# Backup Script for Jenkins
We backup `JENKINS_HOME` by syncing it to 
`BACKUP_DIR` and pushing the diffs into a git repository. 
We restore an older version of `JENKINS_HOME` by checking out
an old commit into `BACKUP_DIR` and `rsync` this with `JENKINS_HOME`. 


## What it does?
 - sync the jenkins home directory into a backup directory
 - adds new files to git
 - commit new files
 - push delta into git repo 
 - add the action to file `backup.log` in `JENKINS_LOG` directory

## Variables
 - `JENKINS_HOME` jenkins home directory, set in `/etc/default/jenkins`
 - `GIT_USER` name of the commiter
 - `GIT_EMAIL` email of the commiter
 - `BACKUP_DIR` keeps a synced copy of `JENKINS_HOME`, gets pushed into the git repository
 - `COMMIT_MESSAGE` 

## Usage
### Prerequesites
We assume a working git repo in `BACKUP_DIR` and
 - user `jenkins` to have credentials to *write to `BACKUP_DIR`* 
 - user `jenkins` to have credentials to *pull/push the local git repo in `BACKUP_DIR`*
 - user `jenkins` can *start/restart service jenkins*

To backup Jenkins, type:
```sh
sudo -u jenkins /path/to/backup_to_git.sh
```

To restore Jenkins, type:
```sh
sudo -u jenkins /restore_from_git.sh
```

### Sources
The orginal idea is from 
 - https://github.com/nghiant2710/jenkins-backup and
 - https://github.com/luisalima/backup_jenkins_config 


### Files
- **functions.sh** provides functions 
- **backup_to_git.sh** 
  * `rsync` from `JENKINS_HOME` to `BACKUP_DIR` 
  * commit new files into the git repo
- **push_backup_to_remote.sh** 
  * push commits into the remote git repo
- **restore_from_git.sh** 
  * show recent commits 
  * let user select a commit 
  * check out this commit into the backup directory
  * `rsync` from `BACKUP_DIR` to `JENKINS_HOME`
