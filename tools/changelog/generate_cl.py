"""
DO NOT MANUALLY RUN THIS SCRIPT.
"""
import sys
import re
from pathlib import Path
from ruamel import yaml
from github import Github

CL_BODY = re.compile(r":cl:(.+)?\r\n((.|\n|\r)+?)\r\n\/:cl:", re.MULTILINE)
CL_SPLIT = re.compile(r"(^\w+):\s+(\w.+)", re.MULTILINE)

if len(sys.argv) < 4:
    print("Missing arguments")
    exit(1)

# Blessed is the GoOnStAtIoN birb ZeWaKa for thinking of this first
repo = sys.argv[1]
token = sys.argv[2]
sha = sys.argv[3]

git = Github(token)
repo = git.get_repo(repo)
commit = repo.get_commit(sha)
pr_list = commit.get_pulls()

if not pr_list.totalCount:
    print("Direct commit detected")
    exit(1)

pr = pr_list[0]

pr_body = pr.body
pr_number = pr.number
pr_author = pr.user.login

write_cl = {}
try:
    cl = CL_BODY.search(pr_body)
    cl_list = CL_SPLIT.findall(cl.group(2))
except AttributeError:
    print("No CL found!")
    exit(1)


if cl.group(1) is not None:
    write_cl['author'] = cl.group(1).lstrip()
else:
    write_cl['author'] = pr_author

write_cl['delete-after'] = True

with open(Path.cwd().joinpath("tools/changelog/tags.yml")) as file:
    tags = yaml.safe_load(file)

write_cl['changes'] = []

for k, v in cl_list:
    if k in tags['tags'].keys():
        v = v.rstrip()
        if v not in list(tags['defaults'].values()):
            write_cl['changes'].append({tags['tags'][k]: v})

if write_cl['changes']:
    with open(Path.cwd().joinpath(f"html/changelogs/AutoChangeLog-pr-{pr_number}.yml"), 'w') as file:
        yaml = yaml.YAML()
        yaml.indent(sequence=4, offset=2)
        yaml.dump(write_cl, file)

    print("Done!")
else:
    print("No CL changes detected!")
    exit(0)
