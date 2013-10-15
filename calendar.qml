import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

import "dateExt.js" as DateExt
import "GlobalEventModel.js" as GlobalModel

MainView {
    id: mainView

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
            property var globalModel;

            onCurrentDayChanged: {
                if( monthView.currentMonth !== undefined && !monthView.currentMonth.isSameDay(currentDay))
                    monthView.currentMonth = currentDay.midnight();

                if( !dayView.currentDay.isSameDay(currentDay))
                    dayView.currentDay = currentDay

                if( !weekView.dayStart.isSameDay(currentDay))
                    weekView.dayStart = currentDay

                setStartEndDateToModel();
            }

            function setStartEndDateToModel() {
                if(globalModel) {
                    globalModel.startPeriod =  new Date(currentDay.getFullYear(),0,1,0,0,0,0);
                    globalModel.endPeriod = new Date(currentDay.getFullYear(),11,31,0,0,0,0);
                }
            }

            function newEvent() {
                 PopupUtils.open(newEventComponent, tabPage, {"defaultDate": currentDay})
            }

            Component.onCompleted: {
                globalModel = GlobalModel.gloablModel();
                setStartEndDateToModel();
                tabs.selectedTabIndex = 1;
            }

            ToolbarItems {
                id: commonToolBar

                ToolbarButton {
                    objectName: "todaybutton"
                    action: Action {
                        iconSource: Qt.resolvedUrl("calendar-today.svg");
                        text: i18n.tr("Today");
                        onTriggered: {
                            tabPage.currentDay = (new Date()).midnight();
                        }
                    }
                }
                ToolbarButton {
                    objectName: "neweventbutton"
                    action: Action {
                        iconSource: Qt.resolvedUrl("new-event.svg");
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
