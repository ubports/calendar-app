import QtQuick 2.4
import Ubuntu.Components 1.3

    GridView{
    id: yearView

    property int scrollMonth;
    property bool isCurrentItem;
    property int year;
    readonly property var currentDate: new Date()
    readonly property int currentYear: currentDate.getFullYear()
    readonly property int currentMonth: currentDate.getMonth()
    readonly property int minCellWidth: units.gu(30)

    signal monthSelected(var date);

    function refresh() {
        scrollMonth = 0;
        if(year == currentYear) {
            scrollMonth = currentMonth
        }
        yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
    }

    // Does not increase cash buffer if user is scolling
    cacheBuffer: parent.PathView.view.flicking || parent.PathView.view.dragging || !isCurrentItem ? 0 : 6 * cellHeight

    cellWidth: Math.floor(Math.min.apply(Math, [3, 4].map(function(n)
    { return ((width / n >= minCellWidth) ? width / n : width / 2) })))
    cellHeight: cellWidth * 1.4

    clip: true
    model: 12 /* months in a year */

    //scroll in case content height changed
    onHeightChanged: {
        yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
    }

    Component.onCompleted: {
        yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
    }

    delegate: MonthComponent {
            id: monthComponent
            objectName: "monthComponent" + index

            width: yearView.cellWidth - units.gu(1)
            height: yearView.cellHeight - units.gu(1)
            y: units.gu(0.5)
            x: units.gu(0.5)

            currentYear: yearView.year
            currentMonth: index
            isCurrentItem: yearView.focus
            isYearView: true
            dayLabelFontSize:"x-small"
            dateLabelFontSize: "medium"
            leftLabelFontSize: "medium"
            rightLabelFontSize: "medium"
            onMonthSelected: {
                yearView.monthSelected(date);
            }
    }
}
