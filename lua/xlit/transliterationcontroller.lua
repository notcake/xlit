local self = {}
Xlit.TransliterationController = Xlit.MakeConstructor (self)

function self:ctor ()
	self.Unsaved = false
	
	timer.Create ("Xlit.TransliterationController", 10, 0,
		function ()
			if not self.Unsaved then return end
			
			self:Save ()
		end
	)
	
	Xlit:AddEventListener ("Unloaded", tostring (self),
		function ()
			self:dtor ()
		end
	)
	
	self:Load ()
end

function self:dtor ()
	self:Save ()
	
	timer.Destroy ("Xlit.TransliterationController")
	Xlit:RemoveEventListener ("Unloaded", tostring (self))
end

function self:Load ()
	self.Unsaved = false
	
	local transliterationTable = GLib.Unicode.GetTransliterationTable ()
	local inBuffer = GLib.StringInBuffer (file.Read ("data/xlit_data.txt", "GAME") or "")
	while not inBuffer:IsEndOfStream () do
		local codePoint = inBuffer:UInt32 ()
		local entry = {}
		local count = inBuffer:UInt8 ()
		for i = 1, count do
			entry [#entry + 1] = inBuffer:String ()
		end
		transliterationTable [GLib.UTF8.Char (codePoint)] = entry
	end
end

function self:Save ()
	if not self.Unsaved then return end
	self.Unsaved = false
	
	local transliterationTable = GLib.Unicode.GetTransliterationTable ()
	local outBuffer = GLib.StringOutBuffer ()
	for character, entry in pairs (transliterationTable) do
		outBuffer:UInt32 (GLib.UTF8.Byte (character))
		outBuffer:UInt8 (#entry)
		for _, v in ipairs (entry) do
			outBuffer:String (v)
		end
	end
	
	file.Write ("xlit_data.txt", outBuffer:GetString ())
end

function self:SetTransliterations (character, transliterations)
	GLib.Unicode.GetTransliterationTable () [character] = transliterations
	self.Unsaved = true
end

Xlit.TransliterationController = Xlit.TransliterationController ()