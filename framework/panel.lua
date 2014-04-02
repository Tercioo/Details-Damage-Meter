--> details main objects
local _detalhes = 		_G._detalhes
local gump = 			_detalhes.gump
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
local _
--> lua locals
local _rawset = rawset --> lua local
local _rawget = rawget --> lua local
local _setmetatable = setmetatable --> lua local
local _unpack = unpack --> lua local
local _type = type --> lua local
local _math_floor = math.floor --> lua local
local loadstring = loadstring --> lua local

local cleanfunction = function() end
local PanelMetaFunctions = {}
local APIFrameFunctions

------------------------------------------------------------------------------------------------------------
--> metatables

	PanelMetaFunctions.__call = function (_table, value)
		--> nothing to do
		return true
	end

------------------------------------------------------------------------------------------------------------
--> members

	--> tooltip
	local gmember_tooltip = function (_object)
		return _object:GetTooltip()
	end
	--> shown
	local gmember_shown = function (_object)
		return _object:IsShown()
	end
	--> backdrop color
	local gmember_color = function (_object)
		return _object.frame:GetBackdropColor()
	end
	--> backdrop table
	local gmember_backdrop = function (_object)
		return _object.frame:GetBackdrop()
	end
	--> frame width
	local gmember_width = function (_object)
		return _object.frame:GetWidth()
	end
	--> frame height
	local gmember_height = function (_object)
		return _object.frame:GetHeight()
	end
	--> locked
	local gmember_locked = function (_object)
		return _rawget (_object, "is_locked")
	end

	local get_members_function_index = {
		["tooltip"] = gmember_tooltip,
		["shown"] = gmember_shown,
		["color"] = gmember_color,
		["backdrop"] = gmember_backdrop,
		["width"] = gmember_width,
		["height"] = gmember_height,
		["locked"] = gmember_locked,
	}
	
	PanelMetaFunctions.__index = function (_table, _member_requested)

		local func = get_members_function_index [_member_requested]
		if (func) then
			return func (_table, _member_requested)
		end
		
		local fromMe = _rawget (_table, _member_requested)
		if (fromMe) then
			return fromMe
		end
		
		return PanelMetaFunctions [_member_requested]
	end
	

	--> tooltip
	local smember_tooltip = function (_object, _value)
		return _object:SetTooltip (_value)
	end
	--> show
	local smember_show = function (_object, _value)
		if (_value) then
			return _object:Show()
		else
			return _object:Hide()
		end
	end
	--> hide
	local smember_hide = function (_object, _value)
		if (not _value) then
			return _object:Show()
		else
			return _object:Hide()
		end
	end
	--> backdrop color
	local smember_color = function (_object, _value)
		local _value1, _value2, _value3, _value4 = gump:ParseColors (_value)
		return _object:SetBackdropColor (_value1, _value2, _value3, _value4)
	end
	--> frame width
	local smember_width = function (_object, _value)
		return _object.frame:SetWidth (_value)
	end
	--> frame height
	local smember_height = function (_object, _value)
		return _object.frame:SetHeight (_value)
	end

	--> locked
	local smember_locked = function (_object, _value)
		if (_value) then
			_object.frame:SetMovable (false)
			return _rawset (_object, "is_locked", true)
		else
			_object.frame:SetMovable (true)
			_rawset (_object, "is_locked", false)
			return
		end
	end	
	
	--> backdrop
	local smember_backdrop = function (_object, _value)
		return _object.frame:SetBackdrop (_value)
	end
	
	--> close with right button
	local smember_right_close = function (_object, _value)
		return _rawset (_object, "rightButtonClose", _value)
	end
	
	local set_members_function_index = {
		["tooltip"] = smember_tooltip,
		["show"] = smember_show,
		["hide"] = smember_hide,
		["color"] = smember_color,
		["backdrop"] = smember_backdrop,
		["width"] = smember_width,
		["height"] = smember_height,
		["locked"] = smember_locked,
		["close_with_right"] = smember_right_close,
	}
	
	PanelMetaFunctions.__newindex = function (_table, _key, _value)
		local func = set_members_function_index [_key]
		if (func) then
			return func (_table, _value)
		else
			return _rawset (_table, _key, _value)
		end
	end

------------------------------------------------------------------------------------------------------------
--> methods

--> right click to close
	function PanelMetaFunctions:CreateRightClickLabel (textType, w, h)
		local text
		w = w or 20
		h = h or 20
		
		if (textType) then
			textType = string.lower (textType)
			if (textType == "short") then
				text = Loc ["STRING_RIGHTCLICK_CLOSE_SHORT"]
			elseif (textType == "medium") then
				text = Loc ["STRING_RIGHTCLICK_CLOSE_MEDIUM"]
			elseif (textType == "large") then
				text = Loc ["STRING_RIGHTCLICK_CLOSE_LARGE"]
			end
		else
			text = Loc ["STRING_RIGHTCLICK_CLOSE_SHORT"]
		end

		return gump:NewLabel (self, _, "$parentRightMouseToClose", nil, "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:"..w..":"..h..":0:1:512:512:8:70:328:409|t " .. text)
	end

--> show & hide
	function PanelMetaFunctions:Show()
		self.frame:Show()
		
	end
	function PanelMetaFunctions:Hide()
		self.frame:Hide()
		
	end

-- setpoint
	function PanelMetaFunctions:SetPoint (v1, v2, v3, v4, v5)
		v1, v2, v3, v4, v5 = gump:CheckPoints (v1, v2, v3, v4, v5, self)
		if (not v1) then
			print ("Invalid parameter for SetPoint")
			return
		end
		return self.widget:SetPoint (v1, v2, v3, v4, v5)
	end
	
-- sizes 
	function PanelMetaFunctions:SetSize (w, h)
		if (w) then
			self.frame:SetWidth (w)
		end
		if (h) then
			self.frame:SetHeight (h)
		end
	end
	
-- clear
	function PanelMetaFunctions:HideWidgets()
		for widgetName, widgetSelf in pairs (self) do 
			if (type (widgetSelf) == "table" and widgetSelf.dframework) then
				widgetSelf:Hide()
			end
		end
	end

-- backdrop
	function PanelMetaFunctions:SetBackdrop (background, edge, tilesize, edgesize, tile, left, right, top, bottom)
	
		if (_type (background) == "boolean" and not background) then
			return self.frame:SetBackdrop (nil)
			
		elseif (_type (background) == "table") then
			self.frame:SetBackdrop (background)
			
		else
			local currentBackdrop = self.frame:GetBackdrop() or {edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", tile=true, tileSize=16, edgeSize=16, insets={left=1, right=0, top=0, bottom=0}}
			currentBackdrop.bgFile = background or currentBackdrop.bgFile
			currentBackdrop.edgeFile = edgeFile or currentBackdrop.edgeFile
			currentBackdrop.tileSize = tilesize or currentBackdrop.tileSize
			currentBackdrop.edgeSize = edgesize or currentBackdrop.edgeSize
			currentBackdrop.tile = tile or currentBackdrop.tile
			currentBackdrop.insets.left = left or currentBackdrop.insets.left
			currentBackdrop.insets.right = left or currentBackdrop.insets.right
			currentBackdrop.insets.top = left or currentBackdrop.insets.top
			currentBackdrop.insets.bottom = left or currentBackdrop.insets.bottom
			self.frame:SetBackdrop (currentBackdrop)
		end
	end
	
-- backdropcolor
	function PanelMetaFunctions:SetBackdropColor (color, arg2, arg3, arg4)
		if (arg2) then
			self.frame:SetBackdropColor (color, arg2, arg3, arg4 or 1)
			self.frame.Gradient.OnLeave = {color, arg2, arg3, arg4 or 1}
		else
			local _value1, _value2, _value3, _value4 = gump:ParseColors (color)
			self.frame:SetBackdropColor (_value1, _value2, _value3, _value4)
			self.frame.Gradient.OnLeave = {_value1, _value2, _value3, _value4}
		end
	end
	
-- border color	
	function PanelMetaFunctions:SetBackdropBorderColor (color, arg2, arg3, arg4)
		if (arg2) then
			return self.frame:SetBackdropBorderColor (color, arg2, arg3, arg4)
		end
		local _value1, _value2, _value3, _value4 = gump:ParseColors (color)
		self.frame:SetBackdropBorderColor (_value1, _value2, _value3, _value4)
	end
	
-- gradient colors
	function PanelMetaFunctions:SetGradient (FadeType, color)
		local _value1, _value2, _value3, _value4 = gump:ParseColors (color)
		if (FadeType == "OnEnter") then
			self.frame.Gradient.OnEnter = {_value1, _value2, _value3, _value4}
		elseif (FadeType == "OnLeave") then
			self.frame.Gradient.OnLeave = {_value1, _value2, _value3, _value4}
		end
	end
	
-- tooltip
	function PanelMetaFunctions:SetTooltip (tooltip)
		if (tooltip) then
			return _rawset (self, "have_tooltip", tooltip)
		else
			return _rawset (self, "have_tooltip", nil)
		end
	end
	function PanelMetaFunctions:GetTooltip()
		return _rawget (self, "have_tooltip")
	end

-- frame levels
	function PanelMetaFunctions:GetFrameLevel()
		return self.widget:GetFrameLevel()
	end
	function PanelMetaFunctions:SetFrameLevel (level, frame)
		if (not frame) then
			return self.widget:SetFrameLevel (level)
		else
			local framelevel = frame:GetFrameLevel (frame) + level
			return self.widget:SetFrameLevel (framelevel)
		end
	end

-- frame stratas
	function PanelMetaFunctions:SetFrameStrata()
		return self.widget:GetFrameStrata()
	end
	function PanelMetaFunctions:SetFrameStrata (strata)
		if (_type (strata) == "table") then
			self.widget:SetFrameStrata (strata:GetFrameStrata())
		else
			self.widget:SetFrameStrata (strata)
		end
	end
	
-- enable and disable gradients
	function PanelMetaFunctions:DisableGradient()
		self.GradientEnabled = false
	end
	function PanelMetaFunctions:EnableGradient()
		self.GradientEnabled = true
	end

--> hooks
	function PanelMetaFunctions:SetHook (hookType, func)
		if (func) then
			_rawset (self, hookType.."Hook", func)
		else
			_rawset (self, hookType.."Hook", nil)
		end
	end

------------------------------------------------------------------------------------------------------------
--> scripts

	function PanelMetaFunctions:RunGradient (cancel)
		if (type (cancel) == "boolean" and not canceal) then
			local _r, _g, _b, _a = self.frame:GetBackdropColor()
			if (_r) then
				local OnLeaveColors = self.frame.Gradient.OnLeave
				gump:GradientEffect (self.frame, "frame", _r, _g, _b, _a, OnLeaveColors[1], OnLeaveColors[2], OnLeaveColors[3], OnLeaveColors[4], .3)
			end
		else
			local _r, _g, _b, _a = self.frame:GetBackdropColor()
			if (_r) then
				local OnEnterColors = self.frame.Gradient.OnEnter
				gump:GradientEffect (self.frame, "frame", _r, _g, _b, _a, OnEnterColors[1], OnEnterColors[2], OnEnterColors[3], OnEnterColors[4], .3)
			end
		end
	end
	
	local OnEnter = function (frame)
		if (frame.MyObject.OnEnterHook) then
			local interrupt = frame.MyObject.OnEnterHook (frame)
			if (interrupt) then
				return
			end
		end
		
		if (frame.MyObject.GradientEnabled) then
			frame.MyObject:RunGradient()
		end
		
		if (frame.MyObject.have_tooltip) then 
			GameCooltip:Reset()
			GameCooltip:SetType ("tooltip")
			GameCooltip:SetColor ("main", "transparent")
			GameCooltip:AddLine (frame.MyObject.have_tooltip)
			GameCooltip:SetOwner (frame)
			GameCooltip:ShowCooltip()
		end
	end

	local OnLeave = function (frame)
		if (frame.MyObject.OnLeaveHook) then
			local interrupt = frame.MyObject.OnLeaveHook (frame)
			if (interrupt) then
				return
			end
		end
		
		if (frame.MyObject.GradientEnabled) then
			frame.MyObject:RunGradient (false)
		end
		
		if (frame.MyObject.have_tooltip) then 
			_detalhes.popup:ShowMe (false)
		end
		
	end
	
	local OnHide = function (frame)
		if (frame.MyObject.OnHideHook) then
			local interrupt = frame.MyObject.OnHideHook (frame)
			if (interrupt) then
				return
			end
		end
	end
	
	local OnShow = function (frame)
		if (frame.MyObject.OnShowHook) then
			local interrupt = frame.MyObject.OnShowHook (frame)
			if (interrupt) then
				return
			end
		end
	end
	
	local OnMouseDown = function (frame, button)
		if (frame.MyObject.OnMouseDownHook) then
			local interrupt = frame.MyObject.OnMouseDownHook (frame, button)
			if (interrupt) then
				return
			end
		end
		
		if (frame.MyObject.container == UIParent) then
			if (not frame.isLocked and frame:IsMovable()) then
				frame.isMoving = true
				frame:StartMoving()
			end
		
		elseif (not frame.MyObject.container.isLocked and frame.MyObject.container:IsMovable()) then
			if (not frame.isLocked and frame:IsMovable()) then
				frame.MyObject.container.isMoving = true
				frame.MyObject.container:StartMoving()
			end
		end
		

	end
	
	local OnMouseUp = function (frame, button)
		if (frame.MyObject.OnMouseUpHook) then
			local interrupt = frame.MyObject.OnMouseUpHook (frame, button)
			if (interrupt) then
				return
			end
		end
		
		if (button == "RightButton" and frame.MyObject.rightButtonClose) then
			frame.MyObject:Hide()
		end
		
		if (frame.MyObject.container == UIParent) then
			if (frame.isMoving) then
				frame:StopMovingOrSizing()
				frame.isMoving = false
			end
		else
			if (frame.MyObject.container.isMoving) then
				frame.MyObject.container:StopMovingOrSizing()
				frame.MyObject.container.isMoving = false
			end
		end
	end
	
------------------------------------------------------------------------------------------------------------
--> object constructor
function gump:NewPanel (parent, container, name, member, w, h, backdrop, backdropcolor, bordercolor)

	if (not name) then
		return nil
	elseif (not parent) then
		parent = UIParent
	end
	if (not container) then
		container = parent
	end
	
	if (name:find ("$parent")) then
		name = name:gsub ("$parent", parent:GetName())
	end
	
	local PanelObject = {type = "panel", dframework = true}
	
	if (member) then
		parent [member] = PanelObject
	end
	
	if (parent.dframework) then
		parent = parent.widget
	end
	if (container.dframework) then
		container = container.widget
	end

	
	--> default members:
		--> hooks
		PanelObject.OnEnterHook = nil
		PanelObject.OnLeaveHook = nil
		PanelObject.OnHideHook = nil
		PanelObject.OnShowHook = nil
		PanelObject.OnMouseDownHook = nil
		PanelObject.OnMouseUpHook = nil
		--> misc
		PanelObject.is_locked = true
		PanelObject.GradientEnabled = true
		PanelObject.container = container
		PanelObject.rightButtonClose = false
	
	PanelObject.frame = CreateFrame ("frame", name, parent, "DetailsPanelTemplate")
	PanelObject.widget = PanelObject.frame
	
	if (not APIFrameFunctions) then
		APIFrameFunctions = {}
		local idx = getmetatable (PanelObject.frame).__index
		for funcName, funcAddress in pairs (idx) do 
			if (not PanelMetaFunctions [funcName]) then
				PanelMetaFunctions [funcName] = function (object, ...)
					local x = loadstring ( "return _G."..object.frame:GetName()..":"..funcName.."(...)")
					return x (...)
				end
			end
		end
	end
	
	PanelObject.frame:SetWidth (w or 100)
	PanelObject.frame:SetHeight (h or 100)
	
	PanelObject.frame.MyObject = PanelObject
	
	--> hooks
		PanelObject.frame:SetScript ("OnEnter", OnEnter)
		PanelObject.frame:SetScript ("OnLeave", OnLeave)
		PanelObject.frame:SetScript ("OnHide", OnHide)
		PanelObject.frame:SetScript ("OnShow", OnShow)
		PanelObject.frame:SetScript ("OnMouseDown", OnMouseDown)
		PanelObject.frame:SetScript ("OnMouseUp", OnMouseUp)
		
	_setmetatable (PanelObject, PanelMetaFunctions)

	if (backdrop) then
		PanelObject:SetBackdrop (backdrop)
	elseif (_type (backdrop) == "boolean") then
		PanelObject.frame:SetBackdrop (nil)
	end
	
	if (backdropcolor) then
		PanelObject:SetBackdropColor (backdropcolor)
	end
	
	if (bordercolor) then
		PanelObject:SetBackdropBorderColor (bordercolor)
	end

	return PanelObject
end

------------color pick

local color_pick_func = function()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	local a = OpacitySliderFrame:GetValue()
	ColorPickerFrame:dcallback (r, g, b, a)
end
local color_pick_func_cancel = function()
	ColorPickerFrame:SetColorRGB (unpack (ColorPickerFrame.previousValues))
	local r, g, b = ColorPickerFrame:GetColorRGB()
	local a = OpacitySliderFrame:GetValue()
	ColorPickerFrame:dcallback (r, g, b, a)
end

function gump:ColorPick (frame, r, g, b, alpha, callback)

	ColorPickerFrame:SetPoint ("bottomleft", frame, "topright", 0, 0)
	
	ColorPickerFrame.dcallback = callback
	
	ColorPickerFrame.func = color_pick_func
	ColorPickerFrame.opacityFunc = color_pick_func
	ColorPickerFrame.cancelFunc = color_pick_func_cancel
	
	ColorPickerFrame.opacity = alpha
	ColorPickerFrame.hasOpacity = alpha and true
	
	ColorPickerFrame.previousValues = {r, g, b}
	ColorPickerFrame:SetParent (UIParent)
	ColorPickerFrame:SetFrameStrata ("tooltip")
	ColorPickerFrame:SetColorRGB (r, g, b)
	ColorPickerFrame:Show()

end

------------icon pick

function gump:IconPick (callback)

	if (not gump.IconPickFrame) then 
	
		gump.IconPickFrame = CreateFrame ("frame", "DetailsIconPickFrame", UIParent)
		tinsert (UISpecialFrames, "DetailsIconPickFrame")
		gump.IconPickFrame:SetFrameStrata ("DIALOG")
		
		gump.IconPickFrame:SetPoint ("center", UIParent, "center")
		gump.IconPickFrame:SetWidth (350)
		gump.IconPickFrame:SetHeight (200)
		gump.IconPickFrame:EnableMouse (true)
		gump.IconPickFrame:SetMovable (true)
		gump.IconPickFrame:SetBackdrop ({bgFile = "Interface\\AddOns\\Details\\images\\background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true, tileSize = 32, edgeSize = 32, insets = {left = 5, right = 5, top = 5, bottom = 5}})
		
		gump.IconPickFrame:SetBackdropBorderColor (170/255, 170/255, 170/255)
		gump.IconPickFrame:SetBackdropColor (24/255, 24/255, 24/255, .8)
		gump.IconPickFrame:SetFrameLevel (1)
		
		gump.IconPickFrame.emptyFunction = function() end
		gump.IconPickFrame.callback = gump.IconPickFrame.emptyFunction
		
		--> close button
		local close_button = CreateFrame ("button", nil, gump.IconPickFrame, "UIPanelCloseButton")
		close_button:SetWidth (32)
		close_button:SetHeight (32)
		close_button:SetPoint ("TOPRIGHT", gump.IconPickFrame, "TOPRIGHT", -3, 20)
		close_button:SetFrameLevel (close_button:GetFrameLevel()+2)
		
		local MACRO_ICON_FILENAMES = {}
		gump.IconPickFrame:SetScript ("OnShow", function()
		
			MACRO_ICON_FILENAMES = {};
			MACRO_ICON_FILENAMES[1] = "INV_MISC_QUESTIONMARK";
			local index = 2;
			local numFlyouts = 0;
		
			for i = 1, GetNumSpellTabs() do
				local tab, tabTex, offset, numSpells, _ = GetSpellTabInfo(i);
				offset = offset + 1;
				local tabEnd = offset + numSpells;
				for j = offset, tabEnd - 1 do
					--to get spell info by slot, you have to pass in a pet argument
					local spellType, ID = GetSpellBookItemInfo(j, "player"); 
					if (spellType ~= "FUTURESPELL") then
						local spellTexture = strupper(GetSpellBookItemTexture(j, "player"));
						if ( not string.match( spellTexture, "INTERFACE\\BUTTONS\\") ) then
							MACRO_ICON_FILENAMES[index] = gsub( spellTexture, "INTERFACE\\ICONS\\", "");
							index = index + 1;
						end
					end
					if (spellType == "FLYOUT") then
						local _, _, numSlots, isKnown = GetFlyoutInfo(ID);
						if (isKnown and numSlots > 0) then
							for k = 1, numSlots do 
								local spellID, overrideSpellID, isKnown = GetFlyoutSlotInfo(ID, k)
								if (isKnown) then
									MACRO_ICON_FILENAMES[index] = gsub( strupper(GetSpellTexture(spellID)), "INTERFACE\\ICONS\\", ""); 
									index = index + 1;
								end
							end
						end
					end
				end
			end
			
			GetMacroIcons (MACRO_ICON_FILENAMES)
			GetMacroItemIcons (MACRO_ICON_FILENAMES )
			
		end)
		
		gump.IconPickFrame:SetScript ("OnHide", function()
			MACRO_ICON_FILENAMES = nil;
			collectgarbage()
		end)
		
		gump.IconPickFrame.buttons = {}
		
		local OnClickFunction = function (index) 
			local button = gump.IconPickFrame.buttons [index]
			local texture = button:GetNormalTexture()
			gump.IconPickFrame.callback ("INTERFACE\\ICONS\\"..MACRO_ICON_FILENAMES [button.IconID])
		end
		
		for i = 0, 9 do 
			local newcheck = gump:NewDetailsButton (gump.IconPickFrame, gump.IconPickFrame, _, OnClickFunction, i+1, i+1, 30, 28, "", "", "", "", _, "DetailsIconPickFrameButton"..(i+1))
			newcheck:SetPoint ("topleft", gump.IconPickFrame, "topleft", 12+(i*30), -13)
			newcheck:SetID (i+1)
			gump.IconPickFrame.buttons [#gump.IconPickFrame.buttons+1] = newcheck
		end
		for i = 11, 20 do 
			local newcheck = gump:NewDetailsButton (gump.IconPickFrame, gump.IconPickFrame, _, OnClickFunction, i, i, 30, 28, "", "", "", "", _, "DetailsIconPickFrameButton"..i)
			newcheck:SetPoint ("topleft", "DetailsIconPickFrameButton"..(i-10), "bottomleft", 0, -1)
			newcheck:SetID (i)
			gump.IconPickFrame.buttons [#gump.IconPickFrame.buttons+1] = newcheck
		end
		for i = 21, 30 do 
			local newcheck = gump:NewDetailsButton (gump.IconPickFrame, gump.IconPickFrame, _, OnClickFunction, i, i, 30, 28, "", "", "", "", _, "DetailsIconPickFrameButton"..i)
			newcheck:SetPoint ("topleft", "DetailsIconPickFrameButton"..(i-10), "bottomleft", 0, -1)
			newcheck:SetID (i)
			gump.IconPickFrame.buttons [#gump.IconPickFrame.buttons+1] = newcheck
		end
		for i = 31, 40 do 
			local newcheck = gump:NewDetailsButton (gump.IconPickFrame, gump.IconPickFrame, _, OnClickFunction, i, i, 30, 28, "", "", "", "", _, "DetailsIconPickFrameButton"..i)
			newcheck:SetPoint ("topleft", "DetailsIconPickFrameButton"..(i-10), "bottomleft", 0, -1)
			newcheck:SetID (i)
			gump.IconPickFrame.buttons [#gump.IconPickFrame.buttons+1] = newcheck
		end
		for i = 41, 50 do 
			local newcheck = gump:NewDetailsButton (gump.IconPickFrame, gump.IconPickFrame, _, OnClickFunction, i, i, 30, 28, "", "", "", "", _, "DetailsIconPickFrameButton"..i)
			newcheck:SetPoint ("topleft", "DetailsIconPickFrameButton"..(i-10), "bottomleft", 0, -1)
			newcheck:SetID (i)
			gump.IconPickFrame.buttons [#gump.IconPickFrame.buttons+1] = newcheck
		end
		for i = 51, 60 do 
			local newcheck = gump:NewDetailsButton (gump.IconPickFrame, gump.IconPickFrame, _, OnClickFunction, i, i, 30, 28, "", "", "", "", _, "DetailsIconPickFrameButton"..i)
			newcheck:SetPoint ("topleft", "DetailsIconPickFrameButton"..(i-10), "bottomleft", 0, -1)
			newcheck:SetID (i)
			gump.IconPickFrame.buttons [#gump.IconPickFrame.buttons+1] = newcheck
		end
		
		local scroll = CreateFrame ("ScrollFrame", "DetailsIconPickFrameScroll", gump.IconPickFrame, "ListScrollFrameTemplate")

		local ChecksFrame_Update = function (self)
			--self = self or MacroPopupFrame;
			local numMacroIcons = #MACRO_ICON_FILENAMES;
			local macroPopupIcon, macroPopupButton;
			local macroPopupOffset = FauxScrollFrame_GetOffset (scroll);
			local index;
			
			-- Icon list
			local texture;
			for i = 1, 60 do
				macroPopupIcon = _G["DetailsIconPickFrameButton"..i];
				macroPopupButton = _G["DetailsIconPickFrameButton"..i];
				index = (macroPopupOffset * 10) + i;
				texture = MACRO_ICON_FILENAMES [index]
				if ( index <= numMacroIcons and texture ) then
					macroPopupButton:ChangeIcon ("INTERFACE\\ICONS\\"..texture, "INTERFACE\\ICONS\\"..texture, "INTERFACE\\ICONS\\"..texture, "INTERFACE\\ICONS\\"..texture)
					macroPopupButton.IconID = index
					macroPopupButton:Show();
				else
					macroPopupButton:Hide();
				end

			end
			
			-- Scrollbar stuff
			FauxScrollFrame_Update (scroll, ceil (numMacroIcons / 10) , 5, 20 );
		end
		
		
		scroll:SetPoint ("topleft", gump.IconPickFrame, "topleft", -18, -10)
		scroll:SetWidth (330)
		scroll:SetHeight (178)
		scroll:SetScript ("OnVerticalScroll", function (self, offset) FauxScrollFrame_OnVerticalScroll (scroll, offset, 20, ChecksFrame_Update) end)
		scroll.update = ChecksFrame_Update
		gump.IconPickFrameScroll = scroll
		gump.IconPickFrame:Hide()
		
	end
	
	gump.IconPickFrame:Show()
	gump.IconPickFrameScroll.update (gump.IconPickFrameScroll)
	gump.IconPickFrame.callback = callback or gump.IconPickFrame.emptyFunction
	
end	
