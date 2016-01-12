/*
 * Copyright (C) 2013-2014 Canonical Ltd
 *
 * This file is part of Ubuntu Calendar App
 *
 * Ubuntu Calendar App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Calendar App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.3
import Ubuntu.Components 1.1
import QtOrganizer 5.0
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

Item{
    id: root
    objectName: "MonthComponent"

    property bool isCurrentItem;

    property bool showEvents: false

    property var currentMonth;
    property var isYearView;
    property var selectedDay;
    property bool displayWeekNumber:false;

    property string dayLabelFontSize: "medium"
    property string dateLabelFontSize: "large"
    property string monthLabelFontSize: "x-large"
    property string yearLabelFontSize: "large"

    property alias dayLabelDelegate : dayLabelRepeater.delegate
    property alias dateLabelDelegate : dateLabelRepeater.delegate

    signal monthSelected(var date);
    signal dateSelected(var date);
    signal dateHighlighted(var date);

    // optimize painter
    layer.enabled: true

    Timer {
        id: modelIsDirty

        interval: 500
        repeat: false
        onTriggered: if(showEvents) mainModel.update()
    }

    onCurrentMonthChanged: {
        modelIsDirty.start()
    }

    InvalidFilter {
        id: invalidFilter
    }

    EventListModel {
        id: mainModel

        autoUpdate: false
        startPeriod: intern.monthStart.midnight();
        endPeriod: intern.monthStart.addDays((/*monthGrid.rows * cols */ 42 )-1).endOfDay()
        filter: showEvents ? eventModel.filter : invalidFilter

        onModelChanged: {
            // do you really need binding it?? Is this really necessary
            // I do not see use for that
            intern.eventStatus = mainModel.containsItems(mainModel.startPeriod,
                                                         mainModel.endPeriod,
                                                         86400/*24*60*60*/);
        }
    }

    QtObject{
        id: intern

        property var eventStatus;

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

        property int dateFontSize: FontUtils.sizeToPixels(root.dateLabelFontSize)
        property int dayFontSize: FontUtils.sizeToPixels(root.dayLabelFontSize)

        property int selectedIndex: -1

        function findSelectedDayIndex(){
            if(!selectedDay) {
                return -1;
            }

            if( todayMonth === selectedDay.getMonth() && selectedDay.getFullYear() === todayYear){
                return selectedDay.getDate() +
                       (Date.daysInMonth(monthStartYear, monthStartMonth) - monthStartDate);
            } else {
                return -1;
            }
        }
    }

    onSelectedDayChanged: {
        if( isCurrentItem ) {
            intern.selectedIndex = intern.findSelectedDayIndex();
        }
    }

    onCurrentMonthChanged: {
        intern.selectedIndex = -1;
    }

    Column{
        id: column

        anchors {
            left: weekNumLoader.right;
            right: parent.right;
            top: parent.top;
            bottom: parent.bottom;
            topMargin: units.gu(1.5)
            bottomMargin: units.gu(1)
        }

        spacing: units.gu(1.5)

        Loader {
            width: parent.width
            height: isYearView ? FontUtils.sizeToPixels(root.monthLabelFontSize) : 0;
            sourceComponent: isYearView ? headerComp : undefined
            Component{
                id: headerComp
                ViewHeader{
                    id: monthHeader
                    anchors.fill: parent
                    month: intern.curMonth
                    year: intern.curMonthYear

                    monthLabelFontSize: root.monthLabelFontSize
                    yearLabelFontSize: root.yearLabelFontSize
                }
            }
        }

        Item {
            width: parent.width
            height: dayLabelRow.height + units.gu(1)

            Row{
                id: dayLabelRow
                objectName: "dayLabelRow" + index

                property int dayWidth: width / 7;

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

            width: parent.width
            height: parent.height - monthGrid.y

            property int dayWidth: width / 7 /*cols*/;
            property int dayHeight: height / 6/*rows*/;

            rows: 6
            columns: 7

            Repeater{
                id: dateLabelRepeater
                model: 42 //monthGrid.rows * monthGrid.columns
                delegate: defaultDateLabelComponent
            }
        }
    }

    Loader {
        id: weekNumLoader;
        anchors.left: parent.left;
        width: displayWeekNumber ? parent.width / 7:0;
        height: parent.height;
        visible: displayWeekNumber;
        sourceComponent: displayWeekNumber ? weekNumComp : undefined;
    }

    Component {
        id: weekNumComp

        Column {
            id: weekNumColumn;

            anchors {
                fill: parent
                topMargin: units.gu(1.0)
                bottomMargin: units.gu(1.25)
            }

            Item {
                id: datePlaceHolder;
                objectName:"datePlaceHolder"

                width: parent.width;
                height: isYearView ? units.gu(4.5): units.gu(1.25)
            }

            Item {
                id: weekNumLabelItem;
                objectName: "weekNumLabelItem"

                width: parent.width;
                height: weekNumLabel.height + units.gu(2.0)

                Label{
                    id: weekNumLabel;
                    objectName: "weekNumLabel";
                    width: parent.width;
                    text: i18n.tr("Wk");
                    horizontalAlignment: Text.AlignHCenter;
                    verticalAlignment: Text.AlignVCenter;
                    font.pixelSize: intern.dayFontSize;
                    font.bold: true
                    color: "black"
                }
            }

            Repeater {
                id: weekNumrepeater;
                model: 6;

                Label{
                    id: weekNum
                    objectName: "weekNum" + index
                    width: parent.width;
                    height: (weekNumColumn.height - weekNumLabelItem.height - datePlaceHolder.height) / 6;
                    text: intern.monthStart.addDays(index * 7).weekNumber(Qt.locale().firstDayOfWeek)
                    horizontalAlignment: Text.AlignHCenter;
                    verticalAlignment: Text.AlignVCenter;
                    font.pixelSize: intern.dayFontSize + 1;
                    font.bold: true
                    color: "black"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var selectedDate = new Date(intern.monthStart.addDays(index * 7))
                            if( isYearView ) {
                                root.monthSelected(selectedDate);
                            } else {
                                root.dateSelected(selectedDate);
                            }
                        }
                    }
                }
            }
        }
    }

    Component{
        id: defaultDateLabelComponent
        MonthComponentDateDelegate{
            date: {
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

            isCurrentMonth: {
                //remove offset from index
                //if index falls in 1 to no of days in current month
                //then date is inside current month
                var temp = index - intern.offset
                return (temp >= 1 && temp <= intern.daysInCurMonth)
            }

            isToday: intern.todayDate == date && intern.isCurMonthTodayMonth

            isSelected: showEvents && intern.selectedIndex == index

            width: parent.dayWidth
            height: parent.dayHeight
            fontSize: intern.dateFontSize
            showEvent: showEvents
                        && intern.eventStatus !== undefined
                        && intern.eventStatus[index] !== undefined
                        && intern.eventStatus[index]
        }
    }

    Component{
        id: dafaultDayLabelComponent

        Label{
            id: weekDay
            objectName: "weekDay" + index
            width: parent.dayWidth
            property var day : Qt.locale(Qt.locale().name).standaloneDayName(( Qt.locale().firstDayOfWeek + index), Locale.ShortFormat);
            text: isYearView ? Qt.locale(Qt.locale().name).standaloneDayName(( Qt.locale().firstDayOfWeek + index), Locale.NarrowFormat) : day
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: intern.dayFontSize
            font.bold: true
            color: "black"
        }
    }
}
