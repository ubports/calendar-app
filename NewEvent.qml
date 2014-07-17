import QtQuick 2.0
import QtOrganizer 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Themes.Ambiance 0.1
import Ubuntu.Components.Pickers 0.1
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
    }

    onEndDateChanged: {
        endDateInput.text = Qt.formatDateTime(endDate, "dd MMM yyyy");
        endTimeInput.text = Qt.formatDateTime(endDate, "hh:mm");
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

    //Data for Add events
    function addEvent() {
        event = Qt.createQmlObject("import QtOrganizer 5.0; Event { }", Qt.application,"NewEvent.qml");
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
        if( e.itemType === Type.Event ) {
            if(e.attendees){
                for( var j = 0 ; j < e.attendees.length ; ++j ) {
                    personEdit.text += e.attendees[j].name;
                    if(j!== e.attendees.length-1)
                        personEdit.text += ",";
                }
            }

            var index = 0;
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
                            weeksRow.children[recurrenceRule[0].daysOfWeek[j]+1].checked = true;
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
                if( personEdit.text != "") {
                    var attendee = Qt.createQmlObject("import QtOrganizer 5.0; EventAttendee{}", event, "NewEvent.qml");
                    attendee.name = personEdit.text;
                    event.setDetail(attendee);
                }

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

        anchors {
            top: parent.top
            topMargin: units.gu(2)
            bottom: toolbar.top
            left: parent.left
            right: parent.right
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }

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
                    spacing: units.gu(1)
                    width: parent.width
                    clip: true
                    ListModel {
                        id: contactModel
                    }
                    Button{
                        text: "Add Guest"
                        width: parent.width
                        onClicked: {
                            var popup = PopupUtils.open(Qt.resolvedUrl("ContactChoicePopup.qml"), contactList);
                            popup.contactSelected.connect( function(contact) {
                                contactModel.append(internal.contactToAttendee(contact));
                            });
                        }
                    }

                    Repeater{
                        model: contactModel
                        delegate: Standard {
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
                }
            }

            Row {
                id:weeksRow
                width: parent.width
                spacing: units.gu(4)
                anchors.margins: units.gu(1)
                visible: recurrenceOption.selectedIndex == 5
                Label {
                    text: i18n.tr("Repeats On:")
                    anchors.verticalCenter: parent.verticalCenter
                }
                Repeater{
                    model: Defines.weekLabel
                    width: parent.width
                    CheckBox {
                        id: weekCheck
                        anchors.verticalCenter: parent.verticalCenter
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
                        Label{
                            id:lbl
                            text:modelData
                            anchors.centerIn: parent
                            width: parent.width + units.gu(7)
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

                }
            }
            NewEventEntryField{
                id: limitCount
                width: parent.width
                title: i18n.tr("Count")
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
                DatePicker{
                    id:datePick;
                    width: parent.width
                }
            }
            Item{
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
                }
            }
        }
    }

    EditToolbar {
        id: toolbar
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: units.gu(6)
        acceptAction: Action {
            text: i18n.tr("Save")
            onTriggered: saveToQtPim();
        }
        rejectAction: Action {
            text: i18n.tr("Cancel")
            onTriggered: pageStack.pop();
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
            personEdit.focus = false
            startDateInput.focus = false
            startTimeInput.focus = false
            endDateInput.focus = false
            endTimeInput.focus = false
            messageEdit.focus = false
        }

        function contactToAttendee(contact) {
            var attendee = Qt.createQmlObject("import QtOrganizer 5.0; EventAttendee{}", event, "NewEvent.qml");
            attendee.name = contact.name.firstName + " " + contact.name.lastName;
            attendee.emailAddress = contact.email.emailAddress;
            event.setDetail(attendee);
            return attendee;
        }
    }
}
