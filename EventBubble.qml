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
    property real minimumHeight: units.gu(4)

    // Event bubble style
    property alias titleText: eventTitle.text
    property alias titleColor: eventTitle.color
    property alias strikeoutTitle: eventTitle.font.strikeout
    property alias backgroundColor: bg.color
    property alias backgroundOpacity: bg.opacity
    property color borderColor: "white"

    readonly property bool isSingleLine: (infoBubble.height < (minimumHeight * 2))
    readonly property real startTimeInMinutes: event ? CanlendarCanvas.minutesSince(infoBubble.anchorDate, event.startDateTime) : 0.0
    readonly property real endTimeInMinutes: event ? CanlendarCanvas.minutesSince(infoBubble.anchorDate, event.endDateTime) : 0.0
    readonly property real durationInMinutes: endTimeInMinutes - startTimeInMinutes

    signal clicked(var event);


    // keep color up-to-date
    Connections {
        target: model
        ignoreUnknownSignals: true
        onCollectionsChanged: updateEventBubbleStyle()
    }

    function updateEventBubbleStyle() {
        if (model && event ) {
            var collection = model.collection( event.collectionId );
            var now = new Date();
            var endDateTime = event.endDateTime
            if (!endDateTime || isNaN(endDateTime.getTime())) {
                endDateTime = event.startDateTime;
            }

            updateTitle()

            //Accepted events: Solid collection color with white text.
            infoBubble.backgroundColor = collection.color
            infoBubble.backgroundOpacity = 1
            infoBubble.titleColor = "white";
            infoBubble.strikeoutTitle = false;
            infoBubble.borderColor = "white";

            if( endDateTime >= now) {
                var ownersStatus = getOwnersStatus(collection);
                if (ownersStatus === EventAttendee.StatusDeclined) {
                    // Declined events: As per accepted events with strike-through text.
                    infoBubble.strikeoutTitle = true;

                } else if (ownersStatus === EventAttendee.StatusTentative) {
                    //Maybe events: As per accepted events with ‘(?)’ placed before Event Title.
                    infoBubble.titleText = "(?) " + infoBubble.titleText

                } else if (ownersStatus !== EventAttendee.StatusAccepted) {
                    //Unresponded events: Accepted event colours inverted (i.e. collection color text/ outline on white background).
                    infoBubble.backgroundColor = "white"
                    infoBubble.titleColor = collection.color;
                    infoBubble.borderColor = collection.color;

                }
            } else {
                // Past events: As per accepted events, but at 60% transparency.
                infoBubble.backgroundOpacity = 0.4
            }
        }
    }

    function getOwnersStatus(collection) {
        // Use details method to get attendees list instead of "attendees" property
        // since a binding issue was returning an empty attendees list for some use cases
        var attendees = event.details(Detail.EventAttendee);
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

        return EventAttendee.StatusAccepted;
    }

    function updateTitle() {
        if(event === null || event === undefined) {
            return;
        }

        var startTime = Qt.formatTime(event.startDateTime, "hh:mm")
        var endTime = Qt.formatTime(event.endDateTime, "hh:mm")

        if (type === wideType) {
            // TRANSLATORS: the first argument (%1) refers to a start time for an event,
            // while the second one (%2) refers to the end time
            var timeString = i18n.tr("%1 - %2").arg(startTime).arg(endTime)

            //there is space for two lines
            if (infoBubble.isSingleLine) {
                infoBubble.titleText =  ("%1 %2").arg(timeString).arg(event.displayLabel);
            } else {
                infoBubble.titleText =  ("%1\n%2").arg(timeString).arg(event.displayLabel);
            }
        } else {
            infoBubble.titleText = event.displayLabel
        }
    }

    function resize()
    {
        width = parent ? parent.width * sizeOfRow : 0
        x = depthInRow * width
        z = depthInRow
        // avoid events to be draw too small, use the font height for timeLabel plus a gu(1) as margin
        height = Math.max(minimumHeight, durationInMinutes * parent.minuteHeight)
    }

    onIsSingleLineChanged: updateEventBubbleStyle()
    onEventChanged: {
        updateEventBubbleStyle()
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
        border.color: isLiveEditing ? "red" : infoBubble.borderColor
    }

    Label {
        id: eventTitle

        anchors {
            fill: parent
            margins: units.gu(0.5)
        }
        clip: true
        fontSize: "small"
        font.bold: true
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
            if (event && model && model.collectionIsReadOnlyFromId(event.collectionId)) {
                console.debug("Read-only event can not be dragged")
            } else {
                isLiveEditing = true;
                infoBubble.z += 1;
            }
        }
    }
}
