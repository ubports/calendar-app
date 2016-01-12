import QtQuick 2.0
import Ubuntu.Components 1.1

Item{
    id: dateRootItem

    property int date;
    property bool isCurrentMonth;
    property bool isToday;
    property bool showEvent;
    property alias fontSize: dateLabel.font.pixelSize

    UbuntuShape{
        visible: isToday && isCurrentMonth
        color: isToday && !isSelected ? "#DD4814" : "gray"

        Rectangle{
            anchors.fill: parent
            anchors.margins: units.gu(0.5)
            color: isToday ? "#DD4814" : "darkgray"
        }

        width: Math.max(parent.height, parent.width) / 1.3
        height: width
        anchors.centerIn: dateLabel
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

    Rectangle {
        id: eventIndicator

        width: units.gu(0.8)
        height: width
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.verticalCenter
            topMargin: ((Math.min(parent.height, dateRootItem.width) / 1.3) / 2) + units.gu(0.1)
        }
        anchors.top: dateLabel.bottom
        anchors.topMargin: dateRootItem.height/4
        radius: height/2
        color:"black"
        visible: showEvent
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
