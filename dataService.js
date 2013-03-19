.pragma library

.import QtQuick.LocalStorage 2.0 as LS

var eventsNotifier = Qt.createQmlObject('import QtQuick 2.0; QtObject { signal dataChanged }', Qt.application, 'eventsNotifier')

var db = LS.LocalStorage.openDatabaseSync("Calendar", "", "Offline Calendar", 100000)
if (db.version == "") db.changeVersion("", "0.1", __createFirstTime)

function __loadTestData(tx)
{
    var inserts = '\
insert into Contact(id, name, surname) values (1, "John", "Smith");\
insert into Contact(id, name, surname) values (2, "Jane", "Smith");\
insert into Contact(id, name, surname, avatar) values (3, "Frank", "Mertens", "http://www.gravatar.com/avatar/6d96fd4a98bba7b8779661d5db391ab6");\
insert into Contact(id, name, surname) values (4, "Kunal", "Parmar");\
insert into Contact(id, name, surname) values (5, "Mario", "Boikov");\
insert into Place(id, name, address) values (1, "Quan Sen", "Pasing Arcaden, München");\
insert into Place(id, name, address) values (2, "Jashan", "Landsberger Straße 84, 82110 Germering");\
insert into Place(id, name, latitude, longitude) values (3, "Café Moskau", 52.521339, 13.42279);\
insert into Place(id, name, address) values (4, "Santa Clara Marriott", "2700 Mission College Boulevard, Santa Clara, California");\
insert into Place(id, name, address) values (5, "embeddedworld", "Messezentrum, 90471 Nürnberg");\
insert into Event(id, title, message, startTime, endTime) values (1, "Team Meeting", "Bring your gear...", 1364648400000, 1364650200000);\
insert into Event(id, title, message, startTime, endTime) values (2, "Jane\'s Birthday Party", "this year: southern wine", 1364061600000, 1364068800000);\
insert into Event(id, title, startTime, endTime) values (3, "embeddedworld 2013", 1361836800000, 1362009600000);\
insert into Attendance(eventId, contactId, placeId) values (1, 1, 1);\
insert into Attendance(eventId, contactId, placeId) values (1, 2, 1);\
insert into Attendance(eventId, contactId, placeId) values (1, 3, 1);\
insert into Attendance(eventId, contactId, placeId) values (1, 4, 3);\
insert into Attendance(eventId, contactId, placeId) values (1, 5, 3);\
insert into Attendance(eventId, contactId) values (2, 1);\
insert into Attendance(eventId, contactId) values (2, 2);\
insert into Attendance(eventId, contactId) values (2, 3);\
insert into Venue(eventId, placeId) values (2, 3);\
insert into Venue(eventId, placeId) values (3, 5);\
'.split(';')

    for (var i in inserts) {
        var sql = inserts[i]
        if (sql != "") {
            console.log(sql)
            tx.executeSql(sql)
        }
    }
}

function __createFirstTime(tx)
{
    var schema = '\
create table Event(\
    id integer primary key,\
    title text,\
    message text,\
    startTime integer,\
    endTime integer\
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

    for (var i in schema) {
        var sql = schema[i]
        if (sql != "") {
            console.log(sql)
            tx.executeSql(sql)
        }
    }

    __loadTestData(tx);
}

Array.prototype.append = function(x) { this.push(x) }

function getEvents(termStart, termEnd, events)
{
    var result = null

    db.readTransaction(
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

    for (var i = 0; i < result.rows.length; ++i)
        events.append(result.rows.item(i))

    return events
}

function getAttendees(event, attendees)
{
    var result = null;

    db.readTransaction(
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

    db.transaction(
        function(tx) {
            result = tx.executeSql('\
insert into Event(title, message, startTime, endTime) \
values (?, ?, ?, ?)',
                [ event.title, event.message, event.startTime, event.endTime ]
            )
        }
    )

    event.id = result.insertId

    eventsNotifier.dataChanged()

    return event
}

function removeEvent(event)
{
    db.transaction(
        function(tx) {
            tx.executeSql(
                'delete from Event where id = ?',
                [ event.id ]
            )
            tx.executeSql(
                'delete from Attendance where eventId = ?',
                [ event.id ]
            )
        }
    )

    eventsNotifier.dataChanged()
}

function getContacts(contacts)
{
    var result = null

    db.readTransaction(
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
    db.transaction(
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
    db.transaction(
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

    db.readTransaction(
        function(tx) {
            result = tx.executeSql('select * from Place')
        }
    )

    places = places || []

    for (var i = 0; i < result.rows.length; ++i)
        places.append(result.rows.item(i))

    return places
}

var test = Qt.include('runTests.js', {})
if (test.status == test.EXCEPTION) console.log(test.exception)
