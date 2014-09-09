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

import "dateExt.js" as DateExt
import "ViewType.js" as ViewType


Row{
    id: header

    property int type: ViewType.ViewTypeWeek

    property var startDay: DateExt.today();
    property bool isCurrentItem: false

    signal dateSelected(var date);

    width: parent.width

    Repeater{
        model: type == ViewType.ViewTypeWeek ? 7 : 1

        delegate: HeaderDateComponent{
            date: startDay.addDays(index);
            dayFormat: {
                if( type == ViewType.ViewTypeWeek || (type == ViewType.ViewTypeDay && !header.isCurrentItem) ) {
                    Locale.ShortFormat
                } else {
                    Locale.LongFormat
                }
            }

            dateColor: {
                if( type == ViewType.ViewTypeWeek && date.isSameDay(DateExt.today())){
                    "#5D5D5D"
                } else if( type == ViewType.ViewTypeDay && header.isCurrentItem ) {
                    "#5D5D5D"
                } else {
                    "#AEA79F"
                }
            }

            width: {
                if( type == ViewType.ViewTypeWeek ) {
                    header.width/7
                } else {
                    header.width
                }
            }

            onDateSelected: {
                header.dateSelected(date);
            }
        }
    }
}

