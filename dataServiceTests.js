.pragma library
.import "dateExt.js" as DateExt
.import "dataService.js" as DataService

function printEvent(event) {
    console.log('event:', event)
    console.log('  id:', event.id)
    console.log('  title:', event.title)
    console.log('  message:', event.message)
    console.log('  startTime:', new Date(event.startTime).toLocaleString())
    console.log('  endTime:', new Date(event.endTime).toLocaleString())
}

function printContact(contact) {
    console.log('contact:', contact)
    console.log('  id:', contact.id)
    console.log('  name:', contact.name)
    console.log('  surname:', contact.surname)
    console.log('  avatar:', contact.avatar)
}

function printPlace(place) {
    console.log('place:', place)
    console.log('  name:', place.name)
    console.log('  address:', place.address)
    console.log('  latitude:', place.latitude)
    console.log('  longitude:', place.longitude)
}

var contacts = []
DataService.getContacts(contacts)
for (var i = 0; i < contacts.length; ++i)
    printContact(contacts[i])
console.log('')

var testEvent = DataService.addEvent({
    title: 'Critical Review',
    message: '',
    startTime: new Date(2013, 2, 30, 10, 00).getTime(),
    endTime: new Date(2013, 2, 30, 10, 30).getTime()
})
DataService.addAttendee(testEvent, contacts[1])
DataService.addAttendee(testEvent, contacts[2])
DataService.addAttendee(testEvent, contacts[0])
DataService.removeAttendee(testEvent, contacts[0])
var testPlace = DataService.addPlace({ name: 'Jane\'s bar' })
DataService.addVenue(testEvent, testPlace)
console.log('Added new event with id', testEvent.id)
console.log('')

var events = []
var dayStart = new Date(2013, 2, 30)
DataService.getEvents(dayStart.getTime(), dayStart.addDays(1).getTime(), events)
for (var i = 0; i < events.length; ++i) {
    var event = events[i]
    printEvent(event)
    var attendees = []
    var venues = []
    DataService.getAttendees(event, attendees)
    DataService.getVenues(event, venues)
    for (var j = 0; j < attendees.length; ++j)
        printContact(attendees[j])
    for (var j = 0; j < venues.length; ++j)
        printPlace(venues[j])
    console.log('')
}

DataService.removeEvent(testEvent)
DataService.removePlace(testPlace)
