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

    property date startDay: DateExt.today();
    property bool isActive: false
    property alias contentY: timeLineView.contentY
    property alias contentInteractive: timeLineView.interactive

    property int type: ViewType.ViewTypeWeek

    //visible hour
    property int scrollHour;

    signal dateSelected(var date);

    function scrollToCurrentTime() {
        var currentTime = new Date();
        scrollHour = currentTime.getHours();

        timeLineView.contentY = scrollHour * units.gu(8);
        if(timeLineView.contentY >= timeLineView.contentHeight - timeLineView.height) {
            timeLineView.contentY = timeLineView.contentHeight - timeLineView.height
        }
    }

    Connections{
        target: keyboardEventProvider
        onScrollUp:{
            scrollHour--;
            if( scrollHour < 0) {
                scrollHour = 0;
            }
            scrollToHour();
        }

        onScrollDown:{
            scrollHour++;
            var visibleHour = root.height / units.gu(8);
            if( scrollHour > (25 -visibleHour)) {
                scrollHour = 25 - visibleHour;
            }
            scrollToHour();
        }
    }

    function scrollToHour() {
        timeLineView.contentY = scrollHour * units.gu(8);
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

    Column {
        anchors.fill: parent

        TimeLineHeader{
            id: header
            startDay: root.startDay
            contentX: timeLineView.contentX
            type: root.type

            onDateSelected: {
                root.dateSelected(date);
            }
        }

        SimpleDivider{}

        Row {
            width: parent.width
            height: parent.height - header.height

            TimeLineTimeScale{
                contentY: timeLineView.contentY
            }

            SimpleDivider{
                width: units.gu(0.1)
                height: parent.height
            }

            Flickable {
                id: timeLineView

                height: parent.height
                width: parent.width - units.gu(6)

                boundsBehavior: Flickable.StopAtBounds

                property int delegateWidth: {
                    if( type == ViewType.ViewTypeWeek ) {
                        width/3 - units.gu(1) /*partial visible area*/
                    } else {
                        width
                    }
                }

                contentHeight: units.gu(8) * 24
                contentWidth: {
                    if( type == ViewType.ViewTypeWeek ) {
                        delegateWidth*7
                    } else {
                        width
                    }
                }

                clip: true

                TimeLineBackground{}

                Row {
                    id: week
                    anchors.fill: parent
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
                            model: mainModel

                            Component.onCompleted: {
                                model.addModelChangeListener(destroyAllChildren);
                                model.addModelChangeListener(createEvents);
                            }
                            Component.onDestruction: {
                                model.removeModelChangeListener(destroyAllChildren);
                                model.removeModelChangeListener(createEvents);
                            }

                            Loader{
                                objectName: "weekdevider"
                                height: parent.height
                                width: units.gu(0.15)
                                sourceComponent: type == ViewType.ViewTypeWeek ? weekDividerComponent : undefined
                            }

                            Component {
                                id: weekDividerComponent
                                SimpleDivider{
                                    anchors.fill: parent
                                }
                            }

                            Connections{
                                target: mainModel
                                onStartPeriodChanged:{
                                    destroyAllChildren();
                                }
                            }
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
