import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

PathViewBase{
    id: monthViewPath
    objectName: "MonthView"

    property var currentMonth: DateExt.today();
    property var startMonth: addMonth(currentMonth,-1);

    signal dateSelected(var date);

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
            switch( monthViewPath.indexType(index)) {
            case 0:
                return monthViewPath.startMonth;
            case -1:
                return monthViewPath.addMonth(monthViewPath.startMonth,2);
            case 1:
                return monthViewPath.addMonth(monthViewPath.startMonth,1);
            }
        }

        onDateSelected: {
            monthViewPath.dateSelected(date);
        }
    }
}
