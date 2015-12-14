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
import "dateExt.js" as DateExt
import "ViewType.js" as ViewType

Row{
    id: header

    property int type: ViewType.ViewTypeWeek

    property var startDay: DateExt.today();
    property bool isCurrentItem: false
    property var currentDay

    property int highlightedIndex;
    property var selectedDay;

    signal dateSelected(var date);
    signal dateHighlighted(var date);

    width: parent.width
    height: units.gu(4)

    function findSelectedDayIndex() {
        if(!selectedDay){
            return -1;
        }
        return DateExt.daysBetween(startDay, selectedDay);
    }

    onIsCurrentItemChanged: {
        highlightedIndex = -1
    }

    onSelectedDayChanged: {
        if(isCurrentItem){
            highlightedIndex = findSelectedDayIndex()
        }
    }

    Repeater{
        model: type == ViewType.ViewTypeWeek ? 7 : 1

        delegate: HeaderDateComponent{
            date: type == ViewType.ViewTypeWeek ? startDay.addDays(index) : startDay
            dayFormat: Locale.ShortFormat
            highlighted: (type == ViewType.ViewTypeWeek) && (highlightedIndex === index)

            dayColor: {
                if( type == ViewType.ViewTypeWeek && date.isSameDay(DateExt.today())){
                    //header.highlightedIndex = index
                    UbuntuColors.orange
                } /*else if( type == ViewType.ViewTypeDay && date.isSameDay(currentDay) ) {
                    UbuntuColors.orange
                } */ else {
                    UbuntuColors.darkGrey
                }
            }

            width: type == ViewType.ViewTypeWeek ? ( header.width/7) : header.width
            height: header.height

            onDateSelected: {
                if( type == ViewType.ViewTypeDay ){
                    header.dateSelected(date);
                } else {
                    if(highlighted) {
                        header.dateSelected(date);
                    } else {
                        header.highlightedIndex = index
                        header.dateHighlighted(date);
                    }
                }
            }

            Loader{
                objectName: "divider"
                height: parent.height
                width: units.gu(0.1)
                sourceComponent: type == ViewType.ViewTypeWeek ? dividerComponent : undefined
            }

            Component {
                id: dividerComponent
                SimpleDivider{
                    anchors.fill: parent
                }
            }
        }
    }
}

