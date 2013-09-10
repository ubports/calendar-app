import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Themes.Ambiance 0.1

Item{
    id: root

    property alias title: label.text
    property alias text: entryField.text

    height: Math.max(label.height, entryField.height)

    Row {
        width: parent.width
        height: parent.height
        spacing: units.gu(1)

        Label{
            id: label
            anchors.verticalCenter: parent.verticalCenter
        }

        TextField{
            id: entryField
            width: parent.width - label.width - parent.spacing
            focus: root.focus
        }
    }
}
