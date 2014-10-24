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
import QtOrganizer 5.0

Item{
    id: infoBubble

    property var event;
    property var model;

    property int type: narrowType
    property int wideType: 1;
    property int narrowType: 2;

    property int depthInRow: 0;
    property int sizeOfRow:0

    property Flickable flickable;

    readonly property int minimumHeight: type == wideType
                                         ? eventDetails.item.timeLabelHeight + /*top-bottom margin*/ units.gu(2)
                                         : units.gu(2)

    signal clicked(var event);

    UbuntuShape{
        id: bg
        anchors.fill: parent
    }

    function resize() {
        var offset = parent.width/sizeOfRow;
        x = (depthInRow) * offset;
        width = parent.width - x;
    }

    Connections{
        target: parent
        onWidthChanged:{
            resize();
        }
    }

    onEventChanged: {
        resize();
        assingnBgColor();
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

    function layoutBubbleDetails() {
        if( !flickable || flickable === undefined ) {
            return;
        }

        if( infoBubble.y < flickable.contentY && infoBubble.height > flickable.height) {
            var y = (flickable.contentY - infoBubble.y) * 1.2;
            if( ( y + eventDetails.item.height + units.gu(2)) > infoBubble.height) {
                y = infoBubble.height - eventDetails.item.height - units.gu(2);
            }
            eventDetails.item.y = y;
        }
    }

    Loader {
        id:eventDetails
        sourceComponent: type == wideType ? detailsComponent : undefined
    }

    Component {
        id:detailsComponent

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

                Label {
                    id: descriptionLabel
                    color: "White"
                    fontSize: "x-small"
                    width: parent.width
                }
            }

            onHeightChanged: {
                layoutBubbleDetails();
            }

            Connections {
                target: infoBubble
                onFlickableChanged: {
                    if (flickable && infoBubble.height > flickable.height) {
                        flickable.onContentYChanged.connect(layoutBubbleDetails);
                    }
                }

                onHeightChanged: {
                    if(flickable && infoBubble.height > flickable.height) {
                        flickable.onContentYChanged.connect(layoutBubbleDetails);
                    }
                }

                onEventChanged: {
                    setDetails();
                }
            }

            function setDetails() {
                if(event === null || event === undefined) {
                    return;
                }

                var startTime = event.startDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                var endTime = event.endDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)

                if (type === wideType) {
                    timeLabel.text = ""
                    titleLabel.text = ""
                    descriptionLabel.text = ""
                    //height is less then set only event title
                    if( infoBubble.height > minimumHeight ) {
                        //on wide type show all details
                        if( infoBubble.height > titleLabel.y + titleLabel.height + units.gu(1)) {
                            // TRANSLATORS: the first argument (%1) refers to a start time for an event,
                            // while the second one (%2) refers to the end time
                            var timeString = i18n.tr("%1 - %2").arg(startTime).arg(endTime)
                            timeLabel.text = timeString
                            titleLabel.text = event.displayLabel
                        } else if ( event.displayLabel ) {
                            // TRANSLATORS: the first argument (%1) refers to a start time for an event,
                            // while the second one (%2) refers to title of event
                            timeLabel.text = i18n.tr("%1 - %2").arg(startTime).arg(event.displayLabel);
                        }

                        if (event.description) {
                            descriptionLabel.text = event.description
                            //descriptionText = event.description
                            //If content is too much don't display.
                            if (infoBubble.height < descriptionLabel.y + descriptionLabel.height + units.gu(1)) {
                                descriptionLabel.text = ""
                            }
                        }

                        layoutBubbleDetails();
                    } else if (event.displayLabel){
                        timeLabel.text = event.displayLabel;
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            infoBubble.clicked(event);
        }
    }
}
