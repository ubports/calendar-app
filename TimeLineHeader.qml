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

    height: units.gu(10)
    width: parent.width

    property var date;

    delegate: TimeLineHeaderComponent{
        width: parent.width
        height: parent.height
        type: header.type

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
                return date.addDays(2);
            case 1:
                return date.addDays(1);
            }
        }

        function getDateForWeek() {
            switch( header.indexType(index)) {
            case 0:
                return date;
            case -1:
                return date.addDays(14);
            case 1:
                return date.addDays(7);
            }
        }
    }
}

