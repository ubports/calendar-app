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
import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import QtOrganizer 5.0
import Ubuntu.SyncMonitor 0.1

Page {
    id: root

    property var model;

    signal collectionUpdated();

    visible: false
    title: i18n.tr("Calendars")

    head {
        backAction: Action {
            text: i18n.tr("Back")
            iconName: "back"
            onTriggered: {
                root.collectionUpdated();
                pop();
            }
        }
    }

    head.actions:  Action {
        objectName: "syncbutton"
        iconName: "reload"
        // TRANSLATORS: Please translate this string  to 15 characters only.
        // Currently ,there is no way we can increase width of action menu currently.
        text: enabled ? i18n.tr("Sync") : i18n.tr("Syncing")
        onTriggered: syncMonitor.sync(["calendar"])
        enabled: (syncMonitor.state !== "syncing")
        visible: syncMonitor.enabledServices ? syncMonitor.serviceIsEnabled("calendar") : false
    }

    SyncMonitor {
        id: syncMonitor
    }

    ListView {
        id: calendarsList
        anchors.fill: parent
        footer: CalendarListButtonDelegate {
            id: importFromGoogleButton

            visible: (onlineAccountHelper.status === Loader.Ready)
            iconSource: "image://theme/google"
            labelText: i18n.tr("Add online Calendar")
            onClicked: {
                onlineAccountHelper.item.setupExec()
            }
        }

        model : root.model.getCollections();
        delegate: ListItem.Standard {
            id: delegateComp

            Rectangle {
                id: calendarColorCode

                width: parent.height - units.gu(2)
                height: width

                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                color: modelData.color
                opacity: checkBox.checked ? 1.0 : 0.8

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        //popup dialog
                        var dialog = PopupUtils.open(Qt.resolvedUrl("ColorPickerDialog.qml"),root);
                        dialog.accepted.connect(function(color) {
                            var collection = root.model.collection(modelData.collectionId);
                            collection.color = color;
                            root.model.saveCollection(collection);
                        })
                    }
                }
            }

            Label{
                text: modelData.name
                elide: Text.ElideRight
                opacity: checkBox.checked ? 1.0 : 0.8
                color: UbuntuColors.midAubergine
                width: parent.width - calendarColorCode.width - checkBox.width - units.gu(6) /*margins*/
                anchors {
                    left: calendarColorCode.right
                    margins: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
            }

            control: CheckBox {
                id: checkBox
                checked: modelData.extendedMetaData("collection-selected")
                enabled:  !root.isInEditMode
                onCheckedChanged: {
                    modelData.setExtendedMetaData("collection-selected",checkBox.checked)
                    var collection = root.model.collection(modelData.collectionId);
                    root.model.saveCollection(collection);
                }
            }

        }
    }

    Loader {
        id: onlineAccountHelper

        // if running on test mode does not load online account modules
        property string sourceFile: Qt.resolvedUrl("OnlineAccountsHelper.qml")

        anchors.fill: parent
        asynchronous: true
        source: sourceFile
    }
}

