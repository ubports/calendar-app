import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService

EventViewBase{
    id: root

    flickableChild: timeLineView

    onModelRefreshed: {
        timeLineView.createEvents();
    }

    Flickable{
        id: timeLineView
        anchors.fill: parent

        function scroll() {
            //scroll to first event or current hour
            var hour = intern.now.getHours();
            if( eventModel.count > 0) {
                hour = eventModel.get(0).startTime.getHours();
            }

            timeLineView.contentY = hour * intern.hourHeight;

            if(timeLineView.contentY >= timeLineView.contentHeight - timeLineView.height) {
                timeLineView.contentY = timeLineView.contentHeight - timeLineView.height
            }
        }

        function createEventMap() {
            var eventMap = {};
            for(var i = 0 ; i < eventModel.count ; ++i) {
                var event = eventModel.get(i);
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
                } else if( i === intern.now.getHours()
                          && intern.now.isSameDay( root.dayStart )) {
                    bubbleOverLay.createSeparator(i);
                }
            }

            scroll();
        }

        function showEventDetails(hour) {
            var event = intern.eventMap[hour];
            pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":event});
        }

        contentHeight: timeLineColumn.height + units.gu(3)
        contentWidth: width

        QtObject {
            id: intern
            property var eventMap;
            property var now : new Date();
            property var hourHeight : units.gu(10)
        }

        Rectangle{
            id: background; anchors.fill: parent
            color: "white"
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
                            // TRANSLATORS: this is a time formatting string,
                            // see http://qt-project.org/doc/qt-5.0/qtqml/qml-qtquick2-date.html#details for valid expressions
                            //text: new Date(0, 0, 0, index).toLocaleTimeString(Qt.locale(), i18n.tr("HH:mm"))
                            text: new Date(0, 0, 0, index).toLocaleTimeString(Qt.locale(), i18n.tr("HH"))
                            color:"gray"
                            anchors.top: parent.top
                        }
                        Rectangle{
                            width: parent.width -timeLabel.width
                            height:units.dp(1)
                            color:"gray"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Rectangle{
                        width: parent.width - units.gu(5)
                        height:units.dp(1)
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

            function destroyAllChildren() {
                for( var i = children.length - 1; i >= 0; --i ) {
                    children[i].destroy();
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

            function createSeparator(hour) {
                var w = timeLineView.width - units.gu(2);
                var y = ((intern.now.getMinutes() * intern.hourHeight) / 60) + hour * intern.hourHeight;
                var x = (parent.width -  w)/ 2;
                var properties = {"x": x, "y": y, "width": w}

                var component = Qt.createComponent("TimeSeparator.qml");
                var separator = component.createObject(bubbleOverLay, properties);
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
    }
}
