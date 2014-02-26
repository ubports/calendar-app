import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt

Column {
    id: root
    objectName: "WeekView"

    property var dayStart: new Date();
    property var firstDay: dayStart.weekStart(Qt.locale().firstDayOfWeek);
    anchors.top: parent.top
    anchors.topMargin: units.gu(1.5)
    spacing: units.gu(1)

    anchors.fill: parent

    ViewHeader{
        id: viewHeader
        //date: dayStart
        month: dayStart.getMonth()
        year: dayStart.getFullYear()
    }

    TimeLineHeader{
        id: weekHeader
        objectName: "weekHeader"
        type: typeWeek
        date: weekViewPath.weekStart
    }

    PathViewBase{
        id: weekViewPath

        property var visibleWeek: dayStart.weekStart(Qt.locale().firstDayOfWeek);
        property var weekStart: weekViewPath.visibleWeek

        width: parent.width
        height: root.height - weekViewPath.y

        onNextItemHighlighted: {
            nextWeek();
            weekHeader.incrementCurrentIndex()
        }

        onPreviousItemHighlighted: {
            previousWeek();
            weekHeader.decrementCurrentIndex()
        }

        function nextWeek() {
            var weekStartDay = visibleWeek.weekStart(Qt.locale().firstDayOfWeek);
            dayStart = weekStartDay.addDays(7);
        }

        function previousWeek(){
            var weekStartDay = visibleWeek.weekStart(Qt.locale().firstDayOfWeek);
            dayStart = weekStartDay.addDays(-7);
        }

        delegate: TimeLineBaseComponent {
            id: timeLineView

            type: typeWeek

            width: parent.width
            height: parent.height
            startDay: getWeekStart();

            function getWeekStart() {
                switch( weekViewPath.indexType(index)) {
                case 0:
                    return weekViewPath.weekStart;
                case -1:
                    var weekStartDay= weekViewPath.weekStart.weekStart(Qt.locale().firstDayOfWeek);
                    return weekStartDay.addDays(-7);
                case 1:
                    var weekStartDay = weekViewPath.weekStart.weekStart(Qt.locale().firstDayOfWeek);
                    return weekStartDay.addDays(7);
                }
            }
        }
    }
}


