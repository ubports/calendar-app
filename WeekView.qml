import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService

Page{
    id: root
    anchors.fill: parent

    property var dayStart: new Date()

    Component.onCompleted: {
        if( pageStack.header )
            pageStack.header.visible = false;
    }

    Component.onDestruction: {
        if( pageStack.header )
            pageStack.header.visible = true;
    }

    onDayStartChanged:{
        weekRibbon.visibleWeek = dayStart.weekStart(intern.firstDayOfWeek);
        weekViewPath.visibleWeek = dayStart.weekStart(intern.firstDayOfWeek);
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

    Label{
        id: dummy;text: "SUN";visible: false;fontSize: "large"
    }

    WeekRibbon{
        id: weekRibbon
        visibleWeek: dayStart.weekStart(intern.firstDayOfWeek);
        anchors.top: todayLabel.bottom
        anchors.left: timeLabel.right
        width: parent.width - timeLabel.width
        height: units.gu(10)
        weekWidth: dummy.width + units.gu(1)

        onWeekChanged: {
            dayStart = visibleWeek
        }
    }

    PathViewBase{
        id: weekViewPath

        property var visibleWeek: dayStart.weekStart(intern.firstDayOfWeek);

        QtObject{
            id: intern
            property int firstDayOfWeek: Qt.locale().firstDayOfWeek
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
            var weekStartDay = visibleWeek.weekStart(intern.firstDayOfWeek);
            visibleWeek = weekStartDay.addDays(7);

            dayStart = visibleWeek
        }

        function previousWeek(){
            var weekStartDay = visibleWeek.weekStart(intern.firstDayOfWeek);
            visibleWeek = weekStartDay.addDays(-7);

            dayStart = visibleWeek
        }

        delegate: WeekComponent {
            id: timeLineView

            width: parent.width
            height: parent.height
            weekWidth: dummy.width + units.gu(1)
            weekStart: getWeekStart();

            function getWeekStart() {
                if (index === weekViewPath.currentIndex) {
                    return intern.weekStart;
                }
                var previousIndex = weekViewPath.currentIndex > 0 ? weekViewPath.currentIndex - 1 : 2

                if ( index === previousIndex ) {
                    var weekStartDay= intern.weekStart.weekStart(intern.firstDayOfWeek);
                    return weekStartDay.addDays(-7);
                }

                var weekStartDay = intern.weekStart.weekStart(intern.firstDayOfWeek);
                return weekStartDay.addDays(7);
            }
        }
    }
}

