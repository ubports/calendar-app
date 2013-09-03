import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService

Item{
    id: root
    anchors.fill: parent

    property var dayStart: new Date();

    onDayStartChanged:{
        weekRibbon.visibleWeek = dayStart.weekStart(Qt.locale().firstDayOfWeek);
        weekViewPath.visibleWeek = dayStart.weekStart(Qt.locale().firstDayOfWeek);
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
        visibleWeek: dayStart.weekStart(Qt.locale().firstDayOfWeek);
        anchors.top: todayLabel.bottom
        anchors.left: timeLabel.right
        width: parent.width
        height: units.gu(10)
        //removing timeLabel.width from front and back of ribbon
        weekWidth: ((width - 2* timeLabel.width )/ 7 )

        onWeekChanged: {
            dayStart = visibleWeek
        }
    }

    PathViewBase{
        id: weekViewPath

        property var visibleWeek: dayStart.weekStart(Qt.locale().firstDayOfWeek);

        QtObject{
            id: intern
            property var weekStart: weekViewPath.visibleWeek.addDays(-7)
        }

        anchors.top: weekRibbon.bottom
        width: parent.width
        height: parent.height - weekRibbon.height - units.gu(3)

        onNextItemHighlighted: {
            nextWeek();
        }

        onPreviousItemHighlighted: {
            previousWeek();
        }

        function nextWeek() {
            var weekStartDay = visibleWeek.weekStart(Qt.locale().firstDayOfWeek);
            visibleWeek = weekStartDay.addDays(7);

            dayStart = visibleWeek
        }

        function previousWeek(){
            var weekStartDay = visibleWeek.weekStart(Qt.locale().firstDayOfWeek);
            visibleWeek = weekStartDay.addDays(-7);

            dayStart = visibleWeek
        }

        delegate: WeekComponent {
            id: timeLineView

            width: parent.width
            height: parent.height
            weekWidth: weekRibbon.weekWidth
            weekStart: getWeekStart();

            function getWeekStart() {
                if (index === weekViewPath.currentIndex) {
                    return intern.weekStart;
                }
                var previousIndex = weekViewPath.currentIndex > 0 ? weekViewPath.currentIndex - 1 : 2

                if ( index === previousIndex ) {
                    var weekStartDay= intern.weekStart.weekStart(Qt.locale().firstDayOfWeek);
                    return weekStartDay.addDays(14);
                }

                var weekStartDay = intern.weekStart.weekStart(Qt.locale().firstDayOfWeek);
                return weekStartDay.addDays(7);
            }
        }
    }
}

