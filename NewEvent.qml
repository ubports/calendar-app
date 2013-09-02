import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

import "dataService.js" as DataService

Popover {
    id: popover
    property var defaultDate;
    property alias errorText: errorPopupDialog.text;
    property var startDate: new Date()
    property var endDate: new Date()

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

                Component {
                    id: timePicker
                    TimePicker {
                    }
                }

                Item {
                    id: timeContainer
                    width: parent.width
                    height: startTimeItem.height

                    ListItem.Empty {
                        id: startTimeItem
                        anchors.left: timeContainer.left
                        width: units.gu(12)
                        Button {
                            objectName: "startTimeInput"
                            id: startTimeButton
                            text: Qt.formatDateTime(startDate,"hh:mm")
                            anchors {
                                fill: parent
                                margins: units.gu(1)
                            }
                            onClicked: {
                                internal.clearFocus()
                                var popupObj = PopupUtils.open(timePicker);
                                popupObj.accepted.connect(function(startHour, startMinute) {
                                    var newDate = startDate;
                                    newDate.setHours(startHour, startMinute);
                                    startDate = newDate;
                                })
                            }
                        }
                    }

                    Label {
                        id: endTimeLabel
                        text: i18n.tr("to");
                        anchors {
                            horizontalCenter: parent.horizontalCenter;
                            verticalCenter: startTimeItem.verticalCenter;
                        }
                    }

                   ListItem.Empty {
                        id: endTimeItem
                        highlightWhenPressed: false
                        anchors.right: timeContainer.right
                        width: units.gu(12)
                        Button {
                            objectName: "endTimeInput"
                            id: endTimeButton
                            text: Qt.formatDateTime(endDate,"hh:mm")
                            anchors {
                                fill: parent
                                margins: units.gu(1)
                            }
                            onClicked: {
                                internal.clearFocus()
                                var popupObj = PopupUtils.open(timePicker);
                                popupObj.accepted.connect(function(endHour, endMinute) {
                                    var newDate = endDate;
                                    newDate.setHours(endHour, endMinute);
                                    endDate = newDate;
                                })
                            }
                        }
                    }
                }
            }
        }

        ListItem.Header { text: i18n.tr("Location & People") }
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

        ListItem.Empty {
            highlightWhenPressed: false
            Dialog {
                id: errorPopupDialog
                title: i18n.tr("Error")
                text: ""
                Button {
                    text: i18n.tr("Ok")
                    onClicked: PopupUtils.close(errorPopupDialog)
                }
            }
            Button {
                objectName: "eventSaveButton"
                text: i18n.tr("Save")
                anchors {
                    fill: parent
                    margins: units.gu(1)
                }

                onClicked: {
                    internal.clearFocus()

                    var error = 0;

                    if (startDate > endDate)
                        error = 2;

                    startDate.setDate(defaultDate.getDate());
                    endDate.setDate(defaultDate.getDate());

                    var event = {
                        title: titleEdit.text,
                        message: null,
                        startTime: startDate.getTime(),
                        endTime: endDate.getTime()
                    }

                    if (!error) {
                        DataService.addEvent(event);
                        PopupUtils.close(popover);
                    } else {
                        errorText = i18n.tr("End time can't be before start time");
                        errorPopupDialog.show();
                    }

                    error = 0;
                }
            }
        }
    }

    QtObject {
        id: internal

        function clearFocus() {
            Qt.inputMethod.hide()
            titleEdit.focus = false
            locationEdit.focus = false
            personEdit.focus = false
        }
    }
}
