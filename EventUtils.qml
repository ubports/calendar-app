import QtQuick 2.3
import Ubuntu.Components 1.1
import QtOrganizer 5.0
import "Defines.js" as Defines


QtObject{
    id:eventUtil
    function getWeekDaysIndex(daysOfWeek){
        var index = 0;
        if(compareArrays(daysOfWeek,[Qt.Monday,Qt.Tuesday,Qt.Wednesday,Qt.Thursday,Qt.Friday]))
            index = 2
        else if(compareArrays(daysOfWeek,[Qt.Monday,Qt.Wednesday,Qt.Friday]))
            index = 3
        else if(compareArrays(daysOfWeek,[Qt.Tuesday,Qt.Thursday]))
            index = 4
        else
            index = 5
        return index;
    }

    function compareArrays(daysOfWeek, actualArray){
        if (daysOfWeek.length !== actualArray.length) return false;
        for (var i = 0; i < actualArray.length; i++) {
            if (daysOfWeek[i] !== actualArray[i]) return false;
        }
        return true;
    }
    function getDaysOfWeek(index,weekDays){
        var daysOfWeek = [];
        switch(index){
        case 2:
            daysOfWeek = [Qt.Monday,Qt.Tuesday,Qt.Wednesday,Qt.Thursday,Qt.Friday];
            break;
        case 3:
            daysOfWeek = [Qt.Monday,Qt.Wednesday,Qt.Friday];
            break;
        case 4:
            daysOfWeek = [Qt.Tuesday,Qt.Thursday];
            break;
        case 5:
            daysOfWeek = weekDays.length === 0 ? [date.getDay()] : weekDays;
            break;
        }
        return daysOfWeek;
    }
    function getRecurrenceString(recurrenceRule){
        var index;
        var str = "";
        index = ( recurrenceRule.length > 0 ) ? recurrenceRule[0].frequency : 0;
        if(index === RecurrenceRule.Weekly){
            index = getWeekDaysIndex(recurrenceRule[0].daysOfWeek )
            if (index === 5)
                str += "Every "
        }
        if(index === RecurrenceRule.Monthly)
            index = 6
        if(index === RecurrenceRule.Yearly)
            index = 7
        str = Defines.recurrenceLabel[index]
        if(index > 0){
            if(recurrenceRule[0].limit !== undefined){
                var temp = recurrenceRule[0].limit;
                console.log("Value is " + temp);
                if(parseInt(temp)){
                    str += ";  " + temp + "times "
                }
                else{
                    // TRANSLATORS: this is a date shown in the event details view,
                    // see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details
                    var dateFormat = i18n.tr("ddd MMMM d yyyy");
                    str += "; until " + temp.toLocaleString(Qt.locale(), dateFormat)
                }
            }
        }
        return str;

    }
}
