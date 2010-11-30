-- Prefs.applescript
-- SimpleTeX4ht

(* © Copyright 2004-2010 Yves GESNEL.

This file is part of SimpleTeX4ht.

SimpleTeX4ht is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

SimpleTeX4ht is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with SimpleTeX4ht. If not, see <http://www.gnu.org/licenses/>. *)

(* ==== Properties ==== *)

property preferencesWindow : null

(* ==== Event Handlers ==== *)

-- This event handler is called when the "Preferences" menu item is chosen.
-- 
on choose menu item theObject
	-- Only load the preferences nib once
	if preferencesWindow is equal to null then
		load nib "Preferences"
		set preferencesWindow to window "preferences"
	else
		show window "preferences"
	end if
	
	-- Load in the preferences
	loadPreferences(preferencesWindow)
	
	-- Show the preferences window
	set visible of preferencesWindow to true
end choose menu item

-- This event handler is called when a checkbox is clicked.
-- 
on clicked theObject
	-- Save out the preferences
	storePreferences(preferencesWindow)
end clicked

-- This event handler is called when either the Preferences Window is closed.
-- 
on should close theObject
	-- Hide the preferences window
	set visible of preferencesWindow to false
end should close

(* ==== Handlers ==== *)

-- This handler will read the preferences from the "SimpleTeX4ht.plist" in  the ~/Library/Preferences directory and then sets those values in the UI elements.
--
on loadPreferences(theWindow)
	-- Read in the preferences
	try
		tell user defaults
			set theSwitches to contents of default entry "options"
		end tell
	end try
	
	-- Set the contents of the UI elements
	tell theWindow
		set contents of button "processFiles" to item 1 of theSwitches
		set contents of button "browser" to item 2 of theSwitches
	end tell
end loadPreferences

-- This handler will get the values from the UI elements and store those values in the  preferences file.
--
on storePreferences(theWindow)
	-- Get the contents of the UI elements
	tell theWindow
		set theSwitches to {contents of button "processFiles", contents of button "browser"}
	end tell
	
	-- Write out the preferences
	try
		tell user defaults
			set contents of default entry "options" to theSwitches
		end tell
	end try
end storePreferences