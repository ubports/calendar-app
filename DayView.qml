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
import "ViewType.js" as ViewType

Page{
    id: dayViewPage
    objectName: "dayViewPage"

    property var currentDay: new Date()
    property bool isCurrentPage: false

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

       head.actions: [
           calendarTodayAction,
           commonHeaderActions.newEventAction,
           commonHeaderActions.showCalendarAction,
           commonHeaderActions.reloadAction
       ]

    Column {
        id: column
        anchors.top: parent.top
        anchors.topMargin: units.gu(1.5)
        width: parent.width; height: parent.height
        spacing: units.gu(1)

        anchors.fill: parent

        ViewHeader{
            id: viewHeader
            month: currentDay.getMonth()
            year: currentDay.getFullYear()
        }

        TimeLineHeader{
            id: dayHeader
            type: ViewType.ViewTypeDay
            date: currentDay
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            path: Path {
                startX: -(dayHeader.width/7); startY: dayHeader.height/2
                PathLine { x: (dayHeader.width/7) * 8  ; relativeY: 0;  }
            }
            onDateSelected: {
                if(date < currentDay){
                    currentDay = currentDay.addDays(-1);
                    dayHeader.decrementCurrentIndex()
                }
                else if( date > currentDay){
                     currentDay = currentDay.addDays(1);
                     dayHeader.incrementCurrentIndex();
                 }
             }
        }

        PathViewBase{
            id: dayViewPath
            objectName: "dayViewPath"

            property var startDay: currentDay
            //This is used to scroll all view together when currentItem scrolls
            property var childContentY;

            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5

            width: parent.width
            height: column.height - dayViewPath.y

            path: Path {
                startX: -(dayViewPath.width/1.75); startY: dayViewPath.height/2
                PathLine { x: (dayViewPath.width/7) * 11  ; relativeY: 0;  }
            }

            onNextItemHighlighted: {
                //next day
                currentDay = currentDay.addDays(1);
                dayHeader.incrementCurrentIndex()
            }

            onPreviousItemHighlighted: {
                //previous day
                currentDay = currentDay.addDays(-1);
                dayHeader.decrementCurrentIndex()
            }

            delegate: TimeLineBaseComponent {
                id: timeLineView
                objectName: "DayComponent-"+index

                type: ViewType.ViewTypeDay

                width: parent.width/7 * 5
                height: parent.height
                z: index == dayViewPath.currentIndex ? 2 : 1
                isActive: true

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
                    when: !timeLineView.PathView.isCurrentItem
                }

                //set PathView's contentY property, if its current item
                Binding{
                    target: dayViewPath
                    property: "childContentY"
                    value: contentY
                    when: timeLineView.PathView.isCurrentItem
                }

                contentInteractive: timeLineView.PathView.isCurrentItem

                startDay: dayViewPath.startDay.addDays(dayViewPath.indexType(index))
            }
        }
    }
}
