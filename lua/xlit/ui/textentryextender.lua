local self = {}
Xlit.TextEntryExtender = Xlit.MakeConstructor (self)

function self:ctor ()
	self.FocusedPanel = nil
	self.TextEntry = nil
	self.Button = nil
	
	self.Leetspeak = Xlit.CharacterReplacementMap ()
	self.Leetspeak:SetCharacterReplacement ("a", "4")
	self.Leetspeak:SetCharacterReplacement ("e", "3")
	self.Leetspeak:SetCharacterReplacement ("o", "0")
	self.Leetspeak:SetCharacterReplacement ("s", "5")
	self.Leetspeak:SetCharacterReplacement ("t", "+")
	self.Leetspeak:SetCharacterReplacement ("v", "\\/")
	
	self.NoVowels = Xlit.CharacterReplacementMap ()
	self.NoVowels:SetCharacterReplacement ("A", "")
	self.NoVowels:SetCharacterReplacement ("E", "")
	self.NoVowels:SetCharacterReplacement ("I", "")
	self.NoVowels:SetCharacterReplacement ("O", "")
	self.NoVowels:SetCharacterReplacement ("U", "")
	self.NoVowels:SetCharacterReplacement ("a", "")
	self.NoVowels:SetCharacterReplacement ("e", "")
	self.NoVowels:SetCharacterReplacement ("i", "")
	self.NoVowels:SetCharacterReplacement ("o", "")
	self.NoVowels:SetCharacterReplacement ("u", "")
	
	self.Thorium = Xlit.CharacterReplacementMap ()
	self.Thorium:SetCharacterReplacement ("a", "λ")
	self.Thorium:SetCharacterReplacement ("e", "ë")
	self.Thorium:SetCharacterReplacement ("k", "ҡ")
	self.Thorium:SetCharacterReplacement ("o", "ö")
	self.Thorium:SetCharacterReplacement ("r", "ґ")
	
	self.Metal = Xlit.CharacterReplacementMap ()
	self.Metal:SetCharacterReplacement ("A", "Ä")
	self.Metal:SetCharacterReplacement ("C", "K")
	self.Metal:SetCharacterReplacement ("E", "Ë")
	self.Metal:SetCharacterReplacement ("F", "V")
	self.Metal:SetCharacterReplacement ("O", "Ö")
	self.Metal:SetCharacterReplacement ("U", "V")
	self.Metal:SetCharacterReplacement ("W", "VV")
	self.Metal:SetCharacterReplacement ("a", "ä")
	self.Metal:SetCharacterReplacement ("c", "k")
	self.Metal:SetCharacterReplacement ("e", "ë")
	self.Metal:SetCharacterReplacement ("f", "v")
	self.Metal:SetCharacterReplacement ("o", "ö")
	self.Metal:SetCharacterReplacement ("u", "v")
	self.Metal:SetCharacterReplacement ("w", "vv")
	
	self.CharacterReplacementMap = Xlit.CharacterReplacementMap ()
	
	hook.Add ("Think", "Xlit.KeyboardFocusWatcher",
		function ()
			if self.FocusedPanel == vgui.GetKeyboardFocus () then return end
			if vgui.GetKeyboardFocus () == self.Button then
				if self.FocusedPanel and self.FocusedPanel:IsValid () then
					if self.FocusedPanel.Focus then
						self.FocusedPanel:Focus ()
					else
						self.FocusedPanel:RequestFocus ()
					end
				end
			else
				self.FocusedPanel = vgui.GetKeyboardFocus ()
			end
			
			local panelType = nil
			if self.FocusedPanel and
			   self.FocusedPanel:IsValid () then
				panelType = self.FocusedPanel.ClassName
			end
			if panelType == "DTextEntry" or
			   panelType == "GTextEntry" then
				self:SetTextEntry (self.FocusedPanel)
			else
				self:SetTextEntry (nil)
			end
		end
	)

	Xlit:AddEventListener ("Unloaded",
		function ()
			self:dtor ()
		end
	)
end

function self:dtor ()
	self:SetTextEntry (nil)
	
	hook.Remove ("Think", "Xlit.KeyboardFocusWatcher")
	if self.Button and self.Button:IsValid () then
		self.Button:Remove ()
	end
end

function self:CreateButton ()
	if self.Button and self.Button:IsValid () then return self.Button end
	self.Button = vgui.Create ("GButton")
	self.Button:SetText ("")
	self.Button:SetWide (16)
	self.Button:SetVisible (false)
	self.Button:MakePopup ()
	self.Button:SetKeyboardInputEnabled (false)
	self.Button._Paint = self.Button.Paint
	self.Button.Paint = function (button, w, h)
		self:RepositionButton ()
		
		button:_Paint (w, h)
		Gooey.Glyphs.Draw ("down", Gooey.RenderContext, GLib.Colors.Black, button:IsPressed () and 1 or 0, button:IsPressed () and 1 or 0, button:GetSize ())
	end
	self.Button:AddEventListener ("MouseDown",
		function ()
			if self.TextEntry.Focus then
				self.TextEntry:Focus ()
			else
				self.TextEntry:RequestFocus ()
			end
		end
	)
	
	return self.Button
end

function self:DestroyButton ()
	if not self.Button or not self.Button:IsValid () then return end
	self.Button:Remove ()
end

function self:RepositionButton ()
	if not self.TextEntry then return end
	if not self.TextEntry:IsValid () then return end
	
	local x, y = self.TextEntry:LocalToScreen (0, 0)
	self.Button:SetPos (x + self.TextEntry:GetWide (), y)
	self.Button:MoveToFront ()
end

function self:SetTextEntry (textEntry)
	if self.TextEntry == textEntry then return end
	
	self:CreateButton ()
	self.Button:SetVisible (false)
	
	if self.TextEntry and self.TextEntry:IsValid () then
		self.TextEntry.OnEnter = self.TextEntry.__OnEnter
	end
	
	self.TextEntry = textEntry
	
	if self.TextEntry then
		self.Button:SetParent (self.TextEntry)
		self.Button:SetVisible (true)
		self.Button:SetTall (self.TextEntry:GetTall ())
		
		self:RepositionButton ()
		
		self.TextEntry.__OnEnter = self.TextEntry.OnEnter
		self.TextEntry.OnEnter = function (textEntry, ...)
			if string.sub (textEntry:GetText (), 1, 1) ~= "!" then
				textEntry:SetText (self.CharacterReplacementMap:TranslateString (textEntry:GetText ()))
			end
			return textEntry:__OnEnter (...)
		end
	end
end

-- Xlit.TextEntryExtender = Xlit.TextEntryExtender ()