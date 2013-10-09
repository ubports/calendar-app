.pragma library

.import QtQuick.LocalStorage 2.0 as LS

Array.prototype.append = function(x) { this.push(x) }

var CATEGORY_EVENT = 0
var CATEGORY_TODO = 1

function getEvents(termStart, termEnd, events)
{
    var result = null

    db().readTransaction(
        function(tx) {
            result = tx.executeSql('\
select * from Event \
where (? <= startTime and startTime < ?) or \
      (? < endTime and endTime <= ?) or \
      (startTime <= ? and ? <= endTime) \
order by startTime',
                [ termStart, termEnd, termStart, termEnd, termStart, termEnd ]
            )
        }
    )

    events = events || []

    for (var i = 0; i < result.rows.length; ++i) {
        var e = result.rows.item(i)
        e.startTime = new Date(e.startTime)
        e.endTime = new Date(e.endTime)
        events.append(e)
    }

    return events
}

function getAttendees(event, attendees)
{
    var result = null;

    db().readTransaction(
        function(tx) {
            result = tx.executeSql('\
select c.* from Attendance a, Contact c \
where a.eventId = ? and a.contactId = c.id \
order by c.name',
                [ event.id ]
            )
        }
    )

    attendees = attendees || []

    for (var i = 0; i < result.rows.length; ++i)
        attendees.append(result.rows.item(i))

    return attendees
}

function addEvent(event)
{
    var result = null

    db().transaction(
        function(tx) {
            result = tx.executeSql('\
insert into Event(title, message, startTime, endTime) \
values (?, ?, ?, ?)',
                [ event.title, event.message, event.startTime, event.endTime ]
            )
        }
    )

    event.id = result.insertId

    eventsNotifier().dataChanged()

    return event
}
function updateEvent(event)
{
    db().transaction(
        function(tx) {
            tx.executeSql(
                'update Event set title=?,message=?,startTime=?,endTime=? where id = ?',
                        [ event.title, event.message, event.startTime.getTime(), event.endTime.getTime() ,event.id ]
            )
        }
    )
}

function removeEvent(event)
{
    db().transaction(
        function(tx) {
            tx.executeSql(
                'delete from Event where id = ?',
                [ event.id ]
            )
            tx.executeSql(
                'delete from Attendance where eventId = ?',
                [ event.id ]
            )
            tx.executeSql(
                'delete from Venue where eventId = ?',
                [ event.id ]
            )
        }
    )

    delete event.id

    eventsNotifier().dataChanged()
}

function getContacts(contacts)
{
    var result = null

    db().readTransaction(
        function(tx) {
            result = tx.executeSql('select * from Contact order by name')
        }
    )

    contacts = contacts || []

    for (var i = 0; i < result.rows.length; ++i)
        contacts.append(result.rows.item(i))

    return contacts
}

function addAttendee(event, contact)
{
    db().transaction(
        function(tx) {
            tx.executeSql(
                'insert into Attendance(eventId, contactId) values (?, ?)',
                [ event.id, contact.id ]
            )
        }
    )
}

function removeAttendee(event, contact)
{
    db().transaction(
        function(tx) {
            tx.executeSql(
                'delete from Attendance where eventId = ? and contactId = ?',
                [ event.id, contact.id ]
            )
        }
    )
}

function getPlaces(places)
{
    var result = null

    db().readTransaction(
        function(tx) {
            result = tx.executeSql('select * from Place')
        }
    )

    places = places || []

    for (var i = 0; i < result.rows.length; ++i)
        places.append(result.rows.item(i))

    return places
}

function addPlace(place)
{
    var result = null

    if (typeof place.address == 'undefined') place.address = null
    if (typeof place.latitude == 'undefined') place.latitude = null
    if (typeof place.longitude == 'undefined') place.longitude = null

    db().transaction(
        function(tx) {
            result = tx.executeSql(
                'insert into Place(name, address, latitude, longitude) values(?, ?, ?, ?)',
                [ place.name, place.address, place.latitude, place.longitude ]
            )
        }
    )

    place.id = result.insertId

    return place
}

function removePlace(place)
{
    db().transaction(
        function(tx) {
            tx.executeSql(
                'delete from Place where id = ?',
                [ place.id ]
            )
            tx.executeSql(
                'delete from Venue where placeId = ?',
                [ place.id ]
            )
        }
    )

    delete place.id
}

function addVenue(event, place)
{
    db().transaction(
        function(tx) {
            tx.executeSql(
                'insert into Venue(eventId, placeId) values(?, ?)',
                [ event.id, place.id ]
            )
        }
    )
}

function removeVenue(event, place)
{
    db().transaction(
        function(tx) {
            tx.executeSql(
                'delete from Venue where eventId = ? and placeId = ?',
                [ event.id, place.id ]
            )
        }
    )
}

function getVenues(event, venues)
{
    var result = null

    db().readTransaction(
        function(tx) {
            result = tx.executeSql('\
select p.* \
from Venue v, Place p \
where v.eventId = ? and p.id = v.placeId \
order by p.name',
                [ event.id ]
            )
        }
    )

    venues = venues || []

    for (var i = 0; i < result.rows.length; ++i)
        venues.append(result.rows.item(i))

    return venues
}

function printEvent(event)
{
    console.log('Event', event)
    console.log('  id:', event.id)
    console.log('  title:', event.title)
    console.log('  message:', event.message)
    console.log('  startTime:', new Date(event.startTime).toLocaleString())
    console.log('  endTime:', new Date(event.endTime).toLocaleString())

    var attendees = []
    var venues = []
    getAttendees(event, attendees)
    getVenues(event, venues)
    for (var j = 0; j < attendees.length; ++j)
        printContact(attendees[j])
    for (var j = 0; j < venues.length; ++j)
        printPlace(venues[j])
    console.log('')
}

function printContact(contact)
{
    console.log('Contact', contact)
    console.log('  id:', contact.id)
    console.log('  name:', contact.name)
    console.log('  surname:', contact.surname)
    console.log('  avatar:', contact.avatar)
}

function printPlace(place)
{
    console.log('Place', place)
    console.log('  name:', place.name)
    console.log('  address:', place.address)
    console.log('  latitude:', place.latitude)
    console.log('  longitude:', place.longitude)
}

function __createFirstTime(tx)
{
    var schema = '\
create table Event(\
    id integer primary key,\
    title text,\
    message text,\
    startTime integer,\
    endTime integer,\
    category text default "Events"\
);\
\
create index EventStartTimeIndex on Event(startTime);\
create index EventEndTimeIndex on Event(endTime);\
\
create table Place(\
    id integer primary key,\
    name text,\
    address text,\
    latitude real,\
    longitude real\
);\
\
create table Contact(\
    id integer primary key,\
    name text,\
    surname text,\
    avatar text\
);\
\
create table Attendance(\
    id integer primary key,\
    eventId integer references Event(id) on delete cascade,\
    contactId integer references Contact(id) on delete cascade,\
    placeId integer references Place(id) on delete set null\
);\
\
create table Venue(\
    id integer primary key,\
    eventId integer references Event(id) on delete cascade,\
    placeId integer references Place(id) on delete cascade\
);\
\
'.split(';')

    for (var i = 0; i < schema.length; ++i) {
        var sql = schema[i]
        if (sql != "") {
            console.log(sql)
            tx.executeSql(sql)
        }
    }
}

function eventsNotifier()
{
    if (!eventsNotifier.hasOwnProperty("instance"))
        eventsNotifier.instance = Qt.createQmlObject('import QtQuick 2.0; QtObject { signal dataChanged }', Qt.application, 'DataService.eventsNotifier()')
    return eventsNotifier.instance
}

function db()
{
    if (!db.hasOwnProperty("instance")) {
        db.instance = LS.LocalStorage.openDatabaseSync("Calendar", "", "Offline Calendar", 100000)
        if (db.instance.version == "") db.instance.changeVersion("", "0.1", __createFirstTime)
    }
    return db.instance
}
