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
import QtOrganizer 5.0
import Ubuntu.Components 1.1
import "dateExt.js" as DateExt

Page{
    id: root
    objectName: "AgendaView"

    property var currentDay: new Date()

    signal dateSelected(var date);

    Keys.forwardTo: [eventList]

    function goToBeginning() {
        eventList.positionViewAtBeginning();
    }

    function hasEnabledCalendars() {
        var enabled_calendars = eventListModel.getCollections().filter( function( item ) {
            return item.extendedMetaData( "collection-selected" );
        } );

        return !!enabled_calendars.length;
    }

    Action {
        id: calendarTodayAction
        objectName:"todaybutton"
        iconName: "calendar-today"
        text: i18n.tr("Today")
        onTriggered: {
            currentDay = new Date()
            goToBeginning()
        }
    }

    head.actions: [
        calendarTodayAction,
        commonHeaderActions.newEventAction,
        commonHeaderActions.showCalendarAction,
        commonHeaderActions.reloadAction
    ]

    EventListModel {
        id: eventListModel
        startPeriod: currentDay.midnight();
        endPeriod: currentDay.addDays(30).endOfDay()
        filter: eventModel.filter

        sortOrders: [
            SortOrder{
                blankPolicy: SortOrder.BlanksFirst
                detail: Detail.EventTime
                field: EventTime.FieldStartDateTime
                direction: Qt.AscendingOrder
            }
        ]
    }

    ActivityIndicator {
        visible: running
        running: eventListModel.isLoading
        anchors.centerIn: parent
        z:2
    }

    Label {
        id: noEventsOrCalendarsLabel
        text: {
            var default_title = i18n.tr( "No upcoming events" );

            if ( !root.hasEnabledCalendars() ) {
                default_title = i18n.tr("You have no calendars enabled")
            }

            return default_title;
        }
        visible: !root.hasEnabledCalendars() || !eventListModel.itemCount
        anchors.centerIn: parent
    }

    Button {
        text: i18n.tr( "Enable calendars" )
        visible: !root.hasEnabledCalendars()
        anchors.top: noEventsOrCalendarsLabel.bottom
        anchors.horizontalCenter: noEventsOrCalendarsLabel.horizontalCenter
        anchors.topMargin: units.gu( 1.5 )
        color: UbuntuColors.orange

        onClicked: {
            pageStack.push(Qt.resolvedUrl("CalendarChoicePopup.qml"),{"model":eventModel});
            pageStack.currentPage.collectionUpdated.connect(eventModel.delayedApplyFilter);
        }
    }

    ListView{
        id: eventList
        model: eventListModel
        anchors.fill: parent
        visible: eventListModel.itemCount > 0

        delegate: listDelegate
    }

    Scrollbar{
        flickableItem: eventList
        align: Qt.AlignTrailing
    }

    Component{
        id: listDelegate

        Item {
            id: root
            property var event: eventListModel.items[index];

            width: parent.width
            height: container.height

            onEventChanged: {
                setDetails();
            }

            function setDetails() {
                if(event === null || event === undefined) {
                    return;
                }

                headerContainer.visible = false;
                if( index == 0 ) {
                    headerContainer.visible = true;
                } else {
                    var prevEvent = eventListModel.items[index-1];
                    if( prevEvent.startDateTime.midnight() < event.startDateTime.midnight()) {
                        headerContainer.visible = true;
                    }
                }

                var date = event.startDateTime.toLocaleDateString()
                var startTime = event.startDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                var endTime = event.endDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)

                // TRANSLATORS: the first argument (%1) refers to a start time for an event,
                // while the second one (%2) refers to the end time
                var timeString = i18n.tr("%1 - %2").arg(startTime).arg(endTime)

                header.text = date
                timeLabel.text = timeString

                if( event.displayLabel) {
                    titleLabel.text = event.displayLabel;
                }
            }

            Column {
                id: container

                width: parent.width
                height: detailsContainer.height + headerContainer.height +
                        (headerContainer.visible ? units.gu(2) : units.gu(0.5))

                spacing: headerContainer.visible ? units.gu(1) : 0

                anchors.top: parent.top
                anchors.topMargin: headerContainer.visible ? units.gu(1.5) : units.gu(1)

                DayHeaderBackground{
                    id: headerContainer
                    height: visible ? header.height + units.gu(1) : 0
                    width: parent.width
                    Label{
                        id: header
                        width: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(1)
                        color: "white"
                    }

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            dateSelected(event.startDateTime);
                        }
                    }
                }

                UbuntuShape{
                    id: detailsContainer
                    color: backgroundColor

                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - units.gu(4)
                    height: detailsColumn.height + units.gu(1)

                    states: [
                        State {
                            name: "selected"

                            PropertyChanges {
                                target: detailsContainer
                                color: UbuntuColors.orange
                            }

                            PropertyChanges {
                                target: timeLabel
                                color: "white"
                            }
                        }

                    ]

                    Behavior on color {
                        ColorAnimation {
                            duration: 50
                        }
                    }

                    Column{
                        id: detailsColumn

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: units.gu(0.5)

                        spacing: units.gu(0.5)

                        Row{
                            width: parent.width
                            Label{
                                id: timeLabel
                                color:"gray"
                                width: parent.width - rect.width
                            }
                            Rectangle{
                                id:rect
                                width: units.gu(1)
                                radius: width/2
                                height: width
                                color: "#715772"
                            }
                        }
                        Label{
                            id: titleLabel
                            color:"black"
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            width: parent.width

                            Behavior on color {
                                ColorAnimation {
                                    duration: 50
                                }
                            }
                        }
                    }

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("EventDetails.qml"), {"event":event,"model":eventListModel});
                        }

                        onPressed: {
                            parent.state = "selected"
                        }

                        onReleased: {
                            parent.state = ""
                        }
                    }
                }
            }
        }
    }
}
