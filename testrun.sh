#! /bin/bash  -ex

rsync -aHv ./ phablet@nexus:/tmp/Calendar/
ssh -t phablet@nexus 'cd /tmp/Calendar && GRID_UNIT_PX=18 qmlscene --desktop_file_hint=$PWD/Calendar.desktop $PWD/calendar.qml'
