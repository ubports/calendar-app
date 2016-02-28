.pragma library
.import "dateExt.js" as DateExt

function sortByStartAndSize(eventA, eventB)
{
    var sort = sortEventsByStart(eventA, eventB)
    if (sort === 0)
        sort = sortEventsBySize(eventA, eventB)
    return sort
}

function sortEventsByStart(eventA, eventB)
{
        if (eventA.startTime < eventB.startTime)
            return -1
        else if (eventA.startTime > eventB.startTime)
            return 1
        else
            return 0
}

function sortEventsBySize(eventA, eventB)
{
    var eventAEndTime = eventA.event.endDateTime.getTime()
    var eventBEndTime = eventB.event.endDateTime.getTime()
    if (eventAEndTime > eventBEndTime)
        return -1
    else if (eventAEndTime < eventBEndTime)
        return 1
    return 0
}

function minutesSince(since, until)
{
    var sinceTime = new Date(since)
    sinceTime.setSeconds(0)
    var untilTime =  new Date(until)
    untilTime.setSeconds(0)

    var sinceTimeInSecs = sinceTime.getTime()
    var untilTimeInSecs = untilTime.getTime()

    // limit to since day minutes
    untilTimeInSecs = Math.min(sinceTime.endOfDay().getTime(), untilTimeInSecs)

    // calculate the time in minutes of this event
    var totalSecs =  untilTimeInSecs - sinceTimeInSecs
    if (totalSecs > 0)
        return (totalSecs / 60000)

    return 0
}

function findOptimalY(intersections)
{
    if (intersections.length === 0)
        return 0

    var found
    var optimalY = 0
    while(true) {
        found = false
        for(var i=0; i < intersections.length; i++) {
            if (optimalY === intersections[i].y) {
                found = true
                break
            }
        }
        if (found)
            optimalY++
        else
            return optimalY
    }
}

function dayEventsMap(model, date)
{
    var eventsInfo = []

    var startDate = date.midnight()
    var itemsOfTheDay = model.itemsByTimePeriod(startDate, startDate.endOfDay())

    // put events with the same start time together
    for(var c=0; c < itemsOfTheDay.length; c++) {
        var event = itemsOfTheDay[c]
        if (event.allDay)
            continue

        var eventStartTimeInMinutes = minutesSince(startDate, event.startDateTime)
        var eventEndTimeInMinutes = minutesSince(startDate, event.endDateTime)
        eventsInfo.push({'event': event,
                         'startTime': eventStartTimeInMinutes,
                         'endTime': eventEndTimeInMinutes,
                         'y': -1,
                         'intersectionCount': 0,
                         'width': 1.0})
    }

    eventsInfo.sort(sortByStartAndSize)

    // intersections
    var lines = []
    for(var i=0; i < eventsInfo.length; i++) {
        var eventA = eventsInfo[i]
        line = [eventA]
        for(var y=0; y < eventsInfo.length; y++) {
            if (y === i)
                continue
            var eventB = eventsInfo[y]
            if ((eventA.startTime < eventB.endTime) &&
                (eventB.startTime < eventA.endTime)) {
                line.push(eventB)
            }
        }
        eventA.intersectionCount = line.length - 1
        lines.push(line)
    }

    // calculate y
    for (var l=0; l < lines.length; l++) {
        var time = -1

        var line = lines[l]
        var eventA = line[0]
        if (eventA.y === -1) {
            eventA.y = findOptimalY(line)
        }
        var time = eventA.startTime
        for (var i=1; i < line.length; i++) {
            var event = line[i]
            if ((event.startTime === time) && (event.y === -1)) {
                event.y = findOptimalY(line)
            }
        }
    }

    for (var l=0; l < lines.length; l++) {
        var line = lines[l]
        var eventA = line[0]
        var maxY = eventA.y
        for (var i=1; i < line.length; i++) {
            var event = line[i]
            if (maxY < event.y)
                maxY = event.y
        }
        if (maxY > 0)
            eventA.width = 1 / (maxY + 1)
    }

    return eventsInfo
}
