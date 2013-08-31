import QtQuick 2.0
import Ubuntu.Components 0.1

Label{
    id: todayLabel
    text: Qt.formatDateTime( new Date(),"d MMMM yyyy");
    fontSize: "medium"
    horizontalAlignment: Text.AlignRight
    anchors.rightMargin: units.gu(1)
    anchors.left: parent.left
    anchors.right: parent.right
}
