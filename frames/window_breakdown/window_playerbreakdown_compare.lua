
local Details = Details
local red = "FFFFAAAA"
local green = "FFAAFFAA"
local _GetSpellInfo = Details.GetSpellInfo
local unpack = unpack

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--~compare

local targetTexture = [[Interface\MINIMAP\TRACKING\Target]]
local emptyText = ""

local plus = red .. "-"
local minor = green .. "+"

local bar_color = {.5, .5, .5, .4} -- bar of the second and 3rd player
local bar_color_on_enter = {.9, .9, .9, .9}

local frame_backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true}
local frame_backdrop_color = {0, 0, 0, 0.35}
local frame_backdrop_border_color = {0, 0, 0, 0}

local spell_compare_frame_width = {298, 225, 226}
local spell_compare_frame_height = 200
local target_compare_frame_height = 142

local xLocation = 2
local yLocation = -20
local targetBars = 9

local _unpack = unpack

local IconTexCoord = {5/64, 59/64, 5/64, 59/64}

local Loc = LibStub("AceLocale-3.0"):GetLocale( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

local breakdownWindowFrame = Details.BreakdownWindowFrame

local fill_compare_targets = function(self, player, other_players, target_pool)
    local offset = _G.FauxScrollFrame_GetOffset(self)
    local frame2 = _G.DetailsPlayerComparisonTarget2
    local frame3 = _G.DetailsPlayerComparisonTarget3

    if (not target_pool [1]) then
        for i = 1, targetBars do
            local bar = self.bars [i]
            local bar_2 = frame2.bars [i]
            local bar_3 = frame3.bars [i]

            bar [1]:SetTexture("")
            bar [2].lefttext:SetText(emptyText)
            bar [2].lefttext:SetTextColor(.5, .5, .5, 1)
            bar [2].righttext:SetText("")
            bar [2].righttext2:SetText("")
            bar [2]:SetValue(0)
            bar [2]:SetBackdropColor(1, 1, 1, 0)
            bar [3][4] = nil
            bar_2 [1]:SetTexture("")
            bar_2 [2].lefttext:SetText(emptyText)
            bar_2 [2].lefttext:SetTextColor(.5, .5, .5, 1)
            bar_2 [2].righttext:SetText("")
            bar_2 [2].righttext2:SetText("")
            bar_2 [2]:SetValue(0)
            bar_2 [2]:SetBackdropColor(1, 1, 1, 0)
            bar_2 [3][4] = nil
            bar_3 [1]:SetTexture("")
            bar_3 [2].lefttext:SetText(emptyText)
            bar_3 [2].lefttext:SetTextColor(.5, .5, .5, 1)
            bar_3 [2].righttext:SetText("")
            bar_3 [2].righttext2:SetText("")
            bar_3 [2]:SetValue(0)
            bar_3 [2]:SetBackdropColor(1, 1, 1, 0)
            bar_3 [3][4] = nil
        end

        return
    end

    local top = target_pool [1] [2]

    --player 2
    local player_2 = other_players [1]
    local player_2_target_pool
    local player_2_top
    if (player_2) then
        local player_2_target = player_2.targets
        player_2_target_pool = {}
        for target_name, amount in pairs(player_2_target) do
            player_2_target_pool [#player_2_target_pool+1] = {target_name, amount}
        end
        table.sort (player_2_target_pool, Details.Sort2)
        if (player_2_target_pool [1]) then
            player_2_top = player_2_target_pool [1] [2]
        else
            player_2_top = 0
        end
        --1 skill,
    end

    --player 3
    local player_3 = other_players [2]
    local player_3_target_pool
    local player_3_top
    if (player_3) then
        local player_3_target = player_3.targets
        player_3_target_pool = {}
        for target_name, amount in pairs(player_3_target) do
            player_3_target_pool [#player_3_target_pool+1] = {target_name, amount}
        end
        table.sort (player_3_target_pool, Details.Sort2)
        if (player_3_target_pool [1]) then
            player_3_top = player_3_target_pool [1] [2]
        else
            player_3_top = 0
        end
    end

    for i = 1, targetBars do
        local bar = self.bars [i]
        local bar_2 = frame2.bars [i]
        local bar_3 = frame3.bars [i]

        local index = i + offset
        local data = target_pool [index]

        if (data) then --[name] [total]

            local target_name = data [1]

            bar [1]:SetTexture(targetTexture)
            bar [1]:SetDesaturated(true)
            bar [1]:SetAlpha(.7)

            bar [2].lefttext:SetText(index .. ". " .. target_name)
            bar [2].lefttext:SetTextColor(1, 1, 1, 1)
            bar [2].righttext:SetText(Details:ToK2Min (data [2])) -- .. " (" .. math.floor(data [2] / total * 100) .. "%)"
            bar [2]:SetValue(data [2] / top * 100)
            --bar [2]:SetValue(100)
            bar [3][1] = player.nome --name
            bar [3][2] = target_name
            bar [3][3] = data [2] --total
            bar [3][4] = player

            -- 2
            if (player_2) then

                local player_2_target_total
                local player_2_target_index

                for index, t in ipairs(player_2_target_pool) do
                    if (t[1] == target_name) then
                        player_2_target_total = t[2]
                        player_2_target_index = index
                        break
                    end
                end

                if (player_2_target_total) then
                    bar_2 [1]:SetTexture(targetTexture)
                    bar_2 [1]:SetDesaturated(true)
                    bar_2 [1]:SetAlpha(.7)

                    bar_2 [2].lefttext:SetText(player_2_target_index .. ". " .. target_name)
                    bar_2 [2].lefttext:SetTextColor(1, 1, 1, 1)

                    if (data [2] > player_2_target_total) then
                        local diff = data [2] - player_2_target_total
                        local up = diff / player_2_target_total * 100
                        up = math.floor(up)
                        if (up > 999) then
                            up = "" .. 999
                        end

                        bar_2 [2].righttext2:SetText(Details:ToK2Min (player_2_target_total))
                        bar_2 [2].righttext:SetText(" |c" .. minor .. up .. "%|r")
                    else
                        local diff = player_2_target_total - data [2]
                        local down = diff / data [2] * 100
                        down = math.floor(down)
                        if (down > 999) then
                            down = "" .. 999
                        end
                        bar_2 [2].righttext2:SetText(Details:ToK2Min (player_2_target_total))
                        bar_2 [2].righttext:SetText(" |c" .. plus .. down .. "%|r")
                    end

                    --bar_2 [2]:SetValue(player_2_target_total / player_2_top * 100)
                    bar_2 [2]:SetValue(100)

                    bar_2 [3][1] = player_2.nome
                    bar_2 [3][2] = target_name
                    bar_2 [3][3] = player_2_target_total
                    bar_2 [3][4] = player_2

                else
                    bar_2 [1]:SetTexture("")
                    bar_2 [2].lefttext:SetText(emptyText)
                    bar_2 [2].lefttext:SetTextColor(.5, .5, .5, 1)
                    bar_2 [2].righttext:SetText("")
                    bar_2 [2].righttext2:SetText("")
                    bar_2 [2]:SetValue(0)
                    bar_2 [2]:SetBackdropColor(1, 1, 1, 0)
                    bar_2 [3][4] = nil
                end
            else
                bar_2 [1]:SetTexture("")
                bar_2 [2].lefttext:SetText(emptyText)
                bar_2 [2].lefttext:SetTextColor(.5, .5, .5, 1)
                bar_2 [2].righttext:SetText("")
                bar_2 [2].righttext2:SetText("")
                bar_2 [2]:SetValue(0)
                bar_2 [2]:SetBackdropColor(1, 1, 1, 0)
                bar_2 [3][4] = nil
            end

            -- 3
            if (player_3) then

                local player_3_target_total
                local player_3_target_index

                for index, t in ipairs(player_3_target_pool) do
                    if (t[1] == target_name) then
                        player_3_target_total = t[2]
                        player_3_target_index = index
                        break
                    end
                end

                if (player_3_target_total) then
                    bar_3 [1]:SetTexture(targetTexture)
                    bar_3 [1]:SetDesaturated(true)
                    bar_3 [1]:SetAlpha(.7)

                    bar_3 [2].lefttext:SetText(player_3_target_index .. ". " .. target_name)
                    bar_3 [2].lefttext:SetTextColor(1, 1, 1, 1)

                    if (data [2] > player_3_target_total) then
                        local diff = data [2] - player_3_target_total
                        local up = diff / player_3_target_total * 100
                        up = math.floor(up)
                        if (up > 999) then
                            up = "" .. 999
                        end
                        bar_3 [2].righttext2:SetText(Details:ToK2Min (player_3_target_total))
                        bar_3 [2].righttext:SetText(" |c" .. minor .. up .. "%|r")
                    else
                        local diff = player_3_target_total - data [2]
                        local down = diff / data [2] * 100
                        down = math.floor(down)
                        if (down > 999) then
                            down = "" .. 999
                        end
                        bar_3 [2].righttext:SetText(Details:ToK2Min (player_3_target_total))
                        bar_3 [2].righttext:SetText(" |c" .. plus .. down .. "%|r")
                    end

                    --bar_3 [2]:SetValue(player_3_target_total / player_3_top * 100)
                    bar_3 [2]:SetValue(100)

                    bar_3 [3][1] = player_3.nome
                    bar_3 [3][2] = target_name
                    bar_3 [3][3] = player_3_target_total
                    bar_3 [3][4] = player_3

                else
                    bar_3 [1]:SetTexture("")
                    bar_3 [2].lefttext:SetText(emptyText)
                    bar_3 [2].lefttext:SetTextColor(.5, .5, .5, 1)
                    bar_3 [2].righttext:SetText("")
                    bar_3 [2].righttext2:SetText("")
                    bar_3 [2]:SetValue(0)
                    bar_3 [2]:SetBackdropColor(1, 1, 1, 0)
                    bar_3 [3][4] = nil
                end
            else
                bar_3 [1]:SetTexture("")
                bar_3 [2].lefttext:SetText(emptyText)
                bar_3 [2].lefttext:SetTextColor(.5, .5, .5, 1)
                bar_3 [2].righttext:SetText("")
                bar_3 [2].righttext2:SetText("")
                bar_3 [2]:SetValue(0)
                bar_3 [2]:SetBackdropColor(1, 1, 1, 0)
                bar_3 [3][4] = nil
            end

        else
            bar [1]:SetTexture("")
            bar [2].lefttext:SetText(emptyText)
            bar [2].lefttext:SetTextColor(.5, .5, .5, 1)
            bar [2].righttext:SetText("")
            bar [2].righttext2:SetText("")
            bar [2]:SetValue(0)
            bar [2]:SetBackdropColor(1, 1, 1, 0)
            bar [3][4] = nil
            bar_2 [1]:SetTexture("")
            bar_2 [2].lefttext:SetText(emptyText)
            bar_2 [2].lefttext:SetTextColor(.5, .5, .5, 1)
            bar_2 [2].righttext:SetText("")
            bar_2 [2].righttext2:SetText("")
            bar_2 [2]:SetValue(0)
            bar_2 [2]:SetBackdropColor(1, 1, 1, 0)
            bar_2 [3][4] = nil
            bar_3 [1]:SetTexture("")
            bar_3 [2].lefttext:SetText(emptyText)
            bar_3 [2].lefttext:SetTextColor(.5, .5, .5, 1)
            bar_3 [2].righttext:SetText("")
            bar_3 [2].righttext2:SetText("")
            bar_3 [2]:SetValue(0)
            bar_3 [2]:SetBackdropColor(1, 1, 1, 0)
            bar_3 [3][4] = nil
        end
    end

end

local fill_compare_actors = function(self, player, other_players)

    --main player skills
    local spells_sorted = {}
    for spellid, spelltable in pairs(player.spells._ActorTable) do
        spells_sorted [#spells_sorted+1] = {spelltable, spelltable.total}
    end

    --main player pets
    for petIndex, petName in ipairs(player:Pets()) do
        local petActor = breakdownWindowFrame.instancia.showing [player.tipo]:PegarCombatente (nil, petName)
        if (petActor) then
            for _spellid, _skill in pairs(petActor:GetActorSpells()) do
                spells_sorted [#spells_sorted+1] = {_skill, _skill.total, petName}
            end
        end
    end
    table.sort (spells_sorted, Details.Sort2)

    self.player = player:Name()

    local offset = _G.FauxScrollFrame_GetOffset(self)

    local total = player.total_without_pet
    local top = spells_sorted [1] and spells_sorted [1] [2] or 0

    local frame2 = _G.DetailsPlayerComparisonBox2
    local frame3 = _G.DetailsPlayerComparisonBox3

    local player_2_total
    local player_2_spells_sorted
    local player_2_top
    local player_2_spell_info

    if (other_players [1]) then
        frame2.player = other_players [1]:Name()
        player_2_total = other_players [1].total_without_pet
        player_2_spells_sorted = {}

        --player 2 spells
        for spellid, spelltable in pairs(other_players [1].spells._ActorTable) do
            player_2_spells_sorted [#player_2_spells_sorted+1] = {spelltable, spelltable.total}
        end
        --player 2 pets
        for petIndex, petName in ipairs(other_players [1]:Pets()) do
            local petActor = breakdownWindowFrame.instancia.showing [player.tipo]:PegarCombatente (nil, petName)
            if (petActor) then
                for _spellid, _skill in pairs(petActor:GetActorSpells()) do
                    player_2_spells_sorted [#player_2_spells_sorted+1] = {_skill, _skill.total, petName}
                end
            end
        end

        table.sort (player_2_spells_sorted, Details.Sort2)
        player_2_top = (player_2_spells_sorted [1] and player_2_spells_sorted [1] [2]) or 0
        --se n�o existir uma magia no jogador e o jogador tiver um pet, ele n�o vai encontrar um valor em [1] e dar
        -- ~pet
        player_2_spell_info = {}
        for index, spelltable in ipairs(player_2_spells_sorted) do
            player_2_spell_info [spelltable[1].id] = index
        end

        frame2.NoPLayersToShow:Hide()
        frame3.NoPLayersToShow:Hide()
    else
        frame2.NoPLayersToShow:Show()
        frame3.NoPLayersToShow:Show()
    end

    local player_3_total
    local player_3_spells_sorted
    local player_3_spell_info
    local player_3_top

    if (other_players [2]) then
        frame3.player = other_players [2] and other_players [2]:Name()
        player_3_total = other_players [2] and other_players [2].total_without_pet
        player_3_spells_sorted = {}
        player_3_spell_info = {}

        if (other_players [2]) then
            --player 3 spells
            for spellid, spelltable in pairs(other_players [2].spells._ActorTable) do
                player_3_spells_sorted [#player_3_spells_sorted+1] = {spelltable, spelltable.total}
            end
            --player 3 pets
            for petIndex, petName in ipairs(other_players [2]:Pets()) do
                local petActor = breakdownWindowFrame.instancia.showing [player.tipo]:PegarCombatente (nil, petName)
                if (petActor) then
                    for _spellid, _skill in pairs(petActor:GetActorSpells()) do
                        player_3_spells_sorted [#player_3_spells_sorted+1] = {_skill, _skill.total, petName}
                    end
                end
            end

            table.sort (player_3_spells_sorted, Details.Sort2)
            player_3_top = player_3_spells_sorted [1] [2]
            for index, spelltable in ipairs(player_3_spells_sorted) do
                player_3_spell_info [spelltable[1].id] = index
            end
        end
    end

    for i = 1, 12 do
        local bar = self.bars [i]
        local index = i + offset

        --main player spells
        local data = spells_sorted [index]

        if (data) then --if exists

            --main player - seta no primeiro box
                local spellid = data [1].id
                local name, _, icon = _GetSpellInfo(spellid)

                if (not name) then
                    --no spell found? - tbc problem
                    return
                end

                local petName = data [3]
                bar [1]:SetTexture(icon) --bar[1] = spellicon bar[2] = statusbar
                bar [1]:SetTexCoord(unpack(IconTexCoord)) --bar[1] = spellicon bar[2] = statusbar

                bar [2]:SetBackdropColor(1, 1, 1, 0.1)

                if (petName) then
                    bar [2].lefttext:SetText(index .. ". " .. name .. " (|cFFCCBBBB" .. petName:gsub(" <.*", "") .. "|r)")
                else
                    bar [2].lefttext:SetText(index .. ". " .. name)
                end
                bar [2].lefttext:SetTextColor(1, 1, 1, 1)
                bar [2].righttext:SetText(Details:ToK2Min (data [2])) -- .. " (" .. math.floor(data [2] / total * 100) .. "%)"
                bar [2]:SetValue(data [2] / top * 100)
                --bar [2]:SetValue(100)
                bar [3][1] = data [1].counter --tooltip hits
                bar [3][2] = data [2] / math.max(data [1].counter, 0.0001) --tooltip average
                bar [3][3] = math.floor(data [1].c_amt / math.max(data [1].counter, 0.0001) * 100) --tooltip critical
                bar [3][4] = spellid

            --player 2
            local player_2 = other_players [1]
            local spell = player_2 and player_2.spells._ActorTable [spellid]

            if (not spell and petName and player_2) then
                for _petIndex, _petName in ipairs(player_2:Pets()) do
                    if (_petName:gsub(" <.*", "") == petName:gsub(" <.*", "")) then
                        local petActor = breakdownWindowFrame.instancia.showing [player.tipo]:PegarCombatente (nil, _petName)
                        spell = petActor and petActor.spells._ActorTable [spellid]
                        name = name .. " (|cFFCCBBBB" .. _petName:gsub(" <.*", "") .. "|r)"
                    end
                end
            end

            local bar_2 = frame2 and frame2.bars [i]

            -- ~compare
            if (spell) then
                bar_2 [1]:SetTexture(icon)
                bar_2 [1]:SetTexCoord(unpack(IconTexCoord)) --bar[1] = spellicon bar[2] = statusbar
                bar_2 [2].lefttext:SetText(player_2_spell_info [spellid] .. ". " .. name)
                bar_2 [2].lefttext:SetTextColor(1, 1, 1, 1)
                bar_2 [2]:SetStatusBarColor(unpack(bar_color))
                bar_2 [2]:SetBackdropColor(1, 1, 1, 0.1)

                if (spell.total == 0 and data [2] == 0) then
                    bar_2 [2].righttext2:SetText("0")
                    bar_2 [2].righttext:SetText("+0%")

                elseif (data [2] > spell.total) then
                    if (spell.total > 0) then
                        local diff = data [2] - spell.total
                        local up = diff / spell.total * 100
                        up = math.floor(up)
                        if (up > 999) then
                            up = "" .. 999
                        end
                        bar_2 [2].righttext2:SetText(Details:ToK2Min (spell.total))
                        bar_2 [2].righttext:SetText(" |c" .. minor .. up .. "%|r")
                    else
                        bar_2 [2].righttext2:SetText("0")
                        bar_2 [2].righttext:SetText("+0%")
                    end

                else
                    if (data [2] > 0) then
                        local diff = spell.total - data [2]
                        local down = diff / data [2] * 100
                        down = math.floor(down)
                        if (down > 999) then
                            down = "" .. 999
                        end
                        bar_2 [2].righttext2:SetText(Details:ToK2Min (spell.total))
                        bar_2 [2].righttext:SetText(" |c" .. plus .. down .. "%|r")
                    else
                        bar_2 [2].righttext2:SetText("0")
                        bar_2 [2].righttext:SetText("+0%")
                    end
                end

                bar_2 [2]:SetValue(spell.total / player_2_top * 100)
                bar_2 [2]:SetValue(100)
                bar_2 [3][1] = spell.counter --tooltip hits
                bar_2 [3][2] = spell.total / spell.counter --tooltip average
                bar_2 [3][3] = math.floor(spell.c_amt / spell.counter * 100) --tooltip critical
                bar_2 [2]:SetBackdropColor(1, 1, 1, 0)
            else
                bar_2 [1]:SetTexture("")
                bar_2 [2].lefttext:SetText(emptyText)
                bar_2 [2].lefttext:SetTextColor(.5, .5, .5, 1)
                bar_2 [2].righttext:SetText("")
                bar_2 [2].righttext2:SetText("")
                bar_2 [2]:SetValue(0)
                bar_2 [2]:SetBackdropColor(1, 1, 1, 0)
            end

            --player 3
            local bar_3 = frame3 and frame3.bars [i]

            if (player_3_total) then
                local player_3 = other_players [2]
                local spell = player_3 and player_3.spells._ActorTable [spellid]

                if (not spell and petName and player_3) then
                    for _petIndex, _petName in ipairs(player_3:Pets()) do
                        if (_petName:gsub(" <.*", "") == petName:gsub(" <.*", "")) then
                            local petActor = breakdownWindowFrame.instancia.showing [player.tipo]:PegarCombatente (nil, _petName)
                            spell = petActor and petActor.spells._ActorTable [spellid]
                            local name, _, icon = _GetSpellInfo(spellid)
                            name = name .. " (|cFFCCBBBB" .. _petName:gsub(" <.*", "") .. "|r)"
                        end
                    end
                end

                if (spell) then
                    bar_3 [1]:SetTexture(icon)
                    bar_3 [1]:SetTexCoord(unpack(IconTexCoord)) --bar[1] = spellicon bar[2] = statusbar
                    bar_3 [2].lefttext:SetText(player_3_spell_info [spellid] .. ". " .. name)
                    bar_3 [2].lefttext:SetTextColor(1, 1, 1, 1)
                    bar_3 [2]:SetStatusBarColor(unpack(bar_color))
                    bar_3 [2]:SetBackdropColor(1, 1, 1, 0.1)

                    if (spell.total == 0 and data [2] == 0) then
                        bar_3 [2].righttext2:SetText("0")
                        bar_3 [2].righttext:SetText("+0%")

                    elseif (data [2] > spell.total) then
                        if (spell.total > 0) then
                            local diff = data [2] - spell.total
                            local up = diff / spell.total * 100
                            up = math.floor(up)
                            if (up > 999) then
                                up = "" .. 999
                            end
                            bar_3 [2].righttext2:SetText(Details:ToK2Min (spell.total))
                            bar_3 [2].righttext:SetText(" |c" .. minor .. up .. "%|r")
                        else
                            bar_3 [2].righttext2:SetText("0")
                            bar_3 [2].righttext:SetText("0%")
                        end
                    else
                        if (data [2] > 0) then
                            local diff = spell.total - data [2]
                            local down = diff / data [2] * 100
                            down = math.floor(down)
                            if (down > 999) then
                                down = "" .. 999
                            end
                            bar_3 [2].righttext2:SetText(Details:ToK2Min (spell.total))
                            bar_3 [2].righttext:SetText(" |c" .. plus .. down .. "%|r")
                        else
                            bar_3 [2].righttext:SetText("0")
                            bar_3 [2].righttext:SetText("+0%")
                        end
                    end

                    bar_3 [2]:SetValue(spell.total / player_3_top * 100)
                    bar_3 [2]:SetValue(100)
                    bar_3 [3][1] = spell.counter --tooltip hits
                    bar_3 [3][2] = spell.total / spell.counter --tooltip average
                    bar_3 [3][3] = math.floor(spell.c_amt / spell.counter * 100) --tooltip critical
                else
                    bar_3 [1]:SetTexture("")
                    bar_3 [2].lefttext:SetText(emptyText)
                    bar_3 [2].lefttext:SetTextColor(.5, .5, .5, 1)
                    bar_3 [2].righttext:SetText("")
                    bar_3 [2].righttext2:SetText("")
                    bar_3 [2]:SetValue(0)
                    bar_3 [2]:SetBackdropColor(1, 1, 1, 0)
                end
            else
                bar_3 [1]:SetTexture("")
                bar_3 [2].lefttext:SetText(emptyText)
                bar_3 [2].lefttext:SetTextColor(.5, .5, .5, 1)
                bar_3 [2].righttext:SetText("")
                bar_3 [2].righttext2:SetText("")
                bar_3 [2]:SetValue(0)
                bar_3 [2]:SetBackdropColor(1, 1, 1, 0)
            end
        else
            bar [1]:SetTexture("")
            bar [2].lefttext:SetText(emptyText)
            bar [2].lefttext:SetTextColor(.5, .5, .5, 1)
            bar [2].righttext:SetText("")
            bar [2]:SetValue(0)
            bar [2]:SetBackdropColor(1, 1, 1, 0)
            local bar_2 = frame2.bars [i]
            bar_2 [1]:SetTexture("")
            bar_2 [2].lefttext:SetText(emptyText)
            bar_2 [2].lefttext:SetTextColor(.5, .5, .5, 1)
            bar_2 [2].righttext:SetText("")
            bar_2 [2].righttext2:SetText("")
            bar_2 [2]:SetValue(0)
            bar_2 [2]:SetBackdropColor(1, 1, 1, 0)
            local bar_3 = frame3.bars [i]
            bar_3 [1]:SetTexture("")
            bar_3 [2].lefttext:SetText(emptyText)
            bar_3 [2].lefttext:SetTextColor(.5, .5, .5, 1)
            bar_3 [2].righttext:SetText("")
            bar_3 [2].righttext2:SetText("")
            bar_3 [2]:SetValue(0)
            bar_3 [2]:SetBackdropColor(1, 1, 1, 0)
        end

    end

    for index, spelltable in ipairs(spells_sorted) do

    end

end

local refresh_comparison_box = function(self)
    --atualiza a scroll
    fill_compare_actors (self, self.tab.player, self.tab.players)
    FauxScrollFrame_Update (self, self.tab.spells_amt, 12, 15)
    self:Show()
end

local refresh_target_box = function(self)

    --player 1 targets
    local my_targets = self.tab.player.targets
    local target_pool = {}
    for target_name, amount in pairs(my_targets) do
        target_pool [#target_pool+1] = {target_name, amount}
    end
    table.sort (target_pool, Details.Sort2)

    FauxScrollFrame_Update (self, #target_pool, targetBars, 14)
    self:Show()

    fill_compare_targets (self, self.tab.player, self.tab.players, target_pool)
end

local compare_fill = function(tab, player, combat)
    local players_to_compare = tab.players

    local defaultPlayerName = Details:GetOnlyName(player:Name())
    DetailsPlayerComparisonBox1.name_label:SetText(defaultPlayerName)

    local label2 = _G ["DetailsPlayerComparisonBox2"].name_label
    local label3 = _G ["DetailsPlayerComparisonBox3"].name_label

    local label2_percent = _G ["DetailsPlayerComparisonBox2"].name_label_percent
    local label3_percent = _G ["DetailsPlayerComparisonBox3"].name_label_percent

    if (players_to_compare [1]) then
        local playerName = Details:GetOnlyName(players_to_compare [1]:Name())
        label2:SetText(playerName)
        label2_percent:SetText(defaultPlayerName .. " %")
    else
        label2:SetText("")
        label2_percent:SetText("")
    end
    if (players_to_compare [2]) then
        local playerName = Details:GetOnlyName(players_to_compare [2]:Name())
        label3:SetText(playerName)
        label3_percent:SetText(defaultPlayerName .. " %")
    else
        label3:SetText("")
        label3_percent:SetText("")
    end

    refresh_comparison_box (DetailsPlayerComparisonBox1)
    refresh_target_box (DetailsPlayerComparisonTarget1)

end

local on_enter_target = function(self)
    local frame1 = DetailsPlayerComparisonTarget1
    local frame2 = DetailsPlayerComparisonTarget2
    local frame3 = DetailsPlayerComparisonTarget3

    local bar1 = frame1.bars [self.index]
    local bar2 = frame2.bars [self.index]
    local bar3 = frame3.bars [self.index]

    local player_1 = bar1 [3] [4]
    if (not player_1) then
        return
    end
    local player_2 = bar2 [3] [4]
    local player_3 = bar3 [3] [4]

    local target_name = bar1 [3] [2]

    frame1.tooltip:SetPoint("bottomleft", bar1[2], "topleft", -18, 5)
    frame2.tooltip:SetPoint("bottomleft", bar2[2], "topleft", -18, 5)
    frame3.tooltip:SetPoint("bottomleft", bar3[2], "topleft", -18, 5)

    -- player 1
    local player_1_skills = {}
    for spellid, spell in pairs(player_1.spells._ActorTable) do
        for name, amount in pairs(spell.targets) do
            if (name == target_name) then
                player_1_skills [#player_1_skills+1] = {spellid, amount}
            end
        end
    end
    table.sort (player_1_skills, Details.Sort2)
-- ~pet
    local player_1_top = player_1_skills [1] and player_1_skills [1][2] or 0
    bar1 [2]:SetStatusBarColor(1, 1, 1, 1)

    -- player 2
    local player_2_skills = {}
    local player_2_top
    if (player_2) then
        for spellid, spell in pairs(player_2.spells._ActorTable) do
            for name, amount in pairs(spell.targets) do
                if (name == target_name) then
                    player_2_skills [#player_2_skills+1] = {spellid, amount}
                end
            end
        end
        table.sort (player_2_skills, Details.Sort2)
        player_2_top = player_2_skills [1] and player_2_skills [1][2] or 0
        bar2 [2]:SetStatusBarColor(unpack(bar_color_on_enter))
    end

    -- player 3
    local player_3_skills = {}
    local player_3_top
    if (player_3) then
        for spellid, spell in pairs(player_3.spells._ActorTable) do
            for name, amount in pairs(spell.targets) do
                if (name == target_name) then
                    player_3_skills [#player_3_skills+1] = {spellid, amount}
                end
            end
        end
        table.sort (player_3_skills, Details.Sort2)
        player_3_top = player_3_skills [1] and player_3_skills [1][2] or 0
        bar3 [2]:SetStatusBarColor(unpack(bar_color_on_enter))
    end

    -- build tooltip
    frame1.tooltip:Reset()
    frame2.tooltip:Reset()
    frame3.tooltip:Reset()

    frame1.tooltip:Show()
    frame2.tooltip:Show()
    frame3.tooltip:Show()

    local frame2_gotresults = false
    local frame3_gotresults = false

    for index, spell in ipairs(player_1_skills) do
        local bar = frame1.tooltip.bars [index]
        if (not bar) then
            bar = frame1.tooltip:CreateBar()
        end

        local name, _, icon = _GetSpellInfo(spell[1])
        bar [1]:SetTexture(icon)
        bar [1]:SetTexCoord(unpack(IconTexCoord)) --bar[1] = spellicon bar[2] = statusbar
        bar [2].lefttext:SetText(index .. ". " .. name)
        bar [2].righttext:SetText(Details:ToK2Min (spell [2]))
        bar [2]:SetValue(spell [2]/player_1_top*100)
        --bar [2]:SetValue(100)
        bar [2].bg:Show()

        if (player_2) then

            local player_2_skill
            local found_skill = false
            for this_index, this_spell in ipairs(player_2_skills) do
                if (spell [1] == this_spell[1]) then
                    local bar = frame2.tooltip.bars [index]
                    if (not bar) then
                        bar = frame2.tooltip:CreateBar (index)
                    end

                    bar [1]:SetTexture(icon)
                    bar [1]:SetTexCoord(unpack(IconTexCoord)) --bar[1] = spellicon bar[2] = statusbar
                    bar [2].lefttext:SetText(this_index .. ". " .. name)
                    bar [2].bg:Show()

                    if (spell [2] > this_spell [2]) then
                        local diff = spell [2] - this_spell [2]
                        local up = diff / this_spell [2] * 100
                        up = math.floor(up)
                        if (up > 999) then
                            up = "" .. 999
                        end
                        bar [2].righttext2:SetText(Details:ToK2Min (this_spell [2]))
                        bar [2].righttext:SetText(" |c" .. minor .. up .. "%|r")
                    else
                        local diff = this_spell [2] - spell [2]
                        local down = diff / spell [2] * 100
                        down = math.floor(down)
                        if (down > 999) then
                            down = "" .. 999
                        end
                        bar [2].righttext2:SetText(Details:ToK2Min (this_spell [2]))
                        bar [2].righttext:SetText(" |c" .. plus .. down .. "%|r")
                    end

                    --bar [2]:SetValue(this_spell [2]/player_2_top*100)
                    bar [2]:SetValue(100)
                    found_skill = true
                    frame2_gotresults = true
                    break
                end
            end
            if (not found_skill) then
                local bar = frame2.tooltip.bars [index]
                if (not bar) then
                    bar = frame2.tooltip:CreateBar (index)
                end
                bar [1]:SetTexture("")
                bar [2].lefttext:SetText("")
                bar [2].righttext:SetText("")
                bar [2].righttext2:SetText("")
                bar [2].bg:Hide()
            end
        end

        if (player_3) then
            local player_3_skill
            local found_skill = false
            for this_index, this_spell in ipairs(player_3_skills) do
                if (spell [1] == this_spell[1]) then
                    local bar = frame3.tooltip.bars [index]
                    if (not bar) then
                        bar = frame3.tooltip:CreateBar (index)
                    end

                    bar [1]:SetTexture(icon)
                    bar [1]:SetTexCoord(unpack(IconTexCoord)) --bar[1] = spellicon bar[2] = statusbar
                    bar [2].lefttext:SetText(this_index .. ". " .. name)
                    bar [2].bg:Show()

                    if (spell [2] > this_spell [2]) then
                        local diff = spell [2] - this_spell [2]
                        local up = diff / this_spell [2] * 100
                        up = math.floor(up)
                        if (up > 999) then
                            up = "" .. 999
                        end
                        bar [2].righttext:SetText(Details:ToK2Min (this_spell [2]) .. " |c" .. minor .. up .. "%|r")
                    else
                        local diff = this_spell [2] - spell [2]
                        local down = diff / spell [2] * 100
                        down = math.floor(down)
                        if (down > 999) then
                            down = "" .. 999
                        end
                        bar [2].righttext2:SetText(Details:ToK2Min (this_spell [2]))
                        bar [2].righttext:SetText(" |c" .. plus .. down .. "%|r")
                    end

                    --bar [2]:SetValue(this_spell [2]/player_3_top*100)
                    bar [2]:SetValue(100)
                    found_skill = true
                    frame3_gotresults = true
                    break
                end
            end
            if (not found_skill) then
                local bar = frame3.tooltip.bars [index]
                if (not bar) then
                    bar = frame3.tooltip:CreateBar (index)
                end
                bar [1]:SetTexture("")
                bar [2].lefttext:SetText("")
                bar [2].righttext:SetText("")
                bar [2].righttext2:SetText("")
                bar [2].bg:Hide()
            end
        end

    end

    frame1.tooltip:SetHeight( (#player_1_skills*15) + 2)
    frame2.tooltip:SetHeight( (#player_1_skills*15) + 2)
    frame3.tooltip:SetHeight( (#player_1_skills*15) + 2)

    if (not frame2_gotresults) then
        frame2.tooltip:Hide()
    end
    if (not frame3_gotresults) then
        frame3.tooltip:Hide()
    end

end

local on_leave_target = function(self)
    local frame1 = DetailsPlayerComparisonTarget1
    local frame2 = DetailsPlayerComparisonTarget2
    local frame3 = DetailsPlayerComparisonTarget3

    local bar1 = frame1.bars [self.index]
    local bar2 = frame2.bars [self.index]
    local bar3 = frame3.bars [self.index]

    bar1[2]:SetStatusBarColor(.5, .5, .5, 1)
    bar1[2].icon:SetTexCoord(0, 1, 0, 1)
    bar2[2]:SetStatusBarColor(unpack(bar_color))
    bar2[2].icon:SetTexCoord(0, 1, 0, 1)
    bar3[2]:SetStatusBarColor(unpack(bar_color))
    bar3[2].icon:SetTexCoord(0, 1, 0, 1)

    frame1.tooltip:Hide()
    frame2.tooltip:Hide()
    frame3.tooltip:Hide()
end

local on_enter = function(self)

    local frame1 = DetailsPlayerComparisonBox1
    local frame2 = DetailsPlayerComparisonBox2
    local frame3 = DetailsPlayerComparisonBox3

    local bar1 = frame1.bars [self.index]
    local bar2 = frame2.bars [self.index]
    local bar3 = frame3.bars [self.index]

    frame1.tooltip:SetPoint("bottomleft", bar1[2], "topleft", -18, 5)
    frame2.tooltip:SetPoint("bottomleft", bar2[2], "topleft", -18, 5)
    frame3.tooltip:SetPoint("bottomleft", bar3[2], "topleft", -18, 5)

    local spellid = bar1[3][4]

    --these are player names
    local player1 = frame1.player
    local player2 = frame2.player
    local player3 = frame3.player

    local hits = bar1[3][1]
    local average = bar1[3][2]
    local critical = bar1[3][3]

    ---@type combat
    local combatObject = breakdownWindowFrame.instancia.showing

    local player1_misc = combatObject(4, player1)
    local player2_misc = combatObject(4, player2)
    local player3_misc = combatObject(4, player3)

    local player1_uptime
    local player1_casts

    local COMPARE_FIRSTPLAYER_PERCENT = "100%"
    local COMPARE_UNKNOWNDATA = "-"

    if (bar1[2].righttext:GetText()) then
        bar1[2]:SetStatusBarColor(1, 1, 1, 1)
        bar1[2].icon:SetTexCoord(.1, .9, .1, .9)

        frame1.tooltip.hits_label3:SetText(hits)
        frame1.tooltip.average_label3:SetText(Details:ToK2Min (average))
        frame1.tooltip.crit_label3:SetText(critical .. "%")

        --2 = far left text (percent comparison)
        --3 = total in numbers

        Details.gump:SetFontColor(frame1.tooltip.hits_label2, "gray")
        Details.gump:SetFontColor(frame1.tooltip.average_label2, "gray")
        Details.gump:SetFontColor(frame1.tooltip.crit_label2, "gray")
        Details.gump:SetFontColor(frame1.tooltip.casts_label2, "gray")
        Details.gump:SetFontColor(frame1.tooltip.uptime_label2, "gray")

        frame1.tooltip.hits_label2:SetText(COMPARE_FIRSTPLAYER_PERCENT)
        frame1.tooltip.average_label2:SetText(COMPARE_FIRSTPLAYER_PERCENT)
        frame1.tooltip.crit_label2:SetText(COMPARE_FIRSTPLAYER_PERCENT)

        if (player1_misc) then
            --uptime
            local spell = player1_misc.debuff_uptime_spells and player1_misc.debuff_uptime_spells._ActorTable and player1_misc.debuff_uptime_spells._ActorTable [spellid]
            if (spell) then
                local minutos, segundos = math.floor(spell.uptime/60), math.floor(spell.uptime%60)
                player1_uptime = spell.uptime
                frame1.tooltip.uptime_label3:SetText(minutos .. "m" .. segundos .. "s")
                frame1.tooltip.uptime_label2:SetText(COMPARE_FIRSTPLAYER_PERCENT)
                Details.gump:SetFontColor(frame1.tooltip.uptime_label2, "gray")
                Details.gump:SetFontColor(frame1.tooltip.uptime_label3, "white")
            else
                frame1.tooltip.uptime_label3:SetText(COMPARE_UNKNOWNDATA)
                frame1.tooltip.uptime_label2:SetText(COMPARE_UNKNOWNDATA)
                Details.gump:SetFontColor(frame1.tooltip.uptime_label2, "gray")
                Details.gump:SetFontColor(frame1.tooltip.uptime_label3, "gray")
            end

            --total casts
            local amountOfCasts = combatObject:GetSpellCastAmount(player1, GetSpellInfo(spellid))
            if (amountOfCasts) then
                frame1.tooltip.casts_label3:SetText(amountOfCasts)
                frame1.tooltip.casts_label2:SetText(COMPARE_FIRSTPLAYER_PERCENT)

                Details.gump:SetFontColor(frame1.tooltip.casts_label3, "white")

                player1_casts = amountOfCasts
            else
                frame1.tooltip.casts_label3:SetText("?")
                frame1.tooltip.casts_label2:SetText("?")

                Details.gump:SetFontColor(frame1.tooltip.casts_label3, "silver")
                Details.gump:SetFontColor(frame1.tooltip.casts_label2, "silver")
            end
        else
            frame1.tooltip.uptime_label3:SetText(COMPARE_UNKNOWNDATA)
            frame1.tooltip.uptime_label2:SetText(COMPARE_UNKNOWNDATA)
            Details.gump:SetFontColor(frame1.tooltip.uptime_label2, "gray")
            Details.gump:SetFontColor(frame1.tooltip.uptime_label3, "gray")

            frame1.tooltip.casts_label3:SetText("?")
            frame1.tooltip.casts_label2:SetText("?")
            Details.gump:SetFontColor(frame1.tooltip.casts_label3, "gray")
            Details.gump:SetFontColor(frame1.tooltip.casts_label2, "gray")
        end

        frame1.tooltip:Show()
    end

    if (bar2[2].righttext:GetText()) then

        bar2 [2]:SetStatusBarColor(unpack(bar_color_on_enter))
        bar2[2].icon:SetTexCoord(.1, .9, .1, .9)

        -- hits
        if (hits > bar2[3][1]) then
            local diff = hits - bar2[3][1]
            local up = diff / bar2[3][1] * 100
            up = math.floor(up)
            if (up > 999) then
                up = "" .. 999
            end
            frame2.tooltip.hits_label3:SetText(bar2[3][1])
            frame2.tooltip.hits_label2:SetText(" |c" .. minor .. up .. "%|r")
        else
            local diff = bar2[3][1] - hits
            local down = diff / hits * 100
            down = math.floor(down)
            if (down > 999) then
                down = "" .. 999
            end
            frame2.tooltip.hits_label3:SetText(bar2[3][1])
            frame2.tooltip.hits_label2:SetText(" |c" .. plus .. down .. "%|r")
        end

        --average
        if (average > bar2[3][2]) then
            local diff = average - bar2[3][2]
            local up = diff / bar2[3][2] * 100
            up = math.floor(up)
            if (up > 999) then
                up = "" .. 999
            end
            frame2.tooltip.average_label3:SetText(Details:ToK2Min (bar2[3][2]))
            frame2.tooltip.average_label2:SetText(" |c" .. minor .. up .. "%|r")
        else
            local diff = bar2[3][2] - average
            local down = diff / average * 100
            down = math.floor(down)
            if (down > 999) then
                down = "" .. 999
            end
            frame2.tooltip.average_label3:SetText(Details:ToK2Min (bar2[3][2]))
            frame2.tooltip.average_label2:SetText(" |c" .. plus .. down .. "%|r")
        end

        --criticals
        if (critical > bar2[3][3]) then
            --[[
            local percent = abs((bar2[3][3] / critical * 100) -100)
            percent = math.floor(percent)
            if (percent > 999) then
                up = "" .. 999
            end
            frame2.tooltip.crit_label3:SetText(bar2[3][3] .. "%")
            frame2.tooltip.crit_label2:SetText(" |c" .. minor .. percent .. "%|r")
            --]]
            local diff = critical - bar2[3][3]
            diff = diff / bar2[3][3] * 100
            diff = math.floor(diff)
            if (diff > 999) then
                diff = "" .. 999
            end
            frame2.tooltip.crit_label3:SetText(bar2[3][3] .. "%")
            frame2.tooltip.crit_label2:SetText(" |c" .. minor .. diff .. "%|r")
        else
            local diff = bar2[3][3] - critical
            local down = diff / math.max(critical, 0.1) * 100
            --bar2[3][3] = 62 critical = 53 diff = 9
            --print(diff, bar2[3][3], critical)
            --print(math.max(critical * 100, 0.1))

            down = math.floor(down)
            if (down > 999) then
                down = "" .. 999
            end
            frame2.tooltip.crit_label3:SetText(bar2[3][3] .. "%")
            frame2.tooltip.crit_label2:SetText(" |c" .. plus .. down .. "%|r")
        end

        --update and total casts
        if (player2_misc) then

            --uptime
            local spell = player2_misc.debuff_uptime_spells and player2_misc.debuff_uptime_spells._ActorTable and player2_misc.debuff_uptime_spells._ActorTable [spellid]
            if (spell and spell.uptime) then
                local minutos, segundos = math.floor(spell.uptime/60), math.floor(spell.uptime%60)

                if (not player1_uptime) then
                    frame2.tooltip.uptime_label3:SetText(minutos .. "m" .. segundos .. "s")
                    frame2.tooltip.uptime_label2:SetText("0%|r")

                elseif (player1_uptime > spell.uptime) then
                    local diff = player1_uptime - spell.uptime
                    local up = diff / spell.uptime * 100
                    up = math.floor(up)
                    if (up > 999) then
                        up = "" .. 999
                    end
                    frame2.tooltip.uptime_label3:SetText(minutos .. "m" .. segundos .. "s")
                    frame2.tooltip.uptime_label2:SetText("|c" .. minor .. up .. "%|r")
                else
                    local diff = spell.uptime - player1_uptime
                    local down = diff / player1_uptime * 100
                    down = math.floor(down)
                    if (down > 999) then
                        down = "" .. 999
                    end
                    frame2.tooltip.uptime_label3:SetText(minutos .. "m" .. segundos .. "s")
                    frame2.tooltip.uptime_label2:SetText("|c" .. plus .. down .. "%|r")
                end

                Details.gump:SetFontColor(frame2.tooltip.uptime_label3, "white")
                Details.gump:SetFontColor(frame2.tooltip.uptime_label2, "white")

            else
                frame2.tooltip.uptime_label3:SetText(COMPARE_UNKNOWNDATA)
                frame2.tooltip.uptime_label2:SetText(COMPARE_UNKNOWNDATA)
                Details.gump:SetFontColor(frame2.tooltip.uptime_label3, "gray")
                Details.gump:SetFontColor(frame2.tooltip.uptime_label2, "gray")
            end

            --total casts
            local amt_casts = combatObject:GetSpellCastAmount(player2_misc:Name(), GetSpellInfo(spellid))

            if (amt_casts) then
                if (not player1_casts) then
                    frame2.tooltip.casts_label3:SetText(amt_casts)
                    frame2.tooltip.casts_label2:SetText(COMPARE_UNKNOWNDATA)

                elseif (player1_casts > amt_casts) then
                    local diff = player1_casts - amt_casts
                    local up = diff / amt_casts * 100
                    up = math.floor(up)
                    if (up > 999) then
                        up = "" .. 999
                    end
                    frame2.tooltip.casts_label3:SetText(amt_casts)
                    frame2.tooltip.casts_label2:SetText("|c" .. minor .. up .. "%|r")
                else
                    local diff = amt_casts - player1_casts
                    local down = diff / player1_casts * 100
                    down = math.floor(down)
                    if (down > 999) then
                        down = "" .. 999
                    end
                    frame2.tooltip.casts_label3:SetText(amt_casts)
                    frame2.tooltip.casts_label2:SetText("|c" .. plus .. down .. "%|r")
                end

                Details.gump:SetFontColor(frame2.tooltip.casts_label3, "white")
                Details.gump:SetFontColor(frame2.tooltip.casts_label2, "white")
            else
                frame2.tooltip.casts_label2:SetText("?")
                frame2.tooltip.casts_label3:SetText("?")
                Details.gump:SetFontColor(frame2.tooltip.casts_label3, "gray")
                Details.gump:SetFontColor(frame2.tooltip.casts_label2, "gray")
            end
        else
            frame2.tooltip.casts_label2:SetText(COMPARE_UNKNOWNDATA)
            frame2.tooltip.casts_label2:SetText(COMPARE_UNKNOWNDATA)
            frame2.tooltip.uptime_label3:SetText(COMPARE_UNKNOWNDATA)
            frame2.tooltip.uptime_label2:SetText(COMPARE_UNKNOWNDATA)
        end

        frame2.tooltip:Show()
    end

    ---------------------------------------------------

    if (bar3[2].righttext:GetText()) then
        bar3 [2]:SetStatusBarColor(unpack(bar_color_on_enter))
        bar3[2].icon:SetTexCoord(.1, .9, .1, .9)

        --hits
        if (hits > bar3[3][1]) then
            local diff = hits - bar3[3][1]
            local up = diff / bar3[3][1] * 100
            up = math.floor(up)
            if (up > 999) then
                up = "" .. 999
            end
            frame3.tooltip.hits_label3:SetText(bar3[3][1])
            frame3.tooltip.hits_label2:SetText(" |c" .. minor .. up .. "%|r")
        else
            local diff = bar3[3][1] - hits
            local down = diff / hits * 100
            down = math.floor(down)
            if (down > 999) then
                down = "" .. 999
            end
            frame3.tooltip.hits_label3:SetText(bar3[3][1])
            frame3.tooltip.hits_label2:SetText(" |c" .. plus .. down .. "%|r")
        end

        --average
        if (average > bar3[3][2]) then
            local diff = average - bar3[3][2]
            local up = diff / bar3[3][2] * 100
            up = math.floor(up)
            if (up > 999) then
                up = "" .. 999
            end
            frame3.tooltip.average_label3:SetText(Details:ToK2Min (bar3[3][2]))
            frame3.tooltip.average_label2:SetText(" |c" .. minor .. up .. "%|r")
        else
            local diff = bar3[3][2] - average
            local down = diff / average * 100
            down = math.floor(down)
            if (down > 999) then
                down = "" .. 999
            end
            frame3.tooltip.average_label3:SetText(Details:ToK2Min (bar3[3][2]))
            frame3.tooltip.average_label2:SetText(" |c" .. plus .. down .. "%|r")
        end

        --critical
        if (critical > bar3[3][3]) then
            local diff = critical - bar3[3][3]
            diff = diff / bar3[3][3] * 100
            diff = math.floor(diff)
            if (diff > 999) then
                diff = "" .. 999
            end
            frame3.tooltip.crit_label3:SetText(bar3[3][3] .. "%")
            frame3.tooltip.crit_label2:SetText(" |c" .. minor .. diff .. "%|r")
        else
            local diff = bar3[3][3] - critical
            local down = diff / math.max(critical, 0.1) * 100
            down = math.floor(down)
            if (down > 999) then
                down = "" .. 999
            end
            frame3.tooltip.crit_label3:SetText(bar3[3][3] .. "%")
            frame3.tooltip.crit_label2:SetText(" |c" .. plus .. down .. "%|r")
        end

        --uptime and casts
        if (player3_misc) then

            --uptime
            local spell = player3_misc.debuff_uptime_spells and player3_misc.debuff_uptime_spells._ActorTable and player3_misc.debuff_uptime_spells._ActorTable [spellid]
            if (spell and spell.uptime) then
                local minutos, segundos = math.floor(spell.uptime/60), math.floor(spell.uptime%60)

                if (not player1_uptime) then
                    frame3.tooltip.uptime_label3:SetText(minutos .. "m" .. segundos .. "s")
                    frame3.tooltip.uptime_label2:SetText("0%|r")

                elseif (player1_uptime > spell.uptime) then
                    local diff = player1_uptime - spell.uptime
                    local up = diff / spell.uptime * 100
                    up = math.floor(up)
                    if (up > 999) then
                        up = "" .. 999
                    end
                    frame3.tooltip.uptime_label3:SetText(minutos .. "m" .. segundos .. "s")
                    frame3.tooltip.uptime_label2:SetText("|c" .. minor .. up .. "%|r")
                else
                    local diff = spell.uptime - player1_uptime
                    local down = diff / player1_uptime * 100
                    down = math.floor(down)
                    if (down > 999) then
                        down = "" .. 999
                    end
                    frame3.tooltip.uptime_label3:SetText(minutos .. "m" .. segundos .. "s")
                    frame3.tooltip.uptime_label2:SetText("|c" .. plus .. down .. "%|r")
                end

                Details.gump:SetFontColor(frame3.tooltip.uptime_label3, "white")
                Details.gump:SetFontColor(frame3.tooltip.uptime_label2, "white")
            else
                frame3.tooltip.uptime_label3:SetText(COMPARE_UNKNOWNDATA)
                frame3.tooltip.uptime_label2:SetText(COMPARE_UNKNOWNDATA)
                Details.gump:SetFontColor(frame3.tooltip.uptime_label3, "gray")
                Details.gump:SetFontColor(frame3.tooltip.uptime_label2, "gray")
            end

            --total casts
            local amt_casts = combatObject:GetSpellCastAmount(player3_misc:Name(), GetSpellInfo(spellid))

            if (amt_casts) then

                if (not player1_casts) then
                    frame3.tooltip.casts_label2:SetText(amt_casts)
                elseif (player1_casts > amt_casts) then
                    local diff = player1_casts - amt_casts
                    local up = diff / amt_casts * 100
                    up = math.floor(up)
                    if (up > 999) then
                        up = "" .. 999
                    end
                    frame3.tooltip.casts_label3:SetText(amt_casts)
                    frame3.tooltip.casts_label2:SetText(" |c" .. minor .. up .. "%|r")
                else
                    local diff = amt_casts - player1_casts
                    local down = diff / player1_casts * 100
                    down = math.floor(down)
                    if (down > 999) then
                        down = "" .. 999
                    end
                    frame3.tooltip.casts_label3:SetText(amt_casts)
                    frame3.tooltip.casts_label2:SetText(" |c" .. plus .. down .. "%|r")
                end

                Details.gump:SetFontColor(frame3.tooltip.casts_label3, "white")
                Details.gump:SetFontColor(frame3.tooltip.casts_label2, "white")
            else
                frame3.tooltip.casts_label2:SetText("?")
                frame3.tooltip.casts_label3:SetText("?")
                Details.gump:SetFontColor(frame3.tooltip.casts_label3, "gray")
                Details.gump:SetFontColor(frame3.tooltip.casts_label2, "gray")
            end

        else
            frame3.tooltip.casts_label3:SetText(COMPARE_UNKNOWNDATA)
            frame3.tooltip.casts_label2:SetText(COMPARE_UNKNOWNDATA)
            frame3.tooltip.uptime_label3:SetText(COMPARE_UNKNOWNDATA)
            frame3.tooltip.uptime_label2:SetText(COMPARE_UNKNOWNDATA)
        end

        frame3.tooltip:Show()
    end
end

local on_leave = function(self)
    local frame1 = DetailsPlayerComparisonBox1
    local frame2 = DetailsPlayerComparisonBox2
    local frame3 = DetailsPlayerComparisonBox3

    local bar1 = frame1.bars [self.index]
    local bar2 = frame2.bars [self.index]
    local bar3 = frame3.bars [self.index]

    bar1[2]:SetStatusBarColor(.5, .5, .5, 1)
    bar1[2].icon:SetTexCoord(0, 1, 0, 1)
    bar2[2]:SetStatusBarColor(unpack(bar_color))
    bar2[2].icon:SetTexCoord(0, 1, 0, 1)
    bar3[2]:SetStatusBarColor(unpack(bar_color))
    bar3[2].icon:SetTexCoord(0, 1, 0, 1)

    frame1.tooltip:Hide()
    frame2.tooltip:Hide()
    frame3.tooltip:Hide()
end

local compare_create = function(tab, frame)

    local create_bar = function(name, parent, index, main, is_target)
        local y = ((index-1) * -15) - 7

        local spellicon = parent:CreateTexture(nil, "overlay")
        spellicon:SetSize(14, 14)
        spellicon:SetPoint("topleft", parent, "topleft", 4, y)
        spellicon:SetTexture([[Interface\InventoryItems\WoWUnknownItem01]])

        local bar = CreateFrame("StatusBar", name, parent,"BackdropTemplate")
        bar.index = index
        bar:SetPoint("topleft", spellicon, "topright", 0, 0)
        bar:SetPoint("topright", parent, "topright", -4, y)
        bar:SetStatusBarTexture([[Interface\AddOns\Details\images\bar_serenity]])
        bar:SetStatusBarColor(.5, .5, .5, 1)
        bar:SetAlpha(ALPHA_BLEND_AMOUNT)

        bar:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        bar:SetBackdropColor(1, 1, 1, 0.1)

        bar:SetMinMaxValues(0, 100)
        bar:SetValue(100)
        bar:SetHeight(14)
        bar.icon = spellicon

        if (is_target) then
            bar:SetScript("OnEnter", on_enter_target)
            bar:SetScript("OnLeave", on_leave_target)
        else
            bar:SetScript("OnEnter", on_enter)
            bar:SetScript("OnLeave", on_leave)
        end

        bar.lefttext = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

        local _, size, flags = bar.lefttext:GetFont()
        local font = SharedMedia:Fetch ("font", "Arial Narrow")
        bar.lefttext:SetFont(font, 11)

        bar.lefttext:SetPoint("left", bar, "left", 4, 0)
        bar.lefttext:SetJustifyH("left")
        bar.lefttext:SetTextColor(1, 1, 1, 1)
        bar.lefttext:SetNonSpaceWrap (true)
        bar.lefttext:SetWordWrap (false)
        if (main) then
            bar.lefttext:SetWidth(180)
        else
            bar.lefttext:SetWidth(110)
        end

        bar.righttext = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

        local _, size, flags = bar.righttext:GetFont()
        local font = SharedMedia:Fetch ("font", "Arial Narrow")
        bar.righttext:SetFont(font, 11)

        bar.righttext:SetPoint("right", bar, "right", -2, 0)
        bar.righttext:SetJustifyH("right")
        bar.righttext:SetTextColor(1, 1, 1, 1)

        bar.righttext2 = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

        local _, size, flags = bar.righttext2:GetFont()
        local font = SharedMedia:Fetch ("font", "Arial Narrow")
        bar.righttext2:SetFont(font, 11)

        bar.righttext2:SetPoint("right", bar, "right", -42, 0)
        bar.righttext2:SetJustifyH("right")
        bar.righttext2:SetTextColor(1, 1, 1, 1)

        table.insert(parent.bars, {spellicon, bar, {0, 0, 0}})
    end

    local create_tooltip = function(name)
        local tooltip = CreateFrame("frame", name, UIParent,"BackdropTemplate")

        Details.gump:CreateBorder (tooltip)

        tooltip:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
        tooltip:SetBackdropColor(0, 0, 0, 1)
        tooltip:SetBackdropBorderColor(0, 0, 0, 1)
        tooltip:SetSize(275, 77)
        tooltip:SetFrameStrata("tooltip")

        local y = -3
        local x_start = 2

        local background = tooltip:CreateTexture(nil, "border")
        background:SetTexture([[Interface\SPELLBOOK\Spellbook-Page-1]])
        background:SetTexCoord(.6, 0.1, 0, 0.64453125)
        background:SetVertexColor(0, 0, 0, 0.2)
        background:SetPoint("topleft", tooltip, "topleft", 0, 0)
        background:SetPoint("bottomright", tooltip, "bottomright", 0, 0)

        tooltip.casts_label = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.casts_label:SetPoint("topleft", tooltip, "topleft", x_start, -2 + (y*0))
        tooltip.casts_label:SetText("Total Casts:")
        tooltip.casts_label:SetJustifyH("left")
        tooltip.casts_label2 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.casts_label2:SetPoint("topright", tooltip, "topright", -x_start, -2 + (y*0))
        tooltip.casts_label2:SetText("0")
        tooltip.casts_label2:SetJustifyH("right")
        tooltip.casts_label3 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.casts_label3:SetPoint("topright", tooltip, "topright", -x_start - 46, -2 + (y*0))
        tooltip.casts_label3:SetText("0")
        tooltip.casts_label3:SetJustifyH("right")

        tooltip.hits_label = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.hits_label:SetPoint("topleft", tooltip, "topleft", x_start, -14 + (y*1))
        tooltip.hits_label:SetText("Total Hits:")
        tooltip.hits_label:SetJustifyH("left")
        tooltip.hits_label2 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.hits_label2:SetPoint("topright", tooltip, "topright", -x_start, -14 + (y*1))
        tooltip.hits_label2:SetText("0")
        tooltip.hits_label2:SetJustifyH("right")
        tooltip.hits_label3 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.hits_label3:SetPoint("topright", tooltip, "topright", -x_start - 46, -14 + (y*1))
        tooltip.hits_label3:SetText("0")
        tooltip.hits_label3:SetJustifyH("right")

        tooltip.average_label = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.average_label:SetPoint("topleft", tooltip, "topleft", x_start, -26 + (y*2))
        tooltip.average_label:SetText("Average:")
        tooltip.average_label:SetJustifyH("left")
        tooltip.average_label2 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.average_label2:SetPoint("topright", tooltip, "topright", -x_start, -26 + (y*2))
        tooltip.average_label2:SetText("0")
        tooltip.average_label2:SetJustifyH("right")
        tooltip.average_label3 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.average_label3:SetPoint("topright", tooltip, "topright", -x_start - 46, -26 + (y*2))
        tooltip.average_label3:SetText("0")
        tooltip.average_label3:SetJustifyH("right")

        tooltip.crit_label = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.crit_label:SetPoint("topleft", tooltip, "topleft", x_start, -38 + (y*3))
        tooltip.crit_label:SetText("Critical:")
        tooltip.crit_label:SetJustifyH("left")
        tooltip.crit_label2 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.crit_label2:SetPoint("topright", tooltip, "topright", -x_start, -38 + (y*3))
        tooltip.crit_label2:SetText("0")
        tooltip.crit_label2:SetJustifyH("right")
        tooltip.crit_label3 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.crit_label3:SetPoint("topright", tooltip, "topright", -x_start - 46, -38 + (y*3))
        tooltip.crit_label3:SetText("0")
        tooltip.crit_label3:SetJustifyH("right")

        tooltip.uptime_label = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.uptime_label:SetPoint("topleft", tooltip, "topleft", x_start, -50 + (y*4))
        tooltip.uptime_label:SetText("Uptime:")
        tooltip.uptime_label:SetJustifyH("left")
        tooltip.uptime_label2 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.uptime_label2:SetPoint("topright", tooltip, "topright", -x_start, -50 + (y*4))
        tooltip.uptime_label2:SetText("0")
        tooltip.uptime_label2:SetJustifyH("right")
        tooltip.uptime_label3 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
        tooltip.uptime_label3:SetPoint("topright", tooltip, "topright", -x_start - 46, -50 + (y*4))
        tooltip.uptime_label3:SetText("0")
        tooltip.uptime_label3:SetJustifyH("right")

        local bg_color = {0.5, 0.5, 0.5}
        local bg_texture = [[Interface\AddOns\Details\images\bar_background]]
        local bg_alpha = 1
        local bg_height = 12
        local colors = {{26/255, 26/255, 26/255}, {19/255, 19/255, 19/255}, {26/255, 26/255, 26/255}, {34/255, 39/255, 42/255}, {42/255, 51/255, 60/255}}

        for i = 1, 5 do
            local bg_line1 = tooltip:CreateTexture(nil, "artwork")
            bg_line1:SetTexture(bg_texture)
            bg_line1:SetPoint("topleft", tooltip, "topleft", 0, -2 + (((i-1) * 12) * -1) + (y * (i-1)) + 2)
            bg_line1:SetPoint("topright", tooltip, "topright", -0, -2 + (((i-1) * 12) * -1)  + (y * (i-1)) + 2)
            bg_line1:SetHeight(bg_height + 4)
            bg_line1:SetAlpha(bg_alpha)
            bg_line1:SetVertexColor(unpack(colors[i]))
        end

        return tooltip
    end

    local create_tooltip_target = function(name)
        local tooltip = CreateFrame("frame", name, UIParent,"BackdropTemplate")
        tooltip:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
        tooltip:SetBackdropColor(0, 0, 0, 1)
        tooltip:SetBackdropBorderColor(0, 0, 0, 1)
        tooltip:SetSize(175, 67)
        tooltip:SetFrameStrata("tooltip")
        tooltip.bars = {}

        Details.gump:CreateBorder (tooltip)

        function tooltip:Reset()
            for index, bar in ipairs(tooltip.bars) do
                bar [1]:SetTexture("")
                bar [2].lefttext:SetText("")
                bar [2].righttext:SetText("")
                bar [2].righttext2:SetText("")
                bar [2]:SetValue(0)
                bar [2].bg:Hide()
            end
        end

        local bars_colors = {{19/255, 19/255, 19/255}, {26/255, 26/255, 26/255}}

        function tooltip:CreateBar(index)
            if (index) then
                if (index > #tooltip.bars+1) then
                    for i = #tooltip.bars+1, index-1 do
                        tooltip:CreateBar()
                    end
                end
            end

            local index = #tooltip.bars + 1
            local y = ((index-1) * -15) - 2
            local parent = tooltip

            local spellicon = parent:CreateTexture(nil, "overlay")
            spellicon:SetSize(14, 14)
            spellicon:SetPoint("topleft", parent, "topleft", 1, y)
            spellicon:SetTexture([[Interface\InventoryItems\WoWUnknownItem01]])

            local bar = CreateFrame("StatusBar", name .. "Bar" .. index, parent, "BackdropTemplate")
            bar.index = index
            bar:SetPoint("topleft", spellicon, "topright", 0, 0)
            bar:SetPoint("topright", parent, "topright", -1, y)
            bar:SetStatusBarTexture([[Interface\AddOns\Details\images\bar_serenity]])
            bar:SetStatusBarColor(unpack(bar_color))
            bar:SetMinMaxValues(0, 100)
            bar:SetValue(0)
            bar:SetHeight(14)
            bar.icon = spellicon

            bar.lefttext = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            local _, size, flags = bar.lefttext:GetFont()
            local font = SharedMedia:Fetch ("font", "Arial Narrow")
            bar.lefttext:SetFont(font, 11)
            bar.lefttext:SetPoint("left", bar, "left", 2, 0)
            bar.lefttext:SetJustifyH("left")
            bar.lefttext:SetTextColor(1, 1, 1, 1)
            bar.lefttext:SetNonSpaceWrap (true)
            bar.lefttext:SetWordWrap (false)

            if (name:find("1")) then
                bar.lefttext:SetWidth(110)
            else
                bar.lefttext:SetWidth(80)
            end

            bar.righttext = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            local _, size, flags = bar.righttext:GetFont()
            local font = SharedMedia:Fetch ("font", "Arial Narrow")
            bar.righttext:SetFont(font, 11)
            bar.righttext:SetPoint("right", bar, "right", -2, 0)
            bar.righttext:SetJustifyH("right")
            bar.righttext:SetTextColor(1, 1, 1, 1)

            bar.righttext2 = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            local _, size, flags = bar.righttext2:GetFont()
            local font = SharedMedia:Fetch ("font", "Arial Narrow")
            bar.righttext2:SetFont(font, 11)
            bar.righttext2:SetPoint("right", bar, "right", -46, 0)
            bar.righttext2:SetJustifyH("right")
            bar.righttext2:SetTextColor(1, 1, 1, 1)

            local bg_line1 = bar:CreateTexture(nil, "artwork")
            bg_line1:SetTexture([[Interface\AddOns\Details\images\bar_background]])
            bg_line1:SetAllPoints()
            bg_line1:SetAlpha(0.7)
            if (index % 2 == 0) then
                bg_line1:SetVertexColor(_unpack(bars_colors [2]))
            else
                bg_line1:SetVertexColor(_unpack(bars_colors [2]))
            end
            bar.bg = bg_line1

            local object = {spellicon, bar}
            table.insert(tooltip.bars, object)
            return object
        end

        local background = tooltip:CreateTexture(nil, "artwork")
        background:SetTexture([[Interface\SPELLBOOK\Spellbook-Page-1]])
        background:SetTexCoord(.6, 0.1, 0, 0.64453125)
        background:SetVertexColor(0, 0, 0, 0.6)
        background:SetPoint("topleft", tooltip, "topleft", 2, -4)
        background:SetPoint("bottomright", tooltip, "bottomright", -4, 2)

        return tooltip
    end

    local frame1 = CreateFrame("scrollframe", "DetailsPlayerComparisonBox1", frame, "FauxScrollFrameTemplate,BackdropTemplate")
    frame1:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll (self, offset, 14, refresh_comparison_box) end)
    frame1:SetSize(spell_compare_frame_width[1], spell_compare_frame_height)
    frame1:SetPoint("topleft", frame, "topleft", xLocation, yLocation)
    Details.gump:ReskinSlider(frame1)

    frame1:SetBackdrop(frame_backdrop)
    frame1:SetBackdropColor(unpack(frame_backdrop_color))
    frame1:SetBackdropBorderColor(unpack(frame_backdrop_border_color))

    --override backdrop settings and use the framework defaults
    Details.gump:ApplyStandardBackdrop(frame1)

    frame1.bars = {}
    frame1.tab = tab
    frame1.tooltip = create_tooltip ("DetailsPlayerComparisonBox1Tooltip")
    frame1.tooltip:SetWidth(spell_compare_frame_width[1])

    local playername1 = frame1:CreateFontString(nil, "overlay", "GameFontNormal")
    playername1:SetPoint("bottomleft", frame1, "topleft", 2, 0)
    playername1:SetText("Player 1")
    frame1.name_label = playername1

    --criar as barras do frame1
    for i = 1, 12 do
        create_bar ("DetailsPlayerComparisonBox1Bar"..i, frame1, i, true)
    end

    --cria o box dos targets
    local target1 = CreateFrame("scrollframe", "DetailsPlayerComparisonTarget1", frame, "FauxScrollFrameTemplate,BackdropTemplate")
    target1:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll (self, offset, 14, refresh_target_box) end)
    target1:SetSize(spell_compare_frame_width[1], target_compare_frame_height)
    target1:SetPoint("topleft", frame1, "bottomleft", 0, -10)
    Details.gump:ReskinSlider(target1)

    target1:SetBackdrop(frame_backdrop)
    target1:SetBackdropColor(unpack(frame_backdrop_color))
    target1:SetBackdropBorderColor(unpack(frame_backdrop_border_color))
    target1.bars = {}
    target1.tab = tab
    target1.tooltip = create_tooltip_target ("DetailsPlayerComparisonTarget1Tooltip")
    target1.tooltip:SetWidth(spell_compare_frame_width[1])

    --override backdrop settings and use the framework defaults
    Details.gump:ApplyStandardBackdrop(target1)

    --criar as barras do target1
    for i = 1, targetBars do
        create_bar ("DetailsPlayerComparisonTarget1Bar"..i, target1, i, true, true)
    end

--------------------------------------------

    local frame2 = CreateFrame("frame", "DetailsPlayerComparisonBox2", frame,"BackdropTemplate")
    local frame3 = CreateFrame("frame", "DetailsPlayerComparisonBox3", frame,"BackdropTemplate")

    frame2:SetPoint("topleft", frame1, "topright", 27, 0)
    frame2:SetSize(spell_compare_frame_width[2], spell_compare_frame_height)

    frame2:SetBackdrop(frame_backdrop)
    frame2:SetBackdropColor(unpack(frame_backdrop_color))
    frame2:SetBackdropBorderColor(unpack(frame_backdrop_border_color))

    --override backdrop settings and use the framework defaults
    Details.gump:ApplyStandardBackdrop(frame2)

    frame2.bars = {}
    frame2.tooltip = create_tooltip ("DetailsPlayerComparisonBox2Tooltip")
    frame2.tooltip:SetWidth(spell_compare_frame_width[2])

    local playername2 = frame2:CreateFontString(nil, "overlay", "GameFontNormal")
    playername2:SetPoint("bottomleft", frame2, "topleft", 2, 0)
    playername2:SetText("Player 2")
    frame2.name_label = playername2

    local playername2_percent = frame2:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
    playername2_percent:SetPoint("bottomright", frame2, "topright", -2, 0)
    playername2_percent:SetText("Player 1 %")
    playername2_percent:SetTextColor(.6, .6, .6)

    local noPLayersToShow = frame2:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
    noPLayersToShow:SetPoint("center")
    noPLayersToShow:SetText("There's no more players to compare (with the same class/spec)")
    noPLayersToShow:SetSize(spell_compare_frame_width[2] - 10, spell_compare_frame_height)
    noPLayersToShow:SetJustifyH("center")
    noPLayersToShow:SetJustifyV ("middle")
    Details.gump:SetFontSize(noPLayersToShow, 14)
    Details.gump:SetFontColor(noPLayersToShow, "gray")
    frame2.NoPLayersToShow = noPLayersToShow


    frame2.name_label_percent = playername2_percent

    --criar as barras do frame2
    for i = 1, 12 do
        create_bar ("DetailsPlayerComparisonBox2Bar"..i, frame2, i)
    end

    --cria o box dos targets
    local target2 = CreateFrame("frame", "DetailsPlayerComparisonTarget2", frame,"BackdropTemplate")
    target2:SetSize(spell_compare_frame_width[2], target_compare_frame_height)
    target2:SetPoint("topleft", frame2, "bottomleft", 0, -10)
    target2:SetBackdrop(frame_backdrop)
    target2:SetBackdropColor(unpack(frame_backdrop_color))
    target2:SetBackdropBorderColor(unpack(frame_backdrop_border_color))
    target2.bars = {}
    target2.tooltip = create_tooltip_target ("DetailsPlayerComparisonTarget2Tooltip")
    target2.tooltip:SetWidth(spell_compare_frame_width[2])

    --override backdrop settings and use the framework defaults
    Details.gump:ApplyStandardBackdrop(target2)

    --criar as barras do target2
    for i = 1, targetBars do
        create_bar ("DetailsPlayerComparisonTarget2Bar"..i, target2, i, nil, true)
    end

-----------------------------------------------------------------------

    frame3:SetPoint("topleft", frame2, "topright", 5, 0)
    frame3:SetSize(spell_compare_frame_width[3], spell_compare_frame_height)
    frame3:SetBackdrop(frame_backdrop)
    frame3:SetBackdropColor(unpack(frame_backdrop_color))
    frame3:SetBackdropBorderColor(unpack(frame_backdrop_border_color))

    --override backdrop settings and use the framework defaults
    Details.gump:ApplyStandardBackdrop(frame3)

    frame3.bars = {}
    frame3.tooltip = create_tooltip ("DetailsPlayerComparisonBox3Tooltip")
    frame3.tooltip:SetWidth(spell_compare_frame_width[3])

    local playername3 = frame3:CreateFontString(nil, "overlay", "GameFontNormal")
    playername3:SetPoint("bottomleft", frame3, "topleft", 2, 0)
    playername3:SetText("Player 3")
    frame3.name_label = playername3

    local playername3_percent = frame3:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
    playername3_percent:SetPoint("bottomright", frame3, "topright", -2, 0)
    playername3_percent:SetText("Player 1 %")
    playername3_percent:SetTextColor(.6, .6, .6)
    frame3.name_label_percent = playername3_percent


    local noPLayersToShow = frame3:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
    noPLayersToShow:SetPoint("center")
    noPLayersToShow:SetText("There's no more players to compare (with the same class/spec)")
    noPLayersToShow:SetSize(spell_compare_frame_width[2] - 10, spell_compare_frame_height)
    noPLayersToShow:SetJustifyH("center")
    noPLayersToShow:SetJustifyV ("middle")
    Details.gump:SetFontSize(noPLayersToShow, 14)
    Details.gump:SetFontColor(noPLayersToShow, "gray")
    frame3.NoPLayersToShow = noPLayersToShow

    --criar as barras do frame3
    for i = 1, 12 do
        create_bar ("DetailsPlayerComparisonBox3Bar"..i, frame3, i)
    end

    --cria o box dos targets
    local target3 = CreateFrame("frame", "DetailsPlayerComparisonTarget3", frame,"BackdropTemplate")
    target3:SetSize(spell_compare_frame_width[3], target_compare_frame_height)
    target3:SetPoint("topleft", frame3, "bottomleft", 0, -10)
    target3:SetBackdrop(frame_backdrop)
    target3:SetBackdropColor(unpack(frame_backdrop_color))
    target3:SetBackdropBorderColor(unpack(frame_backdrop_border_color))
    target3.bars = {}
    target3.tooltip = create_tooltip_target ("DetailsPlayerComparisonTarget3Tooltip")
    target3.tooltip:SetWidth(spell_compare_frame_width[3])

    --override backdrop settings and use the framework defaults
    Details.gump:ApplyStandardBackdrop(target3)

    --criar as barras do target1
    for i = 1, targetBars do
        create_bar ("DetailsPlayerComparisonTarget3Bar"..i, target3, i, nil, true)
    end
end

-- ~compare
local iconTableCompare = {
    texture = [[Interface\AddOns\Details\images\icons]],
    --coords = {363/512, 381/512, 0/512, 17/512},
    coords = {383/512, 403/512, 0/512, 15/512},
    width = 16,
    height = 14,
}

function Details:InitializeCompareTab()
    --check if the tab is already created
    for i = 1, #Details.player_details_tabs do
        local tabButton = Details.player_details_tabs[i]
        if (tabButton.tabname == "Compare" or tabButton.tabname == "New Compare") then
            return
        end
    end

    for i = 1, #Details.player_details_tabs do
        local tabButton = Details.player_details_tabs[i]
        if (tabButton.replaces) then
            if (tabButton.replaces.bIsCompareTab) then
                return
            end
        end
    end

    Details:CreatePlayerDetailsTab ("Compare", --[1] tab name
        Loc ["STRING_INFO_TAB_COMPARISON"],  --[2] localized name
        function(tabOBject, playerObject)  --[3] condition

            if (breakdownWindowFrame.atributo > 2) then
                return false
            end

            local same_class = {}
            local class = playerObject.classe
            local my_spells = {}
            local my_spells_total = 0
            --build my spell list
            for spellid, _ in pairs(playerObject.spells._ActorTable) do
                my_spells [spellid] = true
                my_spells_total = my_spells_total + 1
            end

            tabOBject.players = {}
            tabOBject.player = playerObject
            tabOBject.spells_amt = my_spells_total

            if (not breakdownWindowFrame.instancia.showing) then
                return false
            end

            for index, actor in ipairs(breakdownWindowFrame.instancia.showing [breakdownWindowFrame.atributo]._ActorTable) do
                if (actor.classe == class and actor ~= playerObject) then

                    local same_spells = 0
                    for spellid, _ in pairs(actor.spells._ActorTable) do
                        if (my_spells [spellid]) then
                            same_spells = same_spells + 1
                        end
                    end

                    local match_percentage = same_spells / math.max(my_spells_total, 0.000001) * 100

                    if (match_percentage > 30) then
                        table.insert(tabOBject.players, actor)
                    end
                end
            end

            if (#tabOBject.players > 0) then
                --tutorial flash
                local blink = Details:GetTutorialCVar("DETAILS_INFO_TUTORIAL2") or 0
                if (type(blink) == "number" and blink < 10) then

                    if (not tabOBject.FlashAnimation) then
                        local flashAnimation = tabOBject:CreateTexture(nil, "overlay")
                        flashAnimation:SetPoint("topleft", tabOBject.widget, "topleft", 1, -1)
                        flashAnimation:SetPoint("bottomright", tabOBject.widget, "bottomright", -1, 1)
                        flashAnimation:SetColorTexture(1, 1, 1)

                        local flashHub = DetailsFramework:CreateAnimationHub (flashAnimation, function() flashAnimation:Show() end, function() flashAnimation:Hide() end)
                        DetailsFramework:CreateAnimation(flashHub, "alpha", 1, 1, 0, 0.3)
                        DetailsFramework:CreateAnimation(flashHub, "alpha", 2, 1, 0.45, 0)
                        flashHub:SetLooping ("REPEAT")

                        tabOBject.FlashAnimation = flashHub
                    end

                    Details:SetTutorialCVar ("DETAILS_INFO_TUTORIAL2", blink+1)

                    tabOBject.FlashAnimation:Play()
                end

                return true
            end

            --return false
            return true --debug?
        end,

        compare_fill, --[4] fill function

        nil, --[5] onclick

        compare_create, --[6] oncreate
        iconTableCompare --icon table
    )
end