#! /bin/bash  -ex

rsync -aHv ./ phablet@nexus:/tmp/Calendar/
ssh -t phablet@nexus 'cd /tmp/Calendar && echo "qmlscene --desktop_file_hint=$PWD/Calendar.desktop $PWD/calendar.qml" > runme.sh && chmod +x runme.sh && bash -i runme.sh'
