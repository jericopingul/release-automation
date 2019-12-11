import asyncio
import sys
import re
from jira import JIRA
from functools import reduce

### Constants ###
# user email
user = "jerico.pingul@gmail.com"
# api key generated from JIRA from user
# https://confluence.atlassian.com/cloud/api-tokens-938839638.html
apikey = "xxx"
# status to transition to - to do | in progress | done ...etc
transition_status = "to do"
# server url
server = "https://xxx.atlassian.net"

release_name_delimiter_pattern = '_'


def login(user, apikey):
    options = {"server": server}
    return JIRA(options, basic_auth=(user, apikey))


async def set_transition(issue_numbers, transition_name):
    for issue_number in issue_numbers:
        issue = jira.issue(issue_number)
        transition_id = jira.find_transitionid_by_name(issue, transition_name)
        jira.transition_issue(issue, transition_id)
    await asyncio.sleep(0.1)


async def create_version(jira, name, project_key, description):
    jira.create_version(name, project_key, description)
    await asyncio.sleep(0.1)


async def version_issues(jira, issue_numbers, version):
    for issue_number in issue_numbers:
        try:
            issue = jira.issue(issue_number)
            print(issue)
            issue.add_field_value("fixVersions", {"name": version})
        except:
            print("Failed to version issue: " + issue_number)
    await asyncio.sleep(0.1)



async def main():
    jira = login(user, apikey)

    ticket_numbers_csv = sys.argv[1]
    new_master_tag = sys.argv[2]
    print ("arguments: " + ticket_numbers_csv  + " second arg: " + new_master_tag)


    grouped_tickets = []
    ticket_numbers_list = ticket_numbers_csv.split(',')
    unique_ticket_prefixes = set(map(lambda ticket_number: ticket_number.split('-')[0], ticket_numbers_list))

    for unique_ticket in unique_ticket_prefixes:
        print (unique_ticket)

    # unique_tickets_dict = reduce(init_unique_tickets_dict, {})
    unique_tickets_dict = { unique_ticket_prefix : [] for unique_ticket_prefix in unique_ticket_prefixes }

    for key in unique_tickets_dict:
        for ticket_number in ticket_numbers_list:
            if ticket_number.startswith(key):
                unique_tickets_dict[key].append(ticket_number)
        print (key, unique_tickets_dict[key])
        # TODO create release based on each key

        project_versions = jira.project_versions(key)
        if len(project_versions) > 1:
            print(project_versions[len(project_versions) - 1].name )
            release_name_structure = re.split(release_name_delimiter_pattern, project_versions[len(project_versions) - 1].name)
            release_last_index = len(release_name_structure) - 1

            current_version_number = release_name_structure[release_last_index]

            new_release_version_list = release_name_structure[0: release_last_index]
            new_release_version_list.append(str(int(current_version_number)+1))

            new_release_version_name = release_name_delimiter_pattern.join(new_release_version_list)
            print (new_release_version_name)
            try:
                # print(0/0)
                await create_version(jira, new_release_version_name, key, new_master_tag)
            except:
                print("Failed to create release version for project: ", key)

            await version_issues(jira, unique_tickets_dict[key], new_release_version_name)


  

  

      

if __name__== "__main__":
  loop = asyncio.get_event_loop()
  loop.run_until_complete(main())
  loop.close()
