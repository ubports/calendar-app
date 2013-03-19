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

var contacts = []
getContacts(contacts)
for (var i = 0; i < contacts.length; ++i)
    printContact(contacts[i])
console.log('')

var testEvent = addEvent({
    title: "Critical Review",
    message: "",
    startTime: new Date(2013, 2, 30, 10, 00).getTime(),
    endTime: new Date(2013, 2, 30, 10, 30).getTime()
})
addAttendee(testEvent, contacts[1])
addAttendee(testEvent, contacts[2])
addAttendee(testEvent, contacts[0])
removeAttendee(testEvent, contacts[0])
console.log('Added new event with id', testEvent.id)
console.log('')

var events = []
var dayStart = new Date(2013, 2, 30)
getEvents(dayStart.getTime(), dayStart.addDays(1).getTime(), events)
for (var i = 0; i < events.length; ++i) {
    var event = events[i]
    printEvent(event)
    var attendees = []
    getAttendees(event, attendees)
    for (var j = 0; j < attendees.length; ++j)
        printContact(attendees[j])
    console.log('')
}

removeEvent(testEvent)
