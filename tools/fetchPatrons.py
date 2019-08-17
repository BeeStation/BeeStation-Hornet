# Script for fetching the names of patrons from a patreon page.
# written by qwertyquerty
#
# format: python fetchPatrons.py <campaign id>

import requests
import sys

if len(sys.argv) < 2:
	raise Exception("Campaign ID not passed!")

url = "https://www.patreon.com/api/campaigns/{}/pledges?include=patron.null".format(sys.argv[1])


r = requests.get(url)

data = r.json()

patrons = []
for item in data["included"]:
	if item["type"] == "user":
		patrons.append(item["attributes"]["full_name"])


f = open("../config/patrons.txt", "w")
f.write("\n".join(patrons))
f.close()
