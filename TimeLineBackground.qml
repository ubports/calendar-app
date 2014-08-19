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
import Ubuntu.Components 0.1

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

                // TRANSLATORS: this is a time formatting string,
                // see http://qt-project.org/doc/qt-5.0/qtqml/qml-qtquick2-date.html#details for valid expressions
                text: new Date(0, 0, 0, index).toLocaleTimeString(Qt.locale(), i18n.tr("hh ap"))
                color: "#5D5D5D"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                fontSize: "x-large"
                opacity: 0.3
            }
        }
    }
}
