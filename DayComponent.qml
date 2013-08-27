import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService

Flickable{
    id: timeLineView

    property var day: new Date()
    property int weekWidth:0;

    contentHeight: timeLineColumn.height + units.gu(3)
    contentWidth: width

    clip: true

    onDayChanged: {
        scroll();
    }

    //scroll in case content height changed
    onContentHeightChanged: {
        scroll()
    }

    function scroll() {
        //scroll to 9 o'clock or to now
        var now = new Date();
        var hour = 9
        if( day !== undefined
                && now.isSameDay(day)) {
            hour = now.getHours();
        }

        timeLineView.contentY = hour * units.gu(10);
        if(timeLineView.contentY >= timeLineView.contentHeight - timeLineView.height) {
            timeLineView.contentY = timeLineView.contentHeight - timeLineView.height
        }
    }

    Rectangle{
        id: background;
        anchors.fill: parent
        color: "white"
    }

    TimeLineBackground{
        id: timeLineColumn
        anchors.top: parent.top
        anchors.topMargin: units.gu(3)
        width: parent.width
    }

    TimeLineBase {
        id: bubbleOverLay

        width: timeLineColumn.width
        height: timeLineColumn.height
        anchors.top: parent.top
        anchors.topMargin: units.gu(3)
        delegate: infoBubbleComponent
        day: timeLineView.day
    }

    Component{
        id: infoBubbleComponent
        Rectangle{
            id: infoBubble

            property string title;
            property string location;
            property int hour;

            signal clicked(int hour);

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
                    infoBubble.clicked(hour);
                }
            }
        }
    }
}
