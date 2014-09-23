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
import Ubuntu.Components.Popups 1.0

import "dateExt.js" as DateExt
import "ViewType.js" as ViewType

Item {
    id: root

    property var allDayEvents;
    property var startDay: DateExt.today();
    property var model;

    property int type: ViewType.ViewTypeWeek

    width: parent.width

    function getAllDayEvents(startDate, endDate) {
        var map = {};
        var items = model.getItems(startDate,endDate);
        for(var i = 0 ; i < items.length ; ++i) {
            var event = items[(i)];
            if( event && event.allDay ) {
                var key  = Qt.formatDateTime(event.startDateTime, "dd-MMM-yyyy");
                if( !(key in map)) {
                    map[key] = [];
                }
                map[key].push(event);
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
        model: type == ViewType.ViewTypeWeek ? 7 : 1
        delegate: Button {
            id: allDayButton

            property var events;
            gradient: UbuntuColors.orangeGradient
            function getPosition(){
                var sd = startDay.midnight();
                sd = sd.addDays(index);
                if(Qt.formatDateTime(sd, "ddd") === "Sun"){return root.width/7*0}
                if(Qt.formatDateTime(sd, "ddd") === "Mon"){return root.width/7*1}
                if(Qt.formatDateTime(sd, "ddd") === "Tue"){return root.width/7*2}
                if(Qt.formatDateTime(sd, "ddd") === "Wed"){return root.width/7*3}
                if(Qt.formatDateTime(sd, "ddd") === "Thu"){return root.width/7*4}
                if(Qt.formatDateTime(sd, "ddd") === "Fri"){return root.width/7*5}
                if(Qt.formatDateTime(sd, "ddd") === "Sat"){return root.width/7*6}
            }
            x: if(type === ViewType.ViewTypeWeek) {getPosition()}

            clip: true
            width: parent.width/ (type == ViewType.ViewTypeWeek ? 7 : 1)
            visible: !allDayButton.events || allDayButton.events.length === 0 ? false : true

            onClicked: {
                if(!allDayButton.events || allDayButton.events.length === 0) {
                    return;
                }

                if(type == ViewType.ViewTypeWeek) {
                    PopupUtils.open(popoverComponent, root,{"events": allDayButton.events})
                } else {
                    if( allDayButton.events.length > 1 ) {
                        PopupUtils.open(popoverComponent, root,{"events": allDayButton.events})
                    } else {
                        pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":allDayButton.events[0],"model": root.model});
                    }
                }
            }

            Connections{
                target: root
                onAllDayEventsChanged:{
                    var sd = startDay.midnight();
                    sd = sd.addDays(index);
                    var key  = Qt.formatDateTime(sd, "dd-MMM-yyyy");
                    events = allDayEvents[key];

                    if(!events || events.length === 0) {
                        text = "";
                        return;
                    }

                    if(type == ViewType.ViewTypeWeek) {
                        // TRANSLATORS: the first parameter refers to the number of all-day events
                        // on a given day. "Ev." is short form for "Events".
                        // Please keep the translation of "Ev." to 3 characters only, as the week view
                        // where it's shown has limited space
                        text =  i18n.tr("%1 Ev.").arg(events.length)
                    } else {
                        if( events.length > 1) {
                            text = i18n.tr("%1 All day events").arg(events.length)
                        } else {
                            text = events[0].displayLabel;
                        }
                    }
                }
            }
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
