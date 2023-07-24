
local addonId, edTable = ...
local Details = _G._detalhes
local AceLocale = LibStub("AceLocale-3.0")
local Loc = AceLocale:GetLocale("Details_EncounterDetails")
local Graphics = LibStub:GetLibrary("LibGraph-2.0")
local ipairs = ipairs
local _GetSpellInfo = Details.getspellinfo
local unpack = unpack
local detailsFramework = DetailsFramework
local CreateFrame = CreateFrame
local GameCooltip = GameCooltip
local _

local encounterDetails = _G.EncounterDetailsGlobal
local edFrame = encounterDetails.Frame

local emote_segment_index = 1
local searching
local emoteLines = {}
local emoteSearchTable = {}
local CONST_EMOTES_MAX_LINES = 32

encounterDetails.emoteSegmentIndex = emote_segment_index

--emotes frame
local emoteFrame = CreateFrame("frame", "DetailsEncountersEmoteFrame", UIParent, "BackdropTemplate")
emoteFrame:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
emoteFrame:RegisterEvent("CHAT_MSG_RAID_BOSS_WHISPER")
emoteFrame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
emoteFrame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
emoteFrame:RegisterEvent("CHAT_MSG_MONSTER_WHISPER")
emoteFrame:RegisterEvent("CHAT_MSG_MONSTER_PARTY")
emoteFrame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
encounterDetails.EmoteFrame = emoteFrame

local emoteTable = {
    ["CHAT_MSG_RAID_BOSS_EMOTE"] = 1,
    ["CHAT_MSG_RAID_BOSS_WHISPER"] = 2,
    ["CHAT_MSG_MONSTER_EMOTE"] = 3,
    ["CHAT_MSG_MONSTER_SAY"] = 4,
    ["CHAT_MSG_MONSTER_WHISPER"] = 5,
    ["CHAT_MSG_MONSTER_PARTY"] = 6,
    ["CHAT_MSG_MONSTER_YELL"] = 7,
}

emoteFrame:SetScript("OnEvent", function(...)
    if (not encounterDetails.current_whisper_table) then
        return
    end

    local combat = encounterDetails:GetCombat("current")
    --local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 = ...
    --print("2 =", arg2, "3 =", arg3, "4 =",  arg4, "5 =",  arg5, "6 =",  arg6, "7 =",  arg7, "8 =",  arg8, "9 =",  arg9)
    if (combat and encounterDetails:IsInCombat() and encounterDetails:GetZoneType() == "raid") then
        local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 = ...
        table.insert(encounterDetails.current_whisper_table, {combat:GetCombatTime(), arg3, arg4, emoteTable [arg2]})
    end
end)

local refresh_emotes = function(self)
    local offset = FauxScrollFrame_GetOffset(self)
    local emotePool = encounterDetails.charsaved.emotes[emote_segment_index]

    if (searching) then
        local i = 0
        local lower = string.lower

        for index, data in ipairs(emotePool) do
            if (lower(data[2]):find(lower(searching))) then
                i = i + 1
                emoteSearchTable[i] = data
            end
            for o = #emoteSearchTable, i + 1, -1 do
                emoteSearchTable[o] = nil
            end
            emotePool = emoteSearchTable
        end

        edFrame.SearchResults:Show()
        edFrame.SearchResults:SetText("Found " .. i .. " matches")

        if (i > 0) then
            edFrame.ReportEmoteButton:Enable()
        elseif (i == 0) then
            edFrame.ReportEmoteButton:Disable()
        end
    else
        edFrame.SearchResults:Hide()
    end

    if (emotePool) then
        for barIndex = 1, CONST_EMOTES_MAX_LINES do
            local data = emotePool[barIndex + offset]
            local bar = emoteLines[barIndex]

            if (data) then
                bar:Show()

                local min, sec = math.floor(data[1] / 60), math.floor(data[1] % 60)
                bar.leftText:SetText(min .. "m" .. sec .. "s:")

                if (data[2] == "") then
                    bar.rightText:SetText("--x--x--")
                else
                    bar.rightText:SetText(string.format(data[2], data[3]))
                end

                local colorString = encounterDetails.BossWhispColors[data[4]]
                local colorTable = _G.ChatTypeInfo[colorString]

                bar.rightText:SetTextColor(colorTable.r, colorTable.g, colorTable.b)
                bar.icon:SetTexture([[Interface\CHARACTERFRAME\UI-StateIcon]])
                bar.icon:SetTexCoord(0, 0.5, 0.5, 1)
                bar.icon:SetBlendMode("ADD")
            else
                bar:Hide()
            end
        end

        FauxScrollFrame_Update(self, #emotePool, CONST_EMOTES_MAX_LINES, 15)
    else
        for barIndex = 1, CONST_EMOTES_MAX_LINES do
            local bar = emoteLines[barIndex]
            bar:Hide()
        end
    end
end

edFrame.EmoteWidgets = {}
--~emotes ~whispers

local barDivEmotes = detailsFramework:CreateImage(edFrame, "Interface\\AddOns\\Details_EncounterDetails\\images\\boss_bg", 4, 480, "artwork", {724/1024, 728/1024, 0, 245/512})
barDivEmotes:SetPoint("TOPLEFT", edFrame, "TOPLEFT", 244, -74)
barDivEmotes:Hide()
table.insert(edFrame.EmoteWidgets, barDivEmotes)

local emoteScrollFrame = CreateFrame("ScrollFrame", "EncounterDetails_EmoteScroll", edFrame, "FauxScrollFrameTemplate, BackdropTemplate")
emoteScrollFrame:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll(self, offset, 14, refresh_emotes) end)
emoteScrollFrame:SetPoint("topleft", edFrame, "topleft", 249, -75)
emoteScrollFrame:SetPoint("bottomright", edFrame, "bottomright", -33, 42)
emoteScrollFrame.Update = refresh_emotes
emoteScrollFrame:Hide()
detailsFramework:ReskinSlider(emoteScrollFrame, 3)
encounterDetails.EmoteScrollFrame = emoteScrollFrame

table.insert(edFrame.EmoteWidgets, emoteScrollFrame)

local onEnterRow = function(self)
    self:SetBackdrop({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16})
    self:SetBackdropColor(1, 1, 1, .6)
    if (self.rightText:IsTruncated()) then
        GameCooltip:Reset()
        GameCooltip:AddLine(self.rightText:GetText())
        GameCooltip:SetOwner(self, "bottomleft", "topleft", 42, -9)
        GameCooltip:Show()
    end
end
local onLeaveRow = function(self)
    self:SetBackdrop({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16})
    self:SetBackdropColor(1, 1, 1, .3)
    GameCooltip:Hide()
end

local onMouseUpRow = function(self)
    --report
    local text = self.rightText:GetText()
    local time = self.leftText:GetText()

    local reportFunc = function()
        -- remove textures
        text = text:gsub("(|T).*(|t)", "")
        -- remove colors
        text = text:gsub("|c%x?%x?%x?%x?%x?%x?%x?%x?", "")
        text = text:gsub("|r", "")
        -- replace links
        for _, spellid in text:gmatch("(|Hspell:)(.-)(|h)") do
            local spell = tonumber(spellid)
            local link = GetSpellLink(spell)
            text = text:gsub("(|Hspell).*(|h)", link)
        end
        -- remove unit links
        text = text:gsub("(|Hunit).-(|h)", "")
        -- remove the left space
        text = text:gsub("^%s$", "")

        encounterDetails:SendReportLines({"Details! Encounter Emote at " .. time, "\"" .. text .. "\""})
    end

    encounterDetails:SendReportWindow(reportFunc)
end

for i = 1, CONST_EMOTES_MAX_LINES do
    local line = CreateFrame("frame", nil, edFrame,"BackdropTemplate")
    local y = (i-1) * 15 * -1
    line:SetPoint("topleft", emoteScrollFrame, "topleft", 0, y)
    line:SetPoint("topright", emoteScrollFrame, "topright", 0, y)
    line:SetHeight(14)
    line:SetBackdrop({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16})
    line:SetBackdropColor(1, 1, 1, .3)

    line.icon = line:CreateTexture(nil, "overlay")
    line.icon:SetPoint("left", line, "left", 2, 0)
    line.icon:SetSize(14, 14)

    line.leftText = line:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
    line.leftText:SetPoint("left", line.icon, "right", 2, 0)
    line.leftText:SetHeight(14)
    line.leftText:SetJustifyH("left")

    line.rightText = line:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
    line.rightText:SetPoint("left", line.icon, "right", 46, 0)
    line.rightText:SetHeight(14)
    line.rightText:SetJustifyH("left")

    line:SetFrameLevel(emoteScrollFrame:GetFrameLevel()+1)

    line:SetScript("OnEnter", onEnterRow)
    line:SetScript("OnLeave", onLeaveRow)
    line:SetScript("OnMouseUp", onMouseUpRow)
    table.insert(emoteLines, line)
    table.insert(edFrame.EmoteWidgets, line)
    line:Hide()
end

--select emote segment
local emotesSegmentLabel = detailsFramework:CreateLabel(edFrame, "Segment:", 11, nil, "GameFontHighlightSmall")
emotesSegmentLabel:SetPoint("topleft", edFrame, "topleft", 10, -85)

local onEmoteSegmentSelected = function(_, _, segment)
    FauxScrollFrame_SetOffset(emoteScrollFrame, 0)
    emote_segment_index = segment
    encounterDetails.emoteSegmentIndex = segment
    emoteScrollFrame:Update()
end

function encounterDetails:SetEmoteSegment(segment)
    emote_segment_index = segment
    encounterDetails.emoteSegmentIndex = segment
end

local segmentIcon = [[Interface\AddOns\Details\images\icons]]
local segmentIconCoords = {0.7373046875, 0.9912109375, 0.6416015625, 0.7978515625}
local segmentIconColor = {1, 1, 1, 0.5}

local buildEmoteSementsList = function()
    local resultTable = {}
    if (not encounterDetails.charsaved) then
        return resultTable
    end
    for index, segment in ipairs(encounterDetails.charsaved.emotes) do
        local bossIcon, iconWidth, iconHeight, iconL, iconR, iconT, iconB = Details:GetBossEncounterTexture(segment.boss or "unknown")
        bossIcon = bossIcon or ""
        iconWidth, iconHeight = iconWidth or 16, iconHeight or 16
        iconL, iconR, iconT, iconB = iconL or 0, iconR or 1, iconT or 0, iconB or 1

        table.insert(resultTable, {
            label = "#" .. index .. " "  ..(segment.boss or "unknown"),
            value = index,
            icon = bossIcon,
            iconsize = {iconWidth, iconHeight},
            texcoord = {iconL, iconR, iconT, iconB},
            onclick = onEmoteSegmentSelected,
            iconcolor = segmentIconColor
        })
    end
    return resultTable
end

local emoteSegmentsDropdown = detailsFramework:NewDropDown(edFrame, _, "$parentEmotesSegmentDropdown", "EmotesSegment", 180, 20, buildEmoteSementsList, 1)
emoteSegmentsDropdown:SetPoint("topleft", emotesSegmentLabel, "bottomleft", -1, -2)
emoteSegmentsDropdown:SetTemplate(detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
encounterDetails.emoteSegmentsDropdown = emoteSegmentsDropdown

table.insert(edFrame.EmoteWidgets, emoteSegmentsDropdown)
table.insert(edFrame.EmoteWidgets, emotesSegmentLabel)

--search box
local emotesSearchLabel = detailsFramework:CreateLabel(edFrame, "Search:", 11, nil, "GameFontHighlightSmall")
emotesSearchLabel:SetPoint("topleft", edFrame, "topleft", 10, -130)

local emotesSearchResultsLabel = detailsFramework:CreateLabel(edFrame, "", 11, nil, "GameFontNormal", "SearchResults")
emotesSearchResultsLabel:SetPoint("topleft", edFrame, "topleft", 10, -190)

local searchTextEntry = detailsFramework:NewTextEntry(edFrame, nil, "$parentEmoteSearchBox", nil, 180, 20)
searchTextEntry:SetTemplate(detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
searchTextEntry:SetPoint("topleft",emotesSearchLabel, "bottomleft", -1, -2)
searchTextEntry:SetJustifyH("left")
searchTextEntry:SetAsSearchBox()

searchTextEntry:SetHook("OnTextChanged", function()
    searching = searchTextEntry:GetText()
    if (searching == "") then
        searching = nil
        FauxScrollFrame_SetOffset(emoteScrollFrame, 0)
        edFrame.ReportEmoteButton:Disable()
        emoteScrollFrame:Update()
    else
        FauxScrollFrame_SetOffset(emoteScrollFrame, 0)
        edFrame.ReportEmoteButton:Enable()
        emoteScrollFrame:Update()
    end
end)

table.insert(edFrame.EmoteWidgets, searchTextEntry)
table.insert(edFrame.EmoteWidgets, emotesSearchLabel)

-- report button
local reportEmoteButton = detailsFramework:NewButton(edFrame, nil, "$parentReportEmoteButton", "ReportEmoteButton", 180, 20, function()
    local reportFunc = function(IsCurrent, IsReverse, AmtLines)
        local segment = encounterDetails.charsaved.emotes and encounterDetails.charsaved.emotes[emote_segment_index]

        if (segment) then
            encounterDetails.report_lines = {"Details!: Emotes for " .. segment.boss}
            local added = 0

            for index = 1, 16 do
                local bar = emoteLines[index]
                if (bar:IsShown() and added < AmtLines) then
                    local time = bar.leftText:GetText()
                    local text = bar.rightText:GetText()

                    --"|Hunit:77182:Oregorger|hOregorger prepares to cast |cFFFF0000|Hspell:156879|h[Blackrock Barrage]|h|r."

                    -- remove textures
                    text = text:gsub("(|T).*(|t)", "")
                    -- remove colors
                    text = text:gsub("|c%x?%x?%x?%x?%x?%x?%x?%x?", "")
                    text = text:gsub("|r", "")
                    -- replace links
                    for _, spellid in text:gmatch("(|Hspell:)(.-)(|h)") do
                        local spell = tonumber(spellid)
                        local link = GetSpellLink(spell)
                        text = text:gsub("(|Hspell).*(|h)", link)
                    end
                    -- remove unit links
                    text = text:gsub("(|Hunit).-(|h)", "")
                    -- remove the left space
                    text = text:gsub("^%s$", "")

                    table.insert(encounterDetails.report_lines, time .. " " .. text)
                    added = added + 1

                    if (added == AmtLines) then
                        break
                    end
                end
            end

            encounterDetails:SendReportLines(encounterDetails.report_lines)
        else
            encounterDetails:Msg("There is nothing to report.")
        end
    end

    local use_slider = true
    encounterDetails:SendReportWindow(reportFunc, nil, nil, use_slider)
end, nil, nil, nil, "Report Results")

reportEmoteButton:SetIcon([[Interface\AddOns\Details\images\report_button]], 8, 14, nil, {0, 1, 0, 1}, nil, 4, 2)
reportEmoteButton:SetTemplate(detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

reportEmoteButton:SetPoint("topleft", searchTextEntry, "bottomleft", 0, -4)
reportEmoteButton:Disable()

table.insert(edFrame.EmoteWidgets, reportEmoteButton)

for _, widget in pairs(edFrame.EmoteWidgets) do
    widget:Hide()
end

local emoteReportLabel = detailsFramework:NewLabel(searchTextEntry.widget, searchTextEntry.widget, nil, "report_click", "|cFFffb400Left Click|r: Report Line")
emoteReportLabel:SetPoint("topleft", searchTextEntry.widget, "bottomleft", 1, -61)
