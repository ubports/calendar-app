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
import QtQuick 2.0
import Ubuntu.Components 1.1
import "dateExt.js" as DateExt

Item {
    id: bubbleOverLay

    property var delegate;
    property var day;
    property int hourHeight: units.gu(10)
    property var model;

    MouseArea {
        anchors.fill: parent
        objectName: "mouseArea"
        onPressAndHold: {
            var selectedDate = new Date(day);
            var hour = parseInt(mouseY / hourHeight);
            selectedDate.setHours(hour)
            pageStack.push(Qt.resolvedUrl("NewEvent.qml"), {"date":selectedDate, "model":eventModel});
        }
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
        pageStack.push(Qt.resolvedUrl("EventDetails.qml"), {"event":event,"model":model});
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
        if(!bubbleOverLay || bubbleOverLay == undefined || model === undefined) {
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
            bubbleOverLay.showSeparator(intern.now.getHours());
        }
    }

    function destroyAllChildren() {
        for( var i = children.length - 1; i >= 0; --i ) {
            if( children[i].objectName === "mouseArea" ) {
                continue;
            }
            children[i].visible = false;
            if( children[i].objectName !== "separator") {
                children[i].clicked.disconnect( bubbleOverLay.showEventDetails );
                var key = children[i].objectName;
                if (intern.unUsedEvents[key] == "undefined") {

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
            eventBubble = delegate.createObject(bubbleOverLay);
            eventBubble.objectName = children.length;
        } else {
            eventBubble = getUnusedEventBubble();
        }

        var hour = event.startDateTime.getHours();
        var yPos = (( event.startDateTime.getMinutes() * hourHeight) / 60) + hour * hourHeight
        eventBubble.y = yPos;

        var durationMin = (event.endDateTime.getHours() - event.startDateTime.getHours()) * 60;
        durationMin += (event.endDateTime.getMinutes() - event.startDateTime.getMinutes());
        var height = (durationMin * hourHeight )/ 60;
        eventBubble.height = (height > eventBubble.minimumHeight) ? height:eventBubble.minimumHeight ;

        eventBubble.model = bubbleOverLay.model
        eventBubble.depthInRow = depth;
        eventBubble.sizeOfRow = sizeOfRow;
        eventBubble.event = event
        eventBubble.visible = true;
        eventBubble.clicked.connect( bubbleOverLay.showEventDetails );
    }

    function showSeparator(hour) {
        var y = ((intern.now.getMinutes() * hourHeight) / 60) + hour * hourHeight;
        separator.y = y;
        separator.visible = true;
    }
}
