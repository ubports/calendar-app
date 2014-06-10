import QtQuick 2.0
import Ubuntu.Components 0.1
import QtOrganizer 5.0

import "dateExt.js" as DateExt

Page{
    id: root
    objectName: "AgendaView"

    property var currentDay: new Date()

    Keys.forwardTo: [eventList]

    function goToBeginning() {
        eventList.positionViewAtBeginning();
    }

    EventListModel {
        id: eventModel
        startPeriod: currentDay.midnight();
        endPeriod: currentDay.addDays(30).endOfDay()
        filter: UnionFilter{
            filters: [
                DetailFieldFilter{
                    detail: Detail.ItemType
                    field: Type.FieldType
                    value: Type.Event
                    matchFlags: Filter.MatchExactly
                },
                DetailFieldFilter{
                    detail: Detail.ItemType
                    field: Type.FieldType
                    value: Type.EventOccurrence
                    matchFlags: Filter.MatchExactly
                }
            ]
        }

        sortOrders: [SortOrder{
            id: sort
            blankPolicy: SortOrder.BlanksFirst
            detail: Detail.EventTime
            field: EventTime.FieldStartDateTime
            direction: Qt.AscendingOrder
            sensitivity: Qt.CaseInsensitive
        }]
    }

    ActivityIndicator {
        visible: running
        running: eventModel.isLoading
        anchors.centerIn: parent
        z:2
    }

    Label{
        text: i18n.tr("No upcoming events")
        visible: eventModel.itemCount == 0
        anchors.fill: parent
        anchors.centerIn: parent
    }

    ListView{
        id: eventList
        model: eventModel
        anchors.fill: parent
        visible: eventModel.itemCount > 0

        delegate: listDelegate
    }

    Scrollbar{
        flickableItem: eventList
        align: Qt.AlignTrailing
    }

    Component{
        id: listDelegate

        Item {
            id: root
            property var event: eventModel.items[index];

            width: parent.width
            height: container.height

            onEventChanged: {
                setDetails();
            }

            function setDetails() {
                if(event === null || event === undefined) {
                    return;
                }

                headerContainer.visible = false;
                if( index == 0 ) {
                    headerContainer.visible = true;
                } else {
                    var prevEvent = eventModel.items[index-1];
                    if( prevEvent.startDateTime.midnight() < event.startDateTime.midnight()) {
                        headerContainer.visible = true;
                    }
                }

                // TRANSLATORS: this is a time formatting string,
                // see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details for valid expressions
                var timeFormat = i18n.tr("hh:mm");
                var dateFormat = i18n.tr("dddd , d MMMM");
                var date = event.startDateTime.toLocaleString(Qt.locale(),dateFormat);
                var startTime = event.startDateTime.toLocaleTimeString(Qt.locale(), timeFormat)
                var endTime = event.endDateTime.toLocaleTimeString(Qt.locale(), timeFormat)

                // TRANSLATORS: the first argument (%1) refer to a start time for an event,
                // while the third one (%2) refers to the end time
                var timeString = i18n.tr("%1 - %2").arg(startTime).arg(endTime)

                header.text = date
                timeLabel.text = timeString

                if( event.displayLabel) {
                    titleLabel.text = event.displayLabel;
                }
            }

            Column {
                id: container

                width: parent.width
                height: detailsContainer.height + headerContainer.height +
                        (headerContainer.visible ? units.gu(2) : units.gu(0.5))

                spacing: headerContainer.visible ? units.gu(1) : 0

                anchors.top: parent.top
                anchors.topMargin: headerContainer.visible ? units.gu(1.5) : units.gu(1)

                DayHeaderBackground{
                    id: headerContainer
                    height: visible ? header.height + units.gu(1) : 0
                    width: parent.width
                    Label{
                        id: header
                        width: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(1)
                        color: "white"
                    }
                }

                UbuntuShape{
                    id: detailsContainer
                    color: "white"

                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - units.gu(4)
                    height: detailsColumn.height + units.gu(1)

                    Column{
                        id: detailsColumn

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: units.gu(0.5)

                        spacing: units.gu(0.5)

                        Row{
                            width: parent.width
                            Label{
                                id: timeLabel
                                color:"gray"
                                width: parent.width - rect.width
                            }
                            Rectangle{
                                id:rect
                                width: units.gu(1)
                                radius: width/2
                                height: width
                                color: "#715772"
                            }
                        }
                        Label{
                            id: titleLabel
                            color:"black"
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            width: parent.width
                        }
                    }

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("EventDetails.qml"), {"event":event,"model":eventModel});
                        }
                    }
                }
            }
        }
    }
}
