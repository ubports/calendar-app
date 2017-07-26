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
import Ubuntu.Components.Popups 1.3
import QtOrganizer 5.0

import "dateExt.js" as DateExt
import "ViewType.js" as ViewType

Row {
    id: root

    property var startDay: DateExt.today();
    property int type: ViewType.ViewTypeWeek
    property var allDayEvents;
    property var model;

    signal pressAndHold(var date)

    width: parent.width
    height: units.gu(5)

    function getAllDayEvents(startDate, endDate) {
        var map = {};
        var items = model.itemsByTimePeriod(startDate,endDate);
        for(var i = 0 ; i < items.length ; ++i) {
            var event = items[(i)];
            if( event && event.allDay ) {
                for(var d = event.startDateTime; d < event.endDateTime; d = d.addDays(1)) {
                    var key = Qt.formatDateTime(d, "dd-MMM-yyyy");
                    if( !(key in map)) {
                        map[key] = [];
                    }
                    map[key].push(event);
                }
            }
        }
        return map;
    }

    function createAllDayEvents() {
        if(!startDay || startDay === undefined) {
            return;
        }
        var sd = startDay.midnight();
        var ed = sd.addDays( (type == ViewType.ViewTypeDay) ? 1 : 7);
        allDayEvents = getAllDayEvents(sd,ed);
    }

    Repeater{
        id: repeater

        readonly property bool compactView: (root.width  / repeater.count) < units.gu(15)

        model: type == ViewType.ViewTypeWeek ? 7 : 1
        delegate: Item {
            id: allDayButton

            property var events;

            height: units.gu(5)
            width: parent.width / (type == ViewType.ViewTypeWeek ? 7 : 1)

            Rectangle {
                id: temporaryEvent

                anchors.fill: parent
                visible: mouseArea.mouseHold
                Label {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text:  i18n.tr("New event")
                }
                z: 100
            }

            MouseArea {
                id: mouseArea

                property bool mouseHold: false

                preventStealing: mouseHold
                anchors.fill: parent
                onClicked: {
                    if(!allDayButton.events || allDayButton.events.length === 0) {
                        return;
                    }

                    if(repeater.compactView) {
                        PopupUtils.open(popoverComponent, allDayButton,{"events": allDayButton.events})
                    } else {
                        if( allDayButton.events.length > 1 ) {
                            PopupUtils.open(popoverComponent, allDayButton,{"events": allDayButton.events})
                        } else {
                            pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":allDayButton.events[0],"model": root.model});
                        }
                    }
                }

                onReleased: {
                    if (mouseHold && containsMouse) {
                        root.pressAndHold(startDay.midnight().addDays(index))
                    }
                    mouseHold = false
                }


                onPressAndHold: {
                    mouseHold = true
                    Haptics.play()
                }
            }

            Label {
                id: eventLabel
                anchors {
                    fill: parent
                    margins: units.gu(0.5)
                }
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: {
                    if(!events || events.length === 0) {
                        return "";
                    }

                    if(repeater.compactView) {
                        // TRANSLATORS: Please keep the translation of this string to a max of
                        // 5 characters as the week view where it is shown has limited space.
                        return i18n.tr("%1 event", "%1 events", events.length).arg(events.length)
                    } else {
                        if( events.length > 1) {
                           // TRANSLATORS: the argument refers to the number of all day events
                           return i18n.tr("%1 all day event", "%1 all day events", events.length).arg(events.length)
                        } else {
                            return events[0].displayLabel;
                        }
                    }
                }
            }

            Loader{
                objectName: "divider"
                height: parent.height
                width: units.gu(0.15)
                sourceComponent: root.type == ViewType.ViewTypeWeek ? dividerComponent : undefined
            }

            Connections{
                target: root
                onAllDayEventsChanged:{
                    var sd = startDay.midnight();
                    sd = sd.addDays(index);
                    var key  = Qt.formatDateTime(sd, "dd-MMM-yyyy");
                    events = allDayEvents[key];
                }
            }
        }
    }

    Component {
        id: dividerComponent
        SimpleDivider{
            anchors.fill: parent
        }
    }

    Component {
        id: popoverComponent

        Popover {
            id: popover

            property var events;

            ListView{
                id: allDayEventsList

                property var delegateHight: units.gu(4);
                property int maxEventToDisplay: 3;

                clip: true
                visible: true
                width: parent.width
                height: ( delegateHight * (events.length > maxEventToDisplay ? maxEventToDisplay : events.length) ) + units.gu(1)
                model: popover.events
                anchors {
                    top: parent.top; topMargin: units.gu(1); bottomMargin: units.gu(1)
                }

                delegate: Label{
                    text: modelData.displayLabel;
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "black"
                    height: allDayEventsList.delegateHight

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            popover.hide();
                            pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":modelData,"model": root.model});
                        }
                    }
                }
            }
        }
    }
}
