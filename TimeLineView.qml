import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService


Flickable{
    id: scrolllView

    property var dayStart : new Date();

    property bool expanded: false
    property bool expanding: false
    property bool compressing: false

    signal expand()
    signal compress()
    signal newEvent()

    Component.onDestruction: {
        print("Time Line destroyed ....");
    }

    function scroll() {
        //scroll to first event or current hour
        var hour = intern.now.getHours();
        if(eventListModel.count > 0) {
            hour = eventListModel.get(0).startTime.getHours();
        }

        scrolllView.contentY = hour * units.gu(10);

        if(scrolllView.contentY >= scrolllView.contentHeight - scrolllView.height) {
            scrolllView.contentY = scrolllView.contentHeight - scrolllView.height
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
        for( var i = 0 ; i < eventLineColumn.children.length ;++i) {
            var child = eventLineColumn.children[i];
            if( child.customDelegate === 0) {
                var event = intern.eventMap[i];
                if( event ) {
                    child.showEvent(event);
                } else if( i === intern.now.getHours() && intern.now.isSameDay( scrolllView.dayStart )) {
                    child.showSeperator();
                } else {
                    child.hideChild();
                }
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

    height: parent.height
    width: parent.width
    clip: true

    contentHeight: timeLineColumn.height + units.gu(3)
    contentWidth: parent.width

    QtObject {
        id: intern
        property var eventMap;
        property var now : new Date();
    }

    EventListModel {
        id: eventListModel
        termStart: scrolllView.dayStart
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
        z:0

        Repeater{
            model: 24 // hour in a day

            delegate: Item {
                id: delegate
                width: parent.width
                height: units.gu(10)

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

    //Event bubble overlay
    Column{
        id: eventLineColumn
        anchors.top: parent.top
        anchors.topMargin: units.gu(3)
        width: parent.width
        z:1

        Repeater{
            id: repeater
            model: 24 // hour in a day

            delegate: Item {
                id: eventDelegate

                property int customDelegate: 0;

                width: parent.width
                height: units.gu(10)

                Rectangle{
                    id: infoBubble

                    property string title;
                    property string location;

                    visible: false

                    color:'#fffdaa';
                    width: scrolllView.width - units.gu(8)
                    x: units.gu(5)
                    z:1

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
                            scrolllView.showEventDetails(index);
                        }
                    }
                }

                Rectangle {
                    id: seperator
                    height: units.gu(0.5)
                    width: scrolllView.width - units.gu(2)
                    color: "#c94212"
                    visible: false
                    z: 1
                }

                function hideChild() {
                    for(var i=0 ; i < children.length ; ++i ) {
                        children[i].visible = false;
                    }
                }

                function showEvent( event) {
                    //var info = eventInfo.createObject(eventDelegate,{"title":event.title,"location":"test"});
                    infoBubble.visible = true;
                    infoBubble.title = event.title;
                    infoBubble.location = "test";

                    var yPos = ( event.startTime.getMinutes() * eventDelegate.height) / 60
                    infoBubble.y = yPos;

                    var durationMin = (event.endTime.getHours() - event.startTime.getHours()) * 60;
                    durationMin += (event.endTime.getMinutes() - event.startTime.getMinutes());
                    var height = (durationMin * eventDelegate.height )/ 60;
                    infoBubble.height = height;
                }

                function showSeperator() {
                    //var seperator = seperatorComponent.createObject(eventDelegate);
                    var yPos = (intern.now.getMinutes() * eventDelegate.height) / 60
                    seperator.visible = true;
                    seperator.y = yPos;
                    seperator.x = (parent.width - seperator.width)/2
                }
            }
        }
    }
}

