.pragma library

var model;
function globalModel() {
    if( !model) {
        model = Qt.createQmlObject('import QtQuick 2.0; EventListModel {}', Qt.application, 'EventListModel.globalModel()')
    }
    return model;
}
