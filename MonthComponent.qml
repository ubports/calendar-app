import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

Item{
    id: root
    objectName: "MonthComponent"

    property var currentMonth;

    property string dayLabelFontSize: "medium"
    property string dateLabelFontSize: "large"
    property string monthLabelFontSize: "x-large"
    property string yearLabelFontSize: "large"

    property alias dayLabelDelegate : dayLabelRepeater.delegate
    property alias dateLabelDelegate : dateLabelRepeater.delegate

    signal dateSelected(var date)

    height: ubuntuShape.height

    QtObject{
        id: intern

        property int curMonthDate: currentMonth.getDate()
        property int curMonth: currentMonth.getMonth()
        property int curMonthYear: currentMonth.getFullYear()

        property var today: DateExt.today()
        property int todayDate: today.getDate()
        property int todayMonth: today.getMonth()
        property int todayYear: today.getFullYear()


        //date from month will start, this date might be from previous month
        property var monthStart: currentMonth.weekStart( Qt.locale().firstDayOfWeek )
        property int monthStartDate: monthStart.getDate()
        property int monthStartMonth: monthStart.getMonth()
        property int monthStartYear: monthStart.getFullYear()

        property int daysInStartMonth: Date.daysInMonth(monthStartYear, monthStartMonth)
        property int daysInCurMonth:  Date.daysInMonth(curMonthYear,curMonth)

        //check if current month is start month
        property bool isCurMonthStartMonth: curMonthDate === monthStartDate
                        && curMonth === monthStartMonth
                        && curMonthYear === monthStartYear

        //check current month is same as today's month
        property bool isCurMonthTodayMonth: todayYear === curMonthYear && todayMonth == curMonth
        //offset from current month's first date to start date of current month
        property int offset: isCurMonthStartMonth ? -1 : (daysInStartMonth - monthStartDate)
    }

    UbuntuShape {
        id: ubuntuShape

        anchors.fill: parent
        radius: "medium"

        Column{
            id: column

            anchors.top: parent.top
            anchors.topMargin: units.gu(1.5)
            anchors.bottomMargin: units.gu(1)
            anchors.fill: parent
            spacing: units.gu(1.5)

            ViewHeader{
                id: monthHeader
                month: intern.curMonth
                year: intern.curMonthYear

                monthLabelFontSize: root.monthLabelFontSize
                yearLabelFontSize: root.yearLabelFontSize
            }

            Item {
                width: parent.width
                height: dayLabelRow.height + units.gu(1)

                DayHeaderBackground{}

                Row{
                    id: dayLabelRow
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater{
                        id: dayLabelRepeater
                        model:7
                        delegate: dafaultDayLabelComponent
                    }
                }
            }

            Grid{
                id: monthGrid
                objectName: "monthGrid"

                property int weekCount : 6

                width: parent.width
                height: parent.height - monthGrid.y

                property int dayWidth: width / 7;
                property int dayHeight: height / weekCount

                rows: weekCount
                columns: 7

                Repeater{
                    id: dateLabelRepeater
                    model: monthGrid.rows * monthGrid.columns
                    delegate: defaultDateLabelComponent
                }
            }
        }
    }

    Component{
        id: defaultDateLabelComponent

        Item{
            id: dateRootItem

            property int date: {
                //try to find date from index and month's first week's first date
                var temp = intern.daysInStartMonth - intern.offset + index
                //date exceeds days in startMonth,
                //this means previous month is over and we are now in current month
                //to get actual date we need to remove number of days in startMonth
                if( temp > intern.daysInStartMonth ) {
                    temp = temp - intern.daysInStartMonth
                    //date exceeds days in current month
                    // this means date is from next month
                    //to get actual date we need to remove number of days in current month
                    if( temp > intern.daysInCurMonth ) {
                        temp = temp - intern.daysInCurMonth
                    }
                }
                return temp;
            }

            property bool isCurrentMonth: {
                //remove offset from index
                //if index falls in 1 to no of days in current month
                //then date is inside current month
                var temp = index - intern.offset
                return (temp >= 1 && temp <= intern.daysInCurMonth)
            }

            property bool isToday: intern.todayDate == date && intern.isCurMonthTodayMonth

            width: parent.dayWidth
            height: parent.dayHeight

            Loader {
                width: parent.width < parent.height ? parent.width : parent.height
                height: width
                anchors.centerIn: parent
                sourceComponent: isToday && isCurrentMonth ? highLightComp : undefined
            }

            Label{
                id: dateLabel
                anchors.centerIn: parent
                width: parent.width
                text: date
                horizontalAlignment: Text.AlignHCenter
                fontSize: root.dateLabelFontSize
                color: {
                    if( isCurrentMonth ) {
                        if(isToday) {
                            "#2C001E"
                        } else {
                            "white"
                        }
                    } else {
                        "#AEA79F"
                    }
                }
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    root.dateSelected(new Date(intern.monthStartYear,
                                               intern.monthStartMonth,
                                               intern.monthStartDate+index,0,0,0,0));
                }
            }
        }
    }

    Component{
        id: dafaultDayLabelComponent

        Label{
            id: weekDay
            width: parent.width / 7
            property var day :Qt.locale().standaloneDayName(( Qt.locale().firstDayOfWeek + index), Locale.ShortFormat)
            text: day.toUpperCase();
            horizontalAlignment: Text.AlignHCenter
            fontSize: root.dayLabelFontSize
            color: "#AEA79F"
        }
    }

    Component{
        id: highLightComp
        UbuntuShape{
            color: "white"
        }
    }
}
