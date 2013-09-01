import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService

Item{
    id: root
    objectName: "DayView"

    anchors.fill: parent

    property var currentDay: new Date()

    Label{
        id: todayLabel
        text: Qt.formatDateTime( new Date(),"d MMMM yyyy");
        fontSize: "large"
        width: parent.width
    }

    PathViewBase{
        id: weekViewPath
        objectName:"DayViewPathBase"

        property var visibleDay: currentDay;

        QtObject{
            id: intern
            property int firstDayOfWeek: Qt.locale().firstDayOfWeek
            property var startDay: weekViewPath.visibleDay.addDays(-1)
        }

        anchors.top: todayLabel.bottom
        width: parent.width
        height: parent.height - todayLabel.height - units.gu(3)

        onNextItemHighlighted: {
            nextDay();
        }

        onPreviousItemHighlighted: {
            previousDay();
        }

        function nextDay() {
            currentDay = visibleDay.addDays(1);
        }

        function previousDay(){
            currentDay = visibleDay.addDays(-1);
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
                if (index === weekViewPath.currentIndex) {
                    return intern.startDay;
                }

                //next page
                var previousIndex = weekViewPath.currentIndex > 0 ? weekViewPath.currentIndex - 1 : 2
                if ( index === previousIndex ) {
                    return intern.startDay.addDays(2);
                }

                //current page
                return intern.startDay.addDays(1);
            }
        }
    }
}
