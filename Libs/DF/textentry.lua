
--[=[
	When enter is pressed a callback function is called in this format:

	local onEnterPressed = function(parameter1, parameter2, text, self, byScript)
		--parameter1 and parameter2 are set with self:SetParameters(param1, param2)
		--they act like fixed parameters for the callback
		--use they to use a single function for multiple text entries
	end
	
textentry.MyObject.func(textentry.MyObject.param1, textentry.MyObject.param2, text, textentry, byScript or textentry)

--]=]

local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
local APITextEntryFunctions = false

do
	local metaPrototype = {
		WidgetType = "textentry",
		dversion = detailsFramework.dversion,
	}

	--check if there's a metaPrototype already existing
	if (_G[detailsFramework.GlobalWidgetControlNames["textentry"]]) then
		--get the already existing metaPrototype
		local oldMetaPrototype = _G[detailsFramework.GlobalWidgetControlNames["textentry"]]
		--check if is older
		if ( (not oldMetaPrototype.dversion) or (oldMetaPrototype.dversion < detailsFramework.dversion) ) then
			--the version is older them the currently loading one
			--copy the new values into the old metatable
			for funcName, _ in pairs(metaPrototype) do
				oldMetaPrototype[funcName] = metaPrototype[funcName]
			end
		end
	else
		--first time loading the framework
		_G[detailsFramework.GlobalWidgetControlNames["textentry"]] = metaPrototype
	end
end

local TextEntryMetaFunctions = _G[detailsFramework.GlobalWidgetControlNames["textentry"]]

detailsFramework:Mixin(TextEntryMetaFunctions, detailsFramework.SetPointMixin)
detailsFramework:Mixin(TextEntryMetaFunctions, detailsFramework.FrameMixin)
detailsFramework:Mixin(TextEntryMetaFunctions, detailsFramework.TooltipHandlerMixin)
detailsFramework:Mixin(TextEntryMetaFunctions, detailsFramework.ScriptHookMixin)

detailsFramework.TextEntryCounter = detailsFramework.TextEntryCounter or 1

------------------------------------------------------------------------------------------------------------
--metatables

	TextEntryMetaFunctions.__call = function(object, value)
	end

------------------------------------------------------------------------------------------------------------
--members
	--tooltip
	local gmember_tooltip = function(object)
		return object:GetTooltip()
	end

	--shown
	local gmember_shown = function(object)
		return object:IsShown()
	end

	--frame width
	local gmember_width = function(object)
		return object.editbox:GetWidth()
	end

	--frame height
	local gmember_height = function(object)
		return object.editbox:GetHeight()
	end

	--get text
	local gmember_text = function(object)
		return object.editbox:GetText()
	end

	--return if the text entry has focus
	local gmember_hasfocus = function(object)
		return object:HasFocus()
	end

	TextEntryMetaFunctions.GetMembers = TextEntryMetaFunctions.GetMembers or {}
	TextEntryMetaFunctions.GetMembers["tooltip"] = gmember_tooltip
	TextEntryMetaFunctions.GetMembers["shown"] = gmember_shown
	TextEntryMetaFunctions.GetMembers["width"] = gmember_width
	TextEntryMetaFunctions.GetMembers["height"] = gmember_height
	TextEntryMetaFunctions.GetMembers["text"] = gmember_text
	TextEntryMetaFunctions.GetMembers["hasfocus"] = gmember_hasfocus

	TextEntryMetaFunctions.__index = function(object, key)
		local func = TextEntryMetaFunctions.GetMembers[key]
		if (func) then
			return func(object, key)
		end

		local fromMe = rawget(object, key)
		if (fromMe) then
			return fromMe
		end

		return TextEntryMetaFunctions[key]
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--tooltip
	local smember_tooltip = function(object, value)
		return object:SetTooltip(value)
	end

	--show
	local smember_show = function(object, value)
		if (value) then
			return object:Show()
		else
			return object:Hide()
		end
	end

	--hide
	local smember_hide = function(object, value)
		if (not value) then
			return object:Show()
		else
			return object:Hide()
		end
	end

	--frame width
	local smember_width = function(object, value)
		return object.editbox:SetWidth(value)
	end

	--frame height
	local smember_height = function(object, value)
		return object.editbox:SetHeight(value)
	end

	--set text
	local smember_text = function(object, value)
		return object.editbox:SetText(value)
	end

	--set multiline
	local smember_multiline = function(object, value)
		if (value) then
			return object.editbox:SetMultiLine(true)
		else
			return object.editbox:SetMultiLine(false)
		end
	end

	local smember_fontsize = function(object, value)
		return detailsFramework:SetFontSize(object.editbox, value)
	end

	--text horizontal pos
	local smember_horizontalpos = function(object, value)
		return object.editbox:SetJustifyH(string.lower(value))
	end

	TextEntryMetaFunctions.SetMembers = TextEntryMetaFunctions.SetMembers or {}
	TextEntryMetaFunctions.SetMembers["tooltip"] = smember_tooltip
	TextEntryMetaFunctions.SetMembers["show"] = smember_show
	TextEntryMetaFunctions.SetMembers["hide"] = smember_hide
	TextEntryMetaFunctions.SetMembers["width"] = smember_width
	TextEntryMetaFunctions.SetMembers["height"] = smember_height
	TextEntryMetaFunctions.SetMembers["text"] = smember_text
	TextEntryMetaFunctions.SetMembers["multiline"] = smember_multiline
	TextEntryMetaFunctions.SetMembers["align"] = smember_horizontalpos
	TextEntryMetaFunctions.SetMembers["fontsize"] = smember_fontsize
	TextEntryMetaFunctions.SetMembers["textsize"] = smember_fontsize

	TextEntryMetaFunctions.__newindex = function(object, key, value)
		local func = TextEntryMetaFunctions.SetMembers[key]
		if (func) then
			return func(object, value)
		else
			return rawset(object, key, value)
		end
	end

------------------------------------------------------------------------------------------------------------
--methods

	local cleanfunction = function()end
	function TextEntryMetaFunctions:SetEnterFunction(func, param1, param2)
		if (func) then
			rawset(self, "func", func)
		else
			rawset(self, "func", cleanfunction)
		end

		if (param1 ~= nil) then
			rawset(self, "param1", param1)
		end
		if (param2 ~= nil) then
			rawset(self, "param2", param2)
		end
	end

	function TextEntryMetaFunctions:SetText(text)
		self.editbox:SetText(text)
	end

	function TextEntryMetaFunctions:GetText()
		return self.editbox:GetText()
	end

	--select all text
	function TextEntryMetaFunctions:SelectAll()
		self.editbox:HighlightText()
	end

	function TextEntryMetaFunctions:SetAutoSelectTextOnFocus(value)
		self.autoSelectAllText = value
	end

	--set label description
	function TextEntryMetaFunctions:SetLabelText(text)
		self.label:SetText(text)
	end

	--set tab order
	function TextEntryMetaFunctions:SetNext(nextbox)
		self.next = nextbox
	end

	function TextEntryMetaFunctions:SetParameters(param1, param2)
		if (param1 ~= nil) then
			self.param1 = param1
		end

		if (param2 ~= nil) then
			self.param2 = param2
		end
	end

	--blink
	function TextEntryMetaFunctions:Blink()
		self.label:SetTextColor(1, .2, .2, 1)
	end

	--hooks
	function TextEntryMetaFunctions:Enable()
		if (not self.editbox:IsEnabled()) then
			self.editbox:Enable()
			self.editbox:SetBackdropBorderColor(unpack(self.enabled_border_color))
			self.editbox:SetBackdropColor(unpack(self.enabled_backdrop_color))
			self.editbox:SetTextColor(unpack(self.enabled_text_color))
			if (self.editbox.borderframe) then
				local r, g, b, a = detailsFramework:ParseColors(unpack(self.editbox.borderframe.onleave_backdrop))
				self.editbox.borderframe:SetBackdropColor(r, g, b, a)
			end
		end
	end

	function TextEntryMetaFunctions:Disable()
		if (self.editbox:IsEnabled()) then
			self.enabled_border_color = {self.editbox:GetBackdropBorderColor()}
			self.enabled_backdrop_color = {self.editbox:GetBackdropColor()}
			self.enabled_text_color = {self.editbox:GetTextColor()}

			self.editbox:Disable()

			self.editbox:SetBackdropBorderColor(0, 0, 0, 1)
			self.editbox:SetBackdropColor(.1, .1, .1, .834)
			self.editbox:SetTextColor(.5, .5, .5, .5)

			if (self.editbox.borderframe) then
				self.editbox.borderframe:SetBackdropColor(.5, .5, .5, .5)
			end
		end
	end

	function TextEntryMetaFunctions:SetCommitFunction(func)
		if (type(func) == "function") then
			self.func = func
		end
	end

	function TextEntryMetaFunctions:IgnoreNextCallback()
		self.ignoreNextCallback = true
	end

------------------------------------------------------------------------------------------------------------
--scripts and hooks

	local OnEnter = function(textentry)
		local object = textentry.MyObject
		local kill = object:RunHooksForWidget("OnEnter", textentry, object)
		if (kill) then
			return
		end

		object:ShowTooltip()

		textentry.mouse_over = true

		if (textentry:IsEnabled()) then
			textentry.current_bordercolor = textentry.current_bordercolor or {textentry:GetBackdropBorderColor()}
			local onEnterBorderColor = object.onenter_backdrop_border_color
			if (onEnterBorderColor) then
				textentry:SetBackdropBorderColor(detailsFramework:ParseColors(onEnterBorderColor))
			else
				textentry:SetBackdropBorderColor(1, 1, 1, 0.6)
			end
		end
	end

	local OnLeave = function(textentry)
		local object = textentry.MyObject
		local kill = object:RunHooksForWidget("OnLeave", textentry, object)
		if (kill) then
			return
		end

		object:HideTooltip()

		textentry.mouse_over = false

		if (textentry:IsEnabled()) then
			textentry:SetBackdropBorderColor(unpack(textentry.current_bordercolor))
		end
	end

	local OnHide = function(textentry)
		local object = textentry.MyObject
		local kill = object:RunHooksForWidget("OnHide", textentry, object)
		if (kill) then
			return
		end
	end

	local OnShow = function(textentry)
		local object = textentry.MyObject
		local kill = object:RunHooksForWidget("OnShow", textentry, object)
		if (kill) then
			return
		end
	end

	local OnEnterPressed = function(textentry, byScript)
		local object = textentry.MyObject
		if (object.ignoreNextCallback) then
			detailsFramework.Schedules.RunNextTick(function() object.ignoreNextCallback = nil end)
			return
		end

		local kill = object:RunHooksForWidget("OnEnterPressed", textentry, object, object.text)
		if (kill) then
			return
		end

		local text = detailsFramework:Trim(textentry:GetText())
		if (string.len(text) > 0) then
			textentry.text = text
			if (textentry.MyObject.func) then
				--need to have a dispatch here
				textentry.MyObject.func(textentry.MyObject.param1, textentry.MyObject.param2, text, textentry, byScript or textentry)
			end
		else
			textentry:SetText("")
			textentry.MyObject.currenttext = ""
		end

		if (not object.NoClearFocusOnEnterPressed) then
			textentry.focuslost = true --quando estiver editando e clicar em outra caixa
			textentry:ClearFocus()
			if (textentry.MyObject.tab_on_enter and textentry.MyObject.next) then
				textentry.MyObject.next:SetFocus()
			end
		end
	end

	local OnEscapePressed = function(textentry)
		local object = textentry.MyObject
		local kill = object:RunHooksForWidget("OnEscapePressed", textentry, object, object.text)
		if (kill) then
			return
		end

		textentry.focuslost = true
		textentry:ClearFocus()
	end

	local OnSpacePressed = function(textEntry)
		local object = textEntry.MyObject
		local kill = object:RunHooksForWidget("OnSpacePressed", textEntry, object)
		if (kill) then
			return
		end
	end

	local OnEditFocusLost = function(textEntry)
		local object = textEntry.MyObject
		if (object.ignoreNextCallback) then
			detailsFramework.Schedules.RunNextTick(function() object.ignoreNextCallback = nil end)
			return
		end

		if (textEntry:IsShown()) then
			local kill = object:RunHooksForWidget("OnEditFocusLost", textEntry, object, object.text)
			if (kill) then
				return
			end

			if (not textEntry.focuslost) then
				local text = detailsFramework:Trim(textEntry:GetText())
				if (string.len(text) > 0) then
					textEntry.MyObject.currenttext = text
					if (textEntry.MyObject.func) then
						textEntry.MyObject.func(textEntry.MyObject.param1, textEntry.MyObject.param2, text, textEntry, nil)
					end
				else
					textEntry:SetText("")
					textEntry.MyObject.currenttext = ""
				end
			else
				textEntry.focuslost = false
			end

			textEntry.MyObject.label:SetTextColor(.8, .8, .8, 1)
		end
	end

	local OnEditFocusGained = function(textentry)
		local object = textentry.MyObject
		local kill = object:RunHooksForWidget("OnEditFocusGained", textentry, object)
		if (kill) then
			return
		end
		textentry.MyObject.label:SetTextColor(1, 1, 1, 1)

		if (object.autoSelectAllText) then
			object:SelectAll()
		end
	end

	local OnChar = function(textentry, char)
		local object = textentry.MyObject
		local kill = object:RunHooksForWidget("OnChar", textentry, char, object)
		if (kill) then
			return
		end
	end

	local OnTextChanged = function(textentry, byUser)
		local capsule = textentry.MyObject
		local kill = capsule:RunHooksForWidget("OnTextChanged", textentry, byUser, capsule)
		if (kill) then
			return
		end
	end

	local OnTabPressed = function(textentry)
		local capsule = textentry.MyObject
		local bByUser = false
		local kill = capsule:RunHooksForWidget("OnTabPressed", textentry, bByUser, capsule)
		if (kill) then
			return
		end

		if (textentry.MyObject.next) then
			OnEnterPressed(textentry, false)
			textentry.MyObject.next:SetFocus()
		end
	end

	function TextEntryMetaFunctions:PressEnter(byScript)
		OnEnterPressed(self.editbox, byScript)
	end

	---set the textEntry as a search box, it will add a magnifying glass icon on the left side and a clearSearchButton in the right.
	function TextEntryMetaFunctions:SetAsSearchBox()
		if (self.__bIsSearchBox) then
			return
		end

		self:SetJustifyH("left")
        self:SetJustifyV("middle")
		self:SetTextInsets(18, 14, 0, 0)

		local magnifyingGlassTexture = self:CreateTexture(nil, "OVERLAY")
		magnifyingGlassTexture:SetAtlas("common-search-magnifyingglass")
		magnifyingGlassTexture:SetPoint("left", self.widget, "left", 4, 0)
		magnifyingGlassTexture:SetSize(self:GetHeight()-10, self:GetHeight()-10)
		magnifyingGlassTexture:SetAlpha(0.5)
		self.MagnifyingGlassTexture = magnifyingGlassTexture

		local searchFontString = self:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		searchFontString:SetText("search")
		searchFontString:SetAlpha(0.3)
		searchFontString:SetPoint("left", magnifyingGlassTexture, "right", 2, 0)
		detailsFramework:SetFontSize(searchFontString, 10)
		self.SearchFontString = searchFontString

		local clearSearchButton = CreateFrame("button", nil, self.widget, "UIPanelCloseButton")
		clearSearchButton:SetPoint("right", self.widget, "right", -3, 0)
		clearSearchButton:SetSize(10, 10)
		clearSearchButton:SetAlpha(0.3)
		clearSearchButton:GetNormalTexture():SetAtlas("common-search-clearbutton")
		clearSearchButton:GetHighlightTexture():SetAtlas("common-search-clearbutton")
		clearSearchButton:GetPushedTexture():SetAtlas("common-search-clearbutton")
		clearSearchButton:Hide()
		self.ClearSearchButton = clearSearchButton

		clearSearchButton:SetScript("OnClick", function()
			self:SetText("")
			local bByScript = true
			self:PressEnter(bByScript)
			self:ClearFocus()
		end)

		self:SetHook("OnEditFocusGained", function()
			clearSearchButton:Show()
			searchFontString:Hide()
		end)

		self:SetHook("OnEditFocusLost", function()
			if (self:GetText() == "") then
				searchFontString:Show()
				clearSearchButton:Hide()
			end
		end)

		self.__bIsSearchBox = true
	end
------------------------------------------------------------------------------------------------------------

function TextEntryMetaFunctions:SetTemplate(template)
	template = detailsFramework:ParseTemplate(self.type, template) --"textentry"

	if (template.multiline) then
		self.editbox:SetMultiLine(true)
	end

	if (template.width) then
		self.editbox:SetWidth(template.width)
	end
	if (template.height) then
		self.editbox:SetHeight(template.height)
	end

	if (template.backdrop) then
		self.editbox:SetBackdrop(template.backdrop)
	end

	if (template.backdropcolor) then
		local r, g, b, a = detailsFramework:ParseColors(template.backdropcolor)
		self.editbox:SetBackdropColor(r, g, b, a)
		self.onleave_backdrop = {r, g, b, a}
	end

	if (template.backdropbordercolor) then
		local r, g, b, a = detailsFramework:ParseColors(template.backdropbordercolor)
		self.editbox:SetBackdropBorderColor(r, g, b, a)
		self.editbox.current_bordercolor[1] = r
		self.editbox.current_bordercolor[2] = g
		self.editbox.current_bordercolor[3] = b
		self.editbox.current_bordercolor[4] = a
		self.onleave_backdrop_border_color = {r, g, b, a}
	end

	if (template.onentercolor) then
		local r, g, b, a = detailsFramework:ParseColors(template.onentercolor)
		self.onenter_backdrop = {r, g, b, a}
		self:HookScript("OnEnter", detailsFramework.TemplateOnEnter)
		self.__has_onentercolor_script = true
	end

	if (template.onleavecolor) then
		local r, g, b, a = detailsFramework:ParseColors(template.onleavecolor)
		self.onleave_backdrop = {r, g, b, a}
		self:HookScript("OnLeave", detailsFramework.TemplateOnLeave)
		self.__has_onleavecolor_script = true
	end

	if (template.onenterbordercolor) then
		local r, g, b, a = detailsFramework:ParseColors(template.onenterbordercolor)
		self.onenter_backdrop_border_color = {r, g, b, a}
		if (not self.__has_onentercolor_script) then
			self:HookScript("OnEnter", detailsFramework.TemplateOnEnter)
		end
	end

	if (template.onleavebordercolor) then
		local r, g, b, a = detailsFramework:ParseColors(template.onleavebordercolor)
		self.onleave_backdrop_border_color = {r, g, b, a}
		if (not self.__has_onleavecolor_script) then
			self:HookScript("OnLeave", detailsFramework.TemplateOnLeave)
		end
	end
end

--TextEntryMetaFunctions.SetTemplate = DetailsFramework.SetTemplate

------------------------------------------------------------------------------------------------------------
--object constructor

---@class df_textentry : editbox
---@field widget editbox
---@field tooltip any
---@field show any
---@field hide any
---@field width any
---@field height any
---@field text any
---@field multiline any
---@field align any
---@field fontsize any
---@field param1 any
---@field param2 any
---@field ShouldOptimizeAutoComplete boolean?
---@field AutoComplete_StopOnEnterPress boolean?
---@field SetTemplate fun(self:df_textentry, template:table|string)
---@field Disable fun(self:df_textentry)
---@field Enable fun(self:df_textentry)
---@field SetCommitFunction fun(self:df_textentry, func:function)
---@field SetParameters fun(self:df_textentry, param1:any, param2:any)
---@field SetNext fun(self:df_textentry, next:df_textentry)
---@field SetLabelText fun(self:df_textentry, text:string)
---@field SelectAll fun(self:df_textentry)
---@field SetAutoSelectTextOnFocus fun(self:df_textentry, value:boolean)
---@field Blink fun(self:df_textentry)
---@field SetText fun(self:df_textentry, text:string|number)
---@field GetText fun(self:df_textentry)
---@field SetEnterFunction fun(self:df_textentry, func:function, param1:any, param2:any)
---@field SetHook fun(self:df_textentry, hookName:string, func:function)
---@field SetAsSearchBox fun(self:df_textentry)
---@field SetAsAutoComplete fun(self:df_textentry, poolName:string, poolTable:table?, shouldOptimize:boolean?) poolName is the name of the member on textEntry that will be used to store the pool table, poolTable is an array with word to be used on the autocomplete, shouldOptimize is a boolean that will optimize the autocomplete by using a cache table, it's recommended to use it if the autocomplete array is too large.

---@param parent frame
---@param textChangedCallback function
---@param width number
---@param height number
---@param member string?
---@param name string?
---@param labelText string?
---@param textentryTemplate table?
---@param labelTemplate table?
---@return df_textentry
function detailsFramework:CreateTextEntry(parent, textChangedCallback, width, height, member, name, labelText, textentryTemplate, labelTemplate)
---@diagnostic disable-next-line: return-type-mismatch
	return detailsFramework:NewTextEntry(parent, parent, name, member, width, height, textChangedCallback, nil, nil, nil, labelText, textentryTemplate, labelTemplate)
end

function detailsFramework:NewTextEntry(parent, container, name, member, width, height, func, param1, param2, space, withLabel, entryTemplate, labelTemplate)
	if (not name) then
		name = "DetailsFrameworkTextEntryNumber" .. detailsFramework.TextEntryCounter
		detailsFramework.TextEntryCounter = detailsFramework.TextEntryCounter + 1

	elseif (not parent) then
		return error("Details! FrameWork: parent not found.", 2)
	end

	if (not container) then
		container = parent
	end

	if (name:find("$parent")) then
		local parentName = detailsFramework:GetParentName(parent)
		name = name:gsub("$parent", parentName)
	end

	local newTextEntryObject = {type = "textentry", dframework = true}

	if (member) then
		parent[member] = newTextEntryObject
	end

	if (parent.dframework) then
		parent = parent.widget
	end

	if (container.dframework) then
		container = container.widget
	end

	--misc
	newTextEntryObject.container = container

	if (not width and space) then
		width = space
	end

	--editbox
	newTextEntryObject.editbox = CreateFrame("EditBox", name, parent,"BackdropTemplate")
	newTextEntryObject.editbox:SetSize(232, 20)
	newTextEntryObject.editbox:SetBackdrop({bgFile = [["Interface\DialogFrame\UI-DialogBox-Background"]], tileSize = 64, tile = true, edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]], edgeSize = 10, insets = {left = 1, right = 1, top = 0, bottom = 0}})
	newTextEntryObject.editbox:SetTextInsets(3, 0, 0, -3)
	newTextEntryObject.editbox:SetWidth(width)
	newTextEntryObject.editbox:SetHeight(height)
	newTextEntryObject.editbox:SetJustifyH("center")
	newTextEntryObject.editbox:EnableMouse(true)
	newTextEntryObject.editbox:SetText("")
	newTextEntryObject.editbox:SetAutoFocus(false)
	newTextEntryObject.editbox:SetFontObject("GameFontHighlightSmall")

	newTextEntryObject.editbox:SetJustifyH("left")
	newTextEntryObject.editbox:SetTextInsets(5, 3, 0, 0)

	--editbox label
	newTextEntryObject.editbox.label = newTextEntryObject.editbox:CreateFontString("$parent_Desc", "OVERLAY", "GameFontHighlightSmall")
	newTextEntryObject.editbox.label:SetJustifyH("left")
	newTextEntryObject.editbox.label:SetPoint("RIGHT", newTextEntryObject.editbox, "LEFT", -2, 0)

	newTextEntryObject.label = newTextEntryObject.editbox.label
	newTextEntryObject.widget = newTextEntryObject.editbox
	newTextEntryObject.editbox.MyObject = newTextEntryObject

	if (not APITextEntryFunctions) then
		APITextEntryFunctions = true
		local idx = getmetatable(newTextEntryObject.editbox).__index
		for funcName, funcAddress in pairs(idx) do
			if (not TextEntryMetaFunctions[funcName]) then
				TextEntryMetaFunctions[funcName] = function(object, ...)
					local x = loadstring( "return _G['"..object.editbox:GetName().."']:"..funcName.."(...)")
					return x(...)
				end
			end
		end
	end

	newTextEntryObject.editbox.current_bordercolor = {1, 1, 1, 0.7}
	newTextEntryObject.enabled_border_color = {newTextEntryObject.editbox:GetBackdropBorderColor()}
	newTextEntryObject.enabled_backdrop_color = {newTextEntryObject.editbox:GetBackdropColor()}
	newTextEntryObject.enabled_text_color = {newTextEntryObject.editbox:GetTextColor()}
	newTextEntryObject.onleave_backdrop = {newTextEntryObject.editbox:GetBackdropColor()}
	newTextEntryObject.onleave_backdrop_border_color = {newTextEntryObject.editbox:GetBackdropBorderColor()}

	newTextEntryObject.func = func
	newTextEntryObject.param1 = param1
	newTextEntryObject.param2 = param2
	newTextEntryObject.next = nil
	newTextEntryObject.space = space
	newTextEntryObject.tab_on_enter = false

	newTextEntryObject.editbox:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
	newTextEntryObject.editbox:SetBackdropColor(.2, .2, .2, 1)
	newTextEntryObject.editbox:SetBackdropBorderColor(1, 1, 1, 0.7)

	--hooks
	newTextEntryObject.HookList = {
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

	newTextEntryObject.editbox:SetScript("OnEnter", OnEnter)
	newTextEntryObject.editbox:SetScript("OnLeave", OnLeave)
	newTextEntryObject.editbox:SetScript("OnHide", OnHide)
	newTextEntryObject.editbox:SetScript("OnShow", OnShow)
	newTextEntryObject.editbox:SetScript("OnEnterPressed", OnEnterPressed)
	newTextEntryObject.editbox:SetScript("OnEscapePressed", OnEscapePressed)
	newTextEntryObject.editbox:SetScript("OnSpacePressed", OnSpacePressed)
	newTextEntryObject.editbox:SetScript("OnEditFocusLost", OnEditFocusLost)
	newTextEntryObject.editbox:SetScript("OnEditFocusGained", OnEditFocusGained)
	newTextEntryObject.editbox:SetScript("OnChar", OnChar)
	newTextEntryObject.editbox:SetScript("OnTextChanged", OnTextChanged)
	newTextEntryObject.editbox:SetScript("OnTabPressed", OnTabPressed)

	setmetatable(newTextEntryObject, TextEntryMetaFunctions)

	if (withLabel) then
		local label = detailsFramework:CreateLabel(newTextEntryObject.editbox, withLabel, nil, nil, nil, "label", nil, "overlay")
		label.text = withLabel
		newTextEntryObject.editbox:SetPoint("left", label.widget, "right", 2, 0)
		if (labelTemplate) then
			label:SetTemplate(labelTemplate)
		end
		withLabel = label
	end

	if (entryTemplate) then
		newTextEntryObject:SetTemplate(entryTemplate)
	end

	return newTextEntryObject, withLabel
end

---@class df_searchbox : df_textentry
---@field ClearSearchButton button
---@field MagnifyingGlassTexture texture
---@field SearchFontString fontstring
---@field BottomLineTexture texture
---@field PressEnter fun(self:df_searchbox)
---@field ClearFocus fun(self:df_searchbox)

---create a search box with no backdrop, a magnifying glass icon and a clear search button
---@param parent frame
---@param callback any
---@return df_searchbox
function detailsFramework:CreateSearchBox(parent, callback)
    local onSearchPressEnterCallback = function(_, _, text, self)
        callback(self)
    end

    local searchBox = detailsFramework:CreateTextEntry(parent, onSearchPressEnterCallback, 220, 26)
	---@cast searchBox df_searchbox

    searchBox:SetAsSearchBox()
    searchBox:SetTextInsets(25, 5, 0, 0)
    searchBox:SetBackdrop(nil)
    searchBox:SetHook("OnTextChanged", callback)

    local file, size, flags = searchBox:GetFont()
    searchBox:SetFont(file, 12, flags)
    searchBox.ClearSearchButton:SetAlpha(0)

    searchBox.BottomLineTexture = searchBox:CreateTexture(nil, "border")
    searchBox.BottomLineTexture:SetPoint("bottomleft", searchBox.widget, "bottomleft", -15, 0)
    searchBox.BottomLineTexture:SetPoint("bottomright", searchBox.widget, "bottomright", 0, 0)
	local bUseAtlasSize = false
    searchBox.BottomLineTexture:SetAtlas("common-slider-track")
    searchBox.BottomLineTexture:SetHeight(8)

	--create the button to clear the search box
	searchBox.ClearSearchButton = CreateFrame("button", nil, searchBox.widget, "UIPanelCloseButton")
	searchBox.ClearSearchButton:SetPoint("right", searchBox.widget, "right", -3, 0)
	searchBox.ClearSearchButton:SetSize(10, 10)
	searchBox.ClearSearchButton:SetAlpha(0.3)
	searchBox.ClearSearchButton:GetNormalTexture():SetAtlas("common-search-clearbutton")
	searchBox.ClearSearchButton:GetHighlightTexture():SetAtlas("common-search-clearbutton")
	searchBox.ClearSearchButton:GetPushedTexture():SetAtlas("common-search-clearbutton")

	searchBox.ClearSearchButton:SetScript("OnClick", function()
		searchBox:SetText("")
		searchBox:PressEnter()
		searchBox:ClearFocus()
	end)

    return searchBox
end


function detailsFramework:NewSpellEntry(parent, func, width, height, param1, param2, member, name)
	local editbox = detailsFramework:NewTextEntry(parent, parent, name, member, width, height, func, param1, param2)
	return editbox
end

local function_gettext = function(self)
	return self.editbox:GetText()
end

local function_settext = function(self, text)
	return self.editbox:SetText(text)
end

local function_clearfocus = function(self)
	return self.editbox:ClearFocus()
end

local function_setfocus = function(self)
	return self.editbox:SetFocus(true)
end

local get_last_word = function(self)
	self.lastword = ""
	local cursor_pos = self.editbox:GetCursorPosition()
	local text = self.editbox:GetText()
	for i = cursor_pos, 1, -1 do
		local character = text:sub (i, i)
		if (character:match ("%a")) then
			self.lastword = character .. self.lastword
			--print(self.lastword)
		else
			break
		end
	end
end

--On Text Changed
local AutoComplete_OnTextChanged = function(editboxWidget, byUser, capsule)
	capsule = capsule or editboxWidget.MyObject or editboxWidget

	local chars_now = editboxWidget:GetText():len()
	if (not editboxWidget.ignore_textchange) then
		--backspace
		if (chars_now == capsule.characters_count -1) then
			capsule.lastword = capsule.lastword:sub (1, capsule.lastword:len()-1)
		--delete lots of text
		elseif (chars_now < capsule.characters_count) then
			--o auto complete selecionou outra palavra bem menor e caiu nesse filtro
			editboxWidget.end_selection = nil
			capsule:GetLastWord()
		end
	else
		editboxWidget.ignore_textchange = nil
	end
	capsule.characters_count = chars_now

	--call the other hooks for the widget
	capsule:RunHooksForWidget("OnTextChanged", editboxWidget, byUser, capsule)
end

local AutoComplete_OnSpacePressed = function(editboxWidget, capsule)
	capsule = capsule or editboxWidget.MyObject or editboxWidget

--	if (not gotMatch) then
		--editboxWidget.end_selection = nil
--	end
end

local AutoComplete_OnEscapePressed = function(editboxWidget)
	editboxWidget.end_selection = nil
end

local AutoComplete_OnEnterPressed = function(editboxWidget)

	local capsule = editboxWidget.MyObject or editboxWidget
	if (editboxWidget.end_selection) then
		editboxWidget:SetCursorPosition (editboxWidget.end_selection)
		editboxWidget:HighlightText (0, 0)
		editboxWidget.end_selection = nil
		--editboxWidget:Insert (" ") --estava causando a adi��o de uma palavra a mais quando o pr�ximo catactere for um espa�o
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

	if (capsule.AutoComplete_StopOnEnterPress) then
		editboxWidget:ClearFocus()
	end
end

local AutoComplete_OnEditFocusGained = function(editboxWidget)
	local capsule = editboxWidget.MyObject or editboxWidget
	capsule:GetLastWord()
	--print("last word:", editboxWidget.lastword)
	editboxWidget.end_selection = nil
	editboxWidget.focusGained = true
	capsule.characters_count = editboxWidget:GetText():len()
end

local OptimizeAutoCompleteTable = function(self, wordList)
	local optimizedTable = {}

	local lower = string.lower
	local sub = string.sub
	local len = string.len

	local subTables = 0

	for i = 1, #wordList do
		local thisWord = wordList [i]
		if (len (thisWord) > 0) then
			thisWord = lower (thisWord)

			local firstCharacter = sub (thisWord, 1, 1)

			local charTable = optimizedTable [firstCharacter]
			if (not charTable) then
				charTable = {}
				optimizedTable [firstCharacter] = charTable

				subTables = subTables + 1
			end

			charTable [#charTable+1] = thisWord
		end
	end

	wordList.Optimized = optimizedTable
end

local AutoComplete_OnChar = function(editboxWidget, char, capsule)
	if (char == "") then
		return
	end

	capsule = capsule or editboxWidget.MyObject or editboxWidget
 	editboxWidget.end_selection = nil

	if (editboxWidget.ignore_input) then
		return
	end

	--reseta a palavra se acabou de ganhar focus e apertou espa�o
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
			error("Details! Framework: TextEntry has AutoComplete but no word list table.")
			return
		end

		if (capsule.ShouldOptimizeAutoComplete) then
			if (not wordList.Optimized) then
				OptimizeAutoCompleteTable (capsule, wordList)
			end

			local firstCharacter = string.lower(string.sub (capsule.lastword, 1, 1))
			wordList = wordList.Optimized [firstCharacter]

			if (wordList) then
				for i = 1, #wordList do
					local thisWord = wordList [i]
					if (thisWord and (thisWord:find("^" .. capsule.lastword) or thisWord:lower():find("^" .. capsule.lastword))) then
						local rest = thisWord:gsub(capsule.lastword, "")
						rest = rest:lower():gsub(capsule.lastword, "")
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
			return
		end

		for i = 1, #wordList do
			local thisWord = wordList [i]
			if (thisWord and (thisWord:find("^" .. capsule.lastword) or thisWord:lower():find("^" .. capsule.lastword))) then
				local rest = thisWord:gsub(capsule.lastword, "")
				rest = rest:lower():gsub(capsule.lastword, "")
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

function TextEntryMetaFunctions:SetAsAutoComplete(poolName, poolTable, shouldOptimize)
	if (not self.SetHook) then
		--self is borderframe
		self = self.editbox
		self.editbox = self --compatible with fw functions

		self.lastword = ""
		self.characters_count = 0
		self.poolName = poolName
		self.GetLastWord = get_last_word --editbox:GetLastWord()
		self.NoClearFocusOnEnterPressed = true --avoid auto clear focus
		self.ShouldOptimizeAutoComplete = shouldOptimize

		if (poolTable) then
			self [poolName] = poolTable
		end

		self:HookScript ("OnEditFocusGained", AutoComplete_OnEditFocusGained)
		self:HookScript ("OnEnterPressed", AutoComplete_OnEnterPressed)
		self:HookScript ("OnEscapePressed", AutoComplete_OnEscapePressed)
		self:HookScript ("OnTextChanged", AutoComplete_OnTextChanged)
		self:HookScript ("OnChar", AutoComplete_OnChar)
		self:HookScript ("OnSpacePressed", AutoComplete_OnSpacePressed)
	else
		--fw textfield
		self.lastword = ""
		self.characters_count = 0
		self.poolName = poolName
		self.GetLastWord = get_last_word --editbox:GetLastWord()
		self.NoClearFocusOnEnterPressed = true --avoid auto clear focus
		self.ShouldOptimizeAutoComplete = shouldOptimize

		self:SetHook("OnEditFocusGained", AutoComplete_OnEditFocusGained)
		self:SetHook("OnEnterPressed", AutoComplete_OnEnterPressed)
		self.editbox:HookScript ("OnEscapePressed", AutoComplete_OnEscapePressed)
		self.editbox:SetScript("OnTextChanged", AutoComplete_OnTextChanged)
		self.editbox:SetScript("OnChar", AutoComplete_OnChar)
		self.editbox:SetScript("OnSpacePressed", AutoComplete_OnSpacePressed)
	end

end

local set_speciallua_editor_font_size = function(borderFrame, newSize)
	local file, size, flags = borderFrame.editbox:GetFont()
	borderFrame.editbox:SetFont(file, newSize, flags)
	borderFrame.editboxlines:SetFont(file, newSize, flags)
end

---@class df_luaeditor : frame
---@field scroll scrollframe
---@field editbox editbox
---@field scrollnumberlines number
---@field editboxlines editbox
---@field SetTemplate fun(self:df_luaeditor, template:table)
---@field Disable fun(self:df_luaeditor)
---@field Enable fun(self:df_luaeditor)
---@field SetText fun(self:df_luaeditor, text:string)
---@field GetText fun(self:df_luaeditor):string
---@field SetTextSize fun(self:df_luaeditor, size:number)
---@field ClearFocus fun(self:df_luaeditor)
---@field SetFocus fun(self:df_luaeditor)

---create a text box to edit lua code
---if 'nointent' is true, the lua code will not be indented / highlighted / colored
---@param parent frame
---@param width number
---@param height number
---@param member string?
---@param name string?
---@param nointent boolean?
---@param showLineNumbers boolean?
---@param bNoName boolean?
---@return df_luaeditor
function detailsFramework:NewSpecialLuaEditorEntry(parent, width, height, member, name, nointent, showLineNumbers, bNoName)
	if (not bNoName) then
		if (name and name:find("$parent")) then
			local parentName = detailsFramework:GetParentName(parent)
			name = name:gsub("$parent", parentName)
		end
	else
		name =  nil
	end

	local borderframe = CreateFrame("Frame", name, parent,"BackdropTemplate")
	borderframe:SetSize(width, height)

	if (member) then
		parent[member] = borderframe
	end

	local scrollframe = CreateFrame("ScrollFrame", name, borderframe, "UIPanelScrollFrameTemplate, BackdropTemplate")
	local scrollframeNumberLines = CreateFrame("ScrollFrame", name and (name .. "NumberLines"), borderframe, "UIPanelScrollFrameTemplate, BackdropTemplate")

	scrollframe.editbox = CreateFrame("editbox", name and "$parentEditBox", scrollframe,"BackdropTemplate")
	scrollframe.editbox:SetMultiLine (true)
	scrollframe.editbox:SetAutoFocus(false)
	scrollframe.editbox:SetScript("OnCursorChanged", _G.ScrollingEdit_OnCursorChanged)
	scrollframe.editbox:SetScript("OnEscapePressed", _G.EditBox_ClearFocus)
	scrollframe.editbox:SetFontObject("GameFontHighlightSmall")
	scrollframe:SetScrollChild(scrollframe.editbox)

	--line number
	if (showLineNumbers) then
		scrollframeNumberLines.editbox = CreateFrame("editbox", name and "$parentLineNumbers", scrollframeNumberLines, "BackdropTemplate")
		scrollframeNumberLines.editbox:SetMultiLine (true)
		scrollframeNumberLines.editbox:SetAutoFocus(false)
		scrollframeNumberLines.editbox:SetEnabled (false)
		scrollframeNumberLines.editbox:SetFontObject("GameFontHighlightSmall")
		scrollframeNumberLines.editbox:SetJustifyH("left")
		scrollframeNumberLines.editbox:SetJustifyV ("top")
		scrollframeNumberLines.editbox:SetTextColor(.3, .3, .3, .5)
		scrollframeNumberLines.editbox:SetPoint("topleft", borderframe, "topleft", 0, -10)
		scrollframeNumberLines.editbox:SetPoint("bottomleft", borderframe, "bottomleft", 0, 10)

		scrollframeNumberLines:SetScrollChild(scrollframeNumberLines.editbox)
		scrollframeNumberLines:EnableMouseWheel(false)

		for i = 1, 1000 do
			scrollframeNumberLines.editbox:Insert (i .. "\n")
		end

		--place the lua code field 20 pixels to the right to make run to the lines scroll
		scrollframe:SetPoint("topleft", borderframe, "topleft", 30, -10)
		scrollframe:SetPoint("bottomright", borderframe, "bottomright", -10, 10)

		--when the lua code field scrolls, make the lua field scroll too
		scrollframe:SetScript("OnVerticalScroll", function(self, offset)
			scrollframeNumberLines:SetVerticalScroll(scrollframe:GetVerticalScroll())
			scrollframeNumberLines.ScrollBar:Hide()
		end)

		--place the number lines scroll in the begining of the editing code space
		scrollframeNumberLines:SetPoint("topleft", borderframe, "topleft", 2, -10)
		scrollframeNumberLines:SetPoint("bottomright", borderframe, "bottomright", -10, 10)

		scrollframeNumberLines.editbox:SetJustifyH("left")
		scrollframeNumberLines.editbox:SetJustifyV ("top")

		scrollframeNumberLines:SetScript("OnSizeChanged", function(self)
			scrollframeNumberLines.editbox:SetSize(self:GetSize())
			scrollframeNumberLines.ScrollBar:Hide()
		end)

		scrollframeNumberLines.ScrollBar:HookScript("OnShow", function(self)
			self:Hide()
		end)

		borderframe.scrollnumberlines = scrollframeNumberLines
		borderframe.editboxlines = scrollframeNumberLines.editbox
		borderframe.editboxlines.borderframe = borderframe

		scrollframeNumberLines.ScrollBar:Hide()
		scrollframeNumberLines:SetBackdrop(nil)
		scrollframeNumberLines.editbox:SetBackdrop(nil)

		local stringLengthFontString = scrollframeNumberLines:CreateFontString(nil, "overlay", "GameFontNormal")

		local currentUpdateLineCounterTimer = nil

		local updateLineCounter = function()
			scrollframeNumberLines.editbox:SetSize(scrollframe.editbox:GetSize())

			local text = scrollframe.editbox:GetText()
			local textInArray = detailsFramework:SplitTextInLines(text)

			local maxStringWidth = scrollframe.editbox:GetWidth()
			scrollframeNumberLines.editbox:SetWidth(maxStringWidth)

			local font, size, flags = scrollframe.editbox:GetFont()
			scrollframeNumberLines.editbox:SetFont(font, size, flags)
			stringLengthFontString:SetFont(font, size, flags)

			local resultText = ""

			--this approuch has many problems but it is better than nothing
			for i = 1, #textInArray do
				--set the line text into a fontstring to get its width
				local thisText = textInArray[i]
				stringLengthFontString:SetText(thisText)
				local lineTextLength = math.ceil(stringLengthFontString:GetStringWidth())

				if (lineTextLength < maxStringWidth) then
					resultText = resultText .. i .. "\n"
				else
					--if the text width is bigger than the editbox width, add a blank line into the line counter
					local linesToOccupy = math.floor(lineTextLength / maxStringWidth)
					local fillingText = i .. ""
					for o = 1, linesToOccupy do
						fillingText = fillingText .. "\n"
					end
					resultText = resultText .. fillingText .. "\n"
				end
			end

			scrollframeNumberLines.editbox:SetText(resultText)

			currentUpdateLineCounterTimer = nil
		end

		scrollframe.editbox:HookScript("OnTextChanged", function()
			if (currentUpdateLineCounterTimer) then
				return
			end
			currentUpdateLineCounterTimer = C_Timer.NewTimer(0.25, updateLineCounter)
		end)

	else
		scrollframe:SetPoint("topleft", borderframe, "topleft", 10, -10)
		scrollframe:SetPoint("bottomright", borderframe, "bottomright", -10, 10)
		scrollframeNumberLines:SetPoint("topleft", borderframe, "topleft", 10, -10)
		scrollframeNumberLines:SetPoint("bottomright", borderframe, "bottomright", -10, 10)
		scrollframeNumberLines:Hide()
	end

	borderframe.SetAsAutoComplete = TextEntryMetaFunctions.SetAsAutoComplete

	scrollframe:SetScript("OnSizeChanged", function(self)
		scrollframe.editbox:SetSize(self:GetSize())
	end)

	scrollframe.editbox:SetJustifyH("left")
	scrollframe.editbox:SetJustifyV ("top")
	scrollframe.editbox:SetMaxBytes (1024000)
	scrollframe.editbox:SetMaxLetters (128000)

	borderframe.GetText = function_gettext
	borderframe.SetText = function_settext
	borderframe.ClearFocus = function_clearfocus
	borderframe.SetFocus = function_setfocus
	borderframe.SetTextSize = set_speciallua_editor_font_size

	borderframe.Enable = TextEntryMetaFunctions.Enable
	borderframe.Disable = TextEntryMetaFunctions.Disable

	borderframe.SetTemplate = TextEntryMetaFunctions.SetTemplate

	if (not nointent) then
		IndentationLib.enable(scrollframe.editbox, nil, 4)
	end

	borderframe:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		tile = 1, tileSize = 16, edgeSize = 16, insets = {left = 5, right = 5, top = 5, bottom = 5}})

	scrollframe.editbox.current_bordercolor = {1, 1, 1, 0.7}
	borderframe:SetBackdropBorderColor(1, 1, 1, 0.7)
	borderframe:SetBackdropColor(0.090195, 0.090195, 0.188234, 1)

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