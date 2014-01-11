import QtQuick 2.0
import Ubuntu.Components 0.1

Page{
    id: root
    anchors.fill: parent

    property var viewSource;
    property var view: loader.item

    signal loaded();

    Loader {
        id: loader
        anchors.fill: parent
        onLoaded:{
            root.loaded();
        }
    }

    function loadView(){
        loader.source = root.viewSource
    }
}
