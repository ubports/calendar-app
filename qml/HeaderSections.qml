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

ScrollView {
    width: parent.width
    height: sections.height
    anchors {
        bottom: parent.bottom
    }
    horizontalScrollbar.align: Qt.AlignLeading

    contentItem: Sections {
        id: sections
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        selectedIndex: tabs.selectedTabIndex
        Connections {
            target: tabs
            onSelectedTabIndexChanged: {
                sections.selectedIndex = tabs.selectedTabIndex
            }
        }
        actions: tabs.tabsAction

    }
}
