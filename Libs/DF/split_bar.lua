
local DF = _G ["DetailsFramework"]
if (not DF or not DetailsFrameworkCanLoad) then
	return 
end

local _
local _rawset = rawset --> lua local
local _rawget = rawget --> lua local
local _setmetatable = setmetatable --> lua local
local _unpack = unpack --> lua local
local _type = type --> lua local
local _math_floor = math.floor --> lua local

local cleanfunction = function() end
local SplitBarMetaFunctions = {}
local APISplitBarFunctions

------------------------------------------------------------------------------------------------------------
--> metatables

	SplitBarMetaFunctions.__call = function (_table, value)
		if (not value) then
			return _table.statusbar:GetValue()
		else
			_table.div:SetPoint ("left", _table.statusbar, "left", value * (_table.statusbar:GetWidth()/100) - 18, 0)
			return _table.statusbar:SetValue (value)
		end
	end

	SplitBarMetaFunctions.__add = function (v1, v2) 
		if (_type (v1) == "table") then
			local v = v1.statusbar:GetValue()
			v = v + v2
			v1.div:SetPoint ("left", v1.statusbar, "left", value * (v1.statusbar:GetWidth()/100) - 18, 0)
			v1.statusbar:SetValue (v)
		else
			local v = v2.statusbar:GetValue()
			v = v + v1
			v2.div:SetPoint ("left", v2.statusbar, "left", value * (v2.statusbar:GetWidth()/100) - 18, 0)
			v2.statusbar:SetValue (v)
		end
	end

	SplitBarMetaFunctions.__sub = function (v1, v2) 
		if (_type (v1) == "table") then
			local v = v1.statusbar:GetValue()
			v = v - v2
			v1.div:SetPoint ("left", v1.statusbar, "left", value * (v1.statusbar:GetWidth()/100) - 18, 0)
			v1.statusbar:SetValue (v)
		else
			local v = v2.statusbar:GetValue()
			v = v - v1
			v2.div:SetPoint ("left", v2.statusbar, "left", value * (v2.statusbar:GetWidth()/100) - 18, 0)
			v2.statusbar:SetValue (v)
		end
	end

------------------------------------------------------------------------------------------------------------
--> members

	--> tooltip
	local function gmember_tooltip (_object)
		return _object:GetTooltip()
	end
	--> shown
	local gmember_shown = function (_object)
		return _object.statusbar:IsShown()
	end
	--> frame width
	local gmember_width = function (_object)
		return _object.statusbar:GetWidth()
	end
	--> frame height
	local gmember_height = function (_object)
		return _object.statusbar:GetHeight()
	end
	--> value
	local gmember_value = function (_object)
		return _object.statusbar:GetValue()
	end
	--> right text
	local gmember_rtext = function (_object)
		return _object.textright:GetText()
	end
	--> left text
	local gmember_ltext = function (_object)
		return _object.textleft:GetText()
	end
	--> right color
	local gmember_rcolor = function (_object)
		return _object.background.original_colors
	end
	--> left color
	local gmember_lcolor = function (_object)
		return _object.texture.original_colors
	end
	--> right icon
	local gmember_ricon = function (_object)
		return _object.iconright:GetTexture()
	end
	--> left icon
	local gmember_licon = function (_object)
		return _object.iconleft:GetTexture()
	end
	--> texture
	local gmember_texture = function (_object)
		return _object.texture:GetTexture()
	end	
	--> font size
	local gmember_textsize = function (_object)
		local _, fontsize = _object.textleft:GetFont()
		return fontsize
	end
	--> font face
	local gmember_textfont = function (_object)
		local fontface = _object.textleft:GetFont()
		return fontface
	end
	--> font color
	local gmember_textcolor = function (_object)
		return _object.textleft:GetTextColor()
	end
	
	local get_members_function_index = {
		["tooltip"] = gmember_tooltip,
		["shown"] = gmember_shown,
		["width"] = gmember_width,
		["height"] = gmember_height,
		["value"] = gmember_value,
		["righttext"] = gmember_rtext,
		["lefttext"] = gmember_ltext,
		["rightcolor"] = gmember_rcolor,
		["leftcolor"] = gmember_lcolor,
		["righticon"] = gmember_ricon,
		["lefticon"] = gmember_licon,
		["texture"] = gmember_texture,
		["fontsize"] = gmember_textsize,
		["fontface"] = gmember_textfont,
		["fontcolor"] = gmember_textcolor,
		["textsize"] = gmember_textsize, --alias
		["textfont"] = gmember_textfont, --alias
		["textcolor"] = gmember_textcolor --alias
	}
	
	SplitBarMetaFunctions.__index = function (_table, _member_requested)

		local func = get_members_function_index [_member_requested]
		if (func) then
			return func (_table, _member_requested)
		end
		
		local fromMe = _rawget (_table, _member_requested)
		if (fromMe) then
			return fromMe
		end
		
		return SplitBarMetaFunctions [_member_requested]
	end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--> tooltip
	local smember_tooltip = function (_object, _value)
		return _object:SetTooltip (_value)
	end
	--> show
	local smember_shown = function (_object, _value)
		if (_value) then
			return _object:Show()
		else
			return _object:Hide()
		end
	end
	--> hide
	local smember_hide = function (_object, _value)
		if (_value) then
			return _object:Hide()
		else
			return _object:Show()
		end
	end
	--> width
	local smember_width = function (_object, _value)
		return _object.statusbar:SetWidth (_value)
	end
	--> height
	local smember_height = function (_object, _value)
		return _object.statusbar:SetHeight (_value)
	end
	--> statusbar value
	local smember_value = function (_object, _value)
		_object.statusbar:SetValue (_value)
		return _object.div:SetPoint ("left", _object.statusbar, "left", _value * (_object.statusbar:GetWidth()/100) - 18, 0)
	end
	--> right text
	local smember_rtext = function (_object, _value)
		return _object.textright:SetText (_value)
	end
	--> left text
	local smember_ltext = function (_object, _value)
		return _object.textleft:SetText (_value)
	end
	--> right color
	local smember_rcolor = function (_object, _value)
		local _value1, _value2, _value3, _value4 = DF:ParseColors (_value)
		_object.background.original_colors = {_value1, _value2, _value3, _value4}
		return _object.background:SetVertexColor (_value1, _value2, _value3, _value4)
	end
	--> left color
	local smember_lcolor = function (_object, _value)
		local _value1, _value2, _value3, _value4 = DF:ParseColors (_value)
		
		_object.statusbar:SetStatusBarColor (_value1, _value2, _value3, _value4)
		_object.texture.original_colors = {_value1, _value2, _value3, _value4}
		return _object.texture:SetVertexColor (_value1, _value2, _value3, _value4)
	end
	--> right icon
	local smember_ricon = function (_object, _value)
		if (type (_value) == "table") then
			local _value1, _value2 = _unpack (_value)
			_object.iconright:SetTexture (_value1)
			if (_value2) then
				_object.iconright:SetTexCoord (_unpack (_value2))
			end
		else
			_object.iconright:SetTexture (_value)
		end
		return
	end
	--> left icon
	local smember_licon = function (_object, _value)
		if (type (_value) == "table") then
			local _value1, _value2 = _unpack (_value)
			_object.iconleft:SetTexture (_value1)
			if (_value2) then
				_object.iconleft:SetTexCoord (_unpack (_value2))
			end
		else
			_object.iconleft:SetTexture (_value)
		end
		return
	end
	--> texture
	local smember_texture = function (_object, _value)
		if (type (_value) == "table") then
			local _value1, _value2 = _unpack (_value)
			_object.texture:SetTexture (_value1)
			_object.background:SetTexture (_value1)
			if (_value2) then
				_object.texture:SetTexCoord (_unpack (_value2))
				_object.background:SetTexCoord (_unpack (_value2))
			end
		else
			_object.texture:SetTexture (_value)
			_object.background:SetTexture (_value)
		end
		return
	end
	--> font face
	local smember_textfont = function (_object, _value)
		DF:SetFontFace (_object.textleft, _value)
		return DF:SetFontFace (_object.textright, _value)
	end
	--> font size
	local smember_textsize = function (_object, _value)
		DF:SetFontSize (_object.textleft, _value)
		return DF:SetFontSize (_object.textright, _value)
	end
	--> font color
	local smember_textcolor = function (_object, _value)
		local _value1, _value2, _value3, _value4 = DF:ParseColors (_value)
		_object.textleft:SetTextColor (_value1, _value2, _value3, _value4)
		return _object.textright:SetTextColor (_value1, _value2, _value3, _value4)
	end

	local set_members_function_index = {
		["tooltip"] = smember_tooltip,
		["shown"] = smember_shown,
		["width"] = smember_width,
		["height"] = smember_height,
		["value"] = smember_value,
		["righttext"] = smember_rtext,
		["lefttext"] = smember_ltext,
		["rightcolor"] = smember_rcolor,
		["leftcolor"] = smember_lcolor,
		["righticon"] = smember_ricon,
		["lefticon"] = smember_licon,
		["texture"] = smember_texture,
		["fontsize"] = smember_textsize,
		["fontface"] = smember_textfont,
		["fontcolor"] = smember_textcolor,
		["textsize"] = smember_textsize, --alias
		["textfont"] = smember_textfont, --alias
		["textcolor"] = smember_textcolor --alias
	}
	
	SplitBarMetaFunctions.__newindex = function (_table, _key, _value)
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
	function SplitBarMetaFunctions:Show()
		return self.statusbar:Show()
	end
	function SplitBarMetaFunctions:Hide()
		return self.statusbar:Hide()
	end

-- set split
	function SplitBarMetaFunctions:SetSplit (value)
		if (not value) then
			value = self.statusbar:GetValue()
		elseif (value < 0 or value > 100) then
			return
		end
		self.statusbar:SetValue (value)
		self.div:SetPoint ("left", self.statusbar, "left", value * (self.statusbar:GetWidth()/100) - 18, 0)
	end
	
-- setpoint
	function SplitBarMetaFunctions:SetPoint (v1, v2, v3, v4, v5)
		v1, v2, v3, v4, v5 = DF:CheckPoints (v1, v2, v3, v4, v5, self)
		if (not v1) then
			print ("Invalid parameter for SetPoint")
			return
		end
		return self.widget:SetPoint (v1, v2, v3, v4, v5)
	end
	
-- sizes
	function SplitBarMetaFunctions:SetSize (w, h)
		if (w) then
			self.statusbar:SetWidth (w)
		end
		if (h) then
			self.statusbar:SetHeight (h)
		end
	end
	
-- texture
	function SplitBarMetaFunctions:SetTexture (texture)
		self.background:SetTexture (texture)
		self.texture:SetTexture (texture)
	end
	
-- texts
	function SplitBarMetaFunctions:SetLeftText (text)
		self.textleft:SetText (text)
	end
	function SplitBarMetaFunctions:SetRightText (text)
		self.textright:SetText (text)
	end
	
-- colors
	function SplitBarMetaFunctions:SetLeftColor (r, g, b, a)
		r, g, b, a = DF:ParseColors (r, g, b, a)
		self.texture:SetVertexColor (r, g, b, a)
		self.texture.original_colors = {r, g, b, a}
	end
	function SplitBarMetaFunctions:SetRightColor (r, g, b, a)
		r, g, b, a = DF:ParseColors (r, g, b, a)
		self.background:SetVertexColor (r, g, b, a)
		self.background.original_colors = {r, g, b, a}
	end
	
-- icons
	function SplitBarMetaFunctions:SetLeftIcon (texture, ...)
		self.iconleft:SetTexture (texture)
		if (...) then
			local L, R, U, D = unpack (...)
			self.iconleft:SetTexCoord (L, R, U, D)
		end
	end
	function SplitBarMetaFunctions:SetRightIcon (texture, ...)
		self.iconright:SetTexture (texture)
		if (...) then
			local L, R, U, D = unpack (...)
			self.iconright:SetTexCoord (L, R, U, D)
		end
	end

-- tooltip
	function SplitBarMetaFunctions:SetTooltip (tooltip)
		if (tooltip) then
			return _rawset (self, "have_tooltip", tooltip)
		else
			return _rawset (self, "have_tooltip", nil)
		end
	end
	function SplitBarMetaFunctions:GetTooltip()
		return _rawget (self, "have_tooltip")
	end
	
-- frame levels
	function SplitBarMetaFunctions:GetFrameLevel()
		return self.statusbar:GetFrameLevel()
	end
	function SplitBarMetaFunctions:SetFrameLevel (level, frame)
		if (not frame) then
			return self.statusbar:SetFrameLevel (level)
		else
			local framelevel = frame:GetFrameLevel (frame) + level
			return self.statusbar:SetFrameLevel (framelevel)
		end
	end

-- frame stratas
	function SplitBarMetaFunctions:SetFrameStrata()
		return self.statusbar:GetFrameStrata()
	end
	function SplitBarMetaFunctions:SetFrameStrata (strata)
		if (_type (strata) == "table") then
			self.statusbar:SetFrameStrata (strata:GetFrameStrata())
		else
			self.statusbar:SetFrameStrata (strata)
		end
	end

--> hooks
	function SplitBarMetaFunctions:SetHook (hookType, func)
		if (func) then
			_rawset (self, hookType.."Hook", func)
		else
			_rawset (self, hookType.."Hook", nil)
		end
	end

------------------------------------------------------------------------------------------------------------
--> scripts
	local OnEnter = function (frame)
		if (frame.MyObject.OnEnterHook) then
			local interrupt = frame.MyObject.OnEnterHook (frame)
			if (interrupt) then
				return
			end
		end

		frame.MyObject.div:SetPoint ("left", frame, "left", frame:GetValue() * (frame:GetWidth()/100) - 18, 0)
		
		if (frame.MyObject.have_tooltip) then
			GameCooltip2:Reset()
			GameCooltip2:AddLine (frame.MyObject.have_tooltip)
			GameCooltip2:ShowCooltip (frame, "tooltip")
		end
	end
	
	local OnLeave = function (frame)
		if (frame.MyObject.OnLeaveHook) then
			local interrupt = frame.MyObject.OnLeaveHook (frame)
			if (interrupt) then
				return
			end
		end

		if (frame.MyObject.have_tooltip) then 
			DF.popup:ShowMe (false)
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
		
		if (not frame.MyObject.container.isLocked and frame.MyObject.container:IsMovable()) then
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
		
		if (frame.MyObject.container.isMoving) then
			frame.MyObject.container:StopMovingOrSizing()
			frame.MyObject.container.isMoving = false
		end
	end
	
	local OnSizeChanged = function (statusbar)
		statusbar.MyObject.div:SetPoint ("left", statusbar, "left", statusbar:GetValue() * (statusbar:GetWidth()/100) - 18, 0)
	end

------------------------------------------------------------------------------------------------------------
--> object constructor

function DetailsFrameworkSplitlBar_OnCreate (self)
	self.texture.original_colors = {1, 1, 1, 1}
	self.background.original_colors = {.5, .5, .5, 1}
	self.spark:SetPoint ("left", self, "left", self:GetValue() * (self:GetWidth()/100) - 18, 0)
	return true
end

function DF:CreateSplitBar (parent, parent, w, h, member, name)
	return DF:NewSplitBar (parent, container, name, member, w, h)
end

function DF:NewSplitBar (parent, container, name, member, w, h)
	
	if (not name) then
		name = "DetailsFrameworkSplitbar" .. DF.SplitBarCounter
		DF.SplitBarCounter = DF.SplitBarCounter + 1
	end
	if (not parent) then
		return error ("Details! FrameWork: parent not found.", 2)
	end
	if (not container) then
		container = parent
	end
	
	if (name:find ("$parent")) then
		local parentName = DF.GetParentName (parent)
		name = name:gsub ("$parent", parentName)
	end
	
	local SplitBarObject = {type = "barsplit", dframework = true}

	if (member) then
		parent [member] = SplitBarObject
	end
	
	if (parent.dframework) then
		parent = parent.widget
	end
	if (container.dframework) then
		container = container.widget
	end

	--> default members:
		--> hooks
		SplitBarObject.OnEnterHook = nil
		SplitBarObject.OnLeaveHook = nil
		SplitBarObject.OnHideHook = nil
		SplitBarObject.OnShowHook = nil
		SplitBarObject.OnMouseDownHook = nil
		SplitBarObject.OnMouseUpHook = nil
		--> misc
		SplitBarObject.tooltip = nil
		SplitBarObject.locked = false
		SplitBarObject.have_tooltip = nil
		SplitBarObject.container = container
	
	--> create widgets
		SplitBarObject.statusbar = CreateFrame ("statusbar", name, parent, "DetailsFrameworkSplitBarTemplate")
		SplitBarObject.widget = SplitBarObject.statusbar
		
		if (not APISplitBarFunctions) then
			APISplitBarFunctions = true
			local idx = getmetatable (SplitBarObject.statusbar).__index
			for funcName, funcAddress in pairs (idx) do 
				if (not SplitBarMetaFunctions [funcName]) then
					SplitBarMetaFunctions [funcName] = function (object, ...)
						local x = loadstring ( "return _G['"..object.statusbar:GetName().."']:"..funcName.."(...)")
						return x (...)
					end
				end
			end
		end
		
		SplitBarObject.statusbar:SetHeight (h or 200)
		SplitBarObject.statusbar:SetWidth (w or 14)

		SplitBarObject.statusbar.MyObject = SplitBarObject
		
		SplitBarObject.textleft = _G [name .. "_TextLeft"]
		SplitBarObject.textright = _G [name .. "_TextRight"]
		
		SplitBarObject.iconleft = _G [name .. "_IconLeft"]
		SplitBarObject.iconright = _G [name .. "_IconRight"]
		
		SplitBarObject.background = _G [name .. "_StatusBarBackground"]
		SplitBarObject.texture = _G [name .. "_StatusBarTexture"]
		
		SplitBarObject.div = _G [name .. "_Spark"]

		
	--> hooks
		SplitBarObject.statusbar:SetScript ("OnEnter", OnEnter)
		SplitBarObject.statusbar:SetScript ("OnLeave", OnLeave)
		SplitBarObject.statusbar:SetScript ("OnHide", OnHide)
		SplitBarObject.statusbar:SetScript ("OnShow", OnShow)
		SplitBarObject.statusbar:SetScript ("OnMouseDown", OnMouseDown)
		SplitBarObject.statusbar:SetScript ("OnMouseUp", OnMouseUp)
		SplitBarObject.statusbar:SetScript ("OnSizeChanged", OnSizeChanged)
		
	_setmetatable (SplitBarObject, SplitBarMetaFunctions)
	
	return SplitBarObject
end