/*
 * Copyright (C) 2013-2016 Canonical Ltd
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
import QtOrganizer 5.0
import Ubuntu.Components 1.3
import "dateExt.js" as DateExt
import "./3rd-party/lunar.js" as Lunar

PageWithBottomEdge {
    id: root
    objectName: "AgendaView"

    property var anchorDate: new Date()

    signal dateSelected(var date)

    function goToBeginning() {
        eventList.positionViewAtBeginning();
    }

    function hasEnabledCalendars() {
        var enabled_calendars = eventListModel.getCollections().filter( function( item ) {
            return item.extendedMetaData( "collection-selected" );
        } );

        return !!enabled_calendars.length;
    }

    Keys.forwardTo: [eventList]
    createEventAt: anchorDate

    // Page Header
    header: PageHeader {
        title: i18n.tr("Agenda")

        extension: HeaderSections {}
        trailingActionBar.actions: [
            commonHeaderActions.settingsAction,
        ]
        flickable: eventList
    }

    // make sure that the model is updated after create a new event if it is marked as auto-update false
    onEventSaved: eventListModel.updateIfNecessary()
    onEventDeleted: eventListModel.updateIfNecessary()


    // ListModel to hold all events for upcoming 7days.
    EventListModel {
        id: eventListModel
        objectName: "agendaEventListModel"

        startPeriod: anchorDate.midnight();
        endPeriod: anchorDate.addDays(7).endOfDay()
        filter: model.filter
        active: root.tabSelected && root.active
        sortOrders: [
            SortOrder{
                blankPolicy: SortOrder.BlanksFirst
                detail: Detail.EventTime
                field: EventTime.FieldStartDateTime
                direction: Qt.AscendingOrder
            }
        ]
    }

    // spinner. running while agenda is loading.
    ActivityIndicator {
        z:2
        visible: running
        running: eventListModel.isLoading
        anchors.centerIn: parent
    }

    // Label to be shown when there is no upcoming events or if no calendar is selected.
    Label {
        id: noEventsOrCalendarsLabel
        anchors.centerIn: parent
        visible: (eventList.itemCount === 0) && !eventListModel.isLoading
        text: !root.hasEnabledCalendars() ? i18n.tr("You have no calendars enabled") : i18n.tr( "No upcoming events" )
    }

    // button to be shown when no calendar is selected (onClick will take user to list of all calendars)
    Button {
        anchors {
            top: noEventsOrCalendarsLabel.bottom;
            horizontalCenter: noEventsOrCalendarsLabel.horizontalCenter;
            topMargin: units.gu(1.5)
        }
        color: UbuntuColors.orange
        visible: !root.hasEnabledCalendars()
        text: i18n.tr( "Enable calendars" )

        onClicked: {
            pageStack.push(Qt.resolvedUrl("CalendarChoicePopup.qml"),{"model": model});
            pageStack.currentPage.collectionUpdated.connect(model.delayedApplyFilter);
        }
    }

    // Main ListView with all upcoming events.
    ListView {
        id: eventList
        objectName: "eventList"

        anchors{
            fill: parent
            bottomMargin: root.bottomEdgeHeight
        }
        visible: eventListModel.itemCount > 0
        model: eventListModel
        delegate: listDelegate
    }

    // Scrollbar
    Scrollbar{
        flickableItem: eventList
        align: Qt.AlignTrailing
    }

    // ListView delegate
    Component{
        id: listDelegate

        // Main item to hold listitem delegate.
        Item {
            property var event: eventListModel.items[index];
            property var prevEvent: eventListModel.items[index-1];
            property var date: event.startDateTime.toLocaleDateString()
            property var startTime: event.startDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
            property var endTime: event.endDateTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
            property var lunarDate: Lunar.calendar.solar2lunar(event.startDateTime.getFullYear(),
                                                               event.startDateTime.getMonth() + 1,
                                                               event.startDateTime.getDate())

            width: parent.width
            height: eventContainer.height

            // main Column to hold   header-(date) and event details-(start/end time, Description and location)
            Column {
                id: eventContainer
                objectName: "eventContainer" + index

                width: parent.width
                anchors.top: parent.top

                // header ListItem eg. ( Friday, October 29th 2015 )
                ListItem {
                    width: parent.width
                    height: visible ? units.gu(4) : 0
                    color: theme.palette.nromal.backgroundSecondaryText
                    highlightColor: theme.palette.highlighted.background
                    visible: index === 0 ? true : prevEvent === undefined ? false : prevEvent.startDateTime.midnight() < event.startDateTime.midnight() ? true : false

                    ListItemLayout {
                        id: listitemlayout
                        padding.top: units.gu(1)
                        title.text: mainView.displayLunarCalendar ? ("%1 %2 %3 %4 %5").arg(lunarDate.gzYear).arg(lunarDate .IMonthCn).arg(lunarDate.IDayCn)
                                                                                      .arg(lunarDate.gzDay).arg(lunarDate.isTerm ? lunarDate.Term : "")
                                                                  : date
                        title.color: event.startDateTime.toLocaleDateString() === new Date().toLocaleDateString() ? UbuntuColors.orange : UbuntuColors.darkGrey
                    }

                    // onClicked new page with daily view will open.
                    onClicked: {
                        Haptics.play()
                        dateSelected(event.startDateTime);
                    }
                }

                // Main ListItem to hold details about event eg. ( 19:30 -   Beer with the team )
                //                                               ( 20:00     Hicter             )
                ListItem {
                    id: detailsListItem

                    width: parent.width
                    height: detailsListitemlayout.height
                    color: theme.palette.nromal.backgroundText
                    highlightColor: theme.palette.highlighted.background

                    ListItemLayout {
                        id: detailsListitemlayout

                        title.font.bold: true
                        title.text: event.displayLabel ? event.displayLabel : i18n.tr("no event name set")
                        subtitle.font.pixelSize: title.font.pixelSize
                        subtitle.text: event.location ? event.location : i18n.tr("no location")
                        subtitle.color: event.location ? UbuntuColors.coolGrey : theme.palette.disabled.backgroundText
                        subtitle.font.italic: event.location ? false : true


                        // item to hold SlotsLayout.Leading items: timeStart timeEnad and little calendar indication icon.
                        Item {
                            width: timeLabelStart.width + units.gu(2)
                            height: parent.height
                            SlotsLayout.overrideVerticalPositioning: true
                            SlotsLayout.position: SlotsLayout.Leading

                            // Little icon in left top corner of every event to indicate color of the calendar.
                            UbuntuShape {
                                id: calendarIndicator

                                anchors.verticalCenter: parent.verticalCenter
                                width: units.gu(1)
                                height: width
                                aspect: UbuntuShape.DropShadow
                                backgroundColor: eventListModel.collection(event.collectionId).color
                            }

                            // start time event Label
                            Label {
                                id: timeLabelStart

                                anchors {left: calendarIndicator.right; leftMargin: units.gu(1)}
                                fontSize: "small"
                                y: detailsListitemlayout.mainSlot.y + detailsListitemlayout.title.y
                                   + detailsListitemlayout.title.baselineOffset - baselineOffset
                                text: startTime.concat('-')
                            }

                            // finish time event Label
                            Label {
                                id: timeLabelEnd

                                anchors {left: calendarIndicator.right; leftMargin: units.gu(1)}
                                fontSize: "small"
                                y: detailsListitemlayout.mainSlot.y + detailsListitemlayout.subtitle.y
                                   + detailsListitemlayout.subtitle.baselineOffset - baselineOffset;
                                text: endTime
                            }
                        }

                    }

                    // new page will open to edit selected event
                    onClicked: {
                        Haptics.play()
                        pageStack.push(Qt.resolvedUrl("EventDetails.qml"), {"event":event,"model":eventListModel});
                    }
                }
            }
        }
    }
}
