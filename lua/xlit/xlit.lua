if Xlit then return end
Xlit = Xlit or {}

include ("glib/glib.lua")
include ("gooey/gooey.lua")

GLib.Initialize ("Xlit", Xlit)
GLib.AddCSLuaPackFile ("autorun/xlit.lua")
GLib.AddCSLuaPackFolderRecursive ("xlit")
GLib.AddCSLuaPackSystem ("xlit")

Xlit.PlayerMonitor = Xlit.PlayerMonitor ("Xlit")

include ("export.lua")
include ("transliterationcontroller.lua")

if CLIENT then
	Xlit.IncludeDirectory ("xlit/ui")
end

Xlit.AddReloadCommand ("xlit/xlit.lua", "xlit", "Xlit")