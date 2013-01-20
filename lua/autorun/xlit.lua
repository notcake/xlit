if SERVER or
   file.Exists ("xlit/xlit.lua", "LUA") or
   file.Exists ("xlit/xlit.lua", "LCL") and GetConVar ("sv_allowcslua"):GetBool () then
	include ("xlit/xlit.lua")
end