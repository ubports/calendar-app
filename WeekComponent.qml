import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService

Flickable{
    id: timeLineView

    property var weekStart: new Date()

    contentHeight: timeLineColumn.height + units.gu(3)
    contentWidth: width

    clip: true

    onWeekStartChanged: {
        scroll();
    }

    function scroll() {
        //scroll to 9 o'clock
        var hour = 9//intern.now.getHours();

        timeLineView.contentY = hour * units.gu(10);

        if(timeLineView.contentY >= timeLineView.contentHeight - timeLineView.height) {
            timeLineView.contentY = timeLineView.contentHeight - timeLineView.height
        }
    }

    Rectangle{
        id: background; anchors.fill: parent
        color: "white"
    }

    TimeLineBackground{
        id: timeLineColumn

        anchors.top: parent.top
        anchors.topMargin: units.gu(3)
        width: parent.width
    }

    Row{
        id: dayIndicator

        x: timeLabel.width

        width: parent.width
        height: timeLineView.contentHeight

        objectName: "dayLabelRow"

        Repeater{
            model:7
            delegate: Rectangle{
                height: dayIndicator.height
                width: dummy.width + units.gu(1)
                border.color: "gray"
                opacity: 0.1
            }
        }
    }

    Label{
        id: dummy
        text: "SUN"
        visible: false
        fontSize: "large"
    }

    Row{
        id: week
        width: timeLineColumn.width - x
        height: timeLineColumn.height
        anchors.top: parent.top
        anchors.topMargin: units.gu(3)
        x: timeLabel.width
        spacing: 0

        property var weekStartDay: timeLineView.weekStart.weekStart( Qt.locale().firstDayOfWeek );
        property int timeLineWidth: dummy.width + units.gu(1)//week.width / 7 //units.gu(5)

        Repeater{
            model: 7

            delegate: TimeLineBase {
                anchors.top: parent.top
                height: parent.height
                width: week.timeLineWidth
                delegate: infoBubbleComponent
                day: week.weekStartDay.addDays(index)
            }
        }
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
            width: week.timeLineWidth
            x: units.gu(0)

            border.color: "#f4d690"

            Label{
                text:infoBubble.title;
                fontSize:"small";
                color:"black"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: parent.width
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
