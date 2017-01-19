import csv
import elizabeth as el
import random
from itertools import groupby


personal = el.Personal('pl')
business = el.Business('pl')
address = el.Address('pl')
datetime = el.Datetime('pl')
text = el.Text('pl')
num = el.Numbers()

daysByMonth = {1:31, 2:28, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31}

datesUsed = set()
dateRanges = []
numConfDays = 0
attendByConfDay = dict()
attendByWorkshop = dict()
workshopsByConfDay = dict()
companiesByAttendee = dict()
confReserves = []
workshopReserves = []
priceByConfDay = {}
priceByWorkshop = {}
costByReserv = {}
dateByReserv = {}

def getEndDate(date):
    day = int(date[:2])
    day += random.randint(1,2)
    month = int(date[3:5])
    year = int(date[6:])
    if day > daysByMonth[month]:
        day = day % daysByMonth[month]
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
    return day + '.' + month + '.' + year

def incDate(date):
    day = int(date[:2])
    day += 1
    month = int(date[3:5])
    year = int(date[6:])
    if day > daysByMonth[month]:
        day = day % daysByMonth[month]
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
    return day + '.' + month + '.' + year
    
def chunked(lst, chunkSize):
    newLst = []
    for i in range(0, len(lst), chunkSize):
        newLst.append(lst[i : i + chunkSize])
    return newLst

def randCompanyOrNull():
    return random.choice([random.randint(1,250), ' '])
    
with open('clientData.csv', 'w', encoding='utf-16') as clientOut:
    # The rows are: client_id, company_id, studentcard_number, firstname, lastname, initial
    clientWriter = csv.writer(clientOut, delimiter='~')
    for i in range(10800):
        randGender = random.choice(['male', 'female'])
        randInitial = random.choice(text.alphabet()).upper()
        companyId = randCompanyOrNull()
        clientWriter.writerow([i + 1, companyId, ' ',
                               personal.name(gender = randGender), personal.surname(), randInitial])
        if companyId is not None: 
            companiesByAttendee[i + 1] = companyId
            
        
with open('companyData.csv', 'w', encoding='utf-16') as companyOut:
    # The rows are: company_id, companyname, address, city, country, zipcode
    companyWriter = csv.writer(companyOut, delimiter='~')
    for i in range(250):
        companyWriter.writerow([i + 1, business.company(), address.street_name() + ' ' + address.street_number(),
                                address.city(), address.country(), address.postal_code()])
                                
                                
with open('conferenceData.csv', 'w', encoding='utf-16') as confOut:
    # The rows are: conference_id date_start, date_end, name, price
    confWriter = csv.writer(confOut, delimiter='~')
    for i in range(72):
        randDateStart = datetime.date(start = 2010, end = 2013)
        randDateEnd = getEndDate(randDateStart)
        currDate = randDateStart
        breakOuter = False
        while currDate != incDate(randDateEnd):
            if currDate in datesUsed:
                breakOuter = True
            currDate = incDate(currDate)
        if breakOuter:
            break
        dateRanges.append([randDateStart, randDateEnd])
        confWriter.writerow([i + 1, randDateStart, randDateEnd, text.title()[:100]])
        used = randDateStart
        while used != randDateEnd:
            datesUsed.add(used)
            used = incDate(used)
        datesUsed.add(randDateEnd)
                                
with open('conferenceDaysData.csv', 'w', encoding='utf-16') as confDaysOut:
    # The rows are: conference_day_id, conference_id, date, num_spots
    confDayWriter = csv.writer(confDaysOut, delimiter='~')
    i = 1
    for idx, dates in enumerate(dateRanges):
        confDayDate = dates[0]
        while confDayDate != dates[1]:
            price = business.price()[:-2]
            priceByConfDay[i] = price
            confDayWriter.writerow([i, idx + 1, confDayDate, random.randint(190, 210), price])
            confDayDate = incDate(confDayDate)
            i += 1
        price = business.price()[:-2]
        priceByConfDay[i] = price
        confDayWriter.writerow([i, idx + 1, confDayDate, random.randint(190, 210), price])
        i += 1
    numConfDays = i
        
with open('conferenceAttendees.csv', 'w', encoding='utf-16') as confAttOut:
    # The rows: client_id, conference_day_id
    confAttendeesWriter = csv.writer(confAttOut, delimiter='~')
    for i in range(1, numConfDays + 1):
        attendeeIdSet = set()
        attendeesPerDay = random.randint(60, 70)
        while len(attendeeIdSet) < attendeesPerDay:
            attendeeIdSet.add(random.randint(0, 10800))
        attendByConfDay[i] = []
        for j in range(attendeesPerDay):
            attId = attendeeIdSet.pop()
            attendByConfDay[i].append(attId)
            confAttendeesWriter.writerow([attId, i])
            
        
with open('workshops.csv', 'w', encoding='utf-16') as workshopsOut:
    # The rows are: wokrshop_id, conference_day_id, title, num_spots, date, price
    workshopWriter = csv.writer(workshopsOut, delimiter='~')
    hours = [' 10:00', ' 14:00', ' 16:00', ' 18:00']
    idx = 1
    confDayIdx = 1
    for dates in dateRanges:
        workshopDate = dates[0]
        while workshopDate != dates[1]:
            workshopsByConfDay[confDayIdx] = []
            for i in range(random.randint(3,5)):
                price = business.price()[:-2]
                priceByWorkshop[idx] = price
                workshopWriter.writerow([idx, confDayIdx ,text.title()[:100], random.randint(30, 50), workshopDate + random.choice(hours), price])
                workshopsByConfDay[confDayIdx].append(idx)
                idx += 1
            workshopDate = incDate(workshopDate)
            confDayIdx += 1
        workshopsByConfDay[confDayIdx] = []
        for i in range(3):
            price = business.price()[:-2]
            priceByWorkshop[idx] = price
            workshopWriter.writerow([idx, confDayIdx, text.title()[:100], random.randint(30, 50), workshopDate + random.choice(hours), price])
            idx += 1
            workshopsByConfDay[confDayIdx].append(idx)

with open('workshopAttendees.csv', 'w', encoding='utf-16') as workshopAttOut:
    # Rows: client_id, workshop_id
    workshopAttWriter = csv.writer(workshopAttOut, delimiter='~')
    for idx, attList in attendByConfDay.items():
        if idx not in workshopsByConfDay:
            break
        workshops = workshopsByConfDay[idx]
        attChunks = chunked(attList, len(workshops))
        for i in range(len(workshops)):
            attendByWorkshop[workshops[i]] = []
            for attID in attChunks[i]:
                workshopAttWriter.writerow([attID, workshops[i]])
                attendByWorkshop[workshops[i]].append(attID)
                
with open('reservationDetails.csv', 'w', encoding='utf-16') as resDetOut:
    # Rows: reservation_details_is, client_id, company_id, payment_id, studencard_pool_id, cost, num_spots, reservation_date, reservation_cancellation_date
    resDetailsWriter = csv.writer(resDetOut, delimiter='~')
    attendeesByCompany = dict()
    soloAttendees = []
    i = 1
    for idx, attList in attendByConfDay.items():
        for att in attList:
            if att in companiesByAttendee:
                if companiesByAttendee[att] not in attendeesByCompany:
                    attendeesByCompany[companiesByAttendee[att]] = []
                attendeesByCompany[companiesByAttendee[att]].append(att)
            else:
                soloAttendees.append(att)
        for company, attList in attendeesByCompany.items():
            if idx not in priceByConfDay:
                break
            cost = len(attList) * (1 - 0.85) * float(priceByConfDay[idx])
            costByReserv[i] = cost
            date = datetime.date(start = 2008, end = 2009)
            dateByReserv[i] = date
            resDetailsWriter.writerow([i, ' ', company, i, ' ', cost, len(attList), date, ' '])
            confReserves.append([idx, i])
            i += 1
        for att in soloAttendees:
            if idx not in priceByConfDay:
                break
            cost = (1 - 0.85) * float(priceByConfDay[idx])
            costByReserv[i] = cost
            date = datetime.date(start = 2008, end = 2009)
            dateByReserv[i] = date
            resDetailsWriter.writerow([i, att, ' ', i, ' ', cost, 1, date, ' '])
            confReserves.append([idx, i])
            i += 1
    attendeesByCompany = dict()
    for idx, attList in attendByWorkshop.items():
        for att in attList:
            if att in companiesByAttendee:
                if companiesByAttendee[att] not in attendeesByCompany:
                    attendeesByCompany[companiesByAttendee[att]] = []
                attendeesByCompany[companiesByAttendee[att]].append(att)
            else:
                soloAttendees.append(att)
        for company, attList in attendeesByCompany.items():
            if idx not in priceByWorkshop:
                break
            cost = len(attList) * (1 - 0.85) * float(priceByWorkshop[idx])
            costByReserv[i] = cost
            date = datetime.date(start = 2008, end = 2009)
            dateByReserv[i] = date
            resDetailsWriter.writerow([i, ' ', company, i, ' ', cost, len(attList), date, ' '])
            workshopReserves.append([idx, i])
            i += 1
        for att in soloAttendees:
            if idx not in priceByWorkshop:
                break
            cost = (1 - 0.85) * float(priceByWorkshop[idx])
            costByReserv[i] = cost
            date = datetime.date(start = 2008, end = 2009)
            dateByReserv[i] = date
            resDetailsWriter.writerow([i, att, ' ', i, ' ', cost, 1, date, ' '])
            workshopReserves.append([idx, i])
            i += 1

with open('workshopReservations.csv', 'w', encoding='utf-16') as wshpResOut:
    wshpResWriter = csv.writer(wshpResOut, delimiter='~')
    i = 1
    for row in workshopReserves:
        wshpResWriter.writerow([i, row[0], row[1]])
        i += 1
        
with open('conferenceReservations.csv', 'w', encoding='utf-16') as confResOut:
    confResWriter = csv.writer(confResOut, delimiter='~')
    i = 1
    for row in confReserves:
        confResWriter.writerow([i, row[0], row[1]])
        i += 1
        
with open('payments.csv', 'w', encoding='utf-16') as paymentOut:
    paymentWriter = csv.writer(paymentOut, delimiter='~')
    for idx, cost in costByReserv.items():
        paymentWriter.writerow([idx, incDate(dateByReserv[idx]), cost])