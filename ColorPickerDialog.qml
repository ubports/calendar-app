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

Dialog {
    id: root
    title: i18n.tr("Select Color")
    signal accepted(var color)
    signal rejected()

    contents: [
        Grid{
            height: units.gu(15)
            rows: 2
            columns: 4
            spacing: units.gu(10)
            Repeater{
                model: ["#2C001E","#333333","#DD4814","#DF382C","#EFB73E","#19B6EE","#38B44A","#001F5C"];
                delegate:Rectangle{
                    width: parent.width/5
                    height: width
                    color: modelData
                    radius : units.gu(10)
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            root.accepted(modelData)
                            PopupUtils.close(root)
                        }
                    }
                }
            }
        },
        Button {
            objectName: "TimePickerCancelButton"
            text: i18n.tr("Cancel")
            onClicked: {
                root.rejected()
                PopupUtils.close(root)
            }
            width: (parent.width) / 2
        }
    ]
}
