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
import QtQuick 2.4
import Ubuntu.Components 1.3

import "dateExt.js" as DateExt
import "colorUtils.js" as Color
import "./3rd-party/lunar.js" as Lunar

Item{
    id: root
    objectName: "MonthComponent"

    property bool isCurrentItem;
    property int currentYear;
    property int currentMonth;

    property var isYearView;
    property bool displayWeekNumber:false
    property bool displayLunarCalendar: false

    property alias dayLabelDelegate : dayLabelRepeater.delegate
    property alias dateLabelDelegate : dateLabelRepeater.delegate
    readonly property alias monthStartDate: intern.monthStart

    property string dayLabelFontSize: "medium"
    property string dateLabelFontSize: "large"
    property string leftLabelFontSize: "large"
    property string rightLabelFontSize: "large"

    signal monthSelected(var date);
    signal dateSelected(var date);

    function updateEvents(events) {
        intern.eventsByDate = events
    }

    QtObject{
        id: intern

        property var eventsByDate: new Array(100)

        property var today: DateExt.today()
        property int todayDate: today.getDate()
        property int todayMonth: today.getMonth()
        property int todayYear: today.getFullYear()

        //date from month will start, this date might be from previous month
        property var currentDate: new Date(root.currentYear, root.currentMonth, 1, 0, 0, 0, 0)
        property var monthStart: currentDate.weekStart( Qt.locale().firstDayOfWeek )
        property int monthStartDate: monthStart.getDate()
        property int monthStartMonth: monthStart.getMonth()
        property int monthStartYear: monthStart.getFullYear()
        readonly property int daysInStartMonth: Date.daysInMonth(monthStartYear, monthStartMonth)
        readonly property int daysInCurrentMonth: Date.daysInMonth(root.currentYear, root.currentMonth)

        //check if current month is start month
        property bool isCurMonthStartMonth: root.currentMonth === monthStartMonth &&
                                            root.currentYear === monthStartYear

        //check current month is same as today's month
        property bool isCurMonthTodayMonth: todayYear === root.currentYear &&
                                            todayMonth == root.currentMonth
        //offset from current month's first date to start date of current month
        property int offset: isCurMonthStartMonth ? -1 : (daysInStartMonth - monthStartDate)

        property int dateFontSize: FontUtils.sizeToPixels(root.dateLabelFontSize)
        property int dayFontSize: FontUtils.sizeToPixels(root.dayLabelFontSize)

        property int todayIndex: root.isCurrentItem &&
                                 isCurMonthTodayMonth ?
                                     intern.indexByDate(intern.today) : -1

        function indexByDate(date){
            if (!date) {
                return -1;
            }

            if (date.getFullYear() < root.currentYear ||
                (date.getFullYear() === root.currentYear && date.getMonth() < root.currentMonth)) {
                return offset - (Date.daysInMonth(date.getFullYear(), date.getMonth()) - date.getDate());

            } else if (date.getFullYear() === root.currentYear && date.getMonth() === root.currentMonth) {
               return offset + date.getDate();

            } else if (date.getFullYear() > root.currentYear ||
                       (date.getFullYear() === root.currentYear && date.getMonth() > root.currentMonth)) {
                return offset + Date.daysInMonth(root.currentYear, root.currentMonth) + date.getDate();
            }

            return -1;
        }
    }

    UbuntuShape{
        id: todayShape

        visible: (monthGrid.todayItem != null)
        color: UbuntuColors.orange
        width: parent ? Math.min(parent.height, parent.width) / 1.3 : 0
        height: width
        parent: monthGrid.todayItem
        anchors.centerIn: parent
        z: -1
        Rectangle {
            anchors.fill: parent
            anchors.margins: units.gu(0.5)
            color: UbuntuColors.orange
            radius: 5
        }
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
            height: isYearView ? FontUtils.sizeToPixels(root.leftLabelFontSize) : 0;
            sourceComponent: isYearView ? headerComp : undefined
            Component{
                id: headerComp
                ViewHeader{
                    id: monthHeader
                    anchors.fill: parent
                    month: root.currentMonth
                    year: root.currentYear
                    daysInMonth: intern.daysInStartMonth

                    leftLabelFontSize: root.leftLabelFontSize
                    rightLabelFontSize: root.rightLabelFontSize
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

                anchors{
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                Repeater{
                    id: dayLabelRepeater
                    model:7
                    delegate: dafaultDayLabelComponent
                }
            }
        }

        Grid {
            id: monthGrid
            objectName: "monthGrid"

            property int dayWidth: width / 7 /*cols*/;
            property int dayHeight: height / 6/*rows*/;
            readonly property var todayItem: (intern.todayIndex != -1) &&
                                             (monthGrid.children.length > intern.todayIndex) ?
                                               dateLabelRepeater.itemAt(intern.todayIndex) : null
            anchors {
                left: parent.left
                right: parent.right
            }
            height: parent.height - monthGrid.y
            columns: 7

            Repeater{
                id: dateLabelRepeater
                model: 42
                delegate: isYearView ? monthWithoutEventsDelegate : monthWithEventsDelegate
            }
        }
    }

    MouseArea {
        id: mouseArea

        function getItemAt(x, y)
        {
            var clickPosition = mouseArea.mapToItem(monthGrid, x, y)
            return monthGrid.childAt(clickPosition.x, clickPosition.y)
        }

        function getIndexOfChild(object, child) {
            for (var i = 0; i <= object.children.length; i++) {
                if (object.children[i] === child) {
                    return i;
                }
            }
            return -1;
        }

        anchors {
            fill: column
            topMargin: monthGrid.y
        }

        onPressAndHold: {
            var dayItem = getItemAt(mouse.x, mouse.y)
            var index = getIndexOfChild(monthGrid, dayItem);
            var selectedDate = intern.monthStart.addDays(index);
            pageStack.push(Qt.resolvedUrl("NewEvent.qml"), {"date":selectedDate, "model":eventModel});
        }
        onClicked: {
            var dayItem = getItemAt(mouse.x, mouse.y)
            var index = getIndexOfChild(monthGrid, dayItem);
            var selectedDate = intern.monthStart.addDays(index);
            if (root.isYearView) {
                //If yearView is clicked then open selected MonthView
                root.monthSelected(selectedDate);
            } else {
                root.dateSelected(selectedDate);
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
                    // TRANSLATORS: This is shown in the month view as "Wk" as a title
                    // to indicate the week numbers. It should be a max of up to 3 characters.
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
        id: dafaultDayLabelComponent

        Text {
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
    Component {
        id: monthWithEventsDelegate

        MonthComponentWithEventsDateDelegate {
            property var delegateDate: intern.monthStart.addDays(index)

            date: delegateDate.getDate()
            isCurrentMonth: delegateDate.getMonth() === root.currentMonth
            showEvent: intern.eventsByDate[delegateDate.toDateString()] !== undefined && intern.eventsByDate[delegateDate.toDateString()][0] !== undefined
            lunarData: {
                if (!root.displayLunarCalendar)
                    return null

                var lunar = Lunar.calendar.solar2lunar(intern.monthStartYear,
                                                       intern.monthStartMonth + 1,
                                                       intern.monthStartDate + index)
                if (lunar.isTerm) {
                    return {"lunarText": lunar.Term, "isTerm" :lunar.isTerm};
                } else {
                    return {"lunarText": lunar.IDayCn, "isTerm" :lunar.isTerm};
                }
            }
            isToday: intern.todayDate == date && intern.isCurMonthTodayMonth
            width: monthGrid.dayWidth
            height: monthGrid.dayHeight
            dotColors: {
                if (showEvent === false) {
                    return ["black"];
                }
                else {
                    var colors = [];
                    var events = intern.eventsByDate[delegateDate.toDateString()];
                    for (var index = 0; index < events.length; index++) {
                        var event = events[index];
                        var calendar = mainModel.collection(event.collectionId);
                        colors[calendar.color] = true;
                    }
                return Object.keys(colors);
                }
            }
        }
    }

    Component {
        id: monthWithoutEventsDelegate

        Text {
            width: monthGrid.dayWidth
            height: monthGrid.dayHeight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: {
                var day = intern.monthStartDate + index;
                if ( intern.monthStartDate >= 7 ) {
                    if ( day <= intern.daysInStartMonth ) {
                        text = day;
                        return "#AEA79F";
                    } else {
                        day = day - intern.daysInStartMonth;
                    }
                }

                if ( day <= intern.daysInCurrentMonth ) {
                    text = day;
                    if ( intern.todayDate == day && intern.isCurMonthTodayMonth ) {
                        return "white";
                    } else {
                        return "#5D5D5D";
                    }
                } else {
                    day = day - intern.daysInCurrentMonth;
                    text = day;
                    return "#AEA79F";
                }
            }
        }
    }
}
