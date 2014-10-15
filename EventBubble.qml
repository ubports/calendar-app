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
        setDetails();
    }


    Component.onCompleted: {
        setDetails();
    }


    function setDetails() {
        if(event === null || event === undefined) {
            return;
        }

        var startTime = event.startDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
        var endTime = event.endDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)

        // TRANSLATORS: the first argument (%1) refers to a start time for an event,
        // while the second one (%2) refers to the end time
        var timeString = i18n.tr("%1 - %2").arg(startTime).arg(endTime)

        if (type === wideType) {
            eventDetails.item.timeLableText= ""
            eventDetails.item.titleLabelText = ""
            eventDetails.item.descriptionText.text = ""
            //height is less then set only event title
            if( height > minimumHeight ) {
                //on wide type show all details
                eventDetails.item.timeLableText = timeString
                if (event.displayLabel)
                    eventDetails.item.titleLabelText = event.displayLabel;
                if (event.description)
                {
                    eventDetails.item.descriptionText= event.description
                    //If content is too much don't display.
                    if (height < descriptionLabel.height + descriptionLabel.y) {
                        eventDetails.item.descriptionText.text = ""
                    }
                }
                layoutBubbleDetails();

            } else {
                if (event.displayLabel)
                    eventDetails.item.timeLableText = event.displayLabel;
            }
        }
        if (model) {
            var collection = model.collection( event.collectionId );
            bg.color = collection.color
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

    Connections {
        target: eventDetails.item
        //on dayview, flickable never changed so when height changes we setup connection
        onHeightChanged: {
            if( flickable && height > flickable.height && type == wideType) {
                layoutBubbleDetails();
                flickable.onContentYChanged.connect(layoutBubbleDetails);
            }
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
            property alias timeLableText: timeLabel.text
            property alias titleLabelText: titleLabel.text
            property alias descriptionText: descriptionLabel.text

            width: parent.width
            height: detailsColumn.height

            Column {
                id: detailsColumn

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: units.gu(1)
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
                    visible: type == wideType
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
