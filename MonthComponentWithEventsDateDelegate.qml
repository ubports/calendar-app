import QtQuick 2.4
import Ubuntu.Components 1.3

Item{
    id: dateRootItem

    property int date;
    property bool isCurrentMonth;
    property bool isToday;
    property bool showEvent;
    property alias fontSize: dateLabel.font.pixelSize
    property bool isSelected: false

    Text {
        id: dateLabel
        anchors.centerIn: parent
        text: date
        color: {
            if( isCurrentMonth ) {
                if( isToday || isSelected ) {
                    "white"
                } else {
                    "#5D5D5D"
                }
            } else {
                if(isSelected) {
                    "white"
                } else {
                    "#AEA79F"
                }
            }
        }
    }

    Rectangle {
        id: eventIndicator

        width: visible ? units.gu(0.8) : 0
        height: width
        anchors {
            horizontalCenter: parent.horizontalCenter
            //top: parent.verticalCenter
            //topMargin: ((Math.min(parent.height, dateRootItem.width) / 1.3) / 2) + units.gu(0.1)
            bottom: parent.bottom
        }
        radius: height/2
        color:"black"
        visible: showEvent
    }
}
