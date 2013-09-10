import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Themes.Ambiance 0.1

import "dataService.js" as DataService

Page {
    id: root

    property var date: new Date();
    property alias errorText: errorPopupDialog.text;
    property var startDate: date
    property var endDate: date

    Component.onCompleted: {
        startDate = new Date(date)
        endDate = new Date(date)
        endDate.setMinutes( endDate.getMinutes() + 10)

        startTime.text = Qt.formatDateTime(startDate, "dd MMM yyyy hh:mm");
        endTime.text = Qt.formatDateTime(endDate, "dd MMM yyyy hh:mm");
    }

    anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: units.gu(2)
    }

    title: i18n.tr("New Event")

    tools: ToolbarItems {
        ToolbarButton {
            action: Action {
                text: i18n.tr("Save");
                onTriggered: {
                    saveEvent();
                    pageStack.pop();
                }
            }
        }
    }

    function saveEvent() {
        internal.clearFocus()

        var error = 0;

        if ( startDate > endDate )
            error = 2;

        var event = {
            title: titleEdit.text,
            message: null,
            startTime: startDate.getTime(),
            endTime: endDate.getTime()
        }

        if (!error) {
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
        anchors.top: parent.top
        height: parent.height
        width: parent.width

        contentWidth: width
        contentHeight: column.height

        Column{
            id: column

            width: parent.width
            spacing: units.gu(1)

            UbuntuShape{
                width:parent.width
                height: timeColumn.height + units.gu(1)

                Column{
                    id: timeColumn
                    width: parent.width - units.gu(1)
                    anchors.centerIn: parent
                    spacing: units.gu(1)

                    NewEventEntryField{
                        id: startTime
                        title: i18n.tr("Start")
                        width: parent.width

                        text: Qt.formatDateTime(startDate, "dd MMM yyyy hh:mm");

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                internal.clearFocus()
                                var popupObj = PopupUtils.open(timePicker);
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

                        text: Qt.formatDateTime(endDate,"dd MMM yyyy hh:mm");

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                internal.clearFocus()
                                var popupObj = PopupUtils.open(timePicker);
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

            UbuntuShape{
                width:parent.width
                height: titleEdit.height + units.gu(1)

                NewEventEntryField{
                    id: titleEdit
                    width: parent.width - units.gu(1)
                    anchors.centerIn: parent
                    title: i18n.tr("New Event")
                }
            }

            UbuntuShape{
                width:parent.width
                height: descriptionColumn.height + units.gu(1)

                Column{
                    id: descriptionColumn
                    width: parent.width - units.gu(1)
                    anchors.centerIn: parent
                    spacing: units.gu(1)

                    Label {
                        text: i18n.tr("Description")
                    }

                    TextArea{
                        id: messageEdit
                        width: parent.width
                    }
                }
            }

            UbuntuShape{
                width:parent.width
                height: locationEdit.height + units.gu(1)

                NewEventEntryField{
                    id: locationEdit
                    width: parent.width - units.gu(1)
                    anchors.centerIn: parent
                    title: i18n.tr("Location")
                }
            }

            OptionSelector{
                model:[i18n.tr("Catagory"),"test1","test2"]
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
                    width: parent.width - frequencyLabel.width
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
                    width: parent.width - remindLabel.width
                    model:[i18n.tr("No Reminder"),
                        i18n.tr("At Event"),
                        i18n.tr("5 Minutes"),
                        i18n.tr("10 Minutes"),
                        i18n.tr("15 Minutes"),
                        i18n.tr("30 Minutes"),
                        i18n.tr("45 Minutes"),
                        i18n.tr("1 Hour"),
                        i18n.tr("2 Hours"),
                        i18n.tr("3 Hours"),
                        i18n.tr("4 Hours"),
                        i18n.tr("5 Hours"),
                        i18n.tr("6 Hours"),
                        i18n.tr("7 Hours"),
                        i18n.tr("8 Hours"),
                        i18n.tr("9 Hours"),
                        i18n.tr("10 Hours"),
                        i18n.tr("11 Hours"),
                        i18n.tr("12 Hours"),
                        i18n.tr("18 Hours")]
                }
            }

            UbuntuShape{
                width:parent.width
                height: personEdit.height + units.gu(1)

                NewEventEntryField{
                    id: personEdit
                    width: parent.width - units.gu(1)
                    anchors.centerIn: parent
                    title: i18n.tr("Guests")
                }
            }
        }
    }
}
