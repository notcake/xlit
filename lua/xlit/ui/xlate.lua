local self = {}
local ctor = Xlit.MakeConstructor (self)
local instance = nil

function Xlit.Xlate ()
	if not instance then
		instance = ctor ()
		
		Xlit:AddEventListener ("Unloaded",
			function ()
				instance:dtor ()
				instance = nil
			end
		)
	end
	return instance
end

function self:ctor ()
	self.Panel = vgui.Create ("XlitXlateFrame")
end

function self:dtor ()
	if self.Panel and self.Panel:IsValid () then
		self.Panel:Remove ()
	end
end

function self:GetFrame ()
	return self.Panel
end

concommand.Add ("xlit_show_xlate",
	function ()
		Xlit.Xlate ():GetFrame ():SetVisible (true)
	end
)