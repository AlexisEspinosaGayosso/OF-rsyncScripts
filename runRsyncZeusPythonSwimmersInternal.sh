#!/usr/bin/env bash

#-----------------------------------------
# General
#FOAMVersion=AEG. Defined in the main calling program
#thisScript=AEG. Defined in the main calling program

#-----------------------------------------
#Names for the case
#folderType=AEG. Defined in the main calling program
#dimensionType=AEG. Defined in the main calling program
#domainType=AEG. Defined in the main calling program
#arrayType=AEG. Defined in the main calling program
#arrayDensity=AEG. Defined in the main calling program
#Reynolds=AEG. Defined in the main calling program

#-----------------------------------------
#Working Directories
baseDir=/scratch/pawsey0106/espinosa/Python

#workingDir=AEG. Defined in the main calling program
#GeneralDir=AEG. Defined in the main calling program
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
#Generating a list of existing time directories trying 10 times
for ((jTries=0; jTries<$MaxTries; jTries++))
do
   cd $hereD
   echo "Reading a list of existing time directories" | tee -a ${logJob}
   echo "In CaseDir=${caseDir}" | tee -a ${logJob}
   echo "Try:${jTries}" | tee -a ${logJob}
   rname=$RANDOM
   fLista=/tmp/fLista.${rname}
   fListaClean=/tmp/fListaClean.${rname}
   fListaOrdenada=/tmp/fListaOrdenada.${rname}
   echo "The random name files are:" | tee -a ${logJob}
   echo "${fLista}" | tee -a ${logJob}
   echo "${fListaClean}" | tee -a ${logJob}
   echo "${fListaOrdenada}" | tee -a ${logJob}
   echo "Doing ssh in try:${jTries}" | tee -a ${logJob}
   echo "ssh espinosa@hpc-data.pawsey.org.au ls -d ${caseDir}/*/" | tee -a ${logJob}
   ssh espinosa@hpc-data.pawsey.org.au "ls -d ${caseDir}/*/" | tee -a ${fLista}
   echo "Finished ssh in try:${jTries}" | tee -a ${logJob}
   #if [ -s listaDirs.Borra ]; then
   if [ -s "${fLista}" ]; then
      echo "Cleaning Lista in try:${jTries}" | tee -a ${logJob}
      sed -i 's/\/$//g' "${fLista}"
      while read timeDir
         do
            basename $timeDir >> "${fListaClean}"
         done < "${fLista}"
      #sort -rn listaDirsClean.Borra > listaDirsOrdenada.Borra
      sort "${fListaClean}" > "${fListaOrdenada}"
      echo "Cleaning ListaOrdenanda in try:${jTries}" | tee -a ${logJob}
      i=0
      while read textTimeDir
      do
          timeDirArr[$i]=$textTimeDir
          #echo "The $i timeDir is: ${timeDirArr[$i]}" | tee -a ${logJob}
          ((i++))
      done < "${fListaOrdenada}"
      nTimeDirectories=$i   
   else
      nTimeDirectories=0
   fi
   echo "There are ${nTimeDirectories} directories for clouds in try:${jTries}" | tee -a ${logJob}
   if [ "$nTimeDirectories" -eq "0" ]; then
      doDirectories=false
      echo "Sleeping for ${pausingMinutes} minutes in try:${jTries}" | tee -a ${logJob}
      sleep "${pausingMinutes}m"
   else
      doDirectories=true
      jTries=$MaxTries
   fi
   rm -f "${fLista}"
   rm -f "${fListaClean}"
   rm -f "${fListaOrdenada}"
done


#-----------------------------------------
#Backing up the basic directories
cd $hereD
#Backing up all the directories in the case, except the trajectories
bDir=.
#Executing the backup::
noTrajectoriesBackup

#-----------------------------------------
#Backing up some trajectories quickly
cd $hereD
jBackup=0
bDir=${timeDirArr[$jBackup]}
#Executing the backup::
echo "Backing up ${jBackup}:" | tee -a listaDirs.Borra
echo "Dir is ${bDir}" | tee -a listaDirs.Borra
basicBackup

cd $hereD
jBackup=$(( nTimeDirectories - 1 ))
bDir=${timeDirArr[$jBackup]}
#Executing the backup::
echo "Backing up ${jBackup}:" | tee -a listaDirs.Borra
echo "Dir is ${bDir}" | tee -a listaDirs.Borra
basicBackup

cd $hereD
jBackup=$(( $jBackup - 1 ))
bDir=${timeDirArr[$jBackup]}
#Executing the backup::
echo "Backing up ${jBackup}:" | tee -a listaDirs.Borra
echo "Dir is ${bDir}" | tee -a listaDirs.Borra
basicBackup

cd $hereD
jBackup=$(( nTimeDirectories / 2 ))
bDir=${timeDirArr[$jBackup]}
#Executing the backup::
echo "Backing up ${jBackup}:" | tee -a listaDirs.Borra
echo "Dir is ${bDir}" | tee -a listaDirs.Borra
basicBackup

cd $hereD
jBackup=$(( $jBackup - 1 ))
bDir=${timeDirArr[$jBackup]}
#Executing the backup::
echo "Backing up ${jBackup}:" | tee -a listaDirs.Borra
echo "Dir is ${bDir}" | tee -a listaDirs.Borra
basicBackup

#-----------------------------------------
echo "#******************************************************" | tee -a ${logJob}
echo "#******************************************************" | tee -a ${logJob}
if [ "$quickHere" = "true" ]; then
   echo "quickHere is =${quickHere}" | tee -a ${logJob}
   echo "As it is YES exactly ==true" | tee -a ${logJob}
   echo "Then quickHere YES apply. Finishing here" | tee -a ${logJob}
else
   echo "quickHere is =${quickHere}" | tee -a ${logJob}
   echo "As it is not exactly ==true" | tee -a ${logJob}
   echo "Then quickHere does not apply. Going extended" | tee -a ${logJob}
#-----------------------------------------
#Backing up the REST of postProcessing Directories
#-----------------------------------------
   cd $hereD
   #Backing up all the directories in the case
   bDir=.
   #Executing the backup::
   basicBackup
fi


#-----------------------------------------
#End
echo "Backup of case ${caseDir} Finished" | tee -a ${logJob}
