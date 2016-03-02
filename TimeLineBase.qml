    /*
 * Copyright (C) 2013-2014 Canonical Ltd
 *
 * This file is part of Ubuntu Calendar App
 *
 * Ubuntu Calendar App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Calendar App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.4
import Ubuntu.Components 1.3
import QtOrganizer 5.0

import "dateExt.js" as DateExt
import "calendar_canvas.js" as CanlendarCanvas

Item {
    id: bubbleOverLay

    property var delegate;
    property var day;

    property alias model: modelConnections.target
    property var flickable: null
    readonly property alias creatingEvent: overlayMouseArea.creatingEvent
    readonly property real hourHeight: units.gu(8)
    readonly property real minuteHeight: (hourHeight / 60)

    signal pressAndHoldAt(var date)

    function waitForModelChange()
    {
        intern.waitingForModelChange = true
    }

    function createOrganizerEvent( startDate ) {
        var event = Qt.createQmlObject("import QtOrganizer 5.0; Event {}", Qt.application,"TimeLineBase.qml");
        event.collectionId = (model.defaultCollection().collectionId);
        var endDate = new Date( startDate.getTime() + 3600000 );
        event.startDateTime = startDate;
        event.endDateTime = endDate;
        event.displayLabel = i18n.tr("New event");
        event.setDetail(Qt.createQmlObject("import QtOrganizer 5.0; Comment{ comment: 'X-CAL-DEFAULT-EVENT'}", event,"TimeLineBase.qml"));
        return event
    }

    function getTimeFromYPos(y, day) {
        var date = new Date(day);
        var time = y / hourHeight;
        var minutes = time % 1 ;
        var hour = time - minutes;
        minutes = parseInt(60 * minutes);
        minutes = Math.floor(minutes/15) * 15;
        date.setHours(hour);
        date.setMinutes(minutes);
        return date;
    }

    function showEventDetails(event) {
        var comment = event.detail(Detail.Comment);
        if(comment && comment.comment === "X-CAL-DEFAULT-EVENT") {
            pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"event": event, "model":model});
        } else {
            pageStack.push(Qt.resolvedUrl("EventDetails.qml"), {"event":event,"model":model});
        }
    }

    WorkerScript {
        id: eventLayoutHelper

        source: "calendar_canvas_worker.js"
        onMessage: {
            // check if anything changed during the process
            if (intern.dirty) {
                console.debug("Something has changed while work script was running, ignore message")
            } else {
                var events = messageObject.reply
                var dirty = false
                for (var i=0; i < events.length; i++) {
                    var e = intern.eventsById[events[i].eventId]
                    if (e.eventId != events[i].itemId) {
                        console.warn("Event does not match id:", i)
                        dirty = true
                    }
                    if (e.startDateTime.getTime() != events[i].eventStartTime) {
                        console.warn("Event does not match start time")
                        dirty = true
                    }
                    if (e.endDateTime.getTime() != events[i].eventEndTime) {
                        console.warn("Event does not match end time")
                        dirty = true
                    }

                    if (dirty) {
                        console.warn("Mark as dirty")
                        intern.dirty = true
                        break
                    }

                    createVisual(events[i])
                }
            }
            intern.busy = false
            intern.eventsById = {}
            if (intern.dirty) {
                bubbleOverLay.idleCreateEvents()
            }
        }
    }

    function createVisual(eventInfo)
    {
        var eventBubble;
        if (intern.unUsedEvents.length === 0) {
            var incubator = delegate.incubateObject(bubbleOverLay)
            incubator.forceCompletion()
            eventBubble = incubator.object
        } else {
            eventBubble = getUnusedEventBubble();
        }

        var eventWidth =  (bubbleOverLay.width * eventInfo.width)

        eventBubble.anchorDate = bubbleOverLay.day
        eventBubble.minuteHeight = bubbleOverLay.minuteHeight
        eventBubble.sizeOfRow = eventInfo.width
        eventBubble.depthInRow = eventInfo.y
        eventBubble.model = bubbleOverLay.model
        eventBubble.event = intern.eventsById[eventInfo.eventId]
        eventBubble.resize()
        eventBubble.visible = true
        eventBubble.clicked.connect( bubbleOverLay.showEventDetails );
    }

     function idleCreateEvents() {
        createEventsTimer.restart()
    }

    function createEvents() {
        if(!bubbleOverLay || bubbleOverLay == undefined || model === undefined || model === null) {
            console.debug("\tabort.")
            return;
        }

        // check if there is any update in progress
        if (intern.busy) {
            console.debug("Work script still busy, postpone update")
            // mark as dirsty to triggere a new update after the message arrives
            intern.dirty = true
            return;
        }

        intern.busy = true
        intern.dirty = false
        destroyAllChildren();
        intern.eventsById = {}

        var startDate = day.midnight()
        var itemsOfTheDay = model.itemsByTimePeriod(startDate, startDate.endOfDay())
        if (itemsOfTheDay.length === 0) {
            bubbleOverLay.showSeparator();
            intern.busy = false
            return
        }

        for(var i=0; i < itemsOfTheDay.length; i++) {
            var e = itemsOfTheDay[i]
            intern.eventsById[e.itemId] = e
        }

        var eventInfo = CanlendarCanvas.parseDayEvents(startDate, itemsOfTheDay)
        eventLayoutHelper.sendMessage({'events': eventInfo})
        bubbleOverLay.showSeparator();
    }

    function destroyAllChildren() {
        separator.visible = false
        for(var i=0; i < children.length; i++) {
            var child = children[i]
            if (!child.isEventBubble) {
                continue;
            }
            if (intern.unUsedEvents.indexOf(child) === -1) {
                child.event = null
                child.visible = false;
                child.clicked.disconnect(bubbleOverLay.showEventDetails);
                intern.unUsedEvents.push(child)
            }
        }
    }

    function getUnusedEventBubble() {
        var unusedEvent = null
        if (intern.unUsedEvents.length > 0) {
            unusedEvent = intern.unUsedEvents[0]
            intern.unUsedEvents.splice(0, 1);
        }
        return unusedEvent
    }

    function showSeparator() {
        intern.now = new Date();
        if (intern.now.isSameDay(bubbleOverLay.day) ) {
            var y = ((intern.now.getMinutes() * hourHeight) / 60) + intern.now.getHours() * hourHeight;
            separator.y = y;
            separator.visible = true;
        } else {
            separator.visible = false;
        }
    }

    onDayChanged: bubbleOverLay.idleCreateEvents();
    Component.onCompleted: bubbleOverLay.idleCreateEvents();
    enabled: !intern.busy && !intern.waitingForModelChange

    EventBubble {
        id: temporaryEvent

        isEventBubble: false
        Drag.active: overlayMouseArea.drag.active
        isLiveEditing: overlayMouseArea.creatingEvent
        visible: overlayMouseArea.creatingEvent
        sizeOfRow: 1.0
        z: 100
        onVisibleChanged: {
            if (visible)
                y = event ? CanlendarCanvas.minutesSince(bubbleOverLay.day, event.startDateTime) * bubbleOverLay.minuteHeight : 0
        }
    }

    Item {
        anchors {
            topMargin: flickable ? flickable.contentY : 0
            bottomMargin: flickable ? bubbleOverLay.height - flickable.contentY - flickable.height : bubbleOverLay.height
            fill: parent
        }

        ActivityIndicator {
            visible: intern.busy || intern.waitingForModelChange
            running: visible
            anchors.centerIn: parent
        }

        z: 100
    }

    MouseArea {
        id: overlayMouseArea

        property bool creatingEvent: false

        anchors.fill: parent
        objectName: "mouseArea"
        drag {
            target: creatingEvent ? temporaryEvent : null
            axis: Drag.YAxis
            minimumY: 0
            maximumY: height - temporaryEvent.height
        }


        Binding {
            target: temporaryEvent
            property: "visible"
            value: overlayMouseArea.creatingEvent
        }

        onPressAndHold: {
            var selectedDate = new Date(day);
            var pointY = mouse.y - (hourHeight / 2);
            selectedDate.setHours(Math.floor(pointY / hourHeight))
            selectedDate.setMinutes(Math.min(pointY % hourHeight, 60))
            var event = createOrganizerEvent(selectedDate)

            Haptics.play()

            temporaryEvent.anchorDate = bubbleOverLay.day
            temporaryEvent.minuteHeight = bubbleOverLay.minuteHeight
            temporaryEvent.depthInRow = 0
            temporaryEvent.model = bubbleOverLay.model
            temporaryEvent.event = event
            temporaryEvent.resize()
            creatingEvent = true
        }

        onReleased: {
            if (creatingEvent) {
                bubbleOverLay.pressAndHoldAt(temporaryEvent.event.startDateTime)
                creatingEvent = false
            }
        }

        onCanceled: {
            if (creatingEvent) {
                creatingEvent = false
            }
        }
    }

    TimeSeparator {
        id: separator
        objectName: "separator"
        width:  bubbleOverLay.width
        visible: false
        // make sure that the object is aways visible
        z: 1000
    }

    Timer {
        id: separtorUpdateTimer
        interval: 300000 // every 5 minutes
        running: true
        repeat: true
        onTriggered: showSeparator()
    }

    QtObject {
        id: intern

        property var now : new Date();
        property var eventsById: ({})
        property var unUsedEvents: []
        property bool busy: false
        property bool dirty: false
        property bool waitingForModelChange: false
    }

    Timer {
        id: createEventsTimer

        interval: 300
        running: false
        repeat: false
        onTriggered: createEvents()
    }

    Connections {
        id: modelConnections
        onModelChanged: {
            intern.dirty = true
            intern.waitingForModelChange = false
            bubbleOverLay.idleCreateEvents()
        }
    }
}
