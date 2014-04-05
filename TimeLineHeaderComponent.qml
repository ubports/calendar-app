import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "ViewType.js" as ViewType


Row{
    id: header

    property int type: ViewType.ViewTypeWeek

    property var startDay: DateExt.today();
    property bool isCurrentItem: false

    signal dateSelected(var date);

    width: parent.width

    Repeater{
        model: type == ViewType.ViewTypeWeek ? 7 : 1

        delegate: HeaderDateComponent{
            date: startDay.addDays(index);
            dayFormat: {
                if( type == ViewType.ViewTypeWeek || (type == ViewType.ViewTypeDay && !root.isCurrentItem) ) {
                    Locale.ShortFormat
                } else {
                    Locale.LongFormat
                }
            }

            dateColor: {
                if( type == ViewType.ViewTypeWeek && date.isSameDay(DateExt.today())){
                    "white"
                } else if( type == ViewType.ViewTypeDay && root.isCurrentItem ) {
                    "white"
                } else {
                    "#AEA79F"
                }
            }

            width: {
                if( type == ViewType.ViewTypeWeek ) {
                    header.width/7
                } else {
                    header.width
                }
            }

            onDateSelected: {
                header.dateSelected(date);
            }
        }
    }
}

