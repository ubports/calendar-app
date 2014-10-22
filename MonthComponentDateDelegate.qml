import QtQuick 2.0
import Ubuntu.Components 1.1

Item{
    id: dateRootItem

    property int date;
    property bool isCurrentMonth;
    property bool isToday

    Loader {
        width: parent.width < parent.height ? parent.width : parent.height
        height: width
        anchors.centerIn: parent
        sourceComponent: isToday && isCurrentMonth ? highLightComp : undefined
    }

    Label {
        id: dateLabel
        anchors.centerIn: parent
        width: parent.width
        text: date
        horizontalAlignment: Text.AlignHCenter
        fontSize: root.dateLabelFontSize
        color: {
            if( isCurrentMonth ) {
                if(isToday) {
                    "white"
                } else {
                    "#5D5D5D"
                }
            } else {
                "#AEA79F"
            }
        }
    }

    Loader{
        property bool shouldLoad: showEvents
                                  && intern.eventStatus !== undefined
                                  && intern.eventStatus[index] !== undefined
                                  &&intern.eventStatus[index]
        sourceComponent: shouldLoad ? eventIndicatorComp : undefined
        anchors.top: dateLabel.bottom
        anchors.horizontalCenter: dateLabel.horizontalCenter
    }

    MouseArea {
        anchors.fill: parent
        onPressAndHold: {
            var selectedDate = new Date();
            selectedDate.setFullYear(intern.monthStartYear)
            selectedDate.setMonth(intern.monthStartMonth + 1)
            selectedDate.setDate(date)
            selectedDate.setMinutes(60, 0, 0)
            pageStack.push(Qt.resolvedUrl("NewEvent.qml"), {"date":selectedDate, "model":eventModel});
        }
        onClicked: {
            var selectedDate = new Date(intern.monthStartYear,
                                        intern.monthStartMonth,
                                        intern.monthStartDate + index, 0, 0, 0, 0)
            //If monthView is clicked then open selected DayView
            if ( isYearView === false ) {
                root.dateSelected(selectedDate);
            }
            //If yearView is clicked then open selected MonthView
            else {
                root.monthSelected(selectedDate);
            }
        }
    }
}
