import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Themes.Ambiance 0.1

import "dataService.js" as DataService

Page {
    id: root

    property var date: new Date();
    property var event: null;
    property alias errorText: errorPopupDialog.text;
    property var startDate: date
    property var endDate: date
    property alias scrollY: flickable.contentY
    property bool isEdit: false

    Component.onCompleted: {
        if( pageStack.header )
            pageStack.header.visible = true;
        if(event === null){
            console.log("I am adding");
            addEvent();
            isEdit =false;
        }
        else{
            console.log("I am editing");
            editEvent(event);
            isEdit = true;
        }
    }

    width: parent.width
    height: parent.height

    title: isEdit===false? i18n.tr("New Event"):i18n.tr("Edit Event")

    tools: ToolbarItems {
        //keeping toolbar always open
        opened: true
        locked: true

        //FIXME: set the icons for toolbar buttons
        back: ToolbarButton {
            objectName: "eventCancelButton"
            action: Action {
                text: i18n.tr("Cancel");
                onTriggered: {
                    if(isEdit)
                        pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":event});
                    else
                        pageStack.pop();
                }
            }
        }

        ToolbarButton {
            objectName: "eventSaveButton"
            action: Action {
                text: i18n.tr("Save");
                onTriggered: {
                    saveEvent();
                    if(isEdit)
                        pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":event});
                    else
                        pageStack.pop();
                }
            }
        }
    }
    function addEvent() {
        startDate = new Date(date)
        endDate = new Date(date)
        endDate.setMinutes( endDate.getMinutes() + 10)

        startTime.text = Qt.formatDateTime(startDate, "dd MMM yyyy hh:mm");
        endTime.text = Qt.formatDateTime(endDate, "dd MMM yyyy hh:mm");
    }
    //Editing Event
    function editEvent(e) {
        startDate =new Date(e.startTime);
        endDate = new Date(e.endTime);
        startTime.text = Qt.formatDateTime(e.startTime, "dd MMM yyyy hh:mm");
        endTime.text = Qt.formatDateTime(e.endTime, "dd MMM yyyy hh:mm");
        if(e.title)
            titleEdit.text = e.title;
        if(e.location)
            locationEdit.text = e.location;
        if( e.message ) {
            messageEdit.text = e.message;
        }
    }


    function saveEvent() {
        internal.clearFocus()

        var error = 0;

        if ( startDate > endDate )
            error = 2;
        if(isEdit){
            event.message = messageEdit.text;
            event.startTime = startDate;
            event.endTime = endDate;
            event.title = titleEdit.text;
        }
        else{
            event = {
                title: titleEdit.text,
                message: null,
                startTime: startDate.getTime(),
                endTime: endDate.getTime()
            }
        }
        if (!error) {
            if(isEdit)
                DataService.updateEvent(event);
            else
                DataService.addEvent(event);
        } else {
            errorText = i18n.tr("End time can't be before start time");
            errorPopupDialog.show();
        }

        error = 0;
    }

    QtObject {
        id: internal
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

    Dialog {
        id: errorPopupDialog
        title: i18n.tr("Error")
        text: ""
        Button {
            text: i18n.tr("Ok")
            onClicked: PopupUtils.close(errorPopupDialog)
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
}
