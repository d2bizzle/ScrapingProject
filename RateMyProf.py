# thanks to M. Aaron Owen for use of his code from last year
from selenium import webdriver
import time
import csv

# identify browser to use
driver = webdriver.Chrome()

# specify school - name should match Dictionaries used in other scripts
# - will simplify merge and concat of dataframes later
school = 'harvard'

# open file for writing
csv_file = open(school + '.csv', 'w')

# create writer
writer = csv.writer(csv_file)

# add key names for dictionary
writer.writerow(['name', 'department', 'school', 'overall_score', 'difficulty_score', 'grade', 'chili', 'tag_list', 'content'])

# website to start
topurl = "http://www.ratemyprofessors.com/search.jsp?queryBy=schoolId&schoolName=Harvard+University&schoolID=399&queryoption=TEACHER"
driver.get(topurl)


num_ratings = driver.find_element_by_xpath('//span[@class = "professor-count"]').text
# each button click adds 20 new reviews
if int(num_ratings) <= 20:
	button_clicks = 0
else:
	button_clicks = int(num_ratings) // 20
### ###

prof_urls = []
# the tag for the review container
profs = driver.find_elements_by_xpath('//div[@class = "result-list"]//a')
for prof in profs:
	# if there are reviews, then grab the number of them
	if "ShowRatings" in prof.get_attribute("href"):
		num_reviews = prof.find_element_by_xpath('.//span[@class = "info"]').text.split(" ")[0]
		# if the number is >= 20, add it to the list
		if int(num_reviews) >= 1:
			prof_urls.append(prof.get_attribute("href"))

# now that we have the list of urls, we can scrape the ratings
for url in prof_urls:
	# wait 2 seconds before visiting the next url
	time.sleep(2)

	# initialize the driver as the specific prof's webpage
	driver.get(url)

	# getting the prof's name
	last_name = driver.find_element_by_xpath('//span[@class = "plname"]').text + ", "
	first_name = driver.find_element_by_xpath('//span[@class = "pfname"]').text
	name = last_name + first_name

	# printing so that I can keep track of what's being scraped
	print(name)
	print(url)

	# collecting the number of ratings for the prof to know how many times to click the button
	num_ratings = driver.find_element_by_xpath('//div[@data-table = "rating-filter"]').text.split(" ")[0]

	# need this if you want to extend to cases when reviews are less than 20
	if int(num_ratings) <= 20:
		button_clicks = 0
	else:
		button_clicks = int(num_ratings) // 20

	# initializing the button -this causes problems when reviews are <= 20
	if button_clicks > 0:
		button = driver.find_element_by_xpath('//a[@id = "loadMore"]')
	# clicking the button the desired number of times
	for i in range(button_clicks):
		driver.execute_script("arguments[0].click();", button)
		print("single prof page button click " + str(i + 1))
		time.sleep(2)

	# the reviews have different tags as either class = '' or class = 'even'
	reviews1 = driver.find_elements_by_xpath('//table[@class = "tftable"]//tr[@class = ""]')
	reviews2 = driver.find_elements_by_xpath('//table[@class = "tftable"]//tr[@class = "even"]')

	# getting the department
	department = driver.find_element_by_xpath('//div[@class = "result-title"]').text
	department = department.split("\n")[0]

	# True if the word "hot" is in the attribute
	chili = driver.find_element_by_xpath('//div[@class = "breakdown-section"]//img').get_attribute("src")
	chili = "hot" in chili

	# initializing an empty dictionary to store reviews, professor and school information
	review_dict = {}

	# Reviews are stored separately in odd and even rows.  First, we will start with info from
	# odd reviews
	for ind, review in enumerate(reviews1):
		print("reviews - 1 " + str(ind))
		review_dict = {}
		review2 = review.text.split("\n")
		overall_score = review2[2]
		difficulty_score = review2[4]
		grade = review2[11].split(" ")[2]

		content = review.find_element_by_xpath('.//p').text

		tag_list = []
		raw_tags = review.find_elements_by_xpath('.//div[@class = "tagbox"]//span')
		for i in range(0, len(raw_tags)):
			tag_list.append(raw_tags[i].text)

		review_dict["name"] = name
		review_dict["department"] = department
		review_dict["school"] = school
		review_dict["overall_score"] = overall_score
		review_dict["difficulty_score"] = difficulty_score
		review_dict["grade"] = grade
		review_dict["chili"] = chili
		review_dict["tag_list"] = tag_list
		review_dict["content"] = content
		writer.writerow(review_dict.values())

	# collecting the even rows and putting information in the dictionary
	for ind, review in enumerate(reviews2):
		print("reviews - 2 " + str(ind))
		review_dict = {}
		review2 = review.text.split("\n")
		overall_score = review2[2]
		difficulty_score = review2[4]
		grade = review2[11].split(" ")[2]

		content = review.find_element_by_xpath('.//p').text

		tag_list = []
		raw_tags = review.find_elements_by_xpath('.//div[@class = "tagbox"]//span')
		for i in range(0, len(raw_tags)):
			tag_list.append(raw_tags[i].text)

		review_dict["name"] = name
		review_dict["department"] = department
		review_dict["school"] = school
		review_dict["overall_score"] = overall_score
		review_dict["difficulty_score"] = difficulty_score
		review_dict["grade"] = grade
		review_dict["chili"] = chili
		review_dict["tag_list"] = tag_list
		review_dict["content"] = content
		writer.writerow(review_dict.values())

# closing the driver
driver.close()
