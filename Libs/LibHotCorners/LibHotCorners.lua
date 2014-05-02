local major, minor = "LibHotCorners", 5
local LibHotCorners, oldminor = LibStub:NewLibrary (major, minor)

if (not LibHotCorners) then 
	return
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> main function

	LibHotCorners.embeds = LibHotCorners.embeds or {}
	local embed_functions = {
		"RegisterHotCornerButton",
		"HideHotCornerButton"
	}
	function LibHotCorners:Embed (target)
		for k, v in pairs (embed_functions) do
			target[v] = self[v]
		end
		self.embeds [target] = true
		return target
	end

	local CallbackHandler = LibStub:GetLibrary ("CallbackHandler-1.0")
	LibHotCorners.callbacks = LibHotCorners.callbacks or CallbackHandler:New (LibHotCorners)

	LibHotCorners.topleft = {widgets = {}, quickclick = false, is_enabled = false, map = {}}
	LibHotCorners.bottomleft = {}
	LibHotCorners.topright = {}
	LibHotCorners.bottomright = {}

	local function test (corner)
		assert (corner == "topleft" or corner == "bottomleft" or corner == "topright" or corner == "bottomright", "LibHotCorners:RegisterAddon expects a corner on #1 argument.")
	end
	
	function LibHotCorners:RegisterHotCornerButton (name, corner, savedtable, fname, icon, tooltip, clickfunc, menus, quickfunc)
		corner = string.lower (corner)
		test (corner)
		
		tinsert (LibHotCorners [corner], {name = name, fname = fname, savedtable = savedtable, icon = icon, tooltip = tooltip, click = clickfunc, menus = menus, quickfunc = quickclick})
		LibHotCorners [corner].map [name] = #LibHotCorners [corner]
		
		if (not savedtable.hide) then
			LibHotCorners [corner].is_enabled = true
		end
		
		if (quickfunc and savedtable [corner .. "_quick_click"]) then
			LibHotCorners [corner].quickfunc = quickfunc
		end
		
		return LibHotCorners [corner].map [name]
	end
	
	function LibHotCorners:QuickHotCornerEnable (name, corner, value)
		
		corner = string.lower (corner)
		test (corner)
		
		local corner_table = LibHotCorners [corner]
		local addon_table = corner_table [corner_table.map [name]]
		
		addon_table.savedtable.quickclick = value
		
		if (value and addon_table.quickfunc) then
			corner_table.quickfunc = addon_table.quickfunc
		else
			local got = false
			for index, button_table in ipairs (corner_table) do 
				if (button_table.savedtable.quickclick) then
					corner_table.quickfunc = button_table.quickfunc
					got = true
					break
				end
			end
			
			if (not got) then
				corner_table.quickfunc = nil
			end
		end
	end
	
	function LibHotCorners:HideHotCornerButton (name, corner, value)
		
		corner = string.lower (corner)
		test (corner)
		
		local corner_table = LibHotCorners [corner]
		local addon_table = corner_table [corner_table.map [name]]
		
		addon_table.savedtable.hide = value
		
		LibHotCorners [corner].is_enabled = false
		
		for index, button_table in ipairs (corner_table) do 
			if (not button_table.savedtable.hide) then
				LibHotCorners [corner].is_enabled = true
				break
			end
		end
		
		return true
	end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> create top left corner

	local TopLeftCorner = CreateFrame ("frame", "LibHotCornersTopLeft", UIParent)

	TopLeftCorner:SetSize (1, 1)
	TopLeftCorner:SetFrameStrata ("fullscreen")
	TopLeftCorner:SetPoint ("TopLeft", UIParent, "TopLeft", 0, 0)

	local TopLeftCornerBackdrop = {bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]], tile = true, tileSize = 40}
	
	--> on enter
	local TopLeftCornerOnEnter = function (self)
	
		if (not LibHotCorners.topleft.is_enabled) then
			return
		end
	
		self:SetSize (40, GetScreenHeight())
		TopLeftCorner:SetBackdrop (TopLeftCornerBackdrop)
		
		local i = 1
		
		for index, button_table in ipairs (LibHotCorners.topleft) do 
			if (not button_table.widget) then
				LibHotCorners:CreateAddonWidget (TopLeftCorner, button_table, index, "TopLeft")
			end
			
			if (not button_table.savedtable.hide) then
				button_table.widget:SetPoint ("topleft", self, "topleft", 4, i * 32 * -1)
				button_table.widget:Show()
				i = i + 1
			else
				button_table.widget:Hide()
			end
			
		end

	end

	--> on leave
	local TopLeftCornerOnLeave = function (self)
		self:SetSize (1, 1)
		TopLeftCorner:SetBackdrop (nil)
		for index, button_table in ipairs (LibHotCorners.topleft) do 
			button_table.widget:Hide()
		end
	end

	TopLeftCorner:SetScript ("OnEnter", TopLeftCornerOnEnter)
	TopLeftCorner:SetScript ("OnLeave", TopLeftCornerOnLeave)
	
	--fast corner button
	local QuickClickButton = CreateFrame ("button", "LibHotCornersTopLeftFastButton", TopLeftCorner)
	QuickClickButton:SetPoint ("topleft", TopLeftCorner, "topleft")
	QuickClickButton:SetSize (1, 1)
	QuickClickButton:SetScript ("OnClick", function (self, button)
		if (LibHotCorners.topleft.quickfunc) then
			LibHotCorners.topleft.quickfunc (self, button)
		end
	end)

	QuickClickButton:SetScript ("OnEnter", function() 
		TopLeftCornerOnEnter (TopLeftCorner)
	end)
	
	LibHotCorners.topleft.quickbutton = QuickClickButton

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> buttons 

	local ShowTooltip = function (self)
		if (self.table.tooltip) then
			GameTooltip:SetOwner (self, "ANCHOR_RIGHT")
			GameTooltip:AddLine (self.table.tooltip)
			GameTooltip:Show()
		end
	end

	local WidgetOnEnter = function (self)
		self.parent:GetScript("OnEnter")(self.parent)
		ShowTooltip (self)
	end
	local WidgetOnLeave = function (self)
		self:SetPoint ("topleft", self.parent, "topleft", 4, self.index*32*-1)
		self.parent:GetScript("OnLeave")(self.parent)
		GameTooltip:Hide()
	end
	local WidgetOnMouseDown = function (self)
		self:SetPoint ("topleft", self.parent, "topleft", 5, self.index*33*-1)
	end
	local WidgetOnMouseUp = function (self, button)
		self:SetPoint ("topleft", self.parent, "topleft", 4, self.index*32*-1)
		
		--> if the widget have a click function, run it
		if (self.table.click) then
			self.table.click (self, button)
		end
	end
	
	function LibHotCorners:CreateAddonWidget (frame, button_table, index, side)
	
		--> create the button
		local button = CreateFrame ("button", "LibHotCorners" .. side .. button_table.fname, frame)
		button:SetFrameLevel (frame:GetFrameLevel()+1)
		
		--> write some attributes
		button.index = index
		button.table = button_table
		button.parent = frame
		button_table.widget = button
		
		--> set the icon
		button:SetNormalTexture (button_table.icon)
		button:SetHighlightTexture (button_table.icon)
		
		--> set the point and size
		button:SetSize (32, 32)
		button:Hide()
		
		--> set the scripts
		button:SetScript ("OnEnter", WidgetOnEnter)
		button:SetScript ("OnLeave", WidgetOnLeave)
		button:SetScript ("OnMouseDown", WidgetOnMouseDown)
		button:SetScript ("OnMouseUp", WidgetOnMouseUp)
		
		return button
	end