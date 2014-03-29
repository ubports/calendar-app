import QtQuick 2.0
import Ubuntu.Components 0.1

Item{
    id: header
    width: parent.width
    height: monthLabel.height

    property int month;
    property int year;

    property string monthLabelFontSize: "x-large"
    property string yearLabelFontSize: "large"

    Label{
        id: monthLabel
        objectName: "monthLabel"
        fontSize: monthLabelFontSize
        text: Qt.locale().standaloneMonthName(month)
        anchors.leftMargin: units.gu(1)
        anchors.left: parent.left
        //color:"white"
        anchors.verticalCenter: parent.verticalCenter
    }

    Label{
        id: yearLabel
        objectName: "yearLabel"
        fontSize: yearLabelFontSize
        text: year
        anchors.right: parent.right
        anchors.rightMargin: units.gu(1)
        color:"#AEA79F"
        anchors.verticalCenter: parent.verticalCenter
    }
}
