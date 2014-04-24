--> details main objects
local _detalhes = 		_G._detalhes
local gump = 			_detalhes.gump
local _
local _rawset = rawset --> lua local
local _rawget = rawget --> lua local
local _setmetatable = setmetatable --> lua local
local _unpack = unpack --> lua local
local _type = type --> lua local
local _math_floor = math.floor --> lua local
local loadstring = loadstring --> lua local

local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

local cleanfunction = function() end
local APISliderFunctions = false
local SliderMetaFunctions = {}

------------------------------------------------------------------------------------------------------------
--> metatables

	SliderMetaFunctions.__call = function (_table, value)
		if (not value) then
			if (_table.isSwitch) then
			
				if (type (value) == "boolean") then --> false
					return _table.slider:SetValue (1)
				end
			
				if (_table.slider:GetValue() == 1) then
					return false
				else
					return true
				end
			end
			return _table.slider:GetValue()
		else
			if (_table.isSwitch) then
				if (type (value) == "boolean") then
					if (value) then
						_table.slider:SetValue (2)
					else
						_table.slider:SetValue (1)
					end
				else
					_table.slider:SetValue (value)
				end
				return
			end
			
			return _table.slider:SetValue (value)
		end
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
	--> frame width
	local gmember_width = function (_object)
		return _object.slider:GetWidth()
	end
	--> frame height
	local gmember_height = function (_object)
		return _object.slider:GetHeight()
	end
	--> locked
	local gmember_locked = function (_object)
		return _rawget (_object, "lockdown")
	end
	--> fractional
	local gmember_fractional = function (_object)
		return _rawget (_object, "useDecimals")
	end	
	--> value
	local gmember_value = function (_object)
		return _object()
	end	

	local get_members_function_index = {
		["tooltip"] = gmember_tooltip,
		["shown"] = gmember_shown,
		["width"] = gmember_width,
		["height"] = gmember_height,
		["locked"] = gmember_locked,
		["fractional"] = gmember_fractional,
		["value"] = gmember_value,
	}

	SliderMetaFunctions.__index = function (_table, _member_requested)

		local func = get_members_function_index [_member_requested]
		if (func) then
			return func (_table, _member_requested)
		end
		
		local fromMe = _rawget (_table, _member_requested)
		if (fromMe) then
			return fromMe
		end
		
		return SliderMetaFunctions [_member_requested]
	end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
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
	--> frame width
	local smember_width = function (_object, _value)
		return _object.slider:SetWidth (_value)
	end
	--> frame height
	local smember_height = function (_object, _value)
		return _object.slider:SetHeight (_value)
	end
	--> locked
	local smember_locked = function (_object, _value)
		if (_value) then
			return self:Disable()
		else
			return self:Enable()
		end
	end	
	--> backdrop
	local smember_backdrop = function (_object, _value)
		return _object.slider:SetBackdrop (_value)
	end
	--> fractional
	local smember_fractional = function (_object, _value)
		return _rawset (_object, "useDecimals", _value)
	end
	--> value
	local smember_value = function (_object, _value)
		_object (_value)
	end
	
	local set_members_function_index = {
		["tooltip"] = smember_tooltip,
		["show"] = smember_show,
		["hide"] = smember_hide,
		["backdrop"] = smember_backdrop,
		["width"] = smember_width,
		["height"] = smember_height,
		["locked"] = smember_locked,
		["fractional"] = smember_fractional,
		["value"] = smember_value,
	}
	
	SliderMetaFunctions.__newindex = function (_table, _key, _value)
		local func = set_members_function_index [_key]
		if (func) then
			return func (_table, _value)
		else
			return _rawset (_table, _key, _value)
		end
	end	
	
------------------------------------------------------------------------------------------------------------
--> methods

--> show & hide
	function SliderMetaFunctions:IsShown()
		return self.slider:IsShown()
	end
	function SliderMetaFunctions:Show()
		return self.slider:Show()
	end
	function SliderMetaFunctions:Hide()
		return self.slider:Hide()
	end
	
--> fixed value
	function SliderMetaFunctions:SetFixedParameter (value)
		_rawset (self, "FixedValue", value)
	end
	
--> set value
	function SliderMetaFunctions:SetValue (value)
		return self (value)
	end
	
-- thumb size
	function SliderMetaFunctions:SetThumbSize (w, h)
		if (not w) then
			w = self.thumb:GetWidth()
		end
		if (not h) then
			h = self.thumb:GetHeight()
		end
		return self.thumb:SetSize (w, h)
	end	
	
	
-- setpoint
	function SliderMetaFunctions:SetPoint (v1, v2, v3, v4, v5)
		v1, v2, v3, v4, v5 = gump:CheckPoints (v1, v2, v3, v4, v5, self)
		if (not v1) then
			print ("Invalid parameter for SetPoint")
			return
		end
		return self.widget:SetPoint (v1, v2, v3, v4, v5)
	end

-- sizes
	function SliderMetaFunctions:SetSize (w, h)
		if (w) then
			self.slider:SetWidth (w)
		end
		if (h) then
			return self.slider:SetHeight (h)
		end
	end
	
-- tooltip
	function SliderMetaFunctions:SetTooltip (tooltip)
		if (tooltip) then
			return _rawset (self, "have_tooltip", tooltip)
		else
			return _rawset (self, "have_tooltip", nil)
		end
	end
	function SliderMetaFunctions:GetTooltip()
		return _rawget (self, "have_tooltip")
	end
	
-- frame levels
	function SliderMetaFunctions:GetFrameLevel()
		return self.slider:GetFrameLevel()
	end
	function SliderMetaFunctions:SetFrameLevel (level, frame)
		if (not frame) then
			return self.slider:SetFrameLevel (level)
		else
			local framelevel = frame:GetFrameLevel (frame) + level
			return self.slider:SetFrameLevel (framelevel)
		end
	end

-- frame stratas
	function SliderMetaFunctions:SetFrameStrata()
		return self.slider:GetFrameStrata()
	end
	function SliderMetaFunctions:SetFrameStrata (strata)
		if (_type (strata) == "table") then
			self.slider:SetFrameStrata (strata:GetFrameStrata())
		else
			self.slider:SetFrameStrata (strata)
		end
	end
	
-- enabled
	function SliderMetaFunctions:IsEnabled()
		return not _rawget (self, "lockdown")
	end
	function SliderMetaFunctions:Enable()
		self.slider:Enable()
		self.slider.lock:Hide()
		self.slider.amt:Show()
		return _rawset (self, "lockdown", false)
	end
	function SliderMetaFunctions:Disable()
		self.slider:Disable()
		self.slider.lock:Show()
		self.slider.amt:Hide()
		return _rawset (self, "lockdown", true)
	end

--> hooks
	function SliderMetaFunctions:SetHook (hookType, func)
		if (func) then
			_rawset (self, hookType.."Hook", func)
		else
			_rawset (self, hookType.."Hook", nil)
		end
	end

------------------------------------------------------------------------------------------------------------
--> scripts

	local OnEnter = function (slider)
	
		if (slider.MyObject.OnEnterHook) then
			local interrupt = slider.MyObject.OnEnterHook (slider)
			if (interrupt) then
				return
			end
		end
		
		DetailsFrameworkSliderButtons:ShowMe (slider)
	
		slider.thumb:SetAlpha (1)
	
		if (slider.MyObject.have_tooltip) then 
			_detalhes:CooltipPreset (1)
			GameCooltip:AddLine (slider.MyObject.have_tooltip)
			if (slider.MyObject.have_tooltip == Loc ["STRING_RIGHTCLICK_TYPEVALUE"]) then
				GameCooltip:AddIcon ([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 1, 1, 16, 16, 0.015625, 0.15671875, 0.640625, 0.798828125)
			end
			GameCooltip:ShowCooltip (slider, "tooltip")
		end
		
		local parent = slider:GetParent().MyObject
		if (parent and parent.type == "panel") then
			if (parent.GradientEnabled) then
				parent:RunGradient()
			end
		end
		
	end
	
	local OnLeave = function (slider)
		if (slider.MyObject.OnLeaveHook) then
			local interrupt = slider.MyObject.OnLeaveHook (slider)
			if (interrupt) then
				return
			end
		end
		
		DetailsFrameworkSliderButtons:PrepareToHide()
		
		slider.thumb:SetAlpha (.7)
	
		if (slider.MyObject.have_tooltip) then 
			_detalhes.popup:ShowMe (false)
		end
		
		local parent = slider:GetParent().MyObject
		if (parent and parent.type == "panel") then
			if (parent.GradientEnabled) then
				parent:RunGradient (false)
			end
		end
		
	end
	

	local f = CreateFrame ("frame", "DetailsFrameworkSliderButtons", UIParent)
	f:Hide()
	--f:SetBackdrop ({bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]], tile = true, tileSize = 5})
	f:SetHeight (18)
	
	local t = 0
	f.is_going_hide = false
	local going_hide = function (self, elapsed)
		t = t + elapsed
		if (t > 0.3) then
			f:Hide()
			f:SetScript ("OnUpdate", nil)
			f.is_going_hide = false
		end
	end
	
	function f:ShowMe (host)
		f:SetPoint ("bottomleft", host, "topleft", -3, -5)
		f:SetPoint ("bottomright", host, "topright", 3, -5)
		f:SetFrameStrata (host:GetFrameStrata())
		f:SetFrameLevel (host:GetFrameLevel())
		f:Show()
		if (f.is_going_hide) then
			f:SetScript ("OnUpdate", nil)
			f.is_going_hide = false
		end
		
		f.host = host.MyObject
	end
	
	function f:PrepareToHide()
		f.is_going_hide = true
		t = 0
		f:SetScript ("OnUpdate", going_hide)
	end
	
	local button_plus = CreateFrame ("button", "DetailsFrameworkSliderButtonsPlusButton", f)
	local button_minor = CreateFrame ("button", "DetailsFrameworkSliderButtonsMinorButton", f)
	
	button_plus:SetScript ("OnEnter", function (self)
		if (f.is_going_hide) then
			f:SetScript ("OnUpdate", nil)
			f.is_going_hide = false
		end
	end)
	button_minor:SetScript ("OnEnter", function (self)
		if (f.is_going_hide) then
			f:SetScript ("OnUpdate", nil)
			f.is_going_hide = false
		end
	end)
	
	button_plus:SetScript ("OnLeave", function (self)
		f:PrepareToHide()
	end)
	button_minor:SetScript ("OnLeave", function (self)
		f:PrepareToHide()
	end)
	
	button_plus:SetNormalTexture ([[Interface\Buttons\UI-PlusButton-Up]])
	button_minor:SetNormalTexture ([[Interface\Buttons\UI-MinusButton-Up]])
	
	button_plus:SetPushedTexture ([[Interface\Buttons\UI-PlusButton-Down]])
	button_minor:SetPushedTexture ([[Interface\Buttons\UI-MinusButton-Down]])
	
	button_plus:SetDisabledTexture ([[Interface\Buttons\UI-PlusButton-Disabled]])
	button_minor:SetDisabledTexture ([[Interface\Buttons\UI-MinusButton-Disabled]])
	
	button_plus:SetHighlightTexture ([[Interface\Buttons\UI-PlusButton-Hilight]])
	button_minor:SetHighlightTexture ([[Interface\Buttons\UI-PlusButton-Hilight]])
	
	--button_minor:SetPoint ("bottomleft", f, "bottomleft", -6, -13)
	--button_plus:SetPoint ("bottomright", f, "bottomright", 6, -13)
	
	button_minor:SetPoint ("bottomright", f, "bottomright", 13, -13)
	button_plus:SetPoint ("left", button_minor, "right", -2, 0)
	
	button_plus:SetSize (16, 16)
	button_minor:SetSize (16, 16)
	
	local timer = 0
	local change_timer = 0
	
	-- -- --
	
	local plus_button_script = function()

		local current = f.host.value
		local editbox = SliderMetaFunctions.editbox_typevalue
		
		if (f.host.fine_tuning) then
			f.host:SetValue (current + f.host.fine_tuning)
			if (editbox and SliderMetaFunctions.editbox_typevalue:IsShown()) then
				SliderMetaFunctions.editbox_typevalue:SetText (tostring (string.format ("%.1f", current + f.host.fine_tuning)))
			end
		else
			if (f.host.useDecimals) then
				f.host:SetValue (current + 0.1)
				if (editbox and SliderMetaFunctions.editbox_typevalue:IsShown()) then
					SliderMetaFunctions.editbox_typevalue:SetText (string.format ("%.1f", current + 0.1))
				end
			else
				f.host:SetValue (current + 1)
				if (editbox and SliderMetaFunctions.editbox_typevalue:IsShown()) then
					SliderMetaFunctions.editbox_typevalue:SetText (tostring (math.floor (current + 1)))
				end
			end
		end

	end
	
	button_plus:SetScript ("OnMouseUp", function (self)
		if (not button_plus.got_click) then
			plus_button_script()
		end
		button_plus.got_click = false
		self:SetScript ("OnUpdate", nil)
	end)
	
	local on_update = function (self, elapsed)
		timer = timer + elapsed
		if (timer > 0.4) then
			change_timer = change_timer + elapsed
			if (change_timer > 0.1) then
				change_timer = 0
				plus_button_script()
				button_plus.got_click = true
			end
		end
	end
	button_plus:SetScript ("OnMouseDown", function (self)
		timer = 0
		change_timer = 0
		self:SetScript ("OnUpdate", on_update)
	end)
	
	-- -- --
	
	local minor_button_script = function()
		local current = f.host.value
		local editbox = SliderMetaFunctions.editbox_typevalue
		
		if (f.host.fine_tuning) then
			f.host:SetValue (current - f.host.fine_tuning)
			if (editbox and SliderMetaFunctions.editbox_typevalue:IsShown()) then
				SliderMetaFunctions.editbox_typevalue:SetText (tostring (string.format ("%.1f", current - f.host.fine_tuning)))
			end
		else
			if (f.host.useDecimals) then
				f.host:SetValue (current - 0.1)
				if (editbox and SliderMetaFunctions.editbox_typevalue:IsShown()) then
					SliderMetaFunctions.editbox_typevalue:SetText (string.format ("%.1f", current - 0.1))
				end
			else
				f.host:SetValue (current - 1)
				if (editbox and SliderMetaFunctions.editbox_typevalue:IsShown()) then
					SliderMetaFunctions.editbox_typevalue:SetText (tostring (math.floor (current - 1)))
				end
			end
		end
	end
	
	button_minor:SetScript ("OnMouseUp", function (self)
		if (not button_minor.got_click) then
			minor_button_script()
		end
		button_minor.got_click = false
		self:SetScript ("OnUpdate", nil)
	end)
	
	local on_update = function (self, elapsed)
		timer = timer + elapsed
		if (timer > 0.4) then
			change_timer = change_timer + elapsed
			if (change_timer > 0.1) then
				change_timer = 0
				minor_button_script()
				button_minor.got_click = true
			end
		end
	end
	button_minor:SetScript ("OnMouseDown", function (self)
		timer = 0
		change_timer = 0
		self:SetScript ("OnUpdate", on_update)
	end)
	
	function SliderMetaFunctions:TypeValue()
		if (not self.isSwitch) then
		
			if (not SliderMetaFunctions.editbox_typevalue) then
			
				local editbox = CreateFrame ("EditBox", "DetailsFrameworkSliderEditBox", UIParent)
				
				editbox:SetSize (40, 20)
				editbox:SetJustifyH ("center")
				editbox:SetBackdrop ({bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]],
				edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", --edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
				tile = true, edgeSize = 8, tileSize = 5})
				editbox:SetFontObject ("GameFontHighlightSmall")

				editbox:SetScript ("OnEnterPressed", function()
					editbox:ClearFocus()
					editbox:Hide()
					editbox:GetParent().MyObject.typing_value = false
					editbox:GetParent().MyObject.value = tonumber (editbox:GetText())
				end)
				
				editbox:SetScript ("OnEscapePressed", function()
					editbox:ClearFocus()
					editbox:Hide()
					editbox:GetParent().MyObject.typing_value = false
					editbox:GetParent().MyObject.value = tonumber (self.typing_value_started)
				end)

				editbox:SetScript ("OnTextChanged", function()
					editbox:GetParent().MyObject.typing_can_change = true
					editbox:GetParent().MyObject.value = tonumber (editbox:GetText())
					editbox:GetParent().MyObject.typing_can_change = false
					
					-- esse self fica como o primeiro a ser alterado
					--print ("text changed", self:GetName())
					--print ()
				end)
				
				SliderMetaFunctions.editbox_typevalue = editbox
			end
			
			local pvalue = self.previous_value [2]
			self:SetValue (pvalue)
			
			self.typing_value = true
			self.typing_value_started = pvalue
			
			SliderMetaFunctions.editbox_typevalue:SetSize (self.width, self.height)
			SliderMetaFunctions.editbox_typevalue:SetPoint ("center", self.widget, "center")
			SliderMetaFunctions.editbox_typevalue:SetFocus()
			SliderMetaFunctions.editbox_typevalue:SetParent (self.widget)
			SliderMetaFunctions.editbox_typevalue:SetFrameLevel (self.widget:GetFrameLevel()+1)
			
			if (self.useDecimals) then
				SliderMetaFunctions.editbox_typevalue:SetText (tostring (string.format ("%.1f", self.value)))
			else
				SliderMetaFunctions.editbox_typevalue:SetText (tostring (math.floor (self.value)))
			end
			
			SliderMetaFunctions.editbox_typevalue:HighlightText()
			
			SliderMetaFunctions.editbox_typevalue:Show()
		end
	end
	
	local OnMouseDown = function (slider, button)
		if (button == "RightButton") then
			slider.MyObject:TypeValue()
		end
	end
	
	local OnMouseUp = function (slider, button)
		--if (button == "RightButton") then
		--	if (slider.MyObject.typing_value) then
		--		slider.MyObject:SetValue (slider.MyObject.previous_value [2])
		--	end
		--end
	end
	
	local OnHide = function (slider)
		if (slider.MyObject.OnHideHook) then
			local interrupt = slider.MyObject.OnHideHook (slider)
			if (interrupt) then
				return
			end
		end
		
		if (slider.MyObject.typing_value) then
			SliderMetaFunctions.editbox_typevalue:ClearFocus()
			SliderMetaFunctions.editbox_typevalue:SetText ("")
			slider.MyObject.typing_valu = false
		end
	end
	
	local OnShow = function (slider)
		if (slider.MyObject.OnShowHook) then
			local interrupt = slider.MyObject.OnShowHook (slider)
			if (interrupt) then
				return
			end
		end
	end
	
	local table_insert = table.insert
	local table_remove = table.remove
	
	local OnValueChanged = function (slider)
	
		local amt = slider:GetValue()
	
		if (slider.MyObject.typing_value and not slider.MyObject.typing_can_change) then
			slider.MyObject:SetValue (slider.MyObject.typing_value_started)
			return
		end

		table_insert (slider.MyObject.previous_value, 1, amt)
		table_remove (slider.MyObject.previous_value, 4)
		
		if (slider.MyObject.OnValueChangeHook) then
			local interrupt = slider.MyObject.OnValueChangeHook (slider, slider.MyObject.FixedValue, amt)
			if (interrupt) then
				return
			end
		end

		if (amt < 10 and amt >= 1) then
			amt = "0"..amt
		end
		
		if (slider.MyObject.useDecimals) then
			slider.amt:SetText (string.format ("%.1f", amt))
		else
			slider.amt:SetText (math.floor (amt))
		end
		slider.MyObject.ivalue = amt
	end

------------------------------------------------------------------------------------------------------------
--> object constructor

local SwitchOnClick = function (self, button, forced_value, value)

	local slider = self.MyObject
	
	if (forced_value) then
		rawset (slider, "value", not value)
	end

	if (rawget (slider, "value")) then --actived
	
		rawset (slider, "value", false)
		slider._text:SetText (slider._ltext)
		slider._thumb:ClearAllPoints()
		
		slider:SetBackdropColor (1, 0, 0, 0.4)
		slider._thumb:SetPoint ("left", slider.widget, "left")
	
	else
	
		rawset (slider, "value", true)
		slider._text:SetText (slider._rtext)
		slider._thumb:ClearAllPoints()

		slider:SetBackdropColor (0, 0, 1, 0.4)
		slider._thumb:SetPoint ("right", slider.widget, "right")

	end
	
	if (slider.OnSwitch and not forced_value) then
		local value = rawget (slider, "value")
		if (slider.return_func) then
			value = slider:return_func (value)
		end
		slider.OnSwitch (slider, slider.FixedValue, value)
	end
	
end

local default_switch_func = function (self, passed_value)
	if (self.value) then
		return false
	else
		return true
	end
end

local switch_get_value = function (self)
	return self.value
end

local switch_set_value = function (self, value)
	if (self.switch_func) then
		value = self:switch_func (value)
	end
	
	SwitchOnClick (self.widget, nil, true, value)
end

local switch_set_fixparameter = function (self, value)
	_rawset (self, "FixedValue", value)
end

function gump:NewSwitch (parent, container, name, member, w, h, ltext, rtext, default_value, color_inverted, switch_func, return_func)

--> early checks
	if (not name) then
		return nil
	elseif (not parent) then
		return nil
	end
	if (not container) then
		container = parent
	end

--> defaults
	ltext = ltext or "OFF"
	rtext = rtext or "ON"
	
--> build frames
	
	local slider = gump:NewButton (parent, container, name, member, w, h)
	
	slider.switch_func = switch_func
	slider.return_func = return_func
	slider.SetValue = switch_set_value
	slider.GetValue = switch_get_value
	slider.SetFixedParameter = switch_set_fixparameter
	
	if (member) then
		parent [member] = slider
	end
	
	slider:SetBackdrop ({edgeFile = [[Interface\Buttons\UI-SliderBar-Border]], edgeSize = 8,
	bgFile = [[Interface\AddOns\Details\images\background]], insets = {left = 3, right = 3, top = 5, bottom = 5}})
	
	local thumb = slider:CreateTexture (nil, "artwork")
	thumb:SetTexture ("Interface\\Buttons\\UI-ScrollBar-Knob")
	thumb:SetSize (34+(h*0.2), h*1.2)
	thumb:SetAlpha (0.7)
	thumb:SetPoint ("left", slider.widget, "left")
	
	local text = slider:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
	text:SetTextColor (.8, .8, .8, 1)
	text:SetPoint ("center", thumb, "center")
	
	slider._text = text
	slider._thumb = thumb
	slider._ltext = ltext
	slider._rtext = rtext
	slider.thumb = thumb

	slider.invert_colors = color_inverted
	
	slider:SetScript ("OnClick", SwitchOnClick)

	slider:SetValue (default_value)

	slider.isSwitch = true

	return slider
end

function gump:NewSlider (parent, container, name, member, w, h, min, max, step, defaultv, isDecemal, isSwitch)
	
--> early checks
	if (not name) then
		return nil
	elseif (not parent) then
		return nil
	end
	if (not container) then
		container = parent
	end
	
	if (name:find ("$parent")) then
		name = name:gsub ("$parent", parent:GetName())
	end
	
	local SliderObject = {type = "slider", dframework = true}
	
	if (member) then
		parent [member] = SliderObject
	end	
	
	if (parent.dframework) then
		parent = parent.widget
	end
	if (container.dframework) then
		container = container.widget
	end
	
--> defaults	
	min = min or 1
	max = max or 2
	step = step or 1
	defaultv = defaultv or min
	
	--> default members:
		--> hooks
		SliderObject.OnEnterHook = nil
		SliderObject.OnLeaveHook = nil
		SliderObject.OnHideHook = nil
		SliderObject.OnShowHook = nil
		SliderObject.OnValueChangeHook = nil
		--> misc
		SliderObject.lockdown = false
		SliderObject.container = container
		SliderObject.have_tooltip = nil
		SliderObject.FixedValue = nil
		SliderObject.useDecimals = isDecemal or false
		
	--SliderObject.slider = CreateFrame ("slider", name, parent, "DetailsSliderTemplate")
	SliderObject.slider = CreateFrame ("slider", name, parent)
	SliderObject.widget = SliderObject.slider

	if (not APISliderFunctions) then
		APISliderFunctions = true
		local idx = getmetatable (SliderObject.slider).__index
		for funcName, funcAddress in pairs (idx) do 
			if (not SliderMetaFunctions [funcName]) then
				SliderMetaFunctions [funcName] = function (object, ...)
					local x = loadstring ( "return _G."..object.slider:GetName()..":"..funcName.."(...)")
					return x (...)
				end
			end
		end
	end
	
	SliderObject.slider.MyObject = SliderObject
	SliderObject.slider:SetWidth (w or 232)
	SliderObject.slider:SetHeight (h or 20)
	SliderObject.slider:SetOrientation ("horizontal")
	SliderObject.slider:SetMinMaxValues (min, max)
	SliderObject.slider:SetValueStep (step)
	SliderObject.slider:SetValue (defaultv)
	SliderObject.ivalue = defaultv

	SliderObject.slider:SetBackdrop ({edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", edgeSize = 8})
	SliderObject.slider:SetBackdropColor (0.9, 0.7, 0.7, 1.0)

	SliderObject.thumb = SliderObject.slider:CreateTexture (nil, "artwork")
	SliderObject.thumb:SetTexture ("Interface\\Buttons\\UI-ScrollBar-Knob")
	SliderObject.thumb:SetSize (30+(h*0.2), h*1.2)
	SliderObject.thumb:SetAlpha (0.7)
	SliderObject.slider:SetThumbTexture (SliderObject.thumb)
	SliderObject.slider.thumb = SliderObject.thumb
	
	if (not isSwitch) then
		SliderObject.have_tooltip = Loc ["STRING_RIGHTCLICK_TYPEVALUE"]
	end
	
	SliderObject.amt = SliderObject.slider:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
	
	local amt = defaultv
	if (amt < 10 and amt >= 1) then
		amt = "0"..amt
	end
	
	if (SliderObject.useDecimals) then
		SliderObject.amt:SetText (string.format ("%.1f", amt))
	else
		SliderObject.amt:SetText (math.floor (amt))
	end
	
	SliderObject.amt:SetTextColor (.8, .8, .8, 1)
	SliderObject.amt:SetPoint ("center", SliderObject.thumb, "center")
	SliderObject.slider.amt = SliderObject.amt

	SliderObject.previous_value = {defaultv or 0, 0, 0}
	
	--> hooks
		SliderObject.slider:SetScript ("OnEnter", OnEnter)
		SliderObject.slider:SetScript ("OnLeave", OnLeave)
		SliderObject.slider:SetScript ("OnHide", OnHide)
		SliderObject.slider:SetScript ("OnShow", OnShow)
		SliderObject.slider:SetScript ("OnValueChanged", OnValueChanged)
		SliderObject.slider:SetScript ("OnMouseDown", OnMouseDown)
		SliderObject.slider:SetScript ("OnMouseUp", OnMouseUp)
		
		
	_setmetatable (SliderObject, SliderMetaFunctions)
	
	return SliderObject	
	
end