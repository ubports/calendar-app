/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2018  <copyright holder> <email>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0

/**
 * This Component is used to specify colors that depends on a theme but cannot be suppliy by it.
 */

QtObject {
    property var themes : {
		'Ubuntu.Components.Themes.Ambiance' : {
			'lesuire_time' : "#ffffff",
			'buisness_time' : "#efefef"
		},
		'Ubuntu.Components.Themes.SuruDark' : {
			'lesuire_time' : Theme.palette.normal.background,
			'buisness_time' : Theme.palette.normal.foreground
		}
	}

	function getColorFor(colorName, fallBackColor) {
		return themes[Theme.name] && themes[Theme.name][colorName] ?
						themes[Theme.name][colorName] :
						fallBackColor; // If the current theme is missing from the color scheme return the fallback color
	}
}
