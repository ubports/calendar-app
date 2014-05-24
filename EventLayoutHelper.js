WorkerScript.onMessage = function(allSchs) {

    //sort schedules by duration, longest to shortest
    allSchs.sort(sortFunc);

    while( allSchs.length > 0) {
        var sch = allSchs[0];
        allSchs.splice(0, 1);

        //finds all schedules overlapping with current schedule and remove from original array
        var schs = findOverlappingSchedules(sch, allSchs);
        schs.push(sch);

        //schs contains all schedules overlapping with current schedules
        //now short those schedules from longest to shortest
        schs.sort(sortFunc);

        //assign position to schedules with respest to their duration and  start time
        var array = [];
        var maxDepth = assignDepth(schs, array);
        WorkerScript.sendMessage({ 'schedules': array,"maxDepth":maxDepth});
    }
}

//find all overlapping schedules respect to provided schedule
function findOverlappingSchedules( sch, schs) {
    var array = [];
    var i = 0;
    while( i < schs.length && schs.length > 0) {
        var otherSch = schs[i];
        if( doesOverlap(sch, otherSch) ) {
            schs.splice(i,1);
            array.push(otherSch);
            sch = mergeSchedules(sch,otherSch);
        } else {
            i++;
        }
    }
    return array;
}

//merges tow schedules and creates a schedule which is long engouth to contain both the of them
function mergeSchedules(sch1,sch2) {
    var sch = {};
    sch["start"] = Math.min(sch1.start,sch2.start);
    sch["duration"] = Math.max(sch1.duration,sch2.duration);
    sch["depth"] = 1;
    sch["id"] = "DUMMY";
    return sch;
}


//check if two schedules overlap each other
//is start time of one schedule is between
//start and end time of other schedule then it's considered as overlap
function doesOverlap( sch1, sch2) {
    if( sch1.start >= sch2.start && sch1.start < sch2.start + sch2.duration ) {
        return true;
    }

    if( sch2.start >= sch1.start && sch2.start < sch1.start + sch1.duration ) {
        return true;
    }

    return false;
}

//descending sort function for schedule
function sortFunc(sch1,sch2) {
    if(sch1.duration > sch2.duration) {
        return -1;
    }

    if(sch1.duration < sch2.duration) {
        return 1;
    }

    return 0;
}

//assign depth(position) of schedule with respest to other
function assignDepth(schs, array) {
    var maxDepth = 0;
    while( schs.length > 0 ) {
        var sch = schs[0];
        array.push(sch);
        schs.splice(0,1);
        var depth = findDepth(sch, schs);
        maxDepth = Math.max(maxDepth,depth);
    }
    return maxDepth;
}

function findDepth( sch, schs) {
    var maxDepth = 0;
    for( var i = 0; i < schs.length ; ++i) {
        var otherSch = schs[i];
        if( doesOverlap(sch, otherSch) ) {
            otherSch.depth ++;
            maxDepth = Math.max(maxDepth,otherSch.depth);
            sch = mergeSchedules(sch,otherSch);
        }
    }
    return maxDepth;
}
