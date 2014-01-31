import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt

PathViewBase {
    id: header

    readonly property int typeWeek: 0
    readonly property int typeDay: 1
    property int type: typeWeek

    interactive: false
    model:3

    height: units.gu(8)
    width: parent.width

    property var date;

    DayHeaderBackground{
        height: FontUtils.sizeToPixels("medium") + units.gu(1.5)
    }

    delegate: TimeLineHeaderComponent{
        type: header.type

        isCurrentItem: index == header.currentIndex

        width: {
            if( type == typeWeek ) {
                 parent.width
            } else if( type == typeDay && isCurrentItem ){
                (header.width/7) * 5
            } else {
                (header.width/7)
            }
        }

        startDay: getStartDate();

        function getStartDate() {
            switch(type) {
            case typeWeek:
                return getDateForWeek();
            case typeDay:
                return getDateForDay();
            }
        }

        function getDateForDay() {
            switch( header.indexType(index)) {
            case 0:
                return date;
            case -1:
                return date.addDays(-1);
            case 1:
                return date.addDays(1);
            }
        }

        function getDateForWeek() {
            switch( header.indexType(index)) {
            case 0:
                return date;
            case -1:
                return date.addDays(-7);
            case 1:
                return date.addDays(7);
            }
        }
    }
}

