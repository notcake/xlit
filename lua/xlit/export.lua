concommand.Add ("xlit_export",
	function (ply, _, _)
		if SERVER and ply and ply:IsValid () and not ply:IsAdmin () then return end
		
		local transliterationTable = GLib.Unicode.GetTransliterationTable ()
		local code = GLib.StringBuilder ()
		code = code .. "-- This file is computer-generated.\n"
		code = code .. "local t = GLib.Unicode.GetTransliterationTable ()\n"
		code = code .. "\n"

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
			code = code .. "t [\"" .. GLib.String.Escape (sortedTransliterationTable [i].Character) .. "\"] = { "
			for i = 1, #entry do
				if i > 1 then code = code .. ", " end
				code = code .. "\"" .. GLib.String.Escape (entry [i]) .. "\""
			end
			code = code .. " }\n"
		end
		
		file.Write ("xlit_export.txt", code:ToString ())
		print ("xlit_export: " .. GLib.FormatFileSize (#code:ToString ()) .. " written.")
	end
)