# DUPLICITY
The backup utility
The backups configs should be placed in files/backupConfigs/<hostname>

## Mandatory variables
* duplicity_sftp_username - username for the backup location(remote)
* duplicity_sftp_destination - hostname of the backup destination

## Optional variables

* backup_directory - directory with all the backup configs
* duplicity_log_directory - where logs of individual backups are stored
* duplicity_log: /var/log/duplicity.log - duplicity log

# Backup scripts

## Intro
Each backup uses several files.

* runBackup - Iterates over all conf files and runs them one by one.
* scripts - There are several scripts for different backups:

    * backupDockerDirectory - Make a backup of a directory in a docker container
    * backupLocalDirectory - Make a backup od a directory on the localhost
    * backupDockerPG - Make a backup od a postgresql database running in a
    docker container
    * backupDockerRethinkDB - Make a backup of a rethink database running in
    a docker container.
    * backupLocalMysql - Make a backup od a mysql database on localhost
* runDuplicity - actually runs the duplicity. This script is included in all
profiles
* profiles - Each backup is defined in a profile config file. There are
templates available in the templates directory. Choose one depending on the
kind of backup you are performing.

## Requirements
Following packages need to be installed
* duplicity
* python-paramiko

## Variables

* BACKUP_NAME - string in snake case. Name of the backup.
* DESTINATION_DIRECTORY - string - Path to the directory to backup.
* FULL_BACKUP_INTERVAL - duplicity argument. Define the interval in which to
perform a full backup(start new backup chain). Examples: "1Y", "2M",10D.
The string should be like defined in the duplicity man page:
> An interval, which is a number followed by one of the characters s, m, h, D,
 W, M, or Y (indicating seconds, minutes, hours, days, weeks, months, or years
  respectively), or a series of such pairs. In this case the string refers to
  the time that preceded the current time by the length of the interval.
  For instance, "1h78m" indicates the time that was one hour and 78 minutes ago.
   The calendar here is unsophisticated: a month is always 30 days, a year is
    always 365 days, and a day is always 86400 seconds.

* BACKUP_INTERVAL - integer( >0) - The backup will trigger every
HOURS % BACKUP_INTERVAL. So for example if you want to backup once a day,
set to 24 hours. 0 is NOT VALID!
* SETS_TO_KEEP - integer - How many backup chains should be kept.
If you just want to save latest files, set it to 2, if you prefer to keep
some history then set it to the
"period you want to keep" / FULL_BACKUP_INTERVAL.
* CONTAINER -string - Name of the container to connect to ( when backing up
    content from a docker container)

## Restoring data.
To restore data run duplicity restore.
```
duplicity restore --time=<time format> <backup-location> <restore-location>
```
example:
```
duplicity restore --time='2014-05-21T12:00:00+01:00' sftp://u123451@backup_server/db_backup /tmp
```
>NOTE: Restore location must be unique.

time format looks like this: 'YYYY-MM-DDTHH:mm:SS+HH:mm'

example:
```
2014-05-21T12:00:00+01:00
```
### Restoring postgresql database in a docker container

* drop database
```
docker exec -i <postgres container name> psql -U postgres -h localhost postgres -c "drop database <database name>"
```
* create database
```
docker exec -i <postgres container name> psql -U postgres -h localhost postgres -c "create database <database name>"
```
* import stuff
```
docker exec -i <postgres container name> psql -U postgres -h localhost <database name> < <backup file>
```

## Setting up public key authentication
Setup public key authentication on hetzner backup:

* Generate your key (if you don't have one yet)
```
ssh-keygen
```
* gen
```
ssh-keygen -e -f .ssh/id_rsa.pub | grep -v "Comment:" > .ssh/id_rsa_rfc.pub
```
* sftp to the backup host and create .ssh directory
```
sftp <host>
mkdir .ssh
```

* Copy the pub key to the backup host.
```
scp id_rsa_rfc.pub <backup host>:/.ssh/authorized_keys
```
