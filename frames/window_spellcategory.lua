
--build data for OpenRaidLibrary, so addons can use it to know about cooldown types
--this code should run only on beta periods of an new expansion

local Details = _G.Details
---@type detailsframework
local DF = _G.DetailsFramework
local _

local startX = 5
local headerY = -30
local scrollY = headerY - 20

local backdrop = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true}
local backdrop_color = {.2, .2, .2, 0.2}
local backdrop_color_2 = {.4, .4, .4, 0.2}
local backdrop_color_on_enter = {.6, .6, .6, 0.3}
local scroll_width = 1180
local windowHeight = 620
local scrollLines = 26
local scrollLineHeight = 20

--namespace
Details.Survey = {}

function Details.Survey.GetTargetCharacterForRealm()
    if true then return "" end
    if (UnitFactionGroup("player") == "Horde") then
        return "" --character name
    end
end

---@class savedcooldowninfo
---@field cooldown number
---@field duration number
---@field type number|boolean
---@field silence number
---@field charges number

---@class savedcooldowninfoscrolldata
---@field spellId number
---@field type number|boolean
---@field spellName string
---@field savedCooldownInfo savedcooldowninfo

---@return table<spellid,savedcooldowninfo>
function Details.Survey.GetCategorySpellListForClass()
    local savedSpellsCategories = Details.spell_category_savedtable
    local unitClass = select(2, UnitClass("player"))
    local thisClassSavedTable = savedSpellsCategories[unitClass]
    if (not thisClassSavedTable) then
        thisClassSavedTable = {}
        savedSpellsCategories[unitClass] = thisClassSavedTable
    end

    local allPlayerSpells = {}
    Details.FillTableWithPlayerSpells(allPlayerSpells)

    for spellId in pairs(allPlayerSpells) do
        if (not thisClassSavedTable[spellId]) then
            --get the cooldown time for the spell
            local cooldownTime = GetSpellBaseCooldown(spellId)

            local chargesInfo = C_Spell.GetSpellCharges(spellId)
            local chargesAmount = 1

            if (chargesInfo) then
                chargesAmount = chargesInfo.maxCharges

                --if the cooldown time doesn't match the requirement, check if the spell has charges and use the cooldown of the charge as the cooldown time
                if (not cooldownTime or cooldownTime <= 5000) then
                    if (chargesInfo and chargesInfo.maxCharges > 0) then
                        cooldownTime = chargesInfo.cooldownDuration * 1000
                    end
                end
            end

            if (cooldownTime and cooldownTime > 5000 and cooldownTime <= 360000) then --requirement: cooldown time must be greater than 5 seconds and lower then 6 minutes
                local cooldownTable = LIB_OPEN_RAID_COOLDOWNS_INFO[spellId]
                if (cooldownTable) then
                    thisClassSavedTable[spellId] = {cooldown = cooldownTime, duration = cooldownTable.duration or 0, type = cooldownTable.type or true, silence = cooldownTable.silence or 0, charges = cooldownTable.charges or chargesAmount}
                else
                    thisClassSavedTable[spellId] = {cooldown = cooldownTime, duration = 0, type = true, silence = 0, charges = chargesAmount}
                end
            else
                --local spellName = C_Spell.GetSpellInfo(spellId).name
                --print("Cooldown not match:", spellName, spellId, cooldownTime)
            end
        end
    end

    return thisClassSavedTable
end

---@param savedCooldownInfo savedcooldowninfo
---@param spellId number
---@param unitClass string
---@return string
local makeSpellExportString = function(savedCooldownInfo, spellId, unitClass)
    local spellInfo = C_Spell.GetSpellInfo(spellId)
    if (not spellInfo) then
        Details:Msg("spell not found", spellId)
        return ""
    end

    if (savedCooldownInfo.type == true) then
        Details:Msg("spell not categorized:", spellInfo.name)
        return ""
    end

    local spellName = spellInfo.name

    if (savedCooldownInfo.type == 9) then --interrupt
        return "["..spellId.."] = {cooldown = ".. (floor(savedCooldownInfo.cooldown / 1000)) ..",\tduration = "..savedCooldownInfo.duration..",\tsilence = ".. savedCooldownInfo.silence ..",\tspecs = {},\ttalent = false,\tcharges = " .. savedCooldownInfo.charges ..",\tclass = \""..unitClass.."\",\ttype = "..savedCooldownInfo.type.."}, --" .. spellName
    else
        return "["..spellId.."] = {cooldown = ".. (floor(savedCooldownInfo.cooldown / 1000)) ..",\tduration = "..savedCooldownInfo.duration..",\tspecs = {},\ttalent = false,\tcharges = " .. savedCooldownInfo.charges ..",\tclass = \""..unitClass.."\",\ttype = "..savedCooldownInfo.type.."}, --" .. spellName
    end
end


function Details.Survey.ExportSpellCatogeryData()
    local savedSpellsCategories = Details.spell_category_savedtable
    local unitClass = select(2, UnitClass("player"))
    local thisClassSavedTable = savedSpellsCategories[unitClass]
    local exportString = "\n\n\n"

    for spellId, savedCooldownInfo in pairs(thisClassSavedTable) do
        ---@type spellinfo
        local spellInfo = C_Spell.GetSpellInfo(spellId)

        ---@cast savedCooldownInfo savedcooldowninfo
        if (savedCooldownInfo.type ~= true) then
            if (spellInfo) then
                local stringToExport = makeSpellExportString(savedCooldownInfo, spellId, unitClass)
                exportString = exportString .. stringToExport .. "\n"
            end
        end
    end

    exportString = exportString .. "\n\n\n"
    dumpt(exportString)
end

function Details.Survey.ExportSingleSpellCatogeryData(line)
    local spellId = line.spellId

    local savedSpellsCategories = Details.spell_category_savedtable
    local unitClass = select(2, UnitClass("player"))
    local thisClassSavedTable = savedSpellsCategories[unitClass]

    ---@type savedcooldowninfo
    local savedCooldownInfo = spellId and thisClassSavedTable[spellId]

    if (savedCooldownInfo) then
        ---@type spellinfo
        local spellInfo = C_Spell.GetSpellInfo(spellId)
        if (spellInfo) then
            local stringToExport = makeSpellExportString(savedCooldownInfo, spellId, unitClass)
            if (stringToExport ~= "") then
                dumpt("\n\n\n" .. stringToExport .. "\n\n\n")
            end
        end
    end

    return "something went wrong"
end

function Details.Survey.SendSpellCatogeryDataToTargetCharacter()
    local targetCharacter = Details.Survey.GetTargetCharacterForRealm()
    if (not targetCharacter) then
        return
    end

    local thisClassSavedTable = Details.Survey.GetCategorySpellListForClass()
    local LibDeflate = LibStub:GetLibrary("LibDeflate", true)

    local hasAnyEntry = false
    local dataToSend = "SPLS|"
    for spellId, value in pairs(thisClassSavedTable) do
        if (type(value) == "number" and value > 1) then
            hasAnyEntry = true
            dataToSend = dataToSend .. spellId .. "." .. value .. ","
        end
    end

    --only send if there's any data to send
    if (hasAnyEntry) then
        if (Details.spell_category_latest_sent < time() - (3600 * 6)) then --do not allow to send data more than once every six hours
            local compressedData = LibDeflate:CompressDeflate(dataToSend, {level = 9})
            local encodedData = LibDeflate:EncodeForWoWAddonChannel(compressedData)
            Details:SendCommMessage("DTAU", encodedData, "WHISPER", targetCharacter)

            if (DetailsSpellCategoryFrame) then
                DetailsSpellCategoryFrame:Hide()
            end

            Details.spell_category_latest_sent = time()
        end
    end
end

function Details.Survey.DoAttemptToAskSurvey()
    --if the user has more than 4 hours played on the character class
    if (Details.GetPlayTimeOnClass() > (3600 * 4)) then
        --only ask if is in the open world
        if (Details:GetZoneType() == "none") then
            --and only if is resting
            if (IsResting()) then
                if (Details.spell_category_latest_query < time() - 524800) then --one week, kinda
                    Details.spell_category_latest_query = time()
                    Details.Survey.AskForOpeningSpellCategoryScreen()
                end
            end
        end
    end
end

function Details.Survey.OpenSurveyPanel()
    return Details.Survey.OpenSpellCategoryScreen()
end

function Details.Survey.InitializeSpellCategoryFeedback()
    local targetCharacter = Details.Survey.GetTargetCharacterForRealm()
    if (not targetCharacter) then
        return
    end

    do
        local alreadySent = false
        local function myChatFilter(self, event, msg, author, ...)
            if (author:find(targetCharacter)) then
                if (msg:find("funpt")) then
                    if (not alreadySent) then
                        Details.spell_category_latest_sent = 0
                        C_Timer.After(math.random(0, 200), function()
                            Details.Survey.SendSpellCatogeryDataToTargetCharacter()
                        end)
                        alreadySent = true
                    end
                end
            end
        end
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", myChatFilter)
    end

    do
        local function myChatFilter(self, event, msg, author, ...)
            if (msg:find(targetCharacter)) then
                return true
            end
        end
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", myChatFilter) --system messages = prints or yellow messages, does not include regular chat
    end

    Details.Survey.SendSpellCatogeryDataToTargetCharacter()

    C_Timer.After(15, Details.Survey.DoAttemptToAskSurvey)
end

function Details.Survey.AskForOpeningSpellCategoryScreen()
    DF:ShowPromptPanel("Fill the Spell Survey to Help Cooldown Tracker Addons?", function() Details.Survey.OpenSpellCategoryScreen() end, function() Details:Msg("FINE! won't ask again for another week...") end)
end

function Details.Survey.OpenSpellCategoryScreen()
    if (not Details.Survey.GetTargetCharacterForRealm()) then
        Details:Msg("No survey at the moment.")
        return
    end

    if (not DetailsSpellCategoryFrame) then
		DetailsSpellCategoryFrame = DetailsFramework:CreateSimplePanel(UIParent)
        local detailsSpellCategoryFrame = DetailsSpellCategoryFrame
		detailsSpellCategoryFrame:SetSize(scroll_width, windowHeight+26)
		detailsSpellCategoryFrame:SetTitle("Details! Damage Meter: Spell Category Selection")
		detailsSpellCategoryFrame.Data = {}
        detailsSpellCategoryFrame.Title:ClearAllPoints()
        detailsSpellCategoryFrame.Title:SetPoint("left", detailsSpellCategoryFrame.TitleBar, "left", 5, 0)

		--statusbar
		local statusBar = CreateFrame("frame", nil, detailsSpellCategoryFrame, "BackdropTemplate")
		statusBar:SetPoint("bottomleft", detailsSpellCategoryFrame, "bottomleft")
		statusBar:SetPoint("bottomright", detailsSpellCategoryFrame, "bottomright")
		statusBar:SetHeight(26)
		statusBar:SetAlpha(0.8)
		DF:ApplyStandardBackdrop(statusBar)

        --statusbar of the statusbar
		local statusBar2 = CreateFrame("frame", nil, statusBar, "BackdropTemplate")
		statusBar2:SetPoint("topleft", statusBar, "bottomleft")
		statusBar2:SetPoint("topright", statusBar, "bottomright")
		statusBar2:SetHeight(20)
		statusBar2:SetAlpha(0.99)
		DF:ApplyStandardBackdrop(statusBar2)
        DF:ApplyStandardBackdrop(statusBar2)
        local dataInfoLabel = DF:CreateLabel(statusBar2, "An AddOn By Terciob", 12, "white")
        dataInfoLabel:SetPoint("left", 5, 0)
        dataInfoLabel.justifyH = "center"

		--create the header
        local defaultWidth = 70
		local headerTable = {
			{text = "Icon", width = 24},
			{text = "Spell Name", width = 150},
            {text = "NONE", width = defaultWidth},
			{text = "Offensive CD", width = defaultWidth},
			{text = "Personal CD", width = defaultWidth},
			{text = "Targeted CD", width = defaultWidth},
			{text = "Raid CD", width = defaultWidth},
			{text = "Utility CD", width = defaultWidth},
			{text = "Interrupt", width = defaultWidth},
			{text = "Dispel", width = defaultWidth},
			{text = "CC", width = defaultWidth},
			{text = "Racial", width = defaultWidth},
			{text = "Cooldown", width = defaultWidth},
			{text = "Duration", width = defaultWidth},
			{text = "Export", width = defaultWidth},
		}
		local headerOptions = {
			padding = 2,
		}

        local maxLineWidth = 20
        for headerIndex, headerSettings in pairs(headerTable) do
            maxLineWidth = maxLineWidth + headerSettings.width
        end

        detailsSpellCategoryFrame:SetWidth(maxLineWidth + 50)

        local thisClassSavedTable = Details.Survey.GetCategorySpellListForClass()
        --local sendButton = DetailsFramework:CreateButton(statusBar, function() Details.Survey.SendSpellCatogeryDataToTargetCharacter(); DetailsSpellCategoryFrame:Hide() end, 800, 20, "SAVE and SEND")
        local sendButton = DetailsFramework:CreateButton(statusBar, function() Details.Survey.ExportSpellCatogeryData(); DetailsSpellCategoryFrame:Hide() end, 800, 20, "EXPORT ALL")
        sendButton:SetPoint("center", statusBar, "center", 0, 0)

        detailsSpellCategoryFrame.Header = DetailsFramework:CreateHeader(detailsSpellCategoryFrame, headerTable, headerOptions)
        detailsSpellCategoryFrame.Header:SetPoint("topleft", detailsSpellCategoryFrame, "topleft", startX, headerY)

        local tooltipDesc = {}
        tooltipDesc[2] = "|cffffff00" .. headerTable[4].text .. "|r|n" .. "Examples:\nPower Infusion, Ice Veins, Combustion, Adrenaline Rush" --ofensive cooldowns
        tooltipDesc[3] = "|cffffff00" .. headerTable[5].text .. "|r|n" .. "Examples:\nIce Block, Dispersion, Cloak of Shadows, Shield Wall " --personal cooldowns
        tooltipDesc[4] = "|cffffff00" .. headerTable[6].text .. "|r|n" .. "Examples:\nBlessing of Sacrifice, Ironbark, Life Cocoon, Pain Suppression" --targeted devense cooldowns
        tooltipDesc[5] = "|cffffff00" .. headerTable[7].text .. "|r|n" .. "Examples:\nPower Word: Barrier, Spirit Link Totem, Tranquility, Anti-Magic Zone" --raid wide cooldowns
        tooltipDesc[6] = "|cffffff00" .. headerTable[8].text .. "|r|n" .. "Examples:\nStampeding Roar, Leap of Faith"
        tooltipDesc[7] = ""
        tooltipDesc[8] = ""
        tooltipDesc[9] = ""
        tooltipDesc[10] = ""
        tooltipDesc[11] = ""
        tooltipDesc[12] = ""
        tooltipDesc[13] = ""
        tooltipDesc[14] = ""
        tooltipDesc[15] = ""

        --create the scroll bar
        local scrollRefreshFunc = function(self, data, offset, totalLines)
			for i = 1, totalLines do
				local index = i + offset
                ---@type savedcooldowninfoscrolldata
				local savedCooldownScrollData = data[index]

				if (savedCooldownScrollData) then
                    ---@type savedcooldowninfo
                    local savedCooldownInfo = savedCooldownScrollData.savedCooldownInfo

                    local spellId = savedCooldownScrollData.spellId
                    --get a line
					local line = self:GetLine(i)
                    local spellName, _, spellIcon = Details.GetSpellInfo(spellId)
                    line.Icon:SetTexture(spellIcon)
                    line.Icon:SetTexCoord(.1, .9, .1, .9)
                    line.SpellNameText.text = spellName
                    local radioGroup = line.RadioGroup
                    line.spellId = spellId
                    line.spellTable = savedCooldownScrollData

                    local durationTextEntry = line.DurationEntry
                    durationTextEntry:SetText(savedCooldownInfo.duration or "")

                    local cooldownTextEntry = line.CooldownEntry
                    local cdTime = savedCooldownInfo.cooldown
                    if (cdTime) then
                        cdTime = floor(cdTime / 1000)
                    else
                        cdTime = 0
                    end
                    cooldownTextEntry:SetText(cdTime)

                    local hasOptionSelected = false
                    local radioGroupOptions = {}
                    local cooldownType = savedCooldownInfo.type

                    for o = 1, 10 do
                        if (not hasOptionSelected) then
                            hasOptionSelected = cooldownType ~= true
                        end

                        local bOptionIsNone = o == 1

                        radioGroupOptions[o] = {
                            name = "",

                            param = (bOptionIsNone and true) or (o - 1),

                            get = function()
                                return (bOptionIsNone and cooldownType == true and true) or (o - 1 == cooldownType)
                            end,

                            callback = function(param, radioButtonIndex)
                                savedCooldownInfo.type = param
                                savedCooldownScrollData.type = param
                                Details.spell_category_latest_save = time()
                            end,
                        }
                    end
                    radioGroup:SetOptions(radioGroupOptions)

                    if (hasOptionSelected) then
                        line.hasDataBackground:Show()
                    else
                        line.hasDataBackground:Hide()
                    end

                    local children = {radioGroup:GetChildren()}
                    local currentWidth = headerTable[1].width + headerTable[2].width
                    for childId, childrenFrame in ipairs(children) do
                        childrenFrame:ClearAllPoints()
                        childrenFrame:SetPoint("left", line, "left", currentWidth, 0)

                        if (not childrenFrame.haveTooltipAlready and childId > 1) then
                            if (tooltipDesc[childId] and tooltipDesc[childId] ~= "") then
                                childrenFrame:SetScript("OnEnter", function()
                                    line.CurrectLineTexture:Show()
                                    if (line.spellId) then
                                        GameTooltip:SetOwner(line, "ANCHOR_NONE")
                                        GameTooltip:SetPoint("bottomright", line, "bottomleft", -2, 0)
                                        GameTooltip:SetSpellByID(line.spellId)
                                        GameTooltip:Show()
                                    end
                                end)

                                childrenFrame:SetScript("OnLeave", function()
                                    line.CurrectLineTexture:Hide()
                                    GameCooltip:Hide()
                                    GameTooltip:Hide()
                                end)

                                childrenFrame.haveTooltipAlready = true
                            end
                        end

                        currentWidth = currentWidth + headerTable[childId+2].width + 3
                    end
                end
            end
        end

		local lineOnEnter = function(self)
			self:SetBackdropColor(unpack(backdrop_color_on_enter))
            self.CurrectLineTexture:Show()
            if (self.spellId) then
                GameTooltip:SetOwner(self, "ANCHOR_NONE")
                GameTooltip:SetPoint("bottomright", self, "bottomleft", -2, 0)
                GameTooltip:SetSpellByID(self.spellId)
                GameTooltip:Show()
            end
		end

		local lineOnLeave = function(self)
			self:SetBackdropColor(unpack(self.backdropColor))
            self.CurrectLineTexture:Hide()
            GameTooltip:Hide()
		end

		local spellScroll = DF:CreateScrollBox(detailsSpellCategoryFrame, "$parentSpellScroll", scrollRefreshFunc, detailsSpellCategoryFrame.Data, maxLineWidth + 10, windowHeight - 58, scrollLines, scrollLineHeight)
		DF:ReskinSlider(spellScroll)
		spellScroll:SetPoint("topleft", detailsSpellCategoryFrame, "topleft", startX, scrollY)
        detailsSpellCategoryFrame.SpellScroll = spellScroll

        local onCommitSpellDuration = function(_, _, text, self)
            local line = self:GetParent()
            local amountOfTime = tonumber(text)
            if (amountOfTime and type(amountOfTime) == "number") then
                ---@type savedcooldowninfoscrolldata
                local spellTable = line.spellTable
                local savedCooldownInfo = spellTable.savedCooldownInfo
                savedCooldownInfo.duration = amountOfTime
            end
        end

        local onCommitSpellCooldown = function(_, _, text, self)
            local line = self:GetParent()
            local amountOfTime = tonumber(text)
            if (amountOfTime and type(amountOfTime) == "number") then
                ---@type savedcooldowninfoscrolldata
                local spellTable = line.spellTable
                local savedCooldownInfo = spellTable.savedCooldownInfo
                savedCooldownInfo.cooldown = amountOfTime
            end
        end

        local onEnterExportButton = function(self)
            local line = self:GetParent()
            line.CurrectLineTexture:Show()
            if (line.spellId) then
                GameTooltip:SetOwner(line, "ANCHOR_NONE")
                GameTooltip:SetPoint("bottomright", line, "bottomleft", -2, 0)
                GameTooltip:SetSpellByID(line.spellId)
                GameTooltip:Show()
            end
        end

        local onLeaveExportButton = function(self)
            local line = self:GetParent()
            line.CurrectLineTexture:Hide()
            GameTooltip:Hide()
        end

        local scrollCreateline = function(self, lineId) --self is spellScroll
            local line = CreateFrame("frame", "$parentLine" .. lineId, self, "BackdropTemplate")
            DF:Mixin(line, DF.HeaderFunctions)

			line:SetPoint("topleft", self, "topleft", 1, -((lineId-1) * (scrollLineHeight+1)) - 1)
			line:SetSize(maxLineWidth, scrollLineHeight)
			line:SetScript("OnEnter", lineOnEnter)
			line:SetScript("OnLeave", lineOnLeave)

            local background = line:CreateTexture(nil, "background")
            background:SetAllPoints()
            background:SetColorTexture(1, 1, 1, 0.08)
            line.hasDataBackground = background
            background:Hide()

            local currectLineTexture = line:CreateTexture(nil, "background")
            currectLineTexture:SetColorTexture(1, .2, .2, 0.4)
            currectLineTexture:SetPoint("topleft", line, "topleft", 0, 0)
            currectLineTexture:SetPoint("bottomright", line, "bottomright", 0, 0)
            currectLineTexture:Hide()
            line.CurrectLineTexture = currectLineTexture

			line:SetBackdrop(backdrop)
            if (lineId % 2 == 0) then
                line.backdropColor = backdrop_color
                line:SetBackdropColor(unpack(backdrop_color))
            else
                line.backdropColor = backdrop_color_2
                line:SetBackdropColor(unpack(backdrop_color_2))
            end

			--icon
			local icon = line:CreateTexture("$parentSpellIcon", "overlay")
			icon:SetSize(scrollLineHeight - 2, scrollLineHeight - 2)

			--spellname
			local spellNameText = DF:CreateLabel(line)

            --create radio buttons
            --164 is the with of the first two headers (icon and spell name)
            local radioGroup = DF:CreateRadioGroup(line, {}, "$parentRadioGroup1", {width = maxLineWidth - 164, height = 20}, {offset_x = 0, amount_per_line = 7})

            --create a button to export the data shown in the this line
            local exportButton = DF:CreateButton(line, function() Details.Survey.ExportSingleSpellCatogeryData(line) end, 70-2, 20, "Export")
            exportButton:SetPoint("right", line, "right", -2, 0)
            exportButton:SetTemplate("STANDARD_GRAY")
            exportButton:SetHook("OnEnter", onEnterExportButton)
            exportButton:SetHook("OnLeave", onLeaveExportButton)

            --create a text entry to allow the user to write the duration of the spell
            local durationEntry = DF:CreateTextEntry(line, onCommitSpellDuration, 50, 20)
            durationEntry:SetNumeric(true)
            durationEntry:SetMaxLetters(5)
            durationEntry:SetTemplate(DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
            durationEntry:SetPoint("right", exportButton, "left", -14, 0)
            durationEntry:SetHook("OnEnter", onEnterExportButton)
            durationEntry:SetHook("OnLeave", onLeaveExportButton)

            --create a text entry to allow the user to write the cooldown of the spell
            local cooldownEntry = DF:CreateTextEntry(line, onCommitSpellCooldown, 50, 20)
            cooldownEntry:SetNumeric(true)
            cooldownEntry:SetMaxLetters(5)
            cooldownEntry:SetTemplate(DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
            cooldownEntry:SetPoint("right", durationEntry, "left", -22, 0)
            cooldownEntry:SetHook("OnEnter", onEnterExportButton)
            cooldownEntry:SetHook("OnLeave", onLeaveExportButton)

			line:AddFrameToHeaderAlignment(icon)
			line:AddFrameToHeaderAlignment(spellNameText)
			line:AddFrameToHeaderAlignment(radioGroup)
            line:AlignWithHeader(detailsSpellCategoryFrame.Header, "left")

			line.Icon = icon
			line.SpellNameText = spellNameText
            line.RadioGroup = radioGroup
            line.ExportButton = exportButton
            line.DurationEntry = durationEntry
            line.CooldownEntry = cooldownEntry

            return line
        end

        --create spell lines with the scroll
		for i = 1, scrollLines do
			spellScroll:CreateLine(scrollCreateline)
		end

        function spellScroll:RefreshScroll()
            --create a list of spells from the spell book
            ---@type savedcooldowninfoscrolldata[]
            local indexedSpells = {}
            for spellId, savedCooldownInfo in pairs(thisClassSavedTable) do
                ---@cast savedCooldownInfo savedcooldowninfo
                local spellInfo = C_Spell.GetSpellInfo(spellId)
                if (spellInfo) then
                    indexedSpells[#indexedSpells+1] = {
                        spellId = spellId,
                        type = savedCooldownInfo.type == true and 1 or savedCooldownInfo.type,
                        spellName = spellInfo.name,
                        savedCooldownInfo = savedCooldownInfo
                    }
                end
            end
            table.sort(indexedSpells, function(a, b) return a.spellName < b.spellName end) --sort by name
            spellScroll:SetData(indexedSpells)
            spellScroll:Refresh()
        end
    end

    DetailsSpellCategoryFrame.SpellScroll:RefreshScroll()
    DetailsSpellCategoryFrame:Show()
end
