import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "colorUtils.js" as Color

PathViewBase{
    id: weekRibbonRoot

    objectName: "weekRibbonRoot"

    property var startDay: intern.now

    property var weekStart: startDay.addDays(-7)
    property int selectedIndex: 0

    onStartDayChanged: {
        weekStart = startDay.addDays(-7)
    }

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
        weekRibbonRoot.weekStart = weekStartDay.addDays(7);
        weekRibbonRoot.selectedIndex = 0

        daySelected( weekStart.addDays(7) );
    }

    function previousWeek(){
        var weekStartDay = weekStart.weekStart(intern.weekstartDay);
        weekRibbonRoot.weekStart = weekStartDay.addDays(-7);
        weekRibbonRoot.selectedIndex = 0

        daySelected( weekStart.addDays(7) );
    }

    delegate: Row{
        id: dayLabelRow
        width: parent.width

//        Connections{
//            target: weekRibbonRoot
//            onWeekStartChanged: {
//                dayLabelRow.weekStart = getWeekStart();
//                print("WeekStart:" + dayLabelRow.weekStart);
//            }
//        }

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
                width: dummy.width + units.gu(1)
                Label{
                    //FIXME: how to get localized day initial ?
                    text: Qt.locale().standaloneDayName(( intern.weekstartDay + index), Locale.ShortFormat)
                    horizontalAlignment: Text.AlignHCenter
                    width: column.width
                    fontSize: "medium"
                    //anchors.horizontalCenter: parent.horizontalCenter
                }
                Label{
                    text: weekDay.day.getDate()
                    horizontalAlignment: Text.AlignHCenter
                    width: column.width
                    fontSize: dummy.fontSize
                    //anchors.horizontalCenter: parent.horizontalCenter
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

    Label{
        id: dummy
        text: "SUN"
        visible: false
        fontSize: "large"
    }
}
