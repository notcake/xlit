local self = {}
local ctor = Xlit.MakeConstructor (self)
local instance = nil

function Xlit.Xlit ()
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
	self.Panel = vgui.Create ("XlitFrame")
end

function self:dtor ()
	if self.Panel and self.Panel:IsValid () then
		self.Panel:Remove ()
	end
end

function self:GetFrame ()
	return self.Panel
end

concommand.Add ("xlit_show",
	function ()
		Xlit.Xlit ():GetFrame ():SetVisible (true)
	end
)