concommand.Add ("xlit_export" .. (CLIENT and "_cl" or ""),
	function (ply, _, _)
		if SERVER and ply and ply:IsValid () and not ply:IsAdmin () then return end
		
		local transliterationTable = GLib.Unicode.GetTransliterationTable ()
		local code = GLib.StringBuilder ()
		code = code .. "-- This file is computer-generated.\r\n"
		code = code .. "local t = GLib.Unicode.GetTransliterationTable ()\r\n"
		code = code .. "\r\n"

		local sortedTransliterationTable = {}
		for character, entry in pairs (transliterationTable) do
			sortedTransliterationTable [#sortedTransliterationTable + 1] =
			{
				Character = character,
				CodePoint = GLib.UTF8.Byte (character),
				Entry     = entry
			}
		end
		table.sort (sortedTransliterationTable,
			function (a, b)
				return a.CodePoint < b.CodePoint
			end
		)

		for i = 1, #sortedTransliterationTable do
			local entry = sortedTransliterationTable [i].Entry
			if GLib.Unicode.CharacterHasDecomposition (sortedTransliterationTable [i].Character) then
				print ("Warning: Character " .. sortedTransliterationTable [i].Character .. " already has a decomposition!")
			end
			
			code = code .. "t [\"" .. GLib.String.Escape (sortedTransliterationTable [i].Character) .. "\"] = { "
			for i = 1, #entry do
				if string.find (entry [i], "`") then
					print ("Warning: Character " .. sortedTransliterationTable [i].Character .. "'s decomposition contains the console key (`)!")
				end
				
				if i > 1 then code = code .. ", " end
				code = code .. "\"" .. GLib.String.Escape (entry [i]) .. "\""
			end
			code = code .. " }\r\n"
		end
		
		file.Write ("xlit_export.txt", code:ToString ())
		print ("xlit_export: " .. GLib.FormatFileSize (#code:ToString ()) .. " written.")
	end
)