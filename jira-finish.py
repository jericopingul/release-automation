import asyncio
import sys
import re
from jira import JIRA
import yaml

### Constants ###
config_file = "config.yml"
transition_status = "done"
delay_time = 0.5

def login(user, server, apikey):
    options = {"server": server}
    return JIRA(options, basic_auth=(user, apikey))

async def set_transition(jira, issue_numbers, transition_name):
    for issue_number in issue_numbers:
        try:
            issue = jira.issue(issue_number)
            transition_id = jira.find_transitionid_by_name(issue, transition_name)
            jira.transition_issue(issue, transition_id)
        except:
            print(f'Failed to set {issue_number} to {transition_name}')
    await asyncio.sleep(delay_time)

async def main():
      """
    Parameters
    ----------
    ticket_numbers: str
        comma-separated ticket numbers
    """
    with open(config_file, 'r') as yml_file:
        config = yaml.load(yml_file)
    server = config["server"]
    user = config["user"]
    apikey = config["apikey"]

    jira = login(user, server, apikey)
    ticket_numbers_csv = sys.argv[1]

    ticket_numbers_list = ticket_numbers_csv.split(',')

    await set_transition(jira, ticket_numbers_list, transition_status)

    # FIXME for testng only
    # for ticket in ticket_numbers_list:
    #     print(f'Setting ticket {ticket} to status {transition_status}')

if __name__== "__main__":
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())
    loop.close()
