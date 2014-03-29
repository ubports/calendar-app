import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

Page {
    id: monthViewPage
    objectName: "MonthView"

    property var currentMonth: DateExt.today();

    signal dateSelected(var date);

    Keys.forwardTo: [monthViewPath]

    PathViewBase{
        id: monthViewPath

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
            currentMonth = addMonth(currentMonth,1);
        }

        function previousMonth(){
            currentMonth = addMonth(currentMonth,-1);
        }

        function addMonth(date,month){
            return  new Date(date.getFullYear(),date.getMonth()+month,1,0,0,0);
        }

        delegate: MonthComponent{
            property bool isCurrentItem: index === monthViewPath.currentIndex

            width: parent.width - units.gu(5)
            height: parent.height - units.gu(5)

            currentMonth: getMonthDate();

            function getMonthDate() {
                switch( monthViewPath.indexType(index)) {
                case 0:
                    return monthViewPath.addMonth(monthViewPath.startMonth,0);
                case -1:
                    return monthViewPath.addMonth(monthViewPath.startMonth,-1);
                case 1:
                    return monthViewPath.addMonth(monthViewPath.startMonth,1);
                }
            }

            onDateSelected: {
                monthViewPage.dateSelected(date);
            }
        }
    }
}
