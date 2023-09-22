---@type detailsframework
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
local CreateFrame = CreateFrame

---@class df_keybindframe : frame, df_optionsmixin
---@field options table
---@field bIsKeybindFrame boolean
---@field CreateSpecButtons fun(self:df_keybindframe)
---@field SwitchSpec fun(self:button, button:string, newSpecId:number)

local mainStartX, mainStartY, mainHeightSize = 10, -100, 600

local default_options = {
    width = 800,
    height = 600,
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
local mouseKeys = {
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
local keysToMouse = {
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

local lock_textentry = {
    ["_target"] = true,
    ["_taunt"] = true,
    ["_interrupt"] = true,
    ["_dispel"] = true,
    ["_spell"] = false,
    ["_macro"] = false,
}

--> helpers
local getMainFrame = function(UIObject)
    local parentFrame = UIObject:GetParent()
    for i = 1, 5 do
        if (parentFrame.bIsKeybindFrame) then
            return parentFrame
        end
        parentFrame = parentFrame:GetParent()
    end
    return nil
end

detailsFramework.KeybindMixin = {
	IsListening = false,
	EditingSpec = 0,
	CurrentKeybindEditingSet = {},
    AllSpecButtons = {},

    SwitchSpec = function(self, button, newSpecId) --switch_spec
        self.EditingSpec = newSpecId
        self.CurrentKeybindEditingSet = EnemyGridDBChr.KeyBinds[newSpecId] --!need to get from the addon database
        
        for _, button in ipairs (self.AllSpecButtons) do
            button.selectedTexture:Hide()
        end
        self.MyObject.selectedTexture:Show()
        
        --quick hide and show as a feedback to the player that the spec was changed
        C_Timer.After (.04, function() EnemyGridOptionsPanelFrameKeybindScroill:Hide() end) --!need to defined the scroll frame
        C_Timer.After (.06, function() EnemyGridOptionsPanelFrameKeybindScroill:Show() end) --!need to defined the scroll frame
        
        --atualiza a scroll
        EnemyGridOptionsPanelFrameKeybindScroill:UpdateScroll() --!need to defined the scroll frame
    end,

    CreateSpecButtons = function(self)
        local specsTitle = detailsFramework:CreateLabel(self, "Config keys for spec:", 12, "silver")
        specsTitle:SetPoint("topleft", self, "topleft", 10, mainStartY)

        local allSpecButtons = self.AllSpecButtons

        local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
        local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
        local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
        local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
        local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

        for i = 1, 4 do
            local newSpecButton = detailsFramework:CreateButton(self, self.SwitchSpec, 160, 20, "Spec1 Placeholder Text", 1, nil, nil, "specButton" .. i, nil, 0, options_button_template, options_text_template)
            table.insert(allSpecButtons, newSpecButton)
            self["SpecButton" .. i] = newSpecButton

            newSpecButton:SetPoint("topleft", specsTitle, "bottomleft", 0, -10 + (20*(i-1)))
            spec2:SetPoint ("topleft", specsTitle, "bottomleft", 0, -30)
            spec3:SetPoint ("topleft", specsTitle, "bottomleft", 0, -50)
            if (class == "DRUID") then
                spec4:SetPoint ("topleft", specsTitle, "bottomleft", 0, -70)
            end            
        end

        local classLocName, class = UnitClass("player")
        local i = 1
        for specId in pairs(defaultSpecKeybindList[class]) do
            local button = self["SpecButton" .. i]
            local _, specName, _, specIcon = DF.GetSpecializationInfoByID(specId) --classic return nil

            if (specName) then
                button.text = specName
                button:SetClickFunction(self.SwitchSpec, specId)
                button:SetIcon(specIcon)
                button.specID = specId
                
                local selectedTexture = button:CreateTexture(nil, "background")
                selectedTexture:SetAllPoints()
                selectedTexture:SetColorTexture(1, 1, 1, 0.5)
                if (specId ~= self.EditingSpec) then
                    selectedTexture:Hide()
                end

                button.selectedTexture = selectedTexture
                i = i + 1
            else
                button:Hide()
            end
        end        

    end,

    CreateKeybindListener = function(self)
        local enter_the_key = CreateFrame ("frame", nil, self, "BackdropTemplate")
        enter_the_key:SetFrameStrata("tooltip")
        enter_the_key:SetSize(200, 60)
        detailsFramework:ApplyStandardBackdrop(enter_the_key)
        enter_the_key.text = detailsFramework:CreateLabel(enter_the_key, "- Press a keyboard key to bind.\n- Click to bind a mouse button.\n- Press escape to cancel.", 11, "orange")
        enter_the_key.text:SetPoint("center", enter_the_key, "center", 0, 0)
        enter_the_key:Hide()        



    end,

	set_keybind_key = function(self, button, keybindIndex)
		if (keyBindListener.IsListening) then
			key = mouseKeys [button] or button
			return registerKeybind (keyBindListener, key)
		end
		keyBindListener.IsListening = true
		keyBindListener.keybindIndex = keybindIndex
		keyBindListener:SetScript ("OnKeyDown", registerKeybind)
		
		enter_the_key:Show()
		enter_the_key:SetPoint ("bottom", self, "top")
	end,

    RefreshKeybindScroll = function(self, data, offset, totalLines)
        local keyBindFrame = getMainFrame(self)
        local keybinds = keyBindFrame.CurrentKeybindEditingSet

        for i = 1, totalLines do
            local index = i + offset
            local keybindData = data[index]

            if (keybindData) then
                local line = self:GetLine(i)
                --index
                line.Index.text = index

                --keybind
                local keyBindText = keysToMouse[keybindData.key] or keybindData.key
                
                keyBindText = keyBindText:gsub("type1", "LeftButton")
                keyBindText = keyBindText:gsub("type2", "RightButton")
                keyBindText = keyBindText:gsub("type3", "MiddleButton")
                
                line.KeyBind.text = keyBindText
                line.KeyBind:SetClickFunction(keyBindFrame.set_keybind_key, index, nil, "left")
                line.KeyBind:SetClickFunction(keyBindFrame.set_keybind_key, index, nil, "right")

                --action
                line.ActionDrop:SetFixedParameter(index)
                line.ActionDrop:Select(keybindData.action)

                --action text
                line.ActionText.text = keybindData.actiontext
                line.ActionText:SetEnterFunction(set_action_text, index)
                line.ActionText.CurIndex = index
                
                if (lock_textentry[keybindData.action]) then
                    line.ActionText:Disable()
                else
                    line.ActionText:Enable()
                end

                --delete
                line.Delete:SetClickFunction(keyBindFrame.delete_keybind, index)
            end
        end
    end,

	delete_keybind = function(self, button, keybindIndex)
        local keyBindFrame = getMainFrame(self)
		tremove(keyBindFrame.CurrentKeybindEditingSet, keybindIndex)
		keyBindFrame.keybindScroll:UpdateScroll()
		--EnemyGrid.UpdateKeyBinds()
	end,

	change_key_action = function(self, keybindIndex, value)
        local keyBindFrame = getMainFrame(self)
		local keybind = keyBindFrame.CurrentKeybindEditingSet[keybindIndex]
		keybind.action = value
		keyBindFrame.keybindScroll:UpdateScroll()
		--EnemyGrid.UpdateKeyBinds()
	end,

	set_action_on_espace_press = function (textentry, capsule)
        local keyBindFrame = getMainFrame(textentry)
		capsule = capsule or textentry.MyObject
		local keybind = keyBindFrame.CurrentKeybindEditingSet[capsule.CurIndex]
		textentry:SetText (keybind.actiontext)
		--EnemyGrid.UpdateKeyBinds()
	end,    

	fill_action_dropdown = function(dropdownObject)
        local keyBindFrame = getMainFrame(dropdownObject)
		local locClass, class = UnitClass("player")
		
		local taunt = tauntList[class] and GetSpellInfo(tauntList[class]) or ""
		local interrupt = interruptList[class] and GetSpellInfo(interruptList [class]) or ""
		local dispel = dispelList[class]
		
		if (type (dispel) == "table") then
			local dispelString = "\n"
			for specId, spellid in pairs(dispel) do
				local _, specName = GetSpecializationInfoByID(specId) --!classic versions incompatible
				local spellName = GetSpellInfo(spellid)
				dispelString = dispelString .. "|cFFE5E5E5" .. specName .. "|r: |cFFFFFFFF" .. spellName .. "\n"
			end
			dispel = dispelString
		else
			dispel = GetSpellInfo(dispel) or ""
		end
		
		return {
			{value = "_target", label = "Target", onclick = keyBindFrame.change_key_action, desc = "Target the unit"},
			{value = "_taunt", label = "Taunt", onclick = keyBindFrame.change_key_action, desc = "Cast the taunt spell for your class\n\n|cFFFFFFFFSpell: " .. taunt},
			{value = "_interrupt", label = "Interrupt", onclick = keyBindFrame.change_key_action, desc = "Cast the interrupt spell for your class\n\n|cFFFFFFFFSpell: " .. interrupt},
			{value = "_dispel", label = "Dispel", onclick = keyBindFrame.change_key_action, desc = "Cast the interrupt spell for your class\n\n|cFFFFFFFFSpell: " .. dispel},
			{value = "_spell", label = "Cast Spell", onclick = keyBindFrame.change_key_action, desc = "Type the spell name in the text box"},
			{value = "_macro", label = "Macro", onclick = keyBindFrame.change_key_action, desc = "Type your macro in the text box"},
		}
	end,

    ---@param keyBindFrame df_keybindframe
    ---@param index number
    CreateKeybindScrollLine = function(keyBindFrame, index)
        local line = CreateFrame("frame", "$parentLine" .. index, keybindScroll)
        line:SetSize(1009, 20)
        line:SetPoint("topleft", keyBindFrame, "topleft", 0, -(index-1)*29)
        detailsFramework:ApplyStandardBackdrop(line, index % 2 == 0)
        detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)
        
        local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
        local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
        local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
        local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
        local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

        line.Index = detailsFramework:CreateLabel(line, "place holder")
        line.KeyBind = detailsFramework:CreateButton(line, function()end, 100, 20, "", nil, nil, nil, "SetNewKeybindButton", "$parentSetNewKeybindButton", 0, options_button_template, options_text_template)
        line.ActionDrop = detailsFramework:CreateDropDown(line, keyBindFrame.fill_action_dropdown, 0, 120, 20, "ActionDropdown", "$parentActionDropdown", options_dropdown_template)
        line.ActionText = detailsFramework:CreateTextEntry(line, function()end, 660, 20, "TextBox", "$parentActionText", nil, options_dropdown_template)
        line.Delete = detailsFramework:CreateButton(line, keyBindFrame.delete_keybind, 16, 20, "", nil, nil, nil, "DeleteKeybindButton", "$parentDeleteKeybindButton", 2, options_button_template, options_text_template)
        line.Delete:SetIcon([[Interface\Buttons\UI-StopButton]], nil, nil, nil, nil, nil, nil, 4)
        line.Delete.tooltip = "erase this keybind"        
       
        --editbox
        line.ActionText:SetJustifyH("left")
        line.ActionText:SetHook("OnEscapePressed", keyBindFrame.set_action_on_espace_press)
        line.ActionText:SetHook("OnEditFocusGained", function()
            local playerSpells = {}
            local tab, tabTex, offset, numSpells = GetSpellTabInfo(2)
            for i = 1, numSpells do
                local index = offset + i
                local spellType, spellId = GetSpellBookItemInfo(index, "player")
                if (spellType == "SPELL") then
                    local spellName = GetSpellInfo(spellId)
                    tinsert(playerSpells, spellName)
                end
            end
            line.ActionText.WordList = playerSpells
        end)
        
        line.ActionText:SetAsAutoComplete("WordList")

        line:AddFrameToHeaderAlignment(line.Index)
        line:AddFrameToHeaderAlignment(line.KeyBind)
        line:AddFrameToHeaderAlignment(line.ActionDrop)
        line:AddFrameToHeaderAlignment(line.ActionText)
        line:AddFrameToHeaderAlignment(line.Delete)
        
        line:AlignWithHeader(keyBindFrame.Header, "left")
    end,

    ---comment
    ---@param self df_keybindframe
    CreateKeybindScroll = function(self)
        local scroll_width = self.options.width - 10
        local scroll_height = self.options.height - 40
        local scroll_lines = self.options.amount_lines
        local scroll_line_height = self.options.line_height

		--header
		local headerTable = {
			{text = "", width = 20}, --index
			{text = "", width = 20}, --spell icon
			{text = "Ability Name", width = 120},
			{text = "Keybind", width = 60},
			{text = "Action Type", width = 60},
			{text = "Action Text", width = 45},
			{text = "Clear Keybind", width = 80},
		}
		local headerOptions = {
			padding = 2,
		}

        ---@type df_headerframe
		self.Header = DetailsFramework:CreateHeader(self, headerTable, headerOptions)
		self.Header:SetPoint("topleft", self, "topleft", 5, -25)

		local keybindScroll = detailsFramework:CreateScrollBox(self, "$parentScrollBox", detailsFramework.KeybindMixin.RefreshKeybindScroll, {}, scroll_width, scroll_height, scroll_lines, scroll_line_height)
		detailsFramework:ReskinSlider(keybindScroll)
		keybindScroll:SetPoint("topleft", self.Header, "bottomleft", 0, -2)
        self.keybindScroll = keybindScroll

        for i = 1, scroll_lines do
            keybindScroll:CreateLine(self.CreateKeybindScrollLine)
        end
    end,
}



---@param parent frame
---@param name string?
---@param options table?
function detailsFramework:CreateKeybindFrame(parent, name, options)
    ---@type df_keybindframe
    local keyBindFrame = CreateFrame("frame", name, parent, "BackdropTemplate")
    keyBindFrame.bIsKeybindFrame = true

    detailsFramework:Mixin(keyBindFrame, detailsFramework.OptionsFunctions)

    options = options or {}
    keyBindFrame:BuildOptionsTable(default_options, options)

    keyBindFrame:SetSize(keyBindFrame.options.width, keyBindFrame.options.height)

    keyBindFrame:CreateSpecButtons()

	keyBindFrame:SetScript("OnHide", function()
		if (keyBindFrame.IsListening) then
			keyBindFrame.IsListening = false
			keyBindFrame:SetScript("OnKeyDown", nil)
		end
	end)

    return keyBindFrame
end
