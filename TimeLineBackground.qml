import QtQuick 2.0
import Ubuntu.Components 0.1

Column {
    width: parent.width
    Repeater{
        model: 24 // hour in a day

        delegate: Rectangle {
            width: parent.width
            height: units.gu(10)
            color: ( index % 2 == 0) ? "#e5dbe6" : "#e6e4e9"
            Label{
                id: timeLabel
                text: new Date(0, 0, 0, index).toLocaleTimeString(Qt.locale(), i18n.tr("hh ap"))
                color:"gray"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                fontSize: "x-large"
                opacity: 0.3
            }
        }
    }
}
