import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService

Item{
    id: root
    anchors.fill: parent

    property var dayStart: new Date();

    PathViewBase{
        id: weekViewPath

        property var visibleWeek: dayStart.weekStart(Qt.locale().firstDayOfWeek);
        property var weekStart: weekViewPath.visibleWeek.addDays(-7)

        anchors.top: parent.top
        anchors.topMargin: units.gu(1.5)
        width: parent.width
        height: parent.height - units.gu(3)

        onNextItemHighlighted: {
            nextWeek();
        }

        onPreviousItemHighlighted: {
            previousWeek();
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
                if (index === weekViewPath.currentIndex) {
                    return weekViewPath.weekStart;
                }
                var previousIndex = weekViewPath.currentIndex > 0 ? weekViewPath.currentIndex - 1 : 2

                if ( index === previousIndex ) {
                    var weekStartDay= weekViewPath.weekStart.weekStart(Qt.locale().firstDayOfWeek);
                    return weekStartDay.addDays(14);
                }

                var weekStartDay = weekViewPath.weekStart.weekStart(Qt.locale().firstDayOfWeek);
                return weekStartDay.addDays(7);
            }
        }
    }
}

