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
    id: dayViewPage
    objectName: "dayViewPage"

    property var anchorDate: new Date()
    readonly property var currentDate: dayViewPath.currentItem.startDay

    signal dateSelected(var date);
    signal pressAndHoldAt(var date)

    Keys.forwardTo: [dayViewPath]
    flickable: null

    Action {
        id: calendarTodayAction
        objectName:"todaybutton"
        iconName: "calendar-today"
        text: i18n.tr("Today")
        onTriggered: {
            dayViewPath.scrollToBegginer()
            anchorDate = new Date()
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
            id:monthYear
            objectName:"monthYearLabel"
            fontSize: "x-large"
            text: currentDate.toLocaleString(Qt.locale(),i18n.tr("MMMM yyyy"))
            font.capitalization: Font.Capitalize
        }
    }

    PathViewBase{
        id: dayViewPath
        objectName: "dayViewPath"

        //This is used to scroll all view together when currentItem scrolls
        property var childContentY;

        anchors.fill: parent

        delegate: TimeLineBaseComponent {
            id: timeLineView
            objectName: "DayComponent-"+index

            width: parent.width
            height: parent.height

            type: ViewType.ViewTypeDay
            isActive: PathView.isCurrentItem
            contentInteractive: PathView.isCurrentItem
            startDay: anchorDate.addDays(dayViewPath.loopCurrentIndex + dayViewPath.indexType(index))
            keyboardEventProvider: dayViewPath

            onPressAndHoldAt: {
                dayViewPage.pressAndHoldAt(date)
            }

            Component.onCompleted: {
                if(dayViewPage.active){
                    timeLineView.scrollToCurrentTime();
                }
            }

            Connections{
                target: dayViewPage
                onActiveChanged: {
                    if(dayViewPage.active){
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
