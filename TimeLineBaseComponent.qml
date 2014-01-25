import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt

Item {
    id: root

    property var startDay: DateExt.today();
    property alias contentY: timeLineView.contentY
    property alias contentInteractive: timeLineView.interactive

    property int type: typeWeek

    readonly property int typeWeek: 0
    readonly property int typeDay: 1

    //visible hour
    property int scrollHour: 9;

    onStartDayChanged: {
        scrollToDefHour();
    }

    //scroll in case content height changed
    onHeightChanged: {
        scrollToDefHour();
    }

    Connections{
        target: parent
        onScrollUp:{
            scrollToHour();
            scrollHour--;
            if( scrollHour < 0) {
                scrollHour =0;
            }
        }

        onScrollDown:{
            scrollToHour();
            scrollHour++;
            var visibleHour = root.height / units.gu(10);
            if( scrollHour > (24 -visibleHour)) {
                scrollHour = 24 - visibleHour;
            }
        }
    }

    function scrollToHour() {
        timeLineView.contentY = scrollHour * units.gu(10);
        if(timeLineView.contentY >= timeLineView.contentHeight - timeLineView.height) {
            timeLineView.contentY = timeLineView.contentHeight - timeLineView.height
        }
    }

    function scrollToDefHour() {
        //scroll to 9 o'clock
        scrollHour = 9
        scrollToHour();
    }

    Flickable{
        id: timeLineView

        anchors.top: parent.top
        width: parent.width
        height: parent.height

        contentHeight: units.gu(10) * 24
        contentWidth: width

        clip: true

        TimeLineBackground{
        }

        Row{
            id: week
            width: parent.width
            height: parent.height
            anchors.top: parent.top

            Repeater{
                model: type == typeWeek ? 7 : 1

                delegate: TimeLineBase {
                    property int idx: index
                    anchors.top: parent.top
                    width: {
                        if( type == typeWeek ) {
                             parent.width/7
                        } else {
                            (parent.width)
                        }
                    }
                    height: parent.height
                    delegate: comp
                    day: startDay.addDays(index)
                }
            }
        }
    }

    Component{
        id: comp
        EventBubble{
            type: {
                if( root.type == typeWeek ) {
                    narrowType
                } else {
                    wideType
                }
            }
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: units.gu(0.1)
            anchors.rightMargin: units.gu(0.1)
        }
    }
}
