/*
 * Copyright (C) 2013-2014 Canonical Ltd
 *
 * This file is part of Ubuntu Calendar App
 *
 * Ubuntu Calendar App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Calendar App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "ViewType.js" as ViewType

Page{
    id: weekViewPage
    objectName: "weekViewPage"

    property var dayStart: new Date();
    property var firstDay: dayStart.weekStart(Qt.locale().firstDayOfWeek);
    property bool isCurrentPage: false

    signal dateSelected(var date);

    Keys.forwardTo: [weekViewPath]

    flickable: null

    Column {
        anchors.fill: parent
        anchors.top: parent.top
        anchors.topMargin: units.gu(1.5)
        spacing: units.gu(1)

        ViewHeader{
            id: viewHeader
            month: dayStart.getMonth()
            year: dayStart.getFullYear()
        }

        TimeLineHeader{
            id: weekHeader
            objectName: "weekHeader"
            type: ViewType.ViewTypeWeek
            date: firstDay

            onDateSelected: {
                weekViewPage.dateSelected(date);
            }
        }

        PathViewBase{
            id: weekViewPath
            objectName: "weekViewPath"

            width: parent.width
            height: weekViewPage.height - weekViewPath.y

            //This is used to scroll all view together when currentItem scrolls
            property var childContentY;

            onNextItemHighlighted: {
                nextWeek();
                weekHeader.incrementCurrentIndex()
            }

            onPreviousItemHighlighted: {
                previousWeek();
                weekHeader.decrementCurrentIndex()
            }

            function nextWeek() {
                dayStart = firstDay.addDays(7);
            }

            function previousWeek(){
                dayStart = firstDay.addDays(-7);
            }

            delegate: TimeLineBaseComponent {
                id: timeLineView

                type: ViewType.ViewTypeWeek

                width: parent.width
                height: parent.height

                isActive: timeLineView.PathView.isCurrentItem

                startDay: firstDay.addDays( weekViewPath.indexType(index) * 7)

                Connections{
                    target: weekViewPage
                    onIsCurrentPageChanged:{
                        if(weekViewPage.isCurrentPage){
                            timeLineView.scrollToCurrentTime();
                        }
                    }
                }

                //get contentY value from PathView, if its not current Item
                Binding{
                    target: timeLineView
                    property: "contentY"
                    value: weekViewPath.childContentY;
                    when: !timeLineView.PathView.isCurrentItem
                }

                //set PathView's contentY property, if its current item
                Binding{
                    target: weekViewPath
                    property: "childContentY"
                    value: contentY
                    when: timeLineView.PathView.isCurrentItem
                }
            }
        }
    }
}
