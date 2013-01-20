local self = {}

for _, fontSize in ipairs ({ 16, 32, 144 }) do
	surface.CreateFont ("XlitArial" .. fontSize,
		{
			font = "Arial",
			size = fontSize
		}
	)
end

function self:Init ()
	self:SetCodePoint (0)
end

function self:GetCharacter ()
	return self.Character
end

function self:GetCodePoint ()
	return self.CodePoint
end

function self:Paint (w, h)
	surface.SetDrawColor (GLib.Colors.White)
	surface.DrawRect (0, 0, w, h)
	surface.SetDrawColor (GLib.Colors.Black)
	surface.DrawOutlinedRect (0, 0, w, h)
	
	draw.SimpleText (self.Character, h > 216 and "XlitArial144" or "XlitArial32", w * 0.5, h * 0.5, GLib.Colors.Black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	local info = string.format ("U+%06X", self.CodePoint)
	draw.SimpleText (info, h > 216 and "XlitArial32" or "XlitArial16", w * 0.5, h - (h > 216 and 16 or 0), GLib.Colors.Black, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

function self:SetCharacter (...)
	self.Character = GLib.UTF8.NextChar (...)
	self.CodePoint = GLib.UTF8.Byte (self.Character)
	
	self:SetToolTipText (GLib.Unicode.GetCodePointName (self.CodePoint))
end

function self:SetCodePoint (codePoint)
	self.CodePoint = codePoint or 0
	self.Character = GLib.UTF8.Char (self.CodePoint)
	
	self:SetToolTipText (GLib.Unicode.GetCodePointName (self.CodePoint))
end

Gooey.Register ("XlitCharacterDisplay", self, "GPanel")