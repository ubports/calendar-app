import QtQuick 2.0
import Ubuntu.Components 0.1
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
        property var unUsedEvents: new Array;
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

    function createEvents() {
        if(!bubbleOverLay || bubbleOverLay == undefined) {
            return;
        }

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
                intern.unUsedEvents.push(children[i])
            }
        }
    }

    function createEvent( event, x, width ) {

        var eventBubble;
        if( intern.unUsedEvents.length == 0) {
            eventBubble = delegate.createObject(bubbleOverLay);
        } else {
            eventBubble = intern.unUsedEvents.pop();
        }

        var hour = event.startDateTime.getHours();
        var yPos = (( event.startDateTime.getMinutes() * hourHeight) / 60) + hour * hourHeight
        eventBubble.y = yPos;

        var durationMin = (event.endDateTime.getHours() - event.startDateTime.getHours()) * 60;
        durationMin += (event.endDateTime.getMinutes() - event.startDateTime.getMinutes());
        var height = (durationMin * hourHeight )/ 60;
        eventBubble.height = (height > eventBubble.minimumHeight) ? height:eventBubble.minimumHeight ;

        eventBubble.model = bubbleOverLay.model
        eventBubble.x = x;
        eventBubble.width = width;
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
