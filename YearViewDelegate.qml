import QtQuick 2.0
import Ubuntu.Components 1.1

GridView{
    id: yearView

    property int scrollMonth;
    property bool isCurrentItem;
    property int year;
    readonly property var currentDate: new Date()
    readonly property int currentYear: currentDate.getFullYear()
    readonly property int currentMonth: currentDate.getMonth()
    readonly property int minCellWidth: units.gu(30)

    cellWidth: Math.floor(Math.min.apply(Math, [3, 4].map(function(n)
    { return ((width / n >= minCellWidth) ? width / n : width / 2) })))

    cellHeight: cellWidth * 1.4
    clip: true
    cacheBuffer: 6 * cellHeight

    model: 12 /* months in a year */

    onYearChanged: {
        scrollMonth = 0;
        if(year == currentYear) {
            scrollMonth = currentMonth
        }
        yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
    }

    //scroll in case content height changed
    onHeightChanged: {
        yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
    }

    Component.onCompleted: {
        yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
    }

    Connections{
        target: yearPathView
        onScrollUp: {
            scrollMonth -= 2;
            if(scrollMonth < 0) {
                scrollMonth = 0;
            }
            yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
        }

        onScrollDown: {
            scrollMonth += 2;
            var visibleMonths = yearView.height / cellHeight;
            if( scrollMonth >= (11 - visibleMonths)) {
                scrollMonth = (11 - visibleMonths);
            }
            yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
        }
    }

    delegate: Item {
        width: yearView.cellWidth
        height: yearView.cellHeight

        UbuntuShape {
            radius: "medium"
            anchors {
                fill: parent
                margins: units.gu(0.5)
            }

            MonthComponent {
                id: monthComponent
                objectName: "monthComponent" + index

                anchors.fill: parent
                showEvents: false
                currentMonth: new Date(yearView.year, index, 1, 0, 0, 0, 0)
                isCurrentItem: yearView.focus
                isYearView: true
                dayLabelFontSize:"x-small"
                dateLabelFontSize: "medium"
                monthLabelFontSize: "medium"
                yearLabelFontSize: "medium"

                onMonthSelected: {
                    yearViewPage.monthSelected(date);
                }
            }
        }
    }
}
