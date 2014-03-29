import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

import "dateExt.js" as DateExt
import "GlobalEventModel.js" as GlobalModel
import "ViewType.js" as ViewType

Rectangle{
    id: root

    property var allDayEvents;
    property var startDay: DateExt.today();

    property int type: ViewType.ViewTypeWeek

    height: units.gu(6)
    width: parent.width
    color: "#105040"

    function getAllDayEvents(startDate, endDate) {
        var map = {};
        var itemIds = GlobalModel.globalModel().itemIds(startDate, endDate);
        for(var i = 0 ; i < itemIds.length ; ++i) {
            var eventId = itemIds[(i)];
            var event = GlobalModel.globalModel().item(eventId);            
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

    Component.onCompleted: {
        var model = GlobalModel.globalModel();
        model.reloaded.connect(root.createAllDayEvents);
    }

    onStartDayChanged: {
        createAllDayEvents();
    }

    Row {
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter

        Repeater{
            model: type == ViewType.ViewTypeWeek ? 7 : 1
            delegate: Label{
                id: allDayLabel

                property var events;

                clip: true
                width: parent.width/ (type == ViewType.ViewTypeWeek ? 7 : 1)
                horizontalAlignment: Text.AlignHCenter

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if(!allDayLabel.events || allDayLabel.events.length === 0) {
                            return;
                        }

                        if(type == ViewType.ViewTypeWeek) {
                            PopupUtils.open(popoverComponent, root,{"events": allDayLabel.events})
                        } else {
                            if( allDayLabel.events.length > 1 ) {
                                PopupUtils.open(popoverComponent, root,{"events": allDayLabel.events})
                            } else {
                                pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":allDayLabel.events[0]});
                            }
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
                            text =  i18n.tr("%1E").arg(events.length)
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
                            pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":modelData});
                        }
                    }
                }
            }
        }
    }
}
