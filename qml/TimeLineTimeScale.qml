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

import QtQuick 2.4
import Ubuntu.Components 1.3

Flickable{
    id: timeFlickble

    property real timeLabelHeight: 0
    property real hourItemHeight: units.gu(4)
    property real headerHeight

    height: parent.height
    width: leftColumnContentWithPadding.width
    contentHeight: 24 * hourItemHeight
    contentWidth: width

    interactive: false

    clip: true

    function yToHour (height) {
        return (contentY + (height - headerHeight)) / hourItemHeight;
    }


    MultiPointTouchArea {
        id: businessHourSetter

        property bool isStatic: true
        property real staticTolerance: units.gu(0.5)
        property var startPoint1;
        property var startPoint2;

        minimumTouchPoints: 2
        maximumTouchPoints: 2
        anchors.fill: parent

        onPressed: {
            startPoint1 = Qt.point(touchPoints[0].sceneX, touchPoints[0].sceneY);
            startPoint2 = Qt.point(touchPoints[1].sceneX, touchPoints[1].sceneY);

            touchTimer.wasLong = false;
            isStatic = true;

            touchTimer.restart()
        }

        onUpdated: {
            touchPoints.forEach( function(entry) {
                if (manhattanDistance(Qt.point(entry.x, entry.y), Qt.point(entry.startX, entry.startY)) > staticTolerance) {
                    isStatic = false;
                }
            });
        }

        onReleased: {
            touchTimer.stop();
        }

        Timer {
            id: touchTimer
            property bool wasLong: false

            interval: 1000
            repeat: false
            onTriggered: {
                if (businessHourSetter.isStatic) {
                    wasLong = true;

                    var newBusinessHourStart = yToHour(Math.min(businessHourSetter.startPoint1.y, businessHourSetter.startPoint2.y));
                    var newBusinessHourEnd = yToHour(Math.max(businessHourSetter.startPoint1.y, businessHourSetter.startPoint2.y));

                    settings.businessHourStart = newBusinessHourStart;
                    settings.businessHourEnd = newBusinessHourEnd;
                }
            }
        }

        function manhattanDistance(point1, point2) {
            var diff = Qt.point(point1.x - point2.x, point1.y - point2.y);
            return Math.abs(diff.x) + Math.abs(diff.y);
        }
    }

    Column {
        id: timeLine
        width: parent.width

        Repeater {
            model: 24 // hour in a day

            delegate: Item {
                width: parent.width
                height: hourItemHeight

                Label {
                    id: timeLabel
                    width: localizedTimeLabelTemplate.width
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(0.5)
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignRight
                    text: Qt.formatTime(new Date(0,0,0,index), Qt.SystemLocaleShortDate)
                    color: UbuntuColors.lightGrey
                    fontSize: "small"

                    Binding{
                        target: timeFlickble
                        property: "timeLabelHeight"
                        value: timeLabel.height+2*timeLabel.anchors.topMargin
                    }
                }

                SimpleDivider{}
            }
        }
    }
}
