import csv
import elizabeth as el
import random
from collections import defaultdict
from datetime import datetime
from datetime import timedelta

personal = el.Personal('pl')
business = el.Business('pl')
address = el.Address('pl')
elDatetime = el.Datetime('pl')
text = el.Text('pl')
num = el.Numbers()

daysByMonth = {1:31, 2:28, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31}

clientsByCompany = defaultdict(list)
studentcardByAttendee = defaultdict(int)

numConfDays = 0
usedDates = set()
workshopsByConfDay = defaultdict(list)
priceByConfDay = defaultdict(float)
spotsByConfDay = defaultdict(int)
attendByConfDay = defaultdict(list)

priceByWorkshop = defaultdict(float)
spotsByWorkshop = defaultdict(int)
attendByWorkshop = defaultdict(list)
    
def chunked(lst, chunkSize):
    newLst = []
    for i in range(0, len(lst), chunkSize):
        newLst.append(lst[i : i + chunkSize])
    return newLst

def randCompanyOrNull():
    return random.choice([random.randint(1,250), ' '])

def randSCNumberOrNull():
    for i in range(100000, 999999):
        yield random.choice([i, None])
    
with open('clientData.csv', 'w', encoding='utf-16') as clientOut:
    # The rows are: client_id, company_id, studentcard_number, firstname, lastname, initial
    clientWriter = csv.writer(clientOut, delimiter='~')
    sc_number_gen = randSCNumberOrNull()
    for i in range(10800):
        randGender = random.choice(['male', 'female'])
        randInitial = random.choice(text.alphabet()).upper()
        companyId = randCompanyOrNull()
        studentcard_number = next(sc_number_gen)
        clientWriter.writerow([i + 1, companyId, studentcard_number, personal.name(gender = randGender), personal.surname(), randInitial])
        clientsByCompany[companyId].append(i + 1)
        if studentcard_number is not None:
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
    confDayWriter = csv.writer(confDaysOut, delimiter='~')
    workshopWriter = csv.writer(workshopsOut, delimiter='~')
    
    uidConfDay = 1
    uidWorkshop = 1
    
    hours = [' 10:00', ' 14:00', ' 16:00', ' 18:00']
    
    for i in range(72):
        confDuration = random.randint(1,3)
        randDateStart = datetime.strptime(elDatetime.date(start = 2010, end = 2013), "%d.%m.%Y")
        currentDateList = [randDateStart + timedelta(days=x) for x in range(0, confDuration)]
        
        # Break the outer loop if any of our dates is already used
        breakOuter = False
        for date in currentDateList:
            if date in usedDates:
                breakOuter = True
        if breakOuter:
            continue
                
        confWriter.writerow([i + 1, currentDateList[0].strftime("%d.%m.%Y"), currentDateList[-1].strftime("%d.%m.%Y"), text.title()[:100]])
        
        # Write conference day info data
        for j in range(confDuration):
            price = business.price()[:-2]
            priceByConfDay[uidConfDay] = price
            numSpots = random.randint(60, 70);
            spotsByConfDay[uidConfDay] = numSpots
            confDayWriter.writerow([uidConfDay, i, currentDateList[j].strftime("%d.%m.%Y"), numSpots, price])
            uidConfDay += 1
            numConfDays += 1
            
             # Create workshops for current conference day
            workshopCnt = random.randint(1,4)
            for k in range(workshopCnt):
                price = business.price()[:-2]
                spots = random.randint(30, 50)
                spotsByWorkshop[uidWorkshop] = spots
                priceByWorkshop[uidWorkshop] = price
                workshopsByConfDay[uidConfDay].append(uidWorkshop)
                
                workshopWriter.writerow([uidWorkshop, uidConfDay, text.title()[:100], spots, currentDateList[j].strftime("%d.%m.%Y") + random.choice(hours), price])
                
                uidWorkshop += 1
        
        usedDates.update(currentDateList)

        
with open('conferenceAttendees.csv', 'w', encoding='utf-16') as confAttOut, open('workshopAttendees.csv', 'w', encoding='utf-16') as workshopAttOut:
    # The rows: client_id, conference_day_id
    confAttendeesWriter = csv.writer(confAttOut, delimiter='~')
    workshopAttWriter = csv.writer(workshopAttOut, delimiter='~')
    for i in range(1, numConfDays + 1):
        attendeeIdSet = set()
        numSpots = spotsByConfDay[i]
        attendeesPerDay = random.randint(numSpots - 5, numSpots + 6)
        while len(attendeeIdSet) < attendeesPerDay:
            attendeeIdSet.add(random.randint(1, 10801))
        workshopAttendeeSet = attendeeIdSet.copy()
        while len(attendeeIdSet) != 0:
            attId = attendeeIdSet.pop()
            attendByConfDay[i].append(attId)
            confAttendeesWriter.writerow([attId, i])
        for workshopIdx in workshopsByConfDay[i]:
            for j in range(spotsByWorkshop[workshopIdx]):
                if len(workshopAttendeeSet) == 0:
                    break
                attId = workshopAttendeeSet.pop()
                workshopAttWriter.writerow([attId, workshopIdx])
                attendByWorkshop[workshopIdx].append(attId)
                
with open('reservationDetails.csv', 'w', encoding='utf-16') as resDetOut, open('studentCardPool.csv', 'w', encoding='utf-16') as studOut, open('payments.csv', 'w', encoding='utf-16') as paymentOut, open('workshopReservations.csv', 'w', encoding='utf-16') as wshpResOut, open('conferenceReservations.csv', 'w', encoding='utf-16') as confResOut:
    # Rows: reservation_details_is, client_id, company_id, payment_id, cost, num_spots, num_students, reservation_date, reservation_cancellation_date
    # Studentcardpool rows: res_details_id , studentcard_number
    # Payment rows: payment_id, date_paid, amount_paid
    # WorkshopRes rows: reservation_id, workshop_id, res_details_id
    # ConfRes rows: reservation_id, conference_day_id, res_details_id
    resDetailsWriter = csv.writer(resDetOut, delimiter='~')
    studOutWriter = csv.writer(studOut, delimiter='~')
    paymentWriter = csv.writer(paymentOut, delimiter='~')
    wshpResWriter = csv.writer(wshpResOut, delimiter='~')
    confResWriter = csv.writer(confResOut, delimiter='~')
    payReservStudID = 1
    for idx, attList in attendByConfDay.items():
        numAttByCompany = defaultdict(int)
        studentcards = defaultdict(list)
        attendees = set(attList)
        cmpnAttendees = set()
        for company, clientList in clientsByCompany.items():
            for client in clientList:
                if client in attendees:
                    numAttByCompany[company] += 1
                    if client in studentcardByAttendee:
                        studentcards[company].append(studentcardByAttendee[client])
                    cmpnAttendees.add(client)
        # Company reservations and payments
        for company, spots in numAttByCompany.items():
            cost = float(priceByConfDay[idx]) * 0.85 * (spots - len(studentcards[company])) + float(priceByConfDay[idx]) * 0.85 * len(studentcards[company]) * 0.9
            dateRes = datetime.strptime(elDatetime.date(start = 2008, end = 2009), "%d.%m.%Y")
            resDetailsWriter.writerow([payReservStudID, ' ', company, payReservStudID, cost, spots, len(studentcards[company]), dateRes.strftime("%d.%m.%Y"), ' '])
            confResWriter.writerow([idx, payReservStudID])
            datePaid = dateRes + timedelta(days=1)
            paymentWriter.writerow([payReservStudID, datePaid.strftime("%d.%m.%Y"), cost])
            for number in studentcards[company]:
                studOutWriter.writerow([payReservStudID, number])
            payReservStudID += 1
        # Solo attendees reservations and payments
        for client in attendees.difference(cmpnAttendees):
            if client in studentcardByAttendee:
                cost = float(priceByConfDay[idx]) * 0.85 * 0.9
                dateRes = datetime.strptime(elDatetime.date(start = 2008, end = 2009), "%d.%m.%Y")
                resDetailsWriter.writerow([payReservStudID, client, ' ', payReservStudID, cost, 1, 1, dateRes.strftime("%d.%m.%Y"), ' '])
                confResWriter.writerow([idx, payReservStudID])
                datePaid = dateRes + timedelta(days=2)
                paymentWriter.writerow([payReservStudID, datePaid.strftime("%d.%m.%Y"), cost])
                studOutWriter.writerow([payReservStudID, studentcardByAttendee[client]])
                payReservStudID += 1
            else:
                cost = float(priceByConfDay[idx]) * 0.85
                dateRes = datetime.strptime(elDatetime.date(start = 2008, end = 2009), "%d.%m.%Y")
                resDetailsWriter.writerow([payReservStudID, client, ' ', payReservStudID, cost, 1, 0, dateRes.strftime("%d.%m.%Y"), ' '])
                confResWriter.writerow([idx, payReservStudID])
                datePaid = dateRes + timedelta(days=2)
                paymentWriter.writerow([payReservStudID, datePaid.strftime("%d.%m.%Y"), cost])
                payReservStudID += 1
    for idx, attList in attendByWorkshop.items():
        numAttByCompany = defaultdict(int)
        studentcards = defaultdict(list)
        attendees = set(attList)
        cmpnAttendees = set()
        for company, clientList in clientsByCompany.items():
            for client in clientList:
                if client in attendees:
                    numAttByCompany[company] += 1
                    if client in studentcardByAttendee:
                        studentcards[company].append(studentcardByAttendee[client])
                    cmpnAttendees.add(client)
        # Company reservations and payments
        for company, spots in numAttByCompany.items():
            cost = float(priceByWorkshop[idx]) * 0.85 * (spots - len(studentcards[company])) + float(priceByWorkshop[idx]) * 0.85 * len(studentcards[company]) * 0.9
            dateRes = datetime.strptime(elDatetime.date(start = 2008, end = 2009), "%d.%m.%Y")
            resDetailsWriter.writerow([payReservStudID, ' ', company, payReservStudID, cost, spots, len(studentcards[company]), dateRes.strftime("%d.%m.%Y"), ' '])
            wshpResWriter.writerow([idx, payReservStudID])
            datePaid = dateRes + timedelta(days=1)
            paymentWriter.writerow([payReservStudID, datePaid.strftime("%d.%m.%Y"), cost])
            for number in studentcards[company]:
                studOutWriter.writerow([payReservStudID, number])
            payReservStudID += 1
        # Solo attendees reservations and payments
        for client in attendees:
            if client in studentcardByAttendee:
                cost = float(priceByWorkshop[idx]) * 0.85 * 0.9
                dateRes = datetime.strptime(elDatetime.date(start = 2008, end = 2009), "%d.%m.%Y")
                resDetailsWriter.writerow([payReservStudID, client, ' ', payReservStudID, cost, 1, 1, dateRes.strftime("%d.%m.%Y"), ' '])
                wshpResWriter.writerow([idx, payReservStudID])
                datePaid = dateRes + timedelta(days=2)
                paymentWriter.writerow([payReservStudID, datePaid.strftime("%d.%m.%Y"), cost])
                studOutWriter.writerow([payReservStudID, studentcardByAttendee[client]])
                payReservStudID += 1
            else:
                cost = float(priceByWorkshop[idx]) * 0.85
                dateRes = datetime.strptime(elDatetime.date(start = 2008, end = 2009), "%d.%m.%Y")
                resDetailsWriter.writerow([payReservStudID, client, ' ', payReservStudID, cost, 1, 0, dateRes.strftime("%d.%m.%Y"), ' '])
                wshpResWriter.writerow([idx, payReservStudID])
                datePaid = dateRes + timedelta(days=2)
                paymentWriter.writerow([payReservStudID, datePaid.strftime("%d.%m.%Y"), cost])
                payReservStudID += 1