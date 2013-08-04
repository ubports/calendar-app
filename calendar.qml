import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

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

            property var currentDay: new Date();

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

            tools: ToolbarItems {

                locked: true
                opened: true

                ToolbarButton {
                    action: Action {
                        objectName: "neweventbutton"
                        iconSource: Qt.resolvedUrl("avatar.png")
                        text: i18n.tr("New Event")
                        onTriggered: tabPage.newEvent()

                    }
                }
                ToolbarButton {
                    action: Action {
                        iconSource: Qt.resolvedUrl("avatar.png");
                        text: i18n.tr("Today");
                        onTriggered: {
                            tabPage.currentDay = new Date()
                            monthView.goToToday();
                        }
                    }
                }
            }

            Tabs{
                id: tabs
                Tab{
                    title:"Year"
                    YearView{
                        onMonthSelected: {
                            tabs.selectedTabIndex = 1
                            monthView.startDay = date.midnight();
                            monthView.gotoNextMonth(date.getMonth());
                        }
                    }
                }
                Tab {
                    id: monthTab
                    title: "Month"

                    Item {
                        anchors.fill: parent

                        Label{
                            id: monthLabel
                            fontSize: "large"
                            text: Qt.formatDateTime(monthView.startDay,"MMMM yyyy");
                        }

                        MonthView {
                            id: monthView
                            anchors.top: monthLabel.top
                            anchors.topMargin: units.gu(2)
                            onFocusOnDay: {
                                tabs.selectedTabIndex  = 3
                                tabPage.currentDay = dayStart;
                            }
                        }
                    }
                }
                Tab{
                    title:"Week"
                    WeekView{
                        id: weekView
                        anchors.fill: parent

                        onDayStartChanged: {
                            tabPage.currentDay = dayStart;
                        }
                    }
                }

                Tab{
                    title:"Day"
                    DayView{
                        id: dayView
                        anchors.fill: parent

                        onCurrentDayChanged: {
                            tabPage.currentDay = currentDay;
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
