WorkerScript.onMessage = function(message) {
    console.debug("UIIIIIIIIIII	")
    var processedEvents =  dayEventsMap(message.events)
    WorkerScript.sendMessage({'reply': processedEvents})
}

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
    var eventAEndTime = eventA.endTimeInSecs
    var eventBEndTime = eventB.endTimeInSecs
    if (eventAEndTime > eventBEndTime)
        return -1
    else if (eventAEndTime < eventBEndTime)
        return 1
    return 0
}

/*
 * look for the minumum available 'y' on a list of events
 */
function findOptimalY(intersections)
{
    if (intersections.length === 0)
        return

    var eventWidth = 1.0 / intersections.length
    var yArray = new Array(intersections.length)

    for (var i = 0; i < intersections.length; i++) {
        var intersection = intersections[i]
        for (var y=0; y < yArray.length; y++) {
            if (!yArray[y] || (yArray[y].endTime <= intersection.startTime)) {
                intersection.y = y
                intersection.width = eventWidth
                intersection.intersectionCount = intersections.length
                yArray[y] = intersection
                break
            }
        }
    }
}

function dayEventsMap(eventsInfo)
{
    eventsInfo.sort(sortByStartAndSize)

    var events = eventsInfo.slice()
    var lines = []

    while (events.length > 0) {
        var aux = {"startTime": 0, "ednTime": 0}
        var eventA = events[0]
        events.splice(0, 1)
        var line = [eventA]

        aux.starTime = eventA.startTime
        aux.endTime = eventA.endTime

        var newList = []
        for(var i = 0; i < events.length; i++) {
            var eventB = events[i]
            if ((aux.startTime < eventB.endTime) &&
                (eventB.startTime < aux.endTime)) {
                if (aux.endTime < eventB.endTime)
                    aux.endTime = eventB.endTime
                line.push(eventB)
            } else {
                newList.push(eventB)
            }
        }

        findOptimalY(line)
        lines.push(line)
        events = newList
    }

    return eventsInfo
}
