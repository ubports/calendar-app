import QtQuick 2.0;
import Ubuntu.Components 0.1;
QtObject {
    property var recurrenceLabel:[i18n.tr("Once"),
        i18n.tr("Daily"),
        i18n.tr("Every Weekday (Monday to Friday)"),
        i18n.tr("Every Monday, Wednesday and Friday"),
        i18n.tr("Every Tuesday and Thursday"),
        i18n.tr("Weekly"),
        i18n.tr("Monthly"),
        i18n.tr("Yearly")];
}
