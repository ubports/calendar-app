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

    TimeSeparator{
        id: separator
        objectName: "separator"
        width:  bubbleOverLay.width
        visible: false
        z:1
    }

    QtObject {
        id: intern
        property var now : new Date();
    }

    function showEventDetails(event) {
        pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":event,"model":model});
    }

    property var eventMap;
    function createEvents() {
        if(!bubbleOverLay || bubbleOverLay == undefined) {
            return;
        }
        destroyAllChildren();

        eventMap = {};
        var startDate = new Date(day).midnight();
        var endDate = new Date(day).endOfDay();

        var items = model.getItems(startDate,endDate);
        for(var i = 0 ; i < items.length ; ++i) {
            var event = items[i];
            if(event.allDay === false && !eventMap[event.itemId]) {
                var subItems = getItems(event.startDateTime,event.endDateTime);
                for(var j=0; j < subItems.length ; ++j){
                    var subEvent = subItems[j];
                    eventMap[subEvent.itemId] = true;
                    var width = bubbleOverLay.width/subItems.length;
                    var x = j * width;
                    bubbleOverLay.createEvent(subEvent,subEvent.startDateTime.getHours(), x, width);
                }
            }
        }

        if( intern.now.isSameDay( bubbleOverLay.day ) ) {
            bubbleOverLay.showSeparator(intern.now.getHours());
        }
    }

    function getItems(start, end){
        var retItems = [];
        var items = model.getItems(start, end);
        for(var i = 0; i < items.length ; ++i){
            var event = items[i];
            if( event.allDay === false
                && event.startDateTime.getHours() === start.getHours() ) {
                retItems.push(event);
            }
        }
        return retItems;
    }

    function destroyAllChildren() {
        for( var i = children.length - 1; i >= 0 ;--i ) {
            children[i].visible = false;
            if( children[i].objectName !== "separator") {
                children[i].destroy();
            }
        }
    }

    function createEvent( event ,hour,x, width) {
        var eventBubble = delegate.createObject(bubbleOverLay);

        eventBubble.clicked.connect( bubbleOverLay.showEventDetails );

        var yPos = (( event.startDateTime.getMinutes() * hourHeight) / 60) + hour * hourHeight
        eventBubble.y = yPos;

        var durationMin = (event.endDateTime.getHours() - event.startDateTime.getHours()) * 60;
        durationMin += (event.endDateTime.getMinutes() - event.startDateTime.getMinutes());
        var height = (durationMin * hourHeight )/ 60;
        eventBubble.height = (height > eventBubble.minimumHeight) ? height:eventBubble.minimumHeight ;

        eventBubble.x = x;
        eventBubble.width = width;

        eventBubble.event = event
    }

    function showSeparator(hour) {
        var y = ((intern.now.getMinutes() * hourHeight) / 60) + hour * hourHeight;
        separator.y = y;
        separator.visible = true;
    }
}
