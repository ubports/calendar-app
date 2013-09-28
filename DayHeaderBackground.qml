import QtQuick 2.0

Item {
    width: parent.width
    height:parent.height
    BorderImage {
        id: separator
        source: "PageHeaderBaseDividerLight.png"
        width: parent.width;
        height: parent.height
    }

    Image {
        anchors {
            top: separator.bottom
            left: parent.left
            right: parent.right
        }
        source: "PageHeaderBaseDividerBottom.png"
    }
}
