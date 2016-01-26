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

Page {
    id: monthViewPage
    objectName: "monthViewPage"

    property var anchorDate: DateExt.today();
    readonly property var currentDate: monthViewPath.currentItem.indexDate
    property var selectedDay;
    property var highlightedDate;

    signal dateSelected(var date);
    signal dateHighlighted(var date);

    Keys.forwardTo: [monthViewPath]

    Action {
        id: calendarTodayAction
        objectName:"todaybutton"
        iconName: "calendar-today"
        text: i18n.tr("Today")
        onTriggered: {
            monthViewPath.scrollToBegginer()
            anchorDate = new Date().midnight()
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
            objectName:"monthYearLabel"
            fontSize: "x-large"
            // TRANSLATORS: this is a time formatting string,
            // see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details for valid expressions.
            // It's used in the header of the month and week views
            text: currentDate.toLocaleString(Qt.locale(),i18n.tr("MMMM yyyy"))
            font.capitalization: Font.Capitalize
        }
    }

    PathViewBase{
        id: monthViewPath
        objectName: "monthViewPath"

        anchors.fill: parent

        delegate: MonthWithEventsComponent {
            property var indexDate: monthViewPath.loopCurrentIndex === 0 ?
                                        anchorDate : anchorDate.addMonths(monthViewPath.loopCurrentIndex + monthViewPath.indexType(index))

            currentMonth: indexDate.getMonth()
            currentYear: indexDate.getFullYear()

            width: parent.width - units.gu(4)
            height: parent.height
            isCurrentItem: (index === monthViewPath.currentIndex)
            displayWeekNumber: mainView.displayWeekNumber
            highlightedDate: monthViewPage.highlightedDate
            isYearView: false

            onDateSelected: {
                monthViewPage.dateSelected(date);
            }
            onDateHighlighted: {
                console.debug("Date highlight:" + date)
                monthViewPage.highlightedDate = date
                monthViewPage.dateHighlighted(date);
            }
        }
    }
}
