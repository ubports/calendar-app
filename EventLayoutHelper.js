/*
 * Copyright (C) 2013-2014 Canonical Ltd
 *
 * This file is part of Ubuntu Calendar App
 *
 * Ubuntu Calendar App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Calendar App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
WorkerScript.onMessage = function(events) {

    //returns sorted array of schedules
    //schedule is start time and duration
    var allSchs = processEvents(events);

    while( allSchs.length > 0) {
        var sch = allSchs.shift();

        //finds all schedules overlapping with current schedule and remove from original array
        var schs = findOverlappingSchedules(sch, allSchs);

        //insert original schedule first, so array remain sorted
        schs.unshift(sch);

        //assign position to schedules with respest to their duration and  start time
        var array = [];
        var maxDepth = assignDepth(schs, array);
        WorkerScript.sendMessage({ 'schedules': array,"maxDepth":maxDepth});
    }
}


function getMinutes(time) {
    return time.getHours() * 60 + time.getMinutes();
}

function getDuration(event) {
    var start = getMinutes(event.startDateTime);
    var end = getMinutes(event.endDateTime);
    return end - start;
}

function processEvents(events) {
    var array = [];
    for( var i = 0; i < events.length ; ++i) {
        var event = events[i]
        var sch = {};
        sch["start"] = getMinutes(event.startDateTime);
        sch["duration"] = getDuration(event);
        sch["id"] = event.id;
        sch["depth"] = 0;
        sortedInsert(array,sch);
    }
    return array;
}

//insert in to array using insertion sort
function sortedInsert(array, sch) {
    for(var i = array.length-1; i >=0 ; --i) {
        var temp = array[i];
        if( sch.duration < array[i].duration) {
            array.splice(i+1,0,sch);
            return;
        }
    }
    array.push(sch);
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

//assign depth(position) of schedule with respect to other
function assignDepth(schs, array) {
    var maxDepth = 0;
    while( schs.length > 0 ) {
        var sch = schs.shift()
        array.push(sch);
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
