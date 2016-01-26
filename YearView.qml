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
Page {
    id: yearViewPage
    objectName: "yearViewPage"

    property int anchorYear: new Date().getFullYear()
    readonly property int currentYear: yearPathView.currentItem.item ? yearPathView.currentItem.item.year : anchorYear

    signal monthSelected(var date);

    function refreshCurrentYear(year)
    {
        anchorYear = year;
        var yearViewDelegate = yearPathView.currentItem;
        if (yearViewDelegate && yearViewDelegate.item) {
            yearViewDelegate.item.refresh();
        }
    }

    Action {
        id: calendarTodayAction
        objectName:"todaybutton"
        iconName: "calendar-today"
        text: i18n.tr("Today")
        onTriggered: {
            yearPathView.scrollToBegginer()
            anchorYear = new Date().getFullYear()
        }
    }

    Keys.forwardTo: [yearPathView]
    title: i18n.tr("Year %1").arg(currentYear)

    head {
        actions: [
            calendarTodayAction,
            commonHeaderActions.newEventAction,
            commonHeaderActions.showCalendarAction,
            commonHeaderActions.reloadAction,
            commonHeaderActions.syncCalendarAction,
            commonHeaderActions.settingsAction
        ]
    }

    flickable: null

    PathViewBase {
        id: yearPathView
        objectName: "yearPathView"

        anchors.fill: parent
        snapMode: PathView.NoSnap

        delegate: Loader {
            asynchronous: index !== yearPathView.currentIndex
            width: PathView.view.width
            height: PathView.view.height

            YearViewDelegate{
                anchors.fill: parent
                scrollMonth: 0;
                isCurrentItem: (index == yearPathView.currentIndex)
                focus: isCurrentItem
                year: (anchorYear + yearPathView.loopCurrentIndex + yearPathView.indexType(index))
                onMonthSelected: {
                    yearViewPage.monthSelected(date)
                }
            }
        }
    }
}
