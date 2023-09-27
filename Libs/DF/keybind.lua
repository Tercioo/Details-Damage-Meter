---@type detailsframework
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local unpack = unpack

---@class df_keybindscroll : df_scrollbox
---@field UpdateScroll fun(self:df_keybindscroll)

---@class df_keybinddata : table<any, string>

---@class df_keybindframe : frame, df_optionsmixin
---@field options table
---@field data table
---@field keybindData table
---@field Header df_headerframe
---@field actionId number? the actionId is the spell Id or an actionId or a macro text
---@field button button? the button which got clicked to start editing a keybind
---@field bIsListening boolean if the frame is wayting the user to press a keybind (listening key inputs)
---@field bIsKeybindFrame boolean
---@field keybindScroll df_keybindscroll
---@field keybindListener frame
---@field callback function
---@field CreateKeybindScroll fun(self:df_keybindframe)
---@field CreateKeybindListener fun(self:df_keybindframe)
---@field GetListeningActionId fun(self:df_keybindframe) : number
---@field GetListeningState fun(self:df_keybindframe) : boolean, number, button
---@field GetKeybindData fun(self:df_keybindframe) : df_keybinddata
---@field GetKeybindListener fun(self:df_keybindframe) : frame
---@field GetKeybindScroll fun(self:df_keybindframe) : df_keybindscroll
---@field GetKeybindCallback fun(self:df_keybindframe):function
---@field IsListening fun(self:df_keybindframe) : boolean
---@field OnKeybindChanged fun(self:df_keybindframe, actionId:number, keybind:string?)
---@field SaveKeybind fun(self:df_keybindframe, key:string)
---@field SetListeningState fun(self:df_keybindframe, value:boolean, actionId:number?, button:button?)
---@field SetKeybindData fun(self:df_keybindframe, keybindData:table)
---@field SetKeybindCallback fun(self:df_keybindframe, callback:function)
---@field SwitchSpec fun(self:button, button:string, newSpecId:number)
---@field CreateKeybindScrollLine fun(self:df_keybindframe, index:number)
---@field ClearKeybind fun(self:df_keybindframe, actionId:number)
---@field

---@class keybind_scroll_data : table
---@field key1 spellname
---@field key2 textureid
---@field key3 any
---@field key4 string keybind
---@field key5 boolean is available
---@field key6 number sort value

detailsFramework:NewColor("BLIZZ_OPTIONS_COLOR", 1, 0.8196, 0, 1)

local DARK_BUTTON_TEMPLATE = detailsFramework:InstallTemplate("button", "DARK_BUTTON_TEMPLATE", {backdropcolor = {.1, .1, .1, .7}}, "OPTIONS_BUTTON_TEMPLATE")

local default_options = {
    width = 550,
    height = 500,
	scroll_width = 550 - 10,
	scroll_height = 500 - 20,
	amount_lines = 18,
	line_height = 26,
	show_spells = true,
	show_unitcontrols = true,
	can_modify_keybind_data = true, --if false, won't change the data table passed on the constructor or the one returned by GetKeybindData
}

local headerTable = {
	{text = "", width = 34}, --spell icon
	{text = "Ability Name", width = 200},
	{text = "Keybind", width = 260},
	{text = "Clear", width = 40},
}
local headerOptions = {
	padding = 2,
}

---@type {name: string, keybind: string, icon: string, localizedName: string}[]
local unitControlKeybinds = {
	{name = "target", localizedName = TARGET, keybind = "type1", icon = [[Interface\MINIMAP\TRACKING\Target]]}, --default: left mouse button
	{name = "menu", localizedName = "menu", keybind =  "type2", icon = [[Interface\BUTTONS\UI-GuildButton-PublicNote-Up]]}, --default: right mouse button
	{name = "focus", localizedName = FOCUS, keybind =  "type3", icon = [[Interface\MINIMAP\TRACKING\Focus]]} --default: middle mouse button
}

local defaultSpecKeybindList = {
    ["EVOKER"] = {
        [1467] = {
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
        },
        [1468] = {
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
        },
        [1473] = { --aug
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
        },
    },

	["DEMONHUNTER"] = {
		[577] = {--> havoc demon hunter
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
		},
		[581] = {--> vengeance demon hunter
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
		},
	},

	["DEATHKNIGHT"] = {
		[250] = { --> blood dk
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
		},
		[251] = { --> frost dk
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
		},
		[252] = { --> unholy dk
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
		},
	},

	["WARRIOR"] = {
		[71] = { --> warrior arms
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
		},
		[72] = { --> warrior fury
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
		},
		[73] = { --> warrior protect
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
		},
	},

	["MAGE"] = {
		[62] = { --> mage arcane
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
		},
		[63] = { --> mage fire
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
		},
		[64] = { --> mage frost
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
		},
	},

	["ROGUE"] = {
		[259] = { --> rogue assassination
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
		},
		[260] = { --> rogue combat
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
		},
		[261] = { --> rogue sub
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
		},
	},

	["DRUID"] = {
		[102] = { -->  druid balance
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_dispel", actiontext = ""},
		},
		[103] = { -->  druid feral
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
		},
		[104] = { -->  druid guardian
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
		},
		[105] = { -->  druid resto
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_dispel", actiontext = ""},
		},
	},

	["HUNTER"] = {
		[253] = { -->  hunter bm
			{key = "type1", action = "_target", actiontext = ""},
		},
		[254] = { --> hunter marks
			{key = "type1", action = "_target", actiontext = ""},
		},
		[255] = { --> hunter survivor
			{key = "type1", action = "_target", actiontext = ""},
		},
	},

	["SHAMAN"] = {
		[262] = { --> shaman elemental
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
		},
		[263] = { --> shamel enhancement
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
		},
		[264] = { --> shaman resto
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
		},
	},

	["PRIEST"] = {
		[256] = { --> priest disc
			{key = "type1", action = "_target", actiontext = ""},
		},
		[257] = { --> priest holy
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_dispel", actiontext = ""},
		},
		[258] = { --> priest shadow
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
		},
	},

	["WARLOCK"] = {
		[265] = { --> warlock aff
			{key = "type1", action = "_target", actiontext = ""},
		},
		[266] = { --> warlock demo
			{key = "type1", action = "_target", actiontext = ""},
		},
		[267] = { --> warlock destro
			{key = "type1", action = "_target", actiontext = ""},
		},
	},

	["PALADIN"] = {
		[65] = { --> paladin holy
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_dispel", actiontext = ""},
		},
		[66] = { --> paladin protect
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
		},
		[70] = { --> paladin ret
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
		},
	},

	["MONK"] = {
		[268] = {--> monk bm
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
		},
		[269] = {--> monk ww
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_interrupt", actiontext = ""},
			{key = "type3", action = "_taunt", actiontext = ""},
		},
		[270] = {--> monk mw
			{key = "type1", action = "_target", actiontext = ""},
			{key = "type2", action = "_dispel", actiontext = ""},
		},
	},
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
local clickTypeToMouseButton = {
	["type1"] = "LeftButton",
	["type2"] = "RightButton",
	["type3"] = "MiddleButton",
	["type4"] = "Button4",
	["type5"] = "Button5",
	["type6"] = "Button6",
	["type7"] = "Button7",
	["type8"] = "Button8",
	["type9"] = "Button9",
	["type10"] = "Button10",
	["type11"] = "Button11",
	["type12"] = "Button12",
	["type13"] = "Button13",
	["type14"] = "Button14",
	["type15"] = "Button15",
	["type16"] = "Button16",
}

local clickTypeAlias = {
	["type1"] = "Left Mouse Button",
	["type2"] = "Right Mouse Button",
	["type3"] = "Middle Mouse Button",
	["type4"] = "Mouse Button 4",
	["type5"] = "Mouse Button 5",
	["type6"] = "Mouse Button 6",
	["type7"] = "Mouse Button 7",
	["type8"] = "Mouse Button 8",
	["type9"] = "Mouse Button 9",
	["type10"] = "Mouse Button 10",
	["type11"] = "Mouse Button 11",
	["type12"] = "Mouse Button 12",
	["type13"] = "Mouse Button 13",
	["type14"] = "Mouse Button 14",
	["type15"] = "Mouse Button 15",
	["type16"] = "Mouse Button 16",
}

local tauntList = {
	["DEATHKNIGHT"] = 56222, --Dark Command
	["DEMONHUNTER"] = 185245, --Torment
	["WARRIOR"] = 355, --Taunt
	["PALADIN"] = 62124, --Hand of Reckoning
	["MONK"] = 115546, --Provoke
	["DRUID"] = 6795, --Growl
}

local interruptList = {
	["DEATHKNIGHT"] = 47528, --Mind Freeze
	["DEMONHUNTER"] = 183752, --Consume Magic
	["WARRIOR"] = 6552, --Pummel
	["PALADIN"] = 96231, --Rebuke
	["MONK"] = 116705, --Spear Hand Strike
	["HUNTER"] = 147362, --Counter Shot
	["MAGE"] = 2139, --Counterspell
	["DRUID"] = 106839, --Skull Bash -
	["ROGUE"] = 1766, --Kick
	["SHAMAN"] = 57994, --Wind Shear
	["PRIEST"] = 15487, --Silence
}

local dispelList = {
	["PALADIN"] = {[65] = 4987, [66] = 213644, [70] = 213644}, --Cleanse - Cleanse Toxins - so holy tem 'cleanse' tank e dps tem o toxins
	["MONK"] = 115450, --Detox
	["DRUID"] = {[102] = 2782, [103] = 2782, [104] = 2782, [105] = 88423}, --Nature's Cure - Remove Corruption -so restoration tem o natures cure
	["SHAMAN"] = {[262] = 51886, [263] = 51886, [264] = 77130}, --elemental melee Cleanse Spirit - resto Purify Spirit
	["PRIEST"] = {[256] = 527, [257] = 527, [258] = 213634}, --Purify holy disc - Purify Disease shadow
}

local lock_textentry = {
    ["_target"] = true,
    ["_taunt"] = true,
    ["_interrupt"] = true,
    ["_dispel"] = true,
    ["_spell"] = false,
    ["_macro"] = false,
}

local roundedCornerPreset = {
	roundness = 5,
	color = {.075, .075, .075, 0.98},
	border_color = {.05, .05, .05, 0},
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
	SetListeningState = function(self, value, actionId, button)
		self.bIsListening = value
		self.actionId = actionId
		self.button = button
	end,

	---get the listening state
	---@param self df_keybindframe
	---@return boolean
	---@return number
	---@return button
	GetListeningState = function(self)
		return self.bIsListening, self.actionId, self.button
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
	---@param keyBindFrame df_keybindframe
	ClearKeybind = function(self, button, actionId, keyBindFrame)
		local keybindData = keyBindFrame:GetKeybindData()
		keybindData[actionId] = nil
		keyBindFrame:OnKeybindChanged(actionId, nil)
		local keybindScroll = keyBindFrame:GetKeybindScroll()
		keybindScroll:UpdateScroll()
	end,

	---comment
	---@param self df_keybindframe
	---@param key any
	SaveKeybind = function(self, key) --where this is called? : from OnClickSetKeybindButton and from OnKeyDown() script
		--if the player presses a control key, ignore it
		if (ignoredKeys[key]) then
			return
		end

		local keybindListener = self:GetKeybindListener()

		--exit the process if 'esc' is pressed
		if (key == "ESCAPE") then
			self:SetListeningState(false)
			keybindListener:Hide()
			self:SetScript("OnKeyDown", nil)
			return
		end

		local modifier = (IsShiftKeyDown() and "SHIFT-" or "") .. (IsControlKeyDown() and "CTRL-" or "") .. (IsAltKeyDown() and "ALT-" or "")
		local newKeybind = modifier .. key
		local bIsListening, actionId, frameButton = self:GetListeningState()

		if (self.options.can_modify_keybind_data) then
			---@type table<any, string>
			local keybindData = self:GetKeybindData() --from savedVariables
			keybindData[actionId] = newKeybind
		end

		self:OnKeybindChanged(actionId, newKeybind)

		self:SetListeningState(false)
		self:SetScript("OnKeyDown", nil)
		keybindListener:Hide()

		--dumpt({"modifier", modifier, "newKeybind", newKeybind, "actionId", actionId})

		local keybindScroll = self:GetKeybindScroll()
		keybindScroll:UpdateScroll()
	end,

	---callback for the OnClickSetKeybindButton function on the scrollframe
	---@param self button
	---@param button any
	---@param actionId number
	---@param keyBindFrame df_keybindframe
	OnClickSetKeybindButton = function(self, button, actionId, keyBindFrame)
		local bIsListening, _, frameButton = keyBindFrame:GetListeningState()

		--if the listener is already listening for a keybind while the player clicks on another OnClickSetKeybindButton button, then cancel the previous listener
		if (bIsListening and (self == frameButton)) then
			--if the frame is already listening, it could be a mouse click to set the keybind
			local clickType = mouseButtonToClickType[button]
			print("mouse click:", button, clickType)
			keyBindFrame:SaveKeybind(clickType)
			return
		end

		keyBindFrame:SetListeningState(true, actionId, self)
		keyBindFrame:SetScript("OnKeyDown", keyBindFrame.SaveKeybind)

		local keybindListener = keyBindFrame:GetKeybindListener()
		keybindListener:ClearAllPoints()
		keybindListener:SetPoint("bottom", self, "top", 0, 0)
		keybindListener:Show()
	end,

    RefreshKeybindScroll = function(self, scrollData, offset, totalLines) --~refresh
        local keyBindFrame = getMainFrame(self)

        for i = 1, totalLines do
            local index = i + offset
            local keybindScrollData = scrollData[index]

            if (keybindScrollData) then
                local line = self:GetLine(i)

				--actionId can be a actionId or an action name, e.g. "target"
				---@type string, number, number, string, boolean
				local actionName, iconTexture, actionId, keybind, bIsAvailable = unpack(keybindScrollData)

				--if the keybind isn't set, it is an empty string
                local keyBindText = keybind
                keyBindText = keyBindText:gsub("type1", "Left Mouse Button")
                keyBindText = keyBindText:gsub("type2", "Right Mouse Button")
                keyBindText = keyBindText:gsub("type3", "Middle Mouse Button")
                keyBindText = keyBindText:gsub("type4", "Mouse Button 4")
                keyBindText = keyBindText:gsub("type5", "Mouse Button 5")
                keyBindText = keyBindText:gsub("%-", " - ")

                line.setKeybindButton.text = keyBindText
                line.setKeybindButton:SetClickFunction(keyBindFrame.OnClickSetKeybindButton, actionId, keyBindFrame, "left")
                line.setKeybindButton:SetClickFunction(keyBindFrame.OnClickSetKeybindButton, actionId, keyBindFrame, "right")

                line.clearKeybindButton:SetClickFunction(keyBindFrame.ClearKeybind, actionId, keyBindFrame)

				line.spellIconTexture:SetTexture(iconTexture)
				line.spellIconTexture:SetDesaturated(not bIsAvailable)
				line.spellIconTexture:SetTexCoord(.1, .9, .1, .9)
				line.spellNameFontString:SetText(actionName)

                --action
                --line.ActionDrop:SetFixedParameter(index)
                --line.ActionDrop:Select(keybindData.action)

                --action text
                --line.ActionText.text = keybind --keybindData.actiontext
                --line.ActionText:SetEnterFunction(set_action_text, index)
                --line.ActionText.CurIndex = index

                if (lock_textentry[keybindScrollData.action]) then
                    --line.ActionText:Disable()
                else
                    --line.ActionText:Enable()
                end
            end
        end
    end,

	change_key_action = function(self, keybindIndex, value)
        local keyBindFrame = getMainFrame(self)
		local keybind = keyBindFrame.CurrentKeybindEditingSet[keybindIndex]
		keybind.action = value
		keyBindFrame.keybindScroll:UpdateScroll()
	end,

	set_action_on_espace_press = function (textentry, capsule)
        local keyBindFrame = getMainFrame(textentry)
		capsule = capsule or textentry.MyObject
		local keybind = keyBindFrame.CurrentKeybindEditingSet[capsule.CurIndex]
		textentry:SetText (keybind.actiontext)
	end,

	fill_action_dropdown = function(dropdownObject)
        local keyBindFrame = getMainFrame(dropdownObject)

		return {
			{value = "_target", label = "Target", onclick = keyBindFrame.change_key_action, desc = "Target the unit"},
			--{value = "_taunt", label = "Taunt", onclick = keyBindFrame.change_key_action, desc = "Cast the taunt spell for your class\n\n|cFFFFFFFFSpell: " .. taunt},
			--{value = "_interrupt", label = "Interrupt", onclick = keyBindFrame.change_key_action, desc = "Cast the interrupt spell for your class\n\n|cFFFFFFFFSpell: " .. interrupt},
			--{value = "_dispel", label = "Dispel", onclick = keyBindFrame.change_key_action, desc = "Cast the interrupt spell for your class\n\n|cFFFFFFFFSpell: " .. dispel},
			{value = "_spell", label = "Cast Spell", onclick = keyBindFrame.change_key_action, desc = "Type the spell name in the text box"},
			{value = "_macro", label = "Macro", onclick = keyBindFrame.change_key_action, desc = "Type your macro in the text box"},
		}
	end,

	---run when the mouse enters a scroll line
	OnEnterScrollLine = function(self)
		local highlightTexture = self.highlightTexture
		if (not highlightTexture) then
			highlightTexture = self:GetParent().highlightTexture
		end
		highlightTexture:Show()
	end,

	---run when the mouse leaves a scroll line
	OnLeaveScrollLine = function(self)
		local highlightTexture = self.highlightTexture
		if (not highlightTexture) then
			highlightTexture = self:GetParent().highlightTexture
		end
		highlightTexture:Hide()
	end,

    ---@param keybindScroll frame
    ---@param index number
    CreateKeybindScrollLine = function(keybindScroll, index) --~create
		local keyBindFrame = getMainFrame(keybindScroll)
        local line = CreateFrame("frame", "$parentLine" .. index, keybindScroll)
        line:SetSize(keyBindFrame.options.width - 10, keyBindFrame.options.line_height)
        line:SetPoint("topleft", keyBindFrame, "topleft", 1, -22 - (index-1) * keyBindFrame.options.line_height)
		line:EnableMouse(true)

        --detailsFramework:ApplyStandardBackdrop(line, index % 2 == 0)
		--line:SetBackdropBorderColor(0, 0, 0, 0)

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

		line.spellIconTexture = line:CreateTexture("$parentIcon", "overlay")
		line.spellIconTexture:SetSize(keyBindFrame.options.line_height - 2, keyBindFrame.options.line_height - 2)

		line.spellNameFontString = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
		detailsFramework:SetFontColor(line.spellNameFontString, "BLIZZ_OPTIONS_COLOR")
		detailsFramework:SetFontSize(line.spellNameFontString, 12)

        line.setKeybindButton = detailsFramework:CreateButton(line, function()end, headerTable[3].width, keyBindFrame.options.line_height-2, "", nil, nil, nil, "SetNewKeybindButton", "$parentSetNewKeybindButton", 0, DARK_BUTTON_TEMPLATE_, options_text_template)
		detailsFramework:AddRoundedCornersToFrame(line.setKeybindButton, roundedCornerPreset)
		line.setKeybindButton.textcolor = "white"
		line.setKeybindButton.textsize = 10
		line.setKeybindButton:SetHook("OnEnter", keyBindFrame.OnEnterScrollLine)
		line.setKeybindButton:SetHook("OnLeave", keyBindFrame.OnLeaveScrollLine)

        --line.ActionDrop = detailsFramework:CreateDropDown(line, keyBindFrame.fill_action_dropdown, 0, 120, 20, "ActionDropdown", "$parentActionDropdown", options_dropdown_template)
        --line.ActionText = detailsFramework:CreateTextEntry(line, function()end, 660, 20, "TextBox", "$parentActionText", nil, options_dropdown_template)

        line.clearKeybindButton = detailsFramework:CreateButton(line, keyBindFrame.ClearKeybind, 16, keyBindFrame.options.line_height-2, "", nil, nil, nil, "DeleteKeybindButton", "$parentDeleteKeybindButton", 2, DARK_BUTTON_TEMPLATE_, options_text_template)
		line.clearKeybindButton:SetBackdropBorderColor(0, 0, 0, 0)
        line.clearKeybindButton:SetIcon([[Interface\Buttons\UI-StopButton]], nil, nil, nil, nil, nil, nil, 4)
        line.clearKeybindButton.tooltip = "erase this keybind"

        --editbox
		--[=[
        line.ActionText:SetJustifyH("left")
        line.ActionText:SetHook("OnEscapePressed", keyBindFrame.set_action_on_espace_press)
        line.ActionText:SetHook("OnEditFocusGained", function()
            local playerSpells = {}
            local tab, tabTex, offset, numSpells = GetSpellTabInfo(2)
            for i = 1, numSpells do
                local index = offset + i
                local spellType, actionId = GetSpellBookItemInfo(index, "player")
                if (spellType == "SPELL") then
                    local spellName = GetSpellInfo(actionId)
                    tinsert(playerSpells, spellName)
                end
            end
            line.ActionText.WordList = playerSpells
        end)

        line.ActionText:SetAsAutoComplete("WordList")
		--]=]
        line:AddFrameToHeaderAlignment(line.spellIconTexture)
        line:AddFrameToHeaderAlignment(line.spellNameFontString)
        line:AddFrameToHeaderAlignment(line.setKeybindButton)
        --line:AddFrameToHeaderAlignment(line.ActionDrop)
        --line:AddFrameToHeaderAlignment(line.ActionText)
        line:AddFrameToHeaderAlignment(line.clearKeybindButton)

        line:AlignWithHeader(keyBindFrame.Header, "left")

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

		function keybindScroll.UpdateScroll() --~update
			--keybind data from saved variables
			local data = self:GetKeybindData()

			---@type keybind_scroll_data[]
			local scrollData = {}

			if (self.options.show_spells) then
				--the a list of all spells
				local allPlayerSpells = detailsFramework:GetAvailableSpells()
				--bIsAvailable is a boolean that tells if the spell is from the spec the player is currently using (spells grayed out on the spellbook would be false here)
				for spellId, bIsAvailable in pairs(allPlayerSpells) do
					local spellName, _, spellIcon = GetSpellInfo(spellId)
					if (spellName) then
						local keybind = data[spellId] or ""
						local sortScore = (bIsAvailable and 0 or 200) + string.byte(spellName) -- + (keybind ~= "" and 100 or 0)
						local actionId = spellId
						scrollData[#scrollData+1] = {spellName, spellIcon, actionId, keybind, bIsAvailable, sortScore}
					end
				end

				table.sort(scrollData, function(a, b) return a[6] < b[6] end)
			end

			if (self.options.show_unitcontrols) then
				for i, actionKeyInfo in ipairs(unitControlKeybinds) do
					local actionName = actionKeyInfo.localizedName
					local defaultKeybind = actionKeyInfo.keybind
					local keybind = data[actionName] or defaultKeybind
					local icon = actionKeyInfo.icon
					local actionId = actionKeyInfo.name
					table.insert(scrollData, 1, {actionName, icon, actionId, keybind, defaultKeybind, 0})
				end
			end

			keybindScroll:SetData(scrollData)
			keybindScroll:Refresh()
		end
    end,

	---return the keybind data
	---@param self df_keybindframe
	---@return df_keybinddata
	GetKeybindData = function(self)
		return self.data
	end,

    ---set the keybind data from a profile
	---data consists in a table where the actionId (any) is the key and the value is the keybind (string)
    ---@param self df_keybindframe
	---@param newData df_keybinddata
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

	OnKeybindChanged = function(self, actionId, keybind)
		local callbackFunc = self:GetKeybindCallback()
		if (callbackFunc) then
			detailsFramework:Dispatch(callbackFunc, actionId, keybind)
		end
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

    keyBindFrame:SetSize(keyBindFrame.options.width, keyBindFrame.options.height)

	keyBindFrame:SetScript("OnHide", function()
		if (keyBindFrame:IsListening()) then
			keyBindFrame:SetListeningState(false)
			local keybindListener = keyBindFrame:GetKeybindListener()
			keybindListener:SetScript("OnKeyDown", nil)
		end
	end)

	keyBindFrame:CreateKeybindScroll()
	keyBindFrame:CreateKeybindListener()

	keyBindFrame:SetKeybindData(keybindData or {})

	if (setKeybindCallback) then
		keyBindFrame:SetKeybindCallback(setKeybindCallback)
	end

    return keyBindFrame
end
