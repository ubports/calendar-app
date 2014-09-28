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
import "ViewType.js" as ViewType

PathViewBase {
    id: header

    property int type: ViewType.ViewTypeWeek

    interactive: false
    model:3

    height: units.gu(4)
    width: parent.width

    property var date;

    signal dateSelected(var date);

    delegate: TimeLineHeaderComponent{
        type: header.type

        isCurrentItem: index == header.currentIndex

        width: {
            if( type == ViewType.ViewTypeWeek ) {
                parent.width
            } else if( type == ViewType.ViewTypeDay && isCurrentItem ){
                (header.width/7) * 5
            } else {
                (header.width/7)
            }
        }

        startDay: type == ViewType.ViewTypeWeek ? date.addDays(7*header.indexType(index))
                                                : date.addDays(1*header.indexType(index))

        onDateSelected: {
            header.dateSelected(date);
        }
    }
}

