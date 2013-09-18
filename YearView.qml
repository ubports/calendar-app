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

    delegate: Flickable{
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

        contentHeight: yearGrid.height + units.gu(2)
        contentWidth: width

        Grid{
            id: yearGrid
            rows: 6
            columns: 2

            anchors.top: parent.top
            anchors.topMargin: units.gu(1.5)

            width: parent.width - ((columns-1) * yearGrid.spacing)
            spacing: units.gu(2)
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater{
                model: yearGrid.rows * yearGrid.columns
                delegate: MonthComponent{
                    monthDate: new Date(yearView.year.getFullYear(),index,1,0,0,0,0)
                    width: (parent.width - units.gu(2))/2
                    height: width * 1.5
                    dayLabelFontSize:"x-small"
                    dateLabelFontSize: "medium"
                    monthLabelFontSize: "medium"
                    yearLabelFontSize: "small"

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            root.monthSelected(monthDate);
                        }
                    }
                }
            }
        }
    }
}
