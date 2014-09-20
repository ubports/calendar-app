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
                pop();
            }
        }

        actions: Action {
            text: i18n.tr("Save");
            iconName: "save"
            onTriggered: {
                root.collectionUpdated();
                pop();
            }
        }
    }

    ListView {
        id: calendarsList

        anchors.fill: parent

        model : root.model.getCollections();
        delegate: ListItem.Standard {
            id: delegateComp

            UbuntuShape {
                id: calendarColorCode

                width: parent.height
                height: width - units.gu(2)

                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                color: modelData.color

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
                color: UbuntuColors.midAubergine
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
}

