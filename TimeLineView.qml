import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService


Flickable{
    id: scolllView

    property var dayStart : new Date();

    property bool expanded: false
    property bool expanding: false
    property bool compressing: false

    signal expand()
    signal compress()
    signal newEvent()

    function scroll() {
        //scroll to first event or current hour
        var hour = new Date().getHours();
        if(eventListModel.count > 0) {
            hour = eventListModel.get(0).startTime.getHours();
        }

        scolllView.contentY = hour * units.gu(10)
        if(scolllView.contentY >= scolllView.contentHeight - scolllView.height) {
            scolllView.contentY = scolllView.contentHeight - scolllView.height
        }
    }

    anchors.fill: root
    clip: true

    contentHeight: timeLineColumn.height + units.gu(3)
    contentWidth: parent.width

    onVisibleChanged: {
        if( visible ) {
            scroll();
        }
    }

//    onDayStartChanged: {
//        print(index +":"+dayStart)
//        for( var i=0 ; i < eventLineColumn.children.length-1 ;++i) {
//            eventLineColumn.children[i].createEvent();
//        }
//        scroll();
//    }

    function createEvents() {
        for( var i=0 ; i < eventLineColumn.children.length-1 ;++i) {
            eventLineColumn.children[i].createEvent();
        }
        scroll();
    }

    Text {
        id: dummy
        text: dayStart;
        visible: false
        onTextChanged: {
            createEvents();
        }
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

    EventListModel {
        id: eventListModel
        termStart: dayStart
        termLength: Date.msPerDay

        onCountChanged: {
            createEvents();
        }
    }

    Rectangle{
        id: bg; anchors.fill: parent
    }

    Column{
        id: timeLineColumn
        anchors.top: parent.top
        anchors.topMargin: units.gu(3)
        width: parent.width
        z:0

        Repeater{
            model: 24

            delegate: Item {
                id: delegate
                width: parent.width
                height: units.gu(10)

                Row {
                    width: parent.width
                    y: -timeLabel.height/2
                    Label{
                        id: timeLabel
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

    Column{
        id: eventLineColumn
        anchors.top: parent.top
        anchors.topMargin: units.gu(3)
        width: parent.width
        z:1

        Repeater{
            model: 24

            delegate: Item {
                id: eventDelegate
                width: parent.width
                height: units.gu(10)

                Component{
                    id: eventInfo
                    Rectangle{
                        property string title;
                        property string location;

                        color:'#fffdaa';
                        width: eventDelegate.width - units.gu(8)
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
                            Label{text:title;fontSize:"medium";color:"black"}
                            Label{text:location; fontSize:"small"; color:"black"}
                        }
                    }
                }

                function createEvent() {
                    eventDelegate.children = null;

                    for( var i = 0 ; i < eventListModel.count ; ++i) {
                        var event = eventListModel.get(i)
                        if( index === event.startTime.getHours() ) {

                            var temp = eventInfo.createObject(eventDelegate,{"title":event.title,"location":"test"});

                            var yPos = (event.startTime.getMinutes() * 10) / 60
                            temp.y = units.gu(yPos);

                            var duration = event.endTime.getHours() - event.startTime.getHours();
                            var height = (duration * 10 ) / 1;
                            temp.height = units.gu(height);
                        }
                    }
                }

                Component.onCompleted: {
                    createEvent();
                }
            }
        }
    }
}

