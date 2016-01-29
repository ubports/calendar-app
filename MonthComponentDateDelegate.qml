import QtQuick 2.0
import Ubuntu.Components 1.3

Item{
    id: dateRootItem

    property int date;
    property bool isCurrentMonth;
    property bool isToday;
    property bool showEvent;
    property alias fontSize: dateLabel.font.pixelSize

    property bool isSelected: false

    Loader {
        sourceComponent: (isToday && isCurrentMonth) || isSelected ? highLightComp : undefined

        onSourceComponentChanged: {
            width = Qt.binding( function() {
                var width = dateRootItem.height > dateRootItem.width ? dateRootItem.width :dateRootItem.height
                return ( width / 1.3 );
            });
            height = Qt.binding ( function() { return width} );
            anchors.centerIn = Qt.binding( function() { return dateLabel});
        }
    }

    Label {
        id: dateLabel
        anchors.centerIn: parent
        text: date
        fontSize: root.dateLabelFontSize
        color: {
            if( isCurrentMonth ) {
                if( isToday || isSelected ) {
                    "white"
                } else {
                    "#5D5D5D"
                }
            } else {
                if(isSelected) {
                    "white"
                } else {
                    "#AEA79F"
                }
            }
        }
    }

    Loader{
        sourceComponent: showEvent ? eventIndicatorComp : undefined
        onSourceComponentChanged: {
            width = Qt.binding( function() { return units.gu(0.8)})
            height = Qt.binding( function() { return width })
            anchors.horizontalCenter = Qt.binding( function() { return  parent.horizontalCenter })
            anchors.top = Qt.binding( function() { return parent.verticalCenter })
            anchors.topMargin = Qt.binding( function() {
                var w = (dateRootItem.height > dateRootItem.width ? dateRootItem.width :dateRootItem.height)/1.3
                return (w/2) + units.gu(0.1)
            });
        }
    }

    Component{
        id: eventIndicatorComp
        Rectangle {
            anchors.fill: parent
            radius: height/2
            color: "black"
        }
    }

    Component{
        id: highLightComp
        UbuntuShape{
            color: {
                if( isToday && !isSelected ) {
                    "#DD4814"
                } else {
                    "gray"
                }
            }

            Rectangle{
                anchors.fill: parent
                anchors.margins: units.gu(0.5)
                color: isToday ? "#DD4814" : "darkgray"
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressAndHold: {
            if( isSelected ) {
                var selectedDate = new Date();
                selectedDate.setFullYear(intern.monthStartYear)
                selectedDate.setMonth(intern.monthStartMonth + 1)
                selectedDate.setDate(date)
                selectedDate.setMinutes(60, 0, 0)
                pageStack.push(Qt.resolvedUrl("NewEvent.qml"), {"date":selectedDate, "model":eventModel});
            }
        }
        onClicked: {
            var selectedDate = new Date(intern.monthStartYear,
                                        intern.monthStartMonth,
                                        intern.monthStartDate + index, 0, 0, 0, 0)
            if( isYearView ) {
                //If yearView is clicked then open selected MonthView
                root.monthSelected(selectedDate);
            } else {
                if( isSelected ) {
                    //If monthView is clicked then open selected DayView
                    root.dateSelected(selectedDate);
                } else {
                    intern.selectedIndex = index
                    root.dateHighlighted(selectedDate)
                }
            }
        }
    }
}
