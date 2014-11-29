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
    id: headerRoot

    property int type: ViewType.ViewTypeWeek
    property date startDay;
    property double contentX;

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

            SimpleDivider{}

            Label {
                height: units.gu(5)
                text: i18n.tr("All Day");
                fontSize: "small"
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        SimpleDivider{
            width: units.gu(0.1);
            height: parent.height
        }

        Loader{
            id: headerLoader
            width: parent.width - labelColumn.width
            height: parent.height

            sourceComponent: {
                if( root.type == ViewType.ViewTypeWeek ) {
                    weekHeaderComponent
                } else {
                    dayHeaderComponent
                }
            }
        }
    }

    Component{
        id: dayHeaderComponent

        Column{
            anchors.fill: parent

            TimeLineHeaderComponent{
                width: parent.width
                height: units.gu(5)
                startDay: headerRoot.startDay
                type: ViewType.ViewTypeDay

                onDateSelected: {
                    headerRoot.dateSelected(date);
                }
            }

            SimpleDivider{}

            AllDayEventComponent {
                type: ViewType.ViewTypeDay
                startDay: headerRoot.startDay
                model: mainModel
                width: parent.width
                height: units.gu(5)

                Component.onCompleted: {
                    mainModel.addModelChangeListener(createAllDayEvents);
                }
                Component.onDestruction: {
                    mainModel.removeModelChangeListener(createAllDayEvents);
                }
            }
        }
    }

    Component{
        id: weekHeaderComponent

        Flickable{
            anchors.fill: parent
            clip: true
            contentX: headerRoot.contentX
            interactive: false

            property int delegateWidth: {
                width/3 - units.gu(1) /*partial visible area*/
            }
            contentHeight: height
            contentWidth: {
                (delegateWidth*7)
            }

            Column{
                width: parent.width
                height: parent.height

                TimeLineHeaderComponent{
                    objectName: "timelineHeader"
                    startDay: headerRoot.startDay 
                    type: ViewType.ViewTypeWeek
                    width: parent.width
                    height: units.gu(5)

                    onDateSelected: {
                        root.dateSelected(date);
                    }
                }

                SimpleDivider{}

                AllDayEventComponent {
                    type: ViewType.ViewTypeWeek
                    startDay: headerRoot.startDay
                    width: parent.width
                    height: units.gu(5)
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
    }
}

