# Release Automation Scripts
Automates the following:
- git flow release process
- Creating Jira release version
- Adding tickets to Jira release version

**Note**
- Full features may only be available for Unix terminal users only
- Some bash commands may not be supported for Windows command line

So run either through WSL or on some Unix environment

# Setup

## Install Python 3 in your terminal

Depending on your OS, instructions will vary.

## Install dependency libraries

### asyncio
`pip install asyncio`

### jira
`pip install jira`

**Note** if you are running on WSL you may need to convert the file line endings to Unix so

### Install `dos2unix`

`sudo apt-get install dos2unix`

then run on each file

`dos2unix <filename>`

### Jira credentials
To access and update Jira tickets you will need to authenticate
- Generate your API key here: https://confluence.atlassian.com/cloud/api-tokens-938839638.html
- Enter API key and email into config.yml
- **Note** API keys are only valid for 7 days by default (an admin API key can be created and will expire in a year https://confluence.atlassian.com/cloud/create-an-admin-api-key-969537932.html)

# Starting a release

## Setup
- Sync your local master and develop branch in with origin
- Provide local machine path to your git project to release as variable `RELEASE_PROJECT_DIR`

## Command
Run
`./release-start.sh`

## Result
This command will do the following:
- Create a release git branch with the specified format from your develop branch
- Diff your new release branch with latest tagged master to extract the new Jira tickets to release
- Run the python script `jira-start.py` which will:
  - Create a new version (release) in Jira and automatically increment the version
  - Add the tickets to the release version
  - **Note** multiple releases can be created if multiple ticket keys are extracted from the ticket diff

# Finishing a release

## Setup
- Add the release branch name to the script as variable `RELEASE_BRANCH`

## Command
`./release-finish.sh`

## Result
This command will do the following:
- Merge the release branch into:
  - master
  - develop
- Increment the master tag version
- Push master and develop to origin
- Delete created release branch
- Run python script `jira-finish.py` to set tickets to done