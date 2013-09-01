import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt

Row{
    id: header

    property int type: typeWeek

    property var startDay: DateExt.today();

    readonly property int typeWeek: 0
    readonly property int typeDay: 1

    width: parent.width
    height: units.gu(10)

    Repeater{
        model: type == typeWeek ? 7 : 3

        delegate: Item {
            property var date : startDay.addDays(index);

            width: {
                if( type == typeWeek || (type == typeDay && index != 1 ) ) {
                     header.width/7
                } else {
                    (header.width/7) * 5
                }
            }

            height: parent.height

            Rectangle{
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: units.gu(1)
                anchors.bottomMargin: units.gu(1)
                visible: {
                    if( type == typeDay && index == 1 ) {
                            true
                    } else if( type == typeWeek ){
                        date.isSameDay(DateExt.today());
                    } else {
                        false
                    }
                }
                color: "#e5dbe6"
                radius: units.gu(1)
            }

            Column{
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                spacing: units.gu(0.5)

                Label{
                    property var day: {
                        if( type == typeWeek || (type == typeDay && index != 1 ) ) {
                             Qt.locale().standaloneDayName(date.getDay(), Locale.ShortFormat)
                        } else {
                            Qt.locale().standaloneDayName(date.getDay(), Locale.LongFormat)
                        }
                    }

                    text: day.toUpperCase();
                    fontSize: "medium"
                    horizontalAlignment: Text.AlignHCenter
                    color: "#b77380"
                    width: parent.width
                }

                Label{
                    text: date.getDate();
                    fontSize: "large"
                    horizontalAlignment: Text.AlignHCenter
                    color:"#715772"
                    width: parent.width
                }
            }
        }
    }
}
