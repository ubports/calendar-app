import QtQuick 2.0
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

    property alias scrollY: flickable.contentY
    property bool isEdit: false

    Component.onCompleted: {

        pageStack.header.visible = true;

        // If startDate is setted by argument we have to not change it
        if (typeof(startDate) === 'undefined')
            startDate = new Date(date)

        // If endDate is setted by argument we have to not change it
        if (typeof(endDate) === 'undefined') {
            endDate = new Date(date)
            endDate.setMinutes( endDate.getMinutes() + 10)
        }
        internal.eventModel = GlobalModel.gloablModel();

        if(event === null){
            isEdit =false;
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
        startDate = new Date(date)
        endDate = new Date(date)
        endDate.setMinutes( endDate.getMinutes() + 10)

        startTime.text = Qt.formatDateTime(startDate, "dd MMM yyyy hh:mm");
        endTime.text = Qt.formatDateTime(endDate, "dd MMM yyyy hh:mm");
    }
    //Editing Event
    function editEvent(e) {
        startDate =new Date(e.startDateTime);
        endDate = new Date(e.endDateTime);
        startTime.text = Qt.formatDateTime(e.startDateTime, "dd MMM yyyy hh:mm");
        endTime.text = Qt.formatDateTime(e.endDateTime, "dd MMM yyyy hh:mm");
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
    }
    //Save the new or Existing event
    function saveToQtPim() {
        internal.clearFocus()
        if ( startDate >= endDate ) {
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
            internal.eventModel.saveItem(event);
            pageStack.pop();
        }
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
    Component {
        id: timePicker
        TimePicker {
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

        Column{
            id: column

            width: parent.width
            spacing: units.gu(1)

            UbuntuShape{
                width:parent.width
                height: timeColumn.height

                Column{
                    id: timeColumn
                    width: parent.width
                    anchors.centerIn: parent
                    spacing: units.gu(1)

                    NewEventEntryField{
                        id: startTime
                        title: i18n.tr("Start")
                        width: parent.width
                        objectName: "startTimeInput"

                        text: Qt.formatDateTime(startDate, "dd MMM yyyy hh:mm");

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                internal.clearFocus()
                                var popupObj = PopupUtils.open(timePicker,root,{"hour": startDate.getHours(),"minute":startDate.getMinutes()});
                                popupObj.accepted.connect(function(startHour, startMinute) {
                                    var newDate = startDate;
                                    newDate.setHours(startHour, startMinute);
                                    startDate = newDate;
                                    startTime.text = Qt.formatDateTime(startDate, "dd MMM yyyy hh:mm");
                                })
                            }
                        }
                    }

                    ThinDivider{}

                    NewEventEntryField{
                        id: endTime
                        title: i18n.tr("End")
                        width: parent.width
                        objectName: "endTimeInput"

                        text: Qt.formatDateTime(endDate,"dd MMM yyyy hh:mm");

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                internal.clearFocus()
                                var popupObj = PopupUtils.open(timePicker,root,{"hour": endDate.getHours(),"minute":endDate.getMinutes()});
                                popupObj.accepted.connect(function(startHour, startMinute) {
                                    var newDate = endDate;
                                    newDate.setHours(startHour, startMinute);
                                    endDate = newDate;
                                    endTime.text = Qt.formatDateTime(endDate, "dd MMM yyyy hh:mm");
                                })
                            }
                        }
                    }
                }
            }
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

            Row{
                width: parent.width
                spacing: units.gu(1)
                Label{
                    id: frequencyLabel
                    text: i18n.tr("This happens");
                    anchors.verticalCenter: parent.verticalCenter
                }
                OptionSelector{
                    model:[i18n.tr("Once"),i18n.tr("Daily"),i18n.tr("Weekly"),i18n.tr("Monthly"),i18n.tr("Yearly")]
                    width: parent.width - frequencyLabel.width - units.gu(1)
                }
            }

            Row{
                width: parent.width
                spacing: units.gu(1)
                Label{
                    id: remindLabel
                    text: i18n.tr("Remind me");
                    anchors.verticalCenter: parent.verticalCenter
                }
                OptionSelector{
                    width: parent.width - remindLabel.width - units.gu(1)
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

        function clearFocus() {
            Qt.inputMethod.hide()
            titleEdit.focus = false
            locationEdit.focus = false
            personEdit.focus = false
            startTime.focus = false
            endTime.focus = false
            messageEdit.focus = false
        }
    }
}
