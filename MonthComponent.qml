import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

Item{
    id: root
    objectName: "MonthComponent"

    property var monthDate;

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

        property var monthDay: monthDate.getDate()
        property int monthMonth: monthDate.getMonth()
        property var monthYear: monthDate.getFullYear()

        property var today: DateExt.today()
        property int todayDate: today.getDate()
        property int todayMonth: today.getMonth()
        property var todayYear: today.getFullYear()


        property var monthStart: monthDate.weekStart( Qt.locale().firstDayOfWeek )
        property int monthStartDate: monthStart.getDate()
        property int monthStartMonth: monthStart.getMonth()
        property var monthStartYear: monthStart.getFullYear()

        property int daysInPrevMonth: Date.daysInMonth(monthStartYear, monthStartMonth)
        property int daysInCurMonth:  Date.daysInMonth(monthYear,monthMonth)

        property bool isMonthStartMonth: monthDay === monthStartDate
                        && monthMonth === monthStartMonth
                        && monthYear === monthStartYear

        property bool isTodayMonthYear: todayYear === monthYear && todayMonth == monthMonth
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
                date: root.monthDate
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
                var temp = intern.monthStartDate + index

                if( intern.isMonthStartMonth ) {
                   if( temp > intern.daysInCurMonth) {
                       temp = temp - intern.daysInCurMonth;
                   }else {
                       isCurrentMonth = true;
                   }
                   return temp;
                }

                if( temp > intern.daysInPrevMonth) {
                   temp = temp - intern.daysInPrevMonth;
                   if(temp > intern.daysInCurMonth) {
                       temp = temp - intern.daysInCurMonth;
                   } else {
                       isCurrentMonth = true
                   }
                }
                return temp;
            }

            property bool isCurrentMonth: false
            property bool isToday: intern.todayDate == date && intern.isTodayMonthYear

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
                    root.dateSelected(date);
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
