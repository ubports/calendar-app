import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt

UbuntuShape {
    id: root

    property var startDay: DateExt.today();

    property int type: typeWeek

    readonly property int typeWeek: 0
    readonly property int typeDay: 1

    color: "#e6e4e9"

    TimeLineHeader{
        id: header
        type: root.type
        anchors.top: parent.top
        startDay: root.startDay
    }

    Flickable{
        id: timeLineView

        anchors.top: header.bottom
        width: parent.width
        height: parent.height - header.height

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
                model: type == typeWeek ? 7 : 3

                delegate: TimeLineBase {
                    anchors.top: parent.top
                    width: {
                        if( type == typeWeek || (type == typeDay && index != 1 ) ) {
                             header.width/7
                        } else {
                            (header.width/7) * 5
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
                if( root.type == typeWeek || (root.type == typeDay && index != 1 ) ) {
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
