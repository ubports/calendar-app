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
import QtQuick.Layouts 1.1

import "ViewType.js" as ViewType

Column {
    id: headerRoot

    property int type: ViewType.ViewTypeWeek
    property date startDay;
    property double contentX;
    property int firstDayOfWeek: Qt.locale().firstDayOfWeek
    property bool isActive: false;
    property var selectedDay;

    signal dateSelected(var date);
    signal dateHighlighted(var date);

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
                objectName: "weeknumber"

                // TRANSLATORS: W refers to Week, followed by the actual week number (%1)
                text: i18n.tr("W%1").arg(startDay.weekNumber(Qt.locale().firstDayOfWeek))
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
                id: dayAllDayComp
                type: ViewType.ViewTypeDay
                startDay: headerRoot.startDay
                model: mainModel
                width: parent.width
                height: units.gu(5)

                Connections{
                    target: mainModel
                    onModelChanged : {
                        dayAllDayComp.createAllDayEvents();
                    }
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
                    isCurrentItem: root.isActive
                    selectedDay: {
                        if( root.selectedDay && startDay.weekNumber(Qt.locale().firstDayOfWeek)
                                === root.selectedDay.weekNumber(Qt.locale().firstDayOfWeek)) {
                        root.selectedDay;
                        } else {
                            null;
                        }
                    }

                    onDateSelected: {
                        root.dateSelected(date);
                    }

                    onDateHighlighted: {
                        root.dateHighlighted(date);
                    }
                }

                SimpleDivider{}

                AllDayEventComponent {
                    id: weekAllDayComp
                    type: ViewType.ViewTypeWeek
                    startDay: headerRoot.startDay
                    width: parent.width
                    height: units.gu(5)
                    model: mainModel

                    Connections{
                        target: mainModel
                        onModelChanged : {
                            weekAllDayComp.createAllDayEvents();
                        }
                    }
                }
            }
        }
    }
}

