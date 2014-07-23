import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Themes.Ambiance 0.1
import QtOrganizer 5.0
import QtContacts 5.0

import "Defines.js" as Defines

Popover {
    id: root

    signal contactSelected(var contact);

    Label {
        anchors.centerIn: parent
        text: i18n.tr("No contact")
        visible: contactModel.contacts.length === 0
    }

    UnionFilter {
        id: filter
        filters: [
            DetailFilter{
                detail: ContactDetail.Name
                field: Name.FirstName
                matchFlags: Filter.MatchContains
                value: searchBox.text
            },
            DetailFilter{
                detail: ContactDetail.Name
                field: Name.LastName
                matchFlags: Filter.MatchContains
                value: searchBox.text
            }
        ]
    }

    ContactModel {
        id: contactModel
        manager: "galera"
        filter: filter
        autoUpdate: true
    }

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: units.gu(1)

        NewEventEntryField{
            id: searchBox
            focus: true
            width: parent.width
            placeholderText: i18n.tr("Search contact")
            primaryItem: Image {
                 height: parent.height*0.5
                 width: parent.height*0.5
                 anchors.verticalCenter: parent.verticalCenter
                 anchors.verticalCenterOffset: -units.gu(0.2)
                 source: Qt.resolvedUrl("search.svg")
             }
        }

        ListView {
            id: contactList
            width: parent.width
            model: contactModel
            height: units.gu(30)
            clip: true
            delegate: Standard{
                property var item: contactModel.contacts[index]
                height: units.gu(4)
                text: item ? item.name.firstName + ", " + item.name.lastName : ""

                onClicked: {
                    root.contactSelected(item);
                    onClicked: PopupUtils.close(root)
                }
            }
        }
    }
}
