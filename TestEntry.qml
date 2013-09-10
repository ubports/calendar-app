import QtQuick 2.0
import Ubuntu.Components 0.1

TextField {
    id: root
    property alias label: title.text
    Label{
        id: title
        anchors.left: parent.left
        height: parent.height
    }
}
