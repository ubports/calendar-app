import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

Item{
    id: root
    property var date;

    signal monthSelected(var date);

    property alias dayLabelDelegate : dayLabelRepeater.delegate
    property alias dateLabelDelegate : dateLabelRepeater.delegate

    objectName: "MonthComponent"

    width: monthGrid.width
    height: monthGrid.height + units.gu(0.5)+ monthName.height

    MouseArea{
        anchors.fill: parent
        onClicked: {
            root.monthSelected( root.date );
        }
    }

    Label{
        id: monthName
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        font.bold: true
        text: {
            Qt.locale().standaloneMonthName(root.date.getMonth())
        }
    }

    Row{
        id: dayLabelRow
        anchors.top: monthName.bottom
        anchors.topMargin: units.gu(0.5)
        spacing: units.gu(0.5)
        width: parent.width
        Repeater{
            id: dayLabelRepeater
            model:7
            delegate: dafaultDayLabelComponent
        }
    }

    Grid{
        id: monthGrid
        property var monthStart: DateExt.getFirstDateofWeek(root.date.getFullYear(),root.date.getMonth())

        rows: DateExt.weekCount(root.date.getFullYear(), root.date.getMonth())
        columns: 7
        spacing: units.gu(0.5)

        anchors.top: dayLabelRow.bottom
        anchors.topMargin: units.gu(0.5)

        Repeater{
            id: dateLabelRepeater
            model: monthGrid.rows * monthGrid.columns
            delegate: defaultDateLabelComponent
        }
    }

    Component{
        id: defaultDateLabelComponent

        Text {
            id: dateLabel

            property var day: parent.monthStart.addDays(index)
            property var isToday: day.isSameDay(intern.now)
            property bool isPaddingDate: day.getMonth() != root.date.getMonth()

            text: day.getDate()
            horizontalAlignment: Text.AlignHCenter
            width: dummy.width
            height: dummy.height
            font.pointSize: dummy.font.pointSize
            color: isToday ? Color.ubuntuOrange : (isPaddingDate ? Color.warmGrey : dummy.color)
            scale: isToday ? 1.5 : 1.
        }
    }

    Component{
        id: dafaultDayLabelComponent
        Text{
            //FIXME: how to get localized day initial ?
            text: Qt.locale().standaloneDayName( (intern.weekstartDay + index), Locale.ShortFormat).charAt(0)
            horizontalAlignment: Text.AlignHCenter
            width: dummy.width
            height: dummy.height
            font.pointSize: dummy.font.pointSize
            font.bold: true
        }
    }

    Text{
        id: dummy
        text: "00"
        visible: false
        font.pointSize: 7.5
    }
}
