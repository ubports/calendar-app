import QtQuick 2.0
import Ubuntu.Components 0.1

Column{
    id: root

    property var date;

    property alias dateColor: dateLabel.color
    property alias dayColor: dayLabel.color

    property int dayFormat: Locale.ShortFormat;

    width: parent.width
    spacing: units.gu(2)

    Label{
        id: dayLabel
        property var day: Qt.locale().standaloneDayName(date.getDay(), dayFormat)
        text: day.toUpperCase();
        fontSize: "medium"
        horizontalAlignment: Text.AlignHCenter
        color: "#AEA79F"
        width: parent.width
    }

    Label{
        id: dateLabel
        text: date.getDate();
        fontSize: "large"
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
    }
}
