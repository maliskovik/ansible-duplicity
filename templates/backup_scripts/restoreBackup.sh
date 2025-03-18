#!/bin/bash

################################################################################
#                                                                              #
#                                 {o,o}                                        #
#                                 |)__)                                        #
#                                 -"-"-                                        #
#                                                                              #
################################################################################
#
# Restore a Duplicity backup
#
################################---VARS---######################################
# Script usage ./restore_backup  [--path <desired_path_for_restored_files>] [--file <path to specific file to restore>] [--time <time of the backup to use> ] <config_file>

# Current directory
SCRIPT_DIR=$(dirname ${0})

# Argument parsing
while [ $# -gt 0 ]; do
  case "$1" in
    --path)
      RESTORE_DESTINATION_DIR=$2
      shift
      ;;
    --file)
      FILE_TO_RESTORE=$2
      shift
      ;;
    --time)
      RESTORE_TIMESTAMP=$2
      shift
      ;;
    *)
    if [ ! -f "$1" ]; then
      echo "Error: Config file path not provided or invalid"
      exit 1
    fi
    BACKUP_CONFIG=$1
      ;;
  esac
  shift
done

# Eval backup config variables
. "${SCRIPT_DIR}/${BACKUP_CONFIG}"
. "${SCRIPT_DIR}/${BACKUP_BACKEND}.cf"

# Default values
: ${RESTORE_DESTINATION_DIR:=/tmp/restore/$(date +%Y%m%d%H%M%S1)_${BACKUP_NAME}}
: ${RESTORE_TIMESTAMP:=now}
export PASSPHRASE="${GPG_PASSPHRASE}"

################################################################################

##############################---FUNCTIONS---###################################

# Function to restore a specific file
#
restore_backup() {
  echo "Starting backup restore"
  echo "Target time for restore: ${RESTORE_TIMESTAMP}"
  if [ -z "$FILE_TO_RESTORE" ]; then
      echo "Restoring entire backup"
      duplicity restore --time "${RESTORE_TIMESTAMP}" "${DESTINATION_URL}" "${RESTORE_DESTINATION_DIR}"
  else
    echo "Restoring file ${FILE_TO_RESTORE}"
    duplicity restore --time "${RESTORE_TIMESTAMP}" --path-to-restore "${FILE_TO_RESTORE}" "${DESTINATION_URL}" "${RESTORE_DESTINATION_DIR}/${FILE_TO_RESTORE}"
  fi
  echo "Restored backup to ${RESTORE_DESTINATION_DIR}"
}

cleanup() {
  echo "Cleaning up"
  unset PASSPHRASE
}

################################################################################

#################################---EXEC---#####################################

restore_backup
cleanup

################################################################################
