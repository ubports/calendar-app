import QtQuick 2.0

PathView {
    id: root

    model: 3
    snapMode: PathView.SnapOneItem

    signal nextItemHighlighted();
    signal previousItemHighlighted();

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

    onCurrentIndexChanged: {
        var diff = currentIndex - intern.previousIndex

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
