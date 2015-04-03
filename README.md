# Backup Script for Jenkins

## Usage

We need to put below script in Job Configuration on Jenkins.
If there are any changes on configuration, new config file will be committed to the specific repository with commit message in template: `Build Configuration Backup for REPO_NAME YYYY-MM-DD`

```sh
JOB_REPOSITORY=
REPOSITORY_ACCOUNT=
REPOSITORY_PASSWORD=
export JENKINS_HOME=$JENKINS_HOME
bash backup.sh $JOB_REPOSITORY $REPOSITORY_ACCOUNT $REPOSITORY_PASSWORD
```

### Sources
The orginal idea is from https://github.com/nghiant2710/jenkins-backup
and.https://github.com/luisalima/backup_jenkins_config 

