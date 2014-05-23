import QtQuick 2.0
import Ubuntu.Components 0.1

TextField{
    id: root
    property alias title: label.text

    primaryItem: Label{
        id: label
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: root.highlighted ? "#2C001E" : Theme.palette.normal.baseText
    }

    color: focus ? "#2C001E" : "#5D5D5D"
    font {
        pixelSize: focus ? FontUtils.sizeToPixels("large") : FontUtils.sizeToPixels("medium")
    }

    onActiveFocusChanged: {
        if (activeFocus) {
            flickable.makeMeVisible(root)
        }
    }
}
