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

PageWithBottomEdge {
    id: monthViewPage
    objectName: "monthViewPage"

    property var anchorDate: DateExt.today();
    readonly property var firstDayOfAnchorDate: new Date(anchorDate.getFullYear(),
    anchorDate.getMonth(),
    1,
    0, 0, 0)
    readonly property var currentDate: monthViewPath.currentItem.item ?
    monthViewPath.currentItem.item.indexDate
    : null

    property var selectedDay;
    property bool displayLunarCalendar: false

    signal dateSelected(var date);

    Keys.forwardTo: [monthViewPath]
    onAnchorDateChanged: monthViewPath.scrollToBegginer()

    Action {
        id: calendarTodayAction
        objectName:"todaybutton"
        iconName: "calendar-today"
        text: i18n.tr("Today")
        onTriggered: {
            anchorDate = new Date().midnight()
        }
    }



    header: DefaultHeader {
        id: pageHeader

        trailingActionBar.actions: [
        calendarTodayAction,
        commonHeaderActions.showCalendarAction,
        commonHeaderActions.reloadAction,
        commonHeaderActions.syncCalendarAction,
        commonHeaderActions.settingsAction
        ]


        title: {
            if (displayLunarCalendar) {
                var year = currentDate.getFullYear()
                var month = currentDate.getMonth()
                var day = Math.floor(Date.daysInMonth(year, month) / 2.0)
                var lunarDate = Lunar.calendar.solar2lunar(year, month + 1, day)
                return i18n.tr("%1 %2").arg(lunarDate .IMonthCn).arg(lunarDate.gzYear)
            } else {
                // TRANSLATORS: this is a time formatting string,
                // see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details for valid expressions.
                // It's used in the header of the month and week views
                var monthName = currentDate.toLocaleString(Qt.locale(),i18n.tr("MMMM yyyy"))
                return monthName[0].toUpperCase() + monthName.substr(1, monthName.length - 1)
            }
        }
        flickable: null
    }

    PathViewBase{
        id: monthViewPath
        objectName: "monthViewPath"

        anchors {
            fill: parent
            topMargin: header.height
            bottomMargin: monthViewPage.bottomEdgeHeight
        }

        property bool loadNonVisibleDelegate: false

        Timer {
            running: true
            onTriggered: monthViewPath.loadNonVisibleDelegate = true
            interval: 1
        }

        delegate: Loader {
            id: delegateLoader

            asynchronous: true
            width: PathView.view.width
            height: PathView.view.height
            active: monthViewPath.loadNonVisibleDelegate || (index === monthViewPath.currentIndex)

            sourceComponent: MonthWithEventsComponent {
                id: monthDelegate

                property var indexDate: firstDayOfAnchorDate.addMonths(monthViewPath.loopCurrentIndex + monthViewPath.indexType(index))

                currentMonth: indexDate.getMonth()
                currentYear: indexDate.getFullYear()
                displayLunarCalendar: monthViewPage.displayLunarCalendar

                autoUpdate: monthViewPage.tabSelected && monthViewPage.active && isCurrentItem
                modelFilter: eventModel.filter
                width: parent.width - units.gu(4)
                height: parent.height
                isCurrentItem: (index === monthViewPath.currentIndex)
                isActive: !monthViewPath.moving && !monthViewPath.flicking
                displayWeekNumber: mainView.displayWeekNumber
                isYearView: false

                onDateSelected: {
                    monthViewPage.dateSelected(date);
                }

                // make sure that the model is updated after create a new event if it is marked as auto-update false
                Connections {
                    target: monthViewPage
                    onActiveChanged: {
                        if (monthViewPage.active) {
                            monthDelegate.update()
                        }
                    }
                    onEventSaved: {
                        monthDelegate.update()
                    }
                    onEventDeleted: {
                        monthDelegate.update()
                    }
                }
            }
        }
    }
}
