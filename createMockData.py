import csv
import elizabeth as el
import random

personal = el.Personal('pl')
business = el.Business('pl')
address = el.Address('pl')
datetime = el.Datetime('pl')
text = el.Text('pl')
num = el.Numbers()

dateRanges = []

def getEndDate(date):
    day = int(date[:2])
    day += random.randint(1,2)
    month = int(date[3:5])
    year = int(date[6:])
    if day > 31:
        day = day % 31
        month += 1
        if month > 12:
            month = month % 12
            year += 1
    day = str(day)
    if len(day) < 2:
        day = '0' + day
    month = str(month)
    if len(month) < 2:
        month = '0' + month
    year = str(year)
    return day + '-' + month + '-' + year

def incDate(date):
day = int(date[:2])
    day += 1
    month = int(date[3:5])
    year = int(date[6:])
    if day > 31:
        day = day % 31
        month += 1
        if month > 12:
            month = month % 12
            year += 1
    day = str(day)
    if len(day) < 2:
        day = '0' + day
    month = str(month)
    if len(month) < 2:
        month = '0' + month
    year = str(year)
    return day + '-' + month + '-' + year
    
with open('clientData.csv', 'wb') as clientOut:
    # The rows are: firstname, lastname, initial
    clientWriter = csv.writer(clientOut, delimiter='||')
    for i in range(10800):
        randGender = random.choice(['male', 'female'])
        randInitial = random.choice(text.alphabet(letter_case='upper'))
        clientWriter.writerow([personal.name(gender = randGender), personal.lastname, randInitial])
        
with open('companyData.csv', 'wb') as companyOut:
    # The rows are: companyname, address, city, country, zipcode
    companyWriter = csv.writer(companyOut, delimiter='||')
    for i in range(250):
        companyWriter.writerow([business.company(), address.street_name() + Address.street_number(),
                                address.city(), address.country(), address.postal_code()])
                                
                                
with open('conferenceData.csv', 'wb') as confOut:
    # The rows are: date_start, date_end, name, price
    confWriter = csv.writer(confOut, delimiter='||')
    for i in range(72):
        randDateStart = date.date(start = '2010', end = '2013', fmt='dd-mm-yyyy')
        randDateEnd = getEndDate(randDateStart)
        dateRanges.append([randDateStart, randDateEnd])
        confWriter.writerow([randDateStart, randDateEnd, text.title(), business.price()[:-2])
                                
with open('conferenceDaysData.csv', 'wb') as confDaysOut:
    # The rows are: date, num_spots
    confDayWriter = csv.writer(confDaysOut, delimiter='||')
    for dates in dateRanges:
        confDayDate = dates[0]
        while confDayDate != dates[1]:
            confDayWriter.writerow([confDayDate, random.randint(190, 210)])
            confDayDate = incDate(confDayDate)
        confDayWriter.writerow([confDayDate, random.randint(190, 210)])
        
with open('workshops.csv', 'wb') as workshopsOut
    # The rows are: title, num_spots, date, price
    workshopWriter = csv.writer(workshopsOut, delimiter='||')
    for dates in dateRanges:
        workshopDate = dates[0]
        while workshopDate != dates[1]:
            for i in range(random.randint(3,5)):
                workshopWriter.writerow([text.title(), random.randint(30, 50), workshopDate, business.price()[:-2]])
            workshopDate = incDate(workshopDate)
        for i in range(3):
            workshopWriter.writerow([text.title(), random.randint(30, 50), workshopDate, business.price()[:-2]])

