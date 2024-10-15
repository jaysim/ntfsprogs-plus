#!/usr/bin/env bash
set -x

IMAGES_REPO="git@github.com:ntfsprogs-plus/ntfs_corrupted_images.git"
REPO_NAME="ntfs_corrupted_images"
PWD=`pwd`
FSCK_PATH=$PWD/../src/

echo "Download corrupted images..."

if [ -d "${REPO_NAME}" ]; then
	cd ${REPO_NAME}
	git pull
	if [ $? -ne 0 ]; then
		echo "git full FAILED. exit"
		exit
	fi
	cd ..
else
	git clone ${IMAGES_REPO} ${REPO_NAME}
fi

setsid /bin/bash -c "cd ${REPO_NAME} && git checkout origin/for-next -b for-next"

# test created_manually directory
echo "==============================================="
echo "Test corrupted images which is created manually"
echo "==============================================="
setsid /bin/bash -c "cd ${REPO_NAME}/created_manually && ENV=${FSCK_PATH} ./test_fsck.sh"
if [ $? -ne 0 ]; then
	echo "Failed to test for created_manually images"
	exit 1
fi

echo "==================================================="
echo "Test corrupted images which is generated during use"
echo "==================================================="
# test generated_during_use directory
/bin/bash -c "cd ${REPO_NAME}/generated_during_use && ENV=${FSCK_PATH} ./test_fsck.sh"
if [ $? -ne 0 ]; then
	echo "Failed to test for generated_during_use images"
	exit 1
fi

#echo "==============================================="
#echo "Test for manually created images"
#echo "   Passed ${MAN_PASS_COUNT} of ${MAN_TOTAL_CNT}"
#echo
#echo "Test for generated images"
#echo "   Passed ${GEN_PASS_COUNT} of ${GEN_TOTAL_CNT}"
#echo "==============================================="
echo "Sucess to test corrupted images"
#rm -rf ${REPO_NAME}
