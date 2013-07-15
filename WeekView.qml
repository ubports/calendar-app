import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService

Item{
    id: root
    anchors.fill: parent

    property var dayStart: new Date()

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

    Label{
        id: dummy;text: "SUN";visible: false;fontSize: "large"
    }

    WeekRibbon{
        id: weekRibbon
        startDay: dayStart.weekStart( Qt.locale().firstDayOfWeek);
        anchors.top: todayLabel.bottom
        anchors.left: timeLabel.right
        width: parent.width - timeLabel.width
        height: units.gu(10)
        weekWidth: dummy.width + units.gu(1)

        onDaySelected: {
            root.dayStart = day
            weekViewPath.weekStart = day
            print( "####Day selected: "+ day)
        }
    }

    PathViewBase{
        id: weekViewPath

        property var weekStart: root.dayStart

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
            var weekStartDay= weekStart.weekStart( Qt.locale().firstDayOfWeek);
            weekStart = weekStartDay.addDays(7);

            dayStart = weekStart
            weekRibbon.startDay = dayStart.weekStart( Qt.locale().firstDayOfWeek);
        }

        function previousWeek(){
            var weekStartDay = weekStart.weekStart(Qt.locale().firstDayOfWeek);
            weekStart = weekStartDay.addDays(-7)

            dayStart = weekStart
            weekRibbon.startDay = dayStart.weekStart( Qt.locale().firstDayOfWeek);
        }

        delegate: WeekComponent {
            id: timeLineView

            width: parent.width
            height: parent.height
            weekWidth: dummy.width + units.gu(1)

            weekStart: {
                if (index === weekViewPath.currentIndex) {
                    return weekViewPath.weekStart;
                }
                var previousIndex = weekViewPath.currentIndex > 0 ? weekViewPath.currentIndex - 1 : 2
                if ( index === previousIndex ) {
                    var weekStartDay= weekViewPath.weekStart.weekStart( Qt.locale().firstDayOfWeek);
                    return weekStartDay.addDays(-7);
                }

                var weekStartDay = weekViewPath.weekStart.weekStart( Qt.locale().firstDayOfWeek);
                return weekStartDay.addDays(0);
            }
        }
    }
}

