
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
local loadstring = loadstring --> lua local
local _string_len = string.len --> lua local

local cleanfunction = function() end
local APITextEntryFunctions = false

do
	local metaPrototype = {
		WidgetType = "textentry",
		SetHook = DF.SetHook,
		RunHooksForWidget = DF.RunHooksForWidget,
	}

	_G [DF.GlobalWidgetControlNames ["textentry"]] = _G [DF.GlobalWidgetControlNames ["textentry"]] or metaPrototype
end

local TextEntryMetaFunctions = _G [DF.GlobalWidgetControlNames ["textentry"]]
DF.TextEntryCounter = DF.TextEntryCounter or 1

------------------------------------------------------------------------------------------------------------
--> metatables

	TextEntryMetaFunctions.__call = function (_table, value)
		--> unknow
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
		return _object.editbox:GetWidth()
	end
	--> frame height
	local gmember_height = function (_object)
		return _object.editbox:GetHeight()
	end
	--> get text
	local gmember_text = function (_object)
		return _object.editbox:GetText()
	end

	TextEntryMetaFunctions.GetMembers = TextEntryMetaFunctions.GetMembers or {}
	TextEntryMetaFunctions.GetMembers ["tooltip"] = gmember_tooltip
	TextEntryMetaFunctions.GetMembers ["shown"] = gmember_shown
	TextEntryMetaFunctions.GetMembers ["width"] = gmember_width
	TextEntryMetaFunctions.GetMembers ["height"] = gmember_height
	TextEntryMetaFunctions.GetMembers ["text"] = gmember_text

	TextEntryMetaFunctions.__index = function (_table, _member_requested)
		local func = TextEntryMetaFunctions.GetMembers [_member_requested]
		if (func) then
			return func (_table, _member_requested)
		end
		
		local fromMe = _rawget (_table, _member_requested)
		if (fromMe) then
			return fromMe
		end
		
		return TextEntryMetaFunctions [_member_requested]
	end
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
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
		return _object.editbox:SetWidth (_value)
	end
	--> frame height
	local smember_height = function (_object, _value)
		return _object.editbox:SetHeight (_value)
	end
	--> set text
	local smember_text = function (_object, _value)
		return _object.editbox:SetText (_value)
	end
	--> set multiline
	local smember_multiline = function (_object, _value)
		if (_value) then
			return _object.editbox:SetMultiLine (true)
		else
			return _object.editbox:SetMultiLine (false)
		end
	end
	--> text horizontal pos
	local smember_horizontalpos = function (_object, _value)
		return _object.editbox:SetJustifyH (string.lower (_value))
	end
	
	TextEntryMetaFunctions.SetMembers = TextEntryMetaFunctions.SetMembers or {}
	TextEntryMetaFunctions.SetMembers ["tooltip"] = smember_tooltip
	TextEntryMetaFunctions.SetMembers ["show"] = smember_show
	TextEntryMetaFunctions.SetMembers ["hide"] = smember_hide
	TextEntryMetaFunctions.SetMembers ["width"] = smember_width
	TextEntryMetaFunctions.SetMembers ["height"] = smember_height
	TextEntryMetaFunctions.SetMembers ["text"] = smember_text
	TextEntryMetaFunctions.SetMembers ["multiline"] = smember_multiline
	TextEntryMetaFunctions.SetMembers ["align"] = smember_horizontalpos
	
	TextEntryMetaFunctions.__newindex = function (_table, _key, _value)
		local func = TextEntryMetaFunctions.SetMembers [_key]
		if (func) then
			return func (_table, _value)
		else
			return _rawset (_table, _key, _value)
		end
	end

------------------------------------------------------------------------------------------------------------
--> methods
	local cleanfunction = function()end
	function TextEntryMetaFunctions:SetEnterFunction (func, param1, param2)
		if (func) then
			_rawset (self, "func", func)
		else
			_rawset (self, "func", cleanfunction)
		end
		
		if (param1 ~= nil) then
			_rawset (self, "param1", param1)
		end
		if (param2 ~= nil) then
			_rawset (self, "param2", param2)
		end
	end

--> set point
	function TextEntryMetaFunctions:SetPoint (MyAnchor, SnapTo, HisAnchor, x, y, Width)
	
		if (type (MyAnchor) == "boolean" and MyAnchor and self.space) then
			local textWidth = self.label:GetStringWidth()+2
			self.editbox:SetWidth (self.space - textWidth - 15)
			return
			
		elseif (type (MyAnchor) == "boolean" and MyAnchor and not self.space) then
			self.space = self.label:GetStringWidth()+2 + self.editbox:GetWidth()
		end
		
		if (Width) then
			self.space = Width
		end
		
		MyAnchor, SnapTo, HisAnchor, x, y = DF:CheckPoints (MyAnchor, SnapTo, HisAnchor, x, y, self)
		if (not MyAnchor) then
			print ("Invalid parameter for SetPoint")
			return
		end
	
		if (self.space) then
			self.label:ClearAllPoints()
			self.editbox:ClearAllPoints()
			
			self.label:SetPoint (MyAnchor, SnapTo, HisAnchor, x, y)
			self.editbox:SetPoint ("left", self.label, "right", 2, 0)
			
			local textWidth = self.label:GetStringWidth()+2
			self.editbox:SetWidth (self.space - textWidth - 15)
		else
			self.label:ClearAllPoints()
			self.editbox:ClearAllPoints()
			self.editbox:SetPoint (MyAnchor, SnapTo, HisAnchor, x, y)
		end

	end
	
	function TextEntryMetaFunctions:SetText (text)
		self.editbox:SetText (text)
	end	
	function TextEntryMetaFunctions:GetText()
		return self.editbox:GetText()
	end
	
--> frame levels
	function TextEntryMetaFunctions:GetFrameLevel()
		return self.editbox:GetFrameLevel()
	end
	function TextEntryMetaFunctions:SetFrameLevel (level, frame)
		if (not frame) then
			return self.editbox:SetFrameLevel (level)
		else
			local framelevel = frame:GetFrameLevel (frame) + level
			return self.editbox:SetFrameLevel (framelevel)
		end
	end

--> select all text
	function TextEntryMetaFunctions:SelectAll()
		self.editbox:HighlightText()
	end
	
--> set labal description
	function TextEntryMetaFunctions:SetLabelText (text)
		if (text) then
			self.label:SetText (text)
		else
			self.label:SetText ("")
		end
		self:SetPoint (true) --> refresh
	end

--> set tab order
	function TextEntryMetaFunctions:SetNext (nextbox)
		self.next = nextbox
	end
	
--> blink
	function TextEntryMetaFunctions:Blink()
		self.label:SetTextColor (1, .2, .2, 1)
	end	
	
--> show & hide
	function TextEntryMetaFunctions:IsShown()
		return self.editbox:IsShown()
	end
	function TextEntryMetaFunctions:Show()
		return self.editbox:Show()
	end
	function TextEntryMetaFunctions:Hide()
		return self.editbox:Hide()
	end
	
-- tooltip
	function TextEntryMetaFunctions:SetTooltip (tooltip)
		if (tooltip) then
			return _rawset (self, "have_tooltip", tooltip)
		else
			return _rawset (self, "have_tooltip", nil)
		end
	end
	function TextEntryMetaFunctions:GetTooltip()
		return _rawget (self, "have_tooltip")
	end
	
--> hooks
	function TextEntryMetaFunctions:Enable()
		if (not self.editbox:IsEnabled()) then
			self.editbox:Enable()
			self.editbox:SetBackdropBorderColor (unpack (self.enabled_border_color))
			self.editbox:SetBackdropColor (unpack (self.enabled_backdrop_color))
			self.editbox:SetTextColor (unpack (self.enabled_text_color))
			if (self.editbox.borderframe) then
				self.editbox.borderframe:SetBackdropColor (unpack (self.editbox.borderframe.onleave_backdrop))
			end
		end
	end
	
	function TextEntryMetaFunctions:Disable()
		if (self.editbox:IsEnabled()) then
			self.enabled_border_color = {self.editbox:GetBackdropBorderColor()}
			self.enabled_backdrop_color = {self.editbox:GetBackdropColor()}
			self.enabled_text_color = {self.editbox:GetTextColor()}

			self.editbox:Disable()

			self.editbox:SetBackdropBorderColor (.5, .5, .5, .5)
			self.editbox:SetBackdropColor (.5, .5, .5, .5)
			self.editbox:SetTextColor (.5, .5, .5, .5)
			
			if (self.editbox.borderframe) then
				self.editbox.borderframe:SetBackdropColor (.5, .5, .5, .5)
			end
		end
	end
	
------------------------------------------------------------------------------------------------------------
--> scripts and hooks

	local OnEnter = function (textentry)
		local capsule = textentry.MyObject
		
		local kill = capsule:RunHooksForWidget ("OnEnter", textentry, capsule)
		if (kill) then
			return
		end

		if (capsule.have_tooltip) then 
			GameCooltip2:Preset (2)
			GameCooltip2:AddLine (capsule.have_tooltip)
			GameCooltip2:ShowCooltip (textentry, "tooltip")
		end
		
		textentry.mouse_over = true 

		if (textentry:IsEnabled()) then 
			textentry.current_bordercolor = textentry.current_bordercolor or {textentry:GetBackdropBorderColor()}
			textentry:SetBackdropBorderColor (1, 1, 1, 1)
		end
	end
	
	local OnLeave = function (textentry)
		local capsule = textentry.MyObject
	
		local kill = capsule:RunHooksForWidget ("OnLeave", textentry, capsule)
		if (kill) then
			return
		end

		if (textentry.MyObject.have_tooltip) then 
			GameCooltip2:ShowMe (false)
		end
		
		textentry.mouse_over = false 
		
		if (textentry:IsEnabled()) then 
			textentry:SetBackdropBorderColor (unpack (textentry.current_bordercolor))
		end
	end
	
	local OnHide = function (textentry)
		local capsule = textentry.MyObject
		
		local kill = capsule:RunHooksForWidget ("OnHide", textentry, capsule)
		if (kill) then
			return
		end
	end
	
	local OnShow = function (textentry)
		local capsule = textentry.MyObject
		
		local kill = capsule:RunHooksForWidget ("OnShow", textentry, capsule)
		if (kill) then
			return
		end
	end

	local OnEnterPressed = function (textentry, byScript)
		local capsule = textentry.MyObject
	
		local kill = capsule:RunHooksForWidget ("OnEnterPressed", textentry, capsule)
		if (kill) then
			return
		end
	
		local texto = DF:trim (textentry:GetText())
		if (_string_len (texto) > 0) then 
			textentry.text = texto
			if (textentry.MyObject.func) then 
				textentry.MyObject.func (textentry.MyObject.param1, textentry.MyObject.param2, texto, textentry, byScript or textentry)
			end
		else
			textentry:SetText ("")
			textentry.MyObject.currenttext = ""
		end
		
		if (not capsule.NoClearFocusOnEnterPressed) then
			textentry.focuslost = true --> quando estiver editando e clicar em outra caixa
			textentry:ClearFocus()
			
			if (textentry.MyObject.tab_on_enter and textentry.MyObject.next) then
				textentry.MyObject.next:SetFocus()
			end
		end
	end
	
	local OnEscapePressed = function (textentry)
		local capsule = textentry.MyObject
	
		local kill = capsule:RunHooksForWidget ("OnEscapePressed", textentry, capsule)
		if (kill) then
			return
		end	

		textentry.focuslost = true
		textentry:ClearFocus() 
	end
	
	local OnSpacePressed = function (textentry)
		local capsule = textentry.MyObject
		
		local kill = capsule:RunHooksForWidget ("OnSpacePressed", textentry, capsule)
		if (kill) then
			return
		end
	end
	
	local OnEditFocusLost = function (textentry)

		local capsule = textentry.MyObject
	
		if (textentry:IsShown()) then
		
			local kill = capsule:RunHooksForWidget ("OnEditFocusLost", textentry, capsule)
			if (kill) then
				return
			end
		
			if (not textentry.focuslost) then
				local texto = DF:trim (textentry:GetText())
				if (_string_len (texto) > 0) then 
					textentry.MyObject.currenttext = texto
					if (textentry.MyObject.func) then 
						textentry.MyObject.func (textentry.MyObject.param1, textentry.MyObject.param2, texto, textentry, nil)
					end
				else 
					textentry:SetText ("") 
					textentry.MyObject.currenttext = ""
				end 
			else
				textentry.focuslost = false
			end
			
			textentry.MyObject.label:SetTextColor (.8, .8, .8, 1)

		end
	end
	
	local OnEditFocusGained = function (textentry)
	
		local capsule = textentry.MyObject
		
		local kill = capsule:RunHooksForWidget ("OnEditFocusGained", textentry, capsule)
		if (kill) then
			return
		end

		textentry.MyObject.label:SetTextColor (1, 1, 1, 1)
	end
	
	local OnChar = function (textentry, char)
		local capsule = textentry.MyObject
	
		local kill = capsule:RunHooksForWidget ("OnChar", textentry, char, capsule)
		if (kill) then
			return
		end
	end
	
	local OnTextChanged = function (textentry, byUser) 
		local capsule = textentry.MyObject
		
		local kill = capsule:RunHooksForWidget ("OnTextChanged", textentry, byUser, capsule)
		if (kill) then
			return
		end
	end
	
	local OnTabPressed = function (textentry) 
	
		local capsule = textentry.MyObject
	
		local kill = capsule:RunHooksForWidget ("OnTabPressed", textentry, byUser, capsule)
		if (kill) then
			return
		end
		
		if (textentry.MyObject.next) then 
			OnEnterPressed (textentry, false)
			textentry.MyObject.next:SetFocus()
		end
	end
	
	function TextEntryMetaFunctions:PressEnter (byScript)
		OnEnterPressed (self.editbox, byScript)
	end
	
------------------------------------------------------------------------------------------------------------

function TextEntryMetaFunctions:SetTemplate (template)
	if (template.width) then
		self.editbox:SetWidth (template.width)
	end
	if (template.height) then
		self.editbox:SetHeight (template.height)
	end
	
	if (template.backdrop) then
		self.editbox:SetBackdrop (template.backdrop)
	end
	if (template.backdropcolor) then
		local r, g, b, a = DF:ParseColors (template.backdropcolor)
		self.editbox:SetBackdropColor (r, g, b, a)
		self.onleave_backdrop = {r, g, b, a}
	end
	if (template.backdropbordercolor) then
		local r, g, b, a = DF:ParseColors (template.backdropbordercolor)
		self.editbox:SetBackdropBorderColor (r, g, b, a)
		self.editbox.current_bordercolor[1] = r
		self.editbox.current_bordercolor[2] = g
		self.editbox.current_bordercolor[3] = b
		self.editbox.current_bordercolor[4] = a
		self.onleave_backdrop_border_color = {r, g, b, a}
	end
end

------------------------------------------------------------------------------------------------------------
--> object constructor

function DF:CreateTextEntry (parent, func, w, h, member, name, with_label, entry_template, label_template)
	return DF:NewTextEntry (parent, parent, name, member, w, h, func, nil, nil, nil, with_label, entry_template, label_template)
end

function DF:NewTextEntry (parent, container, name, member, w, h, func, param1, param2, space, with_label, entry_template, label_template)
	
	if (not name) then
		name = "DetailsFrameworkTextEntryNumber" .. DF.TextEntryCounter
		DF.TextEntryCounter = DF.TextEntryCounter + 1
		
	elseif (not parent) then
		return error ("Details! FrameWork: parent not found.", 2)
	end
	
	if (not container) then
		container = parent
	end
	
	if (name:find ("$parent")) then
		local parentName = DF.GetParentName (parent)
		name = name:gsub ("$parent", parentName)
	end
	
	local TextEntryObject = {type = "textentry", dframework = true}
	
	if (member) then
		parent [member] = TextEntryObject
	end

	if (parent.dframework) then
		parent = parent.widget
	end
	if (container.dframework) then
		container = container.widget
	end
	
	--> default members:
		--> hooks
		TextEntryObject.OnEnterHook = nil
		TextEntryObject.OnLeaveHook = nil
		TextEntryObject.OnHideHook = nil
		TextEntryObject.OnShowHook = nil
		TextEntryObject.OnEnterPressedHook = nil
		TextEntryObject.OnEscapePressedHook = nil
		TextEntryObject.OnEditFocusGainedHook = nil
		TextEntryObject.OnEditFocusLostHook = nil
		TextEntryObject.OnCharHook = nil
		TextEntryObject.OnTextChangedHook = nil
		TextEntryObject.OnTabPressedHook = nil

		--> misc
		TextEntryObject.container = container
		TextEntryObject.have_tooltip = nil

	TextEntryObject.editbox = CreateFrame ("EditBox", name, parent, "DetailsFrameworkEditBoxTemplate2")
	TextEntryObject.widget = TextEntryObject.editbox
	
	TextEntryObject.editbox:SetTextInsets (3, 0, 0, -3)

	if (not APITextEntryFunctions) then
		APITextEntryFunctions = true
		local idx = getmetatable (TextEntryObject.editbox).__index
		for funcName, funcAddress in pairs (idx) do 
			if (not TextEntryMetaFunctions [funcName]) then
				TextEntryMetaFunctions [funcName] = function (object, ...)
					local x = loadstring ( "return _G['"..object.editbox:GetName().."']:"..funcName.."(...)")
					return x (...)
				end
			end
		end
	end
	
	TextEntryObject.editbox.MyObject = TextEntryObject
	
	if (not w and space) then
		w = space
	elseif (w and space) then
		if (DF.debug) then
			--print ("warning: you are using width and space, try use only space for better results.")
		end
	end
	
	TextEntryObject.editbox:SetWidth (w)
	TextEntryObject.editbox:SetHeight (h)

	TextEntryObject.editbox:SetJustifyH ("center")
	TextEntryObject.editbox:EnableMouse (true)
	TextEntryObject.editbox:SetText ("")

	TextEntryObject.editbox:SetAutoFocus (false)
	TextEntryObject.editbox:SetFontObject ("GameFontHighlightSmall")

	TextEntryObject.editbox.current_bordercolor = {1, 1, 1, 0.7}
	TextEntryObject.editbox:SetBackdropBorderColor (1, 1, 1, 0.7)
	TextEntryObject.enabled_border_color = {TextEntryObject.editbox:GetBackdropBorderColor()}
	TextEntryObject.enabled_backdrop_color = {TextEntryObject.editbox:GetBackdropColor()}
	TextEntryObject.enabled_text_color = {TextEntryObject.editbox:GetTextColor()}
	TextEntryObject.onleave_backdrop = {TextEntryObject.editbox:GetBackdropColor()}
	TextEntryObject.onleave_backdrop_border_color = {TextEntryObject.editbox:GetBackdropBorderColor()}
	
	TextEntryObject.func = func
	TextEntryObject.param1 = param1
	TextEntryObject.param2 = param2
	TextEntryObject.next = nil
	TextEntryObject.space = space
	TextEntryObject.tab_on_enter = false
	
	TextEntryObject.label = _G [name .. "_Desc"]
	
	TextEntryObject.editbox:SetBackdrop ({bgFile = DF.folder .. "background", tileSize = 64, edgeFile = DF.folder .. "border_2", edgeSize = 10, insets = {left = 1, right = 1, top = 1, bottom = 1}})
	
	--> hooks
	
		TextEntryObject.HookList = {
			OnEnter = {},
			OnLeave = {},
			OnHide = {},
			OnShow = {},
			OnEnterPressed = {},
			OnEscapePressed = {},
			OnSpacePressed = {},
			OnEditFocusLost = {},
			OnEditFocusGained = {},
			OnChar = {},
			OnTextChanged = {},
			OnTabPressed = {},
		}
		
		TextEntryObject.editbox:SetScript ("OnEnter", OnEnter)
		TextEntryObject.editbox:SetScript ("OnLeave", OnLeave)
		TextEntryObject.editbox:SetScript ("OnHide", OnHide)
		TextEntryObject.editbox:SetScript ("OnShow", OnShow)
		
		TextEntryObject.editbox:SetScript ("OnEnterPressed", OnEnterPressed)
		TextEntryObject.editbox:SetScript ("OnEscapePressed", OnEscapePressed)
		TextEntryObject.editbox:SetScript ("OnSpacePressed", OnSpacePressed)
		TextEntryObject.editbox:SetScript ("OnEditFocusLost", OnEditFocusLost)
		TextEntryObject.editbox:SetScript ("OnEditFocusGained", OnEditFocusGained)
		TextEntryObject.editbox:SetScript ("OnChar", OnChar)
		TextEntryObject.editbox:SetScript ("OnTextChanged", OnTextChanged)
		TextEntryObject.editbox:SetScript ("OnTabPressed", OnTabPressed)
		
	_setmetatable (TextEntryObject, TextEntryMetaFunctions)
	
	if (with_label) then
		local label = DF:CreateLabel (TextEntryObject.editbox, with_label, nil, nil, nil, "label", nil, "overlay")
		label.text = with_label
		TextEntryObject.editbox:SetPoint ("left", label.widget, "right", 2, 0)
		if (label_template) then
			label:SetTemplate (label_template)
		end
		with_label = label
	end
	
	if (entry_template) then
		TextEntryObject:SetTemplate (entry_template)
	end	
	
	return TextEntryObject, with_label
	
end

function DF:NewSpellEntry (parent, func, w, h, param1, param2, member, name)
	local editbox = DF:NewTextEntry (parent, parent, name, member, w, h, func, param1, param2)
	
--	editbox:SetHook ("OnEditFocusGained", SpellEntryOnEditFocusGained)
--	editbox:SetHook ("OnTextChanged", SpellEntryOnTextChanged)
	
	return editbox	
end

local function_gettext = function (self)
	return self.editbox:GetText()
end
local function_settext = function (self, text)
	return self.editbox:SetText (text)
end
local function_clearfocus = function (self)
	return self.editbox:ClearFocus()
end
local function_setfocus = function (self)
	return self.editbox:SetFocus (true)
end

function DF:NewSpecialLuaEditorEntry (parent, w, h, member, name, nointent)
	
	if (name:find ("$parent")) then
		local parentName = DF.GetParentName (parent)
		name = name:gsub ("$parent", parentName)
	end
	
	local borderframe = CreateFrame ("Frame", name, parent)
	borderframe:SetSize (w, h)

	if (member) then
		parent [member] = borderframe
	end
	
	local scrollframe = CreateFrame ("ScrollFrame", name, borderframe, "DetailsFrameworkEditBoxMultiLineTemplate")

	scrollframe:SetScript ("OnSizeChanged", function (self)
		scrollframe.editbox:SetSize (self:GetSize())
	end)
	
	scrollframe:SetPoint ("topleft", borderframe, "topleft", 10, -10)
	scrollframe:SetPoint ("bottomright", borderframe, "bottomright", -30, 10)
	
	scrollframe.editbox:SetMultiLine (true)
	scrollframe.editbox:SetJustifyH ("left")
	scrollframe.editbox:SetJustifyV ("top")
	scrollframe.editbox:SetMaxBytes (1024000)
	scrollframe.editbox:SetMaxLetters (128000)
	
	borderframe.GetText = function_gettext
	borderframe.SetText = function_settext
	borderframe.ClearFocus = function_clearfocus
	borderframe.SetFocus = function_setfocus
	
	borderframe.Enable = TextEntryMetaFunctions.Enable
	borderframe.Disable = TextEntryMetaFunctions.Disable
	
	borderframe.SetTemplate = TextEntryMetaFunctions.SetTemplate
	
	if (not nointent) then
		IndentationLib.enable (scrollframe.editbox, nil, 4)
	end
	
	borderframe:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], 
		tile = 1, tileSize = 16, edgeSize = 16, insets = {left = 5, right = 5, top = 5, bottom = 5}})
	
	scrollframe.editbox.current_bordercolor = {1, 1, 1, 0.7}
	borderframe:SetBackdropBorderColor (1, 1, 1, 0.7)
	borderframe:SetBackdropColor (0.090195, 0.090195, 0.188234, 1)
	
	borderframe.enabled_border_color = {borderframe:GetBackdropBorderColor()}
	borderframe.enabled_backdrop_color = {borderframe:GetBackdropColor()}
	borderframe.enabled_text_color = {scrollframe.editbox:GetTextColor()}

	borderframe.onleave_backdrop = {scrollframe.editbox:GetBackdropColor()}
	borderframe.onleave_backdrop_border_color = {scrollframe.editbox:GetBackdropBorderColor()}
	
	borderframe.scroll = scrollframe
	borderframe.editbox = scrollframe.editbox
	borderframe.editbox.borderframe = borderframe
	
	return borderframe
end


------------------------------------------------------------------------------------
--auto complete

-- block -------------------
--code author Saiket from  http://www.wowinterface.com/forums/showpost.php?p=245759&postcount=6
--- @return StartPos, EndPos of highlight in this editbox.
local function GetTextHighlight ( self )
	local Text, Cursor = self:GetText(), self:GetCursorPosition();
	self:Insert( "" ); -- Delete selected text
	local TextNew, CursorNew = self:GetText(), self:GetCursorPosition();
	-- Restore previous text
	self:SetText( Text );
	self:SetCursorPosition( Cursor );
	local Start, End = CursorNew, #Text - ( #TextNew - CursorNew );
	self:HighlightText( Start, End );
	return Start, End;
end
local StripColors;
do
	local CursorPosition, CursorDelta;
	--- Callback for gsub to remove unescaped codes.
	local function StripCodeGsub ( Escapes, Code, End )
		if ( #Escapes % 2 == 0 ) then -- Doesn't escape Code
			if ( CursorPosition and CursorPosition >= End - 1 ) then
				CursorDelta = CursorDelta - #Code;
			end
			return Escapes;
		end
	end
	--- Removes a single escape sequence.
	local function StripCode ( Pattern, Text, OldCursor )
		CursorPosition, CursorDelta = OldCursor, 0;
		return Text:gsub( Pattern, StripCodeGsub ), OldCursor and CursorPosition + CursorDelta;
	end
	--- Strips Text of all color escape sequences.
	-- @param Cursor  Optional cursor position to keep track of.
	-- @return Stripped text, and the updated cursor position if Cursor was given.
	function StripColors ( Text, Cursor )
		Text, Cursor = StripCode( "(|*)(|c%x%x%x%x%x%x%x%x)()", Text, Cursor );
		return StripCode( "(|*)(|r)()", Text, Cursor );
	end
end

local COLOR_END = "|r";
--- Wraps this editbox's selected text with the given color.
local function ColorSelection ( self, ColorCode )
	local Start, End = GetTextHighlight( self );
	local Text, Cursor = self:GetText(), self:GetCursorPosition();
	if ( Start == End ) then -- Nothing selected
		--Start, End = Cursor, Cursor; -- Wrap around cursor
		return; -- Wrapping the cursor in a color code and hitting backspace crashes the client!
	end
	-- Find active color code at the end of the selection
	local ActiveColor;
	if ( End < #Text ) then -- There is text to color after the selection
		local ActiveEnd;
		local CodeEnd, _, Escapes, Color = 0;
		while ( true ) do
			_, CodeEnd, Escapes, Color = Text:find( "(|*)(|c%x%x%x%x%x%x%x%x)", CodeEnd + 1 );
			if ( not CodeEnd or CodeEnd > End ) then
				break;
			end
			if ( #Escapes % 2 == 0 ) then -- Doesn't escape Code
				ActiveColor, ActiveEnd = Color, CodeEnd;
			end
		end

		if ( ActiveColor ) then
			-- Check if color gets terminated before selection ends
			CodeEnd = 0;
			while ( true ) do
				_, CodeEnd, Escapes = Text:find( "(|*)|r", CodeEnd + 1 );
				if ( not CodeEnd or CodeEnd > End ) then
					break;
				end
				if ( CodeEnd > ActiveEnd and #Escapes % 2 == 0 ) then -- Terminates ActiveColor
					ActiveColor = nil;
					break;
				end
			end
		end
	end

	local Selection = Text:sub( Start + 1, End );
	-- Remove color codes from the selection
	local Replacement, CursorReplacement = StripColors( Selection, Cursor - Start );

	self:SetText( ( "" ):join(
		Text:sub( 1, Start ),
		ColorCode, Replacement, COLOR_END,
		ActiveColor or "", Text:sub( End + 1 )
	) );

	-- Restore cursor and highlight, adjusting for wrapper text
	Cursor = Start + CursorReplacement;
	if ( CursorReplacement > 0 ) then -- Cursor beyond start of color code
		Cursor = Cursor + #ColorCode;
	end
	if ( CursorReplacement >= #Replacement ) then -- Cursor beyond end of color
		Cursor = Cursor + #COLOR_END;
	end
	
	self:SetCursorPosition( Cursor );
	-- Highlight selection and wrapper
	self:HighlightText( Start, #ColorCode + ( #Replacement - #Selection ) + #COLOR_END + End );
end
-- end of the block ---------------------

local get_last_word = function (self)
	self.lastword = ""
	local cursor_pos = self.editbox:GetCursorPosition()
	local text = self.editbox:GetText()
	for i = cursor_pos, 1, -1 do
		local character = text:sub (i, i)
		if (character:match ("%a")) then
			self.lastword = character .. self.lastword
		else
			break
		end
	end
end

--On Text Changed
local AutoComplete_OnTextChanged = function (editboxWidget, byUser, capsule)
	capsule = capsule or editboxWidget.MyObject
	
	local chars_now = editboxWidget:GetText():len()
	if (not editboxWidget.ignore_textchange) then
		--> backspace
		if (chars_now == capsule.characters_count -1) then
			capsule.lastword = capsule.lastword:sub (1, capsule.lastword:len()-1)
		--> delete lots of text
		elseif (chars_now < capsule.characters_count) then
			--o auto complete selecionou outra palavra bem menor e caiu nesse filtro
			editboxWidget.end_selection = nil
			capsule:GetLastWord()
		end
	else
		editboxWidget.ignore_textchange = nil
	end
	capsule.characters_count = chars_now
end

local AutoComplete_OnSpacePressed = function (editboxWidget, capsule)
	capsule = capsule or editboxWidget.MyObject

--	if (not gotMatch) then
		--editboxWidget.end_selection = nil
--	end
end

local AutoComplete_OnEscapePressed = function (editboxWidget)
	editboxWidget.end_selection = nil
end

local AutoComplete_OnEnterPressed = function (editboxWidget)

	local capsule = editboxWidget.MyObject
	if (editboxWidget.end_selection) then
		editboxWidget:SetCursorPosition (editboxWidget.end_selection)
		editboxWidget:HighlightText (0, 0)
		editboxWidget.end_selection = nil
		--editboxWidget:Insert (" ") --estava causando a adição de uma palavra a mais quando o próximo catactere for um espaço
	else
		if (editboxWidget:IsMultiLine()) then
			editboxWidget:Insert ("\n")
			--reseta a palavra se acabou de ganhar focus e apertou enter
			if (editboxWidget.focusGained) then
				capsule.lastword = ""
				editboxWidget.focusGained = nil
			end
		else
			editboxWidget:Insert ("")
			editboxWidget.focuslost = true
			editboxWidget:ClearFocus()
		end
	end
	capsule.lastword = ""

end

local AutoComplete_OnEditFocusGained = function (editboxWidget)
	local capsule = editboxWidget.MyObject
	capsule:GetLastWord()
	editboxWidget.end_selection = nil
	editboxWidget.focusGained = true
	capsule.characters_count = editboxWidget:GetText():len()	
end

local AutoComplete_OnChar = function (editboxWidget, char, capsule)
	if (char == "") then
		return
	end
	
	capsule = capsule or editboxWidget.MyObject
 	editboxWidget.end_selection = nil
	
	if (editboxWidget.ignore_input) then
		return
	end
	
	--reseta a palavra se acabou de ganhar focus e apertou espaço
	if (editboxWidget.focusGained and char == " ") then
		capsule.lastword = ""
		editboxWidget.focusGained = nil
	else
		editboxWidget.focusGained = nil
	end
	
	if (char:match ("%a") or (char == " " and capsule.lastword ~= "")) then
		capsule.lastword = capsule.lastword .. char
	else
		capsule.lastword = ""
	end
	
	editboxWidget.ignore_input = true
	if (capsule.lastword:len() >= 2) then
	
		local wordList = capsule [capsule.poolName]
		if (not wordList) then
			if (DF.debug) then
				error ("Details! Framework: Invalid word list table.")
			end
			return
		end
	
		for i = 1, #wordList do
			local thisWord = wordList [i]
			if (thisWord and (thisWord:find ("^" .. capsule.lastword) or thisWord:lower():find ("^" .. capsule.lastword))) then
				local rest = thisWord:gsub (capsule.lastword, "")
				rest = rest:lower():gsub (capsule.lastword, "")
				local cursor_pos = editboxWidget:GetCursorPosition()
				editboxWidget:Insert (rest)
				editboxWidget:HighlightText (cursor_pos, cursor_pos + rest:len())
				editboxWidget:SetCursorPosition (cursor_pos)
				editboxWidget.end_selection = cursor_pos + rest:len()
				editboxWidget.ignore_textchange = true
				break
			end
		end
	
	end
	editboxWidget.ignore_input = false
end

function TextEntryMetaFunctions:SetAsAutoComplete (poolName)
	
	self.lastword = ""
	self.characters_count = 0
	self.poolName = poolName
	self.GetLastWord = get_last_word --editbox:GetLastWord()
	self.NoClearFocusOnEnterPressed = true --avoid auto clear focus
	
	self:SetHook ("OnEditFocusGained", AutoComplete_OnEditFocusGained)
	self.editbox:HookScript ("OnEscapePressed", AutoComplete_OnEscapePressed)
	
--	self:SetHook ("OnTextChanged", AutoComplete_OnTextChanged)
	self:SetHook ("OnEnterPressed", AutoComplete_OnEnterPressed)
--	self:SetHook ("OnChar", AutoComplete_OnChar)
--	self:SetHook ("OnSpacePressed", AutoComplete_OnSpacePressed)
	
	self.editbox:SetScript ("OnTextChanged", AutoComplete_OnTextChanged)
--	self.editbox:SetScript ("OnEnterPressed", AutoComplete_OnEnterPressed)
	self.editbox:SetScript ("OnChar", AutoComplete_OnChar)
	self.editbox:SetScript ("OnSpacePressed", AutoComplete_OnSpacePressed)

end

-- endp