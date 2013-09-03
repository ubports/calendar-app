import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService

Item{
    id: root
    objectName: "DayView"

    anchors.fill: parent

    property var currentDay: new Date()

    PathViewBase{
        id: dayViewPath
        objectName: "DayViewPathBase"

        property var startDay: currentDay.addDays(-1)

        anchors.top: parent.top
        anchors.topMargin: units.gu(1.5)
        width: parent.width
        height: parent.height - units.gu(3)

        onNextItemHighlighted: {
            //next day
            currentDay = currentDay.addDays(1);
        }

        onPreviousItemHighlighted: {
            //previous day
            currentDay = currentDay.addDays(-1);
        }

        delegate: TimeLineBaseComponent {
            id: timeLineView
            objectName: "DayComponent-"+index

            type: typeDay

            width: parent.width
            height: parent.height
            startDay: getStartDay().addDays(-1);

            function getStartDay() {
                //previous page
                if (index === dayViewPath.currentIndex) {
                    return dayViewPath.startDay;
                }

                //next page
                var previousIndex = dayViewPath.currentIndex > 0 ? dayViewPath.currentIndex - 1 : 2
                if ( index === previousIndex ) {
                    return dayViewPath.startDay.addDays(2);
                }

                //current page
                return dayViewPath.startDay.addDays(1);
            }
        }
    }
}
