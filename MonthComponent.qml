import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

Item{
    id: root
    objectName: "MonthComponent"

    property var monthDate;

    property string dayLabelFontSize: "medium"
    property string dateLabelFontSize: "large"
    property string monthLabelFontSize: "large"

    property alias dayLabelDelegate : dayLabelRepeater.delegate
    property alias dateLabelDelegate : dateLabelRepeater.delegate

    signal dateSelected(var date)

    height: column.height

    Column{
        id: column

        anchors.fill: parent
        spacing: units.gu(1.5)

        Label{
            id: monthLabel
            fontSize: monthLabelFontSize
            text: Qt.locale().standaloneMonthName(root.monthDate.getMonth())
            anchors.leftMargin: units.gu(1)
            anchors.left: parent.left
            anchors.right: parent.right
        }

        Row{
            id: dayLabelRow
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater{
                id: dayLabelRepeater
                model:7
                delegate: dafaultDayLabelComponent
            }
        }

        UbuntuShape {

            width: parent.width
            height: parent.height - monthLabel.height - dayLabelRow.height - units.gu(5) - units.gu(3)

            radius: "medium"

            Grid{
                id: monthGrid

                property int weekCount : 6
                property var monthStart: DateExt.getFirstDateofWeek(root.monthDate.getFullYear(),root.monthDate.getMonth())

                anchors {
                    fill: parent
                    topMargin: units.gu(1)
                    bottomMargin: units.gu(1)
                }

                rows: weekCount
                columns: 7

                Repeater{
                    id: dateLabelRepeater
                    model: monthGrid.rows * monthGrid.columns
                    delegate: defaultDateLabelComponent
                }
            }
        }
    }

    Component{
        id: defaultDateLabelComponent

        Item{
            id: dateRootItem
            property var date: parent.monthStart.addDays(index);
            property bool isCurrentMonth: DateExt.isSameMonth(root.monthDate,date)

            width: parent.width / 7;
            height: parent.height / parent.weekCount

            UbuntuShape{
                id: highLightRect

                anchors {
                    fill: parent
                    topMargin: units.gu(1)
                    bottomMargin: units.gu(1)
                }

                color: "#e5dbe6"
                visible: date.isSameDay(DateExt.today())
            }

            Label{
                id: dateLabel
                anchors.centerIn: parent
                text: date.getDate()
                horizontalAlignment: Text.AlignHCenter
                fontSize: root.dateLabelFontSize
                color: "#57365E"
                opacity: parent.isCurrentMonth ? 1. : 0.5
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    root.dateSelected(date);
                }
            }
        }
    }

    Component{
        id: dafaultDayLabelComponent

        Label{
            id: weekDay
            width: parent.width / 7
            property var day :Qt.locale().standaloneDayName(( Qt.locale().firstDayOfWeek + index), Locale.ShortFormat)
            text: day.toUpperCase();
            horizontalAlignment: Text.AlignHCenter
            fontSize: root.dayLabelFontSize
        }
    }
}
