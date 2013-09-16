import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService

Item{
    id: root
    objectName: "DayView"

    anchors.fill: parent

    property var currentDay: new Date()

    Column {
        id: column
        anchors.top: parent.top
        anchors.topMargin: units.gu(1.5)
        width: parent.width; height: parent.height

        ViewHeader{
            id: viewHeader
            date: currentDay
        }

        TimeLineHeader{
            id: dayHeader
            type: typeDay
            date: currentDay.addDays(-2)
        }

        PathViewBase{
            id: dayViewPath
            objectName: "DayViewPathBase"

            property var startDay: currentDay

            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5

            width: parent.width
            height: column.height - viewHeader.height - dayHeader.height

            path: Path {
                startX: -(dayViewPath.width/1.75); startY: dayViewPath.height/2
                PathLine { x: (dayViewPath.width/7) * 11  ; relativeY: 0;  }
            }

            onNextItemHighlighted: {
                //next day
                currentDay = currentDay.addDays(1);
                dayHeader.incrementCurrentIndex()
            }

            onPreviousItemHighlighted: {
                //previous day
                currentDay = currentDay.addDays(-1);
                dayHeader.decrementCurrentIndex()
            }

            delegate: TimeLineBaseComponent {
                id: timeLineView
                objectName: "DayComponent-"+index

                type: typeDay

                width: parent.width/7 * 5
                height: parent.height
                z: index == dayViewPath.currentIndex ? 2 : 1

                startDay: getStartDay()

                function getStartDay() {
                    switch( dayViewPath.indexType(index)) {
                    case 0:
                        return dayViewPath.startDay;
                    case -1:
                        return dayViewPath.startDay.addDays(-1);
                    case 1:
                        return dayViewPath.startDay.addDays(1);
                    }
                }
            }
        }
    }
}
