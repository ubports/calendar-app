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
import Ubuntu.Components 1.1

import "dateExt.js" as DateExt
Page {
    id: yearViewPage
    objectName: "yearViewPage"

    property int currentYear: DateExt.today().getFullYear();
    signal monthSelected(var date);

    Keys.forwardTo: [yearPathView]

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

        delegate: GridView{
            id: yearView
            clip: true
            focus: index == yearPathView.currentIndex

            property int scrollMonth: 0;
            property bool isCurrentItem: index == yearPathView.currentIndex
            property int year: (yearViewPage.currentYear + yearPathView.indexType(index))

            width: parent.width
            height: parent.height
            anchors.top: parent.top

            readonly property int minCellWidth: units.gu(30)
            cellWidth: Math.floor(Math.min.apply(Math, [3, 4].map(function(n)
            { return ((width / n >= minCellWidth) ? width / n : width / 2) })))

            cellHeight: cellWidth * 1.4

            model: 12 /* months in a year */

            onYearChanged: {
                scrollMonth = 0;
                yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
            }

            //scroll in case content height changed
            onHeightChanged: {
                scrollMonth = 0;
                yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
            }

            Connections{
                target: yearPathView
                onScrollUp: {
                    scrollMonth -= 2;
                    if(scrollMonth < 0) {
                        scrollMonth = 0;
                    }
                    yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
                }

                onScrollDown: {
                    scrollMonth += 2;
                    var visibleMonths = yearView.height / cellHeight;
                    if( scrollMonth >= (11 - visibleMonths)) {
                        scrollMonth = (11 - visibleMonths);
                    }
                    yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
                }
            }

            delegate: Item {
                width: yearView.cellWidth
                height: yearView.cellHeight

                MonthComponent {
                    id: monthComponent
                    objectName: "monthComponent" + index
                    showEvents: false
                    currentMonth: new Date(yearView.year, index, 1, 0, 0, 0, 0)

                    isYearView: true
                    anchors.fill: parent
                    anchors.margins: units.gu(0.5)

                    dayLabelFontSize:"x-small"
                    dateLabelFontSize: "medium"
                    monthLabelFontSize: "medium"
                    yearLabelFontSize: "small"

                    onMonthSelected: {
                       yearViewPage.monthSelected(date);
                    }
                }
            }
        }
    }
}
