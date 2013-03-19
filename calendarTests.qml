import QtQuick 2.0
import Ubuntu.Components 0.1
import "dataServiceTests.js" as DataServiceTests

Item {
    width: units.gu(20)
    height: units.gu(20)
    Button {
        anchors.fill: parent
        anchors.margins: units.gu(5)
        text: "Close"
        onClicked: Qt.quit()
    }
}
