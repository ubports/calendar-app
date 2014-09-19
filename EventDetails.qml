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

    property var event;
    property string headerColor :"black"
    property string detailColor :"grey"
    property var model;

    anchors{
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }

    flickable: null

    title: i18n.tr("Event Details")

    Component.onCompleted: {

        showEvent(event);
    }

    Connections{
        target: pageStack
        onCurrentPageChanged:{
            if( pageStack.currentPage === root) {
                showEvent(event);
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
        calendarName.text = i18n.tr("%1 Calendar").arg( collection.name)
    }

    function updateRecurrence( event ) {
        var index = 0;
        if(event.recurrence) {
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
            for( var j = 0 ; j < attendees.length ; ++j ) {
                contactModel.append( {"name": attendees[j].name,"participationStatus": attendees[j].participationStatus }  );
            }
        }
    }

    function updateReminder(event) {
        var reminder = event.detail( Detail.VisualReminder)
        if( reminder ) {
            for(var i=0; i<reminderModel.count; i++) {
                if(reminder.secondsBeforeStart === reminderModel.get(i).value)
                    reminderHeader.text = reminderModel.get(i).label
            }
        } else {
            reminderHeader.text = reminderModel.get(0).label
        }
    }

    function updateLocation(event) {
        if( event.location ) {
            locationLabel.text = i18n.tr("%1").arg(event.location)
        }
    }

    function showEvent(e) {
        // TRANSLATORS: this is a time formatting string,
        // see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details for valid expressions
        var timeFormat = i18n.tr("hh:mm");
        // TRANSLATORS: this is a time & Date formatting string,
        //see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details
        var dateFormat = i18n.tr("dddd, MMMM dd")
        var startTime = e.startDateTime.toLocaleTimeString(Qt.locale(), timeFormat);
        var endTime = e.endDateTime.toLocaleTimeString(Qt.locale(), timeFormat);
        dateLabel.text = e.allDay === true ? i18n.tr("%1 (All Day)").arg( e.startDateTime.toLocaleString(Qt.locale(),dateFormat))
                                           :e.startDateTime.toLocaleString(Qt.locale(),dateFormat) + ", " +startTime + "-"  + endTime;

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

    Keys.onEscapePressed: {
        pageStack.pop();
    }

    Keys.onPressed: {
        if ((event.key === Qt.Key_E) && ( event.modifiers & Qt.ControlModifier)) {
            pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"event": root.event});
        }
    }

    tools: ToolbarItems {
        ToolbarButton {
            action:Action {
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
            }
        }

        ToolbarButton {
            action:Action {
                text: i18n.tr("Edit");
                objectName: "edit"
                iconName: "edit";
                onTriggered: {
                    if( event.itemType === Type.EventOccurrence ) {
                        var dialog = PopupUtils.open(Qt.resolvedUrl("EditEventConfirmationDialog.qml"),root,{"event": event});
                        dialog.editEvent.connect( function(eventId){
                            if( eventId === event.parentId ) {
                                pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"event":internal.parentEvent,"model":model});
                            } else {
                                pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"event":event,"model":model});
                            }
                        });
                    } else {
                        pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"event":event,"model":model});
                    }
                }
            }
        }
    }
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
        width: parent.width
        height: parent.height
        clip: true

        contentHeight: column.height + units.gu(3) /*top margin + spacing */
        contentWidth: parent.width

        interactive: contentHeight > height

        Rectangle{
            id: eventInfo
            width:parent.width
            height: eventInfoList.height + units.gu(5)

            Column{
                id:eventInfoList
                width: parent.width
                spacing: units.gu(0.5)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                anchors.top: parent.top
                anchors.topMargin: units.gu(2)
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
                    objectName: "titleLabel"
                    fontSize: "medium"
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: "white"
                    text:"Monday, September 22, 4:00 - 5:00 PM"
                }
                Label{
                    id: repeatLabel
                    objectName: "titleLabel"
                    fontSize: "small"
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: "white"
                }
                Label{
                    id: locationLabel
                    objectName: "titleLabel"
                    fontSize: "small"
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: "white"
                }
            }

        }
        Column{
            id: column
            spacing: units.gu(1)
            anchors{
                top:parent.top
                topMargin: units.gu(2) + eventInfo.height
                right: parent.right
                rightMargin: units.gu(2)
                left:parent.left
                leftMargin: units.gu(2)
            }
            Row{
                width: parent.width
                spacing: units.gu(1)
                UbuntuShape{
                    id: calendarIndicator
                    width: parent.height
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label{
                    id:calendarName
                    objectName: "calendarName"
                    anchors.verticalCenter: parent.verticalCenter
                    color: headerColor
                }
            }
            Label{
                id: descLabel
                objectName: "descriptionLabel"
                wrapMode: Text.WordWrap
                fontSize: "medium"
                width: parent.width
                color: detailColor
            }
            ListItem.ThinDivider{}
            Label{
                text: i18n.tr("Guests");
                fontSize: "medium"
                color: headerColor
            }
            Label {
                id:noGuests
                color: detailColor
                text: i18n.tr("No Guests added")
                visible:contactModel.count == 0

            }
            //Guest Entery Model starts
            Column{
                id: contactList
                objectName: 'contactList'
                spacing: units.gu(1)
                width: parent.width
                clip: true
                ListModel {
                    id: contactModel
                }
                Repeater{
                    model: contactModel
                    delegate: Row{
                        spacing: units.gu(1)
                        CheckBox{
                            checked: participationStatus
                            enabled: false
                        }
                        Label {
                            text:name
                            anchors.verticalCenter:  parent.verticalCenter
                            color: detailColor
                        }
                    }
                }


            }
            //Guest Entries ends
            ListItem.ThinDivider{}
            Label{
                text: i18n.tr("Reminder");
                fontSize: "medium"
                color: headerColor
            }
            Label {
                id:reminderHeader
                color: detailColor
            }
        }
    }
}
