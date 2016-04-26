import QtQuick 2.0
import QtTest 1.0
import QtOrganizer 5.0

import "../../dateExt.js" as DATE
import "../.."


TestCase{
    id: root
    name: "Event List Model tests"

    Component {
        id: modelComp

        EventListModel {
            id: eventModel

            manager: "memory"
            startPeriod: new Date(2016, 7, 1, 0, 0, 0, 0)
            endPeriod: new Date(2016, 8, 1, 0, 0, 0, 0)
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

    function create_event_from_data(model, data)
    {
        return eventComp.createObject(model,
                                      {'allDay': data.allDay,
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

    function test_days_with_events_with_all_day_events()
    {
        var data = [{startDate: new Date(2016, 7, 10, 0, 0, 0, 0),
                     endDate: new Date(2016, 7, 11, 0, 0, 0, 0),
                     label: "Event 7/01/2016",
                     allDay: true}]
        var model = create_events(data)
        var eventsByDay = model.daysWithEvents()
        compare(eventsByDay[new Date(2016, 7, 9, 0, 0, 0, 0).toDateString()], false)
        compare(eventsByDay[new Date(2016, 7, 10, 0, 0, 0, 0).toDateString()], true)
        compare(eventsByDay[new Date(2016, 7, 11, 0, 0, 0, 0).toDateString()], false)
    }

    function test_days_with_events()
    {
        var data = [{startDate: new Date(2016, 7, 1, 13, 0, 0, 0),
                     endDate: new Date(2016, 7, 1, 13, 30, 0, 0),
                     label: "Event 7/01/2016 at 13:00 until 13:30",
                     allDay: false},
                    {startDate: new Date(2016, 7, 2, 10, 10, 0, 0),
                     endDate: new Date(2016, 7, 2, 11, 00, 0, 0),
                     label: "Event 7/02/2016 at 10:10 until 11:00",
                     allDay: false},
                    {startDate: new Date(2016, 7, 3, 10, 10, 0, 0),
                     endDate: new Date(2016, 7, 3, 11, 00, 0, 0),
                     label: "Event 7/03/2016 at 10:10 until 11:00",
                     allDay: false},
                    {startDate: new Date(2016, 7, 5, 10, 10, 0, 0),
                     endDate: new Date(2016, 7, 5, 11, 00, 0, 0),
                     label: "Event 7/05/2016 at 10:10 until 11:00",
                     allDay: false},
                    {startDate: new Date(2016, 7, 10, 10, 10, 0, 0),
                     endDate: new Date(2016, 7, 10, 10, 00, 0, 0),
                     label: "Event 7/10/2016 at 10:10 until 11:00",
                     allDay: false},
                    {startDate: new Date(2016, 7, 20, 10, 10, 0, 0),
                     endDate: new Date(2016, 7, 20, 11, 00, 0, 0),
                     label: "Event 7/20/2016 at 10:10 until 11:00",
                     allDay: false},
                    // event with two days of duration
                    {startDate: new Date(2016, 7, 15, 10, 10, 0, 0),
                     endDate: new Date(2016, 7, 16, 11, 00, 0, 0),
                     label: "Event 7/15/2016 at 10:10 until 11:00",
                     allDay: false}
                    ]
        var expectedTrueDates = [ new Date(2016, 7, 1, 0, 0, 0, 0).toDateString(),
                                  new Date(2016, 7, 2, 0, 0, 0, 0).toDateString(),
                                  new Date(2016, 7, 3, 0, 0, 0, 0).toDateString(),
                                  new Date(2016, 7, 5, 0, 0, 0, 0).toDateString(),
                                  new Date(2016, 7, 10, 0, 0, 0, 0).toDateString(),
                                  new Date(2016, 7, 15, 0, 0, 0, 0).toDateString(),
                                  new Date(2016, 7, 16, 0, 0, 0, 0).toDateString(),
                                  new Date(2016, 7, 20, 0, 0, 0, 0).toDateString()]
        var model = create_events(data)
        var eventsByDay = model.daysWithEvents()
        // model contains 32 days
        compare(Object.keys(eventsByDay).length, 32)

        var duration = DATE.daysBetween(model.startPeriod.midnight(), model.endPeriod.midnight())
        var startDate = model.startPeriod.midnight()
        for(var d = 0; d < duration; d++) {
            var actualDate = startDate.addDays(d)
            // check if it was expected to be true
            if (eventsByDay[startDate.addDays(d).toDateString()]) {
                var index = expectedTrueDates.indexOf(actualDate.toDateString())
                verify( index != -1)
                expectedTrueDates.splice(index, 1);
            }
        }
        // make sure that all date appears on result
        compare(expectedTrueDates.length, 0)
    }
}
