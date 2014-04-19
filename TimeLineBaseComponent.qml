import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import QtOrganizer 5.0

import "dateExt.js" as DateExt
import "ViewType.js" as ViewType

Item {
    id: root

    property var startDay: DateExt.today();
    property alias contentY: timeLineView.contentY
    property alias contentInteractive: timeLineView.interactive

    property int type: ViewType.ViewTypeWeek

    function scrollToCurrentTime() {
        //scroll to current time
        var currentTime = new Date();
        //TODO: if current time is early morning should we show time from 9 am ?
        var hour = currentTime.getHours();

        timeLineView.contentY = hour * units.gu(10);
        if(timeLineView.contentY >= timeLineView.contentHeight - timeLineView.height) {
            timeLineView.contentY = timeLineView.contentHeight - timeLineView.height
        }
    }

    EventListModel {
        id: mainModel
        startPeriod: startDay.midnight();
        endPeriod: type == ViewType.ViewTypeWeek ? startPeriod.addDays(7).endOfDay(): startPeriod.endOfDay()
    }


    Column {
        anchors.top: parent.top

        width: parent.width
        height: parent.height

        AllDayEventComponent{
            id: allDayContainer
            type: root.type
            startDay: root.startDay
            model: mainModel
            Component.onCompleted: {
                model.addModelChangeListener(createAllDayEvents);
            }
        }

        Flickable{
            id: timeLineView

            width: parent.width
            height: parent.height - allDayContainer.height

            contentHeight: units.gu(10) * 24
            contentWidth: width

            clip: true

            TimeLineBackground{
            }

            Row{
                id: week
                width: parent.width
                height: parent.height
                anchors.top: parent.top

                Repeater{
                    model: type == ViewType.ViewTypeWeek ? 7 : 1

                    delegate: TimeLineBase {
                        property int idx: index
                        anchors.top: parent.top
                        width: {
                            if( type == ViewType.ViewTypeWeek ) {
                                 parent.width/7
                            } else {
                                (parent.width)
                            }
                        }
                        height: parent.height
                        delegate: comp
                        day: startDay.addDays(index)

                        model: mainModel
                        Component.onCompleted: {
                            model.addModelChangeListener(createEvents);
                        }
                    }
                }
            }
        }
    }

    Component{
        id: comp
        EventBubble{
            type: {
                if( root.type == ViewType.ViewTypeWeek ) {
                    narrowType
                } else {
                    wideType
                }
            }
            //anchors.left: parent.left
            //anchors.right: parent.right
            //anchors.leftMargin: units.gu(0.1)
            //anchors.rightMargin: units.gu(0.1)
            flickable: timeLineView
            clip: true
        }
    }
}
