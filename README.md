# Backup Script for Jenkins Configuration
## What it does?
 - sync `JENKINS_HOME` to `BACKUP_DIR`
 - commit file changes (addition/deletion)
 - log action to file `backup.log` in `JENKINS_LOG` directory

### `backup_to_git.sh`  
Backup `JENKINS_HOME` by syncing it to 
`BACKUP_DIR` and commit the diffs into git. 

### `restore_from_git.sh` 
Restore an older version of `JENKINS_HOME` by checking out
an old commit into `BACKUP_DIR` and `rsync` this to `JENKINS_HOME`. 
Old commits are listed to be selected as user input.

### Local git repo
`BACKUP_DIR` is the folder of the local git repository keeping the 
changes of Jenkins configuration.

## Variables
 - `JENKINS_HOME` jenkins home directory, set in `/etc/default/jenkins`
 - `GIT_USER` name of the commiter
 - `GIT_EMAIL` email of the commiter
 - `BACKUP_DIR` keeps a synced copy of `JENKINS_HOME` in local git repo
 - `COMMIT_MESSAGE` 

## Usage
### Prerequesites
We assume a working git repo in `BACKUP_DIR` and
 - user `jenkins` to have credentials to *write to `BACKUP_DIR`* 
 - user `jenkins` to have credentials to *pull/push the local git repo in `BACKUP_DIR`*
 - user `jenkins` to *start/restart service jenkins*

To backup Jenkins, type:
```sh
sudo -u jenkins /path/to/backup_to_git.sh "Commit message"
```

To restore Jenkins, type:
```sh
sudo -u jenkins /restore_from_git.sh
LOGGING TO /var/log/jenkins/backup.log
[Wed Feb  3 14:34:54 UTC 2016]  
[Wed Feb  3 14:34:54 UTC 2016] Starting to restore Service Jenkins on AMI i-0f83ec56e936ca5ad 
[Wed Feb  3 14:34:54 UTC 2016] Showing you available git commits 

f22178d jenkins: Job [Test-Colorize2] hierarchy renamed from [Test Colorize2] to [Test-Colorize2]
bacdb57 jenkins: Job [Test Colorize2] configuration updated
b2cd8f0 jenkins: Job [Test-Colorize] hierarchy renamed from [Test Colorize] to [Test-Colorize]
17734e4 jenkins: Job [Test Colorize] configuration updated
b62547b jenkins: User [Michael Turner] configuration updated
5dbdf91 jenkins: Job [Docker-Build-Apache] configuration updated
0121d30 jenkins: Plugin configuration files updated

Enter your commit:
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
