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
                            text: Qt.formatDateTime(defaultDate,"hh")
                            anchors {
                                fill: parent
                                margins: units.gu(1)
                            }
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
                            text: Qt.formatDateTime(defaultDate,"hh")
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
                    var startDate = new Date(defaultDate)
                    print(startDate)
                    startDate.setHours(startTimeEdit.text)
                    print(startTimeEdit.text)

                    var endDate = new Date(defaultDate)
                    print(endDate)
                    endDate.setHours(endTimeEdit.text)
                    print(endTimeEdit.text)

                    var event = {
                        title: titleEdit.text,
                        message: null,
                        startTime: startDate.getTime(),
                        endTime: endDate.getTime()
                    }

                    DataService.addEvent(event)

                    PopupUtils.close(popover);
                }
            }
        }
    }
}
