import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt
import "GlobalEventModel.js" as GlobalModel

Item {
    id: bubbleOverLay

    property var delegate;
    property var day;
    property int hourHeight: units.gu(10)

    Component.onCompleted: {
        intern.model = GlobalModel.gloablModel();
        intern.model.reloaded.connect(bubbleOverLay.createEvents);
    }

    onDayChanged: {
        if( intern.model)
            bubbleOverLay.createEvents();
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
        property var model;
    }

    function showEventDetails(event) {
        pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":event});
    }

    function createEvents() {
        bubbleOverLay.destroyAllChildren();

        var startDate = new Date(day);
        startDate.setHours(0,0,0,0);

        var endDate = startDate.addDays(1);
        endDate.setHours(0,0,0,0);

        var itemIds = intern.model.itemIds(startDate,endDate);
        for(var i = 0 ; i < itemIds.length ; ++i) {
            var eventId = itemIds[(i)];
            var event = intern.model.item(eventId);
            if( event ) {
                print("ITEM_ID Created--->" + eventId)
                bubbleOverLay.createEvent(event,event.startDateTime.getHours());
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
                children[i].visible = false;
                children[i].destroy();
            }
        }
    }

    function createEvent( event ,hour) {
        var eventBubble = delegate.createObject(bubbleOverLay);
        eventBubble.clicked.connect( bubbleOverLay.showEventDetails );
        eventBubble.event = event

        var yPos = (( event.startDateTime.getMinutes() * hourHeight) / 60) + hour * hourHeight
        eventBubble.y = yPos;

        var durationMin = (event.endDateTime.getHours() - event.startDateTime.getHours()) * 60;
        durationMin += (event.endDateTime.getMinutes() - event.startDateTime.getMinutes());
        var height = (durationMin * hourHeight )/ 60;
        eventBubble.height = height;
    }

    function showSeparator(hour) {
        var y = ((intern.now.getMinutes() * hourHeight) / 60) + hour * hourHeight;
        separator.y = y;
        separator.visible = true;
    }
}
