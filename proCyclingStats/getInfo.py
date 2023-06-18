#!/usr/bin/env python3

import requests
from bs4 import BeautifulSoup
from countryDict import countries

colours = {
	"red": "\033[31m",
	"blue": "\033[34m",
	"yellow": "\033[33m",
	"cyan": "\033[36m",
	"magenta": "\033[35m",
	"green": "\033[32m",
	"end": "\033[0m"
}

url = "https://www.procyclingstats.com/race/tour-of-slovenia/2023/stage-5/live"

urlHome = "https://www.procyclingstats.com"

home = requests.get(urlHome)

soup = BeautifulSoup(home.text, "html.parser")

target = soup.find("h3", string="LiveStats")
liveRaces = target.find_next_sibling()

links = liveRaces.find_all("a", href=True)

options = []

for i, link in enumerate(links):
	hyperlink = link["href"]
	title = link.find("div", class_="racename").text
	if "FINISHED" in title:
		continue
	print(f"{i+1}: {title}")
	options.append(hyperlink)

#choice = input("Enter choice: ")
#url = "https://www.procyclingstats.com/" + options[int(choice)-1]

response = requests.get(url)

#soup = BeautifulSoup(response.text, "html.parser")

f = open("output.html", "r")
soup = BeautifulSoup(f.read(), "html.parser")
f.close()
'''
tables = soup.find_all("table")

for i, x in enumerate(tables):
	if "JARC" in x.text	:
		print("NEXT ENTRY (" + str(i) + ")\n\n")	
		print(x)


target = soup.find("h3", string="Situation")
for sib in target.find_next_siblings():
	if sib.name == "h3":
		break
	else:
		print(sib.prettify())
print(target)
'''

uLists = soup.find_all("ul")

raceStats = uLists[13]

listElements = raceStats.find_all("li")

stageStats = []

for i, element in enumerate(listElements):
	stageStats.append(element.find_all("div")[1].text)
	if i == 4:
		break

print(colours["yellow"] + "Completed:\t " + colours["end"] + colours["red"] + stageStats[2] + "KM" + colours["end"])
print(colours["yellow"] + "Remaining:\t " + colours["end"] + colours["cyan"] + stageStats[0] + "KM" + colours["end"])
print(colours["yellow"] + "Time:\t\t " + colours["end"] + colours["magenta"] + stageStats[1] + colours["end"])
print(colours["yellow"] + "Average Speed:\t " + colours["end"] + colours["green"] + stageStats[3] + "KM/H" + colours["end"])
print(colours["yellow"] + "Start Time:\t " + colours["end"] + colours["blue"] + stageStats[4] + colours["end"])

situation = soup.find("ul", class_="situ3")

riderCont = situation.find_all("div", class_="riderCont")

lengthA = len(riderCont)

for i, x in enumerate(riderCont):
	print("")
	
	timeGap = ""
	if not i == 0:
		timeGap = f" ({colours['magenta']}@{x.find('span', class_='time').text}{colours['end']})"
		timeGap = timeGap.replace("+", " ").replace("??", "")
	
	if i == 0:
		print("Breakaway")
	elif not i == lengthA-1:
		print("Poursulvant" + timeGap)
	else:
		print("Peleton" + timeGap)
	
	table = x.find("table")
	rows = table.find_all("tr")
	riders = []
	
	for row in rows:
		cols = row.find_all("td")
		#cols = [ele.text.strip() for ele in cols]
		riders.append([ele for ele in cols if ele])
	
	for rider in riders:
		print(f"{colours['red']}{rider[0].text}{colours['end']}: {colours['green']}{rider[3].text}{colours['end']} ({colours['blue']}{rider[2].text}{colours['end']}) ({colours['cyan']}{rider[1].span['title']}{colours['end']}) ({colours['magenta']}{countries.get(rider[5].span['class'][2].upper(), 'ERROR')}{colours['end']})")

'''
for sib in target.find_next_siblings():
	if sib.name == "h3":
		break
	else:
		print(sib)
		print("END\n\n\n\n\n\n")
		#links = sib.find_all("a", href=True)
		#print(links.)
'''
