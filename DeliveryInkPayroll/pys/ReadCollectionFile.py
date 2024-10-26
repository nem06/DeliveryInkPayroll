import csv
import time

from pypdf import PdfReader
import re
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

ids = ['D46', 'D47']
endDate = '2024-10-06'
collectionList = {}
collectionRouteMapping = {}

for id in ids:
    mappingFile = open('D:\\Dahna\\Container\\Files\\' + id + '-Subs.csv', 'r', encoding='utf-8-sig')
    csv_reader = csv.reader(mappingFile)
    for row in csv_reader:
        collectionRouteMapping[row[3]] = row[14]

    file = PdfReader('D:\\Dahna\\Container\\Files\\' + endDate + '\\InputFiles\\' + id + '_Collections.pdf')
    totalPages = len(file.pages)

    for i in range(1, totalPages):
        acc = (re.search('Name:(.*)[\d][\d]/', file.pages[i].extract_text())).group(1)
        acc = acc[0:(acc.index('/') - 2)]
        amount = (re.findall('\$\d+\.\d+\$', file.pages[i].extract_text()))[0]
        amount = amount[1:-1]
        name = file.pages[i].extract_text().splitlines()[3]
        address = file.pages[i].extract_text().splitlines()[12]
        number = (file.pages[i].extract_text().splitlines()[7])[0:10]
        period = re.search('\d{2}/\d{2}/\d{2}\s+to\s+\d{2}/\d{2}/\d{2}', file.pages[i].extract_text()).group(0)
        collectionList[acc] = [acc, amount, name, address, collectionRouteMapping[acc]]
        if(len(file.pages[i].extract_text().splitlines()) > 30):
            acc = (re.search('Name:(.*)[\d][\d]/', file.pages[i].extract_text())).group(1)
            acc = acc[0:(acc.index('/') - 2)]
            amount = (re.findall('\$\d+\.\d+\$', file.pages[i].extract_text()))[3]
            amount = amount[1:-1]
            name = file.pages[i].extract_text().splitlines()[19]
            address = file.pages[i].extract_text().splitlines()[28]
            number = (file.pages[i].extract_text().splitlines()[23])[0:10]
            period = re.search('\d{2}/\d{2}/\d{2}\s+to\s+\d{2}/\d{2}/\d{2}', file.pages[i].extract_text()).group(0)
            collectionList[acc + "_1"] = [acc, amount, name, address, collectionRouteMapping[acc]]



# chrome_options = Options()
# chrome_options.add_argument("--new-tab")
# chrome_options.add_argument("--start-maximized")
# chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
# driver = webdriver.Chrome(options=chrome_options)
# driver.get("https://dart.delivery/ui/startmail/dart.web.accountinfo/default.aspx")
#
# driver.find_element("xpath", '//*[@id="root"]/div/div[2]/div[1]/div/div/div/div/div[3]/div/input').send_keys('aadam')
# driver.find_element("xpath", '//*[@id="root"]/div/div[2]/div[1]/div/div/div/div/div[4]/div/input').send_keys('aadam1')
# driver.find_element("xpath", '//*[@id="login-btn"]').click()
# time.sleep(2)
# driver.get('https://dart.delivery/ui/startmail/dart.web.accountinfo/default.aspx')
# time.sleep(2)
# for collection in collectionList:
#     driver.find_element("xpath", '//*[@id="MainContent_txtAccountNum"]').clear()
#     driver.find_element("xpath", '//*[@id="MainContent_txtAccountNum"]').send_keys(collection)
#     driver.find_element("xpath", '//*[@id="MainContent_btnGetAccountInfo"]').click()
#     while True:
#         try:
#             driver.find_element("xpath", '//*[@id="MainContent_TabContainer1_tabRouteHistory_tab"]/span/span').click()
#             time.sleep(1)
#             route = driver.find_element("xpath", '//*[@id="MainContent_TabContainer1_tabRouteHistory_gvRouteHistory"]/tbody/tr[2]/td[4]').text
#             collectionList[collection].append(route)
#             break
#         except Exception as err:
#             time.sleep(3)


with open('D:\\Dahna\\Container\\Files\\' + endDate + '\\InputFiles\\CollectionList.csv', 'w', newline='', encoding='utf-8-sig') as update_file:
    writer = csv.writer(update_file)
    for collection in collectionList:
        writer.writerow(collectionList[collection])
