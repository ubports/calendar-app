import QtQuick 2.0
import QtTest 1.0
import QtOrganizer 5.0

import "../../calendar_canvas.js" as CanvasJs

TestCase{
    id: root
    name: "Date tests"

    Component {
        id: modelComp

        OrganizerModel {
            id: eventModel

            manager: "memory"
            startPeriod: new Date(2016, 7, 2, 0, 0, 0, 0)
            endPeriod: new Date(2016, 13, 2, 0, 0, 0, 0)
            autoUpdate: true
        }
    }

    Component {
        id: eventComp

        Event {
        }
    }

    Component {
        id: spyComp

        SignalSpy {
            id: spy
            signalName: "onModelChanged"
        }
    }

    WorkerScript {
        id: worker

        property var reply: null
        property var eventsById: []
        property bool done: false

        function start(model, startDate)
        {
            worker.done = false
            worker.reply = null
            worker.eventsById = []

            var itemsOfTheDay = model.itemsByTimePeriod(startDate.midnight(), startDate.endOfDay())
            for(var i=0; i < itemsOfTheDay.length; i++) {
                var e = itemsOfTheDay[i]
                worker.eventsById[e.itemId] = e
            }

            console.debug("Items of Day:"+ itemsOfTheDay.length)

            var events = CanvasJs.parseDayEvents(startDate.midnight(), itemsOfTheDay)
            console.debug("Events:" + events.length)
            worker.sendMessage({'events': events})
        }

        source: Qt.resolvedUrl("../../calendar_canvas_worker.js")
        onMessage: {
            var reply =  messageObject.reply
            console.debug("Reply:" + reply.length)
            for(var i=0; i < reply.length; i++) {
                var info = reply[i]
                console.debug("I:" + i + " id:" + info.eventId + " e:" + worker.eventsById[info.eventId])
                info['event'] = worker.eventsById[info.eventId]
            }
            reply.sort(sortEventsByDateAndY)
            worker.reply =reply
            worker.done = true
        }
    }

    function create_event_from_data(model, data)
    {
        return eventComp.createObject(model,
                                      {'allDay': false,
                                       'displayLabel': data.label,
                                       'startDateTime': data.startDate,
                                       'endDateTime': data.endDate})
    }

    function create_events(data)
    {
        var model = modelComp.createObject(root, {});
        var spy = spyComp.createObject(root, {'target': model})

        for(var i=0; i < data.length; i++) {
            var ev = create_event_from_data(model, data[i])
            model.saveItem(ev)
            tryCompare(spy, 'count', i+1)
        }
        compare(model.itemCount, data.length)
        return model
    }

    function debug_map(map)
    {
        for(var k in map) {
            var info = map[k]
            console.debug("\t" + (info.event ? info.event.displayLabel : "null") + " y:" + info.y)
        }
    }

    function sortEventsByDateAndY(eventA, eventB)
    {
        if (eventA.startTime < eventB.startTime)
            return -1
        else if (eventA.startTime > eventB.startTime)
            return 1
        else {
            if (eventA.y < eventB.y)
                return -1
            else if (eventA.y > eventB.y)
                return 1
        }
        return 0
    }

    //    10:00 ----
    //          |XX|
    //    11:00 ----

    //    12:00

    //    13:00 ----
    //          ----
    //    14:00
    function test_two_events_in_distinct_time()
    {
        var data = [{startDate: new Date(2016, 7, 2, 13, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 13, 30, 0, 0),
                     label: "Event at 13:00 until 13:30"},
                    {startDate: new Date(2016, 7, 2, 10, 10, 0, 0),
                     endDate: new Date(2016, 7, 2, 11, 00, 0, 0),
                     label: "Event at 10:10 until 11:00"}]
        var model = create_events(data)

        var startDate = new Date(2016, 7, 2, 11, 11, 11, 11)
        worker.start(model, startDate)
        tryCompare(worker, 'done', true)

        var eventMap = worker.reply
        //"Event at 10:10 until 11:00"
        var eventsAtTenTen = eventMap[0]
        compare(eventsAtTenTen.event.displayLabel, "Event at 10:10 until 11:00")
        compare(eventsAtTenTen.y, 0)

        //"Event at 13:00 until 13:30"
        var eventsAtOnePm = eventMap[1]
        compare(eventsAtOnePm.event.displayLabel, "Event at 13:00 until 13:30")
        compare(eventsAtTenTen.y, 0)
    }

    //    13:00 ---- ----
    //          |XX| |XX|
    //    14:00 ---- ----
    //
    //    15:00
    function test_two_events_at_the_same_time()
    {
        var data = [{startDate: new Date(2016, 7, 2, 13, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 13, 30, 0, 1),
                     label: "Event at 13:00 until 13:30"},
                    {startDate: new Date(2016, 7, 2, 13, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 13, 30, 0, 0),
                     label: "Event at 13:00 until 13:30 (1)"}]
        var model = create_events(data)

        var startDate = new Date(2016, 7, 2, 11, 11, 11, 11)
        worker.start(model, startDate)
        tryCompare(worker, 'done', true)
        var eventMap = worker.reply

        //"Event at 13:00 until 13:30"
        var eventsAtOnePm = eventMap[0]
        compare(eventsAtOnePm.event.displayLabel, "Event at 13:00 until 13:30")
        compare(eventsAtOnePm.y, 0)

        eventsAtOnePm = eventMap[1]
        compare(eventsAtOnePm.event.displayLabel, "Event at 13:00 until 13:30 (1)")
        compare(eventsAtOnePm.y, 1)
    }

    //    13:00 ----
    //          |XX|
    //    14:00 |XX| ----
    //          |XX| |XX|
    //    15:00 |XX| ----
    //          ----
    //    16:00
    function test_intersec_two_events()
    {
        var data = [{startDate: new Date(2016, 7, 2, 13, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 15, 30, 0, 0),
                     label: "Event at 13:00 until 15:30"},
                    {startDate: new Date(2016, 7, 2, 14, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 15, 00, 0, 0),
                     label: "Event at 14:00 until 15:00"}]
        var model = create_events(data)

        var startDate = new Date(2016, 7, 2, 11, 11, 11, 11)
        worker.start(model, startDate)
        tryCompare(worker, 'done', true)
        var eventMap = worker.reply

        //"Event at 13:00 until 15:30"
        var eventsAtOnePm = eventMap[0]
        compare(eventsAtOnePm.event.displayLabel, "Event at 13:00 until 15:30")
        compare(eventsAtOnePm.y, 0)

        //Event at 14:00 until 15:00
        var eventsAtTwoPm = eventMap[1]
        compare(eventsAtTwoPm.event.displayLabel, "Event at 14:00 until 15:00")
        compare(eventsAtTwoPm.y, 1)
    }

    //    13:00 ----
    //          |XX| ----
    //    14:00 |XX| |XX|
    //          |XX| |XX|
    //    15:00 |XX| |XX| ----
    //          ---- ---- |XX|
    //    16:00           |XX|
    //                    |XX|
    //    17:00           |XX|
    //                    |XX|
    //    18:00           |XX|
    //                    |XX|
    //    19:00           ----
    function test_intersec_three_events()
    {
        var data = [{startDate: new Date(2016, 7, 2, 13, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 15, 30, 0, 0),
                     label: "Event at 13:00 until 15:30"},
                    {startDate: new Date(2016, 7, 2, 13, 30, 0, 0),
                     endDate: new Date(2016, 7, 2, 15, 30, 0, 0),
                     label: "Event at 13:30 until 15:30"},
                    {startDate: new Date(2016, 7, 2, 15, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 19, 00, 0, 0),
                     label: "Event at 15:00 until 19:00"}]
        var model = create_events(data)

        var startDate = new Date(2016, 7, 2, 11, 11, 11, 11)
        worker.start(model, startDate)
        tryCompare(worker, 'done', true)
        var eventMap = worker.reply

        //"Event at 13:00 until 15:30"
        var eventsAtOnePm = eventMap[0]
        compare(eventsAtOnePm.event.displayLabel, "Event at 13:00 until 15:30")
        compare(eventsAtOnePm.y, 0)

        //"Event at 13:30 until 15:30"
        var eventsAtHalfPastOnePm = eventMap[1]
        compare(eventsAtHalfPastOnePm.event.displayLabel, "Event at 13:30 until 15:30")
        compare(eventsAtHalfPastOnePm.y, 1)

        //"Event at 15:00 until 19:00"
        var eventsAtThreePm = eventMap[2]
        compare(eventsAtThreePm.event.displayLabel, "Event at 15:00 until 19:00")
        compare(eventsAtThreePm.y, 2)
    }

    //    13:00 ----
    //          |XX|
    //    14:00 |XX| ----
    //          |XX| |XX|
    //    15:00 |XX| |XX|
    //          ---- |XX|
    //    16:00      |XX|
    //          ---- |XX|
    //    17:00 |XX| |XX|
    //          ---- |XX|
    //    18:00      |XX|
    //               |XX|
    //    19:00      |XX|
    //               ----
    //    20:00
    function test_intersec_three_events_2()
    {
        var data = [{startDate: new Date(2016, 7, 2, 13, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 15, 30, 0, 0),
                     label: "Event at 13:00 until 15:30"},
                    {startDate: new Date(2016, 7, 2, 14, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 19, 30, 0, 0),
                     label: "Event at 14:00 until 19:30"},
                    {startDate: new Date(2016, 7, 2, 16, 30, 0, 0),
                     endDate: new Date(2016, 7, 2, 17, 30, 0, 0),
                     label: "Event at 16:30 until 17:30"}]
        var model = create_events(data)

        var startDate = new Date(2016, 7, 2, 11, 11, 11, 11)
        worker.start(model, startDate)
        tryCompare(worker, 'done', true)
        var eventMap = worker.reply

        //"Event at 13:00 until 15:30"
        var eventsAtOnePm = eventMap[0]
        compare(eventsAtOnePm.event.displayLabel, "Event at 13:00 until 15:30")
        compare(eventsAtOnePm.y, 0)

        //"Event at 14:00 until 19:30"
        var eventsAtTwoPm = eventMap[1]
        compare(eventsAtTwoPm.event.displayLabel, "Event at 14:00 until 19:30")
        compare(eventsAtTwoPm.y, 1)


        //"Event at 16:30 until 17:30"
        var eventsHalfPastFor = eventMap[2]
        compare(eventsHalfPastFor.event.displayLabel, "Event at 16:30 until 17:30")
        compare(eventsHalfPastFor.y, 0)

    }

    //    13:00 ---- ---- ----
    //          |XX| |XX| |XX|
    //    14:00 |XX| |XX| ----
    //          |XX| |XX|
    //    15:00 |XX| |XX| ---- ---- ----
    //          |XX| |XX| |XX| |XX| |XX|
    //    16:00 |XX| |XX| ---- ---- ----
    //          |XX| |XX|
    //    17:00 |XX| |XX|
    //          |XX| ----
    //    18:00 |XX|
    function test_intersec_events_after()
    {
        var data = [{startDate: new Date(2016, 7, 2, 13, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 17, 30, 0, 0),
                     label: "Event at 13:00 until 17:30"},
                    {startDate: new Date(2016, 7, 2, 13, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 18, 30, 0, 0),
                     label: "Event at 13:00 until 18:30"},
                    {startDate: new Date(2016, 7, 2, 13, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 14, 0, 0, 0),
                     label: "Event at 13:00 until 14:00"},
                    {startDate: new Date(2016, 7, 2, 15, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 16, 0, 0, 3),
                     label: "Event at 15:00 until 16:00"},
                    {startDate: new Date(2016, 7, 2, 15, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 16, 0, 0, 2),
                     label: "Event at 15:00 until 16:00 (1)"},
                    {startDate: new Date(2016, 7, 2, 15, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 16, 0, 0, 1),
                     label: "Event at 15:00 until 16:00 (2)"}
                ]
        var model = create_events(data)

        var startDate = new Date(2016, 7, 2, 11, 11, 11, 11)
        worker.start(model, startDate)
        tryCompare(worker, 'done', true)
        var eventMap = worker.reply

        //Events @13:00
        var eventsAtOnePm = eventMap[0]
        compare(eventsAtOnePm.event.displayLabel, "Event at 13:00 until 18:30")
        compare(eventsAtOnePm.y, 0)

        eventsAtOnePm = eventMap[1]
        compare(eventsAtOnePm.event.displayLabel, "Event at 13:00 until 17:30")
        compare(eventsAtOnePm.y, 1)

        eventsAtOnePm = eventMap[2]
        compare(eventsAtOnePm.event.displayLabel, "Event at 13:00 until 14:00")
        compare(eventsAtOnePm.y, 2)


        //"Events @15:00
        var eventsAtThreePm = eventMap[3]
        compare(eventsAtThreePm.event.displayLabel, "Event at 15:00 until 16:00")
        compare(eventsAtThreePm.y, 2)

        eventsAtThreePm = eventMap[4]
        compare(eventsAtThreePm.event.displayLabel, "Event at 15:00 until 16:00 (1)")
        compare(eventsAtThreePm.y, 3)

        eventsAtThreePm = eventMap[5]
        compare(eventsAtThreePm.event.displayLabel, "Event at 15:00 until 16:00 (2)")
        compare(eventsAtThreePm.y, 4)
    }

    //    12:00 ---- ----
    //          |XX| |XX| ----
    //    14:00 |XX| |XX| |XX|
    //          |XX| |XX| ----
    //    15:00 |XX| |XX|
    //          ---- ----
    function test_intersec_three_events_3()
    {
        var data = [{startDate: new Date(2016, 7, 2, 12, 30, 0, 0),
                     endDate: new Date(2016, 7, 2, 14, 30, 0, 0),
                     label: "Event at 12:30 until 14:30"},
                    {startDate: new Date(2016, 7, 2, 12, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 15, 30, 0, 1),
                     label: "Event at 12:00 until 15:30"},
                    {startDate: new Date(2016, 7, 2, 12, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 15, 30, 0, 0),
                     label: "Event at 12:00 until 15:30 (1)"}]
        var model = create_events(data)

        var startDate = new Date(2016, 7, 2, 11, 11, 11, 11)
        worker.start(model, startDate)
        tryCompare(worker, 'done', true)
        var eventMap = worker.reply

        //"Event at 12:00 until 15:30"
        var eventsAtNoon = eventMap[0]
        compare(eventsAtNoon.event.displayLabel, "Event at 12:00 until 15:30")
        compare(eventsAtNoon.y, 0)

        eventsAtNoon = eventMap[1]
        compare(eventsAtNoon.event.displayLabel, "Event at 12:00 until 15:30 (1)")
        compare(eventsAtNoon.y, 1)

        //"Event at 12:30 until 14:30"
        var eventsAtHalfPastNoon = eventMap[2]
        compare(eventsAtHalfPastNoon.event.displayLabel, "Event at 12:30 until 14:30")
        compare(eventsAtHalfPastNoon.y, 2)
    }

    function test_intersec_three_events_4()
    {
        var data = [{startDate: new Date(2016, 7, 2, 12, 15, 0, 0),
                     endDate: new Date(2016, 7, 2, 12, 30, 0, 0),
                     label: "Event at 12:15 until 12:30"},
                    {startDate: new Date(2016, 7, 2, 12, 00, 0, 0),
                     endDate: new Date(2016, 7, 2, 12, 30, 0, 1),
                     label: "Event at 12:00 until 12:30"},
                    {startDate: new Date(2016, 7, 2, 12, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 12, 30, 0, 0),
                     label: "Event at 12:00 until 12:30 (1)"}]
        var model = create_events(data)

        var startDate = new Date(2016, 7, 2, 11, 11, 11, 11)
        worker.start(model, startDate)
        tryCompare(worker, 'done', true)
        var eventMap = worker.reply

        //"Event at 12:00 until 12:30"
        var eventsAtNoon = eventMap[0]
        compare(eventsAtNoon.event.displayLabel, "Event at 12:00 until 12:30")
        compare(eventsAtNoon.y, 0)

        eventsAtNoon = eventMap[1]
        compare(eventsAtNoon.event.displayLabel, "Event at 12:00 until 12:30 (1)")
        compare(eventsAtNoon.y, 1)

        //"Event at 12:15 until 12:20"
        var eventsAtHalfPastNoon = eventMap[2]
        compare(eventsAtHalfPastNoon.event.displayLabel, "Event at 12:15 until 12:30")
        compare(eventsAtHalfPastNoon.y, 2)
    }

    function test_intersec_next_day_events()
    {
        var data = [{startDate: new Date(2016, 7, 2, 23, 00, 0, 0),
                     endDate: new Date(2016, 7, 2, 23, 30, 0, 0),
                     label: "Event at 23:00 until 23:30"},
                    {startDate: new Date(2016, 7, 2, 23, 10, 0, 0),
                     endDate: new Date(2016, 7, 3, 00, 30, 0, 0),
                     label: "Event at 23:10 until 00:30"}]
        var model = create_events(data)
        var startDate = new Date(2016, 7, 2, 11, 11, 11, 11)
        worker.start(model, startDate)
        tryCompare(worker, 'done', true)
        var eventMap = worker.reply

        //"Event at 23:00 until 23:30"
        var eventsAtElevenPm = eventMap[0]
        compare(eventsAtElevenPm.event.displayLabel, "Event at 23:00 until 23:30")
        compare(eventsAtElevenPm.y, 0)

        //"Event at 23:30 until 00:30"
        var eventsAtHalfPastElevenPm = eventMap[1]
        compare(eventsAtHalfPastElevenPm.event.displayLabel, "Event at 23:10 until 00:30")
        compare(eventsAtHalfPastElevenPm.y, 1)
    }

    //    10:00 ----
    //          |XX|
    //    11:00 |XX| ----
    //          |XX| |XX|
    //    12:00 |XX| |XX|
    //          |XX| |XX|
    //    13:00 ---- |XX|
    //          |XX| |XX|
    //    14:00 |XX| ----
    //          |XX|
    //    15:00 |XX| ----
    //          |XX| |XX|
    //    16:00 |XX| |XX|
    //          ---- |XX|
    //    17:00      ----
    function test_intersec_five_events()
    {
        var data = [{startDate: new Date(2016, 7, 2, 10, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 13, 0, 0, 0),
                     label: "Event at 10:00 until 13:00"},
                    {startDate: new Date(2016, 7, 2, 11, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 14, 00, 0, 0),
                     label: "Event at 11:00 until 14:00"},
                    {startDate: new Date(2016, 7, 2, 13, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 16, 30, 0, 0),
                     label: "Event at 13:00 until 16:30"},
                    {startDate: new Date(2016, 7, 2, 15, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 17, 00, 0, 0),
                     label: "Event at 15:00 until 17:00"}
                ]
        var model = create_events(data)

        var startDate = new Date(2016, 7, 2, 11, 11, 11, 11)
        worker.start(model, startDate)
        tryCompare(worker, 'done', true)
        var eventMap = worker.reply

        // "Event at 10:00 until 13:00"
        var eventsAtTen = eventMap[0]
        compare(eventsAtTen.event.displayLabel, "Event at 10:00 until 13:00")
        compare(eventsAtTen.y, 0)

        //"Event at 11:00 until 14:00"
        var eventsAtEleven = eventMap[1]
        compare(eventsAtEleven.event.displayLabel, "Event at 11:00 until 14:00")
        compare(eventsAtEleven.y, 1)

        //"Event at 13:00 until 16:30"
        var eventAtOnePm = eventMap[2]
        compare(eventAtOnePm.event.displayLabel, "Event at 13:00 until 16:30")
        compare(eventAtOnePm.y, 0)

        //"Event at 15:00 until 17:00"
        var eventAtThreePm = eventMap[3]
        compare(eventAtThreePm.event.displayLabel, "Event at 15:00 until 17:00")
        compare(eventAtThreePm.y, 1)
    }

    //    10:00 ----
    //          |XX|
    //    11:00 |XX| ----
    //          |XX| |XX|
    //    12:00 |XX| |XX|
    //          |XX| |XX|
    //    13:00 |XX| |XX|
    //          |XX| |XX|
    //    14:00 |XX| |XX|
    //          ---- |XX|
    //    15:00 |XX| |XX|
    //          |XX| |XX|
    //    16:00 |XX| |XX| ----
    //          ---- |XX| |XX|
    //    17:00      ---- |XX|
    //                    ----
    //    18:00
    function test_intersec_between_10_18()
    {
        var data = [{startDate: new Date(2016, 7, 2, 10, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 14, 30, 0, 0),
                     label: "Event at 10:00 until 14:30"},
                    {startDate: new Date(2016, 7, 2, 11, 0, 0, 0),
                     endDate: new Date(2016, 7, 2, 17, 00, 0, 0),
                     label: "Event at 11:00 until 17:00"},
                    {startDate: new Date(2016, 7, 2, 14, 30, 0, 0),
                     endDate: new Date(2016, 7, 2, 16, 30, 0, 0),
                     label: "Event at 14:30 until 16:30"},
                    {startDate: new Date(2016, 7, 2, 16, 00, 0, 0),
                     endDate: new Date(2016, 7, 2, 17, 30, 0, 0),
                     label: "Event at 16:00 until 17:30"}

                ]
        var model = create_events(data)

        var startDate = new Date(2016, 7, 2, 11, 11, 11, 11)
        worker.start(model, startDate)
        tryCompare(worker, 'done', true)
        var eventMap = worker.reply

        // "Event at 10:00 until 14:30"
        var eventsA = eventMap[0]
        compare(eventsA.event.displayLabel, "Event at 10:00 until 14:30")
        compare(eventsA.y, 0)

        //"Event at 11:00 until 17:00"
        var eventsB = eventMap[1]
        compare(eventsB.event.displayLabel, "Event at 11:00 until 17:00")
        compare(eventsB.y, 1)

        //"Event at 14:30 until 16:30"
        var eventsC = eventMap[2]
        compare(eventsC.event.displayLabel, "Event at 14:30 until 16:30")
        compare(eventsC.y, 0)

        //"Event at 16:00 until 17:30"
        var eventsD = eventMap[3]
        compare(eventsD.event.displayLabel, "Event at 16:00 until 17:30")
        compare(eventsD.y, 2)
    }

    //    14:00 ----
    //          |XX| ---- ----
    //    15:00 ---- ---- |XX|
    //          ---- ---- ----
    //    16:00 ---- ----
    //
    function test_intersec_between_14_15_until_16_30()
    {
        var data = [{startDate: new Date(2016, 7, 2, 14, 15, 0, 0),
                     endDate: new Date(2016, 7, 2, 15, 15, 0, 0),
                     label: "Event at 14:15 until 15:15"},
                    {startDate: new Date(2016, 7, 2, 14, 30, 0, 0),
                     endDate: new Date(2016, 7, 2, 15, 00, 0, 0),
                     label: "Event at 14:30 until 15:00"},
                    {startDate: new Date(2016, 7, 2, 14, 45, 0, 0),
                     endDate: new Date(2016, 7, 2, 15, 45, 0, 0),
                     label: "Event at 14:45 until 15:45"},
                    {startDate: new Date(2016, 7, 2, 15, 30, 0, 0),
                     endDate: new Date(2016, 7, 2, 16, 30, 0, 1),
                     label: "Event at 15:30 until 16:30"},
                    {startDate: new Date(2016, 7, 2, 15, 30, 0, 0),
                     endDate: new Date(2016, 7, 2, 16, 30, 0, 0),
                     label: "Event at 15:30 until 16:30 (1)"}
                ]
        var model = create_events(data)

        var startDate = new Date(2016, 7, 2, 11, 11, 11, 11)
        worker.start(model, startDate)
        tryCompare(worker, 'done', true)
        var eventMap = worker.reply

        // "Event at 14:15 until 15:15"
        var eventsA = eventMap[0]
        compare(eventsA.event.displayLabel, "Event at 14:15 until 15:15")
        compare(eventsA.y, 0)
        compare(eventsA.intersectionCount, 5)
        fuzzyCompare(eventsA.width, 0.3, 0.1)

        //"Event at 14:30 until 15:00"
        var eventsB = eventMap[1]
        compare(eventsB.event.displayLabel, "Event at 14:30 until 15:00")
        compare(eventsB.y, 1)
        compare(eventsB.intersectionCount, 5)
        fuzzyCompare(eventsB.width, 0.3, 0.1)

        //"Event at 14:45 until 15:45"
        var eventsC = eventMap[2]
        compare(eventsC.event.displayLabel, "Event at 14:45 until 15:45")
        compare(eventsC.y, 2)
        compare(eventsC.intersectionCount, 5)
        fuzzyCompare(eventsC.width, 0.3, 0.1)

        //"Event at 15:30 until 16:30"
        var eventsD = eventMap[3]
        compare(eventsD.event.displayLabel, "Event at 15:30 until 16:30")
        compare(eventsD.y, 0)
        compare(eventsD.intersectionCount, 5)
        fuzzyCompare(eventsD.width, 0.3, 0.1)

        //"Event at 15:30 until 16:30 (1)"
        var eventsE = eventMap[4]
        compare(eventsE.event.displayLabel, "Event at 15:30 until 16:30 (1)")
        compare(eventsE.y, 1)
        compare(eventsE.intersectionCount, 5)
        fuzzyCompare(eventsE.width, 0.3, 0.1)
    }
}
