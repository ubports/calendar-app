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
    property string monthLabelFontSize: "x-large"
    property string yearLabelFontSize: "large"

    property alias dayLabelDelegate : dayLabelRepeater.delegate
    property alias dateLabelDelegate : dateLabelRepeater.delegate

    signal dateSelected(var date)

    height: ubuntuShape.height

    UbuntuShape {
        id: ubuntuShape

        anchors.fill: parent
        radius: "medium"

        Column{
            id: column

            anchors.top: parent.top
            anchors.topMargin: units.gu(1.5)
            anchors.fill: parent
            spacing: units.gu(1.5)

            Item{
                id: monthHeader
                width: parent.width
                height: monthLabel.height

                Label{
                    id: monthLabel
                    objectName: "monthLabel"
                    fontSize: monthLabelFontSize
                    text: Qt.locale().standaloneMonthName(root.monthDate.getMonth())
                    anchors.leftMargin: units.gu(1)
                    anchors.left: parent.left
                    //color:"white"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label{
                    id: yearLabel
                    objectName: "yearLabel"
                    fontSize: yearLabelFontSize
                    text: root.monthDate.getFullYear()
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(1)
                    color:"#AEA79F"
                    anchors.verticalCenter: parent.verticalCenter
                }
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

            Grid{
                id: monthGrid
                objectName: "monthGrid"

                property int weekCount : 6
                property var monthStart: root.monthDate.weekStart( Qt.locale().firstDayOfWeek )

                width: parent.width
                height: parent.height - monthHeader.height - dayLabelRow.height - units.gu(3)

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

                width: parent.width
                height: width
                anchors.centerIn: parent

                color: "white"
                visible: date.isSameDay(DateExt.today()) && isCurrentMonth
            }

            Label{
                id: dateLabel
                anchors.centerIn: parent
                text: date.getDate()
                horizontalAlignment: Text.AlignHCenter
                fontSize: root.dateLabelFontSize
                color: {
                    if( date.isSameDay(DateExt.today()) && isCurrentMonth ) {
                        "#2C001E"
                    } else if( parent.isCurrentMonth ) {
                        "white"
                    } else {
                        "#AEA79F"
                    }
                }
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
            color: "#AEA79F"
        }
    }
}
