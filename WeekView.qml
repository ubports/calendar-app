import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt

Column {
    id: root

    property var dayStart: new Date();
    property var firstDay: dayStart.weekStart(1);
    anchors.top: parent.top
    anchors.topMargin: units.gu(1.5)
    spacing: units.gu(1)

    anchors.fill: parent

    ViewHeader{
        id: viewHeader
        date: dayStart
    }

    TimeLineHeader{
        id: weekHeader
        objectName: "weekHeader"
        type: typeWeek
        date: weekViewPath.weekStart
    }

    PathViewBase{
        id: weekViewPath

        property var visibleWeek: dayStart.weekStart(1);
        property var weekStart: weekViewPath.visibleWeek.addDays(-7)

        width: parent.width
        height: root.height - viewHeader.height - weekHeader.height

        onNextItemHighlighted: {
            nextWeek();
            weekHeader.incrementCurrentIndex()
        }

        onPreviousItemHighlighted: {
            previousWeek();
            weekHeader.decrementCurrentIndex()
        }

        function nextWeek() {
            var weekStartDay = visibleWeek.weekStart(1);
            dayStart = weekStartDay.addDays(7);
        }

        function previousWeek(){
            var weekStartDay = visibleWeek.weekStart(1);
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
                    var weekStartDay= weekViewPath.weekStart.weekStart(1);
                    return weekStartDay.addDays(14);
                case 1:
                    var weekStartDay = weekViewPath.weekStart.weekStart(1);
                    return weekStartDay.addDays(7);
                }
            }
        }
    }
}


