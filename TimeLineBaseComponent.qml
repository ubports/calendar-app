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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import QtOrganizer 5.0
import "dateExt.js" as DateExt
import "ViewType.js" as ViewType

Item {
    id: root

    property var keyboardEventProvider;

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
        target: keyboardEventProvider
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
        objectName : "activityIndicator"
        running: mainModel.isLoading
        anchors.centerIn: parent
        z:2
    }

    AllDayEventComponent {
        id: allDayContainer
        type: root.type
        startDay: root.startDay
        model: mainModel
        z:1
        Component.onCompleted: {
            mainModel.addModelChangeListener(createAllDayEvents);
        }
        Component.onDestruction: {
            mainModel.removeModelChangeListener(createAllDayEvents);
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Flickable {
            id: timeLineView

            Layout.fillHeight: true

            contentHeight: units.gu(10) * 24
            contentWidth: width
            anchors.right: parent.right
            anchors.left: parent.left

            clip: true

            TimeLineBackground {}

            Row {
                id: week

                anchors {
                    fill: parent
                    leftMargin: type == ViewType.ViewTypeWeek ? units.gu(0)
                                                              : units.gu(6)

                    rightMargin: type == ViewType.ViewTypeWeek ? units.gu(0)
                                                              : units.gu(3)
                }

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

                        Loader{
                            objectName: "weekdevider"
                            height: parent.height
                            width: units.gu(0.15)
                            sourceComponent: type == ViewType.ViewTypeWeek ? weekDeviderComponent : undefined
                        }

                        Component {
                            id: weekDeviderComponent
                            Rectangle{
                                anchors.fill: parent
                                color: "#e5e2e2"
                            }
                        }

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
