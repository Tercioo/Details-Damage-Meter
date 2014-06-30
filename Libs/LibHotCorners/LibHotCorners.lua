local major, minor = "LibHotCorners", 6
local LibHotCorners, oldminor = LibStub:NewLibrary (major, minor)

if (not LibHotCorners) then 
	return
end

local LBD = LibStub ("LibDataBroker-1.1")

local debug = false
local tinsert = tinsert

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> main function

	LibHotCorners.embeds = LibHotCorners.embeds or {}
	local embed_functions = {
		"RegisterHotCornerButton",
		"HideHotCornerButton",
		"QuickHotCornerEnable"
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

	LibHotCorners.topleft = LibHotCorners.topleft or {widgets = {}, quickclick = false, is_enabled = false, map = {}}
	LibHotCorners.bottomleft = {}
	LibHotCorners.topright = {}
	LibHotCorners.bottomright = {}

	local function test (corner)
		assert (corner == "topleft" or corner == "bottomleft" or corner == "topright" or corner == "bottomright", "LibHotCorners:RegisterAddon expects a corner on #1 argument.")
	end
	
	function LibHotCorners:RegisterHotCornerButton (name, corner, savedtable, fname, icon, tooltip, clickfunc, menus, quickfunc, onenter, onleave)
	
		corner = string.lower (corner)
		test (corner)
		
		if (savedtable and not LibHotCorners.options) then
			if (not savedtable.__cachedoptions) then
				savedtable.__cachedoptions = {age = 0, clicks = {}, disabled = {}, is_enabled = true}
			end
			LibHotCorners.options = savedtable.__cachedoptions
			LibHotCorners.options.age = LibHotCorners.options.age + 1
			
			--> version 6
			if (type (LibHotCorners.options.is_enabled) ~= "boolean") then
				LibHotCorners.options.is_enabled = true
			end
		elseif (savedtable) then
			if (LibHotCorners.options.age < savedtable.__cachedoptions.age) then
				LibHotCorners.options = savedtable.__cachedoptions
				LibHotCorners.options.age = LibHotCorners.options.age + 1
			end
			
			--> version 6
			if (type (LibHotCorners.options.is_enabled) ~= "boolean") then
				LibHotCorners.options.is_enabled = true
			end
		end
		
		savedtable = savedtable or {}
		
		tinsert (LibHotCorners [corner], {name = name, fname = fname, savedtable = savedtable, icon = icon, tooltip = tooltip, click = clickfunc, menus = menus, quickfunc = quickfunc, onenter = onenter, onleave = onleave})
		LibHotCorners [corner].map [name] = #LibHotCorners [corner]
		
		if (not savedtable.hide) then
			LibHotCorners [corner].is_enabled = true
		end
		
		if (quickfunc and savedtable [corner .. "_quickclick"]) then
			LibHotCorners [corner].quickfunc = quickfunc
		end
		
		return LibHotCorners [corner].map [name]
	end
	
	function LibHotCorners:QuickHotCornerEnable (name, corner, value)
		
		corner = string.lower (corner)
		test (corner)
		
		local corner_table = LibHotCorners [corner]
		local addon_table = corner_table [corner_table.map [name]]
		
		addon_table.savedtable [corner .. "_quickclick"] = value

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

		--print (LibHotCorners, corner)
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
--> data broker stuff
	function LibHotCorners:DataBrokerCallback (event, name, dataobj)
		if (not name or not dataobj or not dataobj.type) then
			return
		end
		if (dataobj.icon and dataobj.OnClick and not dataobj.HotCornerIgnore) then
			LibHotCorners:RegisterHotCornerButton (name, "TopLeft", nil, name .. "HotCornerLauncher", dataobj.icon, dataobj.OnTooltipShow, dataobj.OnClick, nil, nil, dataobj.OnEnter, dataobj.OnLeave)
		end
	end
	LBD.RegisterCallback (LibHotCorners, "DataBrokerCallback")

	local f = CreateFrame ("frame")
	f:RegisterEvent ("PLAYER_LOGIN")
	f:SetScript ("OnEvent", function()
	
		SLASH_HOTCORNER1, SLASH_HOTCORNER2 = "/hotcorners", "/hotcorner"
		function SlashCmdList.HOTCORNER (msg, editbox)
			HotCornersOpenOptions (self);
		end
	
		for name, dataobj in LBD:DataObjectIterator() do
			if (dataobj.type and dataobj.icon and dataobj.OnClick and not dataobj.HotCornerIgnore) then
				LibHotCorners:RegisterHotCornerButton (name, "TopLeft", nil, name .. "HotCornerLauncher", dataobj.icon, dataobj.OnTooltipShow, dataobj.OnClick, nil, nil, dataobj.OnEnter, dataobj.OnLeave)
			end
		end
		for k, v in pairs (LBD.attributestorage) do 
			--print (k, v)
			--print ("----------------")
			--vardump (v)
			
		end
		f:UnregisterEvent ("PLAYER_LOGIN")
	end)
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> scripts

	--> background (window mode fix)
	function HotCornersBackgroundOnEnter (self)
		if (LibHotCornersTopLeft and LibHotCornersTopLeft:IsShown()) then
			if (LibHotCornersTopLeft:GetWidth() > 2) then
				HotCornersOnLeave (LibHotCornersTopLeft)
			end
		end
		self:EnableMouse (false)
	end

	--> set size
		local function set_size (self)
			if (self.position == "topleft" or self.position == "topright") then
				self:SetSize (40, GetScreenHeight())
			else
				self:SetSize (GetScreenWidth(), 40)
			end
		end
		
	--> show tooltip
		local show_tooltip = function (self)
			if (self.table.tooltip) then
				if (type (self.table.tooltip) == "function") then
					GameTooltip:SetOwner (self, "ANCHOR_RIGHT")
					self.table.tooltip (GameTooltip)
					GameTooltip:Show()
				elseif (type (self.table.tooltip) == "string") then
					GameTooltip:SetOwner (self, "ANCHOR_RIGHT")
					GameTooltip:AddLine (self.table.tooltip)
					GameTooltip:Show()
				end
			elseif (self.table.onenter) then
				self.table.onenter (self)
			end
		end
		
	--> corner frame on enter
		local more_clicked = function (t1, t2)
			return t1[1] > t2[1]
		end

		function HotCornersOnEnter (self)
		
			if (not LibHotCorners.options.is_enabled) then
				return
			end
			
			if (not LibHotCorners [self.position].is_enabled) then
				return
			end
	
			set_size (self)
			
			HotCornersBackgroundFrame:EnableMouse (true)
			
			local i = 1
			
			local sort = {}
			for index, button_table in ipairs (LibHotCorners [self.position]) do 
				tinsert (sort, {LibHotCorners.options.clicks [button_table.name] or 0, button_table})
			end
			table.sort (sort, more_clicked)

			local last_button
			
			for index, button_table in ipairs (sort) do 
				button_table = button_table [2]
				if (not button_table.widget) then
					LibHotCorners:CreateAddonWidget (self, button_table, index, self.position)
				end
				
				button_table.widget:ClearAllPoints()
				
				if (not button_table.savedtable.hide) then
					if (self.position == "topleft" or self.position == "topright") then
						local y = i * 35 * -1
						button_table.widget:SetPoint ("topleft", self, "topleft", 4, y)
						button_table.widget.y = y
					else
						local x = i * 35
						button_table.widget:SetPoint ("topleft", self, "topleft", x, -4)
						button_table.widget.x = x
					end

					button_table.widget:Show()
					last_button = button_table.widget
					
					i = i + 1
				else
					button_table.widget:Hide()
				end
			end
			
			local OptionsButton = LibHotCorners [self.position].optionsbutton
			local y = i * 35 * -1
			OptionsButton:SetPoint ("top", self, "top", 0, y)
			OptionsButton:Show()
			
		end

	--> corner frame on leave
		function HotCornersOnLeave (self)
			self:SetSize (1, 1)
			for index, button_table in ipairs (LibHotCorners [self.position]) do 
				button_table.widget:Hide()
			end
			local OptionsButton = LibHotCorners [self.position].optionsbutton
			OptionsButton:Hide()
		end
		
	--> quick corner on click
		function HotCornersOnQuickClick (self, button)
			local parent_position = self:GetParent().position
			if (LibHotCorners [parent_position].quickfunc) then
				LibHotCorners [parent_position].quickfunc (self, button)
			end
		end

	--> options button onenter
		function HotCornersOptionsButtonOnEnter (self)
			set_size (self:GetParent())
			for index, button_table in ipairs (LibHotCorners [self:GetParent().position]) do 
				if (not button_table.savedtable.hide) then
					button_table.widget:Show()
				end
			end
			self:Show()
		end
		
		function HotCornersOpenOptions (self)
			HotCornersOptionsFrame:Show()
			HotCornersOptionsFrameEnableCheckBox:SetChecked (LibHotCorners.options.is_enabled)
		end
		
		function HotCornersSetEnabled (state)
			LibHotCorners.options.is_enabled = state
		end
	
	--> options button onleave
		function HotCornersOptionsButtonOnLeave (self)
			self:GetParent():GetScript("OnLeave")(self:GetParent())
		end
	
	--> button onenter
		function HotCornersButtonOnEnter (self)
			set_size (self:GetParent())
			for index, button_table in ipairs (LibHotCorners [self:GetParent().position]) do 
				if (not button_table.savedtable.hide) then
					button_table.widget:Show()
				end
			end
			show_tooltip (self)
			local OptionsButton = LibHotCorners [self:GetParent().position].optionsbutton
			OptionsButton:Show()
		end
	
	--> button onleave
		function HotCornersButtonOnLeave (self)
			GameTooltip:Hide()
			if (self.table.onleave) then
				self.table.onleave (self)
			end
			self:GetParent():GetScript("OnLeave")(self:GetParent())
			local OptionsButton = LibHotCorners [self:GetParent().position].optionsbutton
			OptionsButton:Hide()
		end

	--> button onmousedown
		function HotCornersButtonOnMouseDown (self, button)
			if (self:GetParent().position == "topleft" or self:GetParent().position == "topright") then
				self:SetPoint ("topleft", self:GetParent(), "topleft", 5, self.y - 1)
			else
				self:SetPoint ("topleft", self:GetParent(), "topleft", self.x+1, -6)
			end
		end
		
	--> button onmouseup
		function HotCornersButtonOnMouseUp (self, button)
			if (self:GetParent().position == "topleft" or self:GetParent().position == "topright") then
				self:SetPoint ("topleft", self:GetParent(), "topleft", 4, self.y)
			else
				self:SetPoint ("topleft", self:GetParent(), "topleft", self.x, -4)
			end
			if (self.table.click) then
				LibHotCorners.options.clicks [self.table.name] = LibHotCorners.options.clicks [self.table.name] or 0
				LibHotCorners.options.clicks [self.table.name] = LibHotCorners.options.clicks [self.table.name] + 1
				self.table.click (self, button)
			end
		end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> create top left corner

	local TopLeftCorner = CreateFrame ("Frame", "LibHotCornersTopLeft", nil, "HotCornersFrameCornerTemplate")
	TopLeftCorner:SetPoint ("topleft", UIParent, "topleft", 0, 0)
	TopLeftCorner.position = "topleft"
	
	--fast corner button
	local QuickClickButton = CreateFrame ("button", "LibHotCornersTopLeftFastButton", TopLeftCorner, "HotCornersQuickCornerButtonTemplate")
	
	--options button
	local OptionsButton = CreateFrame ("button", "LibHotCornersTopLeftOptionsButton", TopLeftCorner, "HotCornersOptionsButtonTemplate")
	
	if (debug) then
		QuickClickButton:SetSize (20, 20)
		QuickClickButton:SetBackdrop ({bgFile = [[Interface\DialogFrame\UI-DialogBox-Gold-Background]], tile = true, tileSize = 40})
		QuickClickButton:SetBackdropColor (1, 0, 0, 1)
	end
	
	LibHotCorners.topleft.quickbutton = QuickClickButton
	LibHotCorners.topleft.optionsbutton = OptionsButton

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> buttons 

	function LibHotCorners:CreateAddonWidget (frame, button_table, index, side)
	
		--> create the button
		local button = CreateFrame ("button", "LibHotCorners" .. side .. button_table.fname, frame, "HotCornersButtonTemplate")
		
		--> write some attributes
		button.index = index
		button.table = button_table
		button.parent = frame
		button_table.widget = button
		
		--> set the icon
		button:SetNormalTexture (button_table.icon)
		button:SetHighlightTexture (button_table.icon)
		
		if (string.lower (button_table.icon):find ([[\icons\]])) then
			button:GetNormalTexture():SetTexCoord (0.078125, 0.9375, 0.078125, 0.9375)
			button:GetHighlightTexture():SetTexCoord (0.078125, 0.9375, 0.078125, 0.9375)
		end
		
		return button
	end