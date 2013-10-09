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

            ViewHeader{
                id: monthHeader
                date: root.monthDate
                monthLabelFontSize: root.monthLabelFontSize
                yearLabelFontSize: root.yearLabelFontSize
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

            property bool shouldCreateHighlight: date.isSameDay(DateExt.today()) && isCurrentMonth
            property var hightlightObj;

            onShouldCreateHighlightChanged: {
                if( shouldCreateHighlight ) {
                    hightlightObj = highLightComp.createObject(dateRootItem);
                    hightlightObj.z = hightlightObj.z -1;
                } else {
                    if( hightlightObj) {
                        hightlightObj.destroy();
                    }
                }
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

    Component{
        id: highLightComp
        UbuntuShape{
            id: highLightRect

            width: parent.width
            height: width
            anchors.centerIn: parent
            color: "white"
        }
    }
}
