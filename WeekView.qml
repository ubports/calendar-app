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
import "ViewType.js" as ViewType

PageWithBottomEdge {
    id: weekViewPage
    objectName: "weekViewPage"

    property var anchorDate: new Date();
    readonly property var anchorFirstDayOfWeek: anchorDate.weekStart(Qt.locale().firstDayOfWeek)
    readonly property var currentDate: weekViewPath.currentItem.item.startDay
    readonly property var currentFirstDayOfWeek: currentDate.weekStart(Qt.locale().firstDayOfWeek)

    property bool isCurrentPage: false
    property var selectedDay;
    property var highlightedDay;

    signal dateSelected(var date);
    signal pressAndHoldAt(var date, bool allDay)

    function delayScrollToDate(scrollDate) {
        idleScroll.scrollToDate = new Date(scrollDate)
        idleScroll.restart()
    }

    Keys.forwardTo: [weekViewPath]
    createEventAt: null

    Action {
        id: calendarTodayAction
        objectName:"todaybutton"
        iconName: "calendar-today"
        text: i18n.tr("Today")
        onTriggered: {
            var today = new Date()
            delayScrollToDate(today)
            anchorDate = today
        }
    }

    onAnchorDateChanged: {
        weekViewPath.scrollToBegginer()
    }

    onEventCreated: {
        var eventDate = new Date(event.startDateTime)
        highlightedDay = eventDate
        var currentWeekNumber = currentDate.weekNumber(Qt.locale().firstDayOfWeek)
        var eventWeekNumber = eventDate.weekNumber(Qt.locale().firstDayOfWeek)
        var needScroll = false
        if ((eventDate.getFullYear() !== currentDate.getFullYear()) ||
            (currentWeekNumber !== eventWeekNumber)) {
            anchorDate = new Date(eventDate)
            needScroll = true
        } else if (!weekViewPath.currentItem.item.dateTimeIsVisible(eventDate)) {
            needScroll = true
        }

        if (needScroll) {
            delayScrollToDate(eventDate)
        }
    }

    Timer {
        id: idleScroll

        property var scrollToDate: null

        interval: 200
        repeat:false
        onTriggered: {
            if (scrollToDate) {
                weekViewPath.currentItem.item.scrollToDateAndTime(scrollToDate);
                scrollToDate = null
            } else {
                weekViewPath.currentItem.item.scrollToBegin()
            }
        }
    }

    header: PageHeader {
        id: pageHeader

        leadingActionBar.actions: tabs.tabsAction
        trailingActionBar.actions: [
            calendarTodayAction,
            commonHeaderActions.showCalendarAction,
            commonHeaderActions.reloadAction,
            commonHeaderActions.syncCalendarAction,
            commonHeaderActions.settingsAction
        ]

        title: {
            // TRANSLATORS: this is a time formatting string,
            // see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details for valid expressions.
            // It's used in the header of the month and week views
            var currentLastDayOfWeek = currentFirstDayOfWeek.addDays(7)
            if (currentLastDayOfWeek.getMonth() !== currentFirstDayOfWeek.getMonth()) {
                var firstMonthName = currentFirstDayOfWeek.toLocaleString(Qt.locale(),i18n.tr("MMM"))
                var lastMonthName = currentLastDayOfWeek.toLocaleString(Qt.locale(),i18n.tr("MMM"))
                return (firstMonthName[0].toUpperCase() + firstMonthName.substr(1, 2) + "/" +
                        lastMonthName[0].toUpperCase() + lastMonthName.substr(1, 2) + " " +
                        currentLastDayOfWeek.getFullYear())
            } else {
                var monthName = currentDate.toLocaleString(Qt.locale(),i18n.tr("MMMM yyyy"))
                return monthName[0].toUpperCase() + monthName.substr(1, monthName.length - 1)
            }
        }
        flickable: null
    }

    PathViewBase{
        id: weekViewPath
        objectName: "weekviewpathbase"

        anchors {
            fill: parent
            topMargin: header.height
        }

        onCurrentIndexChanged: {
            weekViewPage.highlightedDay = null
        }

        //This is used to scroll all view together when currentItem scrolls
        property var childContentY;

        delegate: Loader {
            id: timelineLoader
            width: parent.width
            height: parent.height
            asynchronous: !weekViewPath.isCurrentItem
            sourceComponent: delegateComponent

            Component{
                id: delegateComponent

                TimeLineBaseComponent {
                    id: timeLineView

                    startDay: anchorFirstDayOfWeek.addDays((weekViewPath.loopCurrentIndex + weekViewPath.indexType(index)) * 7)
                    anchors.fill: parent
                    type: ViewType.ViewTypeWeek
                    isCurrentItem: parent.PathView.isCurrentItem
                    isActive: !weekViewPath.moving && !weekViewPath.flicking
                    keyboardEventProvider: weekViewPath
                    selectedDay: weekViewPage.selectedDay
                    modelFilter: weekViewPage.model ? weekViewPage.model.filter : null

                    onDateSelected: {
                        weekViewPage.dateSelected(date);
                    }

                    onDateHighlighted:{
                        weekViewPage.highlightedDay = date
                    }

                    Component.onCompleted: {
                        var iType = weekViewPath.indexType(index)
                        if (iType === 0) {
                            idleScroll.restart()
                        } else if (iType < 0) {
                            scrollToEnd()
                        }
                    }

                    onPressAndHoldAt: {
                        weekViewPage.pressAndHoldAt(date, allDay)
                    }

                    Connections{
                        target: calendarTodayAction
                        onTriggered:{
                            if (isActive)
                                timeLineView.scrollToDate(new Date());
                            }
                    }

                    Connections {
                        target: weekViewPath
                        onLoopCurrentIndexChanged: {
                            var iType = weekViewPath.indexType(index)
                            if (iType < 0) {
                                scrollToEnd()
                            } else if (iType > 0) {
                                scrollToBegin()
                            }
                        }
                    }

                    //get contentY value from PathView, if its not current Item
                    Binding{
                        target: timeLineView
                        property: "contentY"
                        value: weekViewPath.childContentY;
                        when: !parent.PathView.isCurrentItem
                    }

                    //set PathView's contentY property, if its current item
                    Binding{
                        target: weekViewPath
                        property: "childContentY"
                        value: contentY
                        when: parent.PathView.isCurrentItem
                    }
                    Binding {
                        target: weekViewPath
                        property: "interactive"
                        value: timeLineView.contentInteractive
                    }
                }
            }
        }
    }
}
