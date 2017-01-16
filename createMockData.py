import elizabeth as el
import random

personal = el.Personal('pl')
business = el.Business('pl')
address = el.Address('pl')
datetime = el.Datetime('pl')
text = el.Text('pl')

with open('clientData.csv', 'wb') as clientOut:
    # The rows are: firstname, lastname, initial
    clientWriter = csv.writer(clientOut, delimiter=',')
    for i in range(0, 10800):
        randGender = random.choice(['male', 'female'])
        randInitial = random.choice(text.alphabet(letter_case='upper'))
        clientWriter.writerow([personal.name(gender = randGender), personal.lastname, randInitial])
        
with open('companyData.csv', 'wb') as companyOut:
    # The rows are: companyname, address, city, country, zipcode
    companyWriter = csv.writer(companyOut, delimiter=',')
    for i in range(0, 250):
        companyWriter.writerow([business.company(), address.street_name() + Address.street_number(),
                                address.city(), address.country(), address.postal_code()])
                                
