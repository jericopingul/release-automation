#!/bin/bash

RELEASE_PROJECT_DIR="/path"
DEV_BRANCH="develop"
MASTER_BRANCH="master"
RELASE_DATE_FORMAT="$(date +'%Y%m%d_%H%M')"
NEW_RELEASE_BRANCH="release/release_${RELASE_DATE_FORMAT}"
CURRENT_DIR=$(pwd)

echo $NEW_RELEASE_BRANCH
echo $RELEASE_PROJECT_DIR

# TODO improvement to share variables between scripts
# export variables so they can be used in release-finish.sh script
# export RELEASE_PROJECT_DIR
# export DEV_BRANCH
# export MASTER_BRANCH
# export NEW_RELEASE_BRANCH
# . ./release-finish.sh

cd $RELEASE_PROJECT_DIR

# get current branch
echo $(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# create the release branch from the -develop branch
git checkout -b $NEW_RELEASE_BRANCH $DEV_BRANCH
echo "Created new release branch ${NEW_RELEASE_BRANCH} locally from ${DEV_BRANCH}"

git push -u origin $NEW_RELEASE_BRANCH
echo "Pushed new release branch ${NEW_RELEASE_BRANCH} to origin"

# get diff ticket numbers from master to release, sort + unique and comma-separate
COMMA_SEPARATED_TICKETS=$(git log --pretty=oneline master..${NEW_RELEASE_BRANCH} | grep -e '[A-Z]\+-[0-9]\+' -o | sort -u | xargs | sed -e 's/ /,/g')

# run jira python script - create release + add tickets to release
echo "Running jira-start.py script to create release and add tickets ${COMMA_SEPARATED_TICKETS} to release"
cd $CURRENT_DIR
python3 jira-start.py $COMMA_SEPARATED_TICKETS $NEW_RELEASE_BRANCH

cd $RELEASE_PROJECT_DIR