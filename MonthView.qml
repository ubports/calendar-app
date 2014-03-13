import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

Page{
    id: root

    property var currentMonth: DateExt.today();
    signal dateSelected(var date);

    anchors.fill: parent

    PathViewBase{
        id: monthViewPath
        objectName: "MonthView"
        anchors.fill: parent

        onNextItemHighlighted: {
            nextMonth();
        }

        onPreviousItemHighlighted: {
            previousMonth();
        }

        function nextMonth() {
            currentMonth = addMonth(root.currentMonth,1);
        }

        function previousMonth(){
            currentMonth = addMonth(root.currentMonth,-1);
        }

        function addMonth(date,month){
            var temp = new Date(date.getFullYear(),date.getMonth(),1,0,0,0);
            temp.setMonth(date.getMonth() + month);
            return temp;
        }

        delegate: MonthComponent{
            property bool isCurrentItem: index === monthViewPath.currentIndex

            width: parent.width - units.gu(5)
            height: parent.height - units.gu(5)

            monthDate: getMonthDate();

            function getMonthDate() {
                switch( monthViewPath.indexType(index)) {
                case 0:
                    return monthViewPath.addMonth(root.currentMonth,0);
                case -1:
                    return monthViewPath.addMonth(root.currentMonth,-1);
                case 1:
                    return monthViewPath.addMonth(root.currentMonth,1);
                }
            }

            onDateSelected: {
                root.dateSelected(date);
            }
        }
    }
}
