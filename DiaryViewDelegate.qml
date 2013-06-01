import QtQuick 2.0
import Ubuntu.Components 0.1

import "dataService.js" as DataService

Item {
    id: delegateRoot

    property color textColor: "black"
    //property color bgColor: "#f1f1f1";
    property color bgColor: "white";

    signal clicked(int index);

    function collapse( collapse ) {
        attendeesLayout.visible = !collapse;
        locationLayout.visible = !collapse;
        eventRoot.collapsed = collapse;
    }

    function showEventData() {
        // FIXME: remove test value, need to decide what to do if there is no location, hide it ?
        var venues = [{"name":"Test Venue"}]
        DataService.getVenues(diaryView.model.get(index), venues)
        if( venues.length > 0 ) {
            locationLabel.text = venues[0].name;
        }

        // FIXME: remove test value, need to decide what to do if there are no attendees, hide it ?
        var attendees = ["Test One","Test Two"]
        DataService.getAttendees(diaryView.model.get(index),attendees)
        attendeeLabel.text = attendees.toString();
    }

    function dataChanged() {
        collapse(true);

        var now = new Date;
        var lastEvent = diaryView.model.get(index-1);

        if( endTime >= now
                && (lastEvent === undefined || lastEvent.endTime < now )
                && endTime.isSameDay(now) ) {
            collapse(false);
            bgColor = "#fffdaa";
            seperator.visible = true;
        } else if( startTime < now) {
            textColor = "#747474"
        }

        showEventData();
    }

    height: eventRoot.height + seperator.height + (seperator.visible ? units.gu(1.5) : units.gu(0.5)) /*margins*/
    width: parent.width

    TimeSeparator {
        id: seperator        
        width: delegateRoot.width - units.gu(2)
        anchors.top: parent.top
        anchors.topMargin: units.gu(1)
        anchors.horizontalCenter: parent.horizontalCenter        
        visible: false
    }

    Rectangle {
        id: eventRoot

        property var event;
        property bool collapsed: false;

        color: delegateRoot.bgColor;
        height: eventContainer.height;
        width: parent.width - units.gu(2)

        anchors {
            top: seperator.visible ? seperator.bottom : parent.top
            topMargin: units.gu(1)
            horizontalCenter: parent.horizontalCenter
        }

        MouseArea{
            anchors.fill: parent;
            onClicked: {
                delegateRoot.clicked(index);
            }
        }

        Column{
            id: eventContainer

            spacing: units.gu(1)

            anchors {
                left: parent.left
                right: parent.right
                leftMargin: units.gu(1)
                rightMargin: units.gu(1)
            }

            Row{
                width:parent.width
                spacing: units.gu(2)
                height: timeLabel.height + units.gu(3)

                Label{
                    id:timeLabel
                    fontSize: "large"
                    text: Qt.formatTime(startTime,"hh:mm");
                    anchors.verticalCenter: parent.verticalCenter
                    color: delegateRoot.textColor

                    onTextChanged: {
                        delegateRoot.dataChanged();
                    }
                }

                Label{
                    id: titleLabel
                    fontSize: "large"
                    text: title
                    anchors.verticalCenter: parent.verticalCenter
                    color: delegateRoot.textColor
                    wrapMode: Text.Wrap
                }
            }

            Row{
                id: locationLayout
                width:parent.width
                spacing: units.gu(2)
                Item {
                    id: locationIconContainer
                    width: timeLabel.width
                    height: units.gu(4)
                    Image{
                        source: "icon-location.png"
                        anchors.right: parent.right
                    }
                }
                Label{
                    id: locationLabel
                    width: parent.width - units.gu(2) - locationIconContainer.width
                    color: delegateRoot.textColor
                    wrapMode: Text.Wrap
                }
            }

            Row{
                id: attendeesLayout
                width:parent.width
                spacing: units.gu(2)
                Item {
                    id: contactIconContainer
                    width: timeLabel.width
                    height: units.gu(4)
                    Image{
                        source: "icon-contacts.png"
                        anchors.right: parent.right
                    }
                }
                Label{
                    id: attendeeLabel
                    width: parent.width - units.gu(2) - contactIconContainer.width
                    color: delegateRoot.textColor
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
