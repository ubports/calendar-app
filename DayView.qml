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

        contents: Column{
            width: parent ? parent.width - units.gu(2) : undefined

            Label {
                fontSize: "medium"
                text: Qt.locale().standaloneDayName(currentDay.getDay())
                font.capitalization: Font.Capitalize
            }

            Label {
                id:cuurentDay
                objectName:"monthYearLabel"
                fontSize: "large"
                // TRANSLATORS: this is a time formatting string,
                // see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details for valid expressions.
                // It's used in the header of the day view
                text:i18n.tr(currentDay.toLocaleString(Qt.locale(),i18n.tr("MMMM dd, yyyy")))
            }
        }
    }

    PathViewBase{
        id: dayViewPath
        objectName: "dayViewPath"

        property var startDay: currentDay
        //This is used to scroll all view together when currentItem scrolls
        property var childContentY;

        anchors.fill: parent

        onNextItemHighlighted: {
            //next day
            currentDay = currentDay.addDays(1);
        }

        onPreviousItemHighlighted: {
            //previous day
            currentDay = currentDay.addDays(-1);
        }

        delegate: TimeLineBaseComponent {
            id: timeLineView
            objectName: "DayComponent-"+index

            type: ViewType.ViewTypeDay

            width: parent.width
            height: parent.height
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

