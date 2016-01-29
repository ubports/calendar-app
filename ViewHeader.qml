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

Item{
    id: header
    width: parent.width
    height: monthLabel.height

    property int month;
    property int year;

    property string monthLabelFontSize: "large"
    property string yearLabelFontSize: "large"

    Label{
        id: monthLabel
        objectName: "monthLabel"
        fontSize: monthLabelFontSize
        text: Qt.locale().standaloneMonthName(month)
        anchors.leftMargin: units.gu(1)
        anchors.left: parent.left
        color:"black"
        anchors.verticalCenter: parent.verticalCenter
    }

    Label{
        id: yearLabel
        objectName: "yearLabel"
        fontSize: yearLabelFontSize
        text: year
        anchors.right: parent.right
        anchors.rightMargin: units.gu(1)
        color:"black"
        anchors.verticalCenter: parent.verticalCenter
    }
}
