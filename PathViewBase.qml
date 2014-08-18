/*
 * Copyright (C) 2014 Canonical Ltd
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

PathView {
    id: root

    model: 3
    snapMode: PathView.SnapOneItem

    signal nextItemHighlighted();
    signal previousItemHighlighted();

    signal scrollUp();
    signal scrollDown();

    preferredHighlightBegin: 0.5
    preferredHighlightEnd: 0.5

    path: Path {
        startX: -(root.width); startY: root.height/2
        PathLine { x: (root.width)*2  ; relativeY: 0;  }
    }

    // 0= current index, -1= previous index, 1 next index
    function indexType(index) {
        if (index === root.currentIndex) {
            return 0;
        }

        var previousIndex = root.currentIndex > 0 ? root.currentIndex - 1 : 2
        if ( index === previousIndex ) {
            return -1;
        }

        return 1;
    }

    Keys.onLeftPressed:{
        root.decrementCurrentIndex();
    }

    Keys.onRightPressed:{
        root.incrementCurrentIndex();
    }

    Keys.onSpacePressed: {
        root.scrollDown();
    }

    Keys.onDownPressed: {
        root.scrollDown();
    }

    Keys.onUpPressed: {
        root.scrollUp();
    }

    onCurrentIndexChanged: {
        var diff = currentIndex - intern.previousIndex
        if(diff == 0) return;

        if (intern.previousIndex === count - 1 && currentIndex === 0) diff = 1
        if (intern.previousIndex === 0 && currentIndex === count - 1) diff = -1

        intern.previousIndex = currentIndex

        if ( diff > 0 ) {
            root.nextItemHighlighted();
        }
        else {
            root.previousItemHighlighted();
        }
    }

    QtObject{
        id: intern
        property int previousIndex: root.currentIndex
    }
}
