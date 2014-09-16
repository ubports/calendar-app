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

import QtQuick 2.2
import QtOrganizer 5.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Themes.Ambiance 1.0
import Ubuntu.Components.Pickers 1.0
import QtOrganizer 5.0
import "Defines.js" as Defines

Page {
    id: root
    objectName: 'newEventPage'

    property var date;

    property var event:null;
    property var rule :null;
    property var model;

    property var startDate;
    property var endDate;

    property alias scrollY: flickable.contentY
    property bool isEdit: false

    onStartDateChanged: {
        startDateInput.text = startDate.toLocaleDateString();
        startTimeInput.text = Qt.formatTime(startDate);
        adjustEndDateToStartDate()
    }

    onEndDateChanged: {
        endDateInput.text = endDate.toLocaleDateString();
        endTimeInput.text = Qt.formatTime(endDate);
    }

    head.actions: [
        Action {
            iconName: "ok"
            objectName: "save"
            text: i18n.tr("Save")
            enabled: !!titleEdit.text.trim()
            onTriggered: saveToQtPim();
        }
    ]

    Component.onCompleted: {
        //If current date is setted by an argument we don't have to change it.
        if(typeof(date) === 'undefined'){
            date = new Date();
            var newDate = new Date();
            date.setHours(newDate.getHours(), newDate.getMinutes());
        }

        // If startDate is setted by argument we have to not change it
        //Set the nearest current time.
        if (typeof(startDate) === 'undefined')
            startDate = new Date(root.roundDate(date))

        // If endDate is setted by argument we have to not change it
        if (typeof(endDate) === 'undefined') {
            endDate = new Date(root.roundDate(date))
            endDate.setMinutes(endDate.getMinutes() + 30)
            endTimeInput.text = Qt.formatDateTime(endDate, "hh:mm");
        }

        if(event === null){
            isEdit = false;
            addEvent();
        }

        else{
            isEdit = true;
            editEvent(event);
        }
    }

    function selectCalendar(collectionId) {
        var index = 0;
        for(var i=0; i < calendarsOption.model.length; ++i){
            if(calendarsOption.model[i].collectionId === collectionId){
                index = i;
                break;
            }
        }
        calendarsOption.selectedIndex = index
    }

    //Data for Add events
    function addEvent() {
        event = Qt.createQmlObject("import QtOrganizer 5.0; Event { }", Qt.application,"NewEvent.qml");
        //Create fresh Recurrence Object.
        rule = Qt.createQmlObject("import QtOrganizer 5.0; RecurrenceRule {}", event.recurrence,"EventRepetition.qml");
        selectCalendar(model.defaultCollection().collectionId);
    }

    //Editing Event
    function editEvent(e) {
        //If there is a ReccruenceRule use that , else create fresh Recurrence Object.
        rule = (e.recurrence.recurrenceRules[0] === undefined || e.recurrence.recurrenceRules[0] === null) ?
                    Qt.createQmlObject("import QtOrganizer 5.0; RecurrenceRule {}", event.recurrence,"EventRepetition.qml")
                  : e.recurrence.recurrenceRules[0];

        startDate =new Date(e.startDateTime);
        endDate = new Date(e.endDateTime);

        if(e.displayLabel) {
            titleEdit.text = e.displayLabel;
        }
        if(e.allDay){
            allDayEventCheckbox.checked =true;
        }

        if(e.location) {
            locationEdit.text = e.location;
        }

        if( e.description ) {
            messageEdit.text = e.description;
        }

        allDayEventCheckbox.checked = e.allDay;
        var index = 0;

        if( e.itemType === Type.Event ) {
            if(e.attendees){
                for( var j = 0 ; j < e.attendees.length ; ++j ) {
                    contactList.array.push(e.attendees[j]);
                    contactModel.append(e.attendees[j]);
                }
            }
        }
        var reminder = e.detail( Detail.VisualReminder);
        if( reminder ) {
            visualReminder.secondsBeforeStart = reminder.secondsBeforeStart;

        }
        selectCalendar(e.collectionId);
    }
    //Save the new or Existing event
    function saveToQtPim() {
        internal.clearFocus()
        if ( startDate >= endDate && !allDayEventCheckbox.checked) {
            PopupUtils.open(errorDlgComponent,root,{"text":i18n.tr("End time can't be before start time")});
        } else {
            event.startDateTime = startDate;
            event.endDateTime = endDate;
            event.displayLabel = titleEdit.text;
            event.description = messageEdit.text;
            event.location = locationEdit.text

            event.allDay = allDayEventCheckbox.checked;

            if( event.itemType === Type.Event ) {
                event.attendees = []; // if Edit remove all attendes & add them again if any
                var contacts = [];
                for(var i=0; i < contactList.array.length ; ++i) {
                    var contact = contactList.array[i]
                    contacts.push(contact);
                }
                event.attendees = contacts;
            }
            //Set the Rule object to an event
            if(rule !== null && rule !== undefined)
                event.recurrence.recurrenceRules= [rule]
            //remove old reminder value
            var oldVisualReminder = event.detail(Detail.VisualReminder);
            if(oldVisualReminder) {
                event.removeDetail(oldVisualReminder);
            }

            var oldAudibleReminder = event.detail(Detail.AudibleReminder);
            if(oldAudibleReminder) {
                event.removeDetail(oldAudibleReminder);
            }
            event.setDetail(visualReminder);
            event.setDetail(audibleReminder);

            event.collectionId = calendarsOption.model[calendarsOption.selectedIndex].collectionId;
            model.saveItem(event);
            pageStack.pop();
        }
    }

    VisualReminder{
        id:visualReminder
    }
    AudibleReminder{
        id:audibleReminder
    }

    function getDaysOfWeek(){
        var daysOfWeek = [];
        switch(recurrenceOption.selectedIndex){
        case 2:
            daysOfWeek = Qt.locale().weekDays;
            break;
        case 3:
            daysOfWeek = [Qt.Monday,Qt.Wednesday,Qt.Friday];
            break;
        case 4:
            daysOfWeek = [Qt.Tuesday,Qt.Thursday];
            break;
        case 5:
            daysOfWeek = internal.weekDays.length === 0 ? [date.getDay()] : internal.weekDays;
            break;
        }
        return daysOfWeek;
    }

    function openDatePicker (element, caller, callerProperty, mode) {
        element.highlighted = true;
        var picker = PickerPanel.openDatePicker(caller, callerProperty, mode);
        if (!picker) return;
        picker.closed.connect(function () {
            element.highlighted = false;
        });
    }

    // Calucate default hour and minute for start and end time on event
    function roundDate(date) {
        var tempDate = new Date(date)
        if(tempDate.getMinutes() < 30)
            return tempDate.setMinutes(30)
        tempDate.setMinutes(0)
        return tempDate.setHours(tempDate.getHours() + 1)
    }

    function adjustEndDateToStartDate() {
        // set time forward to one hour
        var time_forward = 3600000;
        endDate = new Date( startDate.getTime() + time_forward );
    }

    ScrollAnimation{id:scrollAnimation}

    function scrollOnExpand(Self,Container,Target,Margin,Visible)
    {
        // Self is needed for "onXxxxxChange" triggers. OnExpansionCompleted however can just write "true".
        // Container is the item which encapsulates everything, such as a column.
        // Target is the Flickable id you wish to scroll
        // Margin is the space between the bottom of the screen and the bottom of the item you are scrolling to.
        // Visible is needed if there is anything that appears under the item you are scrolling to.
        if (Self === false){return}
        var v = units.gu(Margin)
        for (var i in Visible){if(Visible[i].visible === true){v+=Visible[i].height};}

        scrollAnimation.target = Target
        scrollAnimation.to = Container.height-height - v
        scrollAnimation.start()
    }

    width: parent.width
    height: parent.height

    title: isEdit ? i18n.tr("Edit Event"):i18n.tr("New Event")

    Keys.onEscapePressed: {
        pageStack.pop();
    }

    Component{
        id: errorDlgComponent
        Dialog {
            id: dialog
            title: i18n.tr("Error")
            Button {
                text: i18n.tr("OK")
                onClicked: PopupUtils.close(dialog)
            }
        }
    }

    EventUtils{
        id:eventUtils
    }

    Flickable{
        id: flickable

        property var activeItem: null

        function makeMeVisible(item) {
            if (!item) {
                return
            }

            activeItem = item
            var position = flickable.contentItem.mapFromItem(item, 0, 0);

            // check if the item is already visible
            var bottomY = flickable.contentY + flickable.height
            var itemBottom = position.y + item.height
            if (position.y >= flickable.contentY && itemBottom <= bottomY) {
                return;
            }

            // if it is not, try to scroll and make it visible
            var targetY = position.y + item.height - flickable.height
            if (targetY >= 0 && position.y) {
                flickable.contentY = targetY;
            } else if (position.y < flickable.contentY) {
                // if it is hidden at the top, also show it
                flickable.contentY = position.y;
            }
            flickable.returnToBounds()
        }

        anchors.fill: parent
        contentWidth: width
        contentHeight: column.height + units.gu(10)

        Column {
            id: column

            width: parent.width

            ListItem.Header {
                text: i18n.tr("From")
            }

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }

                height: startDateInput.height

                NewEventEntryField{
                    id: startDateInput
                    objectName: "startDateInput"

                    text: ""
                    anchors.left: parent.left
                    width: allDayEventCheckbox.checked ? parent.width : 4 * parent.width / 5

                    MouseArea{
                        anchors.fill: parent
                        onClicked: openDatePicker(startDateInput, root, "startDate", "Years|Months|Days")
                    }
                }

                NewEventEntryField{
                    id: startTimeInput
                    objectName: "startTimeInput"

                    text: ""
                    anchors.right: parent.right
                    width: parent.width / 5
                    visible: !allDayEventCheckbox.checked

                    MouseArea{
                        anchors.fill: parent
                        onClicked: openDatePicker(startTimeInput, root, "startDate", "Hours|Minutes")
                    }
                }
            }

            ListItem.Header {
                text: i18n.tr("To")
                visible: !allDayEventCheckbox.checked
            }

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }

                height: endDateInput.height
                visible: !allDayEventCheckbox.checked

                NewEventEntryField{
                    id: endDateInput
                    objectName: "endDateInput"

                    text: ""
                    anchors.left: parent.left
                    width: 4 * parent.width / 5

                    MouseArea{
                        anchors.fill: parent
                        onClicked: openDatePicker(endDateInput, root, "endDate", "Years|Months|Days")
                    }
                }

                NewEventEntryField{
                    id: endTimeInput
                    objectName: "endTimeInput"

                    text: ""
                    width: parent.width / 5
                    anchors.right: parent.right

                    MouseArea{
                        anchors.fill: parent
                        onClicked: openDatePicker(endTimeInput, root, "endDate", "Hours|Minutes")
                    }
                }
            }

            ListItem.Standard {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: units.gu(-1)
                }

                text: "All Day Event"
                showDivider: false
                control: CheckBox {
                    id: allDayEventCheckbox
                    checked: false
                }
            }

            ListItem.ThinDivider {}

            Column {
                width: parent.width
                spacing: units.gu(1)

                ListItem.Header{
                    text: i18n.tr("Event Details")
                }

                TextField {
                    id: titleEdit
                    objectName: "newEventName"

                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    placeholderText: i18n.tr("Event Name")
                }

                TextArea{
                    id: messageEdit
                    objectName: "eventDescriptionInput"

                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    placeholderText: i18n.tr("Description")
                }

                TextField {
                    id: locationEdit
                    objectName: "eventLocationInput"

                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    placeholderText: i18n.tr("Location")
                }
            }

            Column {
                width: parent.width
                spacing: units.gu(1)

                ListItem.Header {
                    text: i18n.tr("Calendar")
                }

                OptionSelector{
                    id: calendarsOption
                    objectName: "calendarsOption"

                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    containerHeight: itemHeight * 4
                    model: root.model.getCollections();

                    delegate: OptionSelectorDelegate{
                        text: modelData.name

                        UbuntuShape{
                            id: calColor
                            width: height
                            height: parent.height - units.gu(2)
                            color: modelData.color
                            anchors.right: parent.right
                            anchors.rightMargin: units.gu(2)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    onExpandedChanged: Qt.inputMethod.hide();
                }
            }

            Column {
                width: parent.width
                spacing: units.gu(1)

                ListItem.Header {
                    text: i18n.tr("Guests")
                }

                Button{
                    text: i18n.tr("Add Guest")
                    objectName: "addGuestButton"

                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    onClicked: {
                        var popup = PopupUtils.open(Qt.resolvedUrl("ContactChoicePopup.qml"), contactList);
                        popup.contactSelected.connect( function(contact) {
                            var t = internal.contactToAttendee(contact);
                            if( !internal.isContactAlreadyAdded(contact) ) {
                                contactModel.append(t);
                                contactList.array.push(t);
                            }
                        });
                    }
                }

                UbuntuShape {
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    height: contactList.height

                    Column{
                        id: contactList
                        objectName: "guestList"

                        spacing: units.gu(1)
                        width: parent.width
                        clip: true

                        property var array: []

                        ListModel{
                            id: contactModel
                        }

                        Repeater{
                            model: contactModel
                            delegate: ListItem.Standard {
                                objectName: "eventGuest%1".arg(index)
                                height: units.gu(4)
                                text: name
                            }
                        }
                    }
                }

                ListItem.ThinDivider {}
            }

            ListItem.Subtitled{
                id:thisHappens
                objectName :"thisHappens"

                anchors {
                    left: parent.left
                    leftMargin: units.gu(-1)
                }

                showDivider: false
                progression: true
                visible: event.itemType === Type.Event
                text: i18n.tr("This Happens")
                subText: eventUtils.getRecurrenceString(rule)
                onClicked: pageStack.push(Qt.resolvedUrl("EventRepetition.qml"),{"rule": rule,"date":date,"isEdit":isEdit});
            }

            ListItem.ThinDivider {}

            ListItem.Subtitled{
                id:eventReminder
                objectName  : "eventReminder"

                anchors{
                    left:parent.left
                    leftMargin: units.gu(-1)
                }
                showDivider: false
                progression: true
                text: i18n.tr("Reminder")

                RemindersModel {
                    id: reminderModel
                }

                subText:{
                    for(var i=0; i<reminderModel.count; i++) {
                        if(visualReminder.secondsBeforeStart === reminderModel.get(i).value)
                            return reminderModel.get(i).label
                    }
                }

                onClicked: pageStack.push(Qt.resolvedUrl("EventReminder.qml"),
                                          {"visualReminder": visualReminder,
                                              "audibleReminder": audibleReminder,
                                              "reminderModel": reminderModel,
                                              "eventTitle": titleEdit.text})
            }
        }
    }
    // used to keep the field visible when the keyboard appear or dismiss
    KeyboardRectangle {
        id: keyboard

        onHeightChanged: {
            if (flickable.activeItem) {
                flickable.makeMeVisible(flickable.activeItem)
            }
        }
    }

    QtObject {
        id: internal
        function clearFocus() {
            Qt.inputMethod.hide()
            titleEdit.focus = false
            locationEdit.focus = false
            startDateInput.focus = false
            startTimeInput.focus = false
            endDateInput.focus = false
            endTimeInput.focus = false
            messageEdit.focus = false
        }

        function isContactAlreadyAdded(contact) {
            for(var i=0; i < contactList.array.length ; ++i) {
                var attendee = contactList.array[i];
                if( attendee.attendeeId === contact.contactId) {
                    return true;
                }
            }
            return false;
        }

        function contactToAttendee(contact) {
            var attendee = Qt.createQmlObject("import QtOrganizer 5.0; EventAttendee{}", event, "NewEvent.qml");
            attendee.name = contact.displayLabel.label
            attendee.emailAddress = contact.email.emailAddress;
            attendee.attendeeId = contact.contactId;
            return attendee;
        }
    }
}
