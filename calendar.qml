import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

MainView {
    id: mainView

    objectName: "calendar"
    applicationName: "ubuntu-calendar-app"

    width: units.gu(45)
    height: units.gu(80)

    PageStack {
        id: pageStack

        Component.onCompleted: push(monthViewPage)
        __showHeader: false

        Page {
            id: monthViewPage

            // Fix for UITK detecting any Flickable as a vertical flickable
            // This line can be removed after https://code.launchpad.net/~tpeeters/ubuntu-ui-toolkit/internalizePropagated/+merge/164963
            // was merged into the UITK.
            flickable: null

            tools: ToolbarActions {
                Action {
                    iconSource: Qt.resolvedUrl("avatar.png")
                    text: i18n.tr("To-do")
                    onTriggered:; // FIXME
                }
                Action {
                    iconSource: Qt.resolvedUrl("avatar.png")
                    text: i18n.tr("New Event")
                    onTriggered: monthViewPage.newEvent()
                }
                Action {
                    iconSource: Qt.resolvedUrl("avatar.png")
                    text: i18n.tr("Timeline")
                    onTriggered: {
                        if( eventView.eventViewType  === "DiaryView.qml") {
                            eventView.eventViewType = "TimeLineView.qml";
                            text = i18n.tr("Diary")
                        } else {
                            eventView.eventViewType = "DiaryView.qml";
                            text = i18n.tr("Timeline")
                        }
                    }
                }
            }

            Tabs {
                id: tabs

                Tab { title: Qt.locale().standaloneMonthName(0) }
                Tab { title: Qt.locale().standaloneMonthName(1) }
                Tab { title: Qt.locale().standaloneMonthName(2) }
                Tab { title: Qt.locale().standaloneMonthName(3) }
                Tab { title: Qt.locale().standaloneMonthName(4) }
                Tab { title: Qt.locale().standaloneMonthName(5) }
                Tab { title: Qt.locale().standaloneMonthName(6) }
                Tab { title: Qt.locale().standaloneMonthName(7) }
                Tab { title: Qt.locale().standaloneMonthName(8) }
                Tab { title: Qt.locale().standaloneMonthName(9) }
                Tab { title: Qt.locale().standaloneMonthName(10) }
                Tab { title: Qt.locale().standaloneMonthName(11) }

                onSelectedTabIndexChanged: monthView.gotoNextMonth(selectedTabIndex)
            }

            Rectangle {
                anchors.fill: monthView
                color: "white"
            }

            MonthView {
                id: monthView
                onMonthStartChanged: tabs.selectedTabIndex = monthStart.getMonth()
                //y: units.gu(9.5) // FIXME
                onMovementEnded: eventView.currentDayStart = currentDayStart
                onCurrentDayStartChanged: if (!(dragging || flicking)) eventView.currentDayStart = currentDayStart
                Component.onCompleted: eventView.currentDayStart = currentDayStart
                compressed: (eventView.state == "EXPANDED")
                Behavior on height {
                    NumberAnimation { duration: 100 }
                }
            }

            EventView {
                id: eventView

                height: parent.height - monthView.height
                width: mainView.width
                anchors.top: monthView.bottom

                Component.onCompleted: {
                    incrementCurrentDay.connect(monthView.incrementCurrentDay)
                    decrementCurrentDay.connect(monthView.decrementCurrentDay)
                }

                onNewEvent: monthViewPage.newEvent()
            }

            signal newEvent
            onNewEvent: PopupUtils.open(newEventComponent, monthViewPage, {"defaultDate": monthView.currentDayStart})

            Component {
                id: newEventComponent
                NewEvent {}
            }
        }
    }
}
