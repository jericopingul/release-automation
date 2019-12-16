import asyncio
import sys
import re
from jira import JIRA
import yaml

### Constants ###
config_file = "config.yml"
release_name_delimiter_pattern = '_'
delay_time = 0.5

def login(user, server, apikey):
    options = {"server": server}
    return JIRA(options, basic_auth=(user, apikey))

async def create_version(jira, name, project_key, description):
    jira.create_version(name, project_key, description)
    await asyncio.sleep(delay_time)

async def version_issues(jira, issue_numbers, version):
    for issue_number in issue_numbers:
        try:
            issue = jira.issue(issue_number)
            print(issue)
            issue.add_field_value("fixVersions", {"name": version})
        except:
            print(f'Failed to version issue {issue_number}')
    await asyncio.sleep(delay_time)

def increment_project_release_version(release_name_delimiter_pattern, latest_released_version):
    release_name_structure = re.split(release_name_delimiter_pattern, latest_released_version)
    release_last_index = len(release_name_structure) - 1
    current_version_number = release_name_structure[release_last_index]
    new_release_version_list = release_name_structure[0: release_last_index]
    new_release_version_list.append(str(int(current_version_number) + 1).zfill(3))
    return release_name_delimiter_pattern.join(new_release_version_list)

async def main():
    """
    Parameters
    ----------
    ticket_numbers: str
        comma-separated ticket numbers
    version_description: str
        version description
    """
    with open(config_file, 'r') as yml_file:
        config = yaml.load(yml_file)
    server = config["server"]
    user = config["user"]
    apikey = config["apikey"]

    jira = login(user, server, apikey)
    ticket_numbers_csv = sys.argv[1]
    release_version_description = sys.argv[2]

    ticket_numbers_list = ticket_numbers_csv.split(',')
    unique_ticket_prefixes = set(map(lambda ticket_number: ticket_number.split('-')[0], ticket_numbers_list))

    unique_tickets_dict = { unique_ticket_prefix : [] for unique_ticket_prefix in unique_ticket_prefixes }

    for key in unique_tickets_dict:
        for ticket_number in ticket_numbers_list:
            if ticket_number.startswith(key):
                unique_tickets_dict[key].append(ticket_number)
        print(f'Project is {key} and has the tickets due for release: {unique_tickets_dict[key]}')

        project_versions = jira.project_versions(key)
        if len(project_versions) > 1:
            latest_released_version = project_versions[len(project_versions) - 1].name
            print(f'Current latest released version for project {key} is {latest_released_version}')
            new_release_version_name = increment_project_release_version(release_name_delimiter_pattern, latest_released_version)
            print(f'New version name for project {key} will be: {new_release_version_name}')

            try:
                print(f'Creating version with name {new_release_version_name} in project {key}')
                await create_version(jira, new_release_version_name, key, release_version_description)
            except:
                print(f'Failed to create release version for project: {key}')

            await version_issues(jira, unique_tickets_dict[key], new_release_version_name)

            # FIXME for testng only
            # for ticket in unique_tickets_dict[key]:
            #     print(f'Versioning fix version {new_release_version_name} to issue {ticket}')


if __name__== "__main__":
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())
    loop.close()
