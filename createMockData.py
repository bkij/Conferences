import csv
import elizabeth as el
import random
from itertools import groupby
from datetime import datetime
from datetime import timedelta

personal = el.Personal('pl')
business = el.Business('pl')
address = el.Address('pl')
elDatetime = el.Datetime('pl')
text = el.Text('pl')
num = el.Numbers()

daysByMonth = {1:31, 2:28, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31}

usedDates = set()
numConfDays = 0
workshopsByConfDay = defaultdict()
attendeesByCompany = defaultdict()
studentcardByAttendee = defaultdict()

attendByConfDay = dict()
attendByWorkshop = dict()
confReserves = []
workshopReserves = []
priceByConfDay = {}
priceByWorkshop = {}
costByReserv = {}
dateByReserv = {}
    
def chunked(lst, chunkSize):
    newLst = []
    for i in range(0, len(lst), chunkSize):
        newLst.append(lst[i : i + chunkSize])
    return newLst

def randCompanyOrNull():
    return random.choice([random.randint(1,250), ' '])

def randSCNumberOrNull():
    return random.choice([random.randint(100000, 999999)])
    
with open('clientData.csv', 'w', encoding='utf-16') as clientOut:
    # The rows are: client_id, company_id, studentcard_number, firstname, lastname, initial
    clientWriter = csv.writer(clientOut, delimiter='~')
    for i in range(10800):
        randGender = random.choice(['male', 'female'])
        randInitial = random.choice(text.alphabet()).upper()
        companyId = randCompanyOrNull()
        studentcard_number = randSCNumberOrNull()
        clientWriter.writerow([i + 1, companyId, studentcard_number, personal.name(gender = randGender), personal.surname(), randInitial])
        attendeesByCompany[companyId].append(i + 1)
        studentcardByAttendee[i + 1] = studentcard_number

with open('companyData.csv', 'w', encoding='utf-16') as companyOut:
    # The rows are: company_id, companyname, address, city, country, zipcode
    companyWriter = csv.writer(companyOut, delimiter='~')
    for i in range(250):
        companyWriter.writerow([i + 1, business.company(), address.street_name() + ' ' + address.street_number(), address.city(), address.country(), address.postal_code()])
                                
                                
with open('conferenceData.csv', 'w', encoding='utf-16') as confOut, open('conferenceDaysData.csv', 'w', encoding='utf-16') as confDaysOut, open('workshops.csv', 'w', encoding='utf-16') as workshopsOut:
    # The conference rows are: conference_id date_start, date_end, name, price
    # The workshops rows are: wokrshop_id, conference_day_id, title, num_spots, date, price
    # The conference day rows are: conference_day_id, conference_id, date, num_spots, price
    confWriter = csv.writer(confOut, delimiter='~')
    confDayWriter = csv.writer(confDaysOur, delimiter='~')
    workshopWriter = csv.writer(workshopsOut, delimiter='~')
    
    uidConfDay = 1
    uidWorkshop = 1
    
    hours = [' 10:00', ' 14:00', ' 16:00', ' 18:00']
    
    for i in range(72):
        confDuration = random.randint(1,3)
        randDateStart = datetime.srptime(elDatetime.date(start = 2010, end = 2013), "%d.%m.%y"))
        currentDateList = [randDateStart + datetime.timedelta(days=x) for x in range(0, confDuration)]
        
        # Break the outer loop if any of our dates is already used
        for date in currentDateList:
            if date in usedDates:
                break
        else:
            continue
                   
        confWriter.writerow([i + 1, currentDateList[0].strftime("%d.%m.%y"), currentDateList[-1].strftime("%d.%m.%y"), text.title()[:100]])
        
        # Write conference day info data
        for j in range(confDuration):
            price = business.price()[:-2]
            priceByConfDay[uid] = price
            confDayWriter.writerow([uidConfDay, i, currentDateList[j].strftime("%d.%m.%y"), random.randint(190, 210), price])
            uidConfDay += 1
            numConfDays += 1
            
             # Create workshops for current conference day
            workshopCnt = random.randint(1,4)
            for k in range(workshopCnt):
                price = business.price()[:-2]
                priceByWorkshop[uidWorkshop] = price
                workshopsByConfDay[uidConfDay].append(uidWorkshop)
                
                workshopWriter.writerow([uidWorkshop, uidConfDay, text.title()[:100], random.randint(30, 50), currentDateList[j].strftime("%d.%m.%y") + random.choice(hours), price])
                
                uidWorkshop += 1
        
        usedDates.update(currentDateList)

        
with open('conferenceAttendees.csv', 'w', encoding='utf-16') as confAttOut, open('workshopAttendees.csv', 'w', encoding='utf-16') as workshopAttOu:
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
            date = elDatetime.date(start = 2008, end = 2009)
            dateByReserv[i] = date
            resDetailsWriter.writerow([i, ' ', company, i, ' ', cost, len(attList), date, ' '])
            confReserves.append([idx, i])
            i += 1
        for att in soloAttendees:
            if idx not in priceByConfDay:
                break
            cost = (1 - 0.85) * float(priceByConfDay[idx])
            costByReserv[i] = cost
            date = elDatetime.date(start = 2008, end = 2009)
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
            date = elDatetime.date(start = 2008, end = 2009)
            dateByReserv[i] = date
            resDetailsWriter.writerow([i, ' ', company, i, ' ', cost, len(attList), date, ' '])
            workshopReserves.append([idx, i])
            i += 1
        for att in soloAttendees:
            if idx not in priceByWorkshop:
                break
            cost = (1 - 0.85) * float(priceByWorkshop[idx])
            costByReserv[i] = cost
            date = elDatetime.date(start = 2008, end = 2009)
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