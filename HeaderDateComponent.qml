/*
 * Copyright (C) 2014 Canonical Ltd
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
import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: root

    property var date;

    property alias dateColor: dateLabel.color
    property alias dayColor: dayLabel.color

    property int dayFormat: Locale.ShortFormat;

    signal dateSelected(var date);

    width: parent.width
    height: innerColumn.height

    Column {
        id: innerColumn
        width: parent.width
        spacing: units.gu(2)

        Label{
            id: dayLabel
            property var day: Qt.locale().standaloneDayName(date.getDay(), dayFormat)
            text: day.toUpperCase();
            fontSize: "medium"
            horizontalAlignment: Text.AlignHCenter
            color: "white"
            width: parent.width
        }

        Label{
            id: dateLabel
            objectName: "dateLabel"
            text: date.getDate();
            fontSize: "large"
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.dateSelected(date);
        }
    }
}
