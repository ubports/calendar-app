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
    property alias lunarData: lunarLabel.lunarData
    property var dotColors

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

    Label {
        id: lunarLabel

        property var lunarData: null

        text: lunarData ? lunarData.lunarText : ""
        color: {
            if (lunarData && lunarData.isTerm) {
                if (isCurrentMonth && isToday)
                    return "black"
                else
                    return UbuntuColors.red
            } else {
                if (isSelected)
                    return "white"
                else
                    return "#5D5D5D"
            }
        }
        fontSize: "small"
        visible: (lunarData != null)
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        anchors {
            top: dateLabel.bottom
            topMargin: units.gu(0.5)
        }
    }

    Row {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
        Repeater {
            model: dotColors
            Rectangle {
                id: eventIndicator

                width: visible ? units.gu(0.8) : 0
                height: width
                radius: height/2
                color: modelData
                visible: showEvent
            }

        }
    }


}
