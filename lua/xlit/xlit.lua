if Xlit then return end
Xlit = Xlit or {}

include ("glib/glib.lua")
include ("gooey/gooey.lua")

GLib.Initialize ("Xlit", Xlit)
GLib.AddCSLuaPackSystem ("Xlit")
GLib.AddCSLuaPackFile ("autorun/xlit.lua")
GLib.AddCSLuaPackFolderRecursive ("xlit")

include ("export.lua")
include ("transliterationcontroller.lua")

if CLIENT then
	Xlit.IncludeDirectory ("xlit/ui")
end

Xlit.AddReloadCommand ("xlit/xlit.lua", "xlit", "Xlit")