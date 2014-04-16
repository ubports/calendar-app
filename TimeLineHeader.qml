import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "ViewType.js" as ViewType

PathViewBase {
    id: header

    property int type: ViewType.ViewTypeWeek

    interactive: false
    model:3

    height: units.gu(8)
    width: parent.width

    property var date;

    signal dateSelected(var date);

    DayHeaderBackground{
        height: FontUtils.sizeToPixels("medium") + units.gu(1.5)
    }

    delegate: TimeLineHeaderComponent{
        type: header.type

        isCurrentItem: index == header.currentIndex

        width: {
            if( type == ViewType.ViewTypeWeek ) {
                 parent.width
            } else if( type == ViewType.ViewTypeDay && isCurrentItem ){
                (header.width/7) * 5
            } else {
                (header.width/7)
            }
        }

        startDay: getStartDate();

        onDateSelected: {
            header.dateSelected(date);
        }

        function getStartDate() {
            var indexType = header.indexType(index);
            switch(type) {
            case ViewType.ViewTypeWeek:
                return date.addDays(7*indexType);
            case ViewType.ViewTypeDay:
                return date.addDays(1*indexType);
            }
        }
    }
}

