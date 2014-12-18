import QtQuick 2.0
import Ubuntu.Components 1.1

Item{
    id: dateRootItem

    property int date;
    property bool isCurrentMonth;
    property bool isToday;
    property bool showEvent;
    property alias fontSize: dateLabel.font.pixelSize

    Loader {
        sourceComponent: isToday && isCurrentMonth ? highLightComp : undefined
        onSourceComponentChanged: {
            width = Qt.binding( function() { return ( dateRootItem.height / 1.5 ); });
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
        width: units.gu(1)
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: dateLabel.bottom
        anchors.topMargin: dateRootItem.height/4
        sourceComponent: showEvent ? eventIndicatorComp : undefined
    }

    Component{
        id: eventIndicatorComp
        Rectangle {
            anchors.fill: parent
            radius: height/2
            color:"#5E2750"
        }
    }

    Component{
        id: highLightComp
        UbuntuShape{
            color: "#DD4814"
        }
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
