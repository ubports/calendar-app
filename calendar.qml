import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

import "dateExt.js" as DateExt

MainView {
    id: mainView

    objectName: "calendar"
    applicationName: "calendar-app"

    width: units.gu(45)
    height: units.gu(80)

    PageStack {
        id: pageStack

        Component.onCompleted: push(tabPage)

        Page{
            id: tabPage

            property var currentDay: DateExt.today();

            onCurrentDayChanged: {
                if( monthView.startDay !== undefined && !monthView.startDay.isSameDay(currentDay))
                    monthView.startDay = currentDay.midnight();

                if( !dayView.currentDay.isSameDay(currentDay))
                    dayView.currentDay = currentDay

                if( !weekView.dayStart.isSameDay(currentDay))
                    weekView.dayStart = currentDay
            }

            function newEvent() {
                 PopupUtils.open(newEventComponent, tabPage, {"defaultDate": new Date()})
            }

            Component.onCompleted: {
                tabs.selectedTabIndex= 1;
            }

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
                            monthView.goToToday();
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
                                var now = new Date();
                                if( date.getMonth() === now.getMonth()
                                        && date.getFullYear() === now.getFullYear()) {
                                    monthView.goToToday();
                                } else {
                                    monthView.startDay = date.midnight();
                                    monthView.gotoNextMonth(date.getMonth());
                                }
                            }
                        }
                    }
                }
                Tab {
                    id: monthTab
                    title: i18n.tr("Month")
                    page: Page{
                        anchors.fill: parent
                        tools: commonToolBar
                        Column {
                            anchors.fill: parent
                            Label{
                                id: monthLabel
                                fontSize: "large"
                                text: Qt.formatDateTime(monthView.startDay,"MMMM yyyy");
                            }

                            MonthView {
                                id: monthView
                                onFocusOnDay: {
                                    tabs.selectedTabIndex  = 3
                                    tabPage.currentDay = dayStart;
                                }
                            }
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
