import QtQuick 2.0
import QtOrganizer 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Themes.Ambiance 0.1

import "GlobalEventModel.js" as GlobalModel

Page {
    id: root
    property var date: new Date();

    property var event:null;

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
        console.log = function () {
            function do_log (what) {
                messageEdit.text = messageEdit.text + what + "\n";
            }
            for (var i=0,l=arguments.length;i<l;i++) {
                do_log(arguments[i]);
            }
        }

        pageStack.header.visible = true;

        // If startDate is setted by argument we have to not change it
        if (typeof(startDate) === 'undefined')
            startDate = new Date(date)

        // If endDate is setted by argument we have to not change it
        if (typeof(endDate) === 'undefined') {
            var d = new Date(date);
            d.setMinutes(d.getMinutes() + 10); // Change time before setting endDate
                                               // to trigger onEndDateChanged
            endDate = d;
        }
        internal.eventModel = GlobalModel.globalModel();

        if(event === null){
            isEdit = false;
            addEvent();
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

        if(e.displayLabel)
            titleEdit.text = e.displayLabel;
        if(e.location)
            locationEdit.text = e.location;
        if( e.description ) {
            messageEdit.text = e.description;
        }
        if(e.attendees){
            for( var j = 0 ; j < e.attendees.length ; ++j ) {
                personEdit.text += e.attendees[j].name;
                if(j!== e.attendees.length-1)
                    personEdit.text += ",";
            }
        }
        allDayEventCheckbox.checked = e.allDay;

        var index = 0;
        if(e.recurrence ) {
            var recurrenceRule = e.recurrence.recurrenceRules;
            index = ( recurrenceRule.length > 0 ) ? recurrenceRule[0].frequency : 0;
        }
        recurrenceOption.selectedIndex = index;
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
            event.attendees = []; // if Edit remove all attendes & add them again if any
            if( personEdit.text != "") {
                var attendee = Qt.createQmlObject("import QtOrganizer 5.0; EventAttendee{}", Qt.application, "NewEvent.qml");
                attendee.name = personEdit.text;
                event.setDetail(attendee);
            }

            event.allDay = allDayEventCheckbox.checked;

            var recurrenceRule = internal.recurrenceValue[ recurrenceOption.selectedIndex ];
            if( recurrenceRule !== RecurrenceRule.Invalid ) {
                var rule = Qt.createQmlObject("import QtOrganizer 5.0; RecurrenceRule {}", event.recurrence);
                rule.frequency = recurrenceRule;
                event.recurrence.recurrenceRules = [rule];
            }

            internal.eventModel.saveItem(event);
            pageStack.pop();
        }
    }

    function openDatePicker (element, caller, callerProperty, mode) {
        element.highlighted = true;
        var picker = PickerPanel.openDatePicker(caller, callerProperty, mode);
        if (!picker) return;
        picker.closed.connect(function () {
            element.highlighted = false;
        });
    }

    width: parent.width
    height: parent.height

    title: isEdit ? i18n.tr("Edit Event"):i18n.tr("New Event")

    tools: ToolbarItems {
        //keeping toolbar always open
        opened: true
        locked: true

        //FIXME: set the icons for toolbar buttons
        back: ToolbarButton {
            objectName: "eventCancelButton"
            action: Action {
                text: i18n.tr("Cancel");
                iconSource: Qt.resolvedUrl("cancel.svg");
                onTriggered: {
                    pageStack.pop();
                }
            }
        }

        ToolbarButton {
            objectName: "eventSaveButton"
            action: Action {
                text: i18n.tr("Save");
                iconSource: Qt.resolvedUrl("save.svg");
                onTriggered: {
                    saveToQtPim();
                }
            }
        }
    }

    Component{
        id: errorDlgComponent
        Dialog {
            id: dialog
            title: i18n.tr("Error")
            Button {
                text: i18n.tr("Ok")
                onClicked: PopupUtils.close(dialog)
            }
        }
    }

    Flickable{
        id: flickable
        anchors {
            top: parent.top
            topMargin: units.gu(2)
            bottom: parent.bottom
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
                            objectName: "startTimeInput"

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

            UbuntuShape{
                width:parent.width
                height: descriptionColumn.height

                Column{
                    id: descriptionColumn
                    width: parent.width
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(0.5)
                    spacing: units.gu(1)

                    Label {
                        text: i18n.tr("Description")
                        anchors.margins: units.gu(0.5)
                        anchors.left: parent.left
                    }

                    TextArea{
                        id: messageEdit
                        width: parent.width
                    }
                }
            }

            NewEventEntryField{
                id: locationEdit
                width: parent.width
                title: i18n.tr("Location")
                objectName: "eventLocationInput"
            }

            NewEventEntryField{
                id: personEdit
                width: parent.width
                title: i18n.tr("Guests")
                objectName: "eventPeopleInput"
            }

            Item {
                width: parent.width
                height: recurrenceOption.height
                Label{
                    id: frequencyLabel
                    text: i18n.tr("This happens");
                    anchors.verticalCenter: parent.verticalCenter
                }
                OptionSelector{
                    id: recurrenceOption
                    anchors.right: parent.right
                    width: parent.width - optionSelectorWidth - units.gu(1)
                    model: internal.recurrenceLabel
                }
            }

            Item{
                width: parent.width
                height: childrenRect.height
                Label{
                    id: remindLabel
                    text: i18n.tr("Remind me");
                    anchors.verticalCenter: parent.verticalCenter
                }
                OptionSelector{
                    anchors.right: parent.right
                    width: parent.width - optionSelectorWidth - units.gu(1)
                    model:[i18n.tr("No Reminder"),
                        i18n.tr("5 minutes"),
                        i18n.tr("15 minutes"),
                        i18n.tr("30 minutes"),
                        i18n.tr("1 hour"),
                        i18n.tr("2 hours"),
                        i18n.tr("1 day"),
                        i18n.tr("2 days"),
                        i18n.tr("1 week"),
                        i18n.tr("2 weeks")]
                }
            }
        }
    }

    QtObject {
        id: internal
        property var eventModel;
        property var recurrenceValue: [ RecurrenceRule.Invalid,
            RecurrenceRule.Daily,
            RecurrenceRule.Weekly,
            RecurrenceRule.Monthly,
            RecurrenceRule.Yearly];

        property var recurrenceLabel: [ i18n.tr("Once"),
            i18n.tr("Daily"),
            i18n.tr("Weekly"),
            i18n.tr("Monthly"),
            i18n.tr("Yearly")];

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
    }
}
