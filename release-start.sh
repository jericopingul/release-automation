#!/bin/bash

RELEASE_PROJECT_DIR="/Users/jericopingul/projects/sylon-project/sylon"
DEV_BRANCH="develop"
MASTER_BRANCH="master"
RELASE_DATE_FORMAT="$(date +'%Y%m%d_%H%M')"
NEW_RELEASE_BRANCH="release/release_${RELASE_DATE_FORMAT}"

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

# git push -u origin $NEW_RELEASE_BRANCH
# echo "Pushed new release branch ${NEW_RELEASE_BRANCH} to origin"

# TODO run python script to create version in Jira

# get diff ticket numbers from master to release, sort + unique and comma-separate
COMMA_SEPARATED_TICKETS=$(git log --pretty=oneline master..${NEW_RELEASE_BRANCH} | grep -e '[A-Z]\+-[0-9]\+' -o | sort -u | xargs | sed -e 's/ /,/g')
echo $COMMA_SEPARATED_TICKETS

# convert new line list to comma separated
# cat text.txt | xargs | sed -e 's/ /,/g'

git checkout $DEV_BRANCH
git branch -D $NEW_RELEASE_BRANCH