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

import QtQuick 2.0
import Ubuntu.Components 1.1

Flickable{
    id: timeFlickble

    height: parent.height
    width: units.gu(6)

    contentHeight: 24 * units.gu(8)
    contentWidth: width

    interactive: false

    clip: true

    Column {
        id: timeLine
        width: parent.width

        Repeater {
            model: 24 // hour in a day

            delegate: Item {
                width: parent.width
                height: units.gu(8)

                Label {
                    id: timeLabel
                    width: units.gu(5)
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(0.5)
                    horizontalAlignment: Text.AlignRight
                    text: Qt.formatTime( new Date(0,0,0,index), "hh:mm")
                    color: UbuntuColors.lightGrey
                    fontSize: "small"
                }

                SimpleDivider{}
            }
        }
    }
}
