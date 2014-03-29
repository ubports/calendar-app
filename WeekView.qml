import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "ViewType.js" as ViewType

Column {
    id: root
    objectName: "WeekView"

    property var dayStart: new Date();
    property var firstDay: dayStart.weekStart(Qt.locale().firstDayOfWeek);
    property bool isCurrentPage: false

    anchors.fill: parent
    anchors.top: parent.top
    anchors.topMargin: units.gu(1.5)
    spacing: units.gu(1)

    ViewHeader{
        id: viewHeader
        month: dayStart.getMonth()
        year: dayStart.getFullYear()
    }

    TimeLineHeader{
        id: weekHeader
        objectName: "weekHeader"
        type: ViewType.ViewTypeWeek
        date: weekViewPath.weekStart
    }

    PathViewBase{
        id: weekViewPath

        property var visibleWeek: dayStart.weekStart(Qt.locale().firstDayOfWeek);
        property var weekStart: weekViewPath.visibleWeek

        width: parent.width
        height: root.height - weekViewPath.y

        //This is used to scroll all view together when currentItem scrolls
        property var childContentY;

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

            type: ViewType.ViewTypeWeek
            width: parent.width
            height: parent.height

            startDay: getWeekStart();

            Connections{
                target: root
                onIsCurrentPageChanged:{
                    if(root.isCurrentPage){
                        timeLineView.scrollToCurrentTime();
                    }
                }
            }

            //get contentY value from PathView, if its not current Item
            Binding{
                target: timeLineView
                property: "contentY"
                value: weekViewPath.childContentY;
                when: !timeLineView.PathView.isCurrentItem
            }

            //set PathView's contentY property, if its current item
            Binding{
                target: weekViewPath
                property: "childContentY"
                value: contentY
                when: timeLineView.PathView.isCurrentItem
            }

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


