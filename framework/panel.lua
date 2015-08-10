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

simple_panel_counter = 1

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
	function PanelMetaFunctions:CreateRightClickLabel (textType, w, h, close_text)
		local text
		w = w or 20
		h = h or 20
		
		if (close_text) then
			text = close_text
		else
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
			local interrupt = frame.MyObject.OnEnterHook (frame, frame.MyObject)
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
			local interrupt = frame.MyObject.OnLeaveHook (frame, frame.MyObject)
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
			local interrupt = frame.MyObject.OnHideHook (frame, frame.MyObject)
			if (interrupt) then
				return
			end
		end
	end
	
	local OnShow = function (frame)
		if (frame.MyObject.OnShowHook) then
			local interrupt = frame.MyObject.OnShowHook (frame, frame.MyObject)
			if (interrupt) then
				return
			end
		end
	end
	
	local OnMouseDown = function (frame, button)
		if (frame.MyObject.OnMouseDownHook) then
			local interrupt = frame.MyObject.OnMouseDownHook (frame, button, frame.MyObject)
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
			local interrupt = frame.MyObject.OnMouseUpHook (frame, button, frame.MyObject)
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
function gump:CreatePanel (parent, w, h, backdrop, backdropcolor, bordercolor, member, name)
	return gump:NewPanel (parent, parent, name, member, w, h, backdrop, backdropcolor, bordercolor)
end

function gump:NewPanel (parent, container, name, member, w, h, backdrop, backdropcolor, bordercolor)

	if (not name) then
		name = "DetailsPanelNumber" .. gump.PanelCounter
		gump.PanelCounter = gump.PanelCounter + 1

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

------------fill panel

local button_on_enter = function (self)
	self.MyObject._icon:SetBlendMode ("ADD")
end
local button_on_leave = function (self)
	self.MyObject._icon:SetBlendMode ("BLEND")
end

local add_row = function (self, t, need_update)
	local index = #self.rows+1
	
	local thisrow = gump:NewPanel (self, self, "$parentHeader_" .. self._name .. index, nil, 1, 20)
	thisrow.backdrop = {bgFile = [[Interface\DialogFrame\UI-DialogBox-Gold-Background]]}
	thisrow.color = "silver"
	thisrow.type = t.type
	thisrow.func = t.func
	thisrow.name = t.name
	thisrow.notext = t.notext
	thisrow.icon = t.icon
	thisrow.iconalign = t.iconalign
	
	thisrow.hidden = t.hidden or false
	
	local text = gump:NewLabel (thisrow, nil, self._name .. "$parentLabel" .. index, "text")
	text:SetPoint ("left", thisrow, "left", 2, 0)
	text:SetText (t.name)

	tinsert (self._raw_rows, t)
	tinsert (self.rows, thisrow)
	
	if (need_update) then
		self:AlignRows()
	end
end

local align_rows = function (self)

	local rows_shown = 0
	for index, row in ipairs (self.rows) do
		if (not row.hidden) then
			rows_shown = rows_shown + 1
		end
	end

	local cur_width = 0
	local row_width = self._width / rows_shown
	local sindex = 1
	
	wipe (self._anchors)
	
	for index, row in ipairs (self.rows) do
		if (not row.hidden) then
			if (self._autowidth) then
				--row:SetWidth (row_width)
				if (self._raw_rows [index].width) then
					row.width = self._raw_rows [index].width
				else
					row.width = row_width
				end
				row:SetPoint ("topleft", self, "topleft", cur_width, 0)
				tinsert (self._anchors, cur_width)
				cur_width = cur_width + row_width + 1
			else
				row:SetPoint ("topleft", self, "topleft", cur_width, 0)
				row.width = self._raw_rows [index].width
				tinsert (self._anchors, cur_width)
				cur_width = cur_width + self._raw_rows [index].width + 1
			end
			row:Show()

			local type = row.type

			if (type == "text") then
				for i = 1, #self.scrollframe.lines do
					local line = self.scrollframe.lines [i]
					local text = tremove (line.text_available)
					if (not text) then
						self:CreateRowText (line)
						text = tremove (line.text_available)
					end
					tinsert (line.text_inuse, text)
					text:SetPoint ("left", line, "left", self._anchors [#self._anchors], 0)
					text:SetWidth (row.width)
				end
			elseif (type == "entry") then
				for i = 1, #self.scrollframe.lines do
					local line = self.scrollframe.lines [i]
					local entry = tremove (line.entry_available)
					if (not entry) then
						self:CreateRowEntry (line)
						entry = tremove (line.entry_available)
					end
					tinsert (line.entry_inuse, entry)
					entry:SetPoint ("left", line, "left", self._anchors [#self._anchors], 0)
					if (sindex == rows_shown) then
						entry:SetWidth (row.width - 25)
					else
						entry:SetWidth (row.width)
					end
					entry.func = row.func
				end
			elseif (type == "button") then
				for i = 1, #self.scrollframe.lines do
					local line = self.scrollframe.lines [i]
					local button = tremove (line.button_available)
					if (not button) then
						self:CreateRowButton (line)
						button = tremove (line.button_available)
					end
					tinsert (line.button_inuse, button)
					button:SetPoint ("left", line, "left", self._anchors [#self._anchors], 0)
					if (sindex == rows_shown) then
						button:SetWidth (row.width - 25)
					else
						button:SetWidth (row.width)
					end
					
					if (row.icon) then
						button._icon.texture = row.icon
						button._icon:ClearAllPoints()
						if (row.iconalign) then
							if (row.iconalign == "center") then
								button._icon:SetPoint ("center", button, "center")
							elseif (row.iconalign == "right") then
								button._icon:SetPoint ("right", button, "right")
							end
						else
							button._icon:SetPoint ("left", button, "left")
						end
					end
					
					if (row.name and not row.notext) then
						button._text:SetPoint ("left", button._icon, "right", 2, 0)
						button._text.text = row.name
					end					
					
				end
			elseif (type == "icon") then
				for i = 1, #self.scrollframe.lines do
					local line = self.scrollframe.lines [i]
					local icon = tremove (line.icon_available)
					if (not icon) then
						self:CreateRowIcon (line)
						icon = tremove (line.icon_available)
					end
					tinsert (line.icon_inuse, icon)
					icon:SetPoint ("left", line, "left", self._anchors [#self._anchors] + ( ((row.width or 22) - 22) / 2), 0)
					icon.func = row.func
				end
			end
			
			sindex = sindex + 1
		else
			row:Hide()
		end
	end
	
	if (#self.rows > 0) then
		if (self._autowidth) then
			self.rows [#self.rows]:SetWidth (row_width - rows_shown + 1)
		else
			self.rows [#self.rows]:SetWidth (self._raw_rows [rows_shown].width - rows_shown + 1)
		end
	end
	
	self.showing_amt = rows_shown
end

local update_rows = function (self, updated_rows)
	for i = 1, #updated_rows do
		local t = updated_rows [i]
		local raw = self._raw_rows [i]
		
		if (not raw) then
			self:AddRow (t)
		else
			raw.name = t.name
			raw.hidden = t.hidden or false
			
			local widget = self.rows [i]
			widget.name = t.name
			widget.hidden = t.hidden or false
			
			widget.text:SetText (t.name)
		end
	end
	
	for i = #updated_rows+1, #self._raw_rows do
		local raw = self._raw_rows [i]
		local widget = self.rows [i]
		raw.hidden = true
		widget.hidden = true
	end
	
	for index, row in ipairs (self.scrollframe.lines) do
		for i = #row.text_inuse, 1, -1 do
			tinsert (row.text_available, tremove (row.text_inuse, i))
		end
		for i = 1, #row.text_available do
			row.text_available[i]:Hide()
		end
		
		for i = #row.entry_inuse, 1, -1 do
			tinsert (row.entry_available, tremove (row.entry_inuse, i))
		end
		for i = 1, #row.entry_available do
			row.entry_available[i]:Hide()
		end
		
		for i = #row.button_inuse, 1, -1 do
			tinsert (row.button_available, tremove (row.button_inuse, i))
		end
		for i = 1, #row.button_available do
			row.button_available[i]:Hide()
		end
		
		for i = #row.icon_inuse, 1, -1 do
			tinsert (row.icon_available, tremove (row.icon_inuse, i))
		end
		for i = 1, #row.icon_available do
			row.icon_available[i]:Hide()
		end
	end
	
	self:AlignRows()

end

local create_panel_text = function (self, row)
	row.text_total = row.text_total + 1
	local text = gump:NewLabel (row, nil, self._name .. "$parentLabel" .. row.text_total, "text" .. row.text_total)
	tinsert (row.text_available, text)
end

local create_panel_entry = function (self, row)
	row.entry_total = row.entry_total + 1
	local editbox = gump:NewTextEntry (row, nil, "$parentEntry" .. row.entry_total, "entry", 120, 20)
	editbox.align = "left"
	
	editbox:SetHook ("OnEnterPressed", function()
		editbox.widget.focuslost = true
		editbox:ClearFocus()
		editbox.func (editbox.index, editbox.text)
		return true
	end) 
	
	editbox:SetBackdrop ({bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]], edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1})
	editbox:SetBackdropColor (1, 1, 1, 0.1)
	editbox:SetBackdropBorderColor (1, 1, 1, 0.1)
	editbox.editbox.current_bordercolor = {1, 1, 1, 0.1}
	
	tinsert (row.entry_available, editbox)
end

local create_panel_button = function (self, row)
	row.button_total = row.button_total + 1
	local button = gump:NewButton (row, nil, "$parentButton" .. row.button_total, "button" .. row.button_total, 120, 20)
	button:InstallCustomTexture()

	--> create icon and the text
	local icon = gump:NewImage (button, nil, 20, 20)
	local text = gump:NewLabel (button)
	
	button._icon = icon
	button._text = text

	button:SetHook ("OnEnter", button_on_enter)
	button:SetHook ("OnLeave", button_on_leave)
	
	tinsert (row.button_available, button)
end

local icon_onclick = function (texture, iconbutton)
	iconbutton._icon.texture = texture
	iconbutton.func (iconbutton.index, texture)
end

local create_panel_icon = function (self, row)
	row.icon_total = row.icon_total + 1
	local iconbutton = gump:NewButton (row, nil, "$parentIconButton" .. row.icon_total, "iconbutton", 22, 20)
	iconbutton:InstallCustomTexture()
	
	iconbutton:SetHook ("OnEnter", button_on_enter)
	iconbutton:SetHook ("OnLeave", button_on_leave)
	
	iconbutton:SetHook ("OnMouseUp", function()
		gump:IconPick (icon_onclick, true, iconbutton)
		return true
	end)
	
	local icon = gump:NewImage (iconbutton, nil, 20, 20, "artwork", nil, "_icon", "$parentIcon" .. row.icon_total)
	iconbutton._icon = icon

	icon:SetPoint ("center", iconbutton, "center", 0, 0)

	tinsert (row.icon_available, iconbutton)
end

local set_fill_function = function (self, func)
	self._fillfunc = func
end
local set_total_function = function (self, func)
	self._totalfunc = func
end
local drop_header_function = function (self)
	wipe (self.rows)
end
 -- ~fillpanel
function gump:NewFillPanel (parent, rows, name, member, w, h, total_lines, fill_row, autowidth, options)
	
	local panel = gump:NewPanel (parent, parent, name, member, w, h)
	panel.backdrop = nil
	
	options = options or {rowheight = 20}
	panel.rows = {}
	
	panel.AddRow = add_row
	panel.AlignRows = align_rows
	panel.UpdateRows = update_rows
	panel.CreateRowText = create_panel_text
	panel.CreateRowEntry = create_panel_entry
	panel.CreateRowButton = create_panel_button
	panel.CreateRowIcon = create_panel_icon
	panel.SetFillFunction = set_fill_function
	panel.SetTotalFunction = set_total_function
	panel.DropHeader = drop_header_function
	
	panel._name = name
	panel._width = w
	panel._height = h
	panel._raw_rows = {}
	panel._anchors = {}
	panel._fillfunc = fill_row
	panel._totalfunc = total_lines
	panel._autowidth = autowidth
	
	for index, t in ipairs (rows) do 
		panel.AddRow (panel, t)
	end
	
	local refresh_fillbox = function (self)
	
		local offset = FauxScrollFrame_GetOffset (self)
		local filled_lines = panel._totalfunc (panel)		
	
		for index = 1, #self.lines do
	
			local row = self.lines [index]
			if (index <= filled_lines) then

				local real_index = index + offset
				local results = panel._fillfunc (real_index, panel)
				
				if (results [1]) then
					row:Show()

					local text, entry, button, icon = 1, 1, 1, 1
					
					for index, t in ipairs (panel.rows) do
						if (not t.hidden) then
							if (t.type == "text") then
								local fontstring = row.text_inuse [text]
								text = text + 1
								fontstring:SetText (results [index])
								fontstring.index = real_index
								fontstring:Show()

							elseif (t.type == "entry") then
								local entrywidget = row.entry_inuse [entry]
								entry = entry + 1
								entrywidget:SetText (results [index])
								entrywidget.index = real_index
								entrywidget:Show()
								
							elseif (t.type == "button") then
								local buttonwidget = row.button_inuse [button]
								button = button + 1
								buttonwidget.index = real_index
							
								local func = function()
									t.func (real_index, index)
									panel:Refresh()
								end
								buttonwidget:SetClickFunction (func)
							
								if (type (results [index]) == "table") then
									if (results [index].text) then
										buttonwidget:SetText (results [index].text)
									end
									
									if (results [index].icon) then
										buttonwidget._icon:SetTexture (results [index].icon)
									end
									
									if (results [index].func) then
										buttonwidget:SetClickFunction (results [index].func, real_index, results [index].value)
									end
								else
									buttonwidget:SetText (results [index])
								end
								
								buttonwidget:Show()
								
							elseif (t.type == "icon") then
								local iconwidget = row.icon_inuse [icon]
								icon = icon + 1
								
								iconwidget.line = index
								iconwidget.index = real_index
								
								local result = results [index]:gsub (".-%\\", "")
								iconwidget._icon.texture = results [index]
								
								iconwidget:Show()
							end
						end
					end

				else
					row:Hide()
				end
			else
				row:Hide()
			end
		end
	end
	
	function panel:Refresh()
		local filled_lines = panel._totalfunc (panel)
		local scroll_total_lines = #panel.scrollframe.lines
		local line_height = options.rowheight
		refresh_fillbox (panel.scrollframe)
		FauxScrollFrame_Update (panel.scrollframe, filled_lines, scroll_total_lines, line_height)
	end
	
	local scrollframe = CreateFrame ("scrollframe", name .. "Scroll", panel.widget, "FauxScrollFrameTemplate")
	scrollframe:SetScript ("OnVerticalScroll", function (self, offset) FauxScrollFrame_OnVerticalScroll (self, offset, 20, panel.Refresh) end)
	scrollframe:SetPoint ("topleft", panel.widget, "topleft", 0, -21)
	scrollframe:SetPoint ("topright", panel.widget, "topright", -23, -21)
	scrollframe:SetPoint ("bottomleft", panel.widget, "bottomleft")
	scrollframe:SetPoint ("bottomright", panel.widget, "bottomright", -23, 0)
	scrollframe:SetSize (w, h)
	panel.scrollframe = scrollframe
	scrollframe.lines = {}
	
	--create lines
	local size = options.rowheight
	local amount = math.floor (((h-21) / size))
	
	for i = 1, amount do
		--local row = gump:NewPanel (panel, nil, , nil, 1, size)
		local row = CreateFrame ("frame", panel:GetName() .. "Row_" .. i, panel.widget)
		row:SetSize (1, size)
		row.color = {1, 1, 1, .2}
		
		row:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]]})
		
		if (i%2 == 0) then
			row:SetBackdropColor (.5, .5, .5, 0.2)
		else
			row:SetBackdropColor (1, 1, 1, 0.00)
		end
		
		row:SetPoint ("topleft", scrollframe, "topleft", 0, (i-1) * size * -1)
		row:SetPoint ("topright", scrollframe, "topright", 0, (i-1) * size * -1)
		tinsert (scrollframe.lines, row)
		
		row.text_available = {}
		row.text_inuse = {}
		row.text_total = 0
		
		row.entry_available = {}
		row.entry_inuse = {}
		row.entry_total = 0
		
		row.button_available = {}
		row.button_inuse = {}
		row.button_total = 0
		
		row.icon_available = {}
		row.icon_inuse = {}
		row.icon_total = 0
	end
	
	panel.AlignRows (panel)
	
	return panel
end


------------color pick
local color_pick_func = function()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	local a = OpacitySliderFrame:GetValue()
	ColorPickerFrame:dcallback (r, g, b, a, ColorPickerFrame.dframe)
end
local color_pick_func_cancel = function()
	ColorPickerFrame:SetColorRGB (unpack (ColorPickerFrame.previousValues))
	local r, g, b = ColorPickerFrame:GetColorRGB()
	local a = OpacitySliderFrame:GetValue()
	ColorPickerFrame:dcallback (r, g, b, a, ColorPickerFrame.dframe)
end

function gump:ColorPick (frame, r, g, b, alpha, callback)

	ColorPickerFrame:ClearAllPoints()
	ColorPickerFrame:SetPoint ("bottomleft", frame, "topright", 0, 0)
	
	ColorPickerFrame.dcallback = callback
	ColorPickerFrame.dframe = frame
	
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
function gump:IconPick (callback, close_when_select, param1, param2)

	if (not gump.IconPickFrame) then 
	
		local string_lower = string.lower
	
		gump.IconPickFrame = CreateFrame ("frame", "DetailsIconPickFrame", UIParent)
		tinsert (UISpecialFrames, "DetailsIconPickFrame")
		gump.IconPickFrame:SetFrameStrata ("DIALOG")
		
		gump.IconPickFrame:SetPoint ("center", UIParent, "center")
		gump.IconPickFrame:SetWidth (350)
		gump.IconPickFrame:SetHeight (227)
		gump.IconPickFrame:EnableMouse (true)
		gump.IconPickFrame:SetMovable (true)
		gump.IconPickFrame:SetBackdrop ({bgFile = "Interface\\AddOns\\Details\\images\\background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true, tileSize = 32, edgeSize = 32, insets = {left = 5, right = 5, top = 5, bottom = 5}})
		
		--local title = gump.IconPickFrame:CreateTitleRegion()
		
		gump.IconPickFrame:SetBackdropBorderColor (170/255, 170/255, 170/255)
		gump.IconPickFrame:SetBackdropColor (24/255, 24/255, 24/255, .8)
		gump.IconPickFrame:SetFrameLevel (1)
		
		gump.IconPickFrame.emptyFunction = function() end
		gump.IconPickFrame.callback = gump.IconPickFrame.emptyFunction
		
		gump.IconPickFrame.preview =  CreateFrame ("frame", nil, UIParent)
		gump.IconPickFrame.preview:SetFrameStrata ("tooltip")
		gump.IconPickFrame.preview:SetSize (76, 76)
		local preview_image = gump:NewImage (gump.IconPickFrame.preview, nil, 76, 76)
		preview_image:SetAllPoints (gump.IconPickFrame.preview)
		gump.IconPickFrame.preview.icon = preview_image
		gump.IconPickFrame.preview:Hide()
		
		gump.IconPickFrame.searchLabel =  gump:NewLabel (gump.IconPickFrame, nil, "$parentSearchBoxLabel", nil, "search:")
		gump.IconPickFrame.searchLabel:SetPoint ("topleft", gump.IconPickFrame, "topleft", 12, -20)
		gump.IconPickFrame.search = gump:NewTextEntry (gump.IconPickFrame, nil, "$parentSearchBox", nil, 140, 20)
		gump.IconPickFrame.search:SetPoint ("left", gump.IconPickFrame.searchLabel, "right", 2, 0)
		gump.IconPickFrame.search:SetHook ("OnTextChanged", function() 
			gump.IconPickFrame.searching = gump.IconPickFrame.search:GetText()
			if (gump.IconPickFrame.searching == "") then
				gump.IconPickFrameScroll:Show()
				gump.IconPickFrame.searching = nil
				gump.IconPickFrame.updateFunc()
			else
				gump.IconPickFrameScroll:Hide()
				FauxScrollFrame_SetOffset (gump.IconPickFrame, 1)
				gump.IconPickFrame.last_filter_index = 1
				gump.IconPickFrame.updateFunc()
			end
		end)
		
		--> close button
		local close_button = CreateFrame ("button", nil, gump.IconPickFrame, "UIPanelCloseButton")
		close_button:SetWidth (32)
		close_button:SetHeight (32)
		close_button:SetPoint ("TOPRIGHT", gump.IconPickFrame, "TOPRIGHT", -8, -7)
		close_button:SetFrameLevel (close_button:GetFrameLevel()+2)
		
		local MACRO_ICON_FILENAMES = {}
		gump.IconPickFrame:SetScript ("OnShow", function()
		
			MACRO_ICON_FILENAMES = {};
			MACRO_ICON_FILENAMES[1] = "INV_MISC_QUESTIONMARK";
			local index = 2;
		
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
			
			GetLooseMacroItemIcons (MACRO_ICON_FILENAMES)
			GetLooseMacroIcons (MACRO_ICON_FILENAMES)
			GetMacroIcons (MACRO_ICON_FILENAMES)
			GetMacroItemIcons (MACRO_ICON_FILENAMES )
			
		end)
		
		gump.IconPickFrame:SetScript ("OnHide", function()
			MACRO_ICON_FILENAMES = nil;
			collectgarbage()
		end)
		
		gump.IconPickFrame.buttons = {}
		
		local OnClickFunction = function (self) 
			gump.IconPickFrame.callback (self.icon:GetTexture(), gump.IconPickFrame.param1, gump.IconPickFrame.param2)
			if (gump.IconPickFrame.click_close) then
				close_button:Click()
			end
		end
		
		local onenter = function (self)
			gump.IconPickFrame.preview:SetPoint ("bottom", self, "top", 0, 2)
			gump.IconPickFrame.preview.icon:SetTexture (self.icon:GetTexture())
			gump.IconPickFrame.preview:Show()
			self.icon:SetBlendMode ("ADD")
		end
		local onleave = function (self)
			gump.IconPickFrame.preview:Hide()
			self.icon:SetBlendMode ("BLEND")
		end
		
		local backdrop = {bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16,
		insets = {left = 0, right = 0, top = 0, bottom = 0}, edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]], edgeSize = 10}
		
		for i = 0, 9 do 
			local newcheck = CreateFrame ("Button", "DetailsIconPickFrameButton"..(i+1), gump.IconPickFrame)
			local image = newcheck:CreateTexture ("DetailsIconPickFrameButton"..(i+1).."Icon", "overlay")
			newcheck.icon = image
			image:SetPoint ("topleft", newcheck, "topleft", 2, -2); image:SetPoint ("bottomright", newcheck, "bottomright", -2, 2)
			newcheck:SetSize (30, 28)
			newcheck:SetBackdrop (backdrop)
			
			newcheck:SetScript ("OnClick", OnClickFunction)
			newcheck.param1 = i+1
			
			newcheck:SetPoint ("topleft", gump.IconPickFrame, "topleft", 12 + (i*30), -40)
			newcheck:SetID (i+1)
			gump.IconPickFrame.buttons [#gump.IconPickFrame.buttons+1] = newcheck
			newcheck:SetScript ("OnEnter", onenter)
			newcheck:SetScript ("OnLeave", onleave)
		end
		for i = 11, 20 do
			local newcheck = CreateFrame ("Button", "DetailsIconPickFrameButton"..i, gump.IconPickFrame)
			local image = newcheck:CreateTexture ("DetailsIconPickFrameButton"..i.."Icon", "overlay")
			newcheck.icon = image
			image:SetPoint ("topleft", newcheck, "topleft", 2, -2); image:SetPoint ("bottomright", newcheck, "bottomright", -2, 2)
			newcheck:SetSize (30, 28)
			newcheck:SetBackdrop (backdrop)
			
			newcheck:SetScript ("OnClick", OnClickFunction)
			newcheck.param1 = i
			
			newcheck:SetPoint ("topleft", "DetailsIconPickFrameButton"..(i-10), "bottomleft", 0, -1)
			newcheck:SetID (i)
			gump.IconPickFrame.buttons [#gump.IconPickFrame.buttons+1] = newcheck
			newcheck:SetScript ("OnEnter", onenter)
			newcheck:SetScript ("OnLeave", onleave)
		end
		for i = 21, 30 do 
			local newcheck = CreateFrame ("Button", "DetailsIconPickFrameButton"..i, gump.IconPickFrame)
			local image = newcheck:CreateTexture ("DetailsIconPickFrameButton"..i.."Icon", "overlay")
			newcheck.icon = image
			image:SetPoint ("topleft", newcheck, "topleft", 2, -2); image:SetPoint ("bottomright", newcheck, "bottomright", -2, 2)
			newcheck:SetSize (30, 28)
			newcheck:SetBackdrop (backdrop)
			
			newcheck:SetScript ("OnClick", OnClickFunction)
			newcheck.param1 = i
			
			newcheck:SetPoint ("topleft", "DetailsIconPickFrameButton"..(i-10), "bottomleft", 0, -1)
			newcheck:SetID (i)
			gump.IconPickFrame.buttons [#gump.IconPickFrame.buttons+1] = newcheck
			newcheck:SetScript ("OnEnter", onenter)
			newcheck:SetScript ("OnLeave", onleave)
		end
		for i = 31, 40 do 
			local newcheck = CreateFrame ("Button", "DetailsIconPickFrameButton"..i, gump.IconPickFrame)
			local image = newcheck:CreateTexture ("DetailsIconPickFrameButton"..i.."Icon", "overlay")
			newcheck.icon = image
			image:SetPoint ("topleft", newcheck, "topleft", 2, -2); image:SetPoint ("bottomright", newcheck, "bottomright", -2, 2)
			newcheck:SetSize (30, 28)
			newcheck:SetBackdrop (backdrop)
			
			newcheck:SetScript ("OnClick", OnClickFunction)
			newcheck.param1 = i
			
			newcheck:SetPoint ("topleft", "DetailsIconPickFrameButton"..(i-10), "bottomleft", 0, -1)
			newcheck:SetID (i)
			gump.IconPickFrame.buttons [#gump.IconPickFrame.buttons+1] = newcheck
			newcheck:SetScript ("OnEnter", onenter)
			newcheck:SetScript ("OnLeave", onleave)
		end
		for i = 41, 50 do 
			local newcheck = CreateFrame ("Button", "DetailsIconPickFrameButton"..i, gump.IconPickFrame)
			local image = newcheck:CreateTexture ("DetailsIconPickFrameButton"..i.."Icon", "overlay")
			newcheck.icon = image
			image:SetPoint ("topleft", newcheck, "topleft", 2, -2); image:SetPoint ("bottomright", newcheck, "bottomright", -2, 2)
			newcheck:SetSize (30, 28)
			newcheck:SetBackdrop (backdrop)
			
			newcheck:SetScript ("OnClick", OnClickFunction)
			newcheck.param1 = i
			
			newcheck:SetPoint ("topleft", "DetailsIconPickFrameButton"..(i-10), "bottomleft", 0, -1)
			newcheck:SetID (i)
			gump.IconPickFrame.buttons [#gump.IconPickFrame.buttons+1] = newcheck
			newcheck:SetScript ("OnEnter", onenter)
			newcheck:SetScript ("OnLeave", onleave)
		end
		for i = 51, 60 do 
			local newcheck = CreateFrame ("Button", "DetailsIconPickFrameButton"..i, gump.IconPickFrame)
			local image = newcheck:CreateTexture ("DetailsIconPickFrameButton"..i.."Icon", "overlay")
			newcheck.icon = image
			image:SetPoint ("topleft", newcheck, "topleft", 2, -2); image:SetPoint ("bottomright", newcheck, "bottomright", -2, 2)
			newcheck:SetSize (30, 28)
			newcheck:SetBackdrop (backdrop)
			
			newcheck:SetScript ("OnClick", OnClickFunction)
			newcheck.param1 = i
			
			newcheck:SetPoint ("topleft", "DetailsIconPickFrameButton"..(i-10), "bottomleft", 0, -1)
			newcheck:SetID (i)
			gump.IconPickFrame.buttons [#gump.IconPickFrame.buttons+1] = newcheck
			newcheck:SetScript ("OnEnter", onenter)
			newcheck:SetScript ("OnLeave", onleave)
		end
		
		local scroll = CreateFrame ("ScrollFrame", "DetailsIconPickFrameScroll", gump.IconPickFrame, "ListScrollFrameTemplate")

		local ChecksFrame_Update = function (self)

			local numMacroIcons = #MACRO_ICON_FILENAMES
			local macroPopupIcon, macroPopupButton
			local macroPopupOffset = FauxScrollFrame_GetOffset (scroll)
			local index

			local texture
			local filter
			if (gump.IconPickFrame.searching) then
				filter = string_lower (gump.IconPickFrame.searching)
			end
			
			if (filter and filter ~= "") then
				
				local ignored = 0
				local tryed = 0
				local found = 0
				local type = type
				local buttons = gump.IconPickFrame.buttons
				index = 1
				
				for i = 1, 60 do
					
					macroPopupIcon = buttons[i].icon
					macroPopupButton = buttons[i]

					for o = index, numMacroIcons do
					
						tryed = tryed + 1
					
						texture = MACRO_ICON_FILENAMES [o]
						if (type (texture) == "number") then
							macroPopupIcon:SetToFileData (texture)
							texture = macroPopupIcon:GetTexture()
							macroPopupIcon:SetTexture (nil)
						else
							texture = "INTERFACE\\ICONS\\" .. texture
						end
						
						if (texture and texture:find (filter)) then
							macroPopupIcon:SetTexture (texture)
							macroPopupButton:Show()
							found = found + 1
							gump.IconPickFrame.last_filter_index = o
							index = o+1
							break
						else
							ignored = ignored + 1
						end
						
					end
				end
			
				for o = found+1, 60 do
					macroPopupButton = _G ["DetailsIconPickFrameButton"..o]
					macroPopupButton:Hide()
				end
			else
				for i = 1, 60 do
					macroPopupIcon = _G ["DetailsIconPickFrameButton"..i.."Icon"]
					macroPopupButton = _G ["DetailsIconPickFrameButton"..i]
					index = (macroPopupOffset * 10) + i
					texture = MACRO_ICON_FILENAMES [index]
					if ( index <= numMacroIcons and texture ) then

						if (type (texture) == "number") then
							macroPopupIcon:SetToFileData (texture)
						else
							macroPopupIcon:SetTexture ("INTERFACE\\ICONS\\" .. texture)
						end

						macroPopupIcon:SetTexCoord (4/64, 60/64, 4/64, 60/64)
						macroPopupButton.IconID = index
						macroPopupButton:Show()
					else
						macroPopupButton:Hide()
					end
				end
			end
			
			-- Scrollbar stuff
			FauxScrollFrame_Update (scroll, ceil (numMacroIcons / 10) , 5, 20 )
		end

		gump.IconPickFrame.updateFunc = ChecksFrame_Update
		
		scroll:SetPoint ("topleft", gump.IconPickFrame, "topleft", -18, -37)
		scroll:SetWidth (330)
		scroll:SetHeight (178)
		scroll:SetScript ("OnVerticalScroll", function (self, offset) FauxScrollFrame_OnVerticalScroll (scroll, offset, 20, ChecksFrame_Update) end)
		scroll.update = ChecksFrame_Update
		gump.IconPickFrameScroll = scroll
		gump.IconPickFrame:Hide()
		
	end
	
	gump.IconPickFrame.param1, gump.IconPickFrame.param2 = param1, param2
	
	gump.IconPickFrame:Show()
	gump.IconPickFrameScroll.update (gump.IconPickFrameScroll)
	gump.IconPickFrame.callback = callback or gump.IconPickFrame.emptyFunction
	gump.IconPickFrame.click_close = close_when_select
	
end	

local simple_panel_counter = 1
local simple_panel_mouse_down = function (self, button)
	if (button == "RightButton") then
		if (self.IsMoving) then
			self.IsMoving = false
			self:StopMovingOrSizing()
		end
		self:Hide()
		return
	end
	self.IsMoving = true
	self:StartMoving()
end
local simple_panel_mouse_up = function (self, button)
	if (self.IsMoving) then
		self.IsMoving = false
		self:StopMovingOrSizing()
	end
end
local simple_panel_settitle = function (self, title)
	self.title:SetText (title)
end

function gump:CreateSimplePanel (parent, w, h, title, name)
	
	if (not name) then
		name = "DetailsSimplePanel" .. simple_panel_counter
		simple_panel_counter = simple_panel_counter + 1
	end
	if (not parent) then
		parent = UIParent
	end

	local f = CreateFrame ("frame", name, UIParent)
	f:SetSize (w or 400, h or 250)
	f:SetPoint ("center", UIParent, "center", 0, 0)
	f:SetFrameStrata ("FULLSCREEN")
	f:EnableMouse()
	f:SetMovable (true)
	tinsert (UISpecialFrames, name)

	f:SetScript ("OnMouseDown", simple_panel_mouse_down)
	f:SetScript ("OnMouseUp", simple_panel_mouse_up)

	f:SetBackdrop ({bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]], tile = true, tileSize = 128, insets = {left=3, right=3, top=3, bottom=3},
	edgeFile = [[Interface\AddOns\Details\images\border_welcome]], edgeSize = 16})
	f:SetBackdropColor (1, 1, 1, 0.75)
	
	local close = CreateFrame ("button", name .. "Close", f, "UIPanelCloseButton")
	close:SetSize (32, 32)
	close:SetPoint ("topright", f, "topright", 0, -12)

	f.title = gump:CreateLabel (f, title or "", 12, nil, "GameFontNormal")
	f.title:SetPoint ("top", f, "top", 0, -22)
	
	f.SetTitle = simple_panel_settitle
	
	simple_panel_counter = simple_panel_counter + 1
	
	return f
end


------------------------------------------------------------------------------------------------------------------------------------------------
--> chart panel

local chart_panel_backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 32, insets = {left = 5, right = 5, top = 5, bottom = 5}}

local chart_panel_align_timelabels = function (self, elapsed_time)

	self.TimeScale = elapsed_time

	local linha = self.TimeLabels [17]
	local minutos, segundos = math.floor (elapsed_time / 60), math.floor (elapsed_time % 60)
	if (segundos < 10) then
		segundos = "0" .. segundos
	end
	
	if (minutos > 0) then
		if (minutos < 10) then
			minutos = "0" .. minutos
		end
		linha:SetText (minutos .. ":" .. segundos)
	else
		linha:SetText ("00:" .. segundos)
	end
	
	local time_div = elapsed_time / 16 --786 -- 49.125
	
	for i = 2, 16 do
	
		local linha = self.TimeLabels [i]
		
		local this_time = time_div * (i-1)
		local minutos, segundos = math.floor (this_time / 60), math.floor (this_time % 60)
		
		if (segundos < 10) then
			segundos = "0" .. segundos
		end
		
		if (minutos > 0) then
			if (minutos < 10) then
				minutos = "0" .. minutos
			end
			linha:SetText (minutos .. ":" .. segundos)
		else
			linha:SetText ("00:" .. segundos)
		end
		
	end
	
end

local chart_panel_set_scale = function (self, amt, func, text)
	if (type (amt) ~= "number") then
		return
	end
	
	local piece = amt / 8
	
	for i = 1, 8 do
		if (func) then
			self ["dpsamt" .. math.abs (i-9)]:SetText ( func (piece*i) .. (text or ""))
		else
			self ["dpsamt" .. math.abs (i-9)]:SetText ( floor (piece*i) .. (text or ""))
		end
	end
end

local chart_panel_can_move = function (self, can)
	self.can_move = can
end

local chart_panel_overlay_reset = function (self)
	self.OverlaysAmount = 1
	for index, pack in ipairs (self.Overlays) do
		for index2, texture in ipairs (pack) do
			texture:Hide()
		end
	end
end

local chart_panel_reset = function (self)

	self.Graphic:ResetData()
	self.Graphic.max_value = 0
	
	self.TimeScale = nil
	self.BoxLabelsAmount = 1
	table.wipe (self.GData)
	table.wipe (self.OData)
	
	for index, box in ipairs (self.BoxLabels) do
		box.check:Hide()
		box.button:Hide()
		box.box:Hide()
		box.text:Hide()
		box.border:Hide()
		box.showing = false
	end
	
	chart_panel_overlay_reset (self)
end

local chart_panel_enable_line = function (f, thisbox)

	local index = thisbox.index
	local type = thisbox.type
	
	if (thisbox.enabled) then
		--disable
		thisbox.check:Hide()
		thisbox.enabled = false
	else
		--enable
		thisbox.check:Show()
		thisbox.enabled = true
	end
	
	if (type == "graphic") then
	
		f.Graphic:ResetData()
		f.Graphic.max_value = 0
		
		local max = 0
		local max_time = 0
		
		for index, box in ipairs (f.BoxLabels) do
			if (box.type == type and box.showing and box.enabled) then
				local data = f.GData [index]
				
				f.Graphic:AddDataSeries (data[1], data[2], nil, data[3])
				
				if (data[4] > max) then
					max = data[4]
				end
				if (data [5] > max_time) then
					max_time = data [5]
				end
			end
		end
		
		f:SetScale (max)
		f:SetTime (max_time)
		
	elseif (type == "overlay") then

		chart_panel_overlay_reset (f)
		
		for index, box in ipairs (f.BoxLabels) do
			if (box.type == type and box.showing and box.enabled) then
				
				f:AddOverlay (box.index)
				
			end
		end
	
	end
end

local create_box = function (self, next_box)

	local thisbox = {}
	self.BoxLabels [next_box] = thisbox
	
	local box = gump:NewImage (self.Graphic, nil, 16, 16, "border")
	local text = gump:CreateLabel (self.Graphic, nil, nil, nil, "GameFontNormal")
	
	local border = gump:NewImage (self.Graphic, [[Interface\DialogFrame\UI-DialogBox-Gold-Corner]], 30, 30, "artwork")
	border:SetPoint ("center", box, "center", -3, -4)
	
	local checktexture = gump:NewImage (self.Graphic, [[Interface\Buttons\UI-CheckBox-Check]], 18, 18, "overlay")
	checktexture:SetPoint ("center", box, "center", -1, -1)
	
	thisbox.box = box
	thisbox.text = text
	thisbox.border = border
	thisbox.check = checktexture
	thisbox.enabled = true

	local button = gump:CreateButton (self.Graphic, chart_panel_enable_line, 20, 20, "", self, thisbox)
	button:SetPoint ("center", box, "center")
	
	thisbox.button = button
	
	thisbox.box:SetPoint ("right", text, "left", -4, 0)
	
	if (next_box == 1) then
		thisbox.text:SetPoint ("topright", self, "topright", -35, -16)
	else
		thisbox.text:SetPoint ("right", self.BoxLabels [next_box-1].box, "left", -7, 0)
	end

	return thisbox
	
end

local realign_labels = function (self)
	
	local width = self:GetWidth() - 108
	
	local first_box = self.BoxLabels [1]
	first_box.text:SetPoint ("topright", self, "topright", -35, -16)
	
	local line_width = first_box.text:GetStringWidth() + 26
	
	for i = 2, #self.BoxLabels do
	
		local box = self.BoxLabels [i]
		
		if (box.box:IsShown()) then
		
			line_width = line_width + box.text:GetStringWidth() + 26
			
			if (line_width > width) then
				line_width = box.text:GetStringWidth() + 26
				box.text:SetPoint ("topright", self, "topright", -35, -40)
			else
				box.text:SetPoint ("right", self.BoxLabels [i-1].box, "left", -7, 0)
			end
		else
			break
		end
	end
	
end

local chart_panel_add_label = function (self, color, name, type, number)

	local next_box = self.BoxLabelsAmount
	local thisbox = self.BoxLabels [next_box]
	
	if (not thisbox) then
		thisbox = create_box (self, next_box)
	end
	
	self.BoxLabelsAmount = self.BoxLabelsAmount + 1

	thisbox.type = type
	thisbox.index = number

	thisbox.box:SetTexture (unpack (color))
	thisbox.text:SetText (name)
	
	thisbox.check:Show()
	thisbox.button:Show()
	thisbox.border:Show()
	thisbox.box:Show()
	thisbox.text:Show()

	thisbox.showing = true
	thisbox.enabled = true
	
	realign_labels (self)
	
end

local line_default_color = {1, 1, 1}
local draw_overlay = function (self, this_overlay, overlayData, color)

	local pixel = self.Graphic:GetWidth() / self.TimeScale
	local index = 1
	local r, g, b = unpack (color)
	
	for i = 1, #overlayData, 2 do
		local aura_start = overlayData [i]
		local aura_end = overlayData [i+1]
		
		local this_block = this_overlay [index]
		if (not this_block) then
			this_block = self.Graphic:CreateTexture (nil, "border")
			tinsert (this_overlay, this_block)
		end
		this_block:SetHeight (self.Graphic:GetHeight())
		
		this_block:SetPoint ("left", self.Graphic, "left", pixel * aura_start, 0)
		if (aura_end) then
			this_block:SetWidth ((aura_end-aura_start)*pixel)
		else
			--malformed table
			this_block:SetWidth (pixel*5)
		end
		
		this_block:SetTexture (r, g, b, 0.25)
		this_block:Show()
		
		index = index + 1
	end

end

local chart_panel_add_overlay = function (self, overlayData, color, name, icon)

	if (not self.TimeScale) then
		error ("Use SetTime (time) before adding an overlay.")
	end

	if (type (overlayData) == "number") then
		local overlay_index = overlayData
		draw_overlay (self, self.Overlays [self.OverlaysAmount], self.OData [overlay_index][1], self.OData [overlay_index][2])
	else
		local this_overlay = self.Overlays [self.OverlaysAmount]
		if (not this_overlay) then
			this_overlay = {}
			tinsert (self.Overlays, this_overlay)
		end

		draw_overlay (self, this_overlay, overlayData, color)

		tinsert (self.OData, {overlayData, color or line_default_color})
		if (name) then
			self:AddLabel (color or line_default_color, name, "overlay", #self.OData)
		end
	end

	self.OverlaysAmount = self.OverlaysAmount + 1
end

local SMA_table = {}
local SMA_max = 0
local reset_SMA = function()
	table.wipe (SMA_table)
	SMA_max = 0
end

local calc_SMA
calc_SMA = function (a, b, ...)
	if (b) then 
		return calc_SMA (a + b, ...) 
	else 
		return a
	end 
end

local do_SMA = function (value, max_value)

	if (#SMA_table == 10) then 
		tremove (SMA_table, 1)
	end
	
	SMA_table [#SMA_table + 1] = value
	
	local new_value = calc_SMA (unpack (SMA_table)) / #SMA_table
	
	if (new_value > SMA_max) then
		SMA_max = new_value
		return new_value, SMA_max
	else
		return new_value
	end
	
end

local chart_panel_add_data = function (self, graphicData, color, name, elapsed_time, lineTexture, smoothLevel, firstIndex)

	local f = self
	self = self.Graphic
	
	local _data = {}
	local max_value = graphicData.max_value
	local amount = #graphicData
	
	local scaleW = 1/self:GetWidth()

	local content = graphicData
	tinsert (content, 1, 0)
	tinsert (content, 1, 0)
	tinsert (content, #content+1, 0)
	tinsert (content, #content+1, 0)
	
	local _i = 3
	
	local graphMaxDps = math.max (self.max_value, max_value)
	
	if (not smoothLevel) then
		while (_i <= #content-2) do 
			local v = (content[_i-2]+content[_i-1]+content[_i]+content[_i+1]+content[_i+2])/5 --> normalize
			_data [#_data+1] = {scaleW*(_i-2), v/graphMaxDps} --> x and y coords
			_i = _i + 1
		end
	
	elseif (smoothLevel == "SHORT") then
		while (_i <= #content-2) do 
			local value = (content[_i] + content[_i+1]) / 2
			_data [#_data+1] = {scaleW*(_i-2), value}
			_data [#_data+1] = {scaleW*(_i-2), value}
			_i = _i + 2
		end
	
	elseif (smoothLevel == "SMA") then
		reset_SMA()
		while (_i <= #content-2) do 
			local value, is_new_max_value = do_SMA (content[_i], max_value)
			if (is_new_max_value) then
				max_value = is_new_max_value
			end
			_data [#_data+1] = {scaleW*(_i-2), value} --> x and y coords
			_i = _i + 1
		end
	
	elseif (smoothLevel == -1) then
		while (_i <= #content-2) do
			local current = content[_i]
			
			local minus_2 = content[_i-2] * 0.6
			local minus_1 = content[_i-1] * 0.8
			local plus_1 = content[_i+1] * 0.8
			local plus_2 = content[_i+2] * 0.6
			
			local v = (current + minus_2 + minus_1 + plus_1 + plus_2)/5 --> normalize
			_data [#_data+1] = {scaleW*(_i-2), v/graphMaxDps} --> x and y coords
			_i = _i + 1
		end
	
	elseif (smoothLevel == 1) then
		_i = 2
		while (_i <= #content-1) do 
			local v = (content[_i-1]+content[_i]+content[_i+1])/3 --> normalize
			_data [#_data+1] = {scaleW*(_i-1), v/graphMaxDps} --> x and y coords
			_i = _i + 1
		end
		
	elseif (smoothLevel == 2) then
		_i = 1
		while (_i <= #content) do 
			local v = content[_i] --> do not normalize
			_data [#_data+1] = {scaleW*(_i), v/graphMaxDps} --> x and y coords
			_i = _i + 1
		end
		
	end
	
	tremove (content, 1)
	tremove (content, 1)
	tremove (content, #graphicData)
	tremove (content, #graphicData)

	if (max_value > self.max_value) then 
		--> normalize previous data
		if (self.max_value > 0) then
			local normalizePercent = self.max_value / max_value
			for dataIndex, Data in ipairs (self.Data) do 
				local Points = Data.Points
				for i = 1, #Points do 
					Points[i][2] = Points[i][2]*normalizePercent
				end
			end
		end
	
		self.max_value = max_value
		f:SetScale (max_value)
	end
	
	tinsert (f.GData, {_data, color or line_default_color, lineTexture, max_value, elapsed_time})
	if (name) then
		f:AddLabel (color or line_default_color, name, "graphic", #f.GData)
	end
	
	if (firstIndex) then
		if (lineTexture) then
			if (not lineTexture:find ("\\") and not lineTexture:find ("//")) then 
				local path = string.match (debugstack (1, 1, 0), "AddOns\\(.+)LibGraph%-2%.0%.lua")
				if path then
					lineTexture = "Interface\\AddOns\\" .. path .. lineTexture
				else
					lineTexture = nil
				end
			end
		end
		
		table.insert (self.Data, 1, {Points = _data, Color = color or line_default_color, lineTexture = lineTexture, ElapsedTime = elapsed_time})
		self.NeedsUpdate = true
	else
		self:AddDataSeries (_data, color or line_default_color, nil, lineTexture)
		self.Data [#self.Data].ElapsedTime = elapsed_time
	end
	
	local max_time = 0
	for _, data in ipairs (self.Data) do
		if (data.ElapsedTime > max_time) then
			max_time = data.ElapsedTime
		end
	end
	
	f:SetTime (max_time)
	
end

local chart_panel_onresize = function (self)
	local width, height = self:GetSize()
	local spacement = width - 78 - 60
	spacement = spacement / 16
	
	for i = 1, 17 do
		local label = self.TimeLabels [i]
		label:SetPoint ("bottomleft", f, "bottomleft", 78 + ((i-1)*spacement), 13)
		label.line:SetHeight (height - 45)
	end
	
	local spacement = (self.Graphic:GetHeight()) / 8
	for i = 1, 8 do
		self ["dpsamt"..i]:SetPoint ("TOPLEFT", self, "TOPLEFT", 27, -25 + (-(spacement* (i-1))) )
		self ["dpsamt"..i].line:SetWidth (width-20)
	end
	
	self.Graphic:SetSize (width - 135, height - 67)
	self.Graphic:SetPoint ("topleft", self, "topleft", 108, -35)
end

local chart_panel_vlines_on = function (self)
	for i = 1, 17 do
		local label = self.TimeLabels [i]
		label.line:Show()
	end
end

local chart_panel_vlines_off = function (self)
	for i = 1, 17 do
		local label = self.TimeLabels [i]
		label.line:Hide()
	end
end

local chart_panel_set_title = function (self, title)
	self.chart_title.text = title
end

local chart_panel_mousedown = function (self, button)
	if (button == "LeftButton" and self.can_move) then
		if (not self.isMoving) then
			self:StartMoving()
			self.isMoving = true
		end
	elseif (button == "RightButton" and not self.no_right_click_close) then
		if (not self.isMoving) then
			self:Hide()
		end
	end
end
local chart_panel_mouseup = function (self, button)
	if (button == "LeftButton" and self.isMoving) then
		self:StopMovingOrSizing()
		self.isMoving = nil
	end
end

local chart_panel_hide_close_button = function (self)
	self.CloseButton:Hide()
end

local chart_panel_right_click_close = function (self, value)
	if (type (value) == "boolean") then
		if (value) then
			self.no_right_click_close = nil
		else
			self.no_right_click_close = true
		end
	end
end

function gump:CreateChartPanel (parent, w, h, name)

	if (not name) then
		name = "DetailsPanelNumber" .. gump.PanelCounter
		gump.PanelCounter = gump.PanelCounter + 1
	end
	
	parent = parent or UIParent
	w = w or 800
	h = h or 500

	local f = CreateFrame ("frame", name, parent)
	f:SetSize (w or 500, h or 400)
	f:EnableMouse (true)
	f:SetMovable (true)
	
	f:SetScript ("OnMouseDown", chart_panel_mousedown)
	f:SetScript ("OnMouseUp", chart_panel_mouseup)

	f:SetBackdrop (chart_panel_backdrop)
	f:SetBackdropColor (.3, .3, .3, .3)

	local c = CreateFrame ("Button", nil, f, "UIPanelCloseButton")
	c:SetWidth (32)
	c:SetHeight (32)
	c:SetPoint ("TOPRIGHT",  f, "TOPRIGHT", -3, -7)
	c:SetFrameLevel (f:GetFrameLevel()+1)
	c:SetAlpha (0.9)
	f.CloseButton = c
	
	local title = gump:NewLabel (f, nil, "$parentTitle", "chart_title", "Chart!", nil, 20, "yellow")
	title:SetPoint (110, -13)
	_detalhes:SetFontOutline (title, true)

	local bottom_texture = gump:NewImage (f, nil, 702, 25, "background", nil, nil, "$parentBottomTexture")
	bottom_texture:SetTexture (0, 0, 0, .6)
	bottom_texture:SetPoint ("bottomleft", f, "bottomleft", 8, 7)
	bottom_texture:SetPoint ("bottomright", f, "bottomright", -8, 7)

	f.Overlays = {}
	f.OverlaysAmount = 1
	
	f.BoxLabels = {}
	f.BoxLabelsAmount = 1
	
	f.TimeLabels = {}
	for i = 1, 17 do 
		local time = gump:NewLabel (f, nil, "$parentTime"..i, nil, "00:00")
		time:SetPoint ("bottomleft", f, "bottomleft", 78 + ((i-1)*36), 13)
		f.TimeLabels [i] = time
		local line = gump:NewImage (f, nil, 1, h-45, "border", nil, nil, "$parentTime"..i.."Bar")
		line:SetTexture (1, 1, 1, .1)
		line:SetPoint ("bottomleft", time, "topright", 0, -10)
		time.line = line
	end
	
	--graphic
		local g = LibStub:GetLibrary("LibGraph-2.0"):CreateGraphLine (name .. "Graphic", f, "topleft","topleft", 108, -35, w - 120, h - 67)
		g:SetXAxis (-1,1)
		g:SetYAxis (-1,1)
		g:SetGridSpacing (false, false)
		g:SetGridColor ({0.5,0.5,0.5,0.3})
		g:SetAxisDrawing (false,false)
		g:SetAxisColor({1.0,1.0,1.0,1.0})
		g:SetAutoScale (true)
		g:SetLineTexture ("smallline")
		g:SetBorderSize ("right", 0.001)
		g:SetBorderSize ("left", 0.000)
		g:SetBorderSize ("top", 0.002)
		g:SetBorderSize ("bottom", 0.001)
		g.VerticalLines = {}
		g.max_value = 0
		
		g:SetLineTexture ("line")
		
		f.Graphic = g
		f.GData = {}
		f.OData = {}
		
		g:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16})
		g:SetBackdropColor (0, 0, 0, 0.8)
	
	--div lines
		for i = 1, 8, 1 do
			local line = g:CreateTexture (nil, "overlay")
			line:SetTexture (1, 1, 1, .2)
			line:SetWidth (670)
			line:SetHeight (1.1)
		
			gump:NewLabel (f, f, nil, "dpsamt"..i, "100k", "GameFontHighlightSmall")
			f["dpsamt"..i]:SetPoint ("TOPLEFT", f, "TOPLEFT", 27, -61 + (-(24.6*i)))
			line:SetPoint ("topleft", f["dpsamt"..i].widget, "bottom", -27, 0)
			f["dpsamt"..i].line = line
		end
	
	f.SetTime = chart_panel_align_timelabels
	f.EnableVerticalLines = chart_panel_vlines_on
	f.DisableVerticalLines = chart_panel_vlines_off
	f.SetTitle = chart_panel_set_title
	f.SetScale = chart_panel_set_scale
	f.Reset = chart_panel_reset
	f.AddLine = chart_panel_add_data
	f.CanMove = chart_panel_can_move
	f.AddLabel = chart_panel_add_label
	f.AddOverlay = chart_panel_add_overlay
	f.HideCloseButton = chart_panel_hide_close_button
	f.RightClickClose = chart_panel_right_click_close
	
	f:SetScript ("OnSizeChanged", chart_panel_onresize)
	chart_panel_onresize (f)
	
	return f
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ~gframe
local gframe_on_enter_line = function (self)
	self:SetBackdropColor (0, 0, 0, 0)

	local parent = self:GetParent()
	local ball = self.ball
	ball:SetBlendMode ("ADD")
	
	local on_enter = parent._onenter_line
	if (on_enter) then
		return on_enter (self, parent)
	end
end

local gframe_on_leave_line = function (self)
	self:SetBackdropColor (0, 0, 0, .6)
	
	local parent = self:GetParent()
	local ball = self.ball
	ball:SetBlendMode ("BLEND")
	
	local on_leave = parent._onleave_line
	if (on_leave) then
		return on_leave (self, parent)
	end
end

local gframe_create_line = function (self)
	local index = #self._lines+1
	
	local f = CreateFrame ("frame", nil, self)
	self._lines [index] = f
	f.id = index
	f:SetScript ("OnEnter", gframe_on_enter_line)
	f:SetScript ("OnLeave", gframe_on_leave_line)
	
	f:SetWidth (self._linewidth)
	
	if (index == 1) then
		f:SetPoint ("topleft", self, "topleft")
		f:SetPoint ("bottomleft", self, "bottomleft")
	else
		local previous_line = self._lines [index-1]
		f:SetPoint ("topleft", previous_line, "topright")
		f:SetPoint ("bottomleft", previous_line, "bottomright")
	end
	
	local t = f:CreateTexture (nil, "background")
	t:SetWidth (1)
	t:SetPoint ("topright", f, "topright")
	t:SetPoint ("bottomright", f, "bottomright")
	t:SetTexture (1, 1, 1, .1)
	f.grid = t
	
	local b = f:CreateTexture (nil, "overlay")
	b:SetTexture ([[Interface\COMMON\Indicator-Yellow]])
	b:SetSize (16, 16)
	f.ball = b
	local anchor = CreateFrame ("frame", nil, f)
	anchor:SetAllPoints (b)
	b.tooltip_anchor = anchor
	
	local spellicon = f:CreateTexture (nil, "artwork")
	spellicon:SetPoint ("bottom", b, "bottom", 0, 10)
	spellicon:SetSize (16, 16)
	f.spellicon = spellicon
	
	local timeline = f:CreateFontString (nil, "overlay", "GameFontNormal")
	timeline:SetPoint ("bottomright", f, "bottomright", -2, 0)
	_detalhes:SetFontSize (timeline, 8)
	f.timeline = timeline
	
	return f
end

local gframe_getline = function (self, index)
	local line = self._lines [index]
	if (not line) then
		line = gframe_create_line (self)
	end
	return line
end

local gframe_reset = function (self)
	for i, line in ipairs (self._lines) do
		line:Hide()
	end
	if (self.GraphLib_Lines_Used) then
		for i = #self.GraphLib_Lines_Used, 1, -1 do
			local line = tremove (self.GraphLib_Lines_Used)
			tinsert (self.GraphLib_Lines, line)
			line:Hide()
		end
	end
end

local gframe_update = function (self, lines)
	
	local g = LibStub:GetLibrary ("LibGraph-2.0")
	local h = self:GetHeight()/100
	local amtlines = #lines
	local linewidth = self._linewidth
	
	local max_value = 0
	for i = 1, amtlines do
		if (lines [i].value > max_value) then
			max_value = lines [i].value
		end
	end
	
	local o = 1
	local lastvalue = self:GetHeight()/2
	
	for i = 1, min (amtlines, self._maxlines) do
		
		local data = lines [i]

		local pvalue = data.value / max_value * 100
		if (pvalue > 98) then
			pvalue = 98
		end
		pvalue = pvalue * h
	
		g:DrawLine (self, (o-1)*linewidth, lastvalue, o*linewidth, pvalue, linewidth, {1, 1, 1, 1}, "overlay")
		lastvalue = pvalue

		local line = self:GetLine (i)
		line:Show()
		line.ball:Show()
		
		line.ball:SetPoint ("bottomleft", self, "bottomleft", (o*linewidth)-8, pvalue-8)
		line.spellicon:SetTexture (nil)
		line.timeline:SetText (data.text)
		line.timeline:Show()
		
		line.data = data
		
		o = o + 1
	end
	
end

function gump:CreateGFrame (parent, w, h, linewidth, onenter, onleave, member, name)
	local f = CreateFrame ("frame", name, parent)
	f:SetSize (w or 450, h or 150)
	f.CustomLine = [[Interface\AddOns\Details\Libs\LibGraph-2.0\line]]
	
	if (member) then
		parent [member] = f
	end
	
	f.CreateLine = gframe_create_line
	f.GetLine = gframe_getline
	f.Reset = gframe_reset
	f.UpdateLines = gframe_update
	
	f._lines = {}
	
	f._onenter_line = onenter
	f._onleave_line = onleave
	
	f._linewidth = linewidth or 50
	f._maxlines = floor (f:GetWidth() / f._linewidth)
	
	return f
end

--[=[

function gframe:Reset()
	for i = #gframe.GraphLib_Lines_Used, 1, -1 do
		local line = tremove (gframe.GraphLib_Lines_Used)
		tinsert (gframe.GraphLib_Lines, line)
		line:Hide()
	end
end

function DeathGraphs:ShowGraphicForDeath (data)
	
	gframe:Reset()
	gframe:ShowGrid()
	gframe:Show()

	if (not data) then
		return
	end

	local timeline = data [1]
	local max_health = data[4]

	if (#timeline < 16) then
		while (#timeline < 16) do
			table.insert (timeline, 1, {false, 0, 0, data[6], max_health, "-1"})
		end
	end
	
	log = timeline
	
	local h = gframe:GetHeight()/100

	local o = 1
	local lastlife = 156

	--for i = 16, 1, -1 do
	for i = 1, 16, 1 do
		local t = timeline [i]
		if (type (t) == "table") then
		
			--> death parser
			
			local evtype = t [1] --event type
			local spellid = t [2] --spellid
			local amount = t [3] --amount healed or damaged
			local time = t [4] --time
			local life = t [5] --health
			local source = t [6] --source

			local plife = life / max_health * 100
			if (plife > 98) then
				plife = 98
			end
			plife = plife*h
			
			local line
			
			line = g:DrawLine (gframe, (o-1)*29, lastlife, o*29, plife, 50, red, "overlay")

			local ball = gballs [o]
			ball:SetPoint ("bottomleft", gframe, "bottomleft", (o*29)-8, plife-8)
			if (type (evtype) == "boolean" and evtype) then --> damage
				ball.spellicon:SetTexture (select (3, GetSpellInfo (spellid)))
				ball.spellicon:SetTexCoord (4/64, 60/64, 4/64, 60/64)
			else
				ball.spellicon:SetTexture (nil)
			end
			
			ball.line = line
			
			local clock = data[6] - time
			if (type (evtype) == "number" and evtype == 2) then
				if (clock <= 100) then
					timeline_bg.labels [o]:SetText (math.floor (clock))
				else
					timeline_bg.labels [o]:SetText (string.format ("%.1f", clock))
				end
			else
				timeline_bg.labels [o]:SetText ("-" .. string.format ("%.1f", clock))
			end
			
			local frame = gradeframes [o]
			frame.data = t
			
			lastlife = plife
			o = o + 1
		end
	end
	
	DeathGraphs:UpdateOverall()

end

--]=]