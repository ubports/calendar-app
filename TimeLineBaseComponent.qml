import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt

Item {
    id: root

    property var startDay: DateExt.today();

    property int type: typeWeek

    readonly property int typeWeek: 0
    readonly property int typeDay: 1

    onStartDayChanged: {
        timeLineView.scroll();
    }

    //scroll in case content height changed
    onHeightChanged: {
        timeLineView.scroll()
    }

    Flickable{
        id: timeLineView

        anchors.top: parent.top
        width: parent.width
        height: parent.height

        contentHeight: units.gu(10) * 24
        contentWidth: width

        clip: true

        function scroll() {
            //scroll to 9 o'clock
            var hour = 9

            timeLineView.contentY = hour * units.gu(10);
            if(timeLineView.contentY >= timeLineView.contentHeight - timeLineView.height) {
                timeLineView.contentY = timeLineView.contentHeight - timeLineView.height
            }
        }

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
