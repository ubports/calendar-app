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
import Ubuntu.Components.Popups 1.0
import QtOrganizer 5.0

import "dateExt.js" as DateExt
import "ViewType.js" as ViewType

Item {
    id: root

    property var keyboardEventProvider;

    property date startDay: DateExt.today();
    property int weekNumber: startDay.weekNumber(Qt.locale().firstDayOfWeek);
    property bool isActive: false
    property alias contentY: timeLineView.contentY
    property alias contentInteractive: timeLineView.interactive
    property alias modelFilter: mainModel.filter
    property var selectedDay;

    readonly property real hourItemHeight: units.gu(8)
    readonly property int currentHour: timeLineView.contentY > hourItemHeight ?
                                           Math.round(timeLineView.contentY / hourItemHeight) : 1
    readonly property int currentDayOfWeek: timeLineView.contentX > timeLineView.delegateWidth ?
                                                Math.floor(timeLineView.contentX / timeLineView.delegateWidth) : 0
    property int type: ViewType.ViewTypeWeek

    //visible hour
    property int scrollHour;

    signal dateSelected(var date);
    signal dateHighlighted(var date);
    signal pressAndHoldAt(var date, bool allDay);

    function scrollToCurrentTime() {
        var currentTime = new Date();
        scrollHour = currentTime.getHours();

        var newY = scrollHour * hourItemHeight
        timeLineView.contentY = Math.min(timeLineView.contentHeight - timeLineView.height, newY)
        timeLineView.returnToBounds()
    }

    function scrollTocurrentDate() {
        if ( type != ViewType.ViewTypeWeek ){
            return;
        }

        var today = DateExt.today();
        var todayWeekNumber = today.weekNumber(Qt.locale().firstDayOfWeek);
        var startOfWeek = today.weekStart(Qt.locale().firstDayOfWeek);
        var weekDay = today.getDay();
        var diff = weekDay - Qt.locale().firstDayOfWeek
        diff = diff < 0 ? 0 : diff

        var newX = timeLineView.delegateWidth * diff
        timeLineView.contentX = Math.min(timeLineView.contentWidth - timeLineView.width, newX)
        timeLineView.returnToBounds()
    }

    function scrollToEnd()
    {
        timeLineView.contentX = timeLineView.contentWidth - timeLineView.width
        timeLineView.returnToBounds()
    }

    function scrollToBegin()
    {
        timeLineView.contentX = 0
        timeLineView.returnToBounds()
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
        onModelChanged: console.debug("Model changeeeeeeee")
    }

    ActivityIndicator {
        id: activityLoader
        objectName : "activityIndicator"

        visible: running
        anchors.centerIn: parent
        running: mainModel.isLoading
        z:2
    }

    Column {
        anchors.fill: parent

        TimeLineHeader{
            id: header
            objectName: "viewHeader"
            startDay: root.startDay
            contentX: timeLineView.contentX
            type: root.type
            isActive: root.isActive
            selectedDay: root.selectedDay

            onDateSelected: {
                root.dateSelected(date.getFullYear(),
                                  date.getMonth(),
                                  date.getDate(),
                                  root.currentHour, 0, 0)
            }

            onDateHighlighted: {
                root.dateHighlighted(date.getFullYear(),
                                     date.getMonth(),
                                     date.getDate(),
                                     root.currentHour, 0, 0)
            }

            onAllDayPressAndHold: {
                root.pressAndHoldAt(date, true)
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
                objectName: "timelineview"

                height: parent.height
                width: parent.width - units.gu(6)

                boundsBehavior: Flickable.StopAtBounds

                property int delegateWidth: {
                    if( type == ViewType.ViewTypeWeek ) {
                        width/3 - units.gu(1) // partial visible area
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
                            id: delegate

                            property int idx: index
                            flickable: timeLineView
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
                            autoUpdate: root.isActive

                            onPressAndHoldAt: {
                                root.pressAndHoldAt(date, false)
                            }

                            Binding {
                                target: timeLineView
                                property: "interactive"
                                value: !delegate.creatingEvent
                            }

                            DropArea {
                                id: dropArea
                                objectName: "mouseArea"
                                anchors.fill: parent

                                 function modifyEventForDrag(drag) {
                                    var event = drag.source.event;
                                    var diff = event.endDateTime.getTime() - event.startDateTime.getTime();

                                    var startDate = getTimeFromYPos(drag.y, day);
                                    var endDate = new Date( startDate.getTime() + diff );

                                    event.startDateTime = startDate;
                                    event.endDateTime = endDate;

                                    return event;
                                }

                                onDropped: {
                                    var event = dropArea.modifyEventForDrag(drop);
                                    model.saveItem(event);
                                }

                                onPositionChanged: {
                                    dropArea.modifyEventForDrag(drag)
                                    var eventBubble = drag.source;
                                    eventBubble.assingnBgColor();
                                    eventBubble.setDetails();

                                    if( eventBubble.y + eventBubble.height + units.gu(8) > timeLineView.contentY + timeLineView.height ) {
                                        var diff = Math.abs((eventBubble.y + eventBubble.height + units.gu(8))  -
                                                            (timeLineView.height + timeLineView.contentY));
                                        timeLineView.contentY += diff

                                        if(timeLineView.contentY >= timeLineView.contentHeight - timeLineView.height) {
                                            timeLineView.contentY = timeLineView.contentHeight - timeLineView.height
                                        }
                                    }

                                    if(eventBubble.y - units.gu(8) < timeLineView.contentY ) {
                                        var diff = Math.abs((eventBubble.y - units.gu(8))  - timeLineView.contentY);
                                        timeLineView.contentY -= diff

                                        if(timeLineView.contentY <= 0) {
                                            timeLineView.contentY = 0;
                                        }
                                    }
                                }
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
            opacity: parent.enabled ? 1.0 : 0.3
        }
    }
}
