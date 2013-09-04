import QtQuick 2.0
import Ubuntu.Components 0.1

import "dataService.js" as DataService

Item{
    id: infoBubble

    property var event;

    property int type: narrowType
    property int wideType: 1;
    property int narrowType: 2;

    signal clicked(var event);

    UbuntuShape{
        id: bg
        anchors.fill: parent
        color: "white"
    }

    onEventChanged: {
        setDetails();
    }

    Component.onCompleted: {
        setDetails();
    }

    function setDetails() {
        if(event === null || event === undefined) {
            return;
        }

        var startTime= Qt.formatDateTime(event.startTime,"hh:mm");
        var endTime= Qt.formatDateTime(event.endTime,"hh:mm");

        timeLabel.text = ""
        titleLabel.text = ""
        descriptionLabel.text = ""

        if( type == wideType) {
            timeLabel.text = startTime +" - "+ endTime

            if( event.title)
                titleLabel.text = event.title;

            if( event.message)
                descriptionLabel.text = event.message
        } else {
            timeLabel.text = startTime
        }
    }

    Column{
        width: parent.width
        Row{
            width: parent.width

            Rectangle{
                width: units.gu(1)
                radius: width/2
                height: width
                color: "#715772"
                anchors.verticalCenter: parent.verticalCenter
                antialiasing: true
            }

            Label{
                id: timeLabel
                fontSize:"small";
                color:"gray"
                width: parent.width
            }
        }

        Label{
            id: titleLabel
            x: units.gu(1)
            fontSize:"small";
            color:"black"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            width: parent.width
            visible: type == wideType
        }

        Label{
            id: descriptionLabel
            x: units.gu(1)
            fontSize:"small";
            color:"gray"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            width: parent.width
            visible: type == wideType
        }
    }

    MouseArea{
        anchors.fill: parent
        onClicked: {
            infoBubble.clicked(event);
        }
    }
}
