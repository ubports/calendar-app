import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Themes.Ambiance 0.1

TextField{
    id: root
    property alias title: label.text

    primaryItem: Label{
        id: label
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: root.highlighted ? "#2C001E" : dummy.color
    }

    Label{
        id: dummy
        visible: false
    }
}
