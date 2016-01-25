/*
 * Copyright (C) 2012-2015 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.0 as ListItem

ListItem.Standard {
   id: root

   property alias iconSource: uShape.source
   property alias labelText: name.text

   Image {
       id: uShape

       width: parent.height - units.gu(2)
       height: width

       anchors {
           left: parent.left
           leftMargin: units.gu(2)
           verticalCenter: parent.verticalCenter
       }
   }

   Label {
       id: name

       anchors {
           left: uShape.right
           margins: units.gu(2)
           verticalCenter: parent.verticalCenter
       }
       color: UbuntuColors.midAubergine
       elide: Text.ElideRight
   }
}
