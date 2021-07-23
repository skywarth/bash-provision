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
excludePath='./rsync-exclude.txt'
localBackupPath='/media/local_backups'

today=$(date +"%Y%m%d")
backupName="${today}_${host}_rsync"

backupFullPath="${localBackupPath}/${backupName}"

remoteBackupHostRoot="${remoteBackupRoot}/${host}"

if [ -d $localBackupPath ]
then
echo 'local backup path exists.'
Tally_info 'local_backup path already exists'
else
Tally_info 'creating local_backup path'
echo $localBackupPath
mkdir -p $localBackupPath
fi

if [ -d "${backupFullPath}" ]
then
echo "backup folder already exists."
Tally_warn 'Same backup folder for today already exists.'
fi


echo "now running rsync command"
rsync -aH --delete --info=progress2 --info=name0 --exclude-from="${excludePath}" / "${backupFullPath}/"
echo "completed"
Tally_info 'RSYNC command done.'

echo "now creating tar of rsync"
tar -cf "${localBackupPath}/${backupName}.tar" -C "${backupFullPath}" .
echo "tar ready"
Tally_info 'TAR process complete'

Tally_info 'Starting to copy TAR to remote'
echo "copying rsync tar to remote"
cp "${localBackupPath}/${backupName}.tar" "${remoteBackupHostRoot}/rsync/"
echo "done"

echo "deleting the created backup folder"
rm -r "${backupFullPath}"
echo "deleted"
Tally_info 'Deleted the local rsync folder for today.'

exit
