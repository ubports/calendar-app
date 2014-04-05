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

    signal dateSelected(var date);

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
        date: firstDay

        onDateSelected: {
            root.dateSelected(date);
        }
    }

    PathViewBase{
        id: weekViewPath

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
            dayStart = firstDay.addDays(7);
        }

        function previousWeek(){
            dayStart = firstDay.addDays(-7);
        }

        delegate: TimeLineBaseComponent {
            id: timeLineView

            type: ViewType.ViewTypeWeek

            width: parent.width
            height: parent.height

            startDay: firstDay.addDays( weekViewPath.indexType(index) * 7)

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
        }
    }
}


