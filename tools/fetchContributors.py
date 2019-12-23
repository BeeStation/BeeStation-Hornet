# Script for fetching the top contributors of a git repo, and writing it to config/contributors.txt
# written by qwertyquerty
# very ashamed of this one

import requests
import argparse
import operator

# List of github usernames to excluse from the output file
blacklist = [
	"ss13-beebot",
	"dependabot[bot]"
]

parser = argparse.ArgumentParser()

parser.add_argument('--pages', type=int, default=15, help='The program looks at the past 100*pages commits. Default: 15')
parser.add_argument('--repo',  type=str, default=None, help='author/repo e.g. Beestation/BeeStation-Hornet')
parser.add_argument('--token', type=str, default=None, help="Github personal access token (optional)")

args_ns = parser.parse_args()

if args_ns.repo == None:
	raise Exception("--repo argument is required!")

contributors = {}

for page in range(1,args_ns.pages+1):
	url = "https://api.github.com/repos/{}/commits?per_page=100&page={}".format(args_ns.repo, page)

	headers = {}

	if args_ns.token:
		headers = {"Authorization": "token {}".format(args_ns.token)}

	commits = requests.get(url, headers=headers).json()
	
	for commit in commits:
		if "author" in commit and commit["author"]:
			
			author = commit["author"]["login"]

			if author in blacklist:
				continue
			
			if author in contributors:
				contributors[author] += 1
			else:
				contributors[author] = 1

contributors = sorted(contributors.items(), key=operator.itemgetter(1), reverse=True)

contributors = [contrib[0] for contrib in contributors]

f = open("../config/contributors.txt", "wb")
f.write("\n".join(contributors).encode("utf-8"))
f.close()
