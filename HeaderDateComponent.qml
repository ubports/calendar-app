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
import Ubuntu.Components 1.3

Item {
    id: root

    // Property to set the day and date
    property var date;

    // Property to set the font color of the day label
    property alias dayColor: dayLabel.color

    // Property to set the time format of the day label
    property int dayFormat: Locale.ShortFormat

    // Signal fired when pressing on the date
    signal dateSelected(var date)

    property bool highlighted: false

    width: dayLabel.paintedWidth
    height: dateContainer.height

    Rectangle{
        id: background
        color: "transparent"
        visible: highlighted
        anchors.fill: parent
        border.width: units.gu(0.3)
        border.color: UbuntuColors.orange
    }

    Column {
        id: dateContainer
        objectName: "dateContainer"

        width: dayLabel.paintedWidth
        spacing: units.gu(0.2)

        anchors.centerIn: parent

        Label{
            id: dayLabel
            objectName: "dayLabel"
            text: Qt.locale().standaloneDayName(date.getDay(), dayFormat)
            font.bold: true
        }

        Label{
            id: dateLabel
            objectName: "dateLabel"
            text: date.getDate();
            color: dayLabel.color
            anchors.horizontalCenter: dayLabel.horizontalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.dateSelected(date);
        }
    }
}
