import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "colorUtils.js" as Color

PathViewBase{
    id: weekRibbonRoot

    property int weekWidth:0;
    property var visibleWeek: intern.now

    signal daySelected(var day);
    signal weekChanged(var visibleWeek);

    QtObject{
        id: intern
        property var now: new Date()
        property int weekstartDay: Qt.locale().firstDayOfWeek
        property var weekStart: visibleWeek.addDays(-7)
        property var selectedDay: now;
    }

    onNextItemHighlighted: {
        nextWeek();
    }

    onPreviousItemHighlighted: {
        previousWeek();
    }

    onVisibleWeekChanged: {
        setSelectedDay();
    }

    function nextWeek() {
        var weekStartDay= visibleWeek.weekStart(intern.weekstartDay);
        visibleWeek = weekStartDay.addDays(7);
        setSelectedDay();

        weekChanged( visibleWeek );
    }

    function previousWeek(){
        var weekStartDay = visibleWeek.weekStart(intern.weekstartDay);
        visibleWeek = weekStartDay.addDays(-7);
        setSelectedDay();

        weekChanged( visibleWeek );
    }

    function setSelectedDay() {
        if( intern.now.weekStart( intern.weekstartDay).isSameDay(visibleWeek) ) {
            intern.selectedDay =  intern.now
        } else {
            intern.selectedDay = visibleWeek
        }
    }

    delegate: Row{
        id: dayLabelRow
        width: parent.width

        function getWeekStart() {
            if (index === weekRibbonRoot.currentIndex) {
                return intern.weekStart;
            }
            var previousIndex = weekRibbonRoot.currentIndex > 0 ? weekRibbonRoot.currentIndex - 1 : 2

            if ( index === previousIndex ) {
                var weekStartDay= intern.weekStart.weekStart( Qt.locale().firstDayOfWeek);
                return weekStartDay.addDays(-7);
            }

            var weekStartDay = intern.weekStart.weekStart( Qt.locale().firstDayOfWeek);
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

            color: intern.selectedDay.isSameDay(day) ? Color.ubuntuOrange : "white"

            property var weekStartDay: parent.weekStart.weekStart( Qt.locale().firstDayOfWeek);
            property var day : weekStartDay.addDays(index)

            Column {
                id: column
                width: weekWidth
                Label{
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
                    intern.selectedDay = day
                    weekRibbonRoot.daySelected(day);
                }
            }
        }
    }
}
