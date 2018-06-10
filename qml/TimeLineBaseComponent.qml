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
import Ubuntu.Components.Popups 1.3
import QtOrganizer 5.0

import "dateExt.js" as DateExt
import "ViewType.js" as ViewType

Item {
    id: root

    property var keyboardEventProvider;

    property bool isCurrentItem: false
    property bool isActive: false

    property date startDay: DateExt.today();
    property int weekNumber: startDay.weekNumber(Qt.locale().firstDayOfWeek);
    property alias contentY: timeLineView.contentY
    property alias contentInteractive: timeLineView.interactive
    property alias autoUpdate: mainModel.active
    property var modelFilter: invalidFilter
    property var selectedDay;
    property real daysViewed: 5.1

    property real hourItemHeight: units.gu(4)
    property real hourItemHeightMin: Math.max(timeLine.timeLabelHeight, timeLine.height/24)
    property real headerHeight: 0

    onHourItemHeightChanged: {
        keepScrollHourInBounds();
    }

    readonly property int currentHour: timeLineView.contentY > hourItemHeight ?
                                           Math.round(timeLineView.contentY / hourItemHeight) : 1
    readonly property int currentDayOfWeek: timeLineView.contentX > timeLineView.delegateWidth ?
                                                Math.floor(timeLineView.contentX / timeLineView.delegateWidth) : 0
    property int type: ViewType.ViewTypeWeek

    //visible hour
    property real scrollHour

    onScrollHourChanged: {
        keepScrollHourInBounds();
    }

    function keepScrollHourInBounds() {
        var visibleHour = timeLine.height / root.hourItemHeight;

        if( scrollHour < 0) {
            scrollHour = 0;
        }

        if( scrollHour > (24 - visibleHour)) {
            scrollHour = 24 - visibleHour;
        }
    }

    signal dateSelected(var date);
    signal dateHighlighted(var date);
    signal pressAndHoldAt(var date, bool allDay);

    function timeIsVisible(date) {

        var hour = date.getHours();
        var currentTimeY = (hour * hourItemHeight)
        return ((currentTimeY >= timeLineView.contentY) &&
                (currentTimeY <= (timeLineView.contentY + timeLineView.height)));
    }

    function dateIsVisible(date) {
        if (date.getFullYear() !== startDay.getFullYear()) {
            return false;
        }

        if (type != ViewType.ViewTypeWeek) {
            return ((date.getMonth() === startDay.getMonth) &&
                    (date.getDate() === startDay.getDate()))
        }

        var dateDayOfWeekX = date.getDay() * timeLineView.delegateWidth
        return ((dateDayOfWeekX >= timeLineView.contentX) &&
                (dateDayOfWeekX <= (timeLineView.contentX + timeLineView.width)))
    }

    function dateTimeIsVisible(date) {
        return dateIsVisible(date) && timeIsVisible(date);
    }

    function scrollToTime(date) {
        scrollHour = date.getHours();
    }

    function scrollToDate(date) {
        if (type != ViewType.ViewTypeWeek) {
            return;
        }

        var todayWeekNumber = date.weekNumber(Qt.locale().firstDayOfWeek);

        if (todayWeekNumber === root.weekNumber) {
            var startOfWeek = date.weekStart(Qt.locale().firstDayOfWeek);
            var weekDay = date.getDay();
            var diff = weekDay - Qt.locale().firstDayOfWeek
            diff = diff < 0 ? 0 : diff

            var currentDayY = timeLineView.delegateWidth * diff
            var margin = (timeLineView.width - timeLineView.delegateWidth) / 2
            currentDayY = currentDayY - margin
            timeLineView.contentX = Math.min(timeLineView.contentWidth - timeLineView.width, currentDayY > 0 ? currentDayY : 0)
        } else {
            timeLineView.contentX = 0
        }

        timeLineView.returnToBounds()
    }

    function scrollToDateAndTime(date) {
        scrollToTime(date)
        scrollToDate(date)
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

    function update()
    {
        mainModel.updateIfNecessary()
    }

    Connections{
        target: keyboardEventProvider
        onScrollUp:{
            scrollHour--;
        }

        onScrollDown:{
            scrollHour++;
        }
    }

    onIsActiveChanged: {
        if (isActive && (mainModel.filter === invalidFilter)) {
            idleRefresh.reset()
        }
    }

    Timer {
        id: idleRefresh

        function reset()
        {
            mainModel.filter = invalidFilter
            restart()
        }

        interval: root.isCurrentItem ? 500 : 1000
        repeat: false
        onTriggered: {
            mainModel.filter = Qt.binding(function() { return root.modelFilter} )
        }

    }

    EventListModel {
        id: mainModel
        objectName: "timeLineBaseEventListModel:" + root.objectName

        manager:"eds"
        startPeriod: startDay.midnight();
        endPeriod: type == ViewType.ViewTypeWeek ? startPeriod.addDays(6).endOfDay(): startPeriod.endOfDay()

        onStartPeriodChanged: idleRefresh.reset()
        onEndPeriodChanged: idleRefresh.reset()
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
            property real daysViewed: root.daysViewed

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
                id: timeLine
                contentY: timeLineView.contentY
                hourItemHeight: root.hourItemHeight
                headerHeight: header.height + root.headerHeight
            }

            SimpleDivider{
                id: timeLineBorder
                width: units.gu(0.1)
                height: parent.height
            }

            Flickable {
                id: timeLineView
                objectName: "timelineview"

                height: parent.height
                width: parent.width - timeLine.width - timeLineBorder.width

                boundsBehavior: Flickable.StopAtBounds

                property int delegateWidth: {
                    if( type == ViewType.ViewTypeWeek ) {
                        width/root.daysViewed
                    } else {
                        width
                    }
                }

                contentY: scrollHour * hourItemHeight

                onMovementStarted: { contentY = scrollHour * hourItemHeight; }
                onMovementEnded: {
                    scrollHour = contentY / hourItemHeight;
                    contentY = Qt.binding( function() { return scrollHour * hourItemHeight; } );
                }
                contentHeight: root.hourItemHeight * 24
                contentWidth: {
                    if( type == ViewType.ViewTypeWeek ) {
                        delegateWidth*7
                    } else {
                        width
                    }
                }

                clip: true

                TimeLineBackground {
                    property real hourItemHeigth: root.hourItemHeight
                }

                Row {
                    id: week
                    anchors.fill: parent

                    Repeater {
                        model: type == ViewType.ViewTypeWeek ? 7 : 1

                        delegate: TimeLineBase {
                            id: delegate

                            objectName: "TimeLineBase_" + root.objectName

                            property int idx: index
                            hourHeight: root.hourItemHeight
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
                                    delegate.waitForModelChange()
                                    delegate.model.saveItem(event);
                                    delegate.model.updateIfNecessary()
                                }

                                onPositionChanged: {
                                    // the more zoomed in the smaller the scroll factor must be (else the scrolling is too fast)
                                    var zoomedInPenalty = 10*(root.hourItemHeight-root.hourItemHeightMin);
                                    var scrollFactor = 1/(units.gu(0.5)+zoomedInPenalty);
                                    dropArea.modifyEventForDrag(drag);
                                    var eventBubble = drag.source;
                                    eventBubble.updateEventBubbleStyle();

                                    if( eventBubble.y + eventBubble.height + root.hourItemHeight > timeLineView.contentY + timeLineView.height ) {
                                        var diff = Math.abs((eventBubble.y + eventBubble.height + root.hourItemHeight)  -
                                                            (timeLineView.height + timeLineView.contentY));
                                        root.scrollHour += diff*scrollFactor;
                                    }

                                    if(eventBubble.y - root.hourItemHeight < timeLineView.contentY ) {
                                        var diff = Math.abs((eventBubble.y - root.hourItemHeight)  - timeLineView.contentY);
                                        root.scrollHour -= diff*scrollFactor;
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
            flickable: root.isCurrentItem ? timeLineView : null
            clip: true
            opacity: parent.enabled ? 1.0 : 0.3
            minimumHeight: fontMetrics.height + units.gu(1)

            // send a signal to update application current date
            onClicked: root.dateHighlighted(event.startDateTime)
            onIsLiveEditingChanged: {
                if (isLiveEditing)
                    root.dateHighlighted(event.startDateTime)
            }
        }
    }

    // used to check font size and calculate the event minimum height

    FontMetrics {
        id: fontMetrics
        font.pixelSize: FontUtils.sizeToPixels("small")
    }

}
