/*
 * Copyright (C) 2013-2016 Canonical Ltd
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
import QtOrganizer 5.0
import Ubuntu.Components 1.3
import Ubuntu.SyncMonitor 0.1
import Ubuntu.Components.Popups 1.3

Page {
    id: calendarChoicePage
    objectName: "calendarchoicepopup"

    property var model
    signal collectionUpdated()

    visible: false
    header: PageHeader {
        title: i18n.tr("Calendars")
        leadingActionBar.actions: Action {
            text: i18n.tr("Back")
            iconName: "back"
            onTriggered: {
                calendarChoicePage.collectionUpdated();
                pop();
            }
        }
        trailingActionBar.actions: Action {
            objectName: "syncbutton"
            iconName: "reload"
            // TRANSLATORS: Please translate this string  to 15 characters only.
            // Currently ,there is no way we can increase width of action menu currently.
            text: enabled ? i18n.tr("Sync") : i18n.tr("Syncing")
            onTriggered: syncMonitor.sync(["calendar"])
            enabled: (syncMonitor.state !== "syncing")
            visible: syncMonitor.enabledServices ? syncMonitor.serviceIsEnabled("calendar") : false
        }
    }

    SyncMonitor {
        id: syncMonitor
    }

    ListView {
        id: calendarsList

        anchors { top: calendarChoicePage.header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }

        header: ListItem {
            id: importFromGoogleButton

            visible: (onlineAccountHelper.status === Loader.Ready)
            height: onlineCalendarLayout.height + divider.height

            ListItemLayout {
                id: onlineCalendarLayout
                title.text: i18n.tr("Add online Calendar")

                Image {
                    SlotsLayout.position: SlotsLayout.First
                    source: "image://theme/google"
                    width: units.gu(5)
                    height: width
                }
            }

            onClicked: {
                onlineAccountHelper.item.setupExec()
            }
        }

        model : calendarChoicePage.model.getCollections()
        currentIndex: -1

        delegate: ListItem {
            id: delegateComp
            objectName: "calendarItem"

            height: calendarsListLayout.height + divider.height

            ListItemLayout {
                id: calendarsListLayout

                title.text: modelData.name
                title.objectName: "calendarName"

                CheckBox {
                    id: checkBox
                    objectName: "checkBox"
                    SlotsLayout.position: SlotsLayout.Last
                    checked: modelData.extendedMetaData("collection-selected")
                    enabled: !calendarChoicePage.isInEditMode
                    onCheckedChanged: {
                        if (!checkBox.checked && modelData.extendedMetaData("collection-readonly") === false) {
                           var collections = calendarChoicePage.model.getWritableAndSelectedCollections();
                           if (collections.length == 1) {
                               PopupUtils.open(singleWritableDialogComponent);
                               checkBox.checked = true;
                               return;
                           }
                        }

                        modelData.setExtendedMetaData("collection-selected",checkBox.checked)
                        var collection = calendarChoicePage.model.collection(modelData.collectionId);
                        calendarChoicePage.model.saveCollection(collection);
                    }
                }

                Rectangle {
                    id: calendarColorCode
                    objectName: "calendarColorCode"

                    SlotsLayout.position: SlotsLayout.First
                    width: units.gu(5)
                    height: width
                    color: modelData.color
                    opacity: checkBox.checked ? 1.0 : 0.8

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            //popup dialog
                            var dialog = PopupUtils.open(Qt.resolvedUrl("ColorPickerDialog.qml"),calendarChoicePage);
                            dialog.accepted.connect(function(color) {
                                var collection = calendarChoicePage.model.collection(modelData.collectionId);
                                collection.color = color;
                                calendarChoicePage.model.saveCollection(collection);
                            })
                        }
                    }
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

    Component {
        id: singleWritableDialogComponent 
        Dialog {
            id: singleWritableDialog
            title: i18n.tr("Unable to deselect")
            text: i18n.tr("In order to create new events you must have at least one writable calendar selected")
            Button {
                text: i18n.tr("Ok")	
                onClicked: PopupUtils.close(singleWritableDialog)
            }
        }
    }
}
