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
import QtQuick.Layouts 1.1

import "ViewType.js" as ViewType

Column {
    id: root

    property int type: ViewType.ViewTypeWeek
    property date startDay;
    property int weekHeaderScrollX;

    signal dateSelected(var date);

    width: parent.width
    height: units.gu(10)

    Row{
        width: parent.width
        height: parent.height

        Column{
            id: labelColumn
            width : units.gu(6)

            Label{
                id: weekNumLabel
                text: "W"+ root.startDay.weekNumber()
                fontSize: "small"
                height: units.gu(5)
                width: parent.width
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle{
                height: units.gu(0.1)
                width: parent.width
                color: "#e5e2e2"
            }

            Label {
                height: units.gu(5)
                text:i18n.tr("All Day");
                fontSize: "small"
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Rectangle{
            width: units.gu(0.2)
            height: parent.height
            color: "#e5e2e2"
        }

        Column{
            width: parent.width - labelColumn.width
            height: parent.height

            Loader{
                id: headerloader
                width: parent.width
                height: units.gu(5)
                sourceComponent: {
                    if( type == ViewType.ViewTypeWeek ) {
                        weekHeaderComponent
                    } else {
                        dayHeaderComponent
                    }
                }
            }


            Rectangle{
                height: units.gu(0.1)
                width: parent.width
                color: "#e5e2e2"
            }

            Loader{
                id: allDayLoader
                width: parent.width
                height: units.gu(5)
                sourceComponent: {
                    if( type == ViewType.ViewTypeWeek ) {
                        weekAllDayComponent
                    } else {
                        dayAllDayComponent
                    }
                }
            }
        }
    }

    Component {
        id: weekAllDayComponent
        Flickable{
            id: weekAllDay

            width: parent.width
            height: parent.height
            clip: true
            contentX: root.weekHeaderScrollX

            property int delegateWidth: {
                width/3 - units.gu(1) /*partial visible area*/
            }
            contentHeight: height
            contentWidth: {
                (delegateWidth*7)
            }

            AllDayEventComponent {
                type: root.type
                startDay: root.startDay
                model: mainModel

                Component.onCompleted: {
                    mainModel.addModelChangeListener(createAllDayEvents);
                }
                Component.onDestruction: {
                    mainModel.removeModelChangeListener(createAllDayEvents);
                }
            }
        }
    }

    Component {
        id: dayAllDayComponent

        AllDayEventComponent {
            type: root.type
            startDay: root.startDay
            model: mainModel
            width: parent.width
            height: parent.height

            Component.onCompleted: {
                mainModel.addModelChangeListener(createAllDayEvents);
            }
            Component.onDestruction: {
                mainModel.removeModelChangeListener(createAllDayEvents);
            }
        }
    }

    Component {
        id: weekHeaderComponent
        Flickable{
            id: weekDateHeader

            width: parent.width
            height: parent.height
            clip: true
            contentX: root.weekHeaderScrollX

            property int delegateWidth: {
                width/3 - units.gu(1) /*partial visible area*/
            }
            contentHeight: height
            contentWidth: {
                (delegateWidth*7)
            }

            TimeLineHeaderComponent{
                id: dateHeader
                startDay: root.startDay

                onDateSelected: {
                    root.dateSelected(date);
                }
            }
        }
    }

    Component {
        id: dayHeaderComponent
        TimeLineHeaderComponent{
            id: dateHeader
            width: parent.width
            height: parent.height
            startDay: root.startDay

            onDateSelected: {
                root.dateSelected(date);
            }
        }
    }
}

