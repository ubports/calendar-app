import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

Page {
    id: monthViewPage

    property var currentMonth: DateExt.today();

    signal dateSelected(var date);

    PathViewBase{
        id: monthViewPath

        property var startMonth: addMonth(currentMonth,-1);

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
            var temp = new Date(date.getFullYear(),date.getMonth(),1,0,0,0);
            temp.setMonth(date.getMonth() + month);
            return temp;
        }

        delegate: MonthComponent{
            width: parent.width - units.gu(5)
            height: parent.height - units.gu(5)

            monthDate: getMonthDate();

            function getMonthDate() {
                //previous page
                if (index === monthViewPath.currentIndex) {
                    return monthViewPath.startMonth;
                }

                //next page
                var previousIndex = monthViewPath.currentIndex > 0 ? monthViewPath.currentIndex - 1 : 2
                if ( index === previousIndex ) {
                    return monthViewPath.addMonth(monthViewPath.startMonth,2);
                }

                //current page
                return monthViewPath.addMonth(monthViewPath.startMonth,1);
            }

            onDateSelected: {
                monthViewPage.dateSelected(date);
            }
        }
    }
}
