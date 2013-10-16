import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt

PathViewBase {
    id: root

    property var currentYear: DateExt.today();

    signal monthSelected(var date);

    anchors.fill: parent

    onNextItemHighlighted: {
        currentYear = getDateFromYear(currentYear.getFullYear() + 1);
    }

    onPreviousItemHighlighted: {
        currentYear = getDateFromYear(currentYear.getFullYear() - 1);
    }

    function getDateFromYear(year) {
        return new Date(year,0,1,0,0,0,0);
    }

    QtObject{
        id: intern
        property var startYear: getDateFromYear(currentYear.getFullYear()-1);
    }

    delegate: GridView{
        id: yearView
        clip: true

        property var year: getYear();

        function getYear() {
            switch( root.indexType(index)) {
            case 0:
                return intern.startYear;
            case -1:
                return getDateFromYear(intern.startYear.getFullYear() - 1);
            case 1:
                return getDateFromYear(intern.startYear.getFullYear() + 1);
            }
        }

        width: parent.width
        height: parent.height
        anchors.top: parent.top

        cellWidth: width/2
        cellHeight: cellWidth * 1.2

        model: 12 /* months in a year */
        snapMode: GridView.SnapOneRow
        delegate: Item {
            width: yearView.cellWidth
            height: yearView.cellHeight

            MonthComponent{
                id: monthComponent
                monthDate: new Date(yearView.year.getFullYear(),index,1,0,0,0,0)
                anchors.fill: parent
                anchors.margins: units.gu(0.5)

                dayLabelFontSize:"x-small"
                dateLabelFontSize: "medium"
                monthLabelFontSize: "medium"
                yearLabelFontSize: "small"

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        root.monthSelected(monthComponent.monthDate);
                    }
                }
            }
        }
    }
}
