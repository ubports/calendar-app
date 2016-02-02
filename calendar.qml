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
import Ubuntu.Components.Popups 1.0
import QtOrganizer 5.0
import Qt.labs.settings 1.0
import "dateExt.js" as DateExt

MainView {
    id: mainView

    property bool displayWeekNumber: false;

    // Work-around until this branch lands:
    // https://code.launchpad.net/~tpeeters/ubuntu-ui-toolkit/optIn-tabsDrawer/+merge/212496
    //property bool windowActive: typeof window != 'undefined'
    //onWindowActiveChanged: window.title = i18n.tr("Calendar")

    // Argument during startup
    Arguments {
        id: args;

        // Example of argument: calendar:///new-event

        // IMPORTANT
        // Due to bug #1231558 you have to pass arguments BEFORE app:
        // qmlscene calendar:///new-event calendar.qml

        defaultArgument.help: i18n.tr("Calendar app accept four arguments: --starttime, --endtime, --newevent and --eventid. They will be managed by system. See the source for a full comment about them");
        //defaultArgument.required: false;
        defaultArgument.valueNames: ["URL"]

        /* ARGUMENTS on startup
         * (no one is required)
         *
         * Create a new event
         * Keyword: newevent
         *
         * Create a new event. If starttime or endtime are set they are used to set start and end time of the new event.
         * It accepts no value.
         *
         *
         * Choose the view
         * Keyword: starttime
         *
         * If newevent has been called, starttime is the start time of event. Otherwise is the day on which app is focused on startup.
         * It accepts an integer value of the number of seconds since UNIX epoch in the UTC timezone.
         * 0 means today.
         *
         * Keyword: endtime
         *
         * If newevent is set it's the end time of the event, has to be > of starttime.
         * If newevent isn't set and startime is set, its value is used to choose the right view.
         * If neither of precendet flags are set, endtime is ignored.
         * It accepts an integer value of the number of seconds since UNIX epoch in the UTC timezone.
         *
         *
         * Open an existing event
         * Keyword: eventid (provisional)
         *
         * It takes a id of an event and open that event on full page
         */
        Argument {
            name: "eventid"
            required: false
            valueNames: ["EVENT_ID"]
        }
    }

    objectName: "calendar"
    applicationName: "com.ubuntu.calendar"

    width: units.gu(100)
    height: units.gu(80)
    focus: true
    Keys.forwardTo: [tabs.currentPage]

    headerColor: "#E8E8E8"
    backgroundColor: "#f5f5f5"
    footerColor: "#ECECEC"
    anchorToKeyboard: true

    Connections {
        target: UriHandler
        onOpened: {
            var uri = uris[0]
            if(uri !== undefined && url != "") {
                var commands = uri.split("://")[1].split("=");
                if(commands[0].toLowerCase() === "eventid") {
                    // calendar://eventid=??
                    if( eventModel ) {
                        eventModel.showEventFromId(commands[1]);
                    }
                }
            }
        }
    }

    PageStack {
        id: pageStack

        Component.onCompleted: push(tabs)

        // This is for wait that the app is load when newEvent is invoked by argument
        Timer {
            id: timer
            interval: 200; running: false; repeat: false
            onTriggered: {
                tabs.newEvent();
            }
        }

        // Load events after the app startup
        Timer {
            id: applyFilterTimer
            interval: 200; running: false; repeat: false
            onTriggered: {
                eventModel.applyFilterFinal();
            }
        }

        UnionFilter {
            id: itemTypeFilter
            DetailFieldFilter{
                id: eventFilter
                detail: Detail.ItemType;
                field: Type.FieldType
                value: Type.Event
                matchFlags: Filter.MatchExactly
            }

            DetailFieldFilter{
                id: eventOccurenceFilter
                detail: Detail.ItemType;
                field: Type.FieldType
                value: Type.EventOccurrence
                matchFlags: Filter.MatchExactly
            }
        }

        CollectionFilter{
            id: collectionFilter
        }

        InvalidFilter {
            id: invalidFilter
        }

        IntersectionFilter {
            id: mainFilter

            filters: [ collectionFilter, itemTypeFilter]
        }

        EventListModel{
            id: eventModel

            autoUpdate: true
            startPeriod: tabs.currentDay
            endPeriod: tabs.currentDay

            filter: invalidFilter

            function delayedApplyFilter() {
                applyFilterTimer.restart();
            }

            function applyFilterFinal() {
                var collectionIds = [];
                var collections = eventModel.getCollections();
                for(var i=0; i < collections.length ; ++i) {
                    var collection = collections[i]
                    if(collection.extendedMetaData("collection-selected") === true) {
                        collectionIds.push(collection.collectionId);
                    }
                }
                collectionFilter.ids = collectionIds;
                filter = mainFilter
            }

            function showEventFromId(eventId) {
                if(eventId === undefined || eventId === "") {
                    return;
                }

                var requestId = "";
                var callbackFunc = function(id,fetchedItems) {
                    if( requestId === id && fetchedItems.length > 0 ) {
                        pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":fetchedItems[0],"model": eventModel});
                    }
                    eventModel.onItemsFetched.disconnect( callbackFunc );
                }

                eventModel.onItemsFetched.connect( callbackFunc );
                requestId = eventModel.fetchItems(eventId);
            }

            Component.onCompleted: {
                delayedApplyFilter();

                if (args.values.eventid) {
                    showEventFromId(args.values.eventid);
                }
            }
        }


        EventActions {
            id: commonHeaderActions
        }

        Settings {
            id: settings
            property alias defaultViewIndex: tabs.selectedTabIndex
            property alias showWeekNumber: mainView.displayWeekNumber
        }

        Tabs{
            id: tabs
            Keys.forwardTo: [tabs.currentPage]

            property bool isReady: false
            property var currentDay: DateExt.today();
            property var selectedDay;

            // Arguments on startup
            property bool newevent: false;
            property int starttime: -1;
            property int endtime: -1;

            function newEvent() {
                var startDate = new Date();
                var endDate = new Date();
                var startTime;
                var endTime;

                if (starttime === 0) { // startime 0 means now
                    if (endtime !== -1) { // If also endtime has been invoked
                        endTime = parseInt(endtime);
                        if (endTime > startDate) // If endtime is after startime
                            endDate = new Date(endTime);
                    }
                }
                else if (starttime !== -1) { // If starttime has been invoked
                    startTime = parseInt(starttime);
                    startDate = new Date(startTime);
                    if (endtime !== -1) { // If --endtime has been invoked
                        endTime = parseInt(endtime);
                        if (endTime > startDate)
                            endDate = new Date(endTime);
                    }
                }
                //pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"startDate": startDate, "endDate": endDate, //"model":eventModel});
            }

            // This function calculate the difference between --endtime and --starttime and choose the better view
            function calculateDifferenceStarttimeEndtime(startTime, endTime) {
                var minute = 60 * 1000;
                var hour = 60 * minute;
                var day = 24 * hour;
                var month = 30 * day;

                var difference = endTime - startTime;

                if (difference > month)
                    return yearTab.index;   // Year view
                else if (difference > 7 * day)
                    return monthTab.index;   // Month view}
                else if (difference > day)
                    return weekTab.index;   // Week view
                else
                    return dayTab.index;   // Day view
            }

            // This function parse the argument
            function parseArguments(url) {
                var newevenpattern= new RegExp ("newevent");
                var starttimepattern = new RegExp ("starttime=\\d+");
                var endtimepattern = new RegExp ("endtime=\\d+");

                newevent = newevenpattern.test(url);

                if (starttimepattern.test(url))
                    starttime = url.match(/starttime=(\d+)/)[0].replace("starttime=", '');

                if (endtimepattern.test(url))
                    endtime = url.match(/endtime=(\d+)/)[0].replace("endtime=", '');
            }

            //WORKAROUND: The new header api does not work with tabs check bug: #1539759
            property var tabsAction: []

            function createTabAction(index, title, name)
            {
                var actionQml = "import Ubuntu.Components 1.3; Action { objectName: \"tab_%3\"; name: \"tab_%3\"; visible: (tabs.selectedTabIndex != %2); text: i18n.tr(\"%1\"); onTriggered: { tabs.selectedTabIndex = %2; }}"
                return Qt.createQmlObject(actionQml.arg(title).arg(index).arg(name), tabs, "tabs.qml")
            }

            function reloadTabActions()
            {
                var allPages = [
                            {index: 0, name: yearTab.objectName, title: yearTab.title},
                            {index: 1, name: monthTab.objectName, title: monthTab.title},
                            {index: 2, name: weekTab.objectName, title: weekTab.title},
                            {index: 3, name: dayTab.objectName, title: dayTab.title},
                            {index: 4, name: agendaTab.objectName, title: agendaTab.title},
                        ]
                var acts = []
                for(var i=0; i< allPages.length; i++) {
                    var pageInfo = allPages[i]
                    acts.push(createTabAction(pageInfo.index, pageInfo.title, pageInfo.name))
                }
                tabsAction = acts
            }

            Component.onCompleted: {
                // If an url has been set
                if (args.defaultArgument.at(0)) {
                    parseArguments(args.defaultArgument.at(0))
                    tabs.currentDay = new Date()
                    // If newevent has been called on startup
                    if (newevent) {
                        timer.running = true;
                    }
                    else if (starttime !== -1) { // If no newevent has been setted, but starttime
                        var startTime = parseInt(starttime);
                        tabs.currentDay = new Date(startTime);

                        // If also endtime has been settend
                        if (endtime !== -1) {
                            var endTime = parseInt(endtime);
                            tabs.selectedTabIndex = calculateDifferenceStarttimeEndtime(startTime, endTime);
                        }
                        else {
                            // If no endtime has been setted, open the starttime date in day view
                            tabs.selectedTabIndex = dayTab.index;
                        }
                    } // End of else if (starttime)
                    else {
                        // Due to bug #1231558 {if (args.defaultArgument.at(0))} is always true
                        // After the fix we can delete this else
                        tabs.selectedTabIndex = settings.defaultViewIndex;
                    }
                } // End of if about args.values
                else {
                    tabs.selectedTabIndex = settings.defaultViewIndex;
                }
                reloadTabActions()
                tabs.isReady = true
                // WORKAROUND: Due the missing feature on SDK, they can not detect if
                // there is a mouse attached to device or not. And this will cause the
                // bootom edge component to not work correct on desktop.
                // We will consider that  a mouse is always attached until it get implement on SDK.
                QuickUtils.mouseAttached = true
            } // End of Component.onCompleted:


            Keys.onTabPressed: {
                if( event.modifiers & Qt.ControlModifier) {
                    var currentTab = tabs.selectedTabIndex;
                    currentTab ++;
                    if( currentTab >= tabs.tabChildren.length){
                        currentTab = 0;
                    }
                    tabs.selectedTabIndex = currentTab;
                }
            }

            Keys.onBacktabPressed: {
                if( event.modifiers & Qt.ControlModifier) {
                    var currentTab = tabs.selectedTabIndex;
                    currentTab --;
                    if( currentTab < 0){
                        currentTab = tabs.tabChildren.length -1;
                    }
                    tabs.selectedTabIndex = currentTab;
                }
            }

            Tab{
                id: yearTab
                objectName: "yearTab"
                title: i18n.tr("Year")

                page: Loader {
                    id: yearViewLoader

                    asynchronous: true
                    sourceComponent: yearViewComp
                    active: false
                    // Load page on demand and keep it on memory until the application is closed
                    enabled: tabs.isReady && (tabs.selectedTab == yearTab)
                    onEnabledChanged: {
                        if (enabled && !active) {
                            active = true
                        }
                    }
                }
            }

            Tab{
                id: monthTab
                objectName: "monthTab"
                title: i18n.tr("Month")

                page: Loader {
                    id: monthTabLoader

                    asynchronous: true
                    sourceComponent: monthViewComp
                    active: false
                    // Load page on demand and keep it on memory until the application is closed
                    enabled: tabs.isReady && (tabs.selectedTab == monthTab)
                    onEnabledChanged: {
                        if (enabled && !active) {
                            active = true
                        }
                    }
                }
            }

            Tab{
                id: weekTab
                objectName: "weekTab"
                title: i18n.tr("Week")

                page: Loader {
                    id: weekTabLoader

                    asynchronous: true
                    sourceComponent: weekViewComp
                    active: false
                    // Load page on demand and keep it on memory until the application is closed
                    enabled: tabs.isReady && (tabs.selectedTab == weekTab)
                    onEnabledChanged: {
                        if (enabled && !active) {
                            active = true
                        }
                    }
                }
            }

            Tab{
                id: dayTab
                objectName: "dayTab"
                title: i18n.tr("Day")

                page:Loader {
                    id: dayTabLoader

                    asynchronous: true
                    sourceComponent: dayViewComp
                    active: false
                    // Load page on demand and keep it on memory until the application is closed
                    enabled: tabs.isReady && (tabs.selectedTab == dayTab)
                    onEnabledChanged: {
                        if (enabled && !active) {
                            active = true
                        }
                    }
                }
            }

            Tab {
                id: agendaTab
                objectName: "agendaTab"
                title: i18n.tr("Agenda")

                page: Loader {
                    id: agendaTabLoader

                    asynchronous: true
                    sourceComponent: agendaViewComp
                    active: false
                    // Load page on demand and keep it on memory until the application is closed
                    enabled: tabs.isReady && (tabs.selectedTab == agendaTab)
                    onEnabledChanged: {
                        if (enabled && !active) {
                            active = true
                        }
                    }
                }
            }
        }
    }

    Component {
        id: yearViewComp

        YearView {
            model: eventModel
            onMonthSelected: {
                var now = DateExt.today();
                if ((date.getMonth() === now.getMonth()) &&
                    (date.getFullYear() === now.getFullYear())) {
                    tabs.currentDay = now;
                } else {
                    tabs.currentDay = date.midnight();
                }
                tabs.selectedTabIndex = monthTab.index;
            }

            onActiveChanged: {
                if (active) {
                    refreshCurrentYear(DateExt.today().getFullYear())
                }
            }
        }
    }

    Component {
        id: monthViewComp

        MonthView {
            model: eventModel
            onDateHighlighted: {
                tabs.currentDay = date
            }

            onDateSelected: {
                tabs.currentDay = date
                tabs.selectedTabIndex = dayTab.index
            }

            onActiveChanged: {
                if (active) {
                    anchorDate = tabs.currentDay.midnight()
                }
            }
        }
    }

    Component {
        id: weekViewComp

        WeekView {
            property var highlightedDate

            model: eventModel
            onDateHighlighted: {
                highlightedDate = date
                if (date)
                    tabs.currentDay = date
            }

            onDateSelected: {
                tabs.currentDay = date;
                tabs.selectedTabIndex = dayTab.index
            }

            onPressAndHoldAt: {
                pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"date":date, "model":eventModel});
            }

            onActiveChanged: {
                if (active) {
                    anchorDate = tabs.currentDay
                }
            }
        }
    }

    Component {
        id: dayViewComp

        DayView {
            model: eventModel

            onDateSelected: {
                tabs.currentDay = date
            }

            onPressAndHoldAt: {
                pageStack.push(Qt.resolvedUrl("NewEvent.qml"),
                               {"date": date, "model": eventModel});
            }

            onActiveChanged: {
                if (active) {
                    anchorDate = tabs.currentDay
                }
            }
        }
    }

    Component {
        id: agendaViewComp

        AgendaView {
            model: eventModel

            onDateSelected: {
                tabs.currentDay = date;
                tabs.selectedTabIndex = dayTab.index
            }
        }
    }
}
