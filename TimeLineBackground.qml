import QtQuick 2.0
import Ubuntu.Components 0.1

Column {
    width: parent.width
    Repeater{
        model: 24 // hour in a day

        delegate: Item {
            id: delegate
            width: parent.width
            // FIXME: get hour hight from somewhere
            height: units.gu(10)

            Row {
                width: parent.width
                y: -timeLabel.height/2
                Label{
                    id: timeLabel
                    // TRANSLATORS: this is a time formatting string,
                    // see http://qt-project.org/doc/qt-5.0/qtqml/qml-qtquick2-date.html#details for valid expressions
                    //text: new Date(0, 0, 0, index).toLocaleTimeString(Qt.locale(), i18n.tr("HH:mm"))
                    text: new Date(0, 0, 0, index).toLocaleTimeString(Qt.locale(), i18n.tr("HH"))
                    color:"gray"
                    anchors.top: parent.top
                }
                Rectangle{
                    width: parent.width -timeLabel.width
                    height:units.dp(1)
                    color:"gray"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle{
                width: parent.width - units.gu(5)
                height:units.dp(1)
                color:"gray"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
