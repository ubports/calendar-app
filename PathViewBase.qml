import QtQuick 2.0

PathView {
    id: root

    model: 3
    snapMode: PathView.SnapOneItem

    signal nextItemHighlighted();
    signal previousItemHighlighted();

    signal scrollUp();
    signal scrollDown();

    path: Path {
        startX: -(root.width/2); startY: root.height/2
        PathLine { relativeX: root.width; relativeY: 0 }
        PathLine { relativeX: root.width; relativeY: 0 }
        PathLine { relativeX: root.width; relativeY: 0 }
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
