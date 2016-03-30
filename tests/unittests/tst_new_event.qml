import QtQuick 2.0
import QtTest 1.0
import QtOrganizer 5.0

TestCase{
    id: root
    name: "New Event tests"

    property var newEventPage: null

    Component {
        id: eventComp

        Event {
        }
    }

    function create_event_from_data(data)
    {
        return eventComp.createObject(root,
                                      {'allDay': data.allDay,
                                       'displayLabel': data.label,
                                       'startDateTime': data.startDate,
                                       'endDateTime': data.endDate})
    }

    function create_new_event_page(event)
    {
        var component = Qt.createComponent(Qt.resolvedUrl("../../NewEvent.qml"))
        if (component.status === Component.Ready)
            return component.createObject(root, {"event": event})

        return null
    }

    function init()
    {

    }

    function cleanup()
    {
        if (newEventPage) {
            newEventPage.destroy()
            newEventPage = null
        }
    }

    function test_new_event_title()
    {
        newEventPage = create_new_event_page(null)
        compare(newEventPage.header.title, "New Event")
    }

    function test_edit_event_details()
    {
        var startDate = new Date(2016, 3, 28, 14, 0,0 )
        var endDate = new Date(2016, 3, 28, 15, 0,0 )
        var eventData = {"label": 'test_event_details',
                         "allDay": false,
                         "startDate": startDate,
                         "endDate": endDate }
        var event = create_event_from_data(eventData)
        newEventPage = create_new_event_page(event)

        compare(newEventPage.header.title, "Edit Event")
        compare(newEventPage.startDate, startDate)
        compare(newEventPage.endDate, endDate)
    }

    function test_change_start_date()
    {
        var startDate = new Date(2016, 3, 28, 14, 0,0 )
        var endDate = new Date(2016, 3, 28, 15, 0,0 )
        var eventData = {"label": 'test_event_details',
                         "allDay": false,
                         "startDate": startDate,
                         "endDate": endDate }
        var event = create_event_from_data(eventData)
        newEventPage = create_new_event_page(event)

        compare(newEventPage.eventSize, 3600000) // 1h

        //Move start date 1h foward
        var startDatePicker = findChild(newEventPage, "startDateTimeInput")
        startDatePicker.dateTime = new Date(2016, 3, 28, 15, 0,0 )
        compare(newEventPage.eventSize, 3600000) // 1h
        compare(newEventPage.endDate, new Date(2016, 3, 28, 16, 0,0 ))

        //Move start date 3h backward
        startDatePicker.dateTime = new Date(2016, 3, 28, 12, 0,0 )
        compare(newEventPage.eventSize, 3600000) // 1h
        compare(newEventPage.endDate, new Date(2016, 3, 28, 13, 0,0 ))
    }

    function test_change_end_date()
    {
        var startDate = new Date(2016, 3, 28, 14, 0,0 )
        var endDate = new Date(2016, 3, 28, 15, 0,0 )
        var eventData = {"label": 'test_event_details',
                         "allDay": false,
                         "startDate": startDate,
                         "endDate": endDate }
        var event = create_event_from_data(eventData)
        newEventPage = create_new_event_page(event)

        // Move end date 30 min backward
        var endDatePicker = findChild(newEventPage, "endDateTimeInput")
        endDatePicker.dateTime = new Date(2016, 3, 28, 14, 30,0 )
        compare(newEventPage.eventSize, 1800000) // 30 min

        // Move start date 1h foward
        var startDatePicker = findChild(newEventPage, "startDateTimeInput")
        startDatePicker.dateTime = new Date(2016, 3, 28, 15, 0,0 )
        compare(newEventPage.eventSize, 1800000) // 30 min
        compare(newEventPage.endDate, new Date(2016, 3, 28, 15, 30,0 ))
    }

    function test_change_start_date_for_all_day()
    {
        var startDate = new Date(2016, 3, 28, 0, 0,0 )
        var endDate = new Date(2016, 3, 28, 0, 0,0 )
        var eventData = {"label": 'test_event_details',
                         "allDay": true,
                         "startDate": startDate,
                         "endDate": endDate }
        var event = create_event_from_data(eventData)
        newEventPage = create_new_event_page(event)

        compare(newEventPage.eventSize, 0) // 1 day

        // Move start date 1 day foward
        var startDatePicker = findChild(newEventPage, "startDateTimeInput")
        startDatePicker.dateTime = new Date(2016, 3, 29, 0, 0,0)

        // end date should move 1 day
        compare(newEventPage.endDate, new Date(2016, 3, 29, 0, 0,0 ))

        // Move end date 1 day foward
        var endDatePicker = findChild(newEventPage, "endDateTimeInput")
        endDatePicker.dateTime = new Date(2016, 3, 30, 0, 0,0)

        // start date should not change
        compare(newEventPage.startDate, new Date(2016, 3, 29, 0, 0,0 ))
        // event size should increase
        compare(newEventPage.eventSize, 86400000) // 2 days

        // Move start date 1 day foward
        startDatePicker.dateTime = new Date(2016, 3, 30, 0, 0,0)

        // end date should move 2 day
        compare(newEventPage.endDate, new Date(2016, 3, 31, 0, 0,0 ))
    }

    function test_events_with_null_end_date()
    {
        var startDate = new Date(2016, 3, 28, 15, 0,0 )
        var eventData = {"label": 'test_event_details',
                         "allDay": false,
                         "startDate": startDate,
                         "endDate": null }
        var event = create_event_from_data(eventData)
        newEventPage = create_new_event_page(event)

        compare(newEventPage.eventSize, 0)
        compare(newEventPage.startDate, new Date(2016, 3, 28, 15, 0,0 ))
        compare(newEventPage.endDate, new Date(2016, 3, 28, 15, 0,0 ))
    }
}
