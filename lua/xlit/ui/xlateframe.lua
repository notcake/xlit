local self = {}

function self:Init ()
	self:SetTitle ("Xlate")

	self:SetSize (ScrW () * 0.6, ScrH () * 0.6)
	self:Center ()
	self:SetDeleteOnClose (false)
	self:MakePopup ()
	
	self:AddEventListener ("VisibleChanged",
		function (_, visible)
			if not visible then return end
			self.TextEntry:Focus ()
		end
	)
	
	self.TextEntry = vgui.Create ("GTextEntry", self)
	
	self.Replacements = {}
	
	self.SelectionStart = 0
	self.SelectionEnd   = 0
	
	self:PerformLayout ()
end

function self:AddCharacterDisplay (character)
	local characterDisplay = vgui.Create ("XlitCharacterDisplay", self)
	self.Replacements [#self.Replacements + 1] = characterDisplay
	
	characterDisplay:SetCharacter (character)
	characterDisplay:SetSize (64, 64)
	characterDisplay:AddEventListener ("Click",
		function ()
			local text = self.TextEntry:GetText ()
			local left, mid, right = GLib.UTF8.SplitAt (text, self.SelectionEnd)
			mid, right = GLib.UTF8.SplitAt (mid, 2)
			
			self.TextEntry:SetText (left .. character .. right)
			self.TextEntry:SetCaretPos (self.SelectionStart, self.SelectionEnd)
			self.TextEntry:Focus ()
			
			self:RegenerateSubstitutes ()
		end
	)
end

function self:PerformLayout ()
	DFrame.PerformLayout (self)
	
	if self.TextEntry then
		local x, y = 8, 32
		
		self.TextEntry:SetPos (x, y)
		self.TextEntry:SetWide (self:GetWide () - 8 - x)
		y = y + self.TextEntry:GetTall () + 8
		
		table.sort (self.Replacements,
			function (a, b)
				return a:GetCodePoint () < b:GetCodePoint ()
			end
		)
		
		for i = 1, #self.Replacements do
			if x > 8 and x + self.Replacements [i]:GetWide () > self:GetWide () - 8 then
				x = 8
				y = y + self.Replacements [i]:GetTall () + 8
			end
			self.Replacements [i]:SetPos (x, y)
			x = x + self.Replacements [i]:GetWide () + 8
		end
	end
end

function self:SetSelection (selectionStart, selectionEnd)
	if self.SelectionStart == selectionStart and self.SelectionEnd == selectionEnd then return end
	
	self.SelectionStart = selectionStart
	self.SelectionEnd   = selectionEnd
	
	self:RegenerateSubstitutes ()
end

function self:Think ()
	DFrame.Think (self)
	
	self:SetSelection (self.TextEntry:GetCaretPos (), self.TextEntry:GetCaretPos ())
end

-- Internal, do not call
function self:RegenerateSubstitutes ()
	local text = GLib.UTF8.Sub (self.TextEntry:GetText (), self.SelectionEnd, self.SelectionEnd)
	local transliterationTable = GLib.Unicode.GetTransliterationTable ()
	local invMap = {}
	for character, entry in pairs (transliterationTable) do
		for _, v in ipairs (entry) do
			invMap [v] = invMap [v] or {}
			invMap [v] [#invMap [v] + 1] = character
		end
	end
	
	for character, _ in pairs (GLib.Unicode.GetDecompositionMap ()) do
		local decomposition = GLib.Unicode.DecomposeCharacter (character)
		decomposition = GLib.UTF8.NextChar (decomposition)
		invMap [decomposition] = invMap [decomposition] or {}
		invMap [decomposition] [#invMap [decomposition] + 1] = character
	end
	
	for i = 1, #self.Replacements do
		self.Replacements [i]:Remove ()
	end
	self.Replacements = {}
	
	if text == "" then return end
	
	self:AddCharacterDisplay (text)
	if invMap [text] then
		for i = 1, #invMap [text] do
			self:AddCharacterDisplay (invMap [text] [i])
		end
	end
	if GLib.UTF8.Decompose (text) ~= text then
		self:AddCharacterDisplay (GLib.UTF8.Decompose (text))
	end
	if GLib.UTF8.ToLower (text) ~= text then
		self:AddCharacterDisplay (GLib.UTF8.ToLower (text))
	end
	if GLib.UTF8.ToUpper (text) ~= text then
		self:AddCharacterDisplay (GLib.UTF8.ToUpper (text))
	end
	
	if transliterationTable [text] then
		for i = 1, #transliterationTable [text] do
			self:AddCharacterDisplay (transliterationTable [text] [i])
		end
	end
	
	self:InvalidateLayout ()
end

Gooey.Register ("XlitXlateFrame", self, "GFrame")