#!/usr/bin/env bash

. ./bash-toolbelt/toolbelt.sh
Toolbelt_dot ./bash-tally/tally.sh ./backup_logs.log

Toolbelt_readConfig ../.env
# remoteBackupRoot should be loaded from .env after this step

if [[ -f "$FILE" ]]
then
echo ERROR: .env file not found at "$(realpath ../.env)".
Tally_error ".env file not found at $(realpath ../.env)";
exit 1
elif [ -z "${remoteBackupRoot+xxx}" ]
then
echo ERROR: remoteBackupRoot VAR is not set in .env file.
Tally_error "remoteBackupRoot VAR is not set in .env file.";
exit 1
fi



host=$(hostname);

today=$(date +"%Y%m%d")
backupName="${today}_${host}_image.img"

remoteBackupHostRoot="${remoteBackupRoot}/${host}"
remoteBackupImageFolder="${remoteBackupHostRoot}/image"

if [ ! -d "${remoteBackupImageFolder}" ]
then
echo "dir doesn't exists, creating"
mkdir -p remoteBackupImageFolder
fi
echo "beginning dd"
dd bs=4M if=/dev/mmcblk0 of="${remoteBackupImageFolder}/${backupName}" status=progress
echo "image created"
exit

