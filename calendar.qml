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
                            //onMonthStartChanged: tabs.selectedTabIndex = monthStart.getMonth()
                            //y: units.gu(9.5) // FIXME
                            //onMovementEnded: eventView.currentDayStart = currentDayStart
                            //onCurrentDayStartChanged: if (!(dragging || flicking)) eventView.currentDayStart = currentDayStart
                            //Component.onCompleted: eventView.currentDayStart = currentDayStart
                            //compressed: (eventView.state == "EXPANDED")
                            Behavior on height {
                                NumberAnimation { duration: 100 }
                            }

                            onFocusOnDay: {
                                tabs.selectedTabIndex  = 2
                                dayView.dayStart = dayStart
                            }
                        }
                    }
                }
//                Tab{
//                    title:"Week"
//                    WeekView{
//                        id: weekView
//                        anchors.fill: parent
//                    }
//                }
                Tab{
                    title:"Day"
                    DayView{
                        id: dayView
                        anchors.fill: parent
                    }
                }
            }
        }
    }
}
