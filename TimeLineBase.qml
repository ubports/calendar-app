import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt

import QtOrganizer 5.0

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
        var width = bubbleOverLay.width;
        var offset = width/(depth+1);
        for(var i=0; i < array.length ; ++i) {
            var schedule = array[i];
            var x = (schedule.depth) * offset
            var w = width - x;
            var event = intern.eventMap[schedule.id];
            bubbleOverLay.createEvent(event , x, w);
        }
    }

    function getMinutes(time) {
        return time.getHours() * 60 + time.getMinutes();
    }

    function getDuration(event) {
        var start = getMinutes(event.startDateTime);
        var end = getMinutes(event.endDateTime);
        return end - start;
    }

    function createEvents() {
        if(!bubbleOverLay || bubbleOverLay == undefined) {
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

            var start = getMinutes(event.startDateTime);
            var duration = getDuration(event);
            var schedule = {"start": start, "duration": duration,"id":event.itemId, "depth":0};
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
                children[i].destroy();
            }
        }
    }

    function createEvent( event, x, width ) {
        var hour = event.startDateTime.getHours();
        var eventBubble = delegate.createObject(bubbleOverLay);

        var yPos = (( event.startDateTime.getMinutes() * hourHeight) / 60) + hour * hourHeight
        eventBubble.y = yPos;

        var durationMin = (event.endDateTime.getHours() - event.startDateTime.getHours()) * 60;
        durationMin += (event.endDateTime.getMinutes() - event.startDateTime.getMinutes());
        var height = (durationMin * hourHeight )/ 60;
        eventBubble.height = (height > eventBubble.minimumHeight) ? height:eventBubble.minimumHeight ;

        eventBubble.x = x;
        eventBubble.width = width;
        eventBubble.event = event
        eventBubble.clicked.connect( bubbleOverLay.showEventDetails );
    }

    function showSeparator(hour) {
        var y = ((intern.now.getMinutes() * hourHeight) / 60) + hour * hourHeight;
        separator.y = y;
        separator.visible = true;
    }
}
