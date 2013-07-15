import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "colorUtils.js" as Color

PathViewBase{
    id: weekRibbonRoot

    property int weekWidth:0;
    property var startDay: intern.now
    property var weekStart: startDay.addDays(-7)
    property int selectedIndex: 0

    signal daySelected(var day);

    QtObject{
        id: intern
        property var now: new Date()
        property int weekstartDay: Qt.locale().firstDayOfWeek
    }

    onNextItemHighlighted: {
        nextWeek();
    }

    onPreviousItemHighlighted: {
        previousWeek();
    }

    function nextWeek() {
        var weekStartDay= weekStart.weekStart( intern.weekstartDay);
        startDay = weekStartDay.addDays(14);
        selectedIndex = 0

        daySelected( startDay );
    }

    function previousWeek(){
        var weekStartDay = weekStart.weekStart(intern.weekstartDay);
        startDay = weekStartDay;
        selectedIndex = 0

        daySelected( startDay );
    }

    delegate: Row{
        id: dayLabelRow
        width: parent.width

        function getWeekStart() {
            if (index === weekRibbonRoot.currentIndex) {
                return weekRibbonRoot.weekStart;
            }
            var previousIndex = weekRibbonRoot.currentIndex > 0 ? weekRibbonRoot.currentIndex - 1 : 2

            if ( index === previousIndex ) {
                var weekStartDay= weekRibbonRoot.weekStart.weekStart( Qt.locale().firstDayOfWeek);
                return weekStartDay.addDays(-7);
            }

            var weekStartDay = weekRibbonRoot.weekStart.weekStart( Qt.locale().firstDayOfWeek);
            return weekStartDay.addDays(7);
        }

        property var weekStart: getWeekStart();

        Repeater{
            id: dayLabelRepeater
            model:7
            delegate: dafaultDayLabelComponent
        }
    }

    Component{
        id: dafaultDayLabelComponent

        Rectangle{
            id: weekDay

            width: column.width
            height: column.height

            color: weekRibbonRoot.selectedIndex == index ? Color.ubuntuOrange : "white"

            property var myIndex: index

            property var weekStartDay: parent.weekStart.weekStart( Qt.locale().firstDayOfWeek);
            property var day : weekStartDay.addDays(index)
            objectName: "weekDay"+index

            Column {
                id: column
                width: weekWidth
                Label{
                    //FIXME: how to get localized day initial ?
                    text: Qt.locale().standaloneDayName(( intern.weekstartDay + index), Locale.ShortFormat)
                    horizontalAlignment: Text.AlignHCenter
                    width: column.width
                    fontSize: "medium"
                }
                Label{
                    text: weekDay.day.getDate()
                    horizontalAlignment: Text.AlignHCenter
                    width: column.width
                    fontSize: "large"
                }
            }

            MouseArea{
                anchors.fill: parent

                onClicked: {
                    weekRibbonRoot.selectedIndex= index
                    weekRibbonRoot.daySelected(day);
                    print("Day selected: "+ day);
                }
            }
        }
    }
}
