import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

import "dateExt.js" as DateExt

MainView {
    id: mainView

    // Arguments during startup
    Arguments {
        id: args;

        /*
         * BE CAREFUL: - (indent) is not allowed in name of Argument
         * When this bug will be fixed, we have to change the name of Argument
         */

        // Create a new event
        Argument {
            name: "newevent";
            help: i18n.tr("Create a new event. If --starttime or --endtime are set they are used to set start and end time");
            required: false;
        }

        // If newevent has been called, starttime is the start time of event
        // Otherwise is the day on which app is focused on startup
        Argument {
            name: "starttime";
            help: i18n.tr("If --newevent is set it's the start time of the event. Otherwise is the date on which app is focused. It accepts an integer value of the number of seconds since UNIX epoch in the UTC timezone. 0 means today.");
            required: false;
            valueNames: ["START-TIME"]
        }

        Argument {
            name: "endtime";
            help: i18n.tr("If --newevent is set it's the end time of the event, has to be > of --starttime, if set. If --newevent isn't set and --startime is set, its value is used to choose the right view. If neither of precendet flags are set, --endtime is ignored. It accepts an integer value of the number of seconds since UNIX epoch in the UTC timezone.");
            required: false;
            valueNames: ["END-TIME"]
        }
    }

    objectName: "calendar"
    applicationName: "calendar-app"

    width: units.gu(45)
    height: units.gu(80)

    headerColor: "#266249"
    backgroundColor: "#478158"
    footerColor: "#478158"

    PageStack {
        id: pageStack

        Component.onCompleted: push(tabPage)

        Page{
            id: tabPage

            property var currentDay: DateExt.today();

            onCurrentDayChanged: {
                if( monthView.currentMonth !== undefined && !monthView.currentMonth.isSameDay(currentDay))
                    monthView.currentMonth = currentDay.midnight();

                if( !dayView.currentDay.isSameDay(currentDay))
                    dayView.currentDay = currentDay

                if( !weekView.dayStart.isSameDay(currentDay))
                    weekView.dayStart = currentDay
            }

            function newEvent() {
                var defaultDate = currentDay;
                var startDate = new Date;
                var endDate = new Date;
                var startTime;
                var endTime;

                if (args.values.newevent) { // If --newevent has been invoked
                    if (args.values.starttime === 0) { // --startime 0 means now
                        if (args.values.endtime) { // If also --endtime has been invoked
                           endTime = parseInt(args.values.endtime);
                            if (endTime > startDate) // If --endtime is after --startime
                                endDate = new Date(endTime);
                        }
                    }
                    else if (args.values.starttime) { // If --starttime has been invoked
                        startTime = parseInt(args.values.starttime);
                        defaultDate = new Date(startTime);
                        startDate = new Date(startTime);
                        if (args.values.endtime) { // If --endtime has been invoked
                            endTime = parseInt(args.values.endtime);
                            if (endTime > startDate)
                                endDate = new Date(endTime);
                        }
                    }
                }
                PopupUtils.open(newEventComponent, tabPage, {"defaultDate": defaultDate, "startDate": startDate, "endDate": endDate})
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
                    return 1;   // Month view
                else if (difference > day)
                    return 2;   // Week view
                else
                    return 3;   // Day view
            }

            Component.onCompleted: {
                // If --newevent has been called on startup

                if (args.values.newevent) {
                    tabPage.newEvent()
                }
                else if (args.values.starttime) { // If no newevent has been setted, but starttime
                    var startTime = parseInt(args.values.starttime);
                    tabPage.currentDay = new Date(startTime);

                    // If also endtime has been settend
                    if (args.values.endtime) {
                        var endTime = parseInt(args.values.endtime);
                        tabs.selectedTabIndex = calculateDifferenceStarttimeEndtime(startTime, endTime);
                    }
                    else {
                        // If no endtime has been setted, open the starttime date in day view
                        tabs.selectedTabIndex = 3
                    }
                } // End of else if (args.values.starttime)
                else {
                    tabs.selectedTabIndex= 1;
                }
            } // End of Component.onCompleted:

            ToolbarItems {
                id: commonToolBar

                ToolbarButton {
                    objectName: "neweventbutton"
                    action: Action {
                        iconSource: Qt.resolvedUrl("avatar.png")
                        text: i18n.tr("New Event")
                        onTriggered: tabPage.newEvent()
                    }
                }                    
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

            Component {
                id: newEventComponent
                NewEvent {}
            }
        }
    }
}
