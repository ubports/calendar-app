import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

import "dataService.js" as DataService

Popover {
    id: popover
    property var defaultDate;

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

                    var startDate = new Date(defaultDate);
                    var startTime = startTimeEdit.text.split(separator);

                    if (startTime.length === 2 && startTime[0].length < 3 && startTime[1].length < 3) {
                        //HH:MM format
                        startDate.setHours(startTime[0]);
                        startDate.setMinutes(startTime[1]);
                    } else if (startTime.length === 1 && startTime[0].length < 3) {
                        //HH format
                        startDate.setHours(startTime[0]);
                        startDate.setMinutes(0);

                        startTime[1] = 0;
                    } else {
                        print ('Invalid format');
                        error = 1;
                    }

                    var endDate = new Date(defaultDate);
                    var endTime = endTimeEdit.text.split(separator);

                    if (endTime.length === 2 && endTime[0].length < 3 && endTime[1].length < 3) {
                        //HH:MM format
                        endDate.setHours(endTime[0]);
                        endDate.setMinutes(endTime[1]);
                    } else if (endTime.length === 1 && endTime[0].length < 3) {
                        //HH format
                        endDate.setHours(endTime[0]);
                        endDate.setMinutes(0);

                        endTime[1] = 0;
                    } else {
                        print ('Invalid format');
                        error = 1;
                    }

                    if (startDate > endDate) {
                        print ('startTime > endTime');
                        error = 1;
                    }

                    var event = {
                        title: titleEdit.text,
                        message: null,
                        startTime: startDate.getTime(),
                        endTime: endDate.getTime()
                    }

                    if (!error)
                        DataService.addEvent(event)

                    PopupUtils.close(popover);
                }
            }
        }
    }
}
