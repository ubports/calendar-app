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
import QtOrganizer 5.0

import "calendar_canvas.js" as CanlendarCanvas

Item{
    id: infoBubble

    property var anchorDate;
    property var event;
    property var model: null
    property int depthInRow: 0
    property real sizeOfRow:0.0
    property real minuteHeight: 1.0
    property int type: narrowType
    property int wideType: 1;
    property int narrowType: 2;
    property bool isLiveEditing: false
    property Flickable flickable;
    property bool isEventBubble: true

    readonly property int minimumHeight: type == wideType
                                         ? detailsItems.timeLabelHeight + /*top-bottom margin*/ units.gu(2)
                                         : units.gu(2)

    readonly property real startTimeInMinutes: event ? CanlendarCanvas.minutesSince(infoBubble.anchorDate, event.startDateTime) : 0.0
    readonly property real endTimeInMinutes: event ? CanlendarCanvas.minutesSince(infoBubble.anchorDate, event.endDateTime) : 0.0
    readonly property real durationInMinutes: endTimeInMinutes - startTimeInMinutes

    signal clicked(var event);

    // keep color up-to-date
    Connections {
        target: model
        ignoreUnknownSignals: true
        onCollectionsChanged: assingnBgColor()
    }

    function assingnBgColor() {
        if (model && event ) {
            var collection = model.collection( event.collectionId );
            var now = new Date();
            if( event.endDateTime >= now) {
                if( getOwnersStatus(collection) === EventAttendee.StatusDeclined ) {
                    //if owner of account is not attending event the dim it
                    bg.color = Qt.tint( collection.color, "#aaffffff" );
                } else {
                    bg.color = collection.color
                }
            } else {
                //if event is on past then add some white color to original color
                bg.color = Qt.tint( collection.color, "#aaffffff" );
            }
        }
    }

    function getOwnersStatus(collection) {
        var attendees = event.attendees;
        if( attendees !== undefined ) {
            for (var j = 0 ; j < attendees.length ; ++j) {
                var contact = attendees[j];
                //mail to is appended on email address so remove it
                var email = contact.emailAddress.replace("mailto:", "");
                if( email === collection.name) {
                    return contact.participationStatus;
                }
            }
        }
    }

    function setDetails() {
        if(event === null || event === undefined) {
            return;
        }

        var startTime = Qt.formatTime( event.startDateTime, "hh:mm")
        var endTime = Qt.formatTime( event.endDateTime, "hh:mm")

        if (type === wideType) {
            timeLabel.text = ""
            titleLabel.text = ""

            // TRANSLATORS: the first argument (%1) refers to a start time for an event,
            // while the second one (%2) refers to the end time
            var timeString = i18n.tr("%1 - %2").arg(startTime).arg(endTime)

            //height is less then set only event title
            if( infoBubble.height > minimumHeight ) {
                //on wide type show all details
                if( infoBubble.height > titleLabel.y + titleLabel.height + units.gu(1)) {
                    timeLabel.text = timeString
                    titleLabel.text = "<b>" + event.displayLabel +"</b>"
                } else if ( event.displayLabel ) {
                    // TRANSLATORS: the first argument (%1) refers to a time for an event,
                    // while the second one (%2) refers to title of event
                    timeLabel.text = i18n.tr("%1 <b>%2</b>").arg(timeString).arg(event.displayLabel);
                }
            } else if (event.displayLabel){
                // TRANSLATORS: the first argument (%1) refers to a time for an event,
                // while the second one (%2) refers to title of event
                timeLabel.text = i18n.tr("%1 <b>%2</b>").arg(timeString).arg(event.displayLabel);
            }
        } else {
            timeLabel.text = event.displayLabel;
            timeLabel.horizontalAlignment = Text.AlignHCenter
            timeLabel.wrapMode = Text.WrapAtWordBoundaryOrAnywhere
        }
    }

    function resize()
    {
        width = parent ? parent.width * sizeOfRow : 0
        x = depthInRow * width
        z = depthInRow
        height = Math.max(30, (durationInMinutes * parent.minuteHeight))
    }

    onEventChanged: {
        assingnBgColor();
        setDetails();
        resize()
    }

    Connections {
        target: parent
        onWidthChanged: resize()
    }

    Binding {
        target: infoBubble
        property: "y"
        value: (startTimeInMinutes * parent.minuteHeight)
        when: !infoBubble.isLiveEditing
    }

    Rectangle{
        id: bg
        anchors.fill: parent
        border.color: isLiveEditing ? "red" : "white"
    }

    Item {
        id: detailsItems

        property alias timeLabelHeight : timeLabel.height

        width: parent.width
        height: detailsColumn.height

        Column {
            id: detailsColumn

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: units.gu(0.5)
            }

            Label {
                id: timeLabel
                objectName: "timeLabel"
                color: "White"
                fontSize:"small"
                font.bold: true
                width: parent.width
            }

            Label {
                id: titleLabel
                objectName: "titleLabel"
                color: "White"
                fontSize: "small"
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }
    }

    Drag.active: dragArea.drag.active

    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag {
            target: isLiveEditing ? infoBubble : null
            axis: Drag.YAxis
            minimumY: flickable ? flickable.y : 0
            maximumY: flickable ? flickable.contentHeight - infoBubble.height : infoBubble.height
        }
        onReleased: {
            if (isLiveEditing) {
                isLiveEditing = false;
                infoBubble.z -= 1;
            }
            parent.Drag.drop()
        }
        onClicked: {
            if( isLiveEditing ) {
                isLiveEditing = false;
                infoBubble.z -= 1;
            } else {
                infoBubble.clicked(event);
            }
        }

        onPressAndHold: {
            isLiveEditing = true;
            infoBubble.z += 1;
        }
    }
}
