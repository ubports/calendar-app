import QtQuick 2.0
import QtTest 1.0
import QtOrganizer 5.0

import "../../dateExt.js" as DATE

TestCase{
    id: root
    name: "Event Bubble tests"

    property OrganizerModel model: null
    property Collection collection: null
    property Event event: null
    property var eventBubble: null

    Component {
        id: modelComp

        OrganizerModel {}
    }

    Component {
        id: collectionComp

        Collection {}
    }

    Component {
        id: eventAttendeeComp

        EventAttendee {}
    }

    Component {
        id: eventComp

        Event {}
    }

    function create_model_from_data(data)
    {
        return modelComp.createObject(root,
                                      {"manager": data.manager,
                                       "startPeriod": data.startPeriod,
                                       "endPeriod": data.endPeriod,
                                       "autoUpdate": data.autoUpdate})
    }

    function create_collection_from_data(data)
    {
        return collectionComp.createObject(root,
                                           {"name": data.name,
                                            "color": data.color})
    }

    function create_event_attendee_from_data(data)
    {
        return eventAttendeeComp.createObject(root,
                                              {"emailAddress": data.emailAddress,
                                               "participationStatus": data.participationStatus})
    }

    function create_event_from_data(data)
    {
        return eventComp.createObject(root,
                                      {"collectionId": data.collectionId,
                                       "allDay": data.allDay,
                                       "displayLabel": data.label,
                                       "startDateTime": data.startDate,
                                       "endDateTime": data.endDate,
                                       "attendees": data.attendees})
    }

    function create_event_bubble(event)
    {
        var component = Qt.createComponent(Qt.resolvedUrl("../../EventBubble.qml"))
        if (component.status === Component.Ready)
            return component.createObject(root, {"model": root.model, "event": event})

        return null
    }

    function get_collection_id_by_name(model, name)
    {
        for (var i = 0 ; i < model.collections.length ; ++i) {
            if (model.collections[i].name === name ) {
                return model.collections[i].collectionId
            }
        }
        return ""
    }

    function initTestCase()
    {
        var startPeriod = new Date(2016, 1, 1, 0, 0, 0, 0)
        var endPeriod = new Date(2017, 1, 1, 0, 0, 0, 0)
        var modelData = {"manager": "memory",
                         "startPeriod": startPeriod,
                         "endPeriod": endPeriod,
                         "autoUpdate": true}
        root.model = create_model_from_data(modelData) 

        var collectionData = {"name": "test@calendar.com",
                              "color": "black" }
        root.collection = create_collection_from_data(collectionData)
        root.model.saveCollection(root.collection)
    }

    function init()
    {
        var collectionId = get_collection_id_by_name(root.model, root.collection.name)
        var startDate = new Date()
        startDate = startDate.addDays(1)
        var endDate = startDate.addMinutes(60)
        var eventData = {"collectionId": collectionId,
                         "label": "Sample Test Event",
                         "allDay": false,
                         "startDate": startDate,
                         "endDate": endDate}
        root.event = create_event_from_data(eventData)
    }

    function cleanup()
    {
        if (root.event) {
            root.event.destroy()
            root.event = null
        }
 
        if (root.eventBubble) {
            root.eventBubble.destroy()
            root.eventBubble = null
        }
    }

    function test_visual_style_future_accepted_event()
    {
        var eventAttendeeData = {"emailAddress": root.collection.name,
                                 "participationStatus": EventAttendee.StatusAccepted}
 
        var eventAttendee = create_event_attendee_from_data(eventAttendeeData)
        root.event.setDetail(eventAttendee)

        eventBubble = create_event_bubble(root.event)
        eventBubble.updateEventBubbleStyle()

        compare(eventBubble.backgroundColor, root.collection.color)
        compare(eventBubble.borderColor, "#ffffff")
        compare(eventBubble.backgroundOpacity, 1.0)
        compare(eventBubble.titleText, "Sample Test Event")
        compare(eventBubble.titleColor, "#ffffff")
        verify(!eventBubble.strikeoutTitle)
    }

    function test_visual_style_future_declined_event()
    {
        var eventAttendeeData = {"emailAddress": root.collection.name,
                                 "participationStatus": EventAttendee.StatusDeclined}
 
        var eventAttendee = create_event_attendee_from_data(eventAttendeeData)
        root.event.setDetail(eventAttendee)

        eventBubble = create_event_bubble(root.event)
        eventBubble.updateEventBubbleStyle()

        compare(eventBubble.backgroundColor, root.collection.color)
        compare(eventBubble.borderColor, "#ffffff")
        compare(eventBubble.backgroundOpacity, 1.0)
        compare(eventBubble.titleText, "Sample Test Event")
        compare(eventBubble.titleColor, "#ffffff")
        verify(eventBubble.strikeoutTitle)
    }

    function test_visual_style_future_maybe_event()
    {
        var eventAttendeeData = {"emailAddress": root.collection.name,
                                 "participationStatus": EventAttendee.StatusTentative}
 
        var eventAttendee = create_event_attendee_from_data(eventAttendeeData)
        root.event.setDetail(eventAttendee)

        eventBubble = create_event_bubble(root.event)
        eventBubble.updateEventBubbleStyle()

        compare(eventBubble.backgroundColor, root.collection.color)
        compare(eventBubble.borderColor, "#ffffff")
        compare(eventBubble.backgroundOpacity, 1.0)
        compare(eventBubble.titleText, "(?) Sample Test Event")
        compare(eventBubble.titleColor, "#ffffff")
        verify(!eventBubble.strikeoutTitle)
    }

    function test_visual_style_future_unknown_event()
    {
        var eventAttendeeData = {"emailAddress": root.collection.name,
                                 "participationStatus": EventAttendee.StatusUnknown}
 
        var eventAttendee = create_event_attendee_from_data(eventAttendeeData)
        root.event.setDetail(eventAttendee)

        eventBubble = create_event_bubble(root.event)
        eventBubble.updateEventBubbleStyle()

        compare(eventBubble.backgroundColor, "#ffffff")
        compare(eventBubble.borderColor, root.collection.color)
        compare(eventBubble.backgroundOpacity, 1.0)
        compare(eventBubble.titleText, "Sample Test Event")
        compare(eventBubble.titleColor, root.collection.color)
        verify(!eventBubble.strikeoutTitle)
    }
}
