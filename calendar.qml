import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
///import Ubuntu.SyncMonitor 0.1
import "dateExt.js" as DateExt

MainView {
    id: mainView
    useDeprecatedToolbar: false

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
    Keys.forwardTo: [pageStack.currentPage]

    headerColor: "#E8E8E8"
    backgroundColor: "#f5f5f5"
    footerColor: "#ECECEC"
    anchorToKeyboard: true

//    SyncMonitor {
//        id: syncMonitor
//    }

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

        EventListModel{
            id: eventModel
            //This model is just for newevent
            //so we dont need any update
            autoUpdate: false

            Component.onCompleted: {
                if (args.values.eventid) {
                    var requestId = "";
                    eventModel.onItemsFetched.connect( function(id,fetchedItems) {
                        if( requestId === id && fetchedItems.length > 0 ) {
                            var event = fetchedItems[0];
                            pageStack.push(Qt.resolvedUrl("EventDetails.qml"),{"event":event,"model": eventModel});
                        }
                    });
                    requestId = eventModel.fetchItems([args.values.eventid]);
                }
            }
        }

        Tabs{
            id: tabs
            Keys.forwardTo: [tabs.currentPage.item]

            property var currentDay: DateExt.today();

            // Arguments on startup
            property bool newevent: false;
            property int starttime: -1;
            property int endtime: -1;

            selectedTabIndex: monthTab.index

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
                pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"startDate": startDate, "endDate": endDate, "model":eventModel});
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
                            tabs.selectedTabIndex = 3;
                        }
                    } // End of else if (starttime)
                    else {
                        // Due to bug #1231558 {if (args.defaultArgument.at(0))} is always true
                        // After the fix we can delete this else
                        tabs.selectedTabIndex= 1;
                    }
                } // End of if about args.values
                else {
                    tabs.selectedTabIndex= 1;
                }
            } // End of Component.onCompleted:

            ToolbarItems {
                id: commonToolBar

                ToolbarButton {
                    action: Action {
                        iconSource: Qt.resolvedUrl("calendar-today.svg");
                        text: i18n.tr("Today");
                        objectName: "todaybutton"
                        onTriggered: {
                            tabs.currentDay = (new Date()).midnight();
                            if(yearViewLoader.item ) yearViewLoader.item.currentYear = tabs.currentDay.getFullYear();
                            if(monthViewLoader.item ) monthViewLoader.item.currentMonth = tabs.currentDay.midnight();
                            if(weekViewLoader.item ) weekViewLoader.item.dayStart = tabs.currentDay;
                            if(dayViewLoader.item ) dayViewLoader.item.currentDay = tabs.currentDay;
                            if(agendaViewLoader.item ) {
                                agendaViewLoader.item.currentDay = tabs.currentDay;
                                agendaViewLoader.item.goToBeginning();
                            }
                        }
                    }
                }
                ToolbarButton {
                    action: Action {
                        objectName: "neweventbutton"
                        iconSource: Qt.resolvedUrl("new-event.svg");
                        text: i18n.tr("New Event");
                        onTriggered: {
                            pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"date":tabs.currentDay,"model":eventModel});
                        }
                    }
                }
                ToolbarButton {
                    objectName: "syncbutton"
                    visible: syncMonitor.enabledServices ? syncMonitor.serviceIsEnabled("calendar") : false
                    action: Action {
                        text: enabled ? i18n.tr("Sync") : i18n.tr("Syncing")
                        iconName: "reload"
                        onTriggered: syncMonitor.sync(["calendar"])
                        enabled: (syncMonitor.state !== "syncing")
                    }
                }
            }

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
                page: Loader{
                    id: yearViewLoader
                    objectName: "yearViewLoader"
                    source: tabs.selectedTab == yearTab ? Qt.resolvedUrl("YearView.qml"):""
                    onLoaded: {
                        item.tools = Qt.binding(function() { return commonToolBar })
                        item.currentYear = tabs.currentDay.getFullYear();
                    }

                    anchors{
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    Connections{
                        target: yearViewLoader.item
                        onMonthSelected: {
                            var now = DateExt.today();
                            if( date.getMonth() === now.getMonth()
                                    && date.getFullYear() === now.getFullYear()) {
                                tabs.currentDay = now;
                            } else {
                                tabs.currentDay = date.midnight();
                            }
                            tabs.selectedTabIndex = monthTab.index;
                        }
                    }
                }
            }

            Tab{
                id: monthTab
                objectName: "monthTab"
                title: i18n.tr("Month")
                page: Loader{
                    id: monthViewLoader
                    objectName: "monthViewLoader"
                    source: tabs.selectedTab == monthTab ? Qt.resolvedUrl("MonthView.qml"):""
                    onLoaded: {
                        item.tools = Qt.binding(function() { return commonToolBar })
                        item.currentMonth = tabs.currentDay.midnight();
                    }

                    anchors{
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    Connections{
                        target: monthViewLoader.item
                        onDateSelected: {
                            tabs.currentDay = date;
                            tabs.selectedTabIndex = dayTab.index;
                        }
                    }
                }
            }

            Tab{
                id: weekTab
                objectName: "weekTab"
                title: i18n.tr("Week")
                page: Loader{
                    id: weekViewLoader
                    objectName: "weekViewLoader"
                    source: tabs.selectedTab == weekTab ? Qt.resolvedUrl("WeekView.qml"):""
                    onLoaded: {
                        item.tools = Qt.binding(function() { return commonToolBar })
                        item.isCurrentPage= Qt.binding(function() { return tabs.selectedTab == weekTab })
                        item.dayStart = tabs.currentDay;
                    }

                    anchors{
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    Connections{
                        target: weekViewLoader.item
                        onDayStartChanged: {
                            tabs.currentDay = weekViewLoader.item.dayStart;
                        }

                        onDateSelected: {
                            tabs.currentDay = date;
                            tabs.selectedTabIndex = dayTab.index;
                        }
                    }
                }
            }

            Tab{
                id: dayTab
                objectName: "dayTab"
                title: i18n.tr("Day")
                page: Loader{
                    id: dayViewLoader
                    objectName: "dayViewLoader"
                    source: tabs.selectedTab == dayTab ? Qt.resolvedUrl("DayView.qml"):""
                    onLoaded: {
                        item.tools = Qt.binding(function() { return commonToolBar })
                        item.isCurrentPage= Qt.binding(function() { return tabs.selectedTab == dayTab })
                        item.currentDay = tabs.currentDay;
                    }

                    anchors{
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    Connections{
                        target: dayViewLoader.item
                        onCurrentDayChanged: {
                            tabs.currentDay = dayViewLoader.item.currentDay;
                        }
                    }
                }
            }

            Tab {
                id: agendaTab
                objectName: "agendaTab"
                title: i18n.tr("Agenda")
                page: Loader {
                    id: agendaViewLoader
                    objectName: "agendaViewLoader"
                    source: tabs.selectedTab == agendaTab ? Qt.resolvedUrl("AgendaView.qml"):""

                    onLoaded: {
                        item.tools = Qt.binding(function() { return commonToolBar })
                        item.currentDay = tabs.currentDay;
                    }

                    anchors{
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                }
            }
        }
    }
}
