#!/usr/bin/env bash

#FUNCTIONS
#-------------------------------------------
#Defining the basic backup function
basicBackup() {
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "CaseDir=${caseDir}" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "Backing up the ${bDir} Dir" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
#sshpass -p $pwRemote rsync --stats --progress -auvzrhs espinosa@hpc-data.pawsey.org.au:$caseDir/$bDir . | tee -a ${logJob}
if [ -z "$bDir" ]; then
   echo "bDir=${bDir} then nothing is done" | tee -a ${logJob}
else
   if [ "$bDir" = " " ]; then
      echo "bDir=${bDir} then nothing is done" | tee -a ${logJob}
   else
      for ((jTries=0; jTries<$MaxTries; jTries++))
      do
         echo "bDir=${bDir} backup will be done, try ${jTries}" | tee -a ${logJob}
         rsync --stats --progress -auvzrhs espinosa@hpc-data.pawsey.org.au:$caseDir/$bDir . | tee -a ${logJob}
         errorRsync=${PIPESTATUS[0]}
         if [ "$errorRsync" -eq 0 ] ; then
           echo "rsync passed with error code ${errorRsync}" | tee -a ${logJob}
           echo "Keep going into the rest of the script" | tee -a ${logJob}
           jTries=$MaxTries
         elif [ "$errorRsync" -eq 23 ] ; then
           echo "rsync failed with error code ${errorRsync}" | tee -a ${logJob}
           echo "Aborting the backup of ${bDir}" | tee -a ${logJob}
           echo "Keep going into the rest of the script" | tee -a ${logJob}
           jTries=$MaxTries
         else
           echo "rsync failed with code ${errorRsync}" | tee -a ${logJob}
           echo "trying again in ${pausingMinutes} minutes" | tee -a ${logJob}
           sleep "${pausingMinutes}m"
         fi
      done
   fi
fi
}

#-------------------------------------------
#Defining the basic backup function with Ignore Existing Files
basicBackupIgnoreExisting() {
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "CaseDir=${caseDir}" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "Backing up the ${bDir} Dir" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
#sshpass -p $pwRemote rsync --stats --progress -auvzrhs espinosa@hpc-data.pawsey.org.au:$caseDir/$bDir . | tee -a ${logJob}
if [ -z "$bDir" ]; then
   echo "bDir=${bDir} then nothing is done" | tee -a ${logJob}
else
   if [ "$bDir" = " " ]; then
      echo "bDir=${bDir} then nothing is done" | tee -a ${logJob}
   else
      for ((jTries=0; jTries<$MaxTries; jTries++))
      do
         echo "bDir=${bDir} backup will be done, try ${jTries}" | tee -a ${logJob}
         rsync --ignore-existing --stats --progress -auvzrhs espinosa@hpc-data.pawsey.org.au:$caseDir/$bDir . | tee -a ${logJob}
         errorRsync=${PIPESTATUS[0]}
         if [ "$errorRsync" -eq 0 ] ; then
           echo "rsync passed with error code ${errorRsync}" | tee -a ${logJob}
           echo "Keep going into the rest of the script" | tee -a ${logJob}
           jTries=$MaxTries
         elif [ "$errorRsync" -eq 23 ] ; then
           echo "rsync failed with error code ${errorRsync}" | tee -a ${logJob}
           echo "Aborting the backup of ${bDir}" | tee -a ${logJob}
           echo "Keep going into the rest of the script" | tee -a ${logJob}
           jTries=$MaxTries
         else
           echo "rsync failed with code ${errorRsync}" | tee -a ${logJob}
           echo "trying again in ${pausingMinutes} minutes" | tee -a ${logJob}
           sleep "${pausingMinutes}m"
         fi
      done
   fi
fi
}

#-------------------------------------------
#Defining the basic backup function with Backing up only Files that have changed in size
basicBackupSizeOnly() {
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "CaseDir=${caseDir}" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "Backing up the ${bDir} Dir" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
#sshpass -p $pwRemote rsync --stats --progress -auvzrhs espinosa@hpc-data.pawsey.org.au:$caseDir/$bDir . | tee -a ${logJob}
if [ -z "$bDir" ]; then
   echo "bDir=${bDir} then nothing is done" | tee -a ${logJob}
else
   if [ "$bDir" = " " ]; then
      echo "bDir=${bDir} then nothing is done" | tee -a ${logJob}
   else
      for ((jTries=0; jTries<$MaxTries; jTries++))
      do
         echo "bDir=${bDir} backup will be done, try ${jTries}" | tee -a ${logJob}
         rsync --size-only --stats --progress -auvzrhs espinosa@hpc-data.pawsey.org.au:$caseDir/$bDir . | tee -a ${logJob}
         errorRsync=${PIPESTATUS[0]}
         if [ "$errorRsync" -eq 0 ] ; then
           echo "rsync passed with error code ${errorRsync}" | tee -a ${logJob}
           echo "Keep going into the rest of the script" | tee -a ${logJob}
           jTries=$MaxTries
         elif [ "$errorRsync" -eq 23 ] ; then
           echo "rsync failed with error code ${errorRsync}" | tee -a ${logJob}
           echo "Aborting the backup of ${bDir}" | tee -a ${logJob}
           echo "Keep going into the rest of the script" | tee -a ${logJob}
           jTries=$MaxTries
         else
           echo "rsync failed with code ${errorRsync}" | tee -a ${logJob}
           echo "trying again in ${pausingMinutes} minutes" | tee -a ${logJob}
           sleep "${pausingMinutes}m"
         fi
      done
   fi
fi
}

#-------------------------------------------
#Defining the basic putup function
basicPutup() {
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "CaseDir=${casoDir}" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "Putting up the ${bDir} Dir into ${rDir}" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
#sshpass -p $pwRemote rsync --stats --progress -auvzrhs ./$bDir espinosa@hpc-data.pawsey.org.au:$caseDir | tee -a ${logJob}
if [ -z "$bDir" ]; then
   echo "bDir=${bDir} then nothing is done" | tee -a ${logJob}
else
   if [ "$bDir" = " " ]; then
      echo "bDir=${bDir} then nothing is done" | tee -a ${logJob}
   else
      for ((jTries=0; jTries<$MaxTries; jTries++))
      do
         echo "bDir=${bDir} putup will be done, try ${jTries}" | tee -a ${logJob}
         rsync --stats --progress -auvzrhs $casoDir/$bDir espinosa@hpc-data.pawsey.org.au:$caseDir/$rDir | tee -a ${logJob}
         errorRsync=${PIPESTATUS[0]}
         if [ "$errorRsync" -eq 0 ] ; then
           echo "rsync passed with error code ${errorRsync}" | tee -a ${logJob}
           echo "Keep going into the rest of the script" | tee -a ${logJob}
           jTries=$MaxTries
         elif [ "$errorRsync" -eq 23 ] ; then
           echo "rsync failed with error code ${errorRsync}" | tee -a ${logJob}
           echo "Aborting the backup of ${bDir}" | tee -a ${logJob}
           echo "Keep going into the rest of the script" | tee -a ${logJob}
           jTries=$MaxTries
         else
           echo "rsync failed with code ${errorRsync}" | tee -a ${logJob}
           echo "trying again in ${pausingMinutes} minutes" | tee -a ${logJob}
           sleep "${pausingMinutes}m"
         fi
      done
   fi
fi
}

#-------------------------------------------
#Defining the basic putup function with Ignore Existing files
basicPutupIgnoreExisting() {
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "CaseDir=${casoDir}" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "Putting up the ${bDir} Dir into ${rDir}" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
#sshpass -p $pwRemote rsync --stats --progress -auvzrhs ./$bDir espinosa@hpc-data.pawsey.org.au:$caseDir | tee -a ${logJob}
if [ -z "$bDir" ]; then
   echo "bDir=${bDir} then nothing is done" | tee -a ${logJob}
else
   if [ "$bDir" = " " ]; then
      echo "bDir=${bDir} then nothing is done" | tee -a ${logJob}
   else
      for ((jTries=0; jTries<$MaxTries; jTries++))
      do
         echo "bDir=${bDir} putup will be done, try ${jTries}" | tee -a ${logJob}
         rsync --ignore-existing --stats --progress -auvzrhs $casoDir/$bDir espinosa@hpc-data.pawsey.org.au:$caseDir/$rDir | tee -a ${logJob}
         errorRsync=${PIPESTATUS[0]}
         if [ "$errorRsync" -eq 0 ] ; then
           echo "rsync passed with error code ${errorRsync}" | tee -a ${logJob}
           echo "Keep going into the rest of the script" | tee -a ${logJob}
           jTries=$MaxTries
         elif [ "$errorRsync" -eq 23 ] ; then
           echo "rsync failed with error code ${errorRsync}" | tee -a ${logJob}
           echo "Aborting the backup of ${bDir}" | tee -a ${logJob}
           echo "Keep going into the rest of the script" | tee -a ${logJob}
           jTries=$MaxTries
         else
           echo "rsync failed with code ${errorRsync}" | tee -a ${logJob}
           echo "trying again in ${pausingMinutes} minutes" | tee -a ${logJob}
           sleep "${pausingMinutes}m"
         fi
      done
   fi
fi

#-------------------------------------------
#Defining the basic putup function with only files that have changed in size
basicPutupSizeOnly() {
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "CaseDir=${casoDir}" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "Putting up the ${bDir} Dir into ${rDir}" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
#sshpass -p $pwRemote rsync --stats --progress -auvzrhs ./$bDir espinosa@hpc-data.pawsey.org.au:$caseDir | tee -a ${logJob}
if [ -z "$bDir" ]; then
   echo "bDir=${bDir} then nothing is done" | tee -a ${logJob}
else
   if [ "$bDir" = " " ]; then
      echo "bDir=${bDir} then nothing is done" | tee -a ${logJob}
   else
      for ((jTries=0; jTries<$MaxTries; jTries++))
      do
         echo "bDir=${bDir} putup will be done, try ${jTries}" | tee -a ${logJob}
         rsync --size-only --stats --progress -auvzrhs $casoDir/$bDir espinosa@hpc-data.pawsey.org.au:$caseDir/$rDir | tee -a ${logJob}
         errorRsync=${PIPESTATUS[0]}
         if [ "$errorRsync" -eq 0 ] ; then
           echo "rsync passed with error code ${errorRsync}" | tee -a ${logJob}
           echo "Keep going into the rest of the script" | tee -a ${logJob}
           jTries=$MaxTries
         elif [ "$errorRsync" -eq 23 ] ; then
           echo "rsync failed with error code ${errorRsync}" | tee -a ${logJob}
           echo "Aborting the backup of ${bDir}" | tee -a ${logJob}
           echo "Keep going into the rest of the script" | tee -a ${logJob}
           jTries=$MaxTries
         else
           echo "rsync failed with code ${errorRsync}" | tee -a ${logJob}
           echo "trying again in ${pausingMinutes} minutes" | tee -a ${logJob}
           sleep "${pausingMinutes}m"
         fi
      done
   fi
fi

#-------------------------------------------
#Defining the non trajectories backup function (for the motile particle experiments)
noTrajectoriesBackup() {
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "CaseDir=${caseDir}" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "Backing up the ${bDir} Dir" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
#sshpass -p $pwRemote rsync --stats --progress -auvzrhs espinosa@hpc-data.pawsey.org.au:$caseDir/$bDir . | tee -a ${logJob}
if [ -z "$bDir" ]; then
   echo "bDir=${bDir} then nothing is done" | tee -a ${logJob}
else
   if [ "$bDir" = " " ]; then
      echo "bDir=${bDir} then nothing is done" | tee -a ${logJob}
   else
      for ((jTries=0; jTries<$MaxTries; jTries++))
      do
         echo "bDir=${bDir} backup will be done, try ${jTries}" | tee -a ${logJob}
         rsync --stats --progress -auvzrhs --exclude CompleteTrajectories/ espinosa@hpc-data.pawsey.org.au:$caseDir/$bDir . | tee -a ${logJob}
         errorRsync=${PIPESTATUS[0]}
         if [ "$errorRsync" -eq 0 ] ; then
           echo "rsync passed with error code ${errorRsync}" | tee -a ${logJob}
           echo "Keep going into the rest of the script" | tee -a ${logJob}
           jTries=$MaxTries
         elif [ "$errorRsync" -eq 23 ] ; then
           echo "rsync failed with error code ${errorRsync}" | tee -a ${logJob}
           echo "Aborting the backup of ${bDir}" | tee -a ${logJob}
           echo "Keep going into the rest of the script" | tee -a ${logJob}
           jTries=$MaxTries
         else
           echo "rsync failed with code ${errorRsync}" | tee -a ${logJob}
           echo "trying again in ${pausingMinutes} minutes" | tee -a ${logJob}
           sleep "${pausingMinutes}m"
         fi
      done
   fi
fi
}
