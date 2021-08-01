#!/usr/bin/env bash

. ../bash-toolbelt/toolbelt.sh
Toolbelt_dot ../bash-tally/tally.sh ./backup_logs.log 'log-script-begin'

Toolbelt_readConfig ./.env

if [ $? != 0 ]
then
  echo "Error with Toolbelt_readConfig"
  exit 1
fi

declare -A ELYSIUM_ENV  #this is an array

Toolbelt_parseJSON ${ELYSIUM_ENV_JSON_PATH} ELYSIUM_ENV
if [ $? != 0 ]
then
  echo "Error with Toolbelt_parseJSON"
  exit 1
fi

_remoteBackupRootRealpath=$(realpath "${ELYSIUM_ENV[backupsDirs:remoteBackupRoot]}")
if [[ ! -d "${ELYSIUM_ENV[backupsDirs:remoteBackupRoot]}" ]]
then
echo "ERROR:  remoteBackupRoot is not accessible, make sure it exists. Path: $_remoteBackupRootRealpath."
Tally_error "remoteBackupRoot is not accessible, make sure it exists. Path: $_remoteBackupRootRealpath";
exit 1
elif [ ! -w "${ELYSIUM_ENV[backupsDirs:remoteBackupRoot]}" ]
then
  echo "ERROR:  remoteBackupRoot is not writable Path: $_remoteBackupRootRealpath."
  Tally_error "remoteBackupRoot is not writable Path: $_remoteBackupRootRealpath";
  exit 1
else
   Tally_info "remoteBackupRoot is OK $_remoteBackupRootRealpath";
fi

remoteBackupRoot="${ELYSIUM_ENV[backupsDirs:remoteBackupRoot]}"

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

