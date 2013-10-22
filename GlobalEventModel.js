.pragma library

var model;
function gloablModel() {
    if( !model) {
        model = Qt.createQmlObject('import QtQuick 2.0; EventListModel {}', Qt.application, 'EventListModel.gloablModel()')
    }
    return model;
}
