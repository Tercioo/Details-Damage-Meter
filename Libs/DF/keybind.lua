---@type detailsframework
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

--[=[[
	bugs:
	-t verificar se esta mostrando o indicador de keybinds repetidas
	-t fazer o sort de maneira que fique melhor
	-t fazer um indicador dizendo que a keybind esta desabilitada por causa da load condition
	-t fazer o debug do puf mostrar as keybinds (string)
	- quando iniciar uma edição, fazer um indicador the diga que aquela linha esta esta sendo editada
	- transferir o montagem do código seguro das keybinds no puf para o framework

tried to edit a spell binding:
2x Details/Libs/DF/keybind.lua:1080: attempt to index local 'actionId' (a number value)
[string "@Details/Libs/DF/keybind.lua"]:1160: in function <Details/Libs/DF/keybind.lua:1143>
[string "=[C]"]: in function `xpcall'
[string "@Details/Libs/DF/fw.lua"]:4864: in function `CoreDispatch'
[string "@Details/Libs/DF/button.lua"]:720: in function <Details/Libs/DF/button.lua:656>
--]=]

local _
local IsShiftKeyDown = _G["IsShiftKeyDown"]
local IsControlKeyDown = _G["IsControlKeyDown"]
local IsAltKeyDown = _G["IsAltKeyDown"]
local CreateFrame = _G["CreateFrame"]
local GetSpellInfo = _G["GetSpellInfo"] or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end
local unpack = unpack ---@diagnostic disable-line

---@alias actionidentifier string a string in the format of "spell-spellId" or "macro-macroName" or "system-target", etc, used to pass information about the action more easily

---@class keybind_scroll_data : {key1:string, key2:any, key3:any, key4:string, key5:boolean, key6:number, key7:string}

---@class df_keybind : table
---@field name string
---@field action string|number
---@field keybind string
---@field macro string
---@field conditions table
---@field icon any

---@class df_editkeybindframe : frame
---@field bIsEditing boolean
---@field actionIdentifier actionidentifier
---@field conditionsFailLoadReasonText fontstring
---@field keybindTable df_keybind
---@field nameEditBox df_textentry
---@field iconPickerButton df_button
---@field conditionsButton df_button
---@field editMacroEditBox df_luaeditor
---@field cancelButton df_button
---@field saveButton df_button
---@field deleteMacroButton df_button
---@field Disable fun(self:df_editkeybindframe)
---@field Enable fun(self:df_editkeybindframe)

---@class df_selectkeybindbutton : button
---@field actionIdentifier actionidentifier
---@field keybindTable df_keybind
---@field keybindScrollData keybind_scroll_data

---@class df_keybindscrollline : frame, df_headerfunctions
---@field bIsSeparator boolean
---@field keybindScrollLine boolean
---@field backgroundTexture texture
---@field highlightTexture texture
---@field separatorTitleText fontstring
---@field spellIconTexture texture
---@field actionNameFontString fontstring
---@field setKeybindButton df_button
---@field clearKeybindButton df_button
---@field editKeybindSettingsButton df_button
---@field SetAsSeparator function

local keybindPrototype = {
	name = "", --a name or alias to call this keybind
	action = "", --which action this keybind will do, can be a spellId for spell casting, a macro text or targetting like "target", "focus", "togglemenu"
	keybind = "",
	macro = "",
	conditions = detailsFramework:UpdateLoadConditionsTable({}),
	icon = "",
}

---@type {action: string, keybind: string, icon: string, name: string}[]
local defaultMouseKeybinds = {
	{action = "target", name = _G["TARGET"], keybind = "type1", icon = [[Interface\MINIMAP\TRACKING\Target]]}, --default: left mouse button
	{action = "togglemenu", name = _G["SLASH_TEXTTOSPEECH_MENU"], keybind =  "type2", icon = [[Interface\BUTTONS\UI-GuildButton-PublicNote-Up]]}, --default: right mouse button
	{action = "focus", name = _G["FOCUS"], keybind =  "type3", icon = [[Interface\MINIMAP\TRACKING\Focus]]} --default: middle mouse button
}

local defaultMouseKeybindsKV = {
	["target"] = defaultMouseKeybinds[1],
	["togglemenu"] = defaultMouseKeybinds[2],
	["focus"] = defaultMouseKeybinds[3],
}

---@class df_keybindscroll : df_scrollbox
---@field UpdateScroll fun(self:df_keybindscroll)

---@class df_keybindframe : frame, df_optionsmixin
---@field options table
---@field data table
---@field keybindData table
---@field keybindScrollData keybind_scroll_data
---@field Header df_headerframe
---@field actionId number? the actionId is the spell Id or an actionId or a macro text
---@field button button? the button which got clicked to start editing a keybind
---@field bIsListening boolean if the frame is wayting the user to press a keybind (listening key inputs)
---@field bIsKeybindFrame boolean
---@field keybindScroll df_keybindscroll
---@field keybindListener frame
---@field editKeybindFrame df_editkeybindframe
---@field callback function
---@field ClearKeybind fun(self:button, buttonPresed:string, actionIdentifier:actionidentifier, keybindTable:any)
---@field CreateKeybindScroll fun(self:df_keybindframe)
---@field CreateKeybindListener fun(self:df_keybindframe)
---@field CreateEditPanel fun(self:df_keybindframe)
---@field CreateKeybindScrollLine fun(self:df_keybindframe, index:number)
---@field DeleteMacro fun(self:df_keybindframe)
---@field FindKeybindTable fun(self:df_keybindframe, keybindType:string, actionId:any, actionIdentifier:actionidentifier?) : df_keybind?, number?
---@field GetEditPanel fun(self:df_keybindframe) : df_editkeybindframe
---@field GetPressedModifiers fun() : string
---@field GetListeningActionId fun(self:df_keybindframe) : number
---@field GetListeningState fun(self:df_keybindframe) : boolean, any, button, keybind_scroll_data
---@field GetKeybindData fun(self:df_keybindframe) : df_keybind[]
---@field GetKeybindListener fun(self:df_keybindframe) : frame
---@field GetKeybindScroll fun(self:df_keybindframe) : df_keybindscroll
---@field GetKeybindCallback fun(self:df_keybindframe):function
---@field GetKeybindModifiers fun(keybind:string) : string
---@field GetKeybindTypeAndActionFromIdentifier fun(self:df_keybindframe, actionIdentifier:actionidentifier) : string, any
---@field IsListening fun(self:df_keybindframe) : boolean
---@field IsEditingKeybindSettings fun(self:df_keybindframe) : boolean, string, df_keybind
---@field IsKeybindActionMacro fun(self:df_keybindframe, actionId:any) : boolean
---@field CallKeybindChangeCallback fun(self:df_keybindframe, type:string, keybindTable:df_keybind?, keybindPressed:string?, removedIndex:number?, macroText:string?)
---@field OnKeybindNameChange fun(self:df_keybindframe, name:string)
---@field OnKeybindMacroChange fun(self:df_keybindframe, macroText:string)
---@field OnKeybindIconChange fun(self:df_keybindframe, iconTexture:string)
---@field OnUserClickedToChooseKeybind fun(self:df_keybindframe, button:button, actionIdentifier:actionidentifier, keybindTable:df_keybind|false)
---@field OnUserPressedKeybind fun(self:df_keybindframe, key:string)
---@field SaveKeybindToKeybindData fun(self:df_keybindframe, actionId:any, pressedKeybind:any, bJustCreated:boolean)
---@field SetClearButtonsEnabled fun(self:df_keybindframe, enabled:boolean)
---@field SetEditButtonsEnabled fun(self:df_keybindframe, enabled:boolean)
---@field SetListeningState fun(self:df_keybindframe, value:boolean, actionIdentifier:actionidentifier?, button:button?, keybindScrollData:keybind_scroll_data?)
---@field SetKeybindData fun(self:df_keybindframe, keybindData:table)
---@field SetKeybindCallback fun(self:df_keybindframe, callback:function)
---@field StartEditingKeybindSettings fun(self:frame, button:string, actionIdentifier:actionidentifier, keybindTable:df_keybind)
---@field StopEditingKeybindSettings fun(self:df_keybindframe)
---@field SwitchSpec fun(self:button, button:string, newSpecId:number)

detailsFramework:NewColor("BLIZZ_OPTIONS_COLOR", 1, 0.8196, 0, 1)

local DARK_BUTTON_TEMPLATE = detailsFramework:InstallTemplate("button", "DARK_BUTTON_TEMPLATE", {backdropcolor = {.1, .1, .1, .98}}, "OPTIONS_BUTTON_TEMPLATE")

---only called from OnUserPressedKeybind() when the a keybindTable is not found for the action
---@return df_keybind
local createNewKeybindTable = function(name, keybind, macro, actionId, iconTexture)
	---@type df_keybind
	local newMacroTable = detailsFramework.table.copy({}, keybindPrototype)
	newMacroTable.name = name or "My New Macro" --if a name isn't passed, it's a macro
	newMacroTable.keybind = keybind or ""
	newMacroTable.macro = macro or ""
	newMacroTable.action = actionId
	newMacroTable.icon = iconTexture or ""
	return newMacroTable
end

---return a number representing the sort order of a spell
---@param keybindData any
---@param spellName string
---@param bIsAvailable any
---@return number
local getSpellSortOrder = function(keybindData, spellName, bIsAvailable)
	local sortScore = 0

	if (not bIsAvailable) then
		sortScore = sortScore + 5000
	end

	if (not keybindData) then
		sortScore = sortScore + 300
	end

	sortScore = sortScore + string.byte(spellName)
	return sortScore
end

local default_options = {
    width = 580,
    height = 500,
	edit_width = 400,
	edit_height = 0,
	scroll_width = 580,
	scroll_height = 480,
	amount_lines = 18,
	line_height = 26,
	show_spells = true,
	show_unitcontrols = true,
	show_macros = true,
	can_modify_keybind_data = true, --if false, won't change the data table passed on the constructor or the one returned by GetKeybindData
}

local headerTable = {
	{text = "", width = 34}, --spell icon
	{text = "", width = 200},
	{text = "Keybind", width = 260},
	{text = "Clear", width = 40},
	{text = "Edit", width = 40},
}
local headerOptions = {
	padding = 2,
	backdrop_color = {0, 0, 0, 0},
}


local ignoredKeys = {
	["LSHIFT"] = true,
	["RSHIFT"] = true,
	["LCTRL"] = true,
	["RCTRL"] = true,
	["LALT"] = true,
	["RALT"] = true,
	["UNKNOWN"] = true,
}

local mouseButtonToClickType = {
	["LeftButton"] = "type1",
	["RightButton"] = "type2",
	["MiddleButton"] = "type3",
	["Button4"] = "type4",
	["Button5"] = "type5",
	["Button6"] = "type6",
	["Button7"] = "type7",
	["Button8"] = "type8",
	["Button9"] = "type9",
	["Button10"] = "type10",
	["Button11"] = "type11",
	["Button12"] = "type12",
	["Button13"] = "type13",
	["Button14"] = "type14",
	["Button15"] = "type15",
	["Button16"] = "type16",
}

local roundedCornerPreset = {
	roundness = 5,
	color = {.075, .075, .075, 1},
	border_color = {.05, .05, .05, 1},
	horizontal_border_size_offset = 8,
}

--> helpers
local getMainFrame = function(UIObject)
	if (UIObject.bIsKeybindFrame) then
		return UIObject
	end

    local parentFrame = UIObject:GetParent()

    for i = 1, 5 do
        if (parentFrame.bIsKeybindFrame) then
            return parentFrame
        end
        parentFrame = parentFrame:GetParent()
    end
end

local setAsSeparator = function(line, bIsSeparator, titleText)
	if (bIsSeparator) then
		line.spellIconTexture:Hide()
		line.actionNameFontString:Hide()
		line.setKeybindButton:Hide()
		line.clearKeybindButton:Hide()
		line.editKeybindSettingsButton:Hide()
		line.separatorTitleText:Show()
		line.separatorTitleText:SetText(titleText)
		line.bIsSeparator = true
		line.backgroundTexture:Hide()
	else
		line.spellIconTexture:Show()
		line.actionNameFontString:Show()
		line.setKeybindButton:Show()
		line.clearKeybindButton:Show()
		line.editKeybindSettingsButton:Show()
		line.separatorTitleText:Hide()
		line.bIsSeparator = false
		line.backgroundTexture:Show()
	end
end

---@class df_keybindmixin
detailsFramework.KeybindMixin = {
	bIsListening = false,
	CurrentKeybindEditingSet = {},

	---and the player change spec, the list of spells will change, hence need to update the keybind list if the panel is open
	--if isn't open, the keybinds will be updated when the panel is opened
    OnSpecChanged = function(self, button, newSpecId) --switch_spec
        --quick hide and show as a feedback to the player that the spec was changed
        --C_Timer.After (.04, function() EnemyGridOptionsPanelFrameKeybindScroill:Hide() end) --!need to defined the scroll frame
        --C_Timer.After (.06, function() EnemyGridOptionsPanelFrameKeybindScroill:Show() end) --!need to defined the scroll frame
        --EnemyGridOptionsPanelFrameKeybindScroill:UpdateScroll() --!need to defined the scroll frame
    end,

	---return true if the keybindFrame is waiting for the player to press a keybind
	---@param self df_keybindframe
	---@return boolean bIsListening
	IsListening = function(self)
		return self.bIsListening
	end,

	---return the actionId which the frame is currently listening for a keybind
	---@param self df_keybindframe
	GetListeningActionId = function(self)
		return self.actionId
	end,

	---set the keybindFrame to listen for a keybind
	---@param self df_keybindframe
	---@param value boolean
	---@param actionId number?
	---@param button button?
	SetListeningState = function(self, value, actionId, button, keybindScrollData)
		self.bIsListening = value
		self.actionId = actionId
		self.button = button
		self.keybindScrollData = keybindScrollData

		self:SetClearButtonsEnabled(not value)
		self:SetEditButtonsEnabled(not value)
	end,

	---get the listening state
	---@param self df_keybindframe
	---@return boolean
	---@return number
	---@return button
	---@return keybind_scroll_data
	GetListeningState = function(self)
		return self.bIsListening, self.actionId, self.button, self.keybindScrollData
	end,

	---return the frame which wait for keybinds
	---@param self df_keybindframe
	---@return frame
	GetKeybindListener = function(self)
		return self.keybindListener
	end,

	---get the scroll frame
	---@param self df_keybindframe
	---@return df_keybindscroll
	GetKeybindScroll = function(self)
		return self.keybindScroll
	end,

	---keybind listener is the frame which reads the key pressed by the player when setting a keybind for an ability
    CreateKeybindListener = function(self)
        local keybindListener = CreateFrame ("frame", nil, self, "BackdropTemplate")
        keybindListener:SetFrameStrata("tooltip")
        keybindListener:SetSize(200, 60)
        detailsFramework:ApplyStandardBackdrop(keybindListener)

		self.keybindListener = keybindListener

        keybindListener.text = detailsFramework:CreateLabel(keybindListener, "- Press a keyboard key to bind.\n- Click to bind a mouse button.\n- Press escape to cancel.", 11, "orange")
        keybindListener.text:SetPoint("center", keybindListener, "center", 0, 0)
        keybindListener:Hide()
    end,

	---callback from the clear button
	---@param self button
	---@param button any
	---@param actionIdentifier string
	---@param keybindTable any
	ClearKeybind = function(self, button, actionIdentifier, keybindTable) --~clear
		if (not keybindTable) then
			return
		end

		---@type df_keybindframe
		local keyBindFrame = getMainFrame(self)

		local keybindType, actionId = keyBindFrame:GetKeybindTypeAndActionFromIdentifier(actionIdentifier)
		local _, index = keyBindFrame:FindKeybindTable(keybindType, actionId, actionIdentifier)

		if (index) then
			if (keybindType == "macro") then
				keybindTable.keybind = ""
			else
				if (keyBindFrame.options.can_modify_keybind_data) then
					local keybindData = keyBindFrame:GetKeybindData()
					table.remove(keybindData, index)
				end
				keyBindFrame:CallKeybindChangeCallback("removed", nil, nil, index)
			end
		end

		local bIsEditingKeybind = keyBindFrame:IsEditingKeybindSettings()
		if (bIsEditingKeybind) then
			keyBindFrame:StopEditingKeybindSettings()
		end

		local keybindScroll = keyBindFrame:GetKeybindScroll()
		keybindScroll:UpdateScroll()
	end,

	---@param self df_keybindframe
	DeleteMacro = function(self)
		local bIsEditingKeybind, actionIdentifier, keybindTable = self:IsEditingKeybindSettings()
		if (not bIsEditingKeybind) then
			return
		end

		if (not self:IsKeybindActionMacro(keybindTable.action)) then
			return
		end

		local _, index = self:FindKeybindTable("macro", keybindTable.action, actionIdentifier)

		if (index) then
			if (self.options.can_modify_keybind_data) then
				local keybindData = self:GetKeybindData()
				table.remove(keybindData, index)
			end

			self:CallKeybindChangeCallback("removed", nil, nil, index)
		end

		self:StopEditingKeybindSettings()

		local keybindScroll = self:GetKeybindScroll()
		keybindScroll:UpdateScroll()
	end,

	---return a string with the modifiers of a keybind
	---@param keybind string
	---@return string
	GetKeybindModifiers = function(keybind)
		local modifier = ""
		keybind = string.upper(keybind)

		if (keybind:find("SHIFT-")) then
			modifier = "SHIFT-"
		end

		if (keybind:find("CTRL-")) then
			modifier = modifier .. "CTRL-"
		end

		if (keybind:find("ALT-")) then
			modifier = modifier .. "ALT-"
		end

		return modifier
	end,

	---return a string with the modifiers of the key pressed by the player
	---@return string
	GetPressedModifiers = function()
		return (IsShiftKeyDown() and "SHIFT-" or "") .. (IsControlKeyDown() and "CTRL-" or "") .. (IsAltKeyDown() and "ALT-" or "")
	end,

	---comment
	---@param self df_keybindframe
	---@param keybindTable df_keybind
	---@param pressedKeybind any
	---@param bKeybindJustCreated boolean
	SaveKeybindToKeybindData = function(self, keybindTable, pressedKeybind, bKeybindJustCreated)
		local keybindData = self:GetKeybindData() --from savedVariables

		--if the keybindTable was created by the function which called this function, then need to add the keybind into the saved variables table
		if (bKeybindJustCreated) then
			table.insert(keybindData, keybindTable)
		end

		keybindTable.keybind = pressedKeybind
	end,

	---return the keybindData table if exists
	---@param self df_keybindframe
	---@param keybindType string
	---@param actionId any
	---@param actionIdentifier actionidentifier?
	---@return df_keybind?, number?
	FindKeybindTable = function(self, keybindType, actionId, actionIdentifier)
		local keybindData = self:GetKeybindData()

		if (keybindType == "spell" or keybindType == "system") then
			for i = 1, #keybindData do
				local keybindTable = keybindData[i]
					if (keybindTable.action == actionId) then
					return keybindTable, i
				end
			end
		end

		if (keybindType == "macro") then
			for i = 1, #keybindData do
				local keybindTable = keybindData[i]
				if (keybindTable.action == actionIdentifier) then
					return keybindTable, i
				end
			end
		end
	end,

	---comment
	---@param self df_keybindframe
	---@param actionIdentifier any
	---@return string
	---@return string|number
	GetKeybindTypeAndActionFromIdentifier = function(self, actionIdentifier)
		---@type string, string
		local keybindType, actionId = actionIdentifier:match("([^%-]+)%-(.+)")
		if (keybindType == "spell") then
			return keybindType, tonumber(actionId) and tonumber(actionId) or 0
		end
		return keybindType, actionId
	end,

	---when the user selected a keybind for an action, this function is called
	---@param self df_keybindframe
	---@param keyPressed any keyboard or mouse key to be used to perform the choosen action
	OnUserPressedKeybind = function(self, keyPressed) --called from OnUserClickedToChooseKeybind and from OnKeyDown() script
		--if the player presses a control key, ignore it
		if (ignoredKeys[keyPressed]) then
			return
		end

		local keybindListener = self:GetKeybindListener()

		--exit the process if 'esc' is pressed
		if (keyPressed == "ESCAPE") then
			self:SetListeningState(false)
			keybindListener:Hide()
			self:SetScript("OnKeyDown", nil)
			return
		end

		local modifiers = self:GetPressedModifiers()
		local pressedKeybind = modifiers .. keyPressed
		local bIsListening, actionIdentifier, button, keybindScrollData = self:GetListeningState()
		local bKeybindJustCreated = false

		--keybindType can be 'macro', 'spell' or 'system'
		--actionId can be a spellId, a macro name or some other action like 'target' 'focus' 'togglemenu'
		local keybindType, actionId = self:GetKeybindTypeAndActionFromIdentifier(actionIdentifier)
		local keybindTable = self:FindKeybindTable(keybindType, actionId, actionIdentifier)

		if (not keybindTable) then
			local iconTexture = keybindScrollData[2]
			--create a new keybindTable
			if (keybindType == "spell") then
				local spellId = actionId
				local spellName = GetSpellInfo(spellId)
				if (spellName) then
					--actionId is the spellId
					keybindTable = createNewKeybindTable(spellName, pressedKeybind, "", actionId, iconTexture)
				end

			elseif (keybindType == "system") then
				local defaultKeybind = defaultMouseKeybindsKV[actionId]
				--actionId is an action like 'target' 'focus' 'togglemenu'
				keybindTable = createNewKeybindTable(defaultKeybind.name, pressedKeybind, "", actionId, iconTexture)

			elseif (keybindType == "macro") then
				local macroName = "New Macro"
				--actionId is the word 'macro'
				keybindTable = createNewKeybindTable(macroName, pressedKeybind, "/say hi", "macro", iconTexture)
			end

			bKeybindJustCreated = true
		end

		if (self.options.can_modify_keybind_data) then
			--if the options for this frame allows it to change the keybind in the addon savedVariables, then do it
			self:SaveKeybindToKeybindData(keybindTable, pressedKeybind, bKeybindJustCreated)
		end

		self:CallKeybindChangeCallback("modified", keybindTable, pressedKeybind)

		self:SetListeningState(false)
		self:SetScript("OnKeyDown", nil)
		keybindListener:Hide()

		--dumpt({"modifier", modifier, "newKeybind", newKeybind, "actionId", actionId})

		local keybindScroll = self:GetKeybindScroll()
		keybindScroll:UpdateScroll()
	end,

	---callback for when the user click in to define a keybind to an action
	---@param self df_selectkeybindbutton
	---@param button any
	---@param actionIdentifier actionidentifier
	---@param keybindTable df_keybindframe
	OnUserClickedToChooseKeybind = function(self, button, actionIdentifier, keybindTable)
		---@type df_keybindframe
		local keyBindFrame = getMainFrame(self)
		local bIsListening, _, frameButton = keyBindFrame:GetListeningState()

		--if the listener is already listening for a keybind while the player clicks on another OnUserClickedToChooseKeybind button, then cancel the previous listener
		if (bIsListening and (self == frameButton)) then
			--if the frame is already listening, it could be a mouse click to set the keybind
			local clickType = mouseButtonToClickType[button]
			keyBindFrame:OnUserPressedKeybind(clickType)
			return
		end

		bIsListening = true

		local keybindScrollData = self.keybindScrollData
		keyBindFrame:SetListeningState(bIsListening, actionIdentifier, self, keybindScrollData)
		keyBindFrame:SetScript("OnKeyDown", keyBindFrame.OnUserPressedKeybind)

		local keybindListener = keyBindFrame:GetKeybindListener()
		keybindListener:ClearAllPoints()
		keybindListener:SetPoint("bottom", self, "top", 0, 0)
		keybindListener:Show()

		local bIsEditingKeybind = keyBindFrame:IsEditingKeybindSettings()
		if (bIsEditingKeybind) then
			keyBindFrame:StopEditingKeybindSettings()
		end
	end,

	SetClearButtonsEnabled = function(self, bIsEnabled)
		local keybindScroll = self:GetKeybindScroll()
		local lines = keybindScroll:GetLines()
		for i = 1, #lines do
			local line = lines[i]
			if (bIsEnabled) then
				--can only set enabled if the keybind isn't empty
				if (line.setKeybindButton.text ~= "") then
					line.clearKeybindButton:Enable()
				end
			else
				line.clearKeybindButton:Disable()
			end
		end
	end,

	SetEditButtonsEnabled = function(self, bIsEnabled)
		local keybindScroll = self:GetKeybindScroll()
		local lines = keybindScroll:GetLines()
		for i = 1, #lines do
			local line = lines[i]
			if (bIsEnabled) then
				--can only set enabled if the keybind isn't empty
				if (line.setKeybindButton.text ~= "") then
					line.editKeybindSettingsButton:Enable()
				end
			else
				line.editKeybindSettingsButton:Disable()
			end
		end
	end,

    RefreshKeybindScroll = function(self, scrollData, offset, totalLines) --~refresh
        local keyBindFrame = getMainFrame(self)

		---@type table<string, any[]>
		local repeatedKeybinds = {}

		---@cast scrollData keybind_scroll_data[]

		--build a list of repeated keybinds
		for index = 1, #scrollData do
			local keybindScrollData = scrollData[index]
			local actionName, iconTexture, actionId, keybindData, bIsAvailable = unpack(keybindScrollData)
			---@cast keybindData df_keybind

			if (bIsAvailable) then
				if (type(keybindData) == "table" and keybindData.keybind and keybindData.keybind ~= "") then
					repeatedKeybinds[keybindData.keybind] = repeatedKeybinds[keybindData.keybind] or {}
					table.insert(repeatedKeybinds[keybindData.keybind], keybindData)
				end
			end
		end

		--local bIsListening = keyBindFrame:GetListeningState()
		--local bIsEditingKeybind = keyBindFrame:IsEditingKeybindSettings()

		local lastKeybindActionType = ""

		--refresh the scroll bar
        for i = 1, totalLines do
            local index = i + offset
			---@type keybind_scroll_data
            local keybindScrollData = scrollData[index]

            if (keybindScrollData) then
                local line = self:GetLine(i)

				---@type string, number, any, df_keybind|false, boolean, number, string
				local actionName, iconTexture, actionId, keybindTable, bIsAvailable, sortNumber, actionIdentifier = unpack(keybindScrollData)

				if (actionName == "@separator") then
					line:SetAsSeparator(true, iconTexture)
				else
					line:SetAsSeparator(false)
					--if the keybindData doesn't exists, means the user did not set a keybind for this action yet
					--in this case keybindData is a false boolean
					--keydindText is the text showing which keyboard or mouse button need to be pressed to activate the action
					--if the keybind isn't set, use an empty string
					local keydindText = keybindTable and keybindTable.keybind or ""

					keydindText = keydindText:gsub("type1", _G["LEFT_BUTTON_STRING"])
					keydindText = keydindText:gsub("type2", _G["RIGHT_BUTTON_STRING"])
					keydindText = keydindText:gsub("type3", _G["MIDDLE_BUTTON_STRING"])

					if (keydindText:match("type%d")) then
						local buttonId = keydindText:match("type(%d)")
						buttonId = tonumber(buttonId)
						if (buttonId) then
							local buttonName = _G["BUTTON_" .. buttonId .. "_STRING"]
							if (buttonName and type(buttonName) == "string") then
								keydindText = keydindText:gsub("type" .. buttonId, buttonName)
							end
						end
					end

					keydindText = keydindText:gsub("%-", " - ")

					line.setKeybindButton.text = keydindText

					--start editing keybind button
					line.setKeybindButton:SetClickFunction(keyBindFrame.OnUserClickedToChooseKeybind, actionIdentifier, keybindTable, "left")
					line.setKeybindButton:SetClickFunction(keyBindFrame.OnUserClickedToChooseKeybind, actionIdentifier, keybindTable, "right")

					--clear keybind button
					if (keydindText ~= "") then
						line.clearKeybindButton:Enable()
						line.clearKeybindButton:SetClickFunction(keyBindFrame.ClearKeybind, actionIdentifier, keybindTable)
						line.editKeybindSettingsButton:Enable()
						line.editKeybindSettingsButton:SetClickFunction(keyBindFrame.StartEditingKeybindSettings, actionIdentifier, keybindTable)
					else
						line.clearKeybindButton:Disable()
						line.editKeybindSettingsButton:Disable()
					end

					local setKeybindButtonWidget = line.setKeybindButton.widget
					setKeybindButtonWidget.keybindScrollData = keybindScrollData

					line.spellIconTexture:SetTexture(iconTexture)

					if (not bIsAvailable) then
						line.spellIconTexture:SetDesaturated(true)
						line.setKeybindButton.widget:SetColor(0, 0, 0, 0.1)
						detailsFramework:SetFontColor(line.actionNameFontString, "gray")
					else
						line.spellIconTexture:SetDesaturated(false)
						line.setKeybindButton.widget:SetColor(unpack(roundedCornerPreset.color))
						detailsFramework:SetFontColor(line.actionNameFontString, "BLIZZ_OPTIONS_COLOR")
					end

					line.spellIconTexture:SetTexCoord(.1, .9, .1, .9)
					line.actionNameFontString:SetText(actionName)

					line.setKeybindButton.widget:SetBorderCornerColor(0, 0, 0, 0)

					--check for repeated keybind
					if (keybindTable and bIsAvailable) then
						local keybind = keybindTable.keybind
						local keybindTables = repeatedKeybinds[keybind]
						if (keybindTables and #keybindTables > 1) then
							line.setKeybindButton.widget:SetBorderCornerColor(1, .68, 0, 1)
						end
					end
				end
            end
        end
    end,

	---run when the mouse enters a scroll line
	---@param self df_keybindscrollline
	OnEnterScrollLine = function(self)
		local keyBindFrame = getMainFrame(self)
		local editPanel = keyBindFrame:GetEditPanel()
		editPanel.conditionsFailLoadReasonText:SetText("")

		if (self.bIsSeparator) then
			return
		end

		if (not self.keybindScrollLine) then
			--when the mouse enters a child frame, the self is the child frame, not the scroll line
			self = self:GetParent() ---@diagnostic disable-line getting the parent from df_keybindscrollline would result in type frame making invalid convertion
			---@cast self df_keybindscrollline
		end

		self.highlightTexture:Show()

		--if the keybind is a macro, preview the macro text in the edit panel's lua edit box
		local bIsEditingKeybind = keyBindFrame:IsEditingKeybindSettings()

		if (not bIsEditingKeybind) then
			local keybindScrollData = self.setKeybindButton.widget["keybindScrollData"]
			if (keybindScrollData) then
				local actionName, iconTexture, actionId, keybindTable, bIsAvailable, sortNumber, actionIdentifier = unpack(keybindScrollData)
				---@cast keybindTable df_keybind
				if (actionName ~= "@separator" and keybindTable) then
					if (keybindTable.macro and keybindTable.macro ~= "") then
						---@type df_editkeybindframe
						editPanel.editMacroEditBox:SetText(keybindTable.macro)
					end

					local loadCondition = keybindTable.conditions
					local bCanLoad, reason = detailsFramework:PassLoadFilters(loadCondition)

					if (not bCanLoad) then
						editPanel.conditionsFailLoadReasonText:SetText("This keybind can't be loaded because it's conditions are not met:\n- " .. (reason or ""))
					else
						editPanel.conditionsFailLoadReasonText:SetText("")
					end
				end
			end
		end
	end,

	---run when the mouse leaves a scroll line
	---@param self df_keybindscrollline
	OnLeaveScrollLine = function(self)
		if (self.bIsSeparator) then
			return
		end

		if (not self.keybindScrollLine) then
			--when the mouse enters a child frame, the self is the child frame, not the scroll line
			self = self:GetParent() ---@diagnostic disable-line getting the parent from df_keybindscrollline would result in type frame making invalid convertion
			---@cast self df_keybindscrollline
		end

		self.highlightTexture:Hide()

		--if the keybind is a macro, a preview might be showing in the edit panel's lua edit box, hide it
		local keyBindFrame = getMainFrame(self)
		local bIsEditingKeybind = keyBindFrame:IsEditingKeybindSettings()

		if (not bIsEditingKeybind) then
			local editPanel = keyBindFrame:GetEditPanel()
			editPanel.editMacroEditBox:SetText("")
		end
	end,

    ---@param keybindScroll frame
    ---@param index number
    CreateKeybindScrollLine = function(keybindScroll, index) --~create
		local keyBindFrame = getMainFrame(keybindScroll)

		---@type df_keybindscrollline
        local line = CreateFrame("frame", "$parentLine" .. index, keybindScroll)
        line:SetSize(keyBindFrame.options.width - 10, keyBindFrame.options.line_height)
        line:SetPoint("topleft", keyBindFrame, "topleft", 1, -22 - (index-1) * keyBindFrame.options.line_height)
		line:EnableMouse(true)
		line.keybindScrollLine = true

        --detailsFramework:ApplyStandardBackdrop(line, index % 2 == 0)
		--line:SetBackdropBorderColor(0, 0, 0, 0)

		line.backgroundTexture = line:CreateTexture("$parentBackgroundTexture", "background")
		line.backgroundTexture:SetAllPoints()

		if (index % 2 == 0) then
			line.backgroundTexture:SetColorTexture(0, 0, 0, 0.1)
		else
			line.backgroundTexture:SetColorTexture(0, 0, 0, 0)
		end

		line.highlightTexture = line:CreateTexture(nil, "border")
		line.highlightTexture:SetAllPoints()
		line.highlightTexture:SetColorTexture(1, 1, 1, .1)
		line.highlightTexture:Hide()

		line:SetScript("OnEnter", keyBindFrame.OnEnterScrollLine)
		line:SetScript("OnLeave", keyBindFrame.OnLeaveScrollLine)

        detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)

        local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
        local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
        local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
        local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
        local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

		line.separatorTitleText = line:CreateFontString("$parentSeparatorTitleText", "overlay", "GameFontNormal")
		line.separatorTitleText:SetPoint("center", line, "center", 0, 0)

		line.spellIconTexture = line:CreateTexture("$parentIcon", "overlay")
		line.spellIconTexture:SetSize(keyBindFrame.options.line_height - 2, keyBindFrame.options.line_height - 2)

		line.actionNameFontString = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
		detailsFramework:SetFontColor(line.actionNameFontString, "BLIZZ_OPTIONS_COLOR")
		detailsFramework:SetFontSize(line.actionNameFontString, 12)

		---@type df_button
        line.setKeybindButton = detailsFramework:CreateButton(line, function()end, headerTable[3].width, keyBindFrame.options.line_height-6, "", nil, nil, nil, "SetNewKeybindButton", "$parentSetNewKeybindButton", 0, nil, options_text_template)
		line.setKeybindButton.textcolor = "white"
		line.setKeybindButton.textsize = 10
		line.setKeybindButton:SetHook("OnEnter", keyBindFrame.OnEnterScrollLine)
		line.setKeybindButton:SetHook("OnLeave", keyBindFrame.OnLeaveScrollLine)

		detailsFramework:AddRoundedCornersToFrame(line.setKeybindButton, roundedCornerPreset)

		---@type df_button
        line.clearKeybindButton = detailsFramework:CreateButton(line, keyBindFrame.ClearKeybind, 16, keyBindFrame.options.line_height-2, "", nil, nil, nil, "DeleteKeybindButton", "$parentDeleteKeybindButton", 2, nil, options_text_template)
		line.clearKeybindButton:SetBackdropBorderColor(0, 0, 0, 0)
        line.clearKeybindButton:SetIcon([[Interface\COMMON\CommonIcons]], nil, nil, nil, {0.1264, 0.2514, 0.5048, 0.7548}, nil, nil, 4)

		---@type df_button
        line.editKeybindSettingsButton = detailsFramework:CreateButton(line, keyBindFrame.StartEditingKeybindSettings, 16, keyBindFrame.options.line_height-2, "", nil, nil, nil, "EditKeybindButton", "$parentEditKeybindButton", 2, nil, options_text_template)
		line.editKeybindSettingsButton:SetBackdropBorderColor(0, 0, 0, 0)
        line.editKeybindSettingsButton:SetIcon([[Interface\BUTTONS\UI-GuildButton-PublicNote-Disabled]])

        line:AddFrameToHeaderAlignment(line.spellIconTexture)
        line:AddFrameToHeaderAlignment(line.actionNameFontString)
        line:AddFrameToHeaderAlignment(line.setKeybindButton)
        line:AddFrameToHeaderAlignment(line.clearKeybindButton)
        line:AddFrameToHeaderAlignment(line.editKeybindSettingsButton)

        line:AlignWithHeader(keyBindFrame.Header, "left")

		line.SetAsSeparator = setAsSeparator

		return line
    end,

    ---comment
    ---@param self df_keybindframe
    CreateKeybindScroll = function(self) --~scroll
        local scroll_width = self.options.scroll_width
        local scroll_height = self.options.scroll_height
        local scroll_lines = self.options.amount_lines
        local scroll_line_height = self.options.line_height

		--~header
        ---@type df_headerframe
		self.Header = DetailsFramework:CreateHeader(self, headerTable, headerOptions)
		self.Header:SetPoint("topleft", self, "topleft", 0, 0)

		--this is a hack to hide the background black texture column of the header
		--making the area more clean for the create macro button
		self.Header.columnHeadersCreated[2].Center:SetAlpha(0)

		local onClickCreateMacroButton = function() --~macro
			local newMacroName = "New @Macro (" .. math.random(10000, 99999) .. ")"
			local actionIdentifier = "macro-" .. newMacroName

			local keybindTable = createNewKeybindTable(newMacroName, "", "/say Hi", actionIdentifier, 136377)
			local pressedKeybind = ""

			if (self.options.can_modify_keybind_data) then
				--if the options for this frame allows it to change the keybind in the addon savedVariables, then do it
				local bKeybindJustCreated = true
				self:SaveKeybindToKeybindData(keybindTable, pressedKeybind, bKeybindJustCreated)
			end

			self:CallKeybindChangeCallback("modified", keybindTable, pressedKeybind)

			local keybindScroll = self:GetKeybindScroll()
			keybindScroll:UpdateScroll()

			--start editing this keybindTable
			self:StartEditingKeybindSettings("LeftButton", actionIdentifier, keybindTable)

			--get the keybind editor frame
			---@type df_editkeybindframe
			local keybindEditor = self:GetEditPanel()

			local macroEditBox = keybindEditor.editMacroEditBox
			macroEditBox:SetText(keybindTable.macro)
			macroEditBox:SetFocus()
		end

		local createMacroButton = detailsFramework:CreateButton(self.Header, onClickCreateMacroButton, 200, 32, "Create Macro Keybind", nil, nil, nil, "CreateMacroButton", "$parentCreateMacroButton", 0, DARK_BUTTON_TEMPLATE, detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
		createMacroButton:SetPoint("left", self.Header, "left", 2, 0)
		createMacroButton:SetFrameLevel(self.Header:GetFrameLevel()+10)
		createMacroButton:SetIcon(136377)
		createMacroButton:SetTemplate("OPTIONS_CIRCLEBUTTON_TEMPLATE")
		createMacroButton:SetScale(0.9)
		createMacroButton:SetFontSize(13)

		local keybindScroll = detailsFramework:CreateScrollBox(self, "$parentScrollBox", detailsFramework.KeybindMixin.RefreshKeybindScroll, {}, scroll_width, scroll_height, scroll_lines, scroll_line_height)
		---@cast keybindScroll df_keybindscroll

		detailsFramework:ReskinSlider(keybindScroll)
		keybindScroll:SetPoint("topleft", self.Header, "bottomleft", 0, -5)
        self.keybindScroll = keybindScroll

		keybindScroll:SetBackdropColor(0, 0, 0, 0)
		keybindScroll:SetBackdropBorderColor(0, 0, 0, 0)
		keybindScroll.__background:SetAlpha(0)

        for i = 1, scroll_lines do
            keybindScroll:CreateLine(self.CreateKeybindScrollLine)
        end

		--scroll data constructor
		function keybindScroll.UpdateScroll() --~update
			--keybind data from saved variables
			---@type df_keybind[]
			local data = self:GetKeybindData()

			--pre build keybind data to be used by the scroll data constructor
			---@type table<any, df_keybind>
			local keybindDataParsed = {}

			---@type df_keybind[]
			local allKeybindMacros = {}

			--iterage amoung keybinds already set by the user
			--and fill the tables 'keybindDataParsed' where the key is actionId and the value is the keybind data
			--also fill the table 'allKeybindMacros' with all macros, this is an array with keybind data
			for i = 1, #data do
				---@type df_keybind
				local keybindData = data[i]

				local actionId = keybindData.action --the actionId can be "macro" for macros
				local keybind = keybindData.keybind --the keybind to active the action
				local macro = keybindData.macro --macro here is the macro text
				local name = keybindData.name --for macros it shows the macro name where the spellName is for instance
				local icon = keybindData.icon --for macros the user can set an icon
				local conditions = keybindData.conditions --allows the user to set conditions for the keybind to be active

				local bIsSpell = actionId and type(actionId) == "number"
				if (bIsSpell) then
					local spellId = actionId
					keybindDataParsed[spellId] = keybindData

				elseif (defaultMouseKeybindsKV[actionId]) then
					keybindDataParsed[actionId] = keybindData --"target" "focus" "togglemenu"

				end

				if (type(actionId) == "string" and self:IsKeybindActionMacro(actionId)) then
					table.insert(allKeybindMacros, keybindData)
				end
			end

			---@type keybind_scroll_data[]
			local scrollData = {}

			---@type keybind_scroll_data[] store spells that are not available, they are added after the spells available
			local spellsNotAvailable = {}

			---@type keybind_scroll_data[] store macros that are not available, they are added after the spells available
			local macrosNotAvailable = {}

			table.insert(scrollData, {"@separator", "Regualar Actions", "", "", false, -1})

			if (self.options.show_unitcontrols) then
				for i, mouseActionKeyInfo in ipairs(defaultMouseKeybinds) do
					local mouseActionId = mouseActionKeyInfo.action
					local mouseDefaultKeybind = mouseActionKeyInfo.keybind
					local mouseIcon = mouseActionKeyInfo.icon
					local mouseActionName = mouseActionKeyInfo.name

					local keybindData = keybindDataParsed[mouseActionId]
					local actionIdentifier = "system-" .. mouseActionId

					local thisScrollData = {keybindData and keybindData.name or mouseActionName, keybindData and keybindData.icon or mouseIcon, mouseActionId, keybindData or false, true, 0, actionIdentifier}
					table.insert(scrollData, 1+i, thisScrollData)
				end
			end

			table.insert(scrollData, {"@separator", "Macros", "", "", false, 1})

			if (self.options.show_macros) then
				--sort the table alphabetically
				table.sort(allKeybindMacros, function(t1, t2) return t1.name < t2.name end)

				for i, keybindData in ipairs(allKeybindMacros) do
					local macroName = keybindData.name
					local macroIcon = keybindData.icon
					local macroText = keybindData.macro
					local actionId = keybindData.action
					local conditions = keybindData.conditions

					local bCanLoad = detailsFramework:PassLoadFilters(conditions)
					local sortScore = 2

					local actionIdentifier = actionId

					---@type keybind_scroll_data
					local thisScrollData = {macroName, macroIcon, actionId, keybindData, bCanLoad, sortScore, actionIdentifier}
					if (bCanLoad) then
						table.insert(scrollData, thisScrollData)
					else
						table.insert(macrosNotAvailable, thisScrollData)
					end
				end
			end

			table.insert(scrollData, {"@separator", "Spells", "", "", false, 3})

			local indexToAddNotAvailableMacros = #scrollData + 1

			if (self.options.show_spells) then
				--the a list of all spells
				local allPlayerSpells = detailsFramework:GetAvailableSpells()

				--bIsAvailable is a boolean that tells if the spell is from the spec the player is currently using (spells grayed out on the spellbook would be false here)
				for spellId, bIsAvailable in pairs(allPlayerSpells) do
					local spellName, _, spellIcon = GetSpellInfo(spellId)
					if (spellName) then
						---@type df_keybind|nil
						local keybindData = keybindDataParsed[spellId] --could be nil if doesn't exists

						--show spells with keybinds at the top of the list, then show spells that are available, then show spells that are not available
						--always sub sorting by the spell name
						local sortScore = getSpellSortOrder(keybindData, spellName, bIsAvailable)
						local actionId = spellId

						local actionIdentifier = "spell-" .. actionId

						---@type keybind_scroll_data
						local thisScrollData = {keybindData and keybindData.name or spellName, keybindData and keybindData.icon or spellIcon, actionId, keybindData or false, bIsAvailable, sortScore, actionIdentifier}

						if (not bIsAvailable) then
							spellsNotAvailable[#spellsNotAvailable+1] = thisScrollData
						else
							scrollData[#scrollData+1] = thisScrollData
						end
					end
				end

				table.sort(scrollData, function(a, b) return a[6] < b[6] end)
				table.sort(spellsNotAvailable, function(a, b) return a[6] < b[6] end)
			end

			if (#macrosNotAvailable > 0) then
				table.insert(scrollData, {"@separator", "Macros Not Available", "", "", false, 1})

				for i = 1, #macrosNotAvailable do
					local thisScrollData = macrosNotAvailable[i]
					table.insert(scrollData, thisScrollData)
				end
			end

			if (#spellsNotAvailable > 0) then
				table.insert(scrollData, {"@separator", "Spells Not Available", "", "", false, 3})

				for i = 1, #spellsNotAvailable do
					local thisScrollData = spellsNotAvailable[i]
					table.insert(scrollData, thisScrollData)
				end
			end

			keybindScroll:SetData(scrollData)
			keybindScroll:Refresh()
		end
    end,

	---return the keybind data
	---@param self df_keybindframe
	---@return df_keybind[]
	GetKeybindData = function(self)
		return self.data
	end,

    ---set the keybind data from a profile
	---data consists in a table where the actionId (any) is the key and the value is the keybind (string)
    ---@param self df_keybindframe
	---@param newData df_keybind[]
	SetKeybindData = function(self, newData)
		self.data = newData
		local keybindScroll = self:GetKeybindScroll()
		keybindScroll:UpdateScroll()
	end,

	---set the callback function to be called when the player set or clear a keybind
	---@param self df_keybindframe
	---@param callback function
	SetKeybindCallback = function(self, callback)
		self.callback = callback
		local keybindScroll = self:GetKeybindScroll()
		keybindScroll:UpdateScroll()
	end,

	---@param self df_keybindframe
	---@return function
	GetKeybindCallback = function(self)
		return self.callback
	end,

	---@param self df_keybindframe
	---@param type string "modified", "removed", "conditions", "name"
	---@param keybindTable df_keybind?
	---@param keybindPressed string?
	---@param removedIndex number?
	---@param macroText string?
	CallKeybindChangeCallback = function(self, type, keybindTable, keybindPressed, removedIndex, macroText)
		local callbackFunc = self:GetKeybindCallback()
		if (callbackFunc) then
			detailsFramework:Dispatch(callbackFunc, self, type, keybindTable, keybindPressed, removedIndex, macroText)
		end
	end,

	---@param self df_keybindframe
	---@param actionId any
	IsKeybindActionMacro = function(self, actionId)
		if (type(actionId) == "string") then
			return actionId:match("^macro%-")
		end
	end,

	---on press enter on the edit frame name editbox
	---@param self df_keybindframe
	---@param newName string
	OnKeybindNameChange = function(self, newName)
		local editFrame = self:GetEditPanel()
		local keybindTable = editFrame.keybindTable

		local actionId = keybindTable.action
		---@cast actionId string

		keybindTable.name = newName

		if (self:IsKeybindActionMacro(actionId)) then
			keybindTable.action = "macro-" .. newName
		end

		self:CallKeybindChangeCallback("name", keybindTable)

		local keybindScroll = self:GetKeybindScroll()
		keybindScroll:UpdateScroll()
	end,

	---@param self df_keybindframe
	---@param macroText string
	OnKeybindMacroChange = function(self, macroText)
		---@type df_keybindframe
		local keyBindFrame = getMainFrame(self)

		local editFrame = keyBindFrame:GetEditPanel()
		local keybindTable = editFrame.keybindTable

		if (keyBindFrame.options.can_modify_keybind_data) then
			keybindTable.macro = macroText
		end

		keyBindFrame:CallKeybindChangeCallback("macro", keybindTable, nil, nil, macroText)
	end,

	OnKeybindIconChange = function(self, texture)
		local editFrame = self:GetEditPanel()
		local keybindTable = editFrame.keybindTable
		keybindTable.icon = texture
		self:CallKeybindChangeCallback("icon", keybindTable)
	end,

	---return true if the user is editing a keybind
	---@param self df_keybindframe
	---@return boolean bIsEditing
	---@return string actionIdentifier
	---@return df_keybind keybindTable
	IsEditingKeybindSettings = function(self)
		local editFrame = self:GetEditPanel()
		return editFrame.bIsEditing, editFrame.actionIdentifier, editFrame.keybindTable
	end,

	---start editing the keybind settings
	---@param self frame
	---@param button string
	---@param actionIdentifier string
	---@param keybindTable df_keybind
	StartEditingKeybindSettings = function(self, button, actionIdentifier, keybindTable)
		---@type df_keybindframe
		local keyBindFrame = getMainFrame(self)

		local bIsListening = keyBindFrame:GetListeningState()
		if (bIsListening) then
			return
		end

		local editFrame = keyBindFrame:GetEditPanel()
		editFrame:Enable()

		editFrame.nameEditBox:SetText(keybindTable.name)
		editFrame.iconPickerButton:SetIcon(keybindTable.icon)

		local actionId = keybindTable.action
		---@cast actionId string
		if (keyBindFrame:IsKeybindActionMacro(actionId)) then
			editFrame.editMacroEditBox:SetText(keybindTable.macro)
			editFrame.deleteMacroButton:Enable()
		else
			editFrame.editMacroEditBox:Disable()
			editFrame.deleteMacroButton:Disable()
		end

		editFrame.actionIdentifier = actionIdentifier
		editFrame.keybindTable = keybindTable
		editFrame.bIsEditing = true
	end,

	---disable and clear all entries in the edit frame
	---@param self df_keybindframe
	StopEditingKeybindSettings = function(self)
		local editFrame = self:GetEditPanel()
		editFrame.bIsEditing = false
		editFrame.actionIdentifier = nil
		editFrame.keybindTable = nil
		editFrame:Disable()
	end,

	---return the editing keybind frame
	---@param self df_keybindframe
	---@return df_editkeybindframe
	GetEditPanel = function(self)
		return self.editKeybindFrame
	end,

	---@param self df_keybindframe
	CreateEditPanel = function(self) --~edit
        local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
        local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
        local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
        local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
        local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

		---@type df_editkeybindframe
		local editFrame = CreateFrame("frame", "$parentEditPanel", self, "BackdropTemplate")
		editFrame:SetSize(self.options.edit_width, self.options.edit_height)
		editFrame:SetPoint("topleft", self, "topright", 28, 0) --give space for the scrollbar
		self.editKeybindFrame = editFrame

		--name
		local nameText = editFrame:CreateFontString("$parentNameText", "overlay", "GameFontNormal")
		nameText:SetPoint("topleft", editFrame, "topleft", 10, -10)
		nameText:SetText("Name:")
		detailsFramework:SetFontColor(nameText, "BLIZZ_OPTIONS_COLOR")

		local nameEditBoxCallback = function(param1, param2, text)
			--print("name change", param1, param2, text)
			--self:OnKeybindNameChange(text)
		end
		local nameEditBox = detailsFramework:CreateTextEntry(editFrame, nameEditBoxCallback, 200, 20, "nameEditBox", "$parentNameEditBox", nil, options_dropdown_template)
		nameEditBox:SetPoint("topleft", nameText, "bottomleft", 0, -5)
		nameEditBox:SetBackdropColor(.1, .1, .1, .834)
		nameEditBox:SetJustifyH("left")
		nameEditBox:SetTextInsets(5, 3, 0, 0)

		--icon
		local iconText = editFrame:CreateFontString("$parentIconText", "overlay", "GameFontNormal")
		iconText:SetPoint("topleft", nameEditBox.widget, "bottomleft", 0, -10)
		iconText:SetText("Icon:")
		detailsFramework:SetFontColor(iconText, "BLIZZ_OPTIONS_COLOR")

		local iconPickerButtonCallback = function(texture)
			editFrame.iconPickerButton:SetIcon(texture)
			--self:OnKeybindIconChange(texture)
		end

		local iconPickerButton = detailsFramework:CreateButton(editFrame, function() detailsFramework:IconPick(iconPickerButtonCallback, true) end, 20, 20, "", nil, nil, nil, "iconPickerButton", "$parentIconPickerButton", 0, DARK_BUTTON_TEMPLATE, detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
		iconPickerButton:SetPoint("topleft", iconText, "bottomleft", 0, -5)
		iconPickerButton:SetIcon([[]], nil, nil, nil, {0.1264, 0.2514, 0.5048, 0.7548}, nil, nil, 4)
		iconPickerButton.tooltip = "pick an icon"

		--macro
		local editMacroText = editFrame:CreateFontString("$parentEditMacroText", "overlay", "GameFontNormal")
		editMacroText:SetPoint("topleft", iconPickerButton.widget, "bottomleft", 0, -10)
		editMacroText:SetText("Macro:")
		detailsFramework:SetFontColor(editMacroText, "BLIZZ_OPTIONS_COLOR")

		---@type df_luaeditor
		local editMacroEditBox = detailsFramework:NewSpecialLuaEditorEntry(editFrame, self.options.edit_width-35, 200, "editMacroEditBox", "$parentEditMacroEditBox", true)
		editMacroEditBox:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
		editMacroEditBox:SetBackdropBorderColor(0, 0, 0, 1)
		editMacroEditBox:SetBackdropColor(.1, .1, .1, .5)
		detailsFramework:ReskinSlider(editMacroEditBox.scroll)
		editMacroEditBox:SetPoint("topleft", editMacroText, "bottomleft", 0, -5)

		editMacroEditBox["Center"]:SetColorTexture(.1, .1, .1, .834)

		local saveButtonCallback = function()
			local bIsEditing, actionIdentifier, keybindTable  = self:IsEditingKeybindSettings()
			if (bIsEditing and keybindTable) then
				local keybindName = nameEditBox:GetText()
				local iconTexture = editFrame.iconPickerButton.icon
				local keybindTexture = iconTexture:GetTexture()
				local keybindMacroText = editMacroEditBox:GetText()

				--check if the macro has default name and icon
				if (keybindName:find("@Macro") and iconTexture:GetTexture() == 136377) then
					for macro in keybindMacroText:gmatch("([^%s]+)") do
						local spellName, _, spellIcon = GetSpellInfo(macro)
						if (spellName) then
							keybindName = spellName
							keybindTexture = spellIcon
						end
					end
				end

				self:OnKeybindNameChange(keybindName)
				self:OnKeybindIconChange(keybindTexture)

				local actionId = keybindTable.action
				---@cast actionId string

				if (self:IsKeybindActionMacro(actionId)) then
					self:OnKeybindMacroChange(keybindMacroText)
				end
			end

			self:StopEditingKeybindSettings()

			local keybindScroll = self:GetKeybindScroll()
			keybindScroll:UpdateScroll()
		end

		--save button
		local saveButton = detailsFramework:CreateButton(editFrame, saveButtonCallback, 120, 20, "Save", nil, nil, nil, "saveButton", "$parentSaveButton", 0, DARK_BUTTON_TEMPLATE, detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
		saveButton:SetPoint("topleft", editMacroEditBox, "bottomleft", 0, -10)
		saveButton:SetIcon([[Interface\BUTTONS\UI-CheckBox-Check]])

		local cancelButtonCallback = function()
			self:StopEditingKeybindSettings()
		end

		--cancel button
		local cancelButton = detailsFramework:CreateButton(editFrame, cancelButtonCallback, 120, 20, "Cancel", nil, nil, nil, "cancelButton", "$parentCancelButton", 0, DARK_BUTTON_TEMPLATE, detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
		cancelButton:SetPoint("left", saveButton, "right", 10, 0)
		cancelButton:SetIcon([[Interface\BUTTONS\UI-GROUPLOOT-PASS-DOWN]])

		--conditions
		local conditionsText = editFrame:CreateFontString("$parentConditionsText", "overlay", "GameFontNormal")
		conditionsText:SetPoint("topleft", saveButton.widget, "bottomleft", 0, -40)
		conditionsText:SetText("Can Load Keybind?")
		detailsFramework:SetFontColor(conditionsText, "BLIZZ_OPTIONS_COLOR")

		local onLoadConditionsChange = function()
			--no parameters is passed as the modifications are done directly on the keybindTable.conditions
			--trigger a callback to inform the addon about the change
			self:CallKeybindChangeCallback("conditions", editFrame.keybindTable)
		end

		local openConditionsPanel = function()
			local conditionsSettings = editFrame.keybindTable.conditions
			detailsFramework:OpenLoadConditionsPanel(conditionsSettings, onLoadConditionsChange, {title = "Keybind Load Conditions", name = editFrame.keybindTable.name})
		end

		local conditionsButton = detailsFramework:CreateButton(editFrame, openConditionsPanel, 160, 20, "Edit Load Conditions", nil, nil, [[]], "conditionsButton", "$parentConditionsButton", 0, DARK_BUTTON_TEMPLATE, detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
		conditionsButton:SetPoint("topleft", conditionsText, "bottomleft", 0, -5)

		local conditionsFailLoadReasonText = editFrame:CreateFontString("$parentConditionsFailLoadText", "overlay", "GameFontNormal")
		conditionsFailLoadReasonText:SetPoint("topleft", conditionsButton.widget, "bottomleft", 0, -20)
		conditionsFailLoadReasonText:SetText("")
		conditionsFailLoadReasonText:SetJustifyH("left")
		detailsFramework:SetFontColor(conditionsFailLoadReasonText, "firebrick")
		editFrame.conditionsFailLoadReasonText = conditionsFailLoadReasonText

		--create a button to delete a macro keybind
		local deleteMacroText = editFrame:CreateFontString("$parentDeleteMacroText", "overlay", "GameFontNormal")
		deleteMacroText:SetPoint("topleft", saveButton.widget, "bottomleft", 180, -40)
		deleteMacroText:SetText("Delete Macro")
		detailsFramework:SetFontColor(deleteMacroText, "BLIZZ_OPTIONS_COLOR")

		local onClickDeleteMacroButton = function()
			self:DeleteMacro()
		end

		local deleteMacroButton = detailsFramework:CreateButton(editFrame, onClickDeleteMacroButton, 160, 20, "Delete This Macro", nil, nil, [[]], "deleteMacroButton", "$parentDeleteMacroButton", 0, DARK_BUTTON_TEMPLATE, detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
		deleteMacroButton:SetPoint("topleft", deleteMacroText, "bottomleft", 0, -5)

		--methods
		function editFrame:Disable()
			nameEditBox:SetText("")
			nameEditBox:Disable()
			editMacroEditBox:SetText("")
			editMacroEditBox:Disable()
			iconPickerButton:Disable()
			conditionsButton:Disable()
			deleteMacroButton:Disable()
			saveButton:Disable()
			cancelButton:Disable()
		end

		function editFrame:Enable()
			nameEditBox:Enable()
			iconPickerButton:Enable()
			conditionsButton:Enable()
			deleteMacroButton:Enable()
			editMacroEditBox:Enable()
			saveButton:Enable()
			cancelButton:Enable()
		end

		editFrame:Disable()
	end,
}

---@param parent frame
---@param name string?
---@param options table?
---@param setKeybindCallback function?
---@param keybindData table?
function detailsFramework:CreateKeybindFrame(parent, name, options, setKeybindCallback, keybindData)
    ---@type df_keybindframe
    local keyBindFrame = CreateFrame("frame", name, parent, "BackdropTemplate")
    keyBindFrame.bIsKeybindFrame = true

    detailsFramework:Mixin(keyBindFrame, detailsFramework.OptionsFunctions)
    detailsFramework:Mixin(keyBindFrame, detailsFramework.KeybindMixin)

    options = options or {}
    keyBindFrame:BuildOptionsTable(default_options, options)

	if (keyBindFrame.options.width ~= default_options.width or keyBindFrame.options.height ~= default_options.height) then
		local lineHeight = keyBindFrame.options.line_height
		keyBindFrame.options.amount_lines = math.floor((keyBindFrame.options.height - 20) / lineHeight)
		keyBindFrame.options.scroll_height = keyBindFrame.options.height - 20
		keyBindFrame.options.scroll_width = keyBindFrame.options.width - 10
	end

	if (keyBindFrame.options.edit_height == 0) then
		keyBindFrame.options.edit_height = keyBindFrame.options.height
	end

    keyBindFrame:SetSize(keyBindFrame.options.width, keyBindFrame.options.height)

	keyBindFrame:SetScript("OnHide", function()
		if (keyBindFrame:IsListening()) then
			keyBindFrame:SetListeningState(false)
			local keybindListener = keyBindFrame:GetKeybindListener()
			keybindListener:SetScript("OnKeyDown", nil)
		end

		local bIsEditingKeybind = keyBindFrame:IsEditingKeybindSettings()
		if (bIsEditingKeybind) then
			keyBindFrame:StopEditingKeybindSettings()
		end

		keyBindFrame:SetClearButtonsEnabled(true)
		keyBindFrame:SetEditButtonsEnabled(true)
	end)

	keyBindFrame:SetScript("OnShow", function()
		local keybindScroll = keyBindFrame:GetKeybindScroll()
		keybindScroll:UpdateScroll()
	end)

	keyBindFrame:CreateKeybindScroll()
	keyBindFrame:CreateKeybindListener()
	keyBindFrame:CreateEditPanel()

	keyBindFrame:SetKeybindData(keybindData or {})

	if (setKeybindCallback) then
		keyBindFrame:SetKeybindCallback(setKeybindCallback)
	end

    return keyBindFrame
end
