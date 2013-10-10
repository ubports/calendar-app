import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

import "dateExt.js" as DateExt

MainView {
    id: mainView

    // Argument during startup
    Arguments {
        id: args;

        // Example of argument: calendar:///new-event

        // IMPORTANT
        // Due to bug #1231558 you have to pass arguments BEFORE app:
        // qmlscene calendar:///new-event calendar.qml

        defaultArgument.help: i18n.tr("Calendar app accept three arguments: --starttime, --endtime and --newevet. They will be managed by system. See the source for a full comment about them");
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
         */
    }

    objectName: "calendar"
    applicationName: "com.ubuntu.calendar"

    width: units.gu(45)
    height: units.gu(80)

    headerColor: "#266249"
    backgroundColor: "#478158"
    footerColor: "#478158"
    anchorToKeyboard: true

    PageStack {
        id: pageStack

        Component.onCompleted: push(tabPage)

        Page{
            id: tabPage

            property var currentDay: DateExt.today();

            // Arguments on startup
            property bool newevent: false;
            property int starttime: -1;
            property int endtime: -1;

            onCurrentDayChanged: {
                if( monthView.currentMonth !== undefined && !monthView.currentMonth.isSameDay(currentDay))
                    monthView.currentMonth = currentDay.midnight();

                if( !dayView.currentDay.isSameDay(currentDay))
                    dayView.currentDay = currentDay

                if( !weekView.dayStart.isSameDay(currentDay))
                    weekView.dayStart = currentDay
            }

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
                pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"startDate": startDate, "endDate": endDate});
            }

            // This function calculate the difference between --endtime and --starttime and choose the better view
            function calculateDifferenceStarttimeEndtime(startTime, endTime) {
                var minute = 60 * 1000;
                var hour = 60 * minute;
                var day = 24 * hour;
                var month = 30 * day;

                var difference = endTime - startTime;

                if (difference > month)
                    return 0;   // Year view
                else if (difference > 7 * day)
                    return 1;   // Month view}
                else if (difference > day)
                    return 2;   // Week view
                else
                    return 3;   // Day view
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
                    tabPage.currentDay = new Date()
                    // If newevent has been called on startup
                    if (newevent) {
                        timer.running = true;
                    }
                    else if (starttime !== -1) { // If no newevent has been setted, but starttime
                        var startTime = parseInt(starttime);
                        tabPage.currentDay = new Date(startTime);

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

            Timer {
                id: timer
                interval: 200;
                running: false;
                repeat: false
                onTriggered: {
                    tabPage.newEvent();
                }
            }

            ToolbarItems {
                id: commonToolBar

                ToolbarButton {
                    objectName: "todaybutton"
                    action: Action {
                        iconSource: Qt.resolvedUrl("avatar.png");
                        text: i18n.tr("Today");
                        onTriggered: {
                            tabPage.currentDay = (new Date()).midnight();
                        }
                    }
                }
                ToolbarButton {
                    objectName: "neweventbutton"
                    action: Action {
                        iconSource: Qt.resolvedUrl("avatar.png");
                        text: i18n.tr("New Event");
                        onTriggered: {
                            pageStack.push(Qt.resolvedUrl("NewEvent.qml"),{"date":tabPage.currentDay});
                        }
                    }
                }
            }

            Tabs{
                id: tabs
                Tab{
                    title: i18n.tr("Year")
                    page: Page{
                        anchors.fill: parent
                        tools: commonToolBar
                        YearView{
                            onMonthSelected: {
                                tabs.selectedTabIndex = 1
                                var now = DateExt.today();
                                if( date.getMonth() === now.getMonth()
                                        && date.getFullYear() === now.getFullYear()) {
                                    monthView.currentMonth = now
                                } else {
                                    monthView.currentMonth = date.midnight();
                                }
                            }
                        }
                    }
                }
                Tab {
                    id: monthTab
                    title: i18n.tr("Month")
                    page: MonthView{
                        anchors.fill: parent
                        tools: commonToolBar
                        id: monthView

                        onDateSelected: {
                            tabs.selectedTabIndex  = 3
                            tabPage.currentDay = date;
                        }
                    }
                }
                Tab{
                    title: i18n.tr("Week")
                    page: Page{
                        anchors.fill: parent
                        tools: commonToolBar
                        WeekView{
                            id: weekView
                            anchors.fill: parent

                            onDayStartChanged: {
                                tabPage.currentDay = dayStart;
                            }
                        }
                    }
                }

                Tab{
                    title: i18n.tr("Day")
                    page: Page{
                        anchors.fill: parent
                        tools: commonToolBar
                        DayView{
                            id: dayView
                            anchors.fill: parent

                            onCurrentDayChanged: {
                                tabPage.currentDay = currentDay;
                            }
                        }
                    }
                }
            }
        }
    }
}
