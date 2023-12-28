
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
local GameTooltip = GameTooltip
local wipe = table.wipe
local _

local encounterDetails = _G.EncounterDetailsGlobal
local edFrame = encounterDetails.Frame

edFrame.EnemySpellsWidgets = {}

local CONST_MAX_AURA_LINES = 21

local aurasButtonTemplate = {
    backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
    backdropcolor = {.3, .3, .3, .5},
    onentercolor = {1, 1, 1, .5},
    backdropbordercolor = {0, 0, 0, 1},
}

local spell_blocks = {}
local bossmods_blocks = {}

local on_focus_gain = function(self)
    self:HighlightText()
end

local on_focus_lost = function(self)
    self:HighlightText(0, 0)
end

local on_enter_spell = function(self)
    if (self.MyObject._spellid) then
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")

        if (type(self.MyObject._spellid) == "string") then
            local spellId = self.MyObject._spellid:gsub("%a", "")
            spellId = tonumber(spellId)
            if (spellId) then
                GameTooltip:SetSpellByID(spellId)
            end
        else
            GameTooltip:SetSpellByID(self.MyObject._spellid)
        end
        GameTooltip:Show()

        self:SetBackdropColor(1, 1, 1, .5)
        self:SetBackdropBorderColor(0, 0, 0, 1)
        return true
    end
end

local on_leave_spell = function(self, capsule)
    GameTooltip:Hide()
    self:SetBackdropColor(.3, .3, .3, .5)
end

local create_aura_func = function(self, button, spellid, encounter_id)
    local name, _, icon = encounterDetails.getspellinfo(spellid)
    encounterDetails:OpenAuraPanel(spellid, name, self and self.MyObject._icon.texture, encounter_id)
end

local info_onenter = function(self)
    local spellid = self._spellid

    local info = encounterDetails.EnemySpellPool[spellid]
    if (info) then
        Details:CooltipPreset(2)
        GameCooltip:SetOption("FixedWidth", false)

        for token, _ in pairs(info.token) do
            GameCooltip:AddLine("event:", token, 1, nil, "white")
        end

        GameCooltip:AddLine("source:", info.source, 1, nil, "white")
        GameCooltip:AddLine("school:", encounterDetails:GetSpellSchoolFormatedName(info.school), 1, nil, "white")

        if (info.type) then
            GameCooltip:AddLine("aura type:", info.type, 1, nil, "white")
        end
        GameCooltip:ShowCooltip(self, "tooltip")
    end

    self:SetBackdropColor(1, 1, 1, .5)
end
local info_onleave = function(self)
    GameCooltip:Hide()
    self:SetBackdropColor(.3, .3, .3, .5)
end

local bossModsTitle = detailsFramework:CreateLabel(edFrame, "Boss Mods Time Bars:", 12, "orange")
bossModsTitle:SetPoint(10, -85)
table.insert(edFrame.EnemySpellsWidgets, bossModsTitle)
bossModsTitle:Hide()

local bossSpellsTitle = detailsFramework:CreateLabel(edFrame, "Boss Spells and Auras:", 12, "orange")
bossSpellsTitle:SetPoint(444, -85)
table.insert(edFrame.EnemySpellsWidgets, bossSpellsTitle)
bossSpellsTitle:Hide()

--create boss mods list
for i = 1, CONST_MAX_AURA_LINES do
    local anchor_frame = CreateFrame("frame", "BossFrameBossModsAnchor" .. i, edFrame, "BackdropTemplate")

    local spellicon = detailsFramework:NewImage(anchor_frame, [[Interface\ICONS\TEMP]], 19, 19, "background", nil, "icon", "$parentIcon")

    --timerId
    local spellid = detailsFramework:CreateTextEntry(anchor_frame, encounterDetails.empty_function, 80, 20, nil, "$parentSpellId")
    spellid:SetTemplate(aurasButtonTemplate)
    spellid:SetHook("OnEditFocusGained", on_focus_gain)
    spellid:SetHook("OnEditFocusLost", on_focus_lost)
    spellid:SetHook("OnEnter", on_enter_spell)
    spellid:SetHook("OnLeave", on_leave_spell)

    --ability name
    local spellname = detailsFramework:CreateTextEntry(anchor_frame, encounterDetails.empty_function, 180, 20, nil, "$parentSpellName")
    spellname:SetTemplate(aurasButtonTemplate)
    spellname:SetHook("OnEditFocusGained", on_focus_gain)
    spellname:SetHook("OnEditFocusLost", on_focus_lost)
    spellname:SetHook("OnEnter", on_enter_spell)
    spellname:SetHook("OnLeave", on_leave_spell)

    local create_aura = detailsFramework:NewButton(anchor_frame, nil, "$parentCreateAuraButton", "AuraButton", 90, 18, create_aura_func, nil, nil, nil, "Make Aura")
    create_aura:SetTemplate(aurasButtonTemplate)

    spellicon:SetPoint("topleft", edFrame, "topleft", 10, -85 +(i * 21 * -1))
    spellid:SetPoint("left", spellicon, "right", 4, 0)
    spellname:SetPoint("left", spellid, "right", 4, 0)
    create_aura:SetPoint("left", spellname, "right", 4, 0)

    spellid:SetBackdropBorderColor(0, 0, 0)
    spellname:SetBackdropBorderColor(0, 0, 0)

    anchor_frame.icon = spellicon
    anchor_frame.spellid = spellid
    anchor_frame.spellname = spellname
    anchor_frame.aurabutton = create_aura
    anchor_frame.aurabutton._icon = spellicon

    table.insert(bossmods_blocks, anchor_frame)
    table.insert(edFrame.EnemySpellsWidgets, anchor_frame)

    anchor_frame:Hide()
end

--create buff list
for i = 1, CONST_MAX_AURA_LINES do
    local anchor_frame = CreateFrame("frame", "BossFrameSpellAnchor" .. i, edFrame, "BackdropTemplate")

    local spellicon = detailsFramework:NewImage(anchor_frame, [[Interface\ICONS\TEMP]], 19, 19, "background", nil, "icon", "$parentIcon")

    local spellid = detailsFramework:CreateTextEntry(anchor_frame, encounterDetails.empty_function, 80, 20)
    spellid:SetTemplate(aurasButtonTemplate)
    spellid:SetHook("OnEditFocusGained", on_focus_gain)
    spellid:SetHook("OnEditFocusLost", on_focus_lost)
    spellid:SetHook("OnEnter", on_enter_spell)
    spellid:SetHook("OnLeave", on_leave_spell)

    local spellname = detailsFramework:CreateTextEntry(anchor_frame, encounterDetails.empty_function, 160, 20)
    spellname:SetTemplate(aurasButtonTemplate)
    spellname:SetHook("OnEditFocusGained", on_focus_gain)
    spellname:SetHook("OnEditFocusLost", on_focus_lost)
    spellname:SetHook("OnEnter", on_enter_spell)
    spellname:SetHook("OnLeave", on_leave_spell)

    --spellicon_button:SetPoint("topleft", BossFrame, "topleft", 255, -65 +(i * 21 * -1))
    spellicon:SetPoint("topleft", edFrame, "topleft", 443, -85 +(i * 21 * -1))
    spellid:SetPoint("left", spellicon, "right", 4, 0)
    spellname:SetPoint("left", spellid, "right", 4, 0)

    local spellinfo = CreateFrame("frame", nil, anchor_frame,"BackdropTemplate")
    spellinfo:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
    spellinfo:SetBackdropColor(.3, .3, .3, .5)
    spellinfo:SetBackdropBorderColor(0, 0, 0, 1)
    spellinfo:SetSize(80, 20)
    spellinfo:SetScript("OnEnter", info_onenter)
    spellinfo:SetScript("OnLeave", info_onleave)

    local spellinfotext = spellinfo:CreateFontString(nil, "overlay", "GameFontNormal")
    spellinfotext:SetPoint("center", spellinfo, "center")
    spellinfotext:SetText("info")
    spellinfo:SetPoint("left", spellname.widget, "right", 4, 0)

    local create_aura = detailsFramework:NewButton(anchor_frame, nil, "$parentCreateAuraButton", "AuraButton", 90, 18, create_aura_func, nil, nil, nil, "Make Aura")
    create_aura:SetPoint("left", spellinfo, "right", 4, 0)
    create_aura:SetTemplate(aurasButtonTemplate)

    anchor_frame.icon = spellicon
    anchor_frame.spellid = spellid
    anchor_frame.spellname = spellname
    anchor_frame.aurabutton = create_aura
    anchor_frame.aurabutton._icon = spellicon
    anchor_frame.info = spellinfo

    table.insert(spell_blocks, anchor_frame)
    table.insert(edFrame.EnemySpellsWidgets, anchor_frame)

    anchor_frame:Hide()
end

local update_enemy_spells = function()
    local combat = encounterDetails:GetCombat(encounterDetails._segment)
    local spell_list = {}

    if (combat) then
        for i, npc in combat[1]:ListActors() do
            --damage
            if (npc:IsNeutralOrEnemy()) then
                for spellid, spell in pairs(npc.spells._ActorTable) do
                    if (spellid > 10) then
                        local name, _, icon = encounterDetails.getspellinfo(spellid)
                        table.insert(spell_list, {spellid, name, icon, nil, npc.serial})
                    end
                end
            end
        end

        for i, npc in combat[2]:ListActors() do
            --heal
            if (npc:IsNeutralOrEnemy()) then
                for spellid, spell in pairs(npc.spells._ActorTable) do
                    if (spellid > 10) then
                        local name, _, icon = encounterDetails.getspellinfo(spellid)
                        table.insert(spell_list, {spellid, name, icon, true, npc.serial})
                    end
                end
            end
        end

        table.sort(spell_list, function(t1, t2)
            return t1[2] < t2[2]
        end)

        encounterDetails.SpellScrollframe.spell_pool = spell_list
        encounterDetails.SpellScrollframe.encounter_id = combat.is_boss and combat.is_boss.id
        encounterDetails.SpellScrollframe:Update()
    end
end

local refresh_bossmods_timers = function(self)
    local combat = encounterDetails:GetCombat(encounterDetails._segment)
    local offset = FauxScrollFrame_GetOffset(self)
    local already_added = {}
    local db = Details.boss_mods_timers
    local encounter_id = combat.is_boss and combat.is_boss.id

    if (db) then
        wipe(already_added)
        local timersToAdd = {}

        for timerId, timerTable in pairs(db.encounter_timers_dbm) do
            if (timerTable.id == encounter_id) then
                local spellId = timerTable [7]
                local spellIcon = timerTable [5]
                local spellName

                local spell = timerId
                spell = spell:gsub("ej", "")
                spell = tonumber(spell)

                if (spell and not already_added[spell]) then
                    if (spell > 40000) then
                        local spellname, _, spellicon = _GetSpellInfo(spell)
                        table.insert(timersToAdd, {label = spellname, value = {timerTable[2], spellname, spellIcon or spellicon, timerTable.id, timerTable[7]}, icon = spellIcon or spellicon})
                    else
                        local sectionInfo = C_EncounterJournal.GetSectionInfo(spell)
                        table.insert(timersToAdd, {label = sectionInfo.title, value = {timerTable[2], sectionInfo.title, spellIcon or sectionInfo.abilityIcon, timerTable.id, timerTable[7]}, icon = spellIcon or sectionInfo.abilityIcon})
                    end

                    already_added[spell] = true
                end
            end
        end

        table.sort(timersToAdd, function(t1, t2)
            return t1.label < t2.label
        end)

        local offset = FauxScrollFrame_GetOffset(self)

        for barIndex = 1, CONST_MAX_AURA_LINES do

            local data = timersToAdd[barIndex + offset]
            local bar = bossmods_blocks[barIndex]

            if (data) then
                bar:Show()

                bar.icon.texture = data.icon
                bar.icon:SetTexCoord(.1, .9, .1, .9)
                bar.spellid.text = data.value[1] or "--x--x--"
                bar.spellname.text = data.label or "--x--x--"

                bar.spellid._spellid = data.value[1]
                bar.spellname._spellid = data.value[1]

                local func = function()
                    local timerId, spellname, spellicon, encounterid, spellid = unpack(data.value)
                    encounterDetails:OpenAuraPanel(timerId, spellname, spellicon, encounterid, DETAILS_WA_TRIGGER_DBM_TIMER, DETAILS_WA_AURATYPE_TEXT, {dbm_timer_id = timerId, spellid = spellid, text = "Next " .. spellname .. " In", text_size = 72, icon = spellicon})
                end

                bar.aurabutton:SetClickFunction(func)
            else
                bar:Hide()
            end
        end

        FauxScrollFrame_Update(self, #timersToAdd, CONST_MAX_AURA_LINES, 20)

        if (#timersToAdd > 0) then
            self:Show()
        end
    end
end

local refresh_spellauras = function(self)
    local pool = encounterDetails.SpellScrollframe.spell_pool
    local encounter_id = encounterDetails.SpellScrollframe.encounter_id
    local offset = FauxScrollFrame_GetOffset(self)

    for bar_index = 1, CONST_MAX_AURA_LINES do
        local data = pool[bar_index + offset]
        local bar = spell_blocks[bar_index]

        if (data) then
            bar:Show()

            bar.icon.texture = data[3]
            bar.icon:SetTexCoord(.1, .9, .1, .9)
            bar.spellid.text = data[1]
            bar.spellname.text = data[2]

            bar.spellid._spellid = data[1]
            bar.spellname._spellid = data[1]
            bar.info._spellid = data[1]

            local is_heal = data[4]
            if (is_heal) then
                bar.spellid:SetBackdropBorderColor(0, 1, 0)
                bar.spellname:SetBackdropBorderColor(0, 1, 0)
            else
                bar.spellid:SetBackdropBorderColor(0, 0, 0)
                bar.spellname:SetBackdropBorderColor(0, 0, 0)
            end

            bar.aurabutton:SetClickFunction(create_aura_func, data [1], encounter_id)
        else
            bar:Hide()
        end
    end

    FauxScrollFrame_Update(self, #pool, CONST_MAX_AURA_LINES, 20)
end

local spellScrollFrame = CreateFrame("ScrollFrame", "EncounterDetails_SpellAurasScroll", edFrame, "FauxScrollFrameTemplate, BackdropTemplate")
spellScrollFrame:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll(self, offset, 14, refresh_spellauras) end)
spellScrollFrame:SetPoint("topleft", edFrame, "topleft", 200, -75)
spellScrollFrame:SetPoint("bottomright", edFrame, "bottomright", -33, 42)
spellScrollFrame.Update = refresh_spellauras
spellScrollFrame:Hide()
encounterDetails.SpellScrollframe = spellScrollFrame
detailsFramework:ReskinSlider(spellScrollFrame)

table.insert(edFrame.EnemySpellsWidgets, spellScrollFrame)
encounterDetails.update_enemy_spells = update_enemy_spells

local bossmodsScrollFrame = CreateFrame("ScrollFrame", "EncounterDetails_BossModsScroll", edFrame, "FauxScrollFrameTemplate, BackdropTemplate")
bossmodsScrollFrame:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll(self, offset, 14, refresh_bossmods_timers) end)
bossmodsScrollFrame:SetPoint("topleft", edFrame, "topleft", 10, -75)
bossmodsScrollFrame:SetPoint("bottomleft", edFrame, "bottomleft", 250, 42)
bossmodsScrollFrame.Update = refresh_bossmods_timers
bossmodsScrollFrame:Hide()
encounterDetails.BossModsScrollframe = bossmodsScrollFrame

table.insert(edFrame.EnemySpellsWidgets, bossmodsScrollFrame)
encounterDetails.update_bossmods = function() bossmodsScrollFrame:Update() end

local build_bigwigs_bars = function()
    local t = {}
    local db = Details.boss_mods_timers
    if (db) then
        wipe(already_added)
        local encounter_id = encounterDetails.SpellScrollframe.encounter_id

        for timer_id, timer_table in pairs(db.encounter_timers_bw) do
            if (timer_table.id == encounter_id) then
                local spell = timer_id
                if (spell and not already_added [spell]) then
                    local int_spell = tonumber(spell)
                    if (not int_spell) then
                        local spellname = timer_table [2]:gsub(" %(.%)", "")
                        table.insert(t, {label = spellname, value = {timer_table [2], spellname, timer_table [5], timer_table.id}, icon = timer_table [5], onclick = on_select_bw_bar})
                    elseif (int_spell < 0) then
                        local title, description, depth, abilityIcon, displayInfo, siblingID, nextSectionID, filteredByDifficulty, link, startsOpen, flag1, flag2, flag3, flag4 = C_EncounterJournal.GetSectionInfo(abs(int_spell))
                        table.insert(t, {label = title, value = {timer_table [2], title, timer_table [5] or abilityIcon, timer_table.id}, icon = timer_table [5] or abilityIcon, onclick = on_select_bw_bar})
                    else
                        local spellname, _, spellicon = _GetSpellInfo(int_spell)
                        table.insert(t, {label = spellname, value = {timer_table [2], spellname, timer_table [5] or spellicon, timer_table.id}, icon = timer_table [5] or spellicon, onclick = on_select_bw_bar})
                    end

                    already_added [spell] = true
                end
            end
        end
    end
    return t
end