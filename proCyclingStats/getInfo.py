#!/usr/bin/env python3

import requests
from bs4 import BeautifulSoup
from countryDict import countries

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

choice = input("Enter choice: ")
url = "https://www.procyclingstats.com/" + options[int(choice)-1]

response = requests.get(url)

soup = BeautifulSoup(response.text, "html.parser")

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

situation = soup.find("ul", class_="situ3")

riderCont = situation.find_all("div", class_="riderCont")

lengthA = len(riderCont)

for i, x in enumerate(riderCont):
	print("\n\n")
	
	timeGap = ""
	if not i == 0:
		timeGap = f" (@{x.find('span', class_='time').text})"
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
		print(f"{rider[0].text}: {rider[3].text} ({rider[2].text}) ({rider[1].span['title']}) ({countries.get(rider[5].span['class'][2].upper(), 'ERROR')})")

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
