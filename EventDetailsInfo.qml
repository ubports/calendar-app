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
import Ubuntu.Components.Themes.Ambiance 1.0
Item
{
   property alias header: header.text
   property alias value: value.text
   property string headerColor :"black"
   property string detailColor :"grey"
   property int xMargin
   property int headerWidth: header.width
   width: parent.width
   height: header.height
   Label{
      id: header
      color: headerColor
      font.bold: true
      fontSize: "medium"
      anchors.left: parent.left
   }
   Label{
        id:value
        x: xMargin + units.gu(1)
        color: detailColor
        fontSize: "medium"
   }
}
