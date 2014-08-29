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
local _string_len = string.len --> lua local
local _
local cleanfunction = function() end
local APIDropDownFunctions = false
local DropDownMetaFunctions = {}

------------------------------------------------------------------------------------------------------------
--> metatables

	DropDownMetaFunctions.__call = function (_table, value)
		--> unknow
	end
	
------------------------------------------------------------------------------------------------------------
--> members

	--> selected value
	local gmember_value = function (_object)
		return _object:GetValue()
	end
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
		return _object.button:GetWidth()
	end
	--> frame height
	local gmember_height = function (_object)
		return _object.button:GetHeight()
	end
	--> current text
	local gmember_text = function (_object)
		return _object.label:GetText()
	end
	--> menu creation function
	local gmember_function = function (_object)
		return _object:GetFunction()
	end
	--> menu width
	local gmember_menuwidth = function (_object)
		return _rawget (self, "realsizeW")
	end
	--> menu height
	local gmember_menuheight = function (_object)
		return _rawget (self, "realsizeH")
	end
	
	local get_members_function_index = {
		["value"] = gmember_value,
		["text"] = gmember_text,
		["shown"] = gmember_shown,
		["width"] = gmember_width,
		["menuwidth"] = gmember_menuwidth,
		["height"] = gmember_height,
		["menuheight"] = gmember_menuheight,
		["tooltip"] = gmember_tooltip,
		["func"] = gmember_function,
	}
	
	DropDownMetaFunctions.__index = function (_table, _member_requested)

		local func = get_members_function_index [_member_requested]
		if (func) then
			return func (_table, _member_requested)
		end
		
		local fromMe = _rawget (_table, _member_requested)
		if (fromMe) then
			return fromMe
		end
		
		return DropDownMetaFunctions [_member_requested]
	end
	
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
		return _object.dropdown:SetWidth (_value)
	end
	--> frame height
	local smember_height = function (_object, _value)
		return _object.dropdown:SetHeight (_value)
	end	
	--> menu creation function
	local smember_function = function (_object, _value)
		return _object:SetFunction (_value)
	end
	--> menu width
	local smember_menuwidth = function (_object, _value)
		_object:SetMenuSize (_value, nil)
	end
	--> menu height
	local smember_menuheight = function (_object, _value)
		_object:SetMenuSize (nil, _value)
	end
	
	local set_members_function_index = {
		["tooltip"] = smember_tooltip,
		["show"] = smember_show,
		["hide"] = smember_hide,
		["width"] = smember_width,
		["menuwidth"] = smember_menuwidth,
		["height"] = smember_height,
		["menuheight"] = smember_menuheight,
		["func"] = smember_function,
	}
	
	DropDownMetaFunctions.__newindex = function (_table, _key, _value)
		local func = set_members_function_index [_key]
		if (func) then
			return func (_table, _value)
		else
			return _rawset (_table, _key, _value)
		end
	end

------------------------------------------------------------------------------------------------------------
--> methods
	function DropDownMetaFunctions:IsShown()
		return self.dropdown:IsShown()
	end
	function DropDownMetaFunctions:Show()
		return self.dropdown:Show()
	end
	function DropDownMetaFunctions:Hide()
		return self.dropdown:Hide()
	end

--> menu width and height
	function DropDownMetaFunctions:SetMenuSize (w, h)
		if (w) then
			return _rawset (self, "realsizeW", w)
		end
		if (h) then
			return _rawset (self, "realsizeH", h)
		end
	end
	function DropDownMetaFunctions:GetMenuSize()
		return _rawget (self, "realsizeW"), _rawget (self, "realsizeH")
	end
	
--> function
	function DropDownMetaFunctions:SetFunction (func)
		return _rawset (self, "func", func)
	end
	function DropDownMetaFunctions:GetFunction()
		return _rawget (self, "func")
	end
	
--> value
	function DropDownMetaFunctions:GetValue()
		return _rawget (self, "myvalue")
	end
	function DropDownMetaFunctions:SetValue (value)
		return _rawset (self, "myvalue", value)
	end

--> setpoint
	function DropDownMetaFunctions:SetPoint (v1, v2, v3, v4, v5)
		v1, v2, v3, v4, v5 = gump:CheckPoints (v1, v2, v3, v4, v5, self)
		if (not v1) then
			print ("Invalid parameter for SetPoint")
			return
		end
		return self.widget:SetPoint (v1, v2, v3, v4, v5)
	end

--> sizes
	function DropDownMetaFunctions:SetSize (w, h)
		if (w) then
			self.dropdown:SetWidth (w)
		end
		if (h) then
			return self.dropdown:SetHeight (h)
		end
	end
	
--> tooltip
	function DropDownMetaFunctions:SetTooltip (tooltip)
		if (tooltip) then
			return _rawset (self, "have_tooltip", tooltip)
		else
			return _rawset (self, "have_tooltip", nil)
		end
	end
	function DropDownMetaFunctions:GetTooltip()
		return _rawget (self, "have_tooltip")
	end
	
--> frame levels
	function DropDownMetaFunctions:GetFrameLevel()
		return self.dropdown:GetFrameLevel()
	end
	function DropDownMetaFunctions:SetFrameLevel (level, frame)
		if (not frame) then
			return self.dropdown:SetFrameLevel (level)
		else
			local framelevel = frame:GetFrameLevel (frame) + level
			return self.dropdown:SetFrameLevel (framelevel)
		end
	end

--> frame stratas
	function DropDownMetaFunctions:GetFrameStrata()
		return self.dropdown:GetFrameStrata()
	end
	function DropDownMetaFunctions:SetFrameStrata (strata)
		if (_type (strata) == "table") then
			self.dropdown:SetFrameStrata (strata:GetFrameStrata())
		else
			self.dropdown:SetFrameStrata (strata)
		end
	end
	
--> enabled
	function DropDownMetaFunctions:IsEnabled()
		return self.dropdown:IsEnabled()
	end
	
	function DropDownMetaFunctions:Enable()
		
		self:SetAlpha (1)
		return _rawset (self, "lockdown", false)
		--return self.dropdown:Enable()
	end
	
	function DropDownMetaFunctions:Disable()
	
		self:SetAlpha (.4)
		return _rawset (self, "lockdown", true)
		--return self.dropdown:Disable()
	end

--> fixed value
	function DropDownMetaFunctions:SetFixedParameter (value)
		_rawset (self, "FixedValue", value)
	end
	
--> hooks
	function DropDownMetaFunctions:SetHook (hookType, func)
		if (func) then
			_rawset (self, hookType.."Hook", func)
		else
			_rawset (self, hookType.."Hook", nil)
		end
	end
	
------------------------------------------------------------------------------------------------------------
--> scripts

local last_opened = false

local function isOptionVisible (thisOption)
	if (_type (thisOption.shown) == "boolean" or _type (thisOption.shown) == "function") then
		if (not thisOption.shown) then
			return false
		elseif (not thisOption.shown()) then
			return false
		end
	end
	return true
end

function DropDownMetaFunctions:Refresh()
	local menu = self.func()

	if (#menu == 0) then
		self:NoOption (true)
		self.no_options = true
		return false
		
	elseif (self.no_options) then
		self.no_options = false
		self:NoOption (false)
		self:NoOptionSelected()
		return true
	end

	return true
end

function DropDownMetaFunctions:NoOptionSelected()
	self.label:SetText (self.empty_text or "no option selected")
	self.label:SetTextColor (1, 1, 1, 0.4)
	if (self.empty_icon) then
		self.icon:SetTexture (self.empty_icon)
	else
		self.icon:SetTexture ([[Interface\COMMON\UI-ModelControlPanel]])
		self.icon:SetTexCoord (0.625, 0.78125, 0.328125, 0.390625)
	end
	self.icon:SetVertexColor (1, 1, 1, 0.4)
	
	self.last_select = nil
end

function DropDownMetaFunctions:NoOption (state)
	if (state) then
		self:Disable()
		self:SetAlpha (0.5)
		self.no_options = true
		self.label:SetText ("no options")
		self.label:SetTextColor (1, 1, 1, 0.4)
		self.icon:SetTexture ([[Interface\CHARACTERFRAME\UI-Player-PlayTimeUnhealthy]])
		self.icon:SetTexCoord (0, 1, 0, 1)
		self.icon:SetVertexColor (1, 1, 1, 0.4)		
	else
		self.no_options = false
		self:Enable()
		self:SetAlpha (1)
	end
end

function DropDownMetaFunctions:Select (optionName, byOptionNumber)

	if (type (optionName) == "boolean" and not optionName) then
		self:NoOptionSelected()
		return false
	end

	local menu = self.func()

	if (#menu == 0) then
		self:NoOption (true)
		return true
	else
		self:NoOption (false)
	end
	
	if (byOptionNumber and type (optionName) == "number") then
		if (not menu [optionName]) then --> invalid index
			self:NoOptionSelected()
			return false
		end
		self:Selected (menu [optionName])
		return true
	end
	
	for _, thisMenu in ipairs (menu) do 
		if ( ( thisMenu.label == optionName or thisMenu.value == optionName ) and isOptionVisible (thisMenu)) then
			self:Selected (thisMenu)
			return true
		end
	end
	
	return false
end

function DropDownMetaFunctions:SetEmptyTextAndIcon (text, icon)
	if (text) then
		self.empty_text = text
	end
	if (icon) then
		self.empty_icon = icon
	end

	self:Selected (self.last_select)
end

function DropDownMetaFunctions:Selected (_table)

	if (not _table) then

		--> there is any options?
		if (not self:Refresh()) then
			self.last_select = nil
			return
		end

		--> exists options but none selected
		self:NoOptionSelected()
		return
	end
	
	self.last_select = _table
	self:NoOption (false)
	
	self.label:SetText (_table.label)
	self.icon:SetTexture (_table.icon)
	
	if (_table.icon) then
		self.label:SetPoint ("left", self.icon, "right", 2, 0)
		if (_table.texcoord) then
			self.icon:SetTexCoord (unpack (_table.texcoord))
		else
			self.icon:SetTexCoord (0, 1, 0, 1)
		end
		
		if (_table.iconcolor) then
			if (type (_table.iconcolor) == "string") then
				self.icon:SetVertexColor (gump:ParseColors (_table.iconcolor))
			else
				self.icon:SetVertexColor (unpack (_table.iconcolor))
			end
		else
			self.icon:SetVertexColor (1, 1, 1, 1)
		end
		
	else
		self.label:SetPoint ("left", self.label:GetParent(), "left", 4, 0)
	end
	
	self.statusbar:SetTexture (_table.statusbar)
	
	if (_table.color) then
		local _value1, _value2, _value3, _value4 = gump:ParseColors (_table.color)
		self.label:SetTextColor (_value1, _value2, _value3, _value4)
	else
		self.label:SetTextColor (1, 1, 1, 1)
	end
	
	if (_table.font) then
		self.label:SetFont (_table.font, 10)
	else
		self.label:SetFont ("GameFontHighlightSmall", 10)
	end
	
	self:SetValue (_table.value)

end

function DetailsDropDownOptionClick (button)

	--> update name and icon on main frame
	button.object:Selected (button.table)
	
	--> close menu frame
		button.object:Close()
		
	--> exec function if any
		if (button.table.onclick) then
			button.table.onclick (button:GetParent():GetParent():GetParent().MyObject, button.object.FixedValue, button.table.value)	
		end
		
	--> set the value of selected option in main object
		button.object.myvalue = button.table.value
end

function DropDownMetaFunctions:Open()
	self.dropdown.dropdownframe:Show()
	self.dropdown.dropdownborder:Show()
	self.dropdown.arrowTexture:SetTexture ("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down")
	self.opened = true
	if (last_opened) then
		last_opened:Close()
	end
	last_opened = self
end

function DropDownMetaFunctions:Close()
	--> when menu is being close, just hide the border and the script will call back this again
	if (self.dropdown.dropdownborder:IsShown()) then
		self.dropdown.dropdownborder:Hide()
		return
	end
	self.dropdown.dropdownframe:Hide()
	self.dropdown.arrowTexture:SetTexture ("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
	
	local selectedTexture = _G [self:GetName() .. "_ScrollFrame_ScrollChild_SelectedTexture"]
	selectedTexture:Hide()
	
	self.opened = false
	last_opened = false
end

--> close by escape key
function DetailsDropDownOptionsFrameOnHide (frame)
	frame:GetParent().MyObject:Close()
end

function DetailsDropDownOptionOnEnter (frame)
	if (frame.table.desc) then
		_detalhes:CooltipPreset (2)
		GameCooltip:AddLine (frame.table.desc)
		if (frame.table.descfont) then
			GameCooltip:SetOption ("TextFont", frame.table.descfont)
		end
		
		GameCooltip:SetHost (frame, "topleft", "topright", 10, 0)
		
		GameCooltip:ShowCooltip (nil, "tooltip")
		frame.tooltip = true
	end
	frame:GetParent().mouseover:SetPoint ("left", frame)
	frame:GetParent().mouseover:Show()
end

function DetailsDropDownOptionOnLeave (frame)
	if (frame.table.desc) then
		_detalhes.popup:ShowMe (false)
	end
	frame:GetParent().mouseover:Hide()
end

function DetailsDropDownOnMouseDown (button)
	
	local object = button.MyObject

	if (not object.opened and not _rawget (object, "lockdown")) then --> click to open
		
		local menu = object:func()
		object.builtMenu = menu
		
		local frame_witdh = object.realsizeW
		
		if (menu [1]) then
			--> build menu
			
			local scrollFrame = _G [button:GetName() .. "_ScrollFrame"]
			local scrollChild = _G [button:GetName() .. "_ScrollFrame_ScrollChild"]
			local scrollBorder = _G [button:GetName() .. "_Border"]
			local selectedTexture = _G [button:GetName() .. "_ScrollFrame_ScrollChild_SelectedTexture"]
			local mouseOverTexture = _G [button:GetName() .. "_ScrollFrame_ScrollChild_MouseOverTexture"]
			
			--scrollFrame:SetFrameStrata ("DIALOG")
			--scrollBorder:SetFrameStrata ("DIALOG")
			--scrollChild:SetFrameStrata ("DIALOG")
			
			--print (scrollFrame:GetFrameStrata())
			--print (_G ["DetailsOptionsWindow1FragsPvpSlider"]:GetFrameStrata())
			
			local i = 1
			local showing = 0
			local currentText = button.text:GetText() or ""
			
			if (object.OnMouseDownHook) then
				local interrupt = object.OnMouseDownHook (button, buttontype, menu, scrollFrame, scrollChild, selectedTexture)
				if (interrupt) then
					return
				end
			end
			
			for _, _table in ipairs (menu) do 
				
				local show = isOptionVisible (_table)

				if (show) then
					local _this_row = object.menus [i]
					showing = showing + 1
					
					if (not _this_row) then
					
						local name = button:GetName() .. "Row" .. i
						local parent = scrollChild
						
						_this_row = CreateFrame ("Button", name, parent, "DetailsDropDownOptionTemplate")
						local anchor_i = i-1
						_this_row:SetPoint ("topleft", parent, "topleft", 5, (-anchor_i*20)-5)
						_this_row:SetPoint ("topright", parent, "topright", -5, (-anchor_i*20)-5)
						_this_row.object = object
						object.menus [i] = _this_row
					end
					
					_this_row.icon:SetTexture (_table.icon)
					if (_table.icon) then
					
						_this_row.label:SetPoint ("left", _this_row.icon, "right", 5, 0)
						
						if (_table.texcoord) then
							_this_row.icon:SetTexCoord (unpack (_table.texcoord))
						else
							_this_row.icon:SetTexCoord (0, 1, 0, 1)
						end
						
						if (_table.iconcolor) then
							if (type (_table.iconcolor) == "string") then
								_this_row.icon:SetVertexColor (gump:ParseColors (_table.iconcolor))
							else
								_this_row.icon:SetVertexColor (unpack (_table.iconcolor))
							end
						else
							_this_row.icon:SetVertexColor (1, 1, 1, 1)
						end
					else
						_this_row.label:SetPoint ("left", _this_row.statusbar, "left", 2, 0)
					end
					
					if (_table.iconsize) then
						_this_row.icon:SetSize (_table.iconsize[1], _table.iconsize[2])
					else
						_this_row.icon:SetSize (20, 20)
					end
					
					if (_table.font) then
						_this_row.label:SetFont (_table.font, 10.5)
					else
						_this_row.label:SetFont ("GameFontHighlightSmall", 10.5)
					end
					
					_this_row.statusbar:SetTexture (_table.statusbar)
					_this_row.label:SetText (_table.label)
					
					if (currentText and currentText == _table.label) then
						if (_table.icon) then
							selectedTexture:SetPoint ("left", _this_row.icon, "right", -5, -2)
						else
							selectedTexture:SetPoint ("left", _this_row.statusbar, "left", 0, 0)
						end
						
						selectedTexture:Show()
						selectedTexture:SetVertexColor (1, 1, 1, .3);
						currentText = nil
					end
					
					if (_table.color) then
						local _value1, _value2, _value3, _value4 = gump:ParseColors (_table.color)
						_this_row.label:SetTextColor (_value1, _value2, _value3, _value4)
					else
						_this_row.label:SetTextColor (1, 1, 1, 1)
					end
					
					_this_row.table = _table
					
					local labelwitdh = _this_row.label:GetStringWidth()
					if (labelwitdh+40 > frame_witdh) then
						frame_witdh = labelwitdh+40
					end
					_this_row:Show()
					
					i = i + 1
				end
				
			end
			
			if (currentText) then
				selectedTexture:Hide()
			else
				selectedTexture:SetWidth (frame_witdh-20)
			end
			
			for i = showing+1, #object.menus do
				object.menus [i]:Hide()
			end
			
			local size = object.realsizeH
			
			if (showing*20 > size) then
				--show scrollbar and setup scroll
				object:ShowScroll()
				scrollFrame:EnableMouseWheel (true)
				object.scroll:Altura (size-35)
				object.scroll:SetMinMaxValues (0, (showing*20) - size + 20)
				--width
				scrollBorder:SetWidth (frame_witdh+20)
				scrollFrame:SetWidth (frame_witdh+20)
				scrollChild:SetWidth (frame_witdh+20)
				--height
				scrollBorder:SetHeight (size+20)
				scrollFrame:SetHeight (size)
				scrollChild:SetHeight ((showing*20)+20)
				--mouse over texture
				mouseOverTexture:SetWidth (frame_witdh-7)
				
				for index, row in ipairs (object.menus) do
					row:SetPoint ("topright", scrollChild, "topright", -22, ((-index-1)*20)-5)
				end
				
			else
				--hide scrollbar and disable wheel
				object:HideScroll()
				scrollFrame:EnableMouseWheel (false)
				--width
				scrollBorder:SetWidth (frame_witdh)
				scrollFrame:SetWidth (frame_witdh)
				scrollChild:SetWidth (frame_witdh)
				--height
				scrollBorder:SetHeight ((showing*20) + 25)
				scrollFrame:SetHeight ((showing*20) + 25)
				--mouse over texture
				mouseOverTexture:SetWidth (frame_witdh-10)
				
				for index, row in ipairs (object.menus) do
					row:SetPoint ("topright", scrollChild, "topright", -5, ((-index-1)*20)-5)
				end
			end

			object.scroll:SetValue (0)
			object:Open()
			
		else
			--> clear menu
			
		end
	
	else --> click to close

		object:Close()
	end
	
end

function DetailsDropDownOnEnter (self)

	if (self.MyObject.OnEnterHook) then
		local interrupt = self.MyObject.OnEnterHook (self)
		if (interrupt) then
			return
		end
	end

	if (self.MyObject.onenter_backdrop) then
		self:SetBackdropColor (unpack (self.MyObject.onenter_backdrop))
	else
		self:SetBackdropColor (.2, .2, .2, .2)
	end
	
	self.arrowTexture2:Show()
	
	if (self.MyObject.have_tooltip) then 
		GameCooltip:Reset()
		GameCooltip:SetType ("tooltip")
		GameCooltip:SetColor ("main", "transparent")
		_detalhes:CooltipPreset (2)
		GameCooltip:AddLine (self.MyObject.have_tooltip)
		GameCooltip:SetOwner (self)
		GameCooltip:ShowCooltip()
	end
	
	local parent = self:GetParent().MyObject
	if (parent and parent.type == "panel") then
		if (parent.GradientEnabled) then
			parent:RunGradient()
		end
	end
	
end

function DetailsDropDownOnLeave (self)
	if (self.MyObject.OnLeaveHook) then
		local interrupt = self.MyObject.OnLeaveHook (self)
		if (interrupt) then
			return
		end
	end

	if (self.MyObject.onleave_backdrop) then
		self:SetBackdropColor (unpack (self.MyObject.onleave_backdrop))
	else
		self:SetBackdropColor (1, 1, 1, .5)
	end
	
	self.arrowTexture2:Hide()
	
	if (self.MyObject.have_tooltip) then 
		_detalhes.popup:ShowMe (false)
	end
	
	local parent = self:GetParent().MyObject
	if (parent and parent.type == "panel") then
		if (parent.GradientEnabled) then
			parent:RunGradient (false)
		end
	end
end

function DetailsDropDownOnSizeChanged (self, w, h)
	self.MyObject.label:SetSize (self:GetWidth()-40, 10)
end

function DetailsDropDownOnShow (self)
	if (self.MyObject and self.MyObject.OnShowHook) then
		local interrupt = self.MyObject.OnShowHook (self)
		if (interrupt) then
			return
		end
	end
end

function DetailsDropDownOnHide (self)
	if (self.MyObject and self.MyObject.OnHideHook) then
		local interrupt = self.MyObject.OnHideHook (self)
		if (interrupt) then
			return
		end
	end
	
	self.MyObject:Close()
end



------------------------------------------------------------------------------------------------------------
--> object constructor

function gump:NewDropDown (parent, container, name, member, w, h, func, default)

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
	
	local DropDownObject = {type = "dropdown", dframework = true}
	
	if (member) then
		parent [member] = DropDownObject
	end	
	
	if (parent.dframework) then
		parent = parent.widget
	end
	if (container.dframework) then
		container = container.widget
	end	
	
	if (default == nil) then
		default = 1
	end

	--> default members:
		--> hooks
		DropDownObject.OnEnterHook = nil
		DropDownObject.OnLeaveHook = nil
		DropDownObject.OnHideHook = nil
		DropDownObject.OnShowHook = nil
		DropDownObject.OnMouseDownHook = nil
		--> misc
		DropDownObject.container = container
		DropDownObject.have_tooltip = nil
		
	DropDownObject.dropdown = CreateFrame ("Button", name, parent, "DetailsDropDownTemplate")
	DropDownObject.widget = DropDownObject.dropdown
	
	DropDownObject.__it = {nil, nil}
	--_G [name] = DropDownObject

	if (not APIDropDownFunctions) then
		APIDropDownFunctions = true
		local idx = getmetatable (DropDownObject.dropdown).__index
		for funcName, funcAddress in pairs (idx) do 
			if (not DropDownMetaFunctions [funcName]) then
				DropDownMetaFunctions [funcName] = function (object, ...)
					local x = loadstring ( "return _G."..object.dropdown:GetName()..":"..funcName.."(...)")
					return x (...)
				end
			end
		end
	end
	
	DropDownObject.dropdown.MyObject = DropDownObject
	
	DropDownObject.dropdown:SetWidth (w)
	DropDownObject.dropdown:SetHeight (h)

	DropDownObject.func = func
	DropDownObject.realsizeW = 150
	DropDownObject.realsizeH = 150
	DropDownObject.FixedValue = nil
	DropDownObject.opened = false
	DropDownObject.menus = {}
	DropDownObject.myvalue = nil
	
	DropDownObject.label = _G [name .. "_Text"]
	
	DropDownObject.icon = _G [name .. "_IconTexture"]
	DropDownObject.statusbar = _G [name .. "_StatusBarTexture"]
	DropDownObject.select = _G [name .. "_SelectedTexture"]
	
	local scroll = _G [DropDownObject.dropdown:GetName() .. "_ScrollFrame"]

	DropDownObject.scroll = gump:NewScrollBar (scroll, _G [DropDownObject.dropdown:GetName() .. "_ScrollFrame".."_ScrollChild"], -20, -18)
	
	function DropDownObject:HideScroll()
		scroll.baixo:Hide()
		scroll.cima:Hide()
		scroll.slider:Hide()
	end
	function DropDownObject:ShowScroll()
		scroll.baixo:Show()
		scroll.cima:Show()
		scroll.slider:Show()
	end
	
	--button_down_scripts (DropDownObject, scroll.slider, scroll.baixo)
	
	DropDownObject:HideScroll()
	DropDownObject.label:SetSize (DropDownObject.dropdown:GetWidth()-40, 10)
	
	--> setup class
	_setmetatable (DropDownObject, DropDownMetaFunctions)
	
	--> initialize first menu selected
	
	if (type (default) == "string") then
		DropDownObject:Select (default)
		
	elseif (type (default) == "number") then
		if (not DropDownObject:Select (default)) then
			DropDownObject:Select (default, true)
		end
	end

	return DropDownObject	

end