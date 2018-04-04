import QtQuick 2.4

PinchArea {
    anchors.fill: parent
    pinch.minimumRotation: 0
    pinch.maximumRotation: 0
    pinch.minimumScale: 1
    pinch.maximumScale: 10

    property var targetX: null
    property var targetY: null
    property var originalX
    property var originalY
    property var minX: null
    property var maxX: null
    property var minY: null
    property var maxY: null
    property int threshCountX: 0
    property int threshCountY: 0
    property bool isInvertedX: false
    property bool isInvertedY: false
    property bool zoomAlongX: false
    property bool zoomAlongY: false

    readonly property int threshold: 20

    signal minHitX
    signal maxHitX
    signal minHitY
    signal maxHitY
    signal updateTargetX(real targetX);
    signal updateTargetY(real targetY);

    function isZoomAlongX(angle) {
        return ( (angle < 45 && angle > -45) || (angle > 135 || angle < -135) );
    }

    function isZoomAlongY(angle) {
        return ( (angle > 45 && angle < 135) || (angle < -45 && angle > -135) );
    }

    function scaledX(scale) {
        return (isInvertedX ? originalX*(1/scale) : originalX*scale);
    }

    function scaledY(scale) {
        return (isInvertedY ? originalY*(1/scale) : originalY*scale);
    }

    function respectUpperBound (value, max) {
        return (max ? Math.min(max, value) : value);
    }

    function respectLowerBound (value, min) {
        return (min ? Math.max(min, value) : value);
    }

    function updateThreshCount (min, max, target, threshCount) {
        if (target === max || target === min) {
            return threshCount+1;
        }
        else {
            return 0;
        }
    }

    function signalLimitHitX() {
        if (targetX === maxX) {
            maxHitX()
        }
        if (targetX === minX) {
            minHitX()
        }
    }

    function signalLimitHitY() {
        if (targetY === maxY) {
            maxHitY()
        }
        if (targetY === minY) {
            minHitY()
        }
    }

    onPinchUpdated: {
        if (zoomAlongX) {
            updateTargetX(respectLowerBound(respectUpperBound(scaledX(pinch.scale), maxX), minX));
            threshCountX = updateThreshCount(minX, maxX, targetX, threshCountX);

            if (threshCountX > threshold) {
                signalLimitHitX();
                threshCountX /= 2;
            }
        }

        if (zoomAlongY) {
            updateTargetY(respectLowerBound(respectUpperBound(scaledY(pinch.scale), maxY), minY));
            threshCountY = updateThreshCount(minY, maxY, targetY, threshCountY);

            if (threshCountY > threshold) {
                signalLimitHitY();
                threshCountY /= 2;
            }
        }
    }

    onPinchStarted: {
        if (targetX !== null && isZoomAlongX(pinch.angle)) {
            zoomAlongX = true;
        }

        if (targetY !== null && isZoomAlongY(pinch.angle)) {
            zoomAlongY = true;
        }

        originalX = targetX;
        originalY = targetY;
    }

    onPinchFinished: {
        zoomAlongX = false;
        zoomAlongY = false;
    }
}
