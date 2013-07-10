import QtQuick 2.0
import Ubuntu.Components 0.1

PathViewBase {
    id: root

    anchors.fill: parent
    property var year: getDateFromYear(intern.now.getFullYear()-1);

    signal monthSelected(var date);

    onNextItemHighlighted: {
        year = getDateFromYear(year.getFullYear() + 1);
    }

    onPreviousItemHighlighted: {
        year = getDateFromYear(year.getFullYear() - 1);
    }

    function getDateFromYear(year) {
        return new Date(year,0,1,0,0,0,0);
    }

    QtObject{
        id: intern
        property var now: new Date()
        property int weekstartDay: Qt.locale().firstDayOfWeek
    }

    delegate: Item{
        id: yearView

        property var year: {
            if (index === root.currentIndex) {
                return root.year;
            }
            var previousIndex = root.currentIndex > 0 ? root.currentIndex - 1 : 2

            if ( index === previousIndex ) {
                return getDateFromYear(root.year.getFullYear()-1);
            }

            return getDateFromYear(root.year.getFullYear()+ 1);
        }

        width: parent.width
        height: parent.height

        Label{
            id: yearLabel
            text: year.getFullYear()
            fontSize: "large"
            anchors.horizontalCenter: parent.horizontalCenter
            font.bold: true
        }

        Grid{
            id: yearGrid
            rows: 4
            columns: 3

            width: parent.width
            height: parent.height
            anchors.top: yearLabel.bottom
            spacing: units.gu(2.5)

            Repeater{
                model: yearGrid.rows * yearGrid.columns
                delegate: MonthComponent{
                    date: new Date(year.getFullYear(),index,1,0,0,0,0)

                    onMonthSelected: {
                        root.monthSelected(date);
                    }
                }
            }
        }
    }
}
