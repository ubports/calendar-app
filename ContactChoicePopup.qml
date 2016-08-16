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
import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Components.Themes.Ambiance 1.3
import QtOrganizer 5.0
import QtContacts 5.0

import "Defines.js" as Defines

Popover {
    id: root
    objectName: "contactPopover"

    signal contactSelected(var contact, string emailAddress);

    Label {
        id: noContact
        anchors.centerIn: parent
        text: i18n.tr("No contact")
        visible: contactModel.contacts.length === 0
    }

    UnionFilter {
        id: filter

        property string searchString: ""

        filters: [
            DetailFilter{
                detail: ContactDetail.Name
                field: Name.FirstName
                matchFlags: Filter.MatchContains
                value: filter.searchString
            },
            DetailFilter{
                detail: ContactDetail.Name
                field: Name.LastName
                matchFlags: Filter.MatchContains
                value: filter.searchString
            },
            DetailFilter{
                detail: ContactDetail.DisplayLabel
                field: DisplayLabel.Label
                matchFlags: Filter.MatchContains
                value: filter.searchString
            }
        ]
    }

    ContactModel {
        id: contactModel
        manager: "galera"
        filter: filter
        autoUpdate: true
    }

    Timer {
        id: idleSearch

        interval: 500
        repeat: false
        onTriggered: {
            filter.searchString = searchBox.text
        }
    }

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: units.gu(1)

        TextField {
            id: searchBox
            objectName: "contactPopoverInput"
            focus: true
            width: parent.width
            placeholderText: i18n.tr("Search contact")
            inputMethodHints: Qt.ImhNoPredictiveText
            primaryItem: Icon {
                 height: parent.height*0.5
                 width: parent.height*0.5
                 anchors.verticalCenter: parent.verticalCenter
                 name:"find"
            }
            onTextChanged: {
                idleSearch.restart()
            }
        }

        ListView {
            id: contactList
            objectName: "contactPopoverList"
            width: parent.width
            model: contactModel
            height: units.gu(15)
            clip: true
            focus: false
            delegate: Column {
                width: contactList.width
                Repeater {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    height: childrenRect.height

                    model: Math.max(1, contact.emails.length)
                    delegate: ListItem {
                        property string emailAddress: contact.emails.length > index ? contact.emails[index].emailAddress : ""

                        activeFocusOnPress: false
                        opacity: emailAddress.length > 0 ? 1.0 : 0.3
                        width: contactList.width
                        objectName: "contactPopoverList%1".arg(index)
                        ListItemLayout {
                            title.text: contact.displayLabel.label
                            subtitle.text: emailAddress
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (emailAddress.length > 0) {
                                    root.contactSelected(contact, emailAddress);
                                    PopupUtils.close(root)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: searchBox.forceActiveFocus()
}
