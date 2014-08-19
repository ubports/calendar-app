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
import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

Page {
    id: monthViewPage
    objectName: "monthViewPage"

    property var currentMonth: DateExt.today();

    signal dateSelected(var date);

    Keys.forwardTo: [monthViewPath]

    PathViewBase{
        id: monthViewPath
        objectName: "monthViewPath"

        property var startMonth: currentMonth;

        anchors.top:parent.top

        width:parent.width
        height: parent.height

        onNextItemHighlighted: {
            nextMonth();
        }

        onPreviousItemHighlighted: {
            previousMonth();
        }

        function nextMonth() {
            currentMonth = addMonth(currentMonth, 1);
        }

        function previousMonth() {
            currentMonth = addMonth(currentMonth, -1);
        }

        function addMonth(date,month) {
            return  new Date(date.getFullYear(), date.getMonth() + month, 1, 0, 0, 0);
        }

        delegate: MonthComponent {
            property bool isCurrentItem: index === monthViewPath.currentIndex

            showEvents: true

            width: parent.width - units.gu(5)
            height: parent.height - units.gu(5)

            currentMonth: monthViewPath.addMonth(monthViewPath.startMonth,
                                                 monthViewPath.indexType(index));

            isYearView: false

            onDateSelected: {
                monthViewPage.dateSelected(date);
            }
        }
    }
}
