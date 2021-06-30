#!/bin/bash

################################################################################
#                                                                              #
#                                 {o,o}                                        #
#                                 |)__)                                        #
#                                 -"-"-                                        #
#                                                                              #
################################################################################
#
# Looks at backup configs and list backup chains
#
################################################################################

##############################---FUNCTIONS---###################################

function runTests() {
  cd ~
  # Disable duplicity runs
  mv /etc/cron.d/duplicity duplicity_cronjob
  /opt/backup/checkFileList
  /opt/backup/checkChains
  /opt/backup/checkBackupIntegrity
  # Re-enable duplicity
  mv duplicity_cronjob /etc/cron.d/duplicity
}

################################################################################

###############################---EXECUTION---##################################

runTests

################################################################################
