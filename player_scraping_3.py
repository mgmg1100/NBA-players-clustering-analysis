import time
from bs4 import BeautifulSoup
import requests
from pandas import DataFrame, Series
import pandas as pd
import os
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

root = "http://www.nbaminer.com/nbaminer_nbaminer/player_assist_details.php?partitionpage=&partition2page=&page="
df4 = DataFrame(columns=('Name', 'Assited FGM'))
player_index = 0							


def get_data_4(url):
	global df4
	global player_index
	html = requests.get(url).content
	soup = BeautifulSoup(html,'lxml')
	
	for player in soup.find_all('tr', {'class':'pg-row'}):
		df4.loc[player_index] = [player.find('td',{'data-column-name':'statsnbacom_playerid'}).find('div').get_text()[1:],
		player.find('td',{'data-column-name':'assisted_fg_pct'}).get_text()]
		player_index += 1


if __name__ == "__main__":
	
	for i in range(1,25):
		get_data_4(root+str(i))


	print(df4.head())
	df4.to_csv('players_4.csv')