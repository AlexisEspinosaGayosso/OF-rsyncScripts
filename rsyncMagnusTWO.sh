#!/usr/bin/env bash

#The name of this script
#scriptName=$(readlink --canonicalize --no-newline $0)
scriptName=$(basename $0)

echo "$scriptName: START"
date
# -------------------------------------------------------------
#Checking the number of arguments
if [ $# -ne 1 ]
then
   echo "$scriptName: The script is still not prepared for handling $# arguments"
   echo "$scriptName: The arguments should be: casesList: 1 in total"
   echo "$scriptName: Exiting this script"
   exit -1
else
   #The cases List. If a list is not given, then a directory name should be given
   casesList=$1
   # Sending message
   echo "$scriptName: Processing using the following casesList"
   echo "$scriptName: $casesList"
fi

# -------------------------------------------------------------
#Reading the names of the directories to syncronize
if [ -e $casesList ]; then
   #Read the list of the cases to postProcess
   echo "$scriptName: Reading a list of cases"
   i=0
   while read caseDir
   do
      caseArr[$i]=$caseDir
      echo "$scriptName: The $i case is: ${caseArr[$i]}"
      ((i++))
   done < $casesList
   NDirs=$i
else
   echo "$scriptName: There is no case or list of cases named $casesList"
   exit -2
fi

# -------------------------------------------------------------
# The parent and the receiving main directories
parentDir=${caseArr[0]}
echo "$scriptName: The parent dir is:"
echo "$parentDir"

receivingDir=${caseArr[1]}
echo "$scriptName: The receiving dir is:"
echo "$receivingDir"

# -------------------------------------------------------------
# -------------------------------------------------------------
# -------------------------------------------------------------
# Beginning of the main loop
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
cd $receivingDir
iCase=2
while [ $iCase -lt $NDirs ]; do
   caso=${caseArr[$iCase]}
   if [ -d $caso ]; then
      echo "$caso directory already exists"
   else
      echo "Creating the directory: $caso"
      mkdir $caso
   fi
   #-------------------------------------------------------------
   # Executing the rsync
   sudo rsync --stats --progress -auvzrhs /run/user/1000/gvfs/sftp:host=hpc-data.pawsey.org.au,user=espinosa$parentDir/$caso $receivingDir
   ((iCase++))
done

