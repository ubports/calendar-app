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
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Themes.Ambiance 1.0
import Ubuntu.Components.Pickers 1.0
import QtOrganizer 5.0

import "Defines.js" as Defines

Page {
    id: root
    objectName: 'newEventPage'
    property var date;

    property var event:null;
    property var model;

    property var startDate;
    property var endDate;
    property int optionSelectorWidth: frequencyLabel.width > remindLabel.width ? frequencyLabel.width : remindLabel.width

    property alias scrollY: flickable.contentY
    property bool isEdit: false

    onStartDateChanged: {
        startDateInput.text = Qt.formatDateTime(startDate, "dd MMM yyyy");
        startTimeInput.text = Qt.formatDateTime(startDate, "hh:mm");
        adjustEndDateToStartDate()
    }

    onEndDateChanged: {
        endDateInput.text = Qt.formatDateTime(endDate, "dd MMM yyyy");
        endTimeInput.text = Qt.formatDateTime(endDate, "hh:mm");
    }

    head {
        backAction: Action {
            iconName: "close"
            onTriggered: pageStack.pop();
        }

        actions: [
            Action {
                iconName: "ok"
                objectName: "save"
                text: i18n.tr("Save")
                onTriggered: saveToQtPim();
            }
        ]
    }

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
            titleEdit.forceActiveFocus();
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
        selectCalendar(model.defaultCollection().collectionId);
    }
    //Editing Event
    function editEvent(e) {
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

            index = 0;
            if(e.recurrence ) {
                var recurrenceRule = e.recurrence.recurrenceRules;
                index = ( recurrenceRule.length > 0 ) ? recurrenceRule[0].frequency : 0;
                if(index > 0 )
                {
                    limit.visible = true;
                    if(recurrenceRule[0].limit !== undefined){
                        var temp = recurrenceRule[0].limit;
                        if(parseInt(temp)){
                            limitOptions.selectedIndex = 1;
                            limitCount.text = temp;
                        }
                        else{
                            limitOptions.selectedIndex = 2;
                            datePick.date= temp;
                        }
                    }
                    else{
                        // If limit is infinite
                        limitOptions.selectedIndex = 0;
                    }
                    if(index === RecurrenceRule.Weekly){
                            index = getWeekDaysIndex(recurrenceRule[0].daysOfWeek.sort());
                    }
                    if(recurrenceRule[0].daysOfWeek.length>0 && index === 5){
                        for(var j = 0;j<recurrenceRule[0].daysOfWeek.length;++j){
                            //Start childern after first element.
                            weeksRow.children[recurrenceRule[0].daysOfWeek[j] === 7 ? 0 :recurrenceRule[0].daysOfWeek[j]].children[1].checked = true;
                        }
                    }
                }
            }
            recurrenceOption.selectedIndex = index;
        }

        index = 0;
        var reminder = e.detail( Detail.VisualReminder);
        if( reminder ) {
            var reminderTime = reminder.secondsBeforeStart;
            var foundIndex = Defines.reminderValue.indexOf(reminderTime);
            index = foundIndex != -1 ? foundIndex : 0;
        }
        reminderOption.selectedIndex = index;

        selectCalendar(e.collectionId);
    }
    function getWeekDaysIndex(daysOfWeek){
        var index = 0;
        if(compareArrays(daysOfWeek,[Qt.Monday,Qt.Tuesday,Qt.Wednesday,Qt.Thursday,Qt.Friday]))
            index = 2
        else if(compareArrays(daysOfWeek,[Qt.Monday,Qt.Wednesday,Qt.Friday]))
            index = 3
        else if(compareArrays(daysOfWeek,[Qt.Tuesday,Qt.Thursday]))
            index = 4
        else
            index = 5
        return index;
    }

    function compareArrays(daysOfWeek, actualArray){
        if (daysOfWeek.length !== actualArray.length) return false;
        for (var i = 0; i < actualArray.length; i++) {
            if (daysOfWeek[i] !== actualArray[i]) return false;
        }
        return true;
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

                var recurrenceRule = Defines.recurrenceValue[ recurrenceOption.selectedIndex ];
                var rule = Qt.createQmlObject("import QtOrganizer 5.0; RecurrenceRule {}", event.recurrence,"NewEvent.qml");
                if( recurrenceRule !== RecurrenceRule.Invalid ) {
                    rule.frequency = recurrenceRule;
                    rule.daysOfWeek = getDaysOfWeek();
                    if(limitOptions.selectedIndex === 1 && recurrenceOption.selectedIndex > 0){
                        rule.limit =  parseInt(limitCount.text);
                    }
                    else if(limitOptions.selectedIndex === 2 && recurrenceOption.selectedIndex > 0){
                        rule.limit =  datePick.date;
                    }
                    else{
                        rule.limit = undefined;
                    }
                }
                event.recurrence.recurrenceRules = [rule];
            }

            //remove old reminder value
            var oldVisualReminder = event.detail(Detail.VisualReminder);
            if(oldVisualReminder) {
                event.removeDetail(oldVisualReminder);
            }

            var oldAudibleReminder = event.detail(Detail.AudibleReminder);
            if(oldAudibleReminder) {
                event.removeDetail(oldAudibleReminder);
            }

            var reminderTime = Defines.reminderValue[ reminderOption.selectedIndex ];
            if( reminderTime !== 0 ) {
                var visualReminder =  Qt.createQmlObject("import QtOrganizer 5.0; VisualReminder{}", event, "NewEvent.qml");
                visualReminder.repetitionCount = 3;
                visualReminder.repetitionDelay = 120;
                visualReminder.message = titleEdit.text
                visualReminder.secondsBeforeStart = reminderTime;
                event.setDetail(visualReminder);

                var audibleReminder =  Qt.createQmlObject("import QtOrganizer 5.0; AudibleReminder{}", event, "NewEvent.qml");
                audibleReminder.repetitionCount = 3;
                audibleReminder.repetitionDelay = 120;
                audibleReminder.secondsBeforeStart = reminderTime;
                event.setDetail(audibleReminder);
            }

            event.collectionId = calendarsOption.model[calendarsOption.selectedIndex].collectionId;
            model.saveItem(event);
            pageStack.pop();
        }
    }

    function getDaysOfWeek(){
        var daysOfWeek = [];
        switch(recurrenceOption.selectedIndex){
        case 2:
            daysOfWeek = [Qt.Monday,Qt.Tuesday,Qt.Wednesday,Qt.Thursday,Qt.Friday];
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
        Qt.inputMethod.hide();
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

    // we use a custom toolbar in this view
    tools: ToolbarItems {
        locked: true
        opened: false
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
        anchors.margins: units.gu(2)

        contentWidth: width
        contentHeight: column.height

        Column {
            id: column

            width: parent.width
            spacing: units.gu(1)

            UbuntuShape {
                width:parent.width
                height: timeColumn.height

                Column{
                    id: timeColumn
                    width: parent.width
                    anchors.centerIn: parent
                    spacing: units.gu(1)

                    Item {
                        width: parent.width
                        height: startDateInput.height

                        NewEventEntryField{
                            id: startDateInput
                            title: i18n.tr("Start")
                            objectName: "startDateInput"

                            text: ""

                            width: allDayEventCheckbox.checked ? parent.width : parent.width / 2

                            MouseArea{
                                anchors.fill: parent
                                onClicked: openDatePicker(startDateInput, root, "startDate", "Years|Months|Days")
                            }
                        }

                        NewEventEntryField{
                            id: startTimeInput
                            // TRANSLATORS: This "at" refers to HH:MM of an event. E.g 1st January at 10:30
                            title: i18n.tr("at")
                            objectName: "startTimeInput"

                            text: ""

                            width: (parent.width / 2) - units.gu(1)
                            anchors.right: parent.right
                            visible: !allDayEventCheckbox.checked

                            MouseArea{
                                anchors.fill: parent
                                onClicked: openDatePicker(startTimeInput, root, "startDate", "Hours|Minutes")
                            }
                        }
                    }

                    Item {
                        width: parent.width
                        height: endDateInput.height
                        visible: !allDayEventCheckbox.checked

                        NewEventEntryField{
                            id: endDateInput
                            title: i18n.tr("End")
                            objectName: "endDateInput"

                            text: ""

                            width: parent.width / 2

                            MouseArea{
                                anchors.fill: parent
                                onClicked: openDatePicker(endDateInput, root, "endDate", "Years|Months|Days")
                            }
                        }

                        NewEventEntryField{
                            id: endTimeInput
                            // TRANSLATORS: This "at" refers to HH:MM of an event. E.g 1st January at 10:30
                            title: i18n.tr("at")
                            objectName: "endTimeInput"
                            text: ""
                            width: (parent.width / 2) - units.gu(1)
                            anchors.right: parent.right

                            MouseArea{
                                anchors.fill: parent
                                onClicked: openDatePicker(endTimeInput, root, "endDate", "Hours|Minutes")

                            }
                        }
                    }
                }
            }

            Item{
                width: parent.width
                height: calendarsOption.height
                Label{
                    id: calendarLabel
                    text: i18n.tr("Calendar ");
                    anchors.verticalCenter: parent.verticalCenter
                }

                OptionSelector{
                    id: calendarsOption
                    objectName: "calendarsOption"
                    anchors.right: parent.right
                    width: parent.width - calendarLabel.width - units.gu(1)
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
                            anchors.rightMargin: units.gu(1)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    onExpandedChanged: Qt.inputMethod.hide();
                }
            }

            Row {
                width: parent.width
                spacing: units.gu(1)
                anchors.margins: units.gu(0.5)

                Label {
                    text: i18n.tr("All Day event:")
                    anchors.verticalCenter: allDayEventCheckbox.verticalCenter
                }

                CheckBox {
                    id: allDayEventCheckbox
                    checked: false
                }
            }

            ThinDivider{}

            NewEventEntryField{
                id: titleEdit
                width: parent.width
                title: i18n.tr("Event Name")
                objectName: "newEventName"
            }

            Column{
                id: descriptionColumn
                width: parent.width
                spacing: units.gu(1)

                Label {
                    text: i18n.tr("Description")
                    anchors.margins: units.gu(0.5)
                    anchors.left: parent.left
                }

                TextArea{
                    id: messageEdit
                    objectName: "eventDescriptionInput"
                    width: parent.width
                    color: focus ? "#2C001E" : "#5D5D5D"
                    // default style
                    font {
                        pixelSize: focus ? FontUtils.sizeToPixels("large") : FontUtils.sizeToPixels("medium")
                    }
                }
            }

            NewEventEntryField{
                id: locationEdit
                width: parent.width
                title: i18n.tr("Location")
                objectName: "eventLocationInput"
            }

            UbuntuShape {
                width: parent.width
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
                    Button{
                        text: i18n.tr("Add Guest")
                        objectName: "addGuestButton"
                        width: parent.width
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

                    Repeater{
                        model: contactModel
                        delegate: Standard {
                            objectName: "eventGuest%1".arg(index)
                            height: units.gu(4)
                            text: name
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: recurrenceOption.height
                visible: event.itemType === Type.Event
                Label{
                    id: frequencyLabel
                    text: i18n.tr("This happens");
                    anchors.verticalCenter: parent.verticalCenter
                }
                OptionSelector{
                    id: recurrenceOption
                    anchors.right: parent.right
                    width: parent.width - optionSelectorWidth - units.gu(1)
                    model: Defines.recurrenceLabel
                    containerHeight: itemHeight * 4
                    onExpandedChanged: Qt.inputMethod.hide();
                    onExpansionCompleted: scrollOnExpand(true,column,flickable,-8,[weeksColumn,limit,limitCount,limitDate,remind])
                }
            }

            Column {
                id: weeksColumn
                visible: recurrenceOption.selectedIndex == 5
                Label {
                    text: i18n.tr("Repeats On:")
                }
                Row {
                    id: weeksRow
                    width: column.width
                    spacing: (weeksRow.width - units.gu(28))/6 //Units.gu(28) = weeksRowColumn.width * 7 [weeks]
                    Repeater {
                        model: Defines.weekLabel
                        Column {
                            id: weeksRowColumn
                            width: units.gu(4) //This is help calculate weeksRow.spacing
                            Label {
                                id:lbl
                                text:modelData
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            CheckBox {
                                id: weekCheck
                                onCheckedChanged: {
                                    //EDS consider 7 as Sunday index so if the index is 0 then we have to explicitly push Sunday.
                                    if(index === 0)
                                        (checked) ? internal.weekDays.push(Qt.Sunday) : internal.weekDays.splice(internal.weekDays.indexOf(Qt.Sunday),1);
                                    else
                                        (checked) ? internal.weekDays.push(index) : internal.weekDays.splice(internal.weekDays.indexOf(index),1);
                                }
                                checked: {
                                    (internal.weekDays.length === 0 && index === date.getDay() && isEdit== false) ? true : false;
                                }
                            }
                        }
                    }
                }
            }
            Item {
                id: limit
                visible: recurrenceOption.selectedIndex != 0
                width: parent.width
                height: limitOptions.height
                Label{
                    id: limitLabel
                    text: i18n.tr("Recurring event ends");
                    anchors{
                        left: parent.left
                        right: limitOptions.left
                    }
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    anchors.verticalCenter: parent.verticalCenter
                }
                OptionSelector{
                    id: limitOptions
                    anchors.right: parent.right
                    width: parent.width - optionSelectorWidth - units.gu(3)
                    model: Defines.limitLabel
                    containerHeight: itemHeight * 4
                    onExpandedChanged:   Qt.inputMethod.hide();
                    onExpansionCompleted: scrollOnExpand(true,column,flickable,-5,[limitCount,limitDate,remind])
                }
            }
            NewEventEntryField{
                id: limitCount
                width: parent.width
                // TRANSLATORS: This refers to no of occurences of an event.
                title: i18n.tr("Recurrence")
                objectName: "eventLimitCount"
                visible:  recurrenceOption.selectedIndex != 0 && limitOptions.selectedIndex == 1;
                validator: IntValidator{bottom: 1;}
                inputMethodHints: Qt.ImhDialableCharactersOnly
                focus: true
            }
            Item {
                id: limitDate
                width: parent.width
                height: datePick.height
                visible: recurrenceOption.selectedIndex != 0 && limitOptions.selectedIndex===2;
                onVisibleChanged: scrollOnExpand(this.visible,column,flickable,-16,[remind])
                DatePicker{
                    id:datePick;
                    anchors.right: parent.right
                    anchors.left: parent.left
                }
            }
            Item{
                id: remind
                width: parent.width
                height: reminderOption.height
                Label{
                    id: remindLabel
                    text: i18n.tr("Remind me");
                    anchors.verticalCenter: parent.verticalCenter
                }

                OptionSelector{
                    id: reminderOption
                    anchors.right: parent.right
                    width: parent.width - optionSelectorWidth - units.gu(1)
                    containerHeight: itemHeight * 4
                    model: Defines.reminderLabel
                    onExpandedChanged:   Qt.inputMethod.hide();
                    onExpansionCompleted: scrollOnExpand(true,column,flickable,-1)
                }
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
        property var weekDays : [];
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
