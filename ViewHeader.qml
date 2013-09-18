import QtQuick 2.0
import Ubuntu.Components 0.1

Item{
    id: header
    width: parent.width
    height: monthLabel.height

    property var date;

    Label{
        id: monthLabel
        fontSize: "large"
        text: Qt.locale().standaloneMonthName(date.getMonth())
        anchors.leftMargin: units.gu(1)
        anchors.left: parent.left
        //color:"white"
        anchors.verticalCenter: parent.verticalCenter
    }

    Label{
        id: yearLabel
        fontSize: "medium"
        text: date.getFullYear()
        anchors.right: parent.right
        anchors.rightMargin: units.gu(1)
        color:"#AEA79F"
        anchors.verticalCenter: parent.verticalCenter
    }
}
