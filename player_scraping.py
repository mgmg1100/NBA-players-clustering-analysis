from bs4 import BeautifulSoup
import requests
from pandas import DataFrame, Series
import pandas as pd
import re

df1 = DataFrame(columns=('RK','Name','GP','Min','True Shooting','ASTR','TOR','USG','ORR','DRR','REBR','PER','VA','EVA'))

player_index = 0							
root = "http://insider.espn.go.com/nba/hollinger/statistics/_/page/"#2

def get_data(url):
	global df1
	global player_index
	html = requests.get(url).content
	soup = BeautifulSoup(html,'lxml')
	
	for player in soup.find('table',{'class':'tablehead'}).find_all('tr', {'class':re.compile("player")}):
		df1.loc[player_index] = [player.find_all('td')[i].get_text() for i in range(14)]
		player_index += 1

def name_delimiter():
	global df1
	df1.Name = df1.Name.str.split(pat = ',',n = 1, expand = True)

if __name__ == "__main__":
	
	for i in range(1,11):
		get_data(root+str(i)+"/qualified/false")

	name_delimiter()
	print(df1.head())
	df1.to_csv('players_1.csv')
