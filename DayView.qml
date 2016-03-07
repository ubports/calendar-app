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
    id: dayViewPage
    objectName: "dayViewPage"


    property bool displayLunarCalendar: false
    property var anchorDate: new Date()
    readonly property var currentDate: dayViewPath.currentItem.startDay

    signal dateSelected(var date);
    signal pressAndHoldAt(var date, bool allDay)

    function delayScrollToDate(date, scrollTime) {
        idleScroll.scrollToTime = scrollTime != undefined ? scrollTime : true
        idleScroll.scrollToDate = new Date(date)
        idleScroll.restart()
    }

    Keys.forwardTo: [dayViewPath]

    createEventAt: currentDate
    onAnchorDateChanged: {
        dayViewPath.scrollToBegginer()
    }

    onEventCreated: {
        var scrollDate = new Date(event.startDateTime)
        var needScroll = false
        if ((currentDate.getFullYear() !== scrollDate.getFullYear()) ||
            (currentDate.getMonth() !== scrollDate.getMonth()) ||
            (currentDate.getDate() !== scrollDate.getDate())) {
            anchorDate = new Date(scrollDate)
            needScroll = true
        } else if (!dayViewPath.currentItem.timeIsVisible(scrollDate)) {
            needScroll = true
        }

        if (needScroll) {
            delayScrollToDate(scrollDate, !event.allDay)
        }
    }

    Action {
        id: calendarTodayAction
        objectName:"todaybutton"
        iconName: "calendar-today"
        text: i18n.tr("Today")
        onTriggered: {
            anchorDate = new Date()
            delayScrollToDate(anchorDate)
        }
    }


    Timer {
        id: idleScroll

        property var scrollToDate: null
        property bool scrollToTime: true

        interval: 200
        repeat:false
        onTriggered: {
            if (scrollToDate && scrollToTime) {
                dayViewPath.currentItem.scrollToTime(scrollToDate)
            } else {
                dayViewPath.currentItem.scrollToBegin()
            }
            scrollToDate = null
            scrollToTime = true
        }
    }

    header: PageHeader {
        id: pageHeader

        flickable: null
        leadingActionBar.actions: tabs.tabsAction
        trailingActionBar.actions: [
            calendarTodayAction,
            commonHeaderActions.showCalendarAction,
            commonHeaderActions.reloadAction,
            commonHeaderActions.syncCalendarAction,
            commonHeaderActions.settingsAction
        ]

        title: {
            if(dayViewPage.displayLunarCalendar){
                var lunarDate = Lunar.calendar.solar2lunar(currentDate.getFullYear(),
                                                           currentDate.getMonth() + 1,
                                                           currentDate.getDate())
                return ("%1 %2").arg(lunarDate .IMonthCn).arg(lunarDate.gzYear)
            } else {
                // TRANSLATORS: this is a time formatting string,
                // see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details for valid expressions.
                // It's used in the header of the month and week views
                var monthName = currentDate.toLocaleString(Qt.locale(),i18n.tr("MMMM yyyy"))
                return monthName[0].toUpperCase() + monthName.substr(1, monthName.length - 1)
            }
        }
    }

    onBottomEdgeCommitStarted: {
        var eventAt = new Date()
        if (dayViewPath.currentItem) {
            eventAt.setFullYear(currentDate.getFullYear())
            eventAt.setMonth(currentDate.getMonth())
            eventAt.setDate(currentDate.getDate())
        }
        createEventAt = eventAt
    }

    PathViewBase{
        id: dayViewPath
        objectName: "dayViewPath"

        property var startDay: currentDate
        //This is used to scroll all view together when currentItem scrolls
        property real childContentY;

        anchors {
            fill: parent
            topMargin: header.height
        }

        delegate: TimeLineBaseComponent {
            id: timeLineView
            objectName: "DayComponent-"+index

            width: parent.width
            height: parent.height

            type: ViewType.ViewTypeDay
            isCurrentItem: PathView.isCurrentItem
            isActive: !dayViewPath.moving && !dayViewPath.flicking
            contentInteractive: PathView.isCurrentItem
            startDay: anchorDate.addDays(dayViewPath.loopCurrentIndex + dayViewPath.indexType(index))
            keyboardEventProvider: dayViewPath
            modelFilter: dayViewPage.model ? dayViewPage.model.filter : null

            onPressAndHoldAt: {
                dayViewPage.pressAndHoldAt(date, allDay)
            }

            Component.onCompleted: {
                if(dayViewPage.tabSelected){
                    idleScroll.restart()
                }
            }

            Connections{
                target: dayViewPage
                onTabSelectedChanged: {
                    if(tabSelected){
                        timeLineView.scrollToTime(new Date());
                    }
                }
            }

            //get contentY value from PathView, if its not current Item
            Binding{
                target: timeLineView
                property: "contentY"
                value: dayViewPath.childContentY;
                when: !timeLineView.isCurrentItem
            }

            //set PathView's contentY property, if its current item
            Binding{
                target: dayViewPath
                property: "childContentY"
                value: timeLineView.contentY
                when: timeLineView.isCurrentItem
            }
        }
    }
}
