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
import QtQuick 2.3
import Ubuntu.Components 1.1
import QtOrganizer 5.0

import "dateExt.js" as DateExt

Item {
    id: bubbleOverLay

    property var delegate;
    property var day;
    property int hourHeight: units.gu(8)
    property var model;

    Component.onCompleted: {
        bubbleOverLay.createEvents();
    }

    MouseArea {
        anchors.fill: parent
        objectName: "mouseArea"

        onPressAndHold: {
            var selectedDate = new Date(day);
            var hour = parseInt(mouseY / hourHeight);
            selectedDate.setHours(hour)
            createOrganizerEvent(selectedDate);
        }

        onPressed: {
            intern.now = new Date();
            if( intern.now.isSameDay( bubbleOverLay.day ) ) {
                bubbleOverLay.showSeparator();
            }
        }
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

    function createOrganizerEvent( startDate ) {
        var event = Qt.createQmlObject("import QtOrganizer 5.0; Event {}", Qt.application,"TimeLineBase.qml");
        event.collectionId = (model.defaultCollection().collectionId);
        var endDate = new Date( startDate.getTime() + 3600000 );
        event.startDateTime = startDate;
        event.endDateTime = endDate;
        event.displayLabel = i18n.tr("Untitled");
        event.setDetail(Qt.createQmlObject("import QtOrganizer 5.0; Comment{ comment: 'X-CAL-DEFAULT-EVENT'}", event,"TimeLineBase.qml"));
        model.saveItem(event);
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
        property var unUsedEvents: new Object();
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
            layoutEvents(messageObject.schedules,messageObject.maxDepth);
        }
    }

    function layoutEvents(array, depth) {
        for(var i=0; i < array.length ; ++i) {
            var schedule = array[i];
            var event = intern.eventMap[schedule.id];
            bubbleOverLay.createEvent(event , schedule.depth, depth +1);
        }
    }

    function createEvents() {
        if(!bubbleOverLay || bubbleOverLay == undefined || model === undefined || model === null) {
            return;
        }

        destroyAllChildren();

        var eventMap = {};
        var allSchs = [];

        var startDate = new Date(day).midnight();
        var endDate = new Date(day).endOfDay();
        var items = model.getItems(startDate,endDate);
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
        eventLayoutHelper.sendMessage(allSchs);

        if( intern.now.isSameDay( bubbleOverLay.day ) ) {
            bubbleOverLay.showSeparator();
        }
    }

    function destroyAllChildren() {
        for( var i = children.length - 1; i >= 0; --i ) {
            if( children[i].objectName === "mouseArea" ||
                    children[i].objectName === "weekdevider") {
                continue;
            }
            children[i].visible = false;
            if( children[i].objectName !== "separator") {
                children[i].clicked.disconnect( bubbleOverLay.showEventDetails );
                var key = children[i].objectName;
                if (intern.unUsedEvents[key] === "undefined") {
                    intern.unUsedEvents[key] = children[i];
                }
            }
        }
    }

    function isHashEmpty(hash) {
        for (var prop in hash) {
            if (prop)
                return false;
        }
        return true;
    }

    function getAKeyFromHash(hash) {
        for (var prop in hash) {
            return prop;
        }
        return "undefined";
    }

    function getUnusedEventBubble() {
        /* Recycle an item from unUsedEvents, and remove from hash */
        var key = getAKeyFromHash(intern.unUsedEvents);
        var unUsedBubble = intern.unUsedEvents[key];
        delete intern.unUsedEvents[key];

        return unUsedBubble;
    }

    function createEvent( event, depth, sizeOfRow ) {
        var eventBubble;
        if( isHashEmpty(intern.unUsedEvents) ) {
            var incubator = delegate.incubateObject(bubbleOverLay);
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        incubator.object.objectName = children.length;
                        assignBubbleProperties(incubator.object, event, depth, sizeOfRow);
                    }
                }
            } else {
                incubator.object.objectName = children.length;
                assignBubbleProperties(incubator.object, event, depth, sizeOfRow);
            }
        } else {
            eventBubble = getUnusedEventBubble();
            assignBubbleProperties(eventBubble, event, depth, sizeOfRow);
        }
    }

    function assignBubbleProperties(eventBubble, event, depth, sizeOfRow) {
        var yPos = 0;
        var height = 0;
        var hour = 0;
        var durationMin = 0;

        // skip it in case of endDateTime == dd-MM-yyyy 12:00 AM
        if (event.endDateTime - day  == 0)
            return;

        if (event.endDateTime.isSameDay(day) &&
                event.endDateTime.isSameDay(event.startDateTime)) {
            hour = event.startDateTime.getHours();
            yPos = (( event.startDateTime.getMinutes() * hourHeight) / 60) + hour * hourHeight
            durationMin = (event.endDateTime - event.startDateTime)  / Date.msPerMin;
        }
        if (!event.startDateTime.isSameDay(day) &&
                event.endDateTime.isSameDay(day)) {
            hour = 0;
            yPos = 0;
            durationMin = event.endDateTime.getHours() * 60;
            durationMin += event.endDateTime.getMinutes();
        }
        if (event.startDateTime.isSameDay(day) &&
                !event.endDateTime.isSameDay(day)) {
            hour = event.startDateTime.getHours();
            yPos = (( event.startDateTime.getMinutes() * hourHeight) / 60) + hour * hourHeight
            durationMin = (24 - event.startDateTime.getHours()) * 60;
        }
        if (!event.startDateTime.isSameDay(day) &&
                !event.endDateTime.isSameDay(day)) {
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
}
