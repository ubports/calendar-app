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
import Ubuntu.Components.Popups 0.1
import QtOrganizer 5.0

import "dateExt.js" as DateExt
import "ViewType.js" as ViewType

Item {
    id: root

    property var startDay: DateExt.today();
    property bool isActive: false
    property alias contentY: timeLineView.contentY
    property alias contentInteractive: timeLineView.interactive

    property int type: ViewType.ViewTypeWeek

    //visible hour
    property int scrollHour;

    function scrollToCurrentTime() {
        var currentTime = new Date();
        scrollHour = currentTime.getHours();

        timeLineView.contentY = scrollHour * units.gu(10);
        if(timeLineView.contentY >= timeLineView.contentHeight - timeLineView.height) {
            timeLineView.contentY = timeLineView.contentHeight - timeLineView.height
        }
    }

    Connections{
        target: parent
        onScrollUp:{
            scrollHour--;
            if( scrollHour < 0) {
                scrollHour =0;
            }
            scrollToHour();
        }

        onScrollDown:{
            scrollHour++;
            var visibleHour = root.height / units.gu(10);
            if( scrollHour > (25 -visibleHour)) {
                scrollHour = 25 - visibleHour;
            }
            scrollToHour();
        }
    }

    function scrollToHour() {
        timeLineView.contentY = scrollHour * units.gu(10);
        if(timeLineView.contentY >= timeLineView.contentHeight - timeLineView.height) {
            timeLineView.contentY = timeLineView.contentHeight - timeLineView.height
        }
    }

    EventListModel {
        id: mainModel
        startPeriod: startDay.midnight();
        endPeriod: type == ViewType.ViewTypeWeek ? startPeriod.addDays(7).endOfDay(): startPeriod.endOfDay()
        filter: eventModel.filter
    }

    ActivityIndicator {
        visible: running
        running: mainModel.isLoading
        anchors.centerIn: parent
        z:2
    }

    Column {
        anchors.top: parent.top

        width: parent.width
        height: parent.height

        AllDayEventComponent {
            id: allDayContainer
            type: root.type
            startDay: root.startDay
            model: mainModel
            Component.onCompleted: {
                mainModel.addModelChangeListener(createAllDayEvents);
            }
            Component.onDestruction: {
                mainModel.removeModelChangeListener(createAllDayEvents);
            }
        }

        Flickable {
            id: timeLineView

            width: parent.width
            height: parent.height - allDayContainer.height

            contentHeight: units.gu(10) * 24
            contentWidth: width

            clip: true

            TimeLineBackground {
            }

            Row {
                id: week
                width: parent.width
                height: parent.height
                anchors.top: parent.top

                Repeater {
                    model: type == ViewType.ViewTypeWeek ? 7 : 1

                    delegate: TimeLineBase {
                        property int idx: index
                        anchors.top: parent.top
                        width: {
                            if( type == ViewType.ViewTypeWeek ) {
                                parent.width / 7
                            } else {
                                (parent.width)
                            }
                        }

                        height: parent.height
                        delegate: comp
                        day: startDay.addDays(index)

                        Connections{
                            target: mainModel
                            onStartPeriodChanged:{
                                destroyAllChildren();
                            }
                        }

                        model: mainModel
                        Component.onCompleted: {
                            model.addModelChangeListener(destroyAllChildren);
                            model.addModelChangeListener(createEvents);
                        }
                        Component.onDestruction: {
                            model.removeModelChangeListener(destroyAllChildren);
                            model.removeModelChangeListener(createEvents);
                        }
                    }
                }
            }
        }
    }

    Component {
        id: comp
        EventBubble {
            type: root.type == ViewType.ViewTypeWeek ? narrowType : wideType
            flickable: root.isActive ? timeLineView : null
            clip: true
        }
    }
}
