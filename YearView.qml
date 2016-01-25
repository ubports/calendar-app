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

    property int currentYear: DateExt.today().getFullYear();
    signal monthSelected(var date);

    Keys.forwardTo: [yearPathView]

    function refreshCurrentYear(year) {
        currentYear = year;
        var yearViewDelegate = yearPathView.currentItem.item;
        yearViewDelegate.refresh();
    }

    Action {
        id: calendarTodayAction
        objectName:"todaybutton"
        iconName: "calendar-today"
        text: i18n.tr("Today")
        onTriggered: {
            currentYear = new Date().getFullYear()
        }
    }

    head {
        actions: [
            calendarTodayAction,
            commonHeaderActions.newEventAction,
            commonHeaderActions.showCalendarAction,
            commonHeaderActions.reloadAction,
            commonHeaderActions.syncCalendarAction,
            commonHeaderActions.settingsAction
        ]
        contents: Label {
            id:year
            objectName:"yearLabel"
            fontSize: "x-large"
            text: i18n.tr("Year %1").arg(currentYear)
        }
    }

    PathViewBase {
        id: yearPathView
        objectName: "yearPathView"

        anchors.fill: parent

        onNextItemHighlighted: {
            currentYear = currentYear + 1;
        }

        onPreviousItemHighlighted: {
            currentYear = currentYear - 1;
        }

        delegate: Loader {
            width: parent.width
            height: parent.height
            anchors.top: parent.top

            asynchronous: index !== yearPathView.currentIndex
            sourceComponent: delegateComponent

            Component{
                id: delegateComponent

                YearViewDelegate{
                    focus: index == yearPathView.currentIndex

                    scrollMonth: 0;
                    isCurrentItem: index == yearPathView.currentIndex
                    year: (currentYear + yearPathView.indexType(index))

                    anchors.fill: parent
                }
            }
        }
    }
}
