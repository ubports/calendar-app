import QtQuick 2.0

PathView {
    id: root

    model: 3
    snapMode: PathView.SnapOneItem

    signal nextItemHighlighted();
    signal previousItemHighlighted();

    path: Path {
        startX: -(root.width/2 ); startY: root.height/2
        PathLine { relativeX: root.width; relativeY: 0 }
        PathLine { relativeX: root.width; relativeY: 0 }
        PathLine { relativeX: root.width; relativeY: 0 }
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
