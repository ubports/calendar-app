import QtQuick 2.0
import Ubuntu.Components 0.1

Item{
    id: header
    width: parent.width
    height: monthLabel.height

    property var date;
    property string monthLabelFontSize: "x-large"
    property string yearLabelFontSize: "large"

    Label{
        id: monthLabel
        objectName: "monthLabel"
        fontSize: monthLabelFontSize
        text: Qt.locale().standaloneMonthName(date.getMonth())
        anchors.leftMargin: units.gu(1)
        anchors.left: parent.left
        //color:"white"
        anchors.verticalCenter: parent.verticalCenter
    }

    Label{
        id: yearLabel
        objectName: "yearLabel"
        fontSize: yearLabelFontSize
        text: date.getFullYear()
        anchors.right: parent.right
        anchors.rightMargin: units.gu(1)
        color:"#AEA79F"
        anchors.verticalCenter: parent.verticalCenter
    }
}
