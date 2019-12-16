#!/bin/bash

# Usage: increment_version <version> [<position>]
increment_version() {
 local v=$1
 if [ -z $2 ]; then
    local rgx='^((?:[0-9]+\.)*)([0-9]+)($)'
 else
    local rgx='^((?:[0-9]+\.){'$(($2-1))'})([0-9]+)(\.|$)'
    for (( p=`grep -o "\."<<<".$v"|wc -l`; p<$2; p++)); do
       v+=.0; done; fi
 val=`echo -e "$v" | perl -pe 's/^.*'$rgx'.*$/$2/'`
 echo "$v" | perl -pe s/$rgx.*$'/${1}'`printf %0${#val}s $(($val+1))`/
}
## EXAMPLE   ------------->   # RESULT
#increment_version 1          # 2
#increment_version 1.0.0      # 1.0.1
#increment_version 1 2        # 1.1
#increment_version 1.1.1 2    # 1.2
#increment_version 00.00.001  # 00.00.002

RELEASE_PROJECT_DIR="/path/to/project"
DEV_BRANCH="develop"
MASTER_BRANCH="master"
RELEASE_BRANCH="release/release_xxx"
CURRENT_DIR=$(pwd)

cd $RELEASE_PROJECT_DIR

# git checkout $MASTER_BRANCH
# git merge --no-ff $RELEASE_BRANCH

LAST_MASTER_TAG=$(git for-each-ref refs/tags --sort=-taggerdate --format='%(refname:lstrip=2)' --count=1)
echo "Current latest tag from master is ${LAST_MASTER_TAG}"

# TODO allow major and minor version increment by option
INCREMENTED_MAJOR_AND_MINOR=$(increment_version ${LAST_MASTER_TAG} "2")
NEW_TAG="${INCREMENTED_MAJOR_AND_MINOR}.0"

# git tag $NEW_TAG
echo "Incremented master tag to ${NEW_TAG}"

COMMA_SEPARATED_TICKETS=$(git log --pretty=oneline master..${RELEASE_BRANCH} | grep -e '[A-Z]\+-[0-9]\+' -o | sort -u | xargs | sed -e 's/ /,/g')

# git checkout $DEV_BRANCH
# git merge --no-ff $MASTER_BRANCH

# git push origin $MASTER_BRANCH $DEV_BRANCH

# cleanup to delete local release
# git checkout $DEV_BRANCH
# git branch -D $RELEASE_BRANCH

# run python script to transition tickets to done
cd $CURRENT_DIR
python3 jira-finish.py $COMMA_SEPARATED_TICKETS