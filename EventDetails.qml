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
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Themes.Ambiance 1.0
import Ubuntu.Components.Popups 1.0
import QtOrganizer 5.0

import "Defines.js" as Defines

Page {
    id: root
    objectName: "eventDetails"

    property var event
    property var model

    anchors{
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }

    flickable: null

    title: i18n.tr("Event Details")

    Component.onCompleted: {
        showEvent(event)
    }

    Connections{
        target: pageStack
        onCurrentPageChanged:{
            if( pageStack.currentPage === root) {
                showEvent(event)
            }
        }
    }

    RemindersModel {
        id: reminderModel
    }

    function updateCollection(event) {
        var collection = model.collection( event.collectionId );
        calendarIndicator.color = collection.color
        eventInfo.color=collection.color
        // TRANSLATORS: the first parameter refers to the name of event calendar.
        calendarName.text = i18n.tr("%1 Calendar").arg( collection.name)
    }

    function updateRecurrence( event ) {
        var index = 0;
        if (event.recurrence) {
            if(event.recurrence.recurrenceRules[0] !== undefined){
                var rule =  event.recurrence.recurrenceRules[0];
                repeatLabel.text = eventUtils.getRecurrenceString(rule)
            }
        }
    }

    function updateContacts(event) {
        var attendees = event.attendees;
        contactModel.clear();
        if( attendees !== undefined ) {
            for (var j = 0 ; j < attendees.length ; ++j) {
                contactModel.append( {"name": attendees[j].name,"participationStatus": attendees[j].participationStatus }  );
            }
        }
    }

    function updateReminder(event) {
        var reminder = event.detail( Detail.VisualReminder)
        if(reminder) {
            for(var i=0; i<reminderModel.count; i++) {
                if(reminder.secondsBeforeStart === reminderModel.get(i).value) {
                    reminderHeader.subText = reminderModel.get(i).label
                }
            }
        } else {
            reminderHeader.subText = reminderModel.get(0).label
        }
    }

    function updateLocation(event) {
        if( event.location ) {
            locationLabel.text = event.location
        }
    }

    function showEvent(e) {
        var startTime = e.startDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
        var endTime = e.endDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)

        if( e.allDay ) {
            if( !e.startDateTime.isSameDay( e.endDateTime) ) {
                dateLabel.text = i18n.tr("%1 - %2 (All Day)")
                .arg( e.startDateTime.toLocaleDateString(Qt.locale(), Locale.LongFormat))
                .arg( e.endDateTime.toLocaleDateString(Qt.locale(), Locale.LongFormat))
            } else {
                dateLabel.text = i18n.tr("%1 (All Day)").arg( e.startDateTime.toLocaleDateString(Qt.locale(), Locale.LongFormat))
            }
        } else {
           dateLabel.text = e.startDateTime.toLocaleDateString(Qt.locale(), Locale.LongFormat) + ", " +startTime + " - "  + endTime;
        }

        if( e.itemType === Type.EventOccurrence ){
            var requestId = -1;
            model.onItemsFetched.connect( function(id,fetchedItems){
                if(requestId === id && fetchedItems.length > 0) {
                    internal.parentEvent = fetchedItems[0];
                    updateRecurrence(internal.parentEvent);
                    updateContacts(internal.parentEvent);
                }
            });
            requestId = model.fetchItems([e.parentId]);
        }
        // This is the event title
        if( e.displayLabel) {
            titleLabel.text = e.displayLabel;
        }

        if( e.description ) {
            descLabel.text = e.description;
        }

        updateCollection(e);

        updateContacts(e);

        updateRecurrence(e);

        updateReminder(e);

        updateLocation(e);
    }

    function showEditEventPage(event, model) {
        if(event.itemId === "qtorganizer:::") {
            //Can not edit event without proper itemid
            return;
        }

        pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"event": event, "model":model});
        pageStack.currentPage.eventAdded.connect( function(event){
            pageStack.pop();
        })
    }

    Keys.onEscapePressed: {
        pageStack.pop();
    }

    Keys.onPressed: {
        if ((event.key === Qt.Key_E) && ( event.modifiers & Qt.ControlModifier)) {
            showEditEventPage(event, model);
        }
    }

    head.actions: [
        Action {
            text: i18n.tr("Delete");
            objectName: "delete"
            iconName: "delete"
            onTriggered: {
                var dialog = PopupUtils.open(Qt.resolvedUrl("DeleteConfirmationDialog.qml"),root,{"event": event});
                dialog.deleteEvent.connect( function(eventId){
                    model.removeItem(eventId);
                    pageStack.pop();
                });
            }
        },

        Action {
            text: i18n.tr("Edit");
            objectName: "edit"
            iconName: "edit";
            onTriggered: {
                if( event.itemType === Type.EventOccurrence ) {
                    var dialog = PopupUtils.open(Qt.resolvedUrl("EditEventConfirmationDialog.qml"),root,{"event": event});
                    dialog.editEvent.connect( function(eventId){
                        if( eventId === event.parentId ) {
                            showEditEventPage(internal.parentEvent, model)
                        } else {                            
                            showEditEventPage(event, model)
                        }
                    });
                } else {
                    showEditEventPage(event, model)
                }
            }
        }
    ]

    EventUtils{
        id:eventUtils
    }

    QtObject{
        id: internal
        property var parentEvent;
    }

    Rectangle {
        id: bg
        color: "white"
        anchors.fill: parent
    }

    Scrollbar {
        flickableItem: flicable
        align: Qt.AlignTrailing
    }

    Flickable{
        id: flicable

        clip: interactive
        anchors.fill: parent
        interactive: contentHeight > height

        contentWidth: parent.width
        contentHeight: column.height + eventInfo.height + units.gu(3) /*top margin + spacing */

        Rectangle{
            id: eventInfo

            width: parent.width
            height: eventInfoList.height + units.gu(5)

            Column{
                id:eventInfoList

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: units.gu(2)
                }

                spacing: units.gu(0.5)

                Label{
                    id: titleLabel
                    objectName: "titleLabel"
                    fontSize: "x-large"
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: "white"
                }

                Label{
                    id: dateLabel
                    objectName: "dateLabel"
                    color: "white"
                    fontSize: "medium"
                    width: parent.width
                    wrapMode: Text.WordWrap
                }

                Label{
                    id: repeatLabel
                    objectName: "repeatLabel"
                    color: "white"
                    fontSize: "small"
                    width: parent.width
                    wrapMode: Text.WordWrap
                    visible: repeatLabel.text !== ""
                }

                Label{
                    id: locationLabel
                    objectName: "locationLabel"
                    color: "white"
                    fontSize: "small"
                    width: parent.width
                    wrapMode: Text.WordWrap
                    visible: locationLabel.text !== ""
                }
            }
        }

        Column{
            id: column

            spacing: units.gu(1)
            anchors{
                top: eventInfo.bottom
                right: parent.right
                left:parent.left
                margins: units.gu(2)
            }

            Row{
                width: parent.width
                spacing: units.gu(1)
                UbuntuShape{
                    id: calendarIndicator
                    width: parent.height
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label{
                    id:calendarName
                    objectName: "calendarName"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Label{
                id: descLabel
                objectName: "descriptionLabel"
                visible: text != ""
                width: parent.width
                wrapMode: Text.WordWrap
            }

            Column {
                anchors{
                    right: parent.right
                    left:parent.left
                    margins: units.gu(-2)
                }

                ListItem.Header {
                    text: i18n.tr("Guests")
                    visible: contactModel.count !== 0
                }

                //Guest Entery Model starts
                Column{
                    id: contactList
                    objectName: 'contactList'

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    ListModel {
                        id: contactModel
                    }

                    Repeater{
                        model: contactModel
                        delegate: ListItem.Standard {
                            Label {
                                text: name
                                objectName: "eventGuest%1".arg(index)
                                color: UbuntuColors.midAubergine
                                anchors {
                                    left: parent.left
                                    leftMargin: units.gu(2)
                                    verticalCenter: parent.verticalCenter
                                }
                            }

                            control: CheckBox {
                                enabled: false
                                checked: participationStatus
                            }
                        }
                    }
                }
                //Guest Entries ends

                ListItem.Subtitled {
                    id: reminderHeader
                    text: i18n.tr("Reminder")
                }
            }
        }
    }
}
