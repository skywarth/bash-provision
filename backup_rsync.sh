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



_localBackupRootRealpath=$(realpath "${ELYSIUM_ENV[backupsDirs:localBackupRoot]}")
if [[ ! -d "${ELYSIUM_ENV[backupsDirs:localBackupRoot]}" ]]
then
echo "ERROR:  localBackupRoot is not accessible, make sure it exists. Path: $_localBackupRootRealpath."
Tally_error "localBackupRoot is not accessible, make sure it exists. Path: $_localBackupRootRealpath";
exit 1
elif [ ! -w "${ELYSIUM_ENV[backupsDirs:localBackupRoot]}" ]
then
  echo "ERROR:  localBackupRoot is not writable Path: $_localBackupRootRealpath."
  Tally_error "localBackupRoot is not writable Path: $_localBackupRootRealpath";
  exit 1
else
   Tally_info "localBackupRoot is OK $_localBackupRootRealpath";
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


host=$(hostname);
excludePath='./rsync-exclude.txt'


today=$(date +"%Y%m%d")
backupName="${today}_${host}_rsync"

localBackupRoot="${ELYSIUM_ENV[backupsDirs:localBackupRoot]}"
localBackupFullPath="${localBackupRoot}/${backupName}"

remoteBackupRoot="${ELYSIUM_ENV[backupsDirs:remoteBackupRoot]}"
remoteBackupHostRoot="${remoteBackupRoot}/${host}"



if [ -d $localBackupRoot ]
then
echo 'local backup path exists.'
Tally_info 'local_backup path already exists'
else
Tally_info 'creating local_backup path'
echo $localBackupRoot
mkdir -p $localBackupRoot
fi

if [ -d "${localBackupFullPath}" ]
then
echo "backup folder already exists."
Tally_warn 'Same backup folder for today already exists.'
fi


echo "now running rsync command"
rsync -aH --delete --info=progress2 --info=name0 --exclude-from="${excludePath}" / "${localBackupFullPath}/"
echo "completed"
Tally_info 'RSYNC command done.'

echo "now creating tar of rsync"
tar -cf "${localBackupRoot}/${backupName}.tar" -C "${localBackupFullPath}" .
echo "tar ready"
Tally_info 'TAR process complete'

Tally_info 'Starting to copy TAR to remote'
echo "copying rsync tar to remote"
cp "${localBackupRoot}/${backupName}.tar" "${remoteBackupHostRoot}/rsync/"
echo "done"

echo "deleting the created backup folder"
rm -r "${localBackupFullPath}"
echo "deleted"
Tally_info 'Deleted the local rsync folder for today.'

exit
