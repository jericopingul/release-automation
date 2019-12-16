#!/bin/bash

RELEASE_PROJECT_DIR="/path/to/project"
DEV_BRANCH="develop"
MASTER_BRANCH="master"
RELASE_DATE_FORMAT="$(date +'%Y%m%d_%H%M')"
NEW_RELEASE_BRANCH="release/release_${RELASE_DATE_FORMAT}"
CURRENT_DIR=$(pwd)

# TODO improvement to share variables between scripts
# export variables so they can be used in release-finish.sh script

cd $RELEASE_PROJECT_DIR
echo "Changed directory to ${RELEASE_PROJECT_DIR}"

# current branch
CURRENT_BRANCH=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')
echo "Current branch is ${CURRENT_BRANCH}"

# create the release branch from the -develop branch
git checkout -b $NEW_RELEASE_BRANCH $DEV_BRANCH
echo "Created new release branch ${NEW_RELEASE_BRANCH} locally from ${DEV_BRANCH}"

# git push -u origin $NEW_RELEASE_BRANCH
# echo "Pushed new release branch ${NEW_RELEASE_BRANCH} to origin"

# get diff ticket numbers from master to release, sort + unique and comma-separate
COMMA_SEPARATED_TICKETS=$(git log --pretty=oneline master..${NEW_RELEASE_BRANCH} | grep -e '[A-Z]\+-[0-9]\+' -o | sort -u | xargs | sed -e 's/ /,/g')

# run jira python script - create release + add tickets to release
echo "Running jira-start.py script to create release and add the tickets ${COMMA_SEPARATED_TICKETS} to release"
cd $CURRENT_DIR
python3 jira-start.py $COMMA_SEPARATED_TICKETS $NEW_RELEASE_BRANCH

# FIXEME remove these lines
cd $RELEASE_PROJECT_DIR
echo "Deleting release branch ${NEW_RELEASE_BRANCH}"
git checkout $DEV_BRANCH
git branch -D $NEW_RELEASE_BRANCH