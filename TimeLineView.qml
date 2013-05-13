import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService


Flickable{
    id: timeLineView

    property var dayStart : new Date();

    property bool expanded: false
    property bool expanding: false
    property bool compressing: false

    signal expand()
    signal compress()
    signal newEvent()

    function scroll() {
        //scroll to first event or current hour
        var hour = intern.now.getHours();
        if(eventListModel.count > 0) {
            hour = eventListModel.get(0).startTime.getHours();
        }

        timeLineView.contentY = hour * units.gu(10);

        if(timeLineView.contentY >= timeLineView.contentHeight - timeLineView.height) {
            timeLineView.contentY = timeLineView.contentHeight - timeLineView.height
        }
    }

    function createEventMap() {
        var eventMap = {};
        for(var i = 0 ; i < eventListModel.count ; ++i) {
            var event = eventListModel.get(i);
            eventMap[event.startTime.getHours()] = event
        }
        return eventMap;
    }

    function createEvents() {
        intern.eventMap = createEventMap();

        bubbleOverLay.destroyAllChilds();

        for( var i=0; i < 24; ++i ) {
            var event = intern.eventMap[i];
            if( event ) {
                bubbleOverLay.createEvent(event,i);
            } else if( i === intern.now.getHours()
                      && intern.now.isSameDay( timeLineView.dayStart )) {
                bubbleOverLay.createSeperator(i);
            }
        }

        scroll();
    }

    function showEventDetails(hour) {
        var event = intern.eventMap[hour];
        pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":event});
    }

    onContentYChanged: {
        // console.log(expanded, expanding, compressing, dragging, flicking, moving, contentY)
        if (expanding || compressing || !dragging) return

        if (expanded) {
            if (contentY < -units.gu(0.5)) {
                compressing = true
                expanding = false
            }
        }
        else {
            if (contentY < -units.gu(0.5)) {
                expanding = true
                compressing = false
            }
        }
    }

    onDraggingChanged: {
        if (dragging) return

        if (expanding) {
            expanding = false
            expand()
        }
        else if (compressing) {
            compressing = false
            compress()
        }
    }

    clip: true

    contentHeight: timeLineColumn.height + units.gu(3)
    contentWidth: width

    QtObject {
        id: intern
        property var eventMap;
        property var now : new Date();
        property var hourHeight : units.gu(10)
    }

    EventListModel {
        id: eventListModel
        termStart: timeLineView.dayStart
        termLength: Date.msPerDay

        onReload: {
            createEvents();
        }
    }

    Rectangle{
        id: background; anchors.fill: parent
    }

    //Time line view
    Column{
        id: timeLineColumn
        anchors.top: parent.top
        anchors.topMargin: units.gu(3)
        width: parent.width        

        Repeater{
            model: 24 // hour in a day

            delegate: Item {
                id: delegate
                width: parent.width
                height: intern.hourHeight

                Row {
                    width: parent.width
                    y: -timeLabel.height/2
                    Label{
                        id: timeLabel
                        // FIXME: how to represent
                        text: index+":00"
                        color:"gray"
                        anchors.top: parent.top
                    }
                    Rectangle{
                        width: parent.width -timeLabel.width
                        height:units.gu(0.1)
                        color:"gray"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle{
                    width: parent.width - units.gu(5)
                    height:units.gu(0.1)
                    color:"gray"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    Item {
        id: bubbleOverLay

        width: timeLineColumn.width
        height: timeLineColumn.height
        anchors.top: parent.top
        anchors.topMargin: units.gu(3)

        function destroyAllChilds() {
            for(var i=0 ; i < children.length ; ++i ) {
                children[i].destroy(100);
            }
        }

        function createEvent( event ,hour) {
            var eventBubble = infoBubbleComponent.createObject(bubbleOverLay);
            eventBubble.title = event.title;
            eventBubble.location = "test";
            eventBubble.hour = hour;

            var yPos = (( event.startTime.getMinutes() * intern.hourHeight) / 60) + hour * intern.hourHeight
            eventBubble.y = yPos;

            var durationMin = (event.endTime.getHours() - event.startTime.getHours()) * 60;
            durationMin += (event.endTime.getMinutes() - event.startTime.getMinutes());
            var height = (durationMin * intern.hourHeight )/ 60;
            eventBubble.height = height;
        }

        function createSeperator(hour) {
            var sepatator = separatorComponent.createObject(bubbleOverLay);
            var yPos = ((intern.now.getMinutes() * intern.hourHeight) / 60) + hour * intern.hourHeight
            sepatator.visible = true;
            sepatator.y = yPos;
            sepatator.x = (parent.width - seperator.width)/2
        }
    }

    Component{
        id: infoBubbleComponent
        Rectangle{
            id: infoBubble

            property string title;
            property string location;
            property int hour;

            color:'#fffdaa';
            width: timeLineView.width - units.gu(8)
            x: units.gu(5)

            border.color: "#f4d690"

            Column{
                id: column
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top

                    leftMargin: units.gu(1)
                    rightMargin: units.gu(1)
                    topMargin: units.gu(1)
                }
                spacing: units.gu(1)
                Label{text:infoBubble.title;fontSize:"medium";color:"black"}
                Label{text:infoBubble.location; fontSize:"small"; color:"black"}
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    timeLineView.showEventDetails(hour);
                }
            }
        }
    }

    Component {
        id: separatorComponent
        Rectangle {
            id: separator
            height: units.gu(0.5)
            width: timeLineView.width - units.gu(2)
            color: "#c94212"
            visible: false
        }
    }
}

