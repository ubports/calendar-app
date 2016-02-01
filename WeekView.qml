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

Page{
    id: weekViewPage
    objectName: "weekViewPage"

    property var anchorDate: new Date();
    readonly property var currentDate: weekViewPath.currentItem.item.currentDate
    readonly property var firstDayOfWeek: anchorDate.weekStart(Qt.locale().firstDayOfWeek);
    property bool isCurrentPage: false
    property var selectedDay;

    signal dateSelected(var date);
    signal dateHighlighted(var date);
    signal pressAndHoldAt(var date)

    Keys.forwardTo: [weekViewPath]

    flickable: null

    Action {
        id: calendarTodayAction
        objectName:"todaybutton"
        iconName: "calendar-today"
        text: i18n.tr("Today")
        onTriggered: {
            weekViewPath.scrollToBegginer()
            anchorDate = new Date()
        }
    }

    header: PageHeader {
        id: pageHeader

        leadingActionBar.actions: tabs.tabsAction
        trailingActionBar.actions: [
            calendarTodayAction,
            commonHeaderActions.newEventAction,
            commonHeaderActions.showCalendarAction,
            commonHeaderActions.reloadAction,
            commonHeaderActions.syncCalendarAction,
            commonHeaderActions.settingsAction
        ]

        title: {
            // TRANSLATORS: this is a time formatting string,
            // see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details for valid expressions.
            // It's used in the header of the month and week views
            var monthName = currentDate.toLocaleString(Qt.locale(),i18n.tr("MMMM yyyy"))
            return monthName[0].toUpperCase() + monthName.substr(1, monthName.length - 1)
        }
        flickable: null
    }

    PathViewBase{
        id: weekViewPath
        objectName: "weekviewpathbase"

        anchors {
            fill: parent
            topMargin: header.height
        }

        onCurrentIndexChanged: weekViewPage.dateHighlighted(null)

        //This is used to scroll all view together when currentItem scrolls
        property var childContentY;

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

                    property var currentDate: new Date(startDay.getFullYear(),
                                                       startDay.getMonth(),
                                                       startDay.getDate(),
                                                       currentHour, 0, 0).addDays(currentDayOfWeek)

                    anchors.fill: parent
                    type: ViewType.ViewTypeWeek
                    startDay: firstDayOfWeek.addDays((weekViewPath.loopCurrentIndex + weekViewPath.indexType(index)) * 7)
                    isActive: parent.PathView.isCurrentItem
                    keyboardEventProvider: weekViewPath
                    selectedDay: weekViewPage.selectedDay

                    onDateSelected: {
                        weekViewPage.dateSelected(date);
                    }

                    onDateHighlighted:{
                        weekViewPage.dateHighlighted(date);
                    }

                    Component.onCompleted: {
                        var iType = weekViewPath.indexType(index)
                        if (iType === 0) {
                            scrollToCurrentTime();
                            scrollTocurrentDate();
                        } else if (iType < 0) {
                            scrollToEnd()
                        }
                    }

                    onPressAndHoldAt: {
                        weekViewPage.pressAndHoldAt(date)
                    }

                    Connections{
                        target: calendarTodayAction
                        onTriggered:{
                            if( isActive )
                                timeLineView.scrollTocurrentDate();
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

                    //get contentY value from PathView, if its not current Item
                    Binding{
                        target: timeLineView
                        property: "contentY"
                        value: weekViewPath.childContentY;
                        when: !parent.PathView.isCurrentItem
                    }

                    //set PathView's contentY property, if its current item
                    Binding{
                        target: weekViewPath
                        property: "childContentY"
                        value: contentY
                        when: parent.PathView.isCurrentItem
                    }
                }
            }
        }
    }
}
