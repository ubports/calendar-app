import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt

Column {
    id: root

    property int type: typeWeek

    property var startDay: DateExt.today();

    readonly property int typeWeek: 0
    readonly property int typeDay: 1

    clip: true

    width: parent.width

    Item{
         id: monthHeader
         width: parent.width
         height: monthLabel.height

         Label{
             id: monthLabel
             fontSize: "large"
             text: Qt.locale().standaloneMonthName(root.startDay.getMonth())
             anchors.leftMargin: units.gu(1)
             anchors.left: parent.left
             //color:"white"
             anchors.verticalCenter: parent.verticalCenter
         }

         Label{
             id: yearLabel
             fontSize: "medium"
             text: root.startDay.getFullYear()
             anchors.right: parent.right
             anchors.rightMargin: units.gu(1)
             color:"#AEA79F"
             anchors.verticalCenter: parent.verticalCenter
         }
     }

    Row{
        id: header

        width: parent.width
        height: units.gu(10)

        Repeater{
            model: type == typeWeek ? 7 : 3

            delegate: Item {
                property var date : startDay.addDays(index);
                property int weekDayWidth: header.width / 7

                width: {
                    if( type == typeWeek || (type == typeDay && index != 1 ) ) {
                         weekDayWidth
                    } else {
                        weekDayWidth * 5
                    }
                }

                height: parent.height

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
                        color: "#AEA79F"
                        width: parent.width
                    }

                    Label{
                        text: date.getDate();
                        fontSize: "large"
                        horizontalAlignment: Text.AlignHCenter
                        color: {
                            if( type == typeDay && index == 1 ) {
                                "#715772"
                            } else if( type == typeWeek && date.isSameDay(DateExt.today())){
                                 "#715772"
                            } else {
                                "#AEA79F"
                            }
                        }
                        width: parent.width
                    }
                }
            }
        }
    }
}

