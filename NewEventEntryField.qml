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

TextField{
    id: root
    property alias title: label.text

    primaryItem: Label{
        id: label
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: root.highlighted ? "#2C001E" : Theme.palette.normal.baseText
    }

    color: focus ? "#2C001E" : "#5D5D5D"
    font {
        pixelSize: focus ? FontUtils.sizeToPixels("large") : FontUtils.sizeToPixels("medium")
    }

    onActiveFocusChanged: {
        if (activeFocus) {
            flickable.makeMeVisible(root)
        }
    }
}
