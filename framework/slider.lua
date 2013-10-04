--> details main objects
local _detalhes = 		_G._detalhes
local gump = 			_detalhes.gump

local _rawset = rawset --> lua local
local _rawget = rawget --> lua local
local _setmetatable = setmetatable --> lua local
local _unpack = unpack --> lua local
local _type = type --> lua local
local _math_floor = math.floor --> lua local
local loadstring = loadstring --> lua local

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
	local gmember_fractional = function (_object, _value)
		return _rawget (_object, "useDecimals")
	end	

	local get_members_function_index = {
		["tooltip"] = gmember_tooltip,
		["shown"] = gmember_shown,
		["width"] = gmember_width,
		["height"] = gmember_height,
		["locked"] = gmember_locked,
		["fractional"] = gmember_fractional,
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
	
	local set_members_function_index = {
		["tooltip"] = smember_tooltip,
		["show"] = smember_show,
		["hide"] = smember_hide,
		["backdrop"] = smember_backdrop,
		["width"] = smember_width,
		["height"] = smember_height,
		["locked"] = smember_locked,
		["fractional"] = smember_fractional,
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
	
		slider.thumb:SetAlpha (1)
	
		if (slider.MyObject.have_tooltip) then 
			GameCooltip:Reset()
			GameCooltip:AddLine (slider.MyObject.have_tooltip)
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
	
	local OnHide = function (slider)
		if (slider.MyObject.OnHideHook) then
			local interrupt = slider.MyObject.OnHideHook (slider)
			if (interrupt) then
				return
			end
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
	
	local OnValueChanged = function (slider)
	
		local amt = slider:GetValue()

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
		slider.MyObject.value = amt
	end
	
	

------------------------------------------------------------------------------------------------------------
--> object constructor

function gump:NewSwitch (parent, container, name, member, w, h, ltext, rtext, defaultv)

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
	
	if (type (defaultv) == "boolean" and not defaultv) then
		defaultv = 1
	elseif (type (defaultv) == "boolean" and defaultv) then
		defaultv = 2
	else
		defaultv = defaultv or 1
	end

--> build frames
	local slider = gump:NewSlider (parent, container, name, member, w, h, 1, 2, 1, defaultv)
	
	slider:SetBackdrop ({edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", edgeSize = 8,
	bgFile = [[Interface\AddOns\Details\images\background]], insets = {left = 3, right = 3, top = 5, bottom = 5}})
	
	slider:SetHook ("OnValueChange", function (self)
		if (slider:GetValue() == 1) then
			slider.amt:SetText (ltext)
			if (slider.OnSwitch) then
				slider.OnSwitch (slider, slider.FixedValue, false)
			end
			slider:SetBackdropColor (1, 0, 0, 0.4)
		else
			slider.amt:SetText (rtext)
			if (slider.OnSwitch) then
				slider.OnSwitch (slider, slider.FixedValue, true)
			end
			slider:SetBackdropColor (0, 0, 1, 0.4)
		end
		return true
	end)
	
	slider:SetValue (1)
	slider:SetValue (2)
	slider:SetValue (defaultv)
	
	slider.isSwitch = true
	
	return slider
end

function gump:NewSlider (parent, container, name, member, w, h, min, max, step, defaultv, isDecemal)
	
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
	SliderObject.value = defaultv
	
	--SliderObject.amt = _G [name .. "_Amt"]
	--SliderObject.lock = _G [name .. "_LockTexture"]
	--SliderObject.thumb = _G [name .. "_ThumbTexture"]
	
	SliderObject.slider:SetBackdrop ({edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", edgeSize = 8})
	SliderObject.slider:SetBackdropColor (0.9, 0.7, 0.7, 1.0)
	
	SliderObject.thumb = SliderObject.slider:CreateTexture (nil, "artwork")
	SliderObject.thumb:SetTexture ("Interface\\Buttons\\UI-ScrollBar-Knob")
	--SliderObject.thumb:SetSize (30, 24)
	SliderObject.thumb:SetSize (30+(h*0.2), h*1.2)
	SliderObject.thumb:SetAlpha (0.7)
	SliderObject.slider:SetThumbTexture (SliderObject.thumb)
	SliderObject.slider.thumb = SliderObject.thumb
	
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

	--> hooks
		SliderObject.slider:SetScript ("OnEnter", OnEnter)
		SliderObject.slider:SetScript ("OnLeave", OnLeave)
		SliderObject.slider:SetScript ("OnHide", OnHide)
		SliderObject.slider:SetScript ("OnShow", OnShow)
		SliderObject.slider:SetScript ("OnValueChanged", OnValueChanged)
		
	_setmetatable (SliderObject, SliderMetaFunctions)
	
	return SliderObject	
	
end