import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
Page{
    id: root

    property int currentYear: DateExt.today().getFullYear();
    signal monthSelected(var date);

    Keys.forwardTo: [pathView]

    PathViewBase {
        id: pathView
        objectName: "YearView"

        anchors.fill: parent

        onNextItemHighlighted: {
            currentYear = currentYear + 1;
        }

        onPreviousItemHighlighted: {
            currentYear = currentYear - 1;
        }

        delegate: GridView{
            id: yearView
            clip: true
            focus: index == pathView.currentIndex

            property int scrollMonth: 0;
            property bool isCurrentItem: index == pathView.currentIndex
            property int year: (root.currentYear + pathView.indexType(index))

            width: parent.width
            height: parent.height
            anchors.top: parent.top

            readonly property int minCellWidth: units.gu(30)
            cellWidth: Math.floor(Math.min.apply(Math, [3, 4].map(function(n)
            { return ((width / n >= minCellWidth) ? width / n : width / 2) })))

            cellHeight: cellWidth * 1.4

            model: 12 /* months in a year */

            onYearChanged : {
                scrollMonth=0;
                yearView.positionViewAtIndex(scrollMonth,GridView.Beginning);
            }

            //scroll in case content height changed
            onHeightChanged: {
                scrollMonth=0;
                yearView.positionViewAtIndex(scrollMonth,GridView.Beginning);
            }


            Connections{
                target: pathView
                onScrollUp:{
                    scrollMonth -= 2;
                    if(scrollMonth < 0) {
                        scrollMonth = 0;
                    }
                    yearView.positionViewAtIndex(scrollMonth,GridView.Beginning);
                }

                onScrollDown:{
                    scrollMonth += 2;
                    var visibleMonths = yearView.height / cellHeight;
                    if( scrollMonth >= (11 - visibleMonths)) {
                        scrollMonth = (11 - visibleMonths);
                    }
                    yearView.positionViewAtIndex(scrollMonth,GridView.Beginning);
                }
            }

            delegate: Item {
                width: yearView.cellWidth
                height: yearView.cellHeight

                MonthComponent{
                    id: monthComponent
                    showEvents: false
                    currentMonth: new Date(yearView.year,index,1,0,0,0,0)

                    anchors.fill: parent
                    anchors.margins: units.gu(0.5)

                    dayLabelFontSize:"x-small"
                    dateLabelFontSize: "medium"
                    monthLabelFontSize: "medium"
                    yearLabelFontSize: "small"

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            root.monthSelected(monthComponent.currentMonth);
                        }
                    }
                }
            }
        }
    }
}
