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

root1 = "http://stats.nba.com/league/player/#!/shooting/"
df2 = DataFrame(columns=('Name','Team','Age','5_FGM','5_FGA','5_FGR','9_FGM','9_FGA','9_FGR','14_FGM','14_FGA','14_FGR',
						'19_FGM','19_FGA','19_FGR','24_FGM','24_FGA','24_FGR','29_FGM','29_FGA','29_FGR'))

root2 = "http://stats.nba.com/tracking/#!/player/defense/"
df3 = DataFrame(columns = ['Name','Team','GP','Min','W','L','STL','BLK','DREB','DFGM','DFGA','DFGR'])

player_index_1 = 0
player_index_2 = 0

def get_data_2(url):
	global player_index_1
	br = webdriver.Chrome()
	br.get(url)

	try:
		element = WebDriverWait(br, 20).until(
			EC.presence_of_element_located((By.XPATH, "//*[@id=\"main-container\"]/div[2]/div/div[3]/div/div/div/div/div[5]"))
		)
	finally:

		html = br.page_source.encode('utf-8')
		soup = BeautifulSoup(html,'lxml')


	for page in range(10):
		for player in soup.find('table',{'class':'table'}).find_all('tr'):
			if len(player.find_all('td')) == len(df2.columns) and player.find_all('td')[3].get_text():
				df2.loc[player_index_1] = [player.find_all('td')[i].get_text() for i in range(len(df2.columns))]
				player_index_1 += 1

		br.find_element_by_css_selector("i.fa.fa-caret-right").click()

		html = br.page_source.encode('utf-8')
		soup = BeautifulSoup(html,'lxml')

	br.quit()


def get_data_3(url):
	global player_index_2
	br = webdriver.Chrome()
	br.get(url)

	try:
		element = WebDriverWait(br, 20).until(
			EC.presence_of_element_located((By.XPATH, "//*[@id=\"main-container\"]/div[2]/div/div[2]/div[2]/div/div/div/div/div[6]/div[2]/table/tbody/tr[1]/td[1]/a"))
		)
	finally:

		html = br.page_source.encode('utf-8')
		soup = BeautifulSoup(html,'lxml')


	for page in range(10):
		for player in soup.find('table',{'class':'table'}).find_all('tr'):
			if len(player.find_all('td')) == len(df3.columns) and player.find_all('td')[3].get_text():
				df3.loc[player_index_2] = [player.find_all('td')[i].get_text() for i in range(len(df3.columns))]
				player_index_2 += 1

		br.find_element_by_css_selector("i.fa.fa-caret-right").click()

		html = br.page_source.encode('utf-8')
		soup = BeautifulSoup(html,'lxml')

	br.quit()

if __name__ == "__main__":
	get_data_2(root1)
	get_data_3(root2)
	print(df2)
	print(df3)
	df2.to_csv('players_2.csv')
	df3.to_csv('players_3.csv')
