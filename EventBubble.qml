import QtQuick 2.0
import Ubuntu.Components 0.1

import "dataService.js" as DataService

Rectangle{
    id: infoBubble

    property int type: narrowType
    property var event;

    property var hour;

    property int wideType: 1;
    property int narrowType: 2;

    signal clicked(int hour);

    border.color: "#715772"

    radius: 5
    color: "#f4f2f3"

    onEventChanged: {
        if(event === null || event === undefined) {
            return;
        }

        var startTime= Qt.formatDateTime(event.startTime,"hh:mm");
        var endTime= Qt.formatDateTime(event.endTime,"hh:mm");

        if( type == wideType) {
            timeLabel.text = startTime +" - "+ endTime
            titleLabel.text = event.title;
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
                color:"#715772"
                width: parent.width
            }
        }

        Label{
            id: titleLabel
            x: units.gu(1)
            fontSize:"small";
            color:"#715772"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            width: parent.width
            visible: type == wideType
        }
    }

    MouseArea{
        anchors.fill: parent
        onClicked: {
            infoBubble.clicked(hour);
        }
    }
}
