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

function gump:NewFillPanel (parent, rows, name, member, w, h, total_lines, fill_row, autowidth, options)
	
	local panel = gump:NewPanel (parent, parent, name, member, w, h)
	panel.backdrop = nil
	
	options = options or {rowheight = 20}
	panel.rows = {}

	for index, t in ipairs (rows) do 
		local thisrow = gump:NewPanel (panel, panel, "$parentHeader_" .. name .. index, nil, 1, 20)
		thisrow.backdrop = {bgFile = [[Interface\DialogFrame\UI-DialogBox-Gold-Background]]}
		thisrow.color = "silver"
		thisrow.type = t.type
		thisrow.func = t.func
		thisrow.name = t.name
		thisrow.notext = t.notext
		thisrow.icon = t.icon
		thisrow.iconalign = t.iconalign
		
		local text = gump:NewLabel (thisrow, nil, name .. "$parentLabel", "text")
		text:SetPoint ("left", thisrow, "left", 2, 0)
		text:SetText (t.name)

		tinsert (panel.rows, thisrow)
	end

	local cur_width = 0
	local row_width = w / #rows
	
	local anchors = {}
	
	for index, row in ipairs (panel.rows) do
		if (autowidth) then
			row:SetWidth (row_width)
			row:SetPoint ("topleft", panel, "topleft", cur_width, 0)
			tinsert (anchors, cur_width)
			cur_width = cur_width + row_width + 1
		else
			row:SetPoint ("topleft", panel, "topleft", cur_width, 0)
			row.width = rows [index].width
			tinsert (anchors, cur_width)
			cur_width = cur_width + rows [index].width + 1
		end
	end
	
	if (autowidth) then
		panel.rows [#panel.rows]:SetWidth (row_width - #rows + 1)
	else
		panel.rows [#panel.rows]:SetWidth (rows [#rows].width - #rows + 1)
	end
	
	local refresh_fillbox = function (self)
		local offset = FauxScrollFrame_GetOffset (self)
		local filled_lines = total_lines (panel)

		for index = 1, #self.lines do
		
			local row = self.lines [index]
			if (index <= filled_lines) then
			
				local real_index = index + offset
				local results = fill_row (real_index, panel)

				if (results [1]) then
				
					row:Show()
					
					for i = 1, #row.row_widgets do
					
						row.row_widgets [i].index = real_index
						
						if (panel.rows [i].type == "icon") then

							local result = results [i]:gsub (".-%\\", "")
							row.row_widgets [i]._icon.texture = results [i]
						
						elseif (panel.rows [i].type == "button") then
						
							if (type (results [i]) == "table") then
							
								if (results [i].text) then
									row.row_widgets [i]:SetText (results [i].text)
								end
								
								if (results [i].icon) then
									row.row_widgets [i]._icon:SetTexture (results [i].icon)
								end
								
								if (results [i].func) then
									row.row_widgets [i]:SetClickFunction (results [i].func, real_index, results [i].value)
								end

							else
								row.row_widgets [i]:SetText (results [i])
							end
							
						else
							--> text
							row.row_widgets [i]:SetText (results [i])
							if (panel.rows [i].type == "entry") then
								row.row_widgets [i]:SetCursorPosition (0)
							end
						end
					end
					
				else
					row:Hide()
					for i = 1, #row.row_widgets do
						row.row_widgets [i]:SetText ("")
						if (panel.rows [i].type == "icon") then
							row.row_widgets [i]._icon.texture = ""
						end
					end
				end
			else
				row:Hide()
				for i = 1, #row.row_widgets do
					row.row_widgets [i]:SetText ("")
					if (panel.rows [i].type == "icon") then
						row.row_widgets [i]._icon.texture = ""
					end
				end
			end
		end
	end
	
	function panel:Refresh()
		local filled_lines = total_lines (panel)
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
	
		local row = gump:NewPanel (panel, nil, "$parentRow_" .. i, nil, 1, size)
		row.backdrop = {bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]]}
		row.color = {1, 1, 1, .2}
		row:SetPoint ("topleft", scrollframe, "topleft", 0, (i-1) * size * -1)
		row:SetPoint ("topright", scrollframe, "topright", 0, (i-1) * size * -1)
		tinsert (scrollframe.lines, row)
		
		row.row_widgets = {}
		
		for o = 1, #rows do
		
			local _type = panel.rows [o].type

			if (_type == "text") then
			
				--> create text
				local text = gump:NewLabel (row, nil, name .. "$parentLabel" .. o, "text" .. o)
				text:SetPoint ("left", row, "left", anchors [o], 0)
				
				--> insert in the table
				tinsert (row.row_widgets, text)
			
			elseif (_type == "entry") then
			
				--> create editbox
				local editbox = gump:NewTextEntry (row, nil, "$parentEntry" .. i .. o .. math.random(100), "entry", panel.rows [o].width, 20, panel.rows [o].func, i, o)
				editbox.align = "left"
				
				editbox:SetHook ("OnEnterPressed", function()
					editbox.widget.focuslost = true
					editbox:ClearFocus()
					editbox.func (editbox.index, editbox.text)
					return true
				end) 
				editbox:SetPoint ("left", row, "left", anchors [o], 0)
				editbox:SetBackdrop ({bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]], edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1})
				editbox:SetBackdropColor (1, 1, 1, 0.1)
				editbox:SetBackdropBorderColor (1, 1, 1, 0.1)
				editbox.editbox.current_bordercolor = {1, 1, 1, 0.1}
				--> insert in the table
				tinsert (row.row_widgets, editbox)
			
			elseif (_type == "button") then
			
				--> create button
				local button = gump:NewButton (row, nil, "$parentButton" .. o, "button", panel.rows [o].width, 20)
				
				local func = function()
					panel.rows [o].func (button.index, o)
					panel:Refresh()
				end
				button:SetClickFunction (func)
				
				button:SetPoint ("left", row, "left", anchors [o], 0)
				
				--> create icon and the text
				local icon = gump:NewImage (button, nil, 20, 20)
				local text = gump:NewLabel (button)
				
				button._icon = icon
				button._text = text

				button:SetHook ("OnEnter", button_on_enter)
				button:SetHook ("OnLeave", button_on_leave)

				if (panel.rows [o].icon) then
					icon.texture = panel.rows [o].icon
					if (panel.rows [o].iconalign) then
						if (panel.rows [o].iconalign == "center") then
							icon:SetPoint ("center", button, "center")
						elseif (panel.rows [o].iconalign == "right") then
							icon:SetPoint ("right", button, "right")
						end
					else
						icon:SetPoint ("left", button, "left")
					end
				end
				
				if (panel.rows [o].name and not panel.rows [o].notext) then
					text:SetPoint ("left", icon, "right", 2, 0)
					text.text = panel.rows [o].name
				end

				--> inser in the table
				tinsert (row.row_widgets, button)
			
			elseif (_type == "icon") then
			
				--> create button and icon
				local iconbutton = gump:NewButton (row, nil, "$parentIconButton" .. o, "iconbutton", 22, 20)
				iconbutton:InstallCustomTexture()
				
				iconbutton:SetHook ("OnEnter", button_on_enter)
				iconbutton:SetHook ("OnLeave", button_on_leave)
				
				--iconbutton:InstallCustomTexture()
				local icon = gump:NewImage (iconbutton, nil, 20, 20, "artwork", nil, "_icon", "$parentIcon" .. o)
				iconbutton._icon = icon
				
				iconbutton:SetPoint ("left", row, "left", anchors [o] + ( (panel.rows [o].width - 22) / 2), 0)
				icon:SetPoint ("center", iconbutton, "center", 0, 0)
				
				--> set functions
				local function iconcallback (texture)
					iconbutton._icon.texture = texture
					panel.rows [o].func (iconbutton.index, texture)
				end
				
				iconbutton:SetClickFunction (function()
					gump:IconPick (iconcallback, true)
					return true
				end)
				
				--> insert in the table
				tinsert (row.row_widgets, iconbutton)
				
			end

		end
	end
	
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
function gump:IconPick (callback, close_when_select)

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
		
		gump.IconPickFrame.searchLabel =  gump:NewLabel (gump.IconPickFrame, nil, "$parentSearchBoxLabel", nil, "search:", font, size, color)
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
			gump.IconPickFrame.callback (self.icon:GetTexture())
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



