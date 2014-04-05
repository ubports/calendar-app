import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "ViewType.js" as ViewType

Page{
    id: root
    objectName: "DayView"

    property var currentDay: new Date()
    property bool isCurrentPage: false

    Column {
        id: column
        anchors.top: parent.top
        anchors.topMargin: units.gu(1.5)
        width: parent.width; height: parent.height
        spacing: units.gu(1)

        anchors.fill: parent

        ViewHeader{
            id: viewHeader
            month: currentDay.getMonth()
            year: currentDay.getFullYear()
        }

        TimeLineHeader{
            id: dayHeader
            type: ViewType.ViewTypeDay
            date: currentDay
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            path: Path {
                startX: -(dayHeader.width/7); startY: dayHeader.height/2
                PathLine { x: (dayHeader.width/7) * 8  ; relativeY: 0;  }
            }
        }

        PathViewBase{
            id: dayViewPath
            objectName: "DayViewPathBase"

            property var startDay: currentDay
            //This is used to scroll all view together when currentItem scrolls
            property var childContentY;

            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5

            width: parent.width
            height: column.height - dayViewPath.y

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

                type: ViewType.ViewTypeDay

                width: parent.width/7 * 5
                height: parent.height
                z: index == dayViewPath.currentIndex ? 2 : 1

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
                    value: dayViewPath.childContentY;
                    when: !timeLineView.PathView.isCurrentItem
                }

                //set PathView's contentY property, if its current item
                Binding{
                    target: dayViewPath
                    property: "childContentY"
                    value: contentY
                    when: timeLineView.PathView.isCurrentItem
                }

                contentInteractive: timeLineView.PathView.isCurrentItem

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
