import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService

Item{
    id: root
    objectName: "DayView"

    anchors.fill: parent

    property var currentDay: new Date()

    onCurrentDayChanged:{
        weekRibbon.visibleWeek = currentDay.weekStart(Qt.locale().firstDayOfWeek);
        weekRibbon.setSelectedDay(currentDay);
    }

    Label{
        id: todayLabel
        text: Qt.formatDateTime( new Date(),"d MMMM yyyy");
        fontSize: "large"
        width: parent.width
    }

    Label{
        id: timeLabel;visible: false
        text: new Date(0, 0, 0, 0).toLocaleTimeString(Qt.locale(), i18n.tr("HH"))
    }

    WeekRibbon{
        id: weekRibbon
        visibleWeek: currentDay.weekStart(Qt.locale().firstDayOfWeek);
        anchors.top: todayLabel.bottom
        anchors.left: timeLabel.right
        width: parent.width
        height: units.gu(10)
        //removing timeLabel.width from front and back of ribbon
        weekWidth: ((width - 2* timeLabel.width )/ 7 )

        onWeekChanged: {
            currentDay = visibleWeek
        }

        onDaySelected: {
            currentDay = day;
        }
    }

    PathViewBase{
        id: weekViewPath
        objectName:"DayViewPathBase"

        property var visibleDay: currentDay;

        QtObject{
            id: intern
            property var startDay: weekViewPath.visibleDay.addDays(-1)
        }

        anchors.top: weekRibbon.bottom
        width: parent.width
        height: parent.height - weekRibbon.height - units.gu(3)

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

        delegate: DayComponent {
            id: timeLineView
            objectName: "DayComponent-"+index

            width: parent.width
            height: parent.height
            weekWidth: weekRibbon.weekWidth
            day: getStartDay();

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
