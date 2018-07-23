#!/usr/bin/env bash

#-----------------------------------------
# General
#FOAMVersion=AEG. Defined in the main calling program. Maybe remove.
#thisScript=AEG. Defined in the main calling program. Maybe remove.

#-----------------------------------------
#Names for the case
#folderType=AEG. Defined in the main calling program. Maybe remove.
#dimensionType=AEG. Defined in the main calling program. Maybe remove.
#domainType=AEG. Defined in the main calling program. Maybe remove.
#arrayType=AEG. Defined in the main calling program. Maybe remove.
#arrayDensity=AEG. Defined in the main calling program. Maybe remove.
#Reynolds=AEG. Defined in the main calling program. Maybe remove.

#-----------------------------------------
#Working Directories
#baseDir=AEG. Defined in the main calling program.
#workingDir=AEG. Defined in the main calling program.
#GeneralDir=AEG. Defined in the main calling program. Maybe remove.
#dirToBackup=AEG. Defined in the main calling program.
functionsD=/home/espinosa/bash_functions
backupFunctionsD=/home/espinosa/bin/rsyncScripts
hereD=$PWD

#-----------------------------------------
# Number of last times to reconstruct
#Nlast=AEG. Defined in the main calling program

#-----------------------------------------
#Log files names
dateString=$(date +%Y-%m-%d.%H.%M.%S)
logRun="$hereD/log_runBackup_${dateString}"
logJob="$hereD/log_jobBackup_${dateString}"

#-----------------------------------------
#Sourcing the floating point function defininitons
#Global variable to be used as scale=$float_scale in bc floatingPoint functions
float_scale=4
archi=$functionsD/floatingPoint
if [ -e $archi ]; then
   echo "Found floatingPoint functions" | tee -a ${logJob}
   source $archi
else
   echo "NOT FOUND floatingPoint functions" | tee -a ${logJob}
fi

#-----------------------------------------
#Sourcing the backup function defininitons
archi=$backupFunctionsD/myBackupFunctions.sh
if [ -e $archi ]; then
   echo "Found backup functions" | tee -a ${logJob}
   source $archi
else
   echo "NOT FOUND backup functions" | tee -a ${logJob}
   exit
fi

#-----------------------------------------
#Setting the number of tries and pausing variables as rsync is failing sometimes
MaxTries=10
pausingMinutes=2


#-------------------------------------------
#The path of the case Dir, and Starting
caseDir=$baseDir/$workingDir
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "CaseDir=${caseDir}" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "Starting backup procedure"
echo "#--------------------------------------------------" | tee -a ${logJob}


#-----------------------------------------
#Backing up the whole indicated directory
cd $hereD
#The Whole Directory to Backup ...
bDir=$dirToBackup
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "Whole Directory bDir=${bDir}" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "Starting backup procedure"
echo "#--------------------------------------------------" | tee -a ${logJob}
basicBackup

#-----------------------------------------
#End
echo "Backup of case ${caseDir} Finished" | tee -a ${logJob}
