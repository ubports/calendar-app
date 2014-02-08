.pragma library

var reminderLabel = getReminderLabels();
//value in seconds
var reminderValue = [ 0,
    300 /*5 * 60*/,
    900 /*15* 60*/,
    1800 /*30* 60*/,
    3600 /*1*60*60*/,
    7200 /*2*60*60*/,
    86400 /*24*60*60*/,
    172800 /*2*24*60*60*/,
    604800 /*7*24*60*60*/,
    1209600 /*14*24*60*60*/];

function getReminderLabels() {
    var object = Qt.createQmlObject('\
        import QtQuick 2.0;\
        import Ubuntu.Components 0.1;\
        QtObject {\
            property var reminderLabel:[i18n.tr("No Reminder"),\
                i18n.tr("5 minutes"),\
                i18n.tr("15 minutes"),\
                i18n.tr("30 minutes"),\
                i18n.tr("1 hour"),\
                i18n.tr("2 hours"),\
                i18n.tr("1 day"),\
                i18n.tr("2 days"),\
                i18n.tr("1 week"),\
                i18n.tr("2 weeks")];}', Qt.application, 'ReminderLabelObj');
    return object.reminderLabel;
}

