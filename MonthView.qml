import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

Page {
    id: monthViewPage
    objectName: "monthViewPage"

    property var currentMonth: DateExt.today();

    signal dateSelected(var date);

    Keys.forwardTo: [monthViewPath]

    PathViewBase{
        id: monthViewPath
        objectName: "monthViewPath"

        property var startMonth: currentMonth;

        anchors.top:parent.top

        width:parent.width
        height: parent.height

        onNextItemHighlighted: {
            nextMonth();
        }

        onPreviousItemHighlighted: {
            previousMonth();
        }

        function nextMonth() {
            currentMonth = addMonth(currentMonth, 1);
        }

        function previousMonth() {
            currentMonth = addMonth(currentMonth, -1);
        }

        function addMonth(date,month) {
            return  new Date(date.getFullYear(), date.getMonth() + month, 1, 0, 0, 0);
        }

        delegate: MonthComponent {
            property bool isCurrentItem: index === monthViewPath.currentIndex

            showEvents: true

            width: parent.width - units.gu(5)
            height: parent.height - units.gu(5)

            currentMonth: monthViewPath.addMonth(monthViewPath.startMonth,
                                                 monthViewPath.indexType(index));

            isYearView: false

            onDateSelected: {
                monthViewPage.dateSelected(date);
            }
        }
    }
}
