import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt


Row{
    id: header

    readonly property int typeWeek: 0
    readonly property int typeDay: 1
    property int type: typeWeek

    property var startDay: DateExt.today();
    property bool isCurrentItem: false

    width: parent.width

    Repeater{
        model: type == typeWeek ? 7 : 1

        delegate: HeaderDateComponent{
            date: startDay.addDays(index);
            dayFormat: {
                if( type == typeWeek || (type == typeDay && !root.isCurrentItem) ) {
                    Locale.ShortFormat
                } else {
                    Locale.LongFormat
                }
            }

            dateColor: {
                if( type == typeWeek && date.isSameDay(DateExt.today())){
                    "white"
                } else if( type == typeDay && root.isCurrentItem ) {
                    "white"
                } else {
                    "#AEA79F"
                }
            }

            width: {
                if( type == typeWeek ) {
                    header.width/7
                } else {
                    header.width
                }
            }
        }
    }
}
