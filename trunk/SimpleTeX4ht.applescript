-- SimpleTeX4ht.applescript
-- SimpleTeX4ht

(* © Copyright 2004-2009 Yves GESNEL.

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

global macFile
property progressWindow : null

(* ==== Event Handlers ==== *)

-- Preferences : attempt to make new default entries
on will finish launching theObject
	try
		tell user defaults
			make new default entry at end of default entries with properties {name:"options", content:{false, false}}
		end tell
	end try
end will finish launching

on launched theObject
end launched

-- progress indicator is not visible
on opened theObject
end opened

-- Drag and drop
on awake from nib theObject
	tell theObject to register drag types {"file names"}
end awake from nib

on drop theObject drag info dragInfo
	set dropped to false
	if "file names" is in types of pasteboard of dragInfo then
		set preferred type of pasteboard of dragInfo to "file names"
		set theFiles to contents of pasteboard of dragInfo
		set theFile to (item 1 in theFiles)
		set the_File to theFile as POSIX file
		set FileKind to kind of (info for the_File)
		set forbidden to {"Dossier", "Folder", "Carpeta", "Ordner", "Application", "Programm", "aplicación", "Volume", "Volumen"}
		if FileKind is not in forbidden then
			set macFile to (POSIX file theFile) as Unicode text
			tell theObject to set content to return & "  " & theFile as string
			set dropped to true
		end if
	end if
	return dropped
end drop

on conclude drop theObject drag info dragInfo
end conclude drop

-- Convert button’s action
on clicked theObject
	set selectFile to (localized string "select" from table "Localized")
	set selectFile to getPlainText(selectFile)
	try
		tell user defaults
			set theSwitches to contents of default entry "options"
		end tell
		set tex4htFiles to item 1 of theSwitches
		set openFile to item 2 of theSwitches
	end try
	if name of theObject is "Convert" then
		if (content of text field "path" of window "Main") as string is "  …" then
			set macFile to choose file with prompt selectFile without invisibles
			set theFile to POSIX path of (macFile as string)
			set content of text field "path" of window "Main" to return & "  " & theFile
		end if
		beginProcess()
		if presenceTeX4ht() is false then
			stopProcess()
			set textError to (localized string "error" from table "Localized")
			set textError to getPlainText(textError)
			display dialog textError buttons {"OK"} default button 1 with icon 0
		else
			tell application "Finder"
				set macDir to container of item macFile
				set real_macName to name of item macFile
			end tell
			set unixDir to quoted form of the POSIX path of (macDir as string)
			set theList to cleantext(real_macName)
			set cleaned to item 1 of theList
			set macName to item 2 of theList
			if cleaned then
				set macName to copyAndRename(macFile, macName, macDir)
			end if
			set shortName to removeExtension(macName)
			set extension to "html" as string
			if theObject is button "Convert" of tab view item "Expert" of tab view "tab" of window "Main" then
				set option1 to contents of text field "option1" of tab view item "Expert" of tab view "tab" of window "Main"
				set option2 to contents of text field "option2" of tab view item "Expert" of tab view "tab" of window "Main"
				set option3 to contents of text field "option3" of tab view item "Expert" of tab view "tab" of window "Main"
				set option4 to contents of text field "option4" of tab view item "Expert" of tab view "tab" of window "Main"
				set option to "\"" & option1 & "\"" & " " & "\"" & option2 & "\"" & " " & "\"" & option3 & "\"" & " " & "\"" & option4 & "\""
			else if theObject is button "Convert" of tab view item "HTML" of tab view "tab" of window "Main" then
				if (state of button "multipages" of tab view item "HTML" of tab view "tab" of window "Main") is 1 and (state of button "XHTML" of tab view item "HTML" of tab view "tab" of window "Main") is 0 then
					set option to "\"html,2,sections+\" \"\" \"\" \"-interaction=batchmode\""
				else if (state of button "multipages" of tab view item "HTML" of tab view "tab" of window "Main") is 0 and (state of button "XHTML" of tab view item "HTML" of tab view "tab" of window "Main") is 0 then
					set option to "\"\" \"\" \"\" \"-interaction=batchmode\""
				else if (state of button "multipages" of tab view item "HTML" of tab view "tab" of window "Main") is 1 and (state of button "XHTML" of tab view item "HTML" of tab view "tab" of window "Main") is 1 then
					set option to "\"xhtml,2,sections+\" \"\" \"\" \"-interaction=batchmode\""
				else if (state of button "multipages" of tab view item "HTML" of tab view "tab" of window "Main") is 0 and (state of button "XHTML" of tab view item "HTML" of tab view "tab" of window "Main") is 1 then
					set option to "\"xhtml\" \"\" \"\" \"-interaction=batchmode\""
				end if
			else if theObject is button "Convert" of tab view item "otherModes" of tab view "tab" of window "Main" then
				if (current row of matrix "Matrix" of tab view item "otherModes" of tab view "tab" of window "Main") is 1 then
					set option to ""
					set extension to "odt" as string
				else if (current row of matrix "Matrix" of tab view item "otherModes" of tab view "tab" of window "Main") is 2 then
					set option to "\"xhtml,mozilla\" \" -cmozhtf\" \"-cvalidate\" \"-interaction=batchmode\""
					set extension to "xml" as string
				else if (current row of matrix "Matrix" of tab view item "otherModes" of tab view "tab" of window "Main") is 3 then
					set option to "\"xhtml,docbook\" \" -cunihtf\" \"\" \"-interaction=batchmode\""
					set extension to "xml" as string
				else if (current row of matrix "Matrix" of tab view item "otherModes" of tab view "tab" of window "Main") is 4 then
					set option to "\"xhtml,docbook-mml\" \" -cunihtf\" \"\" \"-interaction=batchmode\""
					set extension to "xml" as string
				else if (current row of matrix "Matrix" of tab view item "otherModes" of tab view "tab" of window "Main") is 5 then
					set option to "\"xhtml,tei\" \" -cunihtf\" \"\" \"-interaction=batchmode\""
					set extension to "xml" as string
				else if (current row of matrix "Matrix" of tab view item "otherModes" of tab view "tab" of window "Main") is 6 then
					set option to "\"xhtml,tei-mml\" \" -cunihtf\" \"\" \"-interaction=batchmode\""
					set extension to "xml" as string
				end if
			end if
			htlatex(option, macName, unixDir, tex4htFiles, openFile, shortName, extension, cleaned)
			if cleaned then
				try
					do shell script "cd  " & unixDir & ";rm " & macName & " ;"
				end try
			end if
			endProcess()
		end if
	end if
end clicked

-- Should quit after last window closed
on should quit after last window closed theObject
	return true
end should quit after last window closed

(* ==== Handlers ==== *)

-- Show progress indicator
on beginProcess()
	set visible of window "Main" to false
	-- Only load the progress nib once
	if progressWindow is equal to null then
		load nib "Progress"
		show window "Progress"
		set progressWindow to window "Progress"
	else
		show window "Progress"
	end if
	set visible of progress indicator "progress" of window "Progress" to true
	repeat with i from 0 to 16
		set content of progress indicator "progress" of window "Progress" to i
	end repeat
end beginProcess

-- htlatex command
on htlatex(option, macName, unixDir, tex4htFiles, openFile, shortName, extension, cleaned)
	try
		set tempFolder to POSIX path of (path to temporary items)
		if extension is "odt" then
			do shell script "export PATH=$PATH:/opt/local/bin:/opt/local/sbin:/sw/bin/:/usr/local/teTeX/bin/powerpc-apple-darwin-current/:/usr/local/bin:/usr/texbin/;cd  " & unixDir & "; mk4ht oolatex " & macName & " ;grep 'No pages of output.' " & shortName & ".log > " & tempFolder & "st4hTemp2;echo 0 >> " & tempFolder & "st4hTemp2"
		else
			do shell script "export PATH=$PATH:/opt/local/bin:/opt/local/sbin:/sw/bin/:/usr/local/teTeX/bin/powerpc-apple-darwin-current/:/usr/local/bin:/usr/texbin/;cd  " & unixDir & "; htlatex " & macName & " " & option & ";grep 'No pages of output.' " & shortName & ".log > " & tempFolder & "st4hTemp2;echo 0 >> " & tempFolder & "st4hTemp2"
			
		end if
	on error
		stopProcess()
	end try
	set thePath to ((path to temporary items as Unicode text) & "st4hTemp2")
	set test to read file thePath
	do shell script "rm " & tempFolder & "st4hTemp2"
	set test to (first character of test) as string
	delay 1
	if test is "N" then
		stopProcess()
		if cleaned then
			try
				do shell script "cd  " & unixDir & ";rm " & macName & " ;"
			end try
		end if
		set conversionError to (localized string "conversionError" from table "Localized")
		set conversionError to getPlainText(conversionError)
		display dialog conversionError buttons {"OK"} default button 1 with icon 0
	else
		try
			if tex4htFiles is true and openFile is true then
				do shell script "cd  " & unixDir & ";rm " & shortName & ".4ct;rm " & shortName & ".4tc;rm " & shortName & ".aux;rm " & shortName & ".dvi;rm " & shortName & ".idv;rm " & shortName & ".lg;rm " & shortName & ".log;rm " & shortName & ".tmp;rm " & shortName & ".xref; open " & shortName & "." & extension & ""
			else if tex4htFiles is false and openFile is true then
				do shell script "cd  " & unixDir & ";open " & shortName & "." & extension & ""
			else if tex4htFiles is true and openFile is false then
				do shell script "cd  " & unixDir & ";rm " & shortName & ".4ct;rm " & shortName & ".4tc;rm " & shortName & ".aux;rm " & shortName & ".dvi;rm " & shortName & ".idv;rm " & shortName & ".lg;rm " & shortName & ".log;rm " & shortName & ".tmp;rm " & shortName & ".xref"
			end if
		end try
	end if
end htlatex

-- getPlainText converts Unicode to plain text
on getPlainText(fromUnicodeString)
	set styledText to fromUnicodeString as string
	set styledRecord to styledText as record
	return «class ktxt» of styledRecord
end getPlainText

-- Check for TeX4ht
on presenceTeX4ht()
	set tempFolder to POSIX path of (path to temporary items)
	do shell script "export PATH=$PATH:/opt/local/bin:/opt/local/sbin:/sw/bin/:/usr/local/teTeX/bin/powerpc-apple-darwin-current/:/usr/local/bin:/usr/texbin/; cd " & tempFolder & "; which htlatex >  st4hTemp1; echo 0 >> st4hTemp1" -- echo 0 avoid a blank temporary file
	set thePath to ((path to temporary items as Unicode text) & "st4hTemp1")
	set test to read file thePath
	do shell script "rm " & tempFolder & "st4hTemp1"
	set test to (first character of test) as string
	repeat with i from 16 to 33
		delay 0.1
		set content of progress indicator "progress" of window "Progress" to i
	end repeat
	if test is not "/" then return false
	if test is "/" then return true
end presenceTeX4ht

-- Remove file extension
on removeExtension(shortName)
	set shortName to ¬
		(the reverse of every character of shortName) as string
	set x to the offset of "." in shortName
	set shortName to (characters (x + 1) thru -1 of shortName) as string
	set shortName to (the reverse of every character of shortName) as string
	return shortName
end removeExtension

-- Clean special characters from a string like $:'/?;&"#%><(){}\~`^\|*
on cleantext(this_text)
	set cleaned to false
	set the standard_characters to "abcdefghijklmnopqrstuvwxyz0123456789"
	set the extra_chars to "-._+!@=[]"
	set the a_chars to "àáâäã"
	set the e_chars to "éèêë"
	set the i_chars to "îïìí"
	set the o_chars to "õôöóò"
	set the u_chars to "ûüùú"
	set the y_chars to "ÿý"
	set the n_chars to "ñ"
	set the c_chars to "ç"
	set the acceptable_characters to the standard_characters & the extra_chars
	set the cleaned_text to ""
	repeat with this_char in this_text
		if this_char is in the acceptable_characters then
			set the cleaned_text to (the cleaned_text & this_char)
		else
			if this_char is in the a_chars then
				set the cleaned_text to (the cleaned_text & "a")
			else if this_char is in the e_chars then
				set the cleaned_text to (the cleaned_text & "e")
			else if this_char is in the i_chars then
				set the cleaned_text to (the cleaned_text & "i")
			else if this_char is in the o_chars then
				set the cleaned_text to (the cleaned_text & "o")
			else if this_char is in the u_chars then
				set the cleaned_text to (the cleaned_text & "u")
			else if this_char is in the y_chars then
				set the cleaned_text to (the cleaned_text & "y")
			else if this_char is in the n_chars then
				set the cleaned_text to (the cleaned_text & "n")
			else if this_char is in the c_chars then
				set the cleaned_text to (the cleaned_text & "c")
			else
				set the cleaned_text to (the cleaned_text & "_") as string
			end if
			set cleaned to true
		end if
	end repeat
	-- if the first character is "-" then change this value to"_"
	if the first character of the cleaned_text is "-" then
		set the cleaned_text to "_" & (get text 2 thru -1 of the cleaned_text)
		set cleaned to true
	end if
	return {cleaned, the cleaned_text}
end cleantext

-- Copy and rename. Check if a filename already exists. A sequential index is added before the extension if necessary.
on copyAndRename(macFile, macName, macDir)
	tell application "Finder"
		set macFileCopy to duplicate macFile
		set PathToCheck to ((macDir as string) & macName)
		if item PathToCheck exists then
			set sequential to 0
			set default_delimiters to AppleScript's text item delimiters
			set AppleScript's text item delimiters to {"."}
			set root_name to the first text item of macName
			set suffix_name to the last text item of macName
			repeat
				set the macName to the (the root_name & the sequential & "." & the suffix_name) as string
				set newPathToCheck to ((macDir as string) & macName)
				if (item newPathToCheck exists) = false then exit repeat
				set sequential to sequential + 1
			end repeat
			set AppleScript's text item delimiters to default_delimiters
		end if
		set the (name of macFileCopy) to macName
	end tell
	return macName
end copyAndRename

-- Stop progress indicator immediately
on stopProcess()
	tell progress indicator "progress" of window "Progress" to stop
	set visible of progress indicator "progress" of window "Progress" to false
	set visible of window "Progress" to false
	set content of text field "path" of window "Main" to "  …"
	set visible of window "Main" to true
end stopProcess

-- Stop progress indicator
on endProcess()
	repeat with i from 33 to 100
		delay 1.0E-5
		set content of progress indicator "progress" of window "Progress" to i
	end repeat
	tell progress indicator "progress" of window "Progress" to stop
	set visible of progress indicator "progress" of window "Progress" to false
	set visible of window "Progress" to false
	set content of text field "path" of window "Main" to "  …"
	set visible of window "Main" to true
end endProcess