#!/bin/bash
###
# chapel-update.sh
# Andrew M. Becker
# Georgia Institute of Technology
# (C) 2022
###
ARM_DL_LINK="https://www.dropbox.com/s/k0eaojk4hbas580/chapel-1.27-arm64.tar.gz?dl=0"
ARM_MD5="0771330b1c4bb1421f3cffd638a2c079"
X64_DL_LINK="https://www.dropbox.com/s/ixdwkk36ye0ufoc/chapel-1.27-x64.tar.gz?dl=0"
X64_MD5="ff98921ced806c99a537a30c238d2130"
DL_LINK=""
DL_MD5=""
OUTPUT_FILE="chapel-1.27-vm.tar.gz"

#Sanity checks
if [ "$(uname -n)" != "cse6220lab" ]
then
    echo "This is meant to be run from the course VM...aborting."
    exit 1
fi

if [ "$(whoami)" != "lab" ]
then
    echo "This is meant to be run as the default lab user...aborting."
    exit 1
fi

#Set the appropriate architecture
if [ "$(uname -m)" == "aarch64" ]
then
    echo "[**] Downloading Chapel update for arm64"
    DL_LINK="$ARM_DL_LINK"
    DL_MD5="$ARM_MD5"
elif [ "$(uname -m)" == "x86_64" ]
then
    echo "[**] Downloading Chapel update for x86_64"
    DL_LINK="$X64_DL_LINK"
    DL_MD5="$X64_MD5"
else
    echo "Unsupported architecture"
    exit 1
fi

#Set the proper directory
cd /home/lab
if [ "$?" -ne "0" ]
then
    echo "Unable to change to download directory."
    exit 1
fi

#Download the package
wget -O $OUTPUT_FILE "$DL_LINK"
if [ "$?" -ne "0" ]
then
    echo "Download failed...please try again."
    exit 1
fi

#Check the hash
echo "[**] Verifying checksum"
if [ "$(md5sum $OUTPUT_FILE | cut -d' ' -f1)" != "$DL_MD5" ]
then
    echo "Download md5sum does not match...please try again."
    exit 1
fi

#Extract the package
echo "[**] Extracting the update"
tar xzf $OUTPUT_FILE
if [ "$?" -ne "0" ]
then
    echo "Something went wrong during extraction...try extracting $OUTPUT_FILE manually."
    exit 1
fi

#Cleanup
echo "[**] Cleaning up tarball"
rm $OUTPUT_FILE
if [ "$?" -ne "0" ]
then
    echo "Something went wrong during cleanup..."
    exit 1
fi

echo "[**] Chapel successfully updated"

#Exit
exit 0
