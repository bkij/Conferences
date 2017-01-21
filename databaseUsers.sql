-- users of database CONFERENCES
Do sprawnego zarz�dzania stworzonym systemem bazodanowym konieczne jest zdefiniowanie u�ytkownik�w oraz ich uprawnie�.

******administrator******
- pe�en dost�p do bazy

******pracownik firmy organizuj�cej konferencje******
- procedury:	tworzenie rezerwacji, warsztatu (CREATE_RESERVATION)
				zmiana ilo�ci miejsc na warsztatach, 
				zmiana limitu miejsc w danym dniu konferencji (NUM_SPOTS_CHANGE,NUM_SPOTS_CONFERENCE_DAY)
				anulowanie rezerwacji na konferencj� (RESERVATION_CANCELLATION_CR)
				anulowanie rezerwacji na warsztat (RESERVATION_CANCELLATION_WS)	
- widoki:		listy osobowe uczestnik�w konferencji na dany dzie� (CONFERENCE_ATTENDEES_PER_DAY)
				listy osobowe uczestnik�w warsztatu na dany dzie� (WORKSHOP_ATTENDEES_PER_DAY)
				lista anulowanych rezerwacji ([Cancelled reservations])
				najpopularniejsze konferencje ([The most popular conferences])
				najpopularniejsze warsztaty ([The most popular workshops])
				lista p�atno�ci danego klienta (PAYMENTS_LIST_PER_CLIENT) 
				lista p�atno�ci danej firmy (PAYMENTS_LIST_PER_COMPANY)
				lista klient�w najcz�ciej korzystaj�cych z us�ug ([THE LIST OF MOST FREQUENT CLIENTS GETING THE SERVICES])
				lista firm najcz�ciej korystaj�cych z us�ug ([THE LIST OF MOST FREQUENT COMPANIES GETTING THE SERVICES])


******klient******
- procedura:	zmiana ilo�ci miejsc w rezerwacji (NUM_SPOTS_RESERVATION_CHANGE)
				anulowanie rezerwacji na konferencj� (RESERVATION_CANCELLATION_CR)
				anulowanie rezerwacji na warsztat (RESERVATION_CANCELLATION_WS)

