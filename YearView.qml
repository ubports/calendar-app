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
import "./3rd-party/lunar.js" as Lunar

PageWithBottomEdge {
    id: yearViewPage
    objectName: "yearViewPage"

    property int anchorYear: new Date().getFullYear()
    property bool displayLunarCalendar: false
    readonly property int currentYear: yearPathView.currentItem.item ? yearPathView.currentItem.item.year : anchorYear

    signal monthSelected(var date);

    function refreshCurrentYear(year)
    {
        if (currentYear !== year) {
            anchorYear = year;
            yearPathView.scrollToBegginer()
        }
        var yearViewDelegate = yearPathView.currentItem;
        if (yearViewDelegate && yearViewDelegate.item) {
            yearViewDelegate.item.refresh();
        }
    }

    createEventAt: null
    Keys.forwardTo: [yearPathView]
    onAnchorYearChanged: {
        yearPathView.scrollToBegginer()
    }

    Action {
        id: calendarTodayAction
        objectName:"todaybutton"
        iconName: "calendar-today"
        text: i18n.tr("Today")
        onTriggered: {
            var todayYear = new Date().getFullYear()
            yearViewPage.refreshCurrentYear(todayYear)
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
            if (displayLunarCalendar) {
                var lunarDate = Lunar.calendar.solar2lunar(currentYear, 6, 0)
                return lunarDate.gzYear +" "+ lunarDate.Animal
            } else {
                return i18n.tr("Year %1").arg(currentYear)
            }
        }
        flickable: null
    }

    ActivityIndicator {
        property var startDate: new Date()

        visible: running
        running: (yearPathView.currentItem.status !== Loader.Ready)
        anchors.centerIn: parent
        z:2

        onRunningChanged: {
            if (!running) {
                var current  = new Date()
                console.debug("Elapsed:" + (current.getTime() - startDate.getTime()))
            }
        }
    }

    flickable: null

    PathViewBase {
        id: yearPathView
        objectName: "yearPathView"

        anchors {
            fill: parent
            topMargin: header.height
            bottomMargin: yearViewPage.bottomEdgeHeight
        }

        property bool loadNonVisibleDelegate: false

        Timer {
            running: true
            onTriggered: yearPathView.loadNonVisibleDelegate = true
            interval: 1
        }

        delegate: Loader {
            id: delegateLoader

            asynchronous: true
            width: PathView.view.width
            height: PathView.view.height
            active: yearPathView.loadNonVisibleDelegate || (index === yearPathView.currentIndex)

            sourceComponent: YearViewDelegate {
                visible: delegateLoader.status === Loader.Ready
                anchors.fill: parent
                scrollMonth: 0;
                isCurrentItem: (index === yearPathView.currentIndex)
                focus: isCurrentItem
                year: (yearViewPage.anchorYear + yearPathView.loopCurrentIndex + yearPathView.indexType(index))
                onMonthSelected: {
                    yearViewPage.monthSelected(date)
                }
            }
        }
    }
}
