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

Item {
    id: bubbleOverLay

    property var delegate;
    property var day;
    property int hourHeight: units.gu(8)
    property alias model: modelConnections.target
    property var flickable: null
    readonly property alias creatingEvent: overlayMouseArea.creatingEvent

    signal pressAndHoldAt(var date)

    Component.onCompleted: bubbleOverLay.idleCreateEvents();
    enabled: !intern.busy && !intern.waitingForModelChange

    function waitForModelChange()
    {
        intern.waitingForModelChange = true
    }

    EventBubble {
        id: temporaryEvent

        isEventBubble: false
        Drag.active: overlayMouseArea.drag.active
        isLiveEditing: overlayMouseArea.creatingEvent
        visible: overlayMouseArea.creatingEvent
        depthInRow: -10000
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
            assignBubbleProperties(temporaryEvent, event, 1, overlayMouseArea.width);
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

        onPressed: {
            intern.now = new Date();
            if( intern.now.isSameDay( bubbleOverLay.day ) ) {
                bubbleOverLay.showSeparator();
            }
        }
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

    TimeSeparator {
        id: separator
        objectName: "separator"
        width:  bubbleOverLay.width
        visible: false
        z:1
    }

    QtObject {
        id: intern

        property var now : new Date();
        property var eventMap;
        property var unUsedEvents: []
        property bool busy: false
        property bool dirty: false
        property bool waitingForModelChange: false
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

        source: "EventLayoutHelper.js"
        onMessage: {
            // check if anything changed during the process
            if (intern.dirty) {
                console.debug("Something has changed while work script was running, ignore message")
            } else {
                // nothing changed we can draw the events now
                layoutEvents(messageObject.schedules, messageObject.maxDepth);
            }

            if (!messageObject.hasMore) {
                var currentDate = new Date()
                intern.busy = false
                if (intern.dirty) {
                    idleCreateEvents()
                }
            }
        }
    }

    function layoutEvents(array, depth) {
        for(var i=0; i < array.length ; ++i) {
            var schedule = array[i];
            var event = intern.eventMap[schedule.id];
            bubbleOverLay.createEvent(event , schedule.depth, depth +1);
        }
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
            console.debug("Work script still busy, mark model as dirty")
            // mark as dirty and wait for the current process to finish
            intern.dirty = true
            return;
        }

        intern.busy = true
        intern.dirty = false
        destroyAllChildren();

        var eventMap = {};
        var allSchs = [];

        var startDate = new Date(day).midnight();
        var endDate = new Date(day).endOfDay();
        var items = model.itemsByTimePeriod(startDate,endDate);
        for(var i = 0; i < items.length; ++i) {
            var event = items[i];

            if(event.allDay) {
                continue;
            }

            var schedule = {"startDateTime": event.startDateTime, "endDateTime": event.endDateTime,"id":event.itemId };
            allSchs.push(schedule);
            eventMap[event.itemId] = event;
        }

        intern.eventMap = eventMap;
        if (allSchs.length > 0) {
            eventLayoutHelper.sendMessage(allSchs);
        } else {
            intern.busy = false
        }

        if(intern.now.isSameDay( bubbleOverLay.day )) {
            bubbleOverLay.showSeparator();
        }
    }

    function destroyAllChildren() {
        separator.visible = false
        for(var i=0; i < children.length; i++) {
            var child = children[i]
            if (!child.isEventBubble) {
                continue;
            }
            if (intern.unUsedEvents.indexOf(child) === -1) {
                child.visible = false;
                child.clicked.disconnect( bubbleOverLay.showEventDetails );
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

    function createEvent( event, depth, sizeOfRow ) {
        var eventBubble;
        if(intern.unUsedEvents.length === 0) {
            var incubator = delegate.incubateObject(bubbleOverLay)
            incubator.forceCompletion()
            eventBubble = incubator.object
        } else {
            eventBubble = getUnusedEventBubble();
        }
        assignBubbleProperties(eventBubble, event, depth, sizeOfRow);
    }

    function assignBubbleProperties(eventBubble, event, depth, sizeOfRow) {
        var yPos = 0;
        var height = 0;
        var hour = 0;
        var durationMin = 0;
        var dayMidnight = day.midnight()

        // skip it in case of endDateTime == dd-MM-yyyy 12:00 AM
        if (event.endDateTime - dayMidnight  == 0) {
            return;
        }

        if ((event.endDateTime.getDate() - day.getDate() == 0) &&
            (event.startDateTime.getDate() - day.getDate() == 0)) {
            // event start and end in this day
            hour = event.startDateTime.getHours();
            yPos = (( event.startDateTime.getMinutes() * hourHeight) / 60) + hour * hourHeight
            durationMin = (event.endDateTime.getHours() - event.startDateTime.getHours()) * 60;
            durationMin += (event.endDateTime.getMinutes() - event.startDateTime.getMinutes());
        } else if ((event.endDateTime.getDate() - day.getDate() == 0) &&
                   (event.startDateTime - dayMidnight < 0)) {
            // event start in the previous date
            hour = 0;
            yPos = 0;
            durationMin = event.endDateTime.getHours() * 60;
            durationMin += event.endDateTime.getMinutes();
        } else if ((event.startDateTime.getDate() - day.getDate() == 0) &&
                   (event.endDateTime - dayMidnight >= Date.msPerDay)) {
            // event start on this day and end in the next day
            hour = event.startDateTime.getHours();
            yPos = (( event.startDateTime.getMinutes() * hourHeight) / 60) + hour * hourHeight
            durationMin = (24 - event.startDateTime.getHours()) * 60;
        } else if ((event.endDateTime - dayMidnight  >= Date.msPerDay) &&
                   (event.startDateTime - dayMidnight <= 0)) {
            // event start in the previous date and end in the future date
            hour = 0;
            yPos = 0;
            durationMin = 24 * 60;
        }

        eventBubble.y = yPos;
        height = (durationMin * hourHeight )/ 60;
        eventBubble.height = (height > eventBubble.minimumHeight) ? height:eventBubble.minimumHeight ;

        eventBubble.model = bubbleOverLay.model
        eventBubble.depthInRow = depth;
        eventBubble.sizeOfRow = sizeOfRow;
        eventBubble.event = event
        eventBubble.visible = true;
        eventBubble.clicked.connect( bubbleOverLay.showEventDetails );
    }

    function showSeparator() {
        var y = ((intern.now.getMinutes() * hourHeight) / 60) + intern.now.getHours() * hourHeight;
        separator.y = y;
        separator.visible = true;
    }

    Timer {
        id: createEventsTimer

        interval: 1
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
