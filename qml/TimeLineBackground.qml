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

Column {
    width: parent.width
    Repeater {
        model: 24 // hours in day
        delegate: Item {

            width: parent.width
            height: hourItemHeight

            Rectangle {
                height: parent.height
                width: parent.width
                color: (index < settings.businessHourStart || index > settings.businessHourEnd) ?
					calenderThemeColors.getColorFor('lesuire_time',theme.palette.normal.background ) :
					calenderThemeColors.getColorFor('buisness_time',theme.palette.normal.foreground)
                z: -1000 // its the background
            }

            SimpleDivider{}
        }
    }
}
