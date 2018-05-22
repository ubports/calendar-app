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
import "./3rd-party/lunar.js" as Lunar

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
    property bool displayLunarCalendar: false

    signal dateSelected(var date);
    signal pressAndHoldAt(var date, bool allDay)

    function delayScrollToDate(scrollDate, scrollTime) {
    var cur = new Date();
        idleScroll.scrollToTime = scrollTime != undefined ? scrollTime : true
    if(idleScroll.scrollToTime && (scrollDate.getHours() + scrollDate.getMinutes() + scrollDate.getSeconds()) === 0) {
            scrollDate.setHours(cur.getHours());
            scrollDate.setMinutes(cur.getMinutes());
        }
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

    onEventSaved: {
        var scrollDate = new Date(event.startDateTime)
        var currentWeekNumber = currentDate.weekNumber(Qt.locale().firstDayOfWeek)
        var eventWeekNumber = scrollDate.weekNumber(Qt.locale().firstDayOfWeek)
        var needScroll = false

        if ((scrollDate.getFullYear() !== currentDate.getFullYear()) ||
            (currentWeekNumber !== eventWeekNumber)) {
            anchorDate = new Date(scrollDate)
            needScroll = true
        } else {
            if (event.allDay) {
                needScroll = !weekViewPath.currentItem.item.dateIsVisible(scrollDate)
            } else {
                needScroll = !weekViewPath.currentItem.item.timeIsVisible(scrollDate)
            }
        }

        highlightedDay = scrollDate
        if (needScroll) {
            delayScrollToDate(scrollDate, !event.allDay)
        }
    }

    Timer {
        id: idleScroll

        property var scrollToDate: null
        property bool scrollToTime: true

        interval: 200
        repeat:false
        onTriggered: {
            if (weekViewPath.currentItem && weekViewPath.currentItem.item) {
                if (scrollToDate) {
                    if (scrollToTime)
                        weekViewPath.currentItem.item.scrollToDateAndTime(scrollToDate);
                    else
                        weekViewPath.currentItem.item.scrollToDate(scrollToDate);
                } else {
                    weekViewPath.currentItem.item.scrollToBegin()
                }
            }

            scrollToDate = null
            scrollToTime = true
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
            if(weekViewPage.displayLunarCalendar){
                var lunarDate = Lunar.calendar.solar2lunar(currentDate.getFullYear(),
                                                           currentDate.getMonth() + 1,
                                                           currentDate.getDate())
                return i18n.tr("%1 %2").arg(lunarDate .IMonthCn).arg(lunarDate.gzYear)
            } else {
                // TRANSLATORS: this is a time formatting string,
                // see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details for valid expressions.
                // It's used in the header of the month and week views
                var currentLastDayOfWeek = currentFirstDayOfWeek.addDays(7)
                if (currentLastDayOfWeek.getMonth() !== currentFirstDayOfWeek.getMonth()) {
                    var firstMonthName = currentFirstDayOfWeek.toLocaleString(Qt.locale(),i18n.tr("MMM"))
                    var lastMonthName = currentLastDayOfWeek.toLocaleString(Qt.locale(),i18n.tr("MMM"))
                    var firstLastMonthStr = firstMonthName[0].toUpperCase() + firstMonthName.substr(1, 2) +
                                            "/" +
                                            lastMonthName[0].toUpperCase() + lastMonthName.substr(1, 2)

                    if (DateExt.isYearPrecedesMonthFormat(Qt.locale().dateFormat(Locale.ShortFormat))) {
                        return currentLastDayOfWeek.getFullYear() + " " + firstLastMonthStr
                    } else {
                        return firstLastMonthStr + " " + currentLastDayOfWeek.getFullYear()
                    }
                } else {
                    var monthName = currentDate.toLocaleString(Qt.locale(),i18n.tr("MMMM yyyy"))
                    return monthName[0].toUpperCase() + monthName.substr(1, monthName.length - 1)
                }
            }
        }
        flickable: null
    }

    PinchAreaBase {
        id: weekViewPinch

        // PinchArea not working inside PathView but we don't want to overlap the PinchArea with the TimeLineTimeScale
        anchors.leftMargin: units.gu(6) // this magic number will be refactored soon
        targetX: weekViewPath.daysViewed
        isInvertedX: true
        minX: 1
        maxX: 7
        onUpdateTargetX: { weekViewPath.daysViewed = targetX; }
        onMaxHitX: { tabs.selectedTabIndex = monthTab.index; }

        targetY: weekViewPath.hourItemHeight
        onUpdateTargetY: { weekViewPath.hourItemHeight = targetY; }

        PathViewBase {
            id: weekViewPath
            objectName: "weekviewpathbase"

            anchors {
                fill: parent
                topMargin: header.height
                bottomMargin: weekViewPage.bottomEdgeHeight
                // this magic number will be refactored soon
                leftMargin: -units.gu(6)
            }

            onCurrentIndexChanged: {
                weekViewPage.highlightedDay = null
            }

            //This is used to scroll all view together when currentItem scrolls
            property real childScrollHour;
            property real daysViewed: 5.1
            property real hourItemHeight: units.gu(4)

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
                        objectName: "weekViewDelegate"

                        startDay: anchorFirstDayOfWeek.addDays((weekViewPath.loopCurrentIndex + weekViewPath.indexType(index)) * 7)
                        anchors.fill: parent
                        type: ViewType.ViewTypeWeek
                        isCurrentItem: parent.PathView.isCurrentItem
                        isActive: !weekViewPath.moving && !weekViewPath.flicking
                        keyboardEventProvider: weekViewPath
                        selectedDay: weekViewPage.selectedDay
                        modelFilter: weekViewPage.model ? weekViewPage.model.filter : null
                        daysViewed: weekViewPath.daysViewed
                        hourItemHeight: Math.max(weekViewPath.hourItemHeight, timeLineView.hourItemHeightMin)
                        headerHeight: weekViewPath.anchors.topMargin

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

                        // make sure that the model is updated after create a new event if it is marked as auto-update false
                        Connections {
                            target: weekViewPage
                            onActiveChanged: {
                                if (weekViewPage.active) {
                                    timeLineView.update()
                                }
                            }
                            onEventSaved: {
                                timeLineView.update()
                            }
                            onEventDeleted: {
                                timeLineView.update()
                            }
                        }

                        //get contentY value from PathView, if its not current Item
                        Binding{
                            target: timeLineView
                            property: "scrollHour"
                            value: weekViewPath.childScrollHour;
                            when: !timeLineView.isCurrentItem
                        }

                        //set PathView's contentY property, if its current item
                        Binding{
                            target: weekViewPath
                            property: "childScrollHour"
                            value: timeLineView.scrollHour
                            when: timeLineView.isCurrentItem
                        }

                        Binding {
                            target: weekViewPath
                            property: "interactive"
                            value: timeLineView.contentInteractive
                        }

                        Binding{
                            target: weekViewPinch
                            property: "minY"
                            value: timeLineView.hourItemHeightMin
                            when: timeLineView.isCurrentItem
                        }
                    }
                }

                Binding {
                    target: item
                    property: "autoUpdate"
                    value: (weekViewPage.tabSelected && weekViewPage.active && PathView.isCurrentItem)
                    when: (timelineLoader.status === Loader.Ready)
                }
            }
        }
    }
}
