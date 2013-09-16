import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt

Column {
    id: root

    readonly property int typeWeek: 0
    readonly property int typeDay: 1
    property int type: typeWeek

    property var startDay: DateExt.today();

    width: parent.width

    Row{
        id: header

        width: parent.width
        height: parent.height

        Repeater{
            model: type == typeWeek ? 7 : 3

            delegate: HeaderDateComponent{
                date: startDay.addDays(index);
                dayFormat: {
                    if( type == typeWeek || (type == typeDay && index != 1) ) {
                        Locale.ShortFormat
                    } else {
                        Locale.LongFormat
                    }
                }

                dateColor: {
                    if( type == typeWeek && date.isSameDay(DateExt.today())){
                        "white"
                    } else if( type == typeDay && index == 1) {
                        "white"
                    } else {
                        "#AEA79F"
                    }
                }

                width: {
                    if( type == typeWeek || (type == typeDay && index != 1 ) ) {
                         header.width/7
                    } else {
                        (header.width/7) * 5
                    }
                }
            }
        }
    }
}
