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
import QtQuick 2.4
import Ubuntu.Components 1.3

PageHeader {
    id: pageHeader

    HeaderSections {
        id: headerSections
        visible: !titleHeaderSections.visible
    }
    TitleHeaderSections {
        id: titleHeaderSections
    }

    states: [
        State {
            name: "MOBILE"
            when: !titleHeaderSections.visible
            PropertyChanges {
                target: pageHeader
                extension: headerSections
            }
        },
        State {
            name: "TABLET"
            when: titleHeaderSections.visible
            PropertyChanges {
                target: pageHeader
                contents: titleHeaderSections
            }
        }
    ]
}
