# script to scrape selected schools from gradeinflation.com
import requests
from bs4 import BeautifulSoup
import pandas as pd

# define main site to scrape and identify list of schools
base = 'http://www.gradeinflation.com/'

UrlDict = {'Vanderbilt': 'Vanderbilt.html','Cornell': 'Cornell.html','Berkeley': 'Ucberkeley.html','UNC': 'Northcarolina.html','Michigan':'Michigan.html','Alabama':'Alabama.html', \
'Lehigh':'Lehigh.html', 'KState': 'Kansasstate.html', 'Clemson':'Clemson.html', 'WState':'Washingtonstate.html', 'VTech': 'Virginiatech.html','CaseW': 'Casewestern.html','RPI':'Rensselaer.html',\
'GTech':'Georgiatech.html','Purdue':'Purdue.html','Montclair':'Montclairstate.html','Wright': 'Wrightstate.html', 'JamesM':'Jamesmadison.html','Towson':'Towson.html','SConn':'Southernconnecticut.html',\
'WMary':'Williamandmary.html','Vassar':'Vassar.html','Kenyon':'Kenyon.html','Allegheny':'Allegheny.html','Siena':'Siena.html'}

# extract lists from Dictionary to use in loop
Schools = [x[0] for x in list(UrlDict.items())]
Urls = [x[1] for x in list(UrlDict.items())]

# define empty dataframe and list to use
GradesList = []
gradeinflation = pd.DataFrame(columns=['year','GPA','school'])

# loop runs through list of schools and extracts html table rows from each page
for i in range(0,len(Schools)):
    grades = []
    school = Schools[i]
    url = Urls[i]
    site = base  +  url
    # use beautiful soup to parse text from html
    ugly = requests.get(site).text
    soup = BeautifulSoup(ugly, 'html.parser')
    # identify table that is needed, find all rows.  Even though there are multiple tables of this class, .find only returns first result
    table = soup.find('table', {'class':'MsoNormalTable'})
    rows = table.find_all('tr')
    # now find all columns and strip out text
    for row in rows:
        cols = row.find_all('td')
        cols = [ele.text.strip() for ele in cols]
        grades.append([ele for ele in cols if ele])
    # create dataframe for this school and append to composite frame
    gradeframe = pd.DataFrame(grades)
    gradeframe.columns= ['year', 'GPA']
    gradeframe['school'] = school
    GradesList.append(gradeframe)
    # write frame to file after concateneting
gradeinflation = pd.concat(GradesList).reset_index(drop=True)
gradeinflation.to_csv('inflation.csv')
