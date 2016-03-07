import QtQuick 2.4
import Ubuntu.Components 1.3

Item{
    id: dateRootItem

    property int date;
    property bool isCurrentMonth;
    property bool isToday;
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
}
