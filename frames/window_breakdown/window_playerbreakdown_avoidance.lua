
    local Details = Details

    local unpack = unpack
    local _GetSpellInfo = Details.GetSpellInfo
    local PLAYER_DETAILS_STATUSBAR_HEIGHT = 20
    local CreateFrame = CreateFrame
    local GameTooltip = GameTooltip
    local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )

	local red = "FFFFAAAA"
	local green = "FFAAFFAA"

    local avoidance_create = function(tab, frame)
        --Percent Desc
            local percent_desc = frame:CreateFontString(nil, "artwork", "GameFontNormal")
            percent_desc:SetText("Percent values are comparisons with the previous try.")
            percent_desc:SetPoint("bottomleft", frame, "bottomleft", 13, 13 + PLAYER_DETAILS_STATUSBAR_HEIGHT)
            percent_desc:SetTextColor(.5, .5, .5, 1)

        --SUMMARY
            local summaryBox = CreateFrame("frame", nil, frame, "BackdropTemplate")
            Details.gump:ApplyStandardBackdrop(summaryBox)
            summaryBox:SetPoint("topleft", frame, "topleft", 10, -15)
            summaryBox:SetSize(200, 160)

            local y = -5
            local padding = 16

            local summary_text = summaryBox:CreateFontString(nil, "artwork", "GameFontNormal")
            summary_text:SetText("Summary")
            summary_text :SetPoint("topleft", summaryBox, "topleft", 5, y)

            y = y - padding

            --total damage received
            local damagereceived = summaryBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            damagereceived:SetPoint("topleft", summaryBox, "topleft", 15, y)
            damagereceived:SetText("Total Damage Taken:") --localize-me
            damagereceived:SetTextColor(.8, .8, .8, 1)

            local damagereceived_amt = summaryBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            damagereceived_amt:SetPoint("left", damagereceived,  "right", 2, 0)
            damagereceived_amt:SetText("0")
            tab.damagereceived = damagereceived_amt

            y = y - padding

            --per second
            local damagepersecond = summaryBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            damagepersecond:SetPoint("topleft", summaryBox, "topleft", 20, y)
            damagepersecond:SetText("Per Second:") --localize-me

            local damagepersecond_amt = summaryBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            damagepersecond_amt:SetPoint("left", damagepersecond,  "right", 2, 0)
            damagepersecond_amt:SetText("0")
            tab.damagepersecond = damagepersecond_amt

            y = y - padding

            --total absorbs
            local absorbstotal = summaryBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            absorbstotal:SetPoint("topleft", summaryBox, "topleft", 15, y)
            absorbstotal:SetText("Total Absorbs:") --localize-me
            absorbstotal:SetTextColor(.8, .8, .8, 1)

            local absorbstotal_amt = summaryBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            absorbstotal_amt:SetPoint("left", absorbstotal,  "right", 2, 0)
            absorbstotal_amt:SetText("0")
            tab.absorbstotal = absorbstotal_amt

            y = y - padding

            --per second
            local absorbstotalpersecond = summaryBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            absorbstotalpersecond:SetPoint("topleft", summaryBox, "topleft", 20, y)
            absorbstotalpersecond:SetText("Per Second:") --localize-me

            local absorbstotalpersecond_amt = summaryBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            absorbstotalpersecond_amt:SetPoint("left", absorbstotalpersecond,  "right", 2, 0)
            absorbstotalpersecond_amt:SetText("0")
            tab.absorbstotalpersecond = absorbstotalpersecond_amt


        --MELEE

            y = -5

            local meleeBox = CreateFrame("frame", nil, frame, "BackdropTemplate")
            Details.gump:ApplyStandardBackdrop(meleeBox)
            meleeBox:SetPoint("topleft", summaryBox, "bottomleft", 0, -5)
            meleeBox:SetSize(200, 160)

            local melee_text = meleeBox:CreateFontString(nil, "artwork", "GameFontNormal")
            melee_text:SetText("Melee")
            melee_text :SetPoint("topleft", meleeBox, "topleft", 5, y)

            y = y - padding

            --dodge
            local dodge = meleeBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            dodge:SetPoint("topleft", meleeBox, "topleft", 15, y)
            dodge:SetText("Dodge:") --localize-me
            dodge:SetTextColor(.8, .8, .8, 1)
            local dodge_amt = meleeBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            dodge_amt:SetPoint("left", dodge,  "right", 2, 0)
            dodge_amt:SetText("0")
            tab.dodge = dodge_amt

            y = y - padding

            local dodgepersecond = meleeBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            dodgepersecond:SetPoint("topleft", meleeBox, "topleft", 20, y)
            dodgepersecond:SetText("Per Second:") --localize-me

            local dodgepersecond_amt = meleeBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            dodgepersecond_amt:SetPoint("left", dodgepersecond,  "right", 2, 0)
            dodgepersecond_amt:SetText("0")
            tab.dodgepersecond = dodgepersecond_amt

            y = y - padding

            -- parry
            local parry = meleeBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            parry:SetPoint("topleft", meleeBox, "topleft", 15, y)
            parry:SetText("Parry:") --localize-me
            parry:SetTextColor(.8, .8, .8, 1)
            local parry_amt = meleeBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            parry_amt:SetPoint("left", parry,  "right", 2, 0)
            parry_amt:SetText("0")
            tab.parry = parry_amt

            y = y - padding

            local parrypersecond = meleeBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            parrypersecond:SetPoint("topleft", meleeBox, "topleft", 20, y)
            parrypersecond:SetText("Per Second:") --localize-me
            local parrypersecond_amt = meleeBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            parrypersecond_amt:SetPoint("left", parrypersecond,  "right", 2, 0)
            parrypersecond_amt:SetText("0")
            tab.parrypersecond = parrypersecond_amt

            y = y - padding

            -- block
            local block = meleeBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            block:SetPoint("topleft", meleeBox, "topleft", 15, y)
            block:SetText("Block:") --localize-me
            block:SetTextColor(.8, .8, .8, 1)
            local block_amt = meleeBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            block_amt:SetPoint("left", block,  "right", 2, 0)
            block_amt:SetText("0")
            tab.block = block_amt

            y = y - padding

            local blockpersecond = meleeBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            blockpersecond:SetPoint("topleft", meleeBox, "topleft", 20, y)
            blockpersecond:SetText("Per Second:") --localize-me
            local blockpersecond_amt = meleeBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            blockpersecond_amt:SetPoint("left", blockpersecond,  "right", 2, 0)
            blockpersecond_amt:SetText("0")
            tab.blockpersecond = blockpersecond_amt

            y = y - padding

            local blockeddamage = meleeBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            blockeddamage:SetPoint("topleft", meleeBox, "topleft", 20, y)
            blockeddamage:SetText("Damage Blocked:") --localize-me
            local blockeddamage_amt = meleeBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            blockeddamage_amt:SetPoint("left", blockeddamage,  "right", 2, 0)
            blockeddamage_amt:SetText("0")
            tab.blockeddamage_amt = blockeddamage_amt

        --ABSORBS
            y = -5

            local absorbsBox = CreateFrame("frame", nil, frame, "BackdropTemplate")
            Details.gump:ApplyStandardBackdrop(absorbsBox)
            absorbsBox:SetPoint("topleft", summaryBox, "topright", 10, 0)
            absorbsBox:SetSize(200, 160)

            local absorb_text = absorbsBox:CreateFontString(nil, "artwork", "GameFontNormal")
            absorb_text:SetText("Absorb")
            absorb_text :SetPoint("topleft", absorbsBox, "topleft", 5, y)

            y = y - padding

            --full absorbs
            local fullsbsorbed = absorbsBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            fullsbsorbed:SetPoint("topleft", absorbsBox, "topleft", 20, y)
            fullsbsorbed:SetText("Full Absorbs:") --localize-me
            fullsbsorbed:SetTextColor(.8, .8, .8, 1)
            local fullsbsorbed_amt = absorbsBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            fullsbsorbed_amt:SetPoint("left", fullsbsorbed,  "right", 2, 0)
            fullsbsorbed_amt:SetText("0")
            tab.fullsbsorbed = fullsbsorbed_amt

            y = y - padding

            --partially absorbs
            local partiallyabsorbed = absorbsBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            partiallyabsorbed:SetPoint("topleft", absorbsBox, "topleft", 20, y)
            partiallyabsorbed:SetText("Partially Absorbed:") --localize-me
            partiallyabsorbed:SetTextColor(.8, .8, .8, 1)
            local partiallyabsorbed_amt = absorbsBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            partiallyabsorbed_amt:SetPoint("left", partiallyabsorbed,  "right", 2, 0)
            partiallyabsorbed_amt:SetText("0")
            tab.partiallyabsorbed = partiallyabsorbed_amt

            y = y - padding

            --partially absorbs per second
            local partiallyabsorbedpersecond = absorbsBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            partiallyabsorbedpersecond:SetPoint("topleft", absorbsBox, "topleft", 25, y)
            partiallyabsorbedpersecond:SetText("Average:") --localize-me
            local partiallyabsorbedpersecond_amt = absorbsBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            partiallyabsorbedpersecond_amt:SetPoint("left", partiallyabsorbedpersecond,  "right", 2, 0)
            partiallyabsorbedpersecond_amt:SetText("0")
            tab.partiallyabsorbedpersecond = partiallyabsorbedpersecond_amt

            y = y - padding

            --no absorbs
            local noabsorbs = absorbsBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            noabsorbs:SetPoint("topleft", absorbsBox, "topleft", 20, y)
            noabsorbs:SetText("No Absorption:") --localize-me
            noabsorbs:SetTextColor(.8, .8, .8, 1)
            local noabsorbs_amt = absorbsBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            noabsorbs_amt:SetPoint("left", noabsorbs,  "right", 2, 0)
            noabsorbs_amt:SetText("0")
            tab.noabsorbs = noabsorbs_amt

        --HEALING

            y = -5
            local healingBox = CreateFrame("frame", nil, frame,"BackdropTemplate")
            Details.gump:ApplyStandardBackdrop(healingBox)
            healingBox:SetPoint("topleft", absorbsBox, "bottomleft", 0, -5)
            healingBox:SetSize(200, 160)

            local healing_text = healingBox:CreateFontString(nil, "artwork", "GameFontNormal")
            healing_text:SetText("Healing")
            healing_text :SetPoint("topleft", healingBox, "topleft", 5, y)

            y = y - padding

            --self healing
            local selfhealing = healingBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            selfhealing:SetPoint("topleft", healingBox, "topleft", 20, y)
            selfhealing:SetText("Self Healing:") --localize-me
            selfhealing:SetTextColor(.8, .8, .8, 1)
            local selfhealing_amt = healingBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            selfhealing_amt:SetPoint("left", selfhealing,  "right", 2, 0)
            selfhealing_amt:SetText("0")
            tab.selfhealing = selfhealing_amt

            y = y - padding

            --self healing per second
            local selfhealingpersecond = healingBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            selfhealingpersecond:SetPoint("topleft", healingBox, "topleft", 25, y)
            selfhealingpersecond:SetText("Per Second:") --localize-me
            local selfhealingpersecond_amt = healingBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
            selfhealingpersecond_amt:SetPoint("left", selfhealingpersecond,  "right", 2, 0)
            selfhealingpersecond_amt:SetText("0")
            tab.selfhealingpersecond = selfhealingpersecond_amt

            y = y - padding

            for i = 1, 5 do
                local healer = healingBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
                healer:SetPoint("topleft", healingBox, "topleft", 20, y + ((i-1)*15)*-1)
                healer:SetText("healer name:") --localize-me
                healer:SetTextColor(.8, .8, .8, 1)
                local healer_amt = healingBox:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
                healer_amt:SetPoint("left", healer,  "right", 2, 0)
                healer_amt:SetText("0")
                tab ["healer" .. i] = {healer, healer_amt}
            end

        --SPELLS

            y = -5

            local spellsBox = CreateFrame("frame", nil, frame,"BackdropTemplate")
            Details.gump:ApplyStandardBackdrop(spellsBox)
            spellsBox:SetPoint("topleft", absorbsBox, "topright", 10, 0)
            spellsBox:SetSize(346, 160 * 2 + 5)

            local spells_text = spellsBox:CreateFontString(nil, "artwork", "GameFontNormal")
            spells_text:SetText("Spells")
            spells_text :SetPoint("topleft", spellsBox, "topleft", 5, y)

            local frame_tooltip_onenter = function(self)
                if (self.spellid) then
                    --self:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 512, edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 8})
                    self:SetBackdropColor(.5, .5, .5, .5)
                    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
                    Details:GameTooltipSetSpellByID (self.spellid)
                    GameTooltip:Show()
                end
            end
            local frame_tooltip_onleave = function(self)
                if (self.spellid) then
                    self:SetBackdropColor(.5, .5, .5, .1)
                    GameTooltip:Hide()
                end
            end

            y = y - padding

            for i = 1, 40 do
                local frame_tooltip = CreateFrame("frame", nil, spellsBox,"BackdropTemplate")
                frame_tooltip:SetPoint("topleft", spellsBox, "topleft", 5, y + ((i-1)*17)*-1)
                frame_tooltip:SetSize(spellsBox:GetWidth()-10, 16)
                frame_tooltip:SetScript("OnEnter", frame_tooltip_onenter)
                frame_tooltip:SetScript("OnLeave", frame_tooltip_onleave)
                frame_tooltip:Hide()

                frame_tooltip:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 512})
                frame_tooltip:SetBackdropColor(.5, .5, .5, .1)

                local icon = frame_tooltip:CreateTexture(nil, "artwork")
                icon:SetSize(14, 14)
                icon:SetPoint("left", frame_tooltip, "left")

                local spell = frame_tooltip:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
                spell:SetPoint("left", icon, "right", 2, 0)
                spell:SetText("spell name:") --localize-me
                spell:SetTextColor(.8, .8, .8, 1)

                local spell_amt = frame_tooltip:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
                spell_amt:SetPoint("left", spell,  "right", 2, 0)
                spell_amt:SetText("0")

                tab ["spell" .. i] = {spell, spell_amt, icon, frame_tooltip}
            end

        end

        local getpercent = function(value, lastvalue, elapsed_time, inverse)
            local ps = value / elapsed_time
            local diff

            if (lastvalue == 0) then
                diff = "+0%"
            else
                if (ps >= lastvalue) then
                    local d = ps - lastvalue
                    d = d / lastvalue * 100
                    d = math.floor(math.abs(d))

                    if (d > 999) then
                        d = "> 999"
                    end

                    if (inverse) then
                        diff = "|c" .. green .. "+" .. d .. "%|r"
                    else
                        diff = "|c" .. red .. "+" .. d .. "%|r"
                    end
                else
                    local d = lastvalue - ps
                    d = d / math.max(ps, 0.001) * 100
                    d = math.floor(math.abs(d))

                    if (d > 999) then
                        d = "> 999"
                    end

                    if (inverse) then
                        diff = "|c" .. red .. "-" .. d .. "%|r"
                    else
                        diff = "|c" .. green .. "-" .. d .. "%|r"
                    end
                end
            end

            return ps, diff
        end

        local avoidance_fill = function(tab, player, combat)
            local elapsed_time = combat:GetCombatTime()

            local last_combat = combat.previous_combat --this is always nil from 2023 may 26
            if (not last_combat or not last_combat [1]) then
                last_combat = combat
            end
            
            local last_actor = last_combat (1, player.nome)
            local n = player.nome
            if (n:find("-")) then
                n = n:gsub(("-.*"), "")
            end

            --damage taken
                local playerdamage = combat (1, player.nome)

                if (not playerdamage.avoidance) then
                    playerdamage.avoidance = Details:CreateActorAvoidanceTable()
                end

                local damagetaken = playerdamage.damage_taken
                local last_damage_received = 0
                if (last_actor) then
                    last_damage_received = last_actor.damage_taken / last_combat:GetCombatTime()
                end

                tab.damagereceived:SetText(Details:ToK2 (damagetaken))

                local ps, diff = getpercent (damagetaken, last_damage_received, elapsed_time)
                tab.damagepersecond:SetText(Details:comma_value (math.floor(ps)) .. " (" .. diff .. ")")

            --absorbs
                local totalabsorbs = playerdamage.avoidance.overall.ABSORB_AMT
                local incomingtotal = damagetaken + totalabsorbs

                local last_total_absorbs = 0
                if (last_actor and last_actor.avoidance) then
                    last_total_absorbs = last_actor.avoidance.overall.ABSORB_AMT / last_combat:GetCombatTime()
                end

                tab.absorbstotal:SetText(Details:ToK2 (totalabsorbs) .. " (" .. math.floor(totalabsorbs / incomingtotal * 100) .. "%)")

                local ps, diff = getpercent (totalabsorbs, last_total_absorbs, elapsed_time, true)
                tab.absorbstotalpersecond:SetText(Details:comma_value (math.floor(ps)) .. " (" .. diff .. ")")

            --dodge
                local totaldodge = playerdamage.avoidance.overall.DODGE
                tab.dodge:SetText(totaldodge)

                local last_total_dodge = 0
                if (last_actor and last_actor.avoidance) then
                    last_total_dodge = last_actor.avoidance.overall.DODGE / last_combat:GetCombatTime()
                end
                local ps, diff = getpercent (totaldodge, last_total_dodge, elapsed_time, true)
                tab.dodgepersecond:SetText( string.format("%.2f", ps) .. " (" .. diff .. ")")

            --parry
                local totalparry = playerdamage.avoidance.overall.PARRY
                tab.parry:SetText(totalparry)

                local last_total_parry = 0
                if (last_actor and last_actor.avoidance) then
                    last_total_parry = last_actor.avoidance.overall.PARRY / last_combat:GetCombatTime()
                end
                local ps, diff = getpercent (totalparry, last_total_parry, elapsed_time, true)
                tab.parrypersecond:SetText(string.format("%.2f", ps) .. " (" .. diff .. ")")

            --block
                local totalblock = playerdamage.avoidance.overall.BLOCKED_HITS
                tab.block:SetText(totalblock)

                local last_total_block = 0
                if (last_actor and last_actor.avoidance) then
                    last_total_block = last_actor.avoidance.overall.BLOCKED_HITS / last_combat:GetCombatTime()
                end
                local ps, diff = getpercent (totalblock, last_total_block, elapsed_time, true)
                tab.blockpersecond:SetText(string.format("%.2f", ps) .. " (" .. diff .. ")")

                tab.blockeddamage_amt:SetText(Details:ToK2 (playerdamage.avoidance.overall.BLOCKED_AMT))

            --absorb
                local fullabsorb = playerdamage.avoidance.overall.FULL_ABSORBED
                local halfabsorb = playerdamage.avoidance.overall.PARTIAL_ABSORBED
                local halfabsorb_amt = playerdamage.avoidance.overall.PARTIAL_ABSORB_AMT
                local noabsorb = playerdamage.avoidance.overall.FULL_HIT

                tab.fullsbsorbed:SetText(fullabsorb)
                tab.partiallyabsorbed:SetText(halfabsorb)
                tab.noabsorbs:SetText(noabsorb)

                if (halfabsorb_amt > 0) then
                    local average = halfabsorb_amt / halfabsorb --tenho o average
                    local last_average = 0
                    if (last_actor and last_actor.avoidance and last_actor.avoidance.overall.PARTIAL_ABSORBED > 0) then
                        last_average = last_actor.avoidance.overall.PARTIAL_ABSORB_AMT / last_actor.avoidance.overall.PARTIAL_ABSORBED
                    end

                    local ps, diff = getpercent (halfabsorb_amt, last_average, halfabsorb, true)
                    tab.partiallyabsorbedpersecond:SetText(Details:comma_value (math.floor(ps)) .. " (" .. diff .. ")")
                else
                    tab.partiallyabsorbedpersecond:SetText("0.00 (0%)")
                end



            --healing

                local actor_heal = combat (2, player.nome)
                if (not actor_heal) then
                    tab.selfhealing:SetText("0")
                    tab.selfhealingpersecond:SetText("0 (0%)")
                else
                    local last_actor_heal = last_combat (2, player.nome)
                    local este_alvo = actor_heal.targets [player.nome]
                    if (este_alvo) then
                        local heal_total = este_alvo
                        tab.selfhealing:SetText(Details:ToK2 (heal_total))

                        if (last_actor_heal) then
                            local este_alvo = last_actor_heal.targets [player.nome]
                            if (este_alvo) then
                                local heal = este_alvo

                                local last_heal = heal / last_combat:GetCombatTime()

                                local ps, diff = getpercent (heal_total, last_heal, elapsed_time, true)
                                tab.selfhealingpersecond:SetText(Details:comma_value (math.floor(ps)) .. " (" .. diff .. ")")

                            else
                                tab.selfhealingpersecond:SetText("0 (0%)")
                            end
                        else
                            tab.selfhealingpersecond:SetText("0 (0%)")
                        end

                    else
                        tab.selfhealing:SetText("0")
                        tab.selfhealingpersecond:SetText("0 (0%)")
                    end


                    -- taken from healer
                    local heal_from = actor_heal.healing_from
                    local myReceivedHeal = {}

                    for actorName, _ in pairs(heal_from) do
                        local thisActor = combat (2, actorName)
                        local targets = thisActor.targets --targets is a container with target classes
                        local amount = targets [player.nome] or 0
                        myReceivedHeal [#myReceivedHeal+1] = {actorName, amount, thisActor.classe}
                    end

                    table.sort (myReceivedHeal, Details.Sort2) --Sort2 sort by second index

                    for i = 1, 5 do
                        local label1, label2 = unpack(tab ["healer" .. i])
                        if (myReceivedHeal [i]) then
                            local name = myReceivedHeal [i][1]

                            name = Details:GetOnlyName(name)
                            --name = Details:RemoveOwnerName (name)

                            label1:SetText(name .. ":")
                            local class = myReceivedHeal [i][3]
                            if (class) then
                                local c = _G["RAID_CLASS_COLORS"][class]
                                if (c) then
                                    label1:SetTextColor(c.r, c.g, c.b)
                                end
                            else
                                label1:SetTextColor(.8, .8, .8, 1)
                            end

                            local last_actor = last_combat (2, myReceivedHeal [i][1])
                            if (last_actor) then
                                local targets = last_actor.targets
                                local amount = targets [player.nome] or 0
                                if (amount) then

                                    local last_heal = amount

                                    local ps, diff = getpercent (myReceivedHeal[i][2], last_heal, 1, true)
                                    label2:SetText( Details:ToK2 (myReceivedHeal[i][2] or 0) .. " (" .. diff .. ")")

                                else
                                    label2:SetText( Details:ToK2 (myReceivedHeal[i][2] or 0))
                                end
                            else
                                label2:SetText( Details:ToK2 (myReceivedHeal[i][2] or 0))
                            end


                        else
                            label1:SetText("-- -- -- --")
                            label1:SetTextColor(.8, .8, .8, 1)
                            label2:SetText("")
                        end
                    end
                end

            --Spells
                --cooldowns
                local index_used = 1
                local misc_player = combat (4, player.nome)
                local encounter_time = combat:GetCombatTime()

                if (misc_player) then
                    if (misc_player.cooldowns_defensive_spells) then
                        local minha_tabela = misc_player.cooldowns_defensive_spells._ActorTable
                        local buffUpdateSpells = misc_player.buff_uptime_spells -- ._ActorTable

                        local cooldowns_usados = {}

                        for _spellid, _tabela in pairs(minha_tabela) do
                            cooldowns_usados [#cooldowns_usados+1] = {_spellid, _tabela.counter}
                        end

                        if (#cooldowns_usados > 0) then

                            table.sort (cooldowns_usados, Details.Sort2)

                            for i = 1, #cooldowns_usados do
                                local esta_habilidade = cooldowns_usados[i]
                                local nome_magia, _, icone_magia = _GetSpellInfo(esta_habilidade[1])

                                local label1, label2, icon1, framebg = unpack(tab ["spell" .. index_used])
                                framebg.spellid = esta_habilidade[1]
                                framebg:Show()

                                --attempt to get the buff update
                                local spellInfo = buffUpdateSpells:GetSpell (framebg.spellid)
                                if (spellInfo) then
                                    label2:SetText(esta_habilidade[2] .. " (" .. math.floor(spellInfo.uptime / encounter_time * 100) .. "% uptime)")
                                else
                                    label2:SetText(esta_habilidade[2])
                                end

                                --update the line
                                label1:SetText(nome_magia .. ":")

                                icon1:SetTexture(icone_magia)
                                icon1:SetTexCoord(0.0625, 0.953125, 0.0625, 0.953125)

                                index_used = index_used + 1
                            end
                        end
                    end
                end

                local cooldownInfo = DetailsFramework.CooldownsInfo

                --see cooldowns that other players used in this actor
                for playerName, _ in pairs(combat.raid_roster) do
                    if (playerName ~= player.nome) then
                        local miscPlayer = combat (4, playerName)
                        if (miscPlayer) then
                            if (miscPlayer.cooldowns_defensive_spells) then
                                local cooldowns = miscPlayer.cooldowns_defensive_spells
                                for spellID, spellTable in cooldowns:ListActors() do
                                    local targets = spellTable.targets
                                    if (targets) then
                                        for targetName, amountCasted in pairs(targets) do
                                            if (targetName == player.nome) then
                                                local spellName, _, spellIcon = _GetSpellInfo(spellID)
                                                local label1, label2, icon1, framebg = unpack(tab ["spell" .. index_used])
                                                framebg.spellid = spellID
                                                framebg:Show()

                                                --attempt to get the buff update
                                                local info = cooldownInfo [spellID]
                                                local cooldownDuration = info and info.duration or 0

                                                if (cooldownDuration > 0) then
                                                    label2:SetText(amountCasted .. " (" .. "|cFFFFFF00" .. miscPlayer.nome .. "|r " .. math.floor(cooldownDuration / encounter_time * 100) .. "% uptime)")
                                                else
                                                    label2:SetText(amountCasted)
                                                end

                                                --update the line
                                                label1:SetText(spellName .. ":")

                                                icon1:SetTexture(spellIcon)
                                                icon1:SetTexCoord(0.0625, 0.953125, 0.0625, 0.953125)

                                                index_used = index_used + 1
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                for i = index_used, 40 do
                    local label1, label2, icon1, framebg = unpack(tab ["spell" .. i])

                    framebg.spellid = nil
                    framebg:Hide()
                    label1:SetText("")
                    label2:SetText("")
                    icon1:SetTexture("")
                end

            --habilidade usada para interromper
        end

        local iconTableAvoidance = {
            texture = [[Interface\AddOns\Details\images\icons]],
            --coords = {363/512, 381/512, 0/512, 17/512},
            coords = {384/512, 402/512, 19/512, 38/512},
            width = 16,
            height = 16,
        }

        Details:CreatePlayerDetailsTab ("Avoidance", --[1] tab name
            Loc ["STRING_INFO_TAB_AVOIDANCE"],  --[2] localized name
            function(tabOBject, playerObject)  --[3] condition
                if (playerObject.isTank) then
                    return true
                else
                    return false
                end
            end,

            avoidance_fill, --[4] fill function

            nil, --[5] onclick

            avoidance_create, --[6] oncreate
            iconTableAvoidance --[7] icon
        )