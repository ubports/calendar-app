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

import QtQuick 2.3
import Ubuntu.Components 1.1
import "dateExt.js" as DateExt
import "ViewType.js" as ViewType

Page{
    id: dayViewPage
    objectName: "dayViewPage"

    property var currentDay: new Date()
    property bool isCurrentPage: false

    signal dateSelected(var date);

    Keys.forwardTo: [dayViewPath]
    flickable: null

    Action {
        id: calendarTodayAction
        objectName:"todaybutton"
        iconName: "calendar-today"
        text: i18n.tr("Today")
        onTriggered: {
            currentDay = new Date()
        }
    }

    head {
        actions: [
            calendarTodayAction,
            commonHeaderActions.newEventAction,
            commonHeaderActions.showCalendarAction,
            commonHeaderActions.reloadAction
        ]

        contents: Label {
            id:monthYear
            objectName:"monthYearLabel"
            fontSize: "x-large"
            text: i18n.tr(currentDay.toLocaleString(Qt.locale(),i18n.tr("MMMM yyyy")))
            font.capitalization: Font.Capitalize
        }
    }

    Column {
        anchors.fill: parent
        anchors.topMargin: units.gu(1)
        spacing: units.gu(1)

        TimeLineHeader{
            id: dayHeader
            objectName: "dayHeader"
            type: ViewType.ViewTypeDay
            currentDay: dayViewPage.currentDay

            onDateSelected: {
                dayViewPage.currentDay = date;
                dayViewPage.dateSelected(date);
            }

            onCurrentDayChanged: {
                date = dayViewPage.currentDay.weekStart(Qt.locale().firstDayOfWeek);
            }

            function nextDay() {
                if(currentDay >= date.addDays(7)) {
                    date = dayViewPage.currentDay.weekStart(Qt.locale().firstDayOfWeek);
                    dayHeader.incrementCurrentIndex();
                }
            }

            function previousDay() {
                if( currentDay < date) {
                    date = dayViewPage.currentDay.weekStart(Qt.locale().firstDayOfWeek);
                    dayHeader.decrementCurrentIndex();
                }
            }
        }

        PathViewBase{
            id: dayViewPath
            objectName: "dayViewPath"

            property var startDay: currentDay
            //This is used to scroll all view together when currentItem scrolls
            property var childContentY;

            width: parent.width
            height: dayViewPage.height - dayViewPath.y

            onNextItemHighlighted: {
                //next day
                currentDay = currentDay.addDays(1);
                dayHeader.nextDay();
            }

            onPreviousItemHighlighted: {
                //previous day
                currentDay = currentDay.addDays(-1);
                dayHeader.previousDay();
            }

            delegate: Loader {
                width: parent.width
                height: parent.height
                asynchronous: index !== dayViewPath.currentIndex
                sourceComponent: delegateComponent

                Component {
                    id: delegateComponent

                    TimeLineBaseComponent {
                        id: timeLineView
                        objectName: "DayComponent-"+index

                        type: ViewType.ViewTypeDay
                        anchors.fill: parent

                        isActive: parent.PathView.isCurrentItem
                        contentInteractive: parent.PathView.isCurrentItem
                        startDay: dayViewPath.startDay.addDays(dayViewPath.indexType(index))
                        keyboardEventProvider: dayViewPath

                        Component.onCompleted: {
                            if(dayViewPage.isCurrentPage){
                                timeLineView.scrollToCurrentTime();
                            }
                        }

                        Connections{
                            target: dayViewPage
                            onIsCurrentPageChanged:{
                                if(dayViewPage.isCurrentPage){
                                    timeLineView.scrollToCurrentTime();
                                }
                            }
                        }

                        //get contentY value from PathView, if its not current Item
                        Binding{
                            target: timeLineView
                            property: "contentY"
                            value: dayViewPath.childContentY;
                            when: !parent.PathView.isCurrentItem
                        }

                        //set PathView's contentY property, if its current item
                        Binding{
                            target: dayViewPath
                            property: "childContentY"
                            value: contentY
                            when: parent.PathView.isCurrentItem
                        }
                    }
                }
            }
        }
    }
}
