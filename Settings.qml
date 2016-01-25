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
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem

Page {
    id: root
    objectName: "settings"

    visible: false
    title: i18n.tr("Settings")

    head {
        backAction: Action {
            text: i18n.tr("Back")
            iconName: "back"
            onTriggered: {
                pop();
            }
        }
    }

    ListModel{
        id: model;
    }

    Column {
        id: settingsColumn
        objectName: "settingsColumn"
        spacing: units.gu(0.5)
        anchors {
            margins: units.gu(2)
            fill: parent
        }

        Item{
            width: parent.width;
            height: Math.max(weekNumber.height, weekCheckBox.height)

            Label{
                id: weekNumber;
                objectName: "weekNumber"
                text: i18n.tr("Show week numbers");
                elide: Text.ElideRight
                opacity: weekCheckBox.checked ? 1.0 : 0.8
                color: UbuntuColors.midAubergine
                anchors {
                    left: parent.left
                    right: weekCheckBox.left;
                    margins: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
            }

            CheckBox {
                id: weekCheckBox
                objectName: "weekCheckBox"
                anchors.right:parent.right;
                onCheckedChanged: {
                    mainView.displayWeekNumber = weekCheckBox.checked;
                }
            }
        }

        ListItem.ThinDivider {}
    }

    Component.onCompleted: {
        weekCheckBox.checked = mainView.displayWeekNumber;
    }
}

