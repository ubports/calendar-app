import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService

Flickable{
    id: timeLineView

    property var weekStart: new Date().midnight();
    property int weekWidth:0;

    contentHeight: timeLineColumn.height
    contentWidth: width

    clip: true

    onWeekStartChanged: {
        scroll();
    }

    function scroll() {
        //scroll to 9 o'clock or to now
        var now = new Date();
        var hour = 9
        if( weekStart !== undefined
                && now.weekStart(Qt.locale().firstDayOfWeek).isSameDay(weekStart)) {
            hour = now.getHours();
        }

        timeLineView.contentY = hour * units.gu(10);
        if(timeLineView.contentY >= timeLineView.contentHeight - timeLineView.height) {
            timeLineView.contentY = timeLineView.contentHeight - timeLineView.height
        }
    }

    //scroll in case content height changed
    onContentHeightChanged: {
        scroll()
    }

    Rectangle{
        id: background;
        anchors.fill: parent
        color: "white"
    }

    TimeLineBackground{
        id: timeLineColumn
        anchors.top: parent.top
        width: parent.width
    }

    //vertical lines for weeks
    Row{
        id: dayIndicator

        x: timeLabel.width
        width: parent.width
        height: timeLineView.contentHeight

        Repeater{
            model:7
            delegate: Rectangle{
                height: dayIndicator.height
                width: weekWidth
                border.color: "gray"
                opacity: 0.1
            }
        }
    }

    Row{
        id: week
        width: timeLineColumn.width - x
        height: timeLineColumn.height
        anchors.top: parent.top
        x: timeLabel.width
        spacing: 0

        property var weekStartDay: timeLineView.weekStart.weekStart( Qt.locale().firstDayOfWeek );

        Repeater{
            model: 7

            delegate: TimeLineBase {
                anchors.top: parent.top
                height: parent.height
                width: weekWidth
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
            property var event;

            signal clicked(var event);

            color:'#fffdaa';
            width: weekWidth
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
                    infoBubble.clicked(infoBubble.event);
                }
            }
        }
    }
}
