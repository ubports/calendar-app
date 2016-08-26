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
import QtOrganizer 5.0
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems
import Ubuntu.Components.Themes.Ambiance 1.3
import Ubuntu.Components.Pickers 1.3
import QtOrganizer 5.0
import "Defines.js" as Defines
import "dateExt.js" as DateExt

Page {
    id: root
    objectName: 'newEventPage'

    // WORKAROUND: allow us to push pages over bottom edge element
    property var bottomEdgePageStack: null

    property var date;
    property alias allDay: allDayEventCheckbox.checked
    property int eventSize: -1

    property var event:null;
    property var rule :null;
    property var model:null;

    property alias startDate: startDateTimeInput.dateTime
    property alias endDate: endDateTimeInput.dateTime
    property alias reminderValue: eventReminder.reminderValue

    property alias scrollY: flickable.contentY
    property bool isEdit: false

    readonly property int millisecsInADay: 86400000
    readonly property int millisecsInAnHour: 3600000

    signal eventSaved(var event);
    signal eventDeleted(var event);
    signal canceled()

    Component.onCompleted: {
        setDate(root.date)

        if (event === undefined) {
            return
        } else if(event === null){
            isEdit = false;
            addEvent();
        } else{
            isEdit = true;
            editEvent(event);
        }
    }

    function cancel()
    {
        if (pageStack)
            pageStack.pop();
        root.canceled()
    }

    function updateEventInfo(date, allDay) {
        selectCalendar(model.getDefaultCollection().collectionId);
        updateEventDate(date, allDay)
    }

    function updateEventDate(date, allDay) {
        setDate(date)
        root.allDay = allDay
    }

    function setDate(date) {
        if ((typeof(date) === 'undefined') || (date === null)) {
            date = new Date();
        }

        if(date.getHours() === 0 && date.getMinutes() === 0)  {
            var newDate = new Date();
            date.setHours(newDate.getHours(), newDate.getMinutes());
        }

        startDate = new Date(root.roundDate(date))
        var enDateValue = new Date(root.roundDate(date))
        endDate = enDateValue.addMinutes(60)
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
        internal.collectionId = collectionId;
    }

    //Data for Add events
    function addEvent() {
        event = Qt.createQmlObject("import QtOrganizer 5.0; Event { }", Qt.application,"NewEvent.qml");
    }

    //Editing Event
    function editEvent(e) {
        //If there is a ReccruenceRule use that , else create fresh Recurrence Object.
        var isOcurrence = ((event.itemType === Type.EventOccurrence) || (event.itemType === Type.TodoOccurrence))
        if(!isOcurrence && e.recurrence.recurrenceRules[0] !== undefined
                && e.recurrence.recurrenceRules[0] !== null){
            rule =  e.recurrence.recurrenceRules[0];
        }

        startDate =new Date(e.startDateTime);

        if(e.displayLabel) {
            titleEdit.text = e.displayLabel;
        }

        allDayEventCheckbox.checked = e.allDay;

        var eventEndDate = e.endDateTime
        if (!eventEndDate || isNaN(eventEndDate.getTime()))
            eventEndDate = new Date(startDate)

        if (e.allDay) {
            allDayEventCheckbox.checked = true
            endDate = new Date(eventEndDate).addDays(-1);
            eventSize = DateExt.daysBetween(startDate, eventEndDate) * root.millisecsInADay
        } else {
            endDate = eventEndDate
            eventSize = (eventEndDate.getTime() - startDate.getTime())
        }

        if(e.location) {
            locationEdit.text = e.location;
        }

        if( e.description ) {
            messageEdit.text = e.description;
        }

        var index = 0;

        // Use details method to get attendees list instead of "attendees" property
        // since a binding issue was returning an empty attendees list for some use cases
        var attendees = e.details(Detail.EventAttendee);
        if (attendees){
            for( var j = 0 ; j < attendees.length ; ++j ) {
                contactModel.append({"contact": attendees[j]});
            }
        }

        var reminder = e.detail(Detail.VisualReminder)
        // fallback to audible
        if (!reminder)
            reminder = e.detail(Detail.AudibleReminder)

        if (reminder) {
            root.reminderValue = reminder.secondsBeforeStart
        } else {
            root.reminderValue = -1
        }
        selectCalendar(e.collectionId);
    }

    function createAttendee(contact)
    {
        var attendee = Qt.createQmlObject("import QtOrganizer 5.0; EventAttendee { }", Qt.application,"NewEvent.qml")
        attendee.attendeeId = contact.attendeeId
        attendee.emailAddress = contact.emailAddress
        attendee.name = contact.name
        attendee.participationRole = EventAttendee.RoleOptionalParticipant
        attendee.participationStatus = EventAttendee.StatusUnknown
        return attendee
    }

    //Save the new or Existing event
    function saveToQtPim() {
        internal.clearFocus()
        if ( startDate > endDate && !allDayEventCheckbox.checked) {
            PopupUtils.open(errorDlgComponent,root,{"text":i18n.tr("End time can't be before start time")});
        } else {
            var newCollection = calendarsOption.model[calendarsOption.selectedIndex].collectionId;
            if( internal.collectionId !== newCollection ){
                //collection change to event is not suported
                //to change collection we create new event with same data with different collection
                //and remove old event
                var eventId = event.itemId;
                model.removeItem(event.itemId)
                event = Qt.createQmlObject("import QtOrganizer 5.0; Event {}", Qt.application,"NewEvent.qml");
            }

            event.allDay = allDayEventCheckbox.checked;
            if (event.allDay){
                event.startDateTime = new Date(startDate).midnight()
                event.endDateTime = new Date(endDate).addDays(1).midnight()
            } else {
                event.startDateTime = startDate;
                event.endDateTime = endDate;
            }

            event.displayLabel = titleEdit.text;
            event.description = messageEdit.text;
            event.location = locationEdit.text

            if ([Type.Event, Type.EventOccurrence].indexOf(event.itemType) != -1) {
                var oldAttendee = event.details(Detail.EventAttendee)
                var newAttendee = []
                for(var i=0; i < contactModel.count ; ++i) {
                    var contact = contactModel.get(i).contact
                    if (contact) {
                        newAttendee.push(contact)
                    }
                }

                // look for removed contacts
                for(var o=0; o < oldAttendee.length; ++o) {
                    var found = false
                    var old = oldAttendee[o]
                    for (var n=0; n < newAttendee.length; ++n) {
                        var new_ = newAttendee[n]
                        if (old.attendeeId == new_.attendeeId) {
                            found = true
                            break
                        }
                    }
                    if (!found) {
                        event.removeDetail(old)
                    }
                }

                // update list
                oldAttendee = event.details(Detail.EventAttendee)

                // look for new contacts
                for(var n=0; n < newAttendee.length; ++n) {
                    var found = false
                    var new_ = newAttendee[n]
                    for(var o=0; o < oldAttendee.length; ++o) {
                        var old = oldAttendee[o]
                        if (old.attendeeId == new_.attendeeId) {
                            found = true
                            break;
                        }
                    }

                    if (!found) {
                        var attendee = createAttendee(contact)
                        event.setDetail(attendee)
                    }
                }
            }

            //Set the Rule object to an event
            var isOcurrence = ((event.itemType === Type.EventOccurrence) || (event.itemType === Type.TodoOccurrence))
            if (!isOcurrence) {
                if(rule !== null && rule !== undefined) {
                    // update monthly rule with final event day
                    // we need to do it here to make sure that the day is the same day as the event startDate
                    if (rule.frequency === RecurrenceRule.Monthly) {
                        rule.daysOfMonth = [event.startDateTime.getDate()]
                    }
                    event.recurrence.recurrenceRules = [rule]
                } else {
                    event.recurrence.recurrenceRules = [];
                }
            }

            // update the first reminder time if necessary
            var reminder = event.detail(Detail.VisualReminder)
            if (!reminder)
                reminder = event.detail(Detail.AudibleReminder)

            if (root.reminderValue >= 0) {
                if (!reminder) {
                    reminder = Qt.createQmlObject("import QtOrganizer 5.0; VisualReminder {}", event, "")
                    reminder.repetitionCount = 0
                    reminder.repetitionDelay = 0
                }
                reminder.secondsBeforeStart = root.reminderValue
                event.setDetail(reminder)
            } else if (reminder) {
                event.removeDetail(reminder)
            }

            event.collectionId = calendarsOption.model[calendarsOption.selectedIndex].collectionId;

            var comment = event.detail(Detail.Comment);
            if(comment && comment.comment === "X-CAL-DEFAULT-EVENT") {
                event.removeDetail(comment);
            }

            model.saveItem(event)
            root.eventSaved(event);
            model.updateIfNecessary()

            if (pageStack)
                pageStack.pop();
        }
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

    // Calucate default hour and minute for start and end time on event
    function roundDate(date) {
        var tempDate = new Date(date)
        tempDate.setHours(date.getHours(), date.getMinutes(), 0, 0);
        var tempMinutes = tempDate.getMinutes()
        if (tempMinutes === 0) {
            return tempDate
        } else if(tempMinutes < 30) {
            return tempDate.setMinutes(30)
        } else {
            tempDate.setMinutes(0)
            return tempDate.setHours(tempDate.getHours() + 1)
        }
    }

    function adjustEndDateToStartDate(time_forward) {
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

    Keys.onEscapePressed: root.cancel()
    header: PageHeader {
        id: pageHeader

        flickable: null
        title: isEdit ? i18n.tr("Edit Event"):i18n.tr("New Event")
        leadingActionBar.actions: Action {
            id: backAction

            name: "cancel"
            text: i18n.tr("Cancel")
            iconName: isEdit ? "back" : "down"
            onTriggered: root.cancel()
        }

        trailingActionBar.actions: [
            Action {
                text: i18n.tr("Delete");
                objectName: "delete"
                iconName: "delete"
                visible : isEdit
                onTriggered: {
                    var dialog = PopupUtils.open(Qt.resolvedUrl("DeleteConfirmationDialog.qml"),root,{"event": event});
                    dialog.deleteEvent.connect( function(eventId){
                        model.removeItem(eventId);
                        model.updateIfNecessary()
                        if (pageStack)
                            pageStack.pop();
                        root.eventDeleted(eventId);
                    });
                }
            },
            Action {
                iconName: "ok"
                objectName: "save"
                text: i18n.tr("Save")
                enabled: !!titleEdit.text.trim()
                onTriggered: saveToQtPim();
            }
        ]
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
        clip: true

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

        flickableDirection: Flickable.VerticalFlick
        anchors{
            left: parent.left
            top: parent.top
            topMargin: pageHeader.height
            right: parent.right
            bottom: keyboardRectangle.top
        }
        contentWidth: width
        contentHeight: column.height

        Column {
            id: column

            width: parent.width

            NewEventTimePicker{
                id: startDateTimeInput
                objectName: "startDateTimeInput"

                header: i18n.tr("From")
                showTimePicker: !allDayEventCheckbox.checked
                anchors {
                    left: parent.left
                    right: parent.right
                }
                onDateTimeChanged: {
                    startDate = dateTime;
                    endDateTimeInput.dateTime = new Date(startDate.getTime() + root.eventSize)
                }
            }

            NewEventTimePicker{
                id: endDateTimeInput
                objectName: "endDateTimeInput"

                header: i18n.tr("To")
                showTimePicker: !allDayEventCheckbox.checked
                anchors {
                    left: parent.left
                    right: parent.right
                }
                onDateTimeChanged: {
                    if (dateTime.getTime() < startDate.getTime()) {
                        root.eventSize = root.allDay ? 0 : root.millisecsInAnHour
                        dateTime = new Date(startDate.getTime() + root.eventSize)
                        return
                    }

                    endDate = dateTime;
                    if (allDay)
                        root.eventSize = endDate.midnight().getTime() - startDate.midnight().getTime()
                    else
                        root.eventSize = endDate.getTime() - startDate.getTime()
                }
            }

            ListItems.Standard {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                text: i18n.tr("All day event")
                __foregroundColor: Theme.palette.normal.baseText
                showDivider: false
                control: CheckBox {
                    objectName: "allDayEventCheckbox"
                    id: allDayEventCheckbox
                    checked: false
                    onCheckedChanged: {
                        if (checked)
                            root.eventSize = Math.max(endDate.midnight().getTime() - startDate.midnight().getTime(), 0)
                        else
                            root.eventSize = Math.max(endDate.getTime() - startDate.getTime(), root.millisecsInAnHour)
                    }
                }
            }

            ListItems.ThinDivider {}

            Column {
                width: parent.width
                spacing: units.gu(1)

                ListItems.Header{
                    text: i18n.tr("Event Details")
                    __foregroundColor: Theme.palette.normal.baseText
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
                    onFocusChanged: {
                        if(titleEdit.focus) {
                            flickable.makeMeVisible(titleEdit);
                        }
                    }
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
                    onFocusChanged: {
                        if(messageEdit.focus) {
                            flickable.makeMeVisible(messageEdit);
                        }
                    }
                }

                TextField {
                    id: locationEdit
                    objectName: "eventLocationInput"

                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    inputMethodHints: Qt.ImhNoPredictiveText
                    placeholderText: i18n.tr("Location")

                    onFocusChanged: {
                        if(locationEdit.focus) {
                            flickable.makeMeVisible(locationEdit);
                        }
                    }
                }
            }

            Column {
                width: parent.width
                spacing: units.gu(1)

                ListItems.Header {
                    text: i18n.tr("Calendar")
                    __foregroundColor: Theme.palette.normal.baseText
                }

                OptionSelector{
                    id: calendarsOption
                    objectName: "calendarsOption"

                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    containerHeight: (model && (model.length > 1) ? itemHeight * model.length : itemHeight)
                    model: root.model ? root.model.getWritableAndSelectedCollections() : []

                    Connections {
                        target: root.model ? root.model : null
                        onModelChanged: {
                            calendarsOption.model = root.model.getWritableAndSelectedCollections()
                        }
                        onCollectionsChanged: {
                            calendarsOption.model = root.model.getWritableAndSelectedCollections()
                        }
                    }

                    Connections {
                        target: root
                        onActiveChanged: {
                            if (root.active) {
                                calendarsOption.model = root.model.getWritableAndSelectedCollections()
                            }
                        }
                    }

                    onExpansionCompleted: flickable.makeMeVisible(calendarsOption)

                    delegate: OptionSelectorDelegate{
                        text: modelData.name

                        UbuntuShape{
                            id: calColor
                            width: height
                            height: parent.height - units.gu(2)
                            color: modelData.color
                            anchors {
                                right: parent.right
                                rightMargin: units.gu(4)
                                verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                    onExpandedChanged: Qt.inputMethod.hide();
                }
            }

            Column {
                width: parent.width
                spacing: units.gu(1)

                ListItems.Header {
                    text: i18n.tr("Guests")
                    __foregroundColor: Theme.palette.normal.baseText
                }

                Button{
                    id: addGuestButton
                    objectName: "addGuestButton"

                    property var contactsPopup: null

                    text: i18n.tr("Add Guest")
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }

                    onClicked: {
                        if (contactsPopup)
                            return

                        flickable.makeMeVisible(addGuestButton)
                        contactsPopup = PopupUtils.open(Qt.resolvedUrl("ContactChoicePopup.qml"), addGuestButton);
                        contactsPopup.contactSelected.connect( function(contact, emailAddress) {
                            if(!internal.isContactAlreadyAdded(contact, emailAddress) ) {
                                var t = internal.contactToAttendee(contact, emailAddress);
                                contactModel.append({"contact": t});
                            }

                        });
                        contactsPopup.Component.onDestruction.connect( function() {
                            addGuestButton.contactsPopup = null
                        })
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

                        ListModel{
                            id: contactModel
                        }

                        Repeater{
                            model: contactModel
                            delegate: ListItem {
                                objectName: "eventGuest%1".arg(index)

                                ListItemLayout {
                                    title.text: contact.name
                                    subtitle.text: contact.emailAddress
                                }

                                leadingActions: ListItemActions {
                                    actions: Action {
                                        iconName: "delete"
                                        onTriggered: {
                                            contactModel.remove(index)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                ListItems.ThinDivider {
                    visible: (event != undefined) && (event.itemType === Type.Event)
                }

            }

            ListItem {
                id:thisHappens
                objectName :"thisHappens"

                visible: (event != undefined) && ((event.itemType === Type.Event) || (event.itemType === Type.Todo))

                ListItemLayout {
                    id: thisHappensLayout
                    title.text: i18n.tr("Repeats")
                    summary.text: (event != undefined) && (event.itemType === Type.Event) ? rule === null ? Defines.recurrenceLabel[0] : eventUtils.getRecurrenceString(rule) : ""
                    ProgressionSlot {}
                }

                onClicked: {
                    var stack = pageStack
                    if (!stack)
                        stack = bottomEdgePageStack

                    stack.push(Qt.resolvedUrl("EventRepetition.qml"),{"eventRoot": root,"isEdit":isEdit});
                }
            }

            ListItem {
                id: eventReminder
                objectName: "eventReminder"

                property int reminderValue: -1

                ListItemLayout {
                    id: eventReminderLayout
                    title.text: i18n.tr("Reminder")
                    summary.text: reminderModel.intervalToString(eventReminder.reminderValue)
                    ProgressionSlot {}
                }

                RemindersModel {
                    id: reminderModel
                }

                onClicked:{
                    var stack = pageStack
                    if (!stack) {
                        stack = bottomEdgePageStack
                    }

                    reminderModel.reset()
                    var reminderPick = stack.push(Qt.resolvedUrl("RemindersPage.qml"),
                                                   {"title": i18n.tr("Reminder"),
                                                    "model": reminderModel,
                                                    "interval": eventReminder.reminderValue})
                    reminderPick.intervalChanged.connect(function() {
                        root.reminderValue = reminderPick.interval
                    })

                }
            }
        }
    }

    // used to keep the field visible when the keyboard appear or dismiss
    KeyboardRectangle {
        id: keyboardRectangle

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Behavior on height {
            SequentialAnimation {
                PauseAnimation { duration: 200 }
                ScriptAction {
                    script: {
                        if (addGuestButton.contactsPopup) {
                            // WORKAROUND: causes the popover to follow the buttom position when keyboard appears
                            flickable.makeMeVisible(addGuestButton)
                            addGuestButton.contactsPopup.caller = null
                            addGuestButton.contactsPopup.caller = addGuestButton
                        } else {
                            flickable.makeMeVisible(flickable.activeItem)
                        }
                    }
                }
            }
        }
    }

    QtObject {
        id: internal

        property var collectionId;

        function clearFocus() {
            Qt.inputMethod.hide()
            titleEdit.focus = false
            locationEdit.focus = false
            startDateTimeInput.clearFocus();
            endDateTimeInput.clearFocus();
            messageEdit.focus = false
        }

        function isContactAlreadyAdded(contact, emailAddress) {
            for(var i=0; i < contactModel.count; i++) {
                var attendee = contactModel.get(i).contact;
                if (attendee && (emailAddress.length > 0)) {
                    if (attendee.emailAddress === emailAddress) {
                        return true;
                    }
                } else {
                    if (attendee.attendeeId === contact.contactId) {
                        return true
                    }
                }
            }
            return false;
        }

        function attendeeFromData(id, name, emailAddress)
        {
            var attendee = Qt.createQmlObject("import QtOrganizer 5.0; EventAttendee{}", internal, "NewEvent.qml");
            attendee.name = name
            attendee.emailAddress = emailAddress
            attendee.attendeeId = id
            return attendee;
        }

        function contactToAttendee(contact, emailAddress) {
            return attendeeFromData(contact.contactId, contact.displayLabel.label, emailAddress)
        }
    }
}
