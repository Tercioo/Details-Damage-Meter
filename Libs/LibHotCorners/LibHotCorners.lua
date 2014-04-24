local major, minor = "LibHotCorners", 5
local LibHotCorners, oldminor = LibStub:NewLibrary (major, minor)

if (not LibHotCorners) then 
	return
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> main functions

	LibHotCorners.embeds = LibHotCorners.embeds or {}
	local embed_functions = {
		"RegisterHotCornerButton"
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

	LibHotCorners.topleft = {widgets = {}}
	LibHotCorners.bottomleft = {}
	LibHotCorners.topright = {}
	LibHotCorners.bottomright = {}

	function LibHotCorners:RegisterHotCornerButton (corner, name, icon, tooltip, clickfunc, menus)
		corner = string.lower (corner)
		assert (corner == "topleft" or corner == "bottomleft" or corner == "topright" or corner == "bottomright", "LibHotCorners:RegisterAddon expects a corner on #1 argument.")
		tinsert (LibHotCorners [corner], {name = name, icon = icon, tooltip = tooltip, click = clickfunc, menus = menus})
	end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> top left corner

	local TopLeftCorner = CreateFrame ("frame", "LibHotCornersTopLeft", UIParent)

	TopLeftCorner:SetSize (20, 20)
	TopLeftCorner:SetFrameStrata ("fullscreen")
	TopLeftCorner:SetPoint ("TopLeft", UIParent, "TopLeft", 0, 0)

	local TopLeftCornerBackdrop = {bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]], tile = true, tileSize = 40}
	
	--> on enter
	local TopLeftCornerOnEnter = function (self)
		self:SetSize (40, GetScreenHeight())
		TopLeftCorner:SetBackdrop (TopLeftCornerBackdrop)
		
		for index, button_table in ipairs (LibHotCorners.topleft) do 
			if (button_table.widget) then
				button_table.widget:Show()
			else
				LibHotCorners:CreateAddonWidget (TopLeftCorner, button_table, index, "TopLeft")
			end
		end
	end

	--> on leave
	local TopLeftCornerOnLeave = function (self)
		self:SetSize (20, 20)
		TopLeftCorner:SetBackdrop (nil)
		for index, button_table in ipairs (LibHotCorners.topleft) do 
			button_table.widget:Hide()
		end
	end
	
	TopLeftCorner:SetScript ("OnEnter", TopLeftCornerOnEnter)
	TopLeftCorner:SetScript ("OnLeave", TopLeftCornerOnLeave)

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
	local WidgetOnMouseUp = function (self)
		self:SetPoint ("topleft", self.parent, "topleft", 4, self.index*32*-1)
		self.table.click()
	end
	
	function LibHotCorners:CreateAddonWidget (frame, button_table, index, side)
		local button = CreateFrame ("button", "LibHotCorners" .. side .. button_table.name, frame)
		
		button.index = index
		button.table = button_table
		button.parent = frame
		button_table.widget = button
		
		button:SetNormalTexture (button_table.icon)
		button:SetHighlightTexture (button_table.icon)
		
		button:SetPoint ("topleft", frame, "topleft", 4, index*32*-1)
		button:SetSize (32, 32)
		button:SetFrameLevel (frame:GetFrameLevel()+1)
		button:SetScript ("OnEnter", WidgetOnEnter)
		button:SetScript ("OnLeave", WidgetOnLeave)
		button:SetScript ("OnMouseDown", WidgetOnMouseDown)
		button:SetScript ("OnMouseUp", WidgetOnMouseUp)
		
		return button
	end