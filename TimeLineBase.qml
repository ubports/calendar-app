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
        termStart: bubbleOverLay.day.midnight()
        termLength: Date.msPerDay

        onReload: {
            bubbleOverLay.createEvents();
        }
    }

    TimeSeparator{
        id: separator
        objectName: "separator"
        width:  bubbleOverLay.width
        z:1
    }

    QtObject {
        id: intern
        property var now : new Date();
    }

    function showEventDetails(event) {
        pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":event});
    }

    function createEvents() {
        bubbleOverLay.destroyAllChildren();

        for(var i = 0 ; i < model.count ; ++i) {
            var event = model.get(i);
            if( event ) {
                bubbleOverLay.createEvent(event,event.startTime.getHours());
            }
        }

        if( intern.now.isSameDay( bubbleOverLay.day ) ) {
            bubbleOverLay.showSeparator(intern.now.getHours());
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

        eventBubble.event = event;
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
