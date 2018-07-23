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
#baseDir=/scratch/pawsey0106/espinosa/OpenFOAM/espinosa-$FOAMVersion/run
baseDir=/scratch/pawsey0001/espinosa/OpenFOAM/espinosa-$FOAMVersion/run
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
   chmod 777 *.Borra
   rm -r *.Borra
   ssh espinosa@hpc-data.pawsey.org.au "ls -dt ${caseDir}/[0-9]*/" | tee -a listaDirs.Borra
   if [ -s listaDirs.Borra ]; then
      sed -i 's/\/$//g' listaDirs.Borra
      while read timeDir
         do
            basename $timeDir >> listaDirsClean.Borra
         done < listaDirs.Borra
      sort -rn listaDirsClean.Borra > listaDirsOrdenada.Borra
      i=0
      while read textTimeDir
      do
          timeDirArr[$i]=$textTimeDir
          #echo "The $i timeDir is: ${timeDirArr[$i]}" | tee -a ${logJob}
          ((i++))
      done < listaDirsOrdenada.Borra
      nTimeDirectories=$i   
   else
      nTimeDirectories=0
   fi
   if [ "$nTimeDirectories" -eq "0" ]; then
      doDirectories=false
      echo "Sleeping for ${pausingMinutes} minutes" | tee -a ${logJob}
      sleep "${pausingMinutes}m"
   else
      doDirectories=true
      jTries=$MaxTries
   fi
done

#-----------------------------------------
#Backing up the basic directories
cd $hereD
#The 0 Dir ...
bDir=0
basicBackupSizeOnly

#The constant Dir ...
bDir=constant
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "CaseDir=${caseDir}" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
echo "Backing up the ${bDir} Dir without polyMesh" | tee -a ${logJob}
echo "#--------------------------------------------------" | tee -a ${logJob}
for ((jTries=0; jTries<$MaxTries; jTries++))
do
   echo "bDir=${bDir} backup will be done, try ${jTries}" | tee -a ${logJob}
   rsync --size-only --stats --progress -auvzrhs --exclude polyMesh/ espinosa@hpc-data.pawsey.org.au:$caseDir/$bDir . | tee -a ${logJob}
   errorRsync=${PIPESTATUS[0]}
   if [ "$errorRsync" -eq 0 ] || [ "$errorRsync" -eq 23 ] ; then
     echo "rsync passed with error code ${errorRsync}" | tee -a ${logJob}
     echo "script will keep going" | tee -a ${logJob}
     jTries=$MaxTries
   else
     echo "rsync failed with code ${errorRsync}" | tee -a ${logJob}
     echo "trying again in ${pausingMinutes} minutes" | tee -a ${logJob}
     sleep "${pausingMinutes}m"
   fi
done


#The system Dir ...
bDir=system
basicBackupSizeOnly

#The dynamicCode Dir ...
bDir=dynamicCode
basicBackupSizeOnly

#The .sh scripts ...
bDir=*.sh
basicBackupSizeOnly

#-----------------------------------------
#Backing up the QUICK postProcessing Directories
cd $hereD
if ! [ -d ./postProcessing ]; then
   mkdir postProcessing
fi
cd postProcessing
#The *.txt Files ...
bDir=./postProcessing/*.txt
basicBackupSizeOnly

#The MeanRings sampled Dirs ...
bDir=./postProcessing/*MeanRings
basicBackupSizeOnly

#The MeanLines sampled Dirs ...
bDir=./postProcessing/*MeanLines
basicBackupSizeOnly

#The python posprocessed Dirs ...
bDir=./postProcessing/pythonFiles
basicBackupSizeOnly

#The meanForces Dirs ...
bDir=./postProcessing/meanForces*
basicBackupSizeOnly

cd $hereD

#-----------------------------------------
#Defining the QUICK times directories to backup
cd $hereD
if [ "$doDirectories" = "true" ]; then
   jEnd=0
   NTheLast=3
   #endTime=${timeDirArr[0]}
   if [ $nTimeDirectories -ge $NTheLast ]; then
       jIni=$NTheLast
       echo "Quick Backing up until the last ${NTheLast} times" | tee -a ${logJob}
   else
       jIni=$nTimeDirectories
       echo "Quick Backing up until the existing ${nTimeDirectories} times" | tee -a ${logJob}
   fi


   #-----------------------------------------
   #Backing up QUICK the last N existing times times
   
   echo "Quick Backing up the last ${jIni} times" | tee -a ${logJob}
   for ((j=$jEnd; j<$jIni; j++))
   do
       bDir=${timeDirArr[$j]}
       echo "Quick Backing up ${bDir}" | tee -a ${logJob}
       basicBackupSizeOnly
   done
fi

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
   cd $hereD
   echo "Backing up the rest of the postprocessing directory" | tee -a ${logJob}
   bDir=./postProcessing
   basicBackupSizeOnly

#-----------------------------------------
#Defining the REST of the time directories
   if [ "$doDirectories" = "true" ]; then
      cd $hereD
      jEnd=0
      #endTime=${timeDirArr[0]}
      if [ $nTimeDirectories -ge $Nlast ]; then
          jIni=$Nlast
          echo "Backing up until the last ${Nlast} times" | tee -a ${logJob}
      else
          jIni=$nTimeDirectories
          echo "Backing up until the existing ${nTimeDirectories} times" | tee -a ${logJob}
      fi
      cd $hereD


#-----------------------------------------
#backing up the REST of the time directories
      cd $hereD
      echo "Backing up the last ${jIni}+1 times" | tee -a ${logJob}
      for ((j=$jEnd; j<$jIni; j++))
      do
          bDir=${timeDirArr[$j]}
          echo "Backing up ${bDir}" | tee -a ${logJob}
          basicBackupSizeOnly
      done
   fi
fi

#-----------------------------------------
#End
echo "Backup of case ${caseDir} Finished" | tee -a ${logJob}
