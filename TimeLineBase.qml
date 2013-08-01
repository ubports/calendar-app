import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt

Item {
    id: bubbleOverLay

    property var delegate;
    property var day;
    property int hourHeight: units.gu(10)

    EventListModel {
        id: model
        termStart: bubbleOverLay.day
        termLength: Date.msPerDay

        onReload: {
            bubbleOverLay.createEvents();
        }
    }

    TimeSeparator{
        id: separator
        objectName: "separator"
        width:  bubbleOverLay.width
    }

    QtObject {
        id: intern
        property var eventMap;
        property var now : new Date();
    }

    function showEventDetails(hour) {
        var event = intern.eventMap[hour];
        pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":event});
    }

    function createEventMap() {
        var eventMap = {};
        for(var i = 0 ; i < model.count ; ++i) {
            var event = model.get(i);
            eventMap[event.startTime.getHours()] = event
        }
        return eventMap;
    }

    function createEvents() {
        intern.eventMap = createEventMap();

        bubbleOverLay.destroyAllChildren();

        for( var i=0; i < 24; ++i ) {
            var event = intern.eventMap[i];
            if( event ) {
                bubbleOverLay.createEvent(event,i);
            }

            if(  i === intern.now.getHours()
                      && intern.now.isSameDay( bubbleOverLay.day )) {
                bubbleOverLay.showSeparator(i);
            }
        }
    }

    function destroyAllChildren() {
        for( var i = children.length - 1; i >= 0; --i ) {
            if( children[i].objectName === "separator") {
                children[i].visible = false;
            } else {
                children[i].destroy();
            }
        }
    }

    function createEvent( event ,hour) {
        var eventBubble = delegate.createObject(bubbleOverLay);

        eventBubble.clicked.connect( bubbleOverLay.showEventDetails );

        eventBubble.title = event.title;
        eventBubble.location = "Test"//event.location;
        eventBubble.hour = hour;

        var yPos = (( event.startTime.getMinutes() * hourHeight) / 60) + hour * hourHeight
        eventBubble.y = yPos;

        var durationMin = (event.endTime.getHours() - event.startTime.getHours()) * 60;
        durationMin += (event.endTime.getMinutes() - event.startTime.getMinutes());
        var height = (durationMin * hourHeight )/ 60;
        eventBubble.height = height;
    }

    function showSeparator(hour) {
        var y = ((intern.now.getMinutes() * hourHeight) / 60) + hour * hourHeight;
        separator.y = y;
        separator.visible = true;
    }
}
