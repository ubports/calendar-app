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

Column {
    width: parent.width

    Repeater {
        model: 24 // hour in a day

        delegate: Rectangle {
            width: parent.width
            height: units.gu(10)
            color: (index % 2 == 0) ? "#F5F5F5" : "#ECECEC"

            Label {
                id: timeLabel

                text: {
                    var locale = Qt.locale()
                    return new Date(0, 0, 0, index).toLocaleTimeString
                            (locale, locale.timeFormat(Locale.NarrowFormat))
                }

                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                color: UbuntuColors.lightGrey
                fontSize: "small"
            }
        }
    }
}
