import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

import "dataService.js" as DataService

Popover {
    id: popover
    property var defaultDate;
    property string errorText;

    Column {
        id: containerLayout
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }

        ListItem.Header { text: i18n.tr("Create event") }
        ListItem.Empty {
            highlightWhenPressed: false
            TextField {
                objectName: "newEventName"
                id: titleEdit
                placeholderText: i18n.tr("Add event name")
                anchors {
                    fill: parent
                    margins: units.gu(1)
                }
            }
        }

        ListItem.Empty {
            id: dateItem

            height: column.height
            width: parent.width

            Column {
                id: column

                anchors {
                    left: parent.left
                    right: parent.right
                }

                Item {
                    width: popover.width
                    height: dateLabel.height
                    Label {
                        id: dateLabel
                        text: Qt.formatDateTime(defaultDate, "ddd, d MMMM yyyy");
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: units.gu(1)
                        }
                    }
                }

                Item {
                    id: timeContainer
                    width: parent.width
                    height: startTime.height

                    ListItem.Empty {
                        id: startTime
                        highlightWhenPressed: false
                        anchors.left: timeContainer.left
                        width: units.gu(12)
                        TextField {
                            objectName: "startTimeInput"
                            id: startTimeEdit
                            text: Qt.formatDateTime(defaultDate,"hh:mm")
                            anchors {
                                fill: parent
                                margins: units.gu(1)
                            }
                        }
                    }

                    Label {
                        id: endTimeLabel
                        text: i18n.tr("to");
                        anchors {
                            horizontalCenter: parent.horizontalCenter;
                            verticalCenter: startTime.verticalCenter;
                        }
                    }

                   ListItem.Empty {
                        id: endTime
                        highlightWhenPressed: false
                        anchors.right: timeContainer.right
                        width: units.gu(12)
                        TextField {
                            objectName: "endTimeInput"
                            id: endTimeEdit
                            text: Qt.formatDateTime(defaultDate,"hh:mm")
                            anchors {
                                fill: parent
                                margins: units.gu(1)
                            }
                        }
                    }
                }
            }
        }

        ListItem.Header { text: i18n.tr("Location") }
        ListItem.Empty {
            highlightWhenPressed: false
            TextField {
                objectName: "eventLocationInput"
                id: locationEdit
                placeholderText: i18n.tr("Add Location")
                anchors {
                    fill: parent
                    margins: units.gu(1)
                }
            }
        }

        ListItem.Header { text: i18n.tr("People") }
        ListItem.Empty {
            highlightWhenPressed: false
            TextField {
                objectName: "eventPeopleInput"
                id: personEdit
                placeholderText: i18n.tr("Invite People")
                anchors {
                    fill: parent
                    margins: units.gu(1)
                }
            }
        }

        ListItem.SingleControl {
            highlightWhenPressed: false
            Dialog {
                id: errorPopupDialog
                title: i18n.tr("Error")
                text: errorText
                Button {
                    text: i18n.tr("Ok")
                    onClicked: PopupUtils.close(errorPopupDialog)
                }
            }
            control: Button {
                objectName: "eventSaveButton"
                text: i18n.tr("Save")
                anchors {
                    fill: parent
                    margins: units.gu(1)
                }

                onClicked: {
                    // TRANSLATORS: This is separator between hours and minutes (HH:MM)
                    // var separator = i18n.tr(":");
                    var separator = ":";
                    var error = 0;

                    var startTime = startTimeEdit.text.split(separator);
                    var startDate = setTime(startTime);

                    var endTime = endTimeEdit.text.split(separator);
                    var endDate = setTime(endTime);

                    if (startDate > endDate)
                        error = 2;

                    var event = {
                        title: titleEdit.text,
                        message: null,
                        startTime: startDate.getTime(),
                        endTime: endDate.getTime()
                    }

                    if (!error) {
                        DataService.addEvent(event);
                        errorPopupDialog.destroy();
                        PopupUtils.close(popover);
                    } else if (error === 1)
                        errorText = i18n.tr("Time format not valid");
                    else if (error === 2)
                        errorText = i18n.tr("End time can't be before start time");

                    errorPopupDialog.show();
                    error = 0;

                    // Control time validity and return date with time
                    function setTime(time) {
                        var date = new Date(defaultDate);
                        if (time.length === 2 && time[0].length < 3 && time[1].length < 3) {
                            //HH:MM format
                            date.setHours(time[0]);
                            date.setMinutes(time[1]);
                        }
                        else if (time.length === 1 && time[0].length < 3) {
                            //HH format
                            date.setHours(time[0]);
                            date.setMinutes(0);
                        }
                        else
                            error = 1;

                        return date;
                    }
                }
            }
        }
    }
}
