.pragma library
.import "dateExt.js" as DateExt
.import "dataService.js" as DataService

function clearData(tx) {
    var deletes = '\
delete from Event;\
delete from Place;\
delete from Contact;\
delete from Attendance;\
delete from Venue\
'.split(';')
    for (var i = 0; i < deletes.length; ++i)
        tx.executeSql(deletes[i])
}

function loadTestDataSimple(tx)
{
    clearData(tx)

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
insert into Venue(eventId, placeId) values (3, 5)\
'.split(';')

    for (var i = 0; i < inserts.length; ++i) {
        var sql = inserts[i]
        if (sql != "") {
            console.log(sql)
            tx.executeSql(sql)
        }
    }
}

function loadTestDataComplex(tx)
{
    clearData(tx)

    function t(d, h, m) {
        if (typeof t.today == "undefined") t.today = new Date().midnight()
        return t.today.addDays(d).setHours(h, m)
    }

    var places = [
        { id: 1, name: "Moskau A" },
        { id: 2, name: "Moskau B" },
        { id: 3, name: "Bischkek" },
        { id: 4, name: "Asgabat A" },
        { id: 5, name: "Asgabat B" },
        { id: 6, name: "Vilnius" },
        { id: 7, name: "Riga" }
    ]

    var speaker = [
        { id: 1, name: "Sean", surname: "Harmer" },
        { id: 2, name: "Marc", surname: "Lutz" },
        { id: 3, name: "David", surname: "Faure" },
        { id: 4, name: "Volker", surname: "Krause" },
        { id: 5, name: "Kevin", surname: "Krammer" },
        { id: 6, name: "Tobias", surname: "Nätterlund" },
        { id: 7, name: "Steffen", surname: "Hansen" },
        { id: 8, name: "Tommi", surname: "Laitinen" },
        { id: 9, name: "Lars", surname: "Knoll" },
        { id: 10, name: "Roland", surname: "Krause" },
        { id: 11, name: "Jens", surname: "Bache-Wiig" },
        { id: 12, name: "Michael", surname: "Wagner" },
        { id: 13, name: "Helmut", surname: "Sedding" },
        { id: 14, name: "Jeff", surname: "Tranter" },
        { id: 15, name: "Simon", surname: "Hausmann" },
        { id: 16, name: "Stephen", surname: "Kelly" },
        { id: 17, name: "Tam", surname: "Hanna" },
        { id: 18, name: "Mirko", surname: "Boehm" },
        { id: 19, name: "Till", surname: "Adam" },
        { id: 20, name: "Thomas", surname: "Senyk" }
    ]

    var events = [
        { id: 1, room: 1, speaker: [ 1 ], title: "Modern OpenGL with Qt5", message: "hands-on training", startTime: t(0, 10, 00), endTime: t(0, 12 ,00) },
        { id: 2, room: 2, speaker: [ 2 ], title: "What's new in C++11", message: "focus on Qt5", startTime: t(0, 13, 00), endTime: t(0, 14, 30) },
        { id: 3, room: 3, speaker: [ 3 ], title: "Model/view Programming using Qt", message: "hands-on training", startTime: t(0, 14, 45), endTime: t(0, 16, 15) },
        { id: 4, room: 4, speaker: [ 4 ], title: "Introduction to Qt Quick", message: "hands-on training", startTime: t(0, 16, 30), endTime: t(0, 17, 45) },
        { id: 5, room: 1, speaker: [ 8 ], title: "Keynote: Qt – Gearing up for the Future", message: "", startTime: t(1, 9, 15), endTime: t(1, 9, 30) },
        { id: 6, room: 1, speaker: [ 9 ], title: "Keynote: Qt 5 Roadmap", message: "", startTime: t(1, 9, 30), endTime: t(1, 10, 30) },
        { id: 7, room: 3, speaker: [ 10 ], title: "Qt and the Google APIs", message: "", startTime: t(1, 10, 45), endTime: t(1, 11, 45) },
        { id: 8, room: 7, speaker: [ 11 ], title: "Desktop Components for QtQuick", message: "", startTime: t(1, 10, 45), endTime: t(1, 11, 45) },
        { id: 9, room: 2, speaker: [ 9 ], title: "The Future of Qt on Embedded Linux", message: "", startTime: t(1, 12, 45), endTime: t(1, 13, 45) },
        { id: 10, room: 7, speaker: [ 12, 13 ], title: "QML for desktop apps", message: "", startTime: t(1, 12, 45), endTime: t(1, 13, 34) },
        { id: 11, room: 2, speaker: [ 14 ], title: "Qt on Raspberry Pi", message: "", startTime: t(1, 14, 00), endTime: t(1, 15, 00) },
        { id: 12, room: 3, speaker: [ 15 ], title: "What's new in QtWebKit in 5.0", message: "", startTime: t(1, 14, 00), endTime: t(1, 15, 00) },
        { id: 13, room: 1, speaker: [ 16 ], title: "In Depth – QMetaType and QMetaObject", message: "", startTime: t(1, 15, 30), endTime: t(1, 16, 30) },
        { id: 14, room: 2, speaker: [ 17 ], title: "Using Qt as mobile cross-platform system", message: "", startTime: t(1, 15, 30), endTime: t(1, 16, 30) },
        { id: 15, room: 1, speaker: [ 18, 19 ], title: "Intentions good, warranty void: Using Qt in unexpected ways", message: "", startTime: t(1, 16, 45), endTime: t(1, 17, 45) },
        { id: 16, room: 2, speaker: [ 20 ], title: "Porting Qt 5 to embedded hardware", message: "", startTime: t(1, 16, 45), endTime: t(1, 17, 45) }
    ]

    for (var i = 0; i < places.length; ++i) {
        var p = places[i]
        tx.executeSql(
            'insert into Place(id, name, address) values (?, ?, ?)',
            [ p.id, p.name, "Cafe Moskau, Berlin, Germany" ]
        )
    }

    for (var i = 0; i < speaker.length; ++i) {
        var s = speaker[i]
        tx.executeSql(
            'insert into Contact(id, name, surname) values (?, ?, ?)',
            [ s.id, s.name, s.surname ]
        )
    }

    for (var i = 0; i < events.length; ++i) {
        var e = events[i]
        tx.executeSql(
            'insert into Event(id, title, message, startTime, endTime) values (?, ?, ?, ?, ?)',
            [ e.id, e.title, e.message, e.startTime, e.endTime ]
        )
        tx.executeSql(
            'insert into Venue(eventId, placeId) values (?, ?)',
            [ e.id, e.room ]
        )
        for (var j = 0; j < e.speaker.length; ++j) {
            tx.executeSql(
                'insert into Attendance(eventId, contactId) values (?, ?)',
                [ e.id, e.speaker[j] ]
            )
        }
    }
}

function runTestSimple(tx)
{
    loadTestDataSimple(tx)

    var contacts = []
    DataService.getContacts(contacts)
    for (var i = 0; i < contacts.length; ++i)
        DataService.printContact(contacts[i])
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
    for (var i = 0; i < events.length; ++i)
        DataService.printEvent(events[i])

    DataService.removeEvent(testEvent)
    DataService.removePlace(testPlace)
}

DataService.db.transaction(
    function (tx) {
        runTestSimple(tx)
        loadTestDataComplex(tx)
    }
)
