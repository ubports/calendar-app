import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

ListView {
    id: diaryView

    property var dayStart: new Date()

    property bool expanding: false
    property bool compressing: false
    property bool expanded: false

    signal compressRequest()
    signal compressComplete()
    signal expandRequest()
    signal expandComplete()

    clip: true

    model: EventListModel {
        termStart: dayStart
        termLength: Date.msPerDay
    }

    section {
        property: "category"
        labelPositioning: ViewSection.CurrentLabelAtStart
        delegate: ListItem.Header {
            text: i18n.tr(section)
        }
    }

    delegate: ListItem.Standard {
        text: startTime.toLocaleTimeString(Qt.locale(i18n.language), Locale.ShortFormat) + "   " + title
    }

    footer: ListItem.Standard {
        text: i18n.tr("(+) New Event / Todo")
    }

    onContentYChanged: {
        if (!dragging) return
        if (expanding || compressing) return

        if (expanded) {
            if (contentY > units.gu(3)) {
                compressing = true
                compressRequest()
            }
        }
        else {
            if (contentY < 0) {
                expanding = true
                expandRequest()
            }
        }
    }

    onDraggingVerticallyChanged: {
        if (expanding) {
            expanding = false
            expandComplete()
        }
        if (compressing) {
            compressing = false
            compressComplete()
        }
    }
}
