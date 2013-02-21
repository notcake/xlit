local self = {}

surface.CreateFont ("XlitArial24",
	{
		font = "Arial",
		size = 24
	}
)

function self:Init ()
	self:SetTitle ("Xlit")

	self:SetSize (ScrW () * 0.8, ScrH () * 0.75)
	self:Center ()
	self:SetDeleteOnClose (false)
	self:MakePopup ()
	
	self:AddEventListener ("VisibleChanged",
		function (_, visible)
			if not visible then return end
			self.TransliterationEntries [1]:RequestFocus ()
		end
	)
	
	self.CharacterMap = vgui.Create ("XlitCharacterMap", self)
	self.CharacterMap:AddEventListener ("BaseCodePointChanged",
		function (_, baseCodePoint)
			self.BaseCodePointLabel:SetText (string.format ("U+%06X", baseCodePoint))
			self.PreviousButton:SetEnabled (baseCodePoint > 0)
			self.PreviousButton2:SetEnabled (baseCodePoint > 0)
		end
	)
	self.CharacterMap:AddEventListener ("SelectedCodePointChanged",
		function (_, selectedCodePoint)
			self:OnSelectedCodePointChanged ()
		end
	)
	
	self.PreviousButton = vgui.Create ("GButton", self)
	self.PreviousButton:SetSize (64, 32)
	self.PreviousButton:SetText ("<")
	self.PreviousButton:SetEnabled (false)
	self.PreviousButton:AddEventListener ("Click",
		function ()
			local baseCodePoint = self.CharacterMap:GetBaseCodePoint () - self.CharacterMap:GetRowCount () * self.CharacterMap:GetColumnCount ()
			baseCodePoint = math.max (0, baseCodePoint)
			self.CharacterMap:SetBaseCodePoint (baseCodePoint)
		end
	)
	
	self.PreviousButton2 = vgui.Create ("GButton", self)
	self.PreviousButton2:SetSize (64, 32)
	self.PreviousButton2:SetText ("<<")
	self.PreviousButton2:SetEnabled (false)
	self.PreviousButton2:AddEventListener ("Click",
		function ()
			local baseCodePoint = self.CharacterMap:GetBaseCodePoint () - 0x1000
			baseCodePoint = math.max (0, baseCodePoint)
			self.CharacterMap:SetBaseCodePoint (baseCodePoint)
		end
	)
	
	self.BaseCodePointLabel = vgui.Create ("GLabel", self)
	self.BaseCodePointLabel:SetText ("U+000000")
	self.BaseCodePointLabel:SetTextColor (GLib.Colors.White)
	self.BaseCodePointLabel:SetContentAlignment (5)
	
	self.NextButton = vgui.Create ("GButton", self)
	self.NextButton:SetSize (64, 32)
	self.NextButton:SetText (">")
	self.NextButton:AddEventListener ("Click",
		function ()
			local baseCodePoint = self.CharacterMap:GetBaseCodePoint () + self.CharacterMap:GetRowCount () * self.CharacterMap:GetColumnCount ()
			self.CharacterMap:SetBaseCodePoint (baseCodePoint)
		end
	)
	
	self.NextButton2 = vgui.Create ("GButton", self)
	self.NextButton2:SetSize (64, 32)
	self.NextButton2:SetText (">>")
	self.NextButton2:AddEventListener ("Click",
		function ()
			local baseCodePoint = self.CharacterMap:GetBaseCodePoint () + 0x1000
			self.CharacterMap:SetBaseCodePoint (baseCodePoint)
		end
	)
	
	self.CharacterDisplay = vgui.Create ("XlitCharacterDisplay", self)
	
	self.CharacterHeader = vgui.Create ("GLabel", self)
	self.CharacterHeader:SetFont ("XlitArial24")
	self.CharacterHeader:SetTextColor (GLib.Colors.White)
	
	self.Decompositions = {}
	
	self.TransliterationEntryLabels = {}
	self.TransliterationEntries     = {}
	for i = 1, 5 do
		local label = vgui.Create ("GLabel", self)
		self.TransliterationEntryLabels [#self.TransliterationEntryLabels + 1] = label
		label:SetText ("Replacement " .. i .. ":")
		label:SetTextColor (GLib.Colors.White)
		label:SetContentAlignment (4)
		label:SizeToContents ()
		
		local textEntry = vgui.Create ("GTextEntry", self)
		self.TransliterationEntries [#self.TransliterationEntries + 1] = textEntry
		textEntry.Id = i
		textEntry:AddEventListener ("TextChanged",
			function (_)
				if self.Updating then return end
				
				local codePoint = self.CharacterMap:GetSelectedCodePoint ()
				local transliterations = {}
				for i = 1, #self.TransliterationEntries do
					local text = self.TransliterationEntries [i]:GetText ()
					if text ~= "" then
						transliterations [#transliterations + 1] = text
					end
				end
				if #transliterations == 0 then
					transliterations = nil
				end
				
				Xlit.TransliterationController:SetTransliterations (GLib.UTF8.Char (codePoint), transliterations)
			end
		)
		textEntry.OnKeyCodeTyped = function (_, keyCode)
			if keyCode == KEY_TAB or
			   keyCode == KEY_ENTER then
				if textEntry:GetText () ~= "" and
				   self.TransliterationEntries [textEntry.Id + 1] then
					GLib.CallDelayed (
						function ()
							self.TransliterationEntries [textEntry.Id + 1]:RequestFocus ()
							self.TransliterationEntries [textEntry.Id + 1]:SetCaretPos (GLib.UTF8.Length (self.TransliterationEntries [textEntry.Id + 1]:GetText ()))
							self.TransliterationEntries [textEntry.Id + 1]:SelectAll ()
						end
					)
				else
					local codePoint = self.CharacterMap:GetSelectedCodePoint () + 1
					while GLib.Unicode.CodePointHasDecomposition (codePoint) or
						  GLib.Unicode.CodePointHasTransliteration (codePoint) or
						  not GLib.Unicode.IsControlCodePoint (codePoint) and codePoint < 127 do
						codePoint = codePoint + 1
					end
					self.CharacterMap:SetSelectedCodePoint (codePoint)
				end
			end
		end
	end
	
	self:OnSelectedCodePointChanged ()
	self:PerformLayout ()
end

function self:PerformLayout ()
	DFrame.PerformLayout (self)
	
	if self.CharacterMap then
		local x, y = 8, 32
		
		self.CharacterMap:SetPos (x, y)
		self.CharacterMap:SetSize (self:GetWide () - 16, self:GetTall () * 0.45 - y - 8)
		y = self:GetTall () * 0.45
		
		self.PreviousButton2:SetPos (x, y)
		self.PreviousButton:SetPos (x + self.PreviousButton:GetWide () + 8, y)
		self.BaseCodePointLabel:SetPos (x, y)
		self.BaseCodePointLabel:SetSize (self:GetWide () - 16, self.PreviousButton:GetTall ())
		self.NextButton2:SetPos (self:GetWide () - 8 - self.NextButton2:GetWide (), y)
		self.NextButton:SetPos (self:GetWide () - 8 - self.NextButton2:GetWide () - 8 - self.NextButton:GetWide (), y)
		y = y + self.PreviousButton:GetTall () + 8
		
		self.CharacterDisplay:SetPos (x, y)
		self.CharacterDisplay:SetSize (0.25 * self:GetWide (), self:GetTall () - y - 8)
		
		x = x + 0.25 * self:GetWide () + 8
		
		self.CharacterHeader:SetPos (x, y)
		self.CharacterHeader:SetSize (self:GetWide () - 8, 48)
		y = y + self.CharacterHeader:GetTall () + 8
		
		for i = 1, #self.Decompositions do
			self.Decompositions [i]:SetPos (x + (self.Decompositions [i]:GetWide () + 8) * (i - 1), y)
		end
		y = y + 72
		
		for i = 1, #self.TransliterationEntries do
			self.TransliterationEntryLabels [i]:SetPos (x, y)
			self.TransliterationEntryLabels [i]:SetTall (self.TransliterationEntries [i]:GetTall ())
			
			self.TransliterationEntries [i]:SetPos (x + self.TransliterationEntryLabels [i]:GetWide () + 8, y)
			self.TransliterationEntries [i]:SetWide (self:GetWide () - 8 - x - self.TransliterationEntryLabels [i]:GetWide () - 8)
			y = y + self.TransliterationEntries [i]:GetTall () + 8
		end
	end
end

-- Internal, do not call
function self:OnSelectedCodePointChanged ()
	local selectedCodePoint = self.CharacterMap:GetSelectedCodePoint ()
	
	local transliterationTable = GLib.Unicode.GetTransliterationTable ()
	local character = GLib.UTF8.Char (selectedCodePoint)
	local transliterations = transliterationTable [character] or {}
	
	self.Updating = true
	for i = 1, #self.TransliterationEntries do
		self.TransliterationEntries [i]:SetText (transliterations [i] or "")
	end
	self.Updating = false
	
	self.TransliterationEntries [1]:RequestFocus ()
	self.TransliterationEntries [1]:SetCaretPos (GLib.UTF8.Length (self.TransliterationEntries [1]:GetText ()))
	self.TransliterationEntries [1]:SelectAll ()

	if not self.CharacterMap:IsCodePointVisible (selectedCodePoint) then
		self.CharacterMap:SetBaseCodePoint (selectedCodePoint - selectedCodePoint % 256)
	end

	self.CharacterDisplay:SetCodePoint (selectedCodePoint)
	self.CharacterHeader:SetText (GLib.Unicode.GetCodePointName (selectedCodePoint) .. "\n" .. GLib.UnicodeCategory [GLib.Unicode.GetCodePointCategory (selectedCodePoint)])
	
	for i = 1, #self.Decompositions do
		self.Decompositions [i]:Remove ()
	end
	self.Decompositions = {}
	
	local decomposition = GLib.Unicode.DecomposeCodePoint (selectedCodePoint)
	for c in GLib.UTF8.Iterator (decomposition) do
		local characterDisplay = vgui.Create ("XlitCharacterDisplay", self)
		self.Decompositions [#self.Decompositions + 1] = characterDisplay
		
		characterDisplay:SetSize (64, 64)
		characterDisplay:SetCharacter (c)
		characterDisplay:AddEventListener ("DoubleClick",
			function ()
				self.CharacterMap:SetSelectedCodePoint (characterDisplay:GetCodePoint ())
			end
		)
	end
	
	self:InvalidateLayout ()
end

Gooey.Register ("XlitFrame", self, "GFrame")