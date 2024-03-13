
local Details = _G.Details
local addonName, Details222 = ...

--get the total of damage and healing of a phase of an encounter
function Details:OnCombatPhaseChanged()

    local current_combat = Details:GetCurrentCombat()
    local current_phase = current_combat.PhaseData[#current_combat.PhaseData][1]

    local phaseDamageContainer = current_combat.PhaseData.damage[current_phase]
    local phaseHealingContainer = current_combat.PhaseData.heal[current_phase]

    local phaseDamageSection = current_combat.PhaseData.damage_section
    local phaseHealingSection = current_combat.PhaseData.heal_section

    if (not phaseDamageContainer) then
        phaseDamageContainer = {}
        current_combat.PhaseData.damage[current_phase] = phaseDamageContainer
    end
    if (not phaseHealingContainer) then
        phaseHealingContainer = {}
        current_combat.PhaseData.heal[current_phase] = phaseHealingContainer
    end

    for index, damage_actor in ipairs(Details.cache_damage_group) do
        local phase_damage = damage_actor.total - (phaseDamageSection [damage_actor.nome] or 0)
        phaseDamageSection [damage_actor.nome] = damage_actor.total
        phaseDamageContainer [damage_actor.nome] = (phaseDamageContainer [damage_actor.nome] or 0) + phase_damage
    end

    for index, healing_actor in ipairs(Details.cache_healing_group) do
        local phase_heal = healing_actor.total - (phaseHealingSection [healing_actor.nome] or 0)
        phaseHealingSection [healing_actor.nome] = healing_actor.total
        phaseHealingContainer [healing_actor.nome] = (phaseHealingContainer [healing_actor.nome] or 0) + phase_heal
    end
end

function Details:BossModsLink()
    if (_G.DBM) then
        local DBM = _G.DBM
        local DBMCallbackPhase2 = function(event, mod, modId, phase, encounterId, stageTotal)
            local encounterTable = Details.encounter_table

            if (phase and encounterTable.phase ~= phase) then
                --Details:Msg("Current phase is now:", phase)
                Details:OnCombatPhaseChanged()
                encounterTable.phase = phase
                local currentCombat = Details:GetCurrentCombat()
                local combatTime = currentCombat:GetCombatTime()
                if (combatTime > 5) then
                    table.insert(currentCombat.PhaseData, {phase, combatTime})
                end
                Details:SendEvent("COMBAT_ENCOUNTER_PHASE_CHANGED", nil, phase)
            end
        end

        local DBMCallbackPull = function(event, mod, delay, synced, startHp)
            local encounterTable = Details.encounter_table
            encounterTable.DBM_Mod = mod
            encounterTable.DBM_ModTime = time()
        end

        DBM:RegisterCallback("pull", DBMCallbackPull)
        DBM:RegisterCallback("DBM_SetStage", DBMCallbackPhase2)
    end

    if (BigWigsLoader and not _G.DBM) then

        --Bigwigs change the phase of an encounter
        function Details:BigWigs_SetStage (event, module, phase)
            phase = tonumber(phase)

            if (phase and type(phase) == "number" and Details.encounter_table.phase ~= phase) then
                Details:OnCombatPhaseChanged()

                Details.encounter_table.phase = phase

                local currentCombat = Details:GetCurrentCombat()
                local combatTime = currentCombat:GetCombatTime()
                if (combatTime > 5) then
                    table.insert(currentCombat.PhaseData, {phase, combatTime})
                end

                Details:SendEvent("COMBAT_ENCOUNTER_PHASE_CHANGED", nil, phase)
                --Details:Msg("Current phase is now:", phase)
            end
        end

        if (BigWigsLoader.RegisterMessage) then
            BigWigsLoader.RegisterMessage (Details, "BigWigs_SetStage")
        end
    end

    Details:CreateCallbackListeners()
end


function Details:CreateCallbackListeners()

    Details.DBM_timers = {}

    local current_encounter = false
    local current_table_dbm = {}
    local current_table_bigwigs = {}

    local event_frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
    event_frame:SetScript("OnEvent", function(self, event, ...)
        if (event == "ENCOUNTER_START") then
            local encounterID, encounterName, difficultyID, raidSize = select(1, ...)
            current_encounter = encounterID

        elseif (event == "ENCOUNTER_END" or event == "PLAYER_REGEN_ENABLED") then
            if (current_encounter) then
                if (_G.DBM) then
                    local db = Details.boss_mods_timers
                    for spell, timer_table in pairs(current_table_dbm) do
                        if (not db.encounter_timers_dbm [timer_table[1]]) then
                            timer_table.id = current_encounter
                            db.encounter_timers_dbm [timer_table[1]] = timer_table
                        end
                    end
                end
                if (BigWigs) then
                    local db = Details.boss_mods_timers
                    for timer_id, timer_table in pairs(current_table_bigwigs) do
                        if (not db.encounter_timers_bw [timer_id]) then
                            timer_table.id = current_encounter
                            db.encounter_timers_bw [timer_id] = timer_table
                        end
                    end
                end
            end

            current_encounter = false
            Details:Destroy(current_table_dbm)
            Details:Destroy(current_table_bigwigs)
        end
    end)

    event_frame:RegisterEvent("ENCOUNTER_START")
    event_frame:RegisterEvent("ENCOUNTER_END")
    event_frame:RegisterEvent("PLAYER_REGEN_ENABLED")

    if (_G.DBM) then
        local dbm_timer_callback = function(bar_type, id, msg, timer, icon, bartype, spellId, colorId, modid)
            local currentCombat = Details:GetCurrentCombat()
            if (not currentCombat.__destroyed) then --async events, need to check for combat destruction
                ---@type combattime
                local combatTime = currentCombat:GetCombatTime()
                table.insert(currentCombat.bossTimers, {"dbm", combatTime, bar_type, id, msg, timer, icon, bartype, spellId, colorId, modid})
                --print("dbm event", bar_type, id, msg, timer, icon, bartype, spellId, colorId, modid)

                local spell = tostring(spellId)
                if (spell and not current_table_dbm[spell]) then
                    current_table_dbm[spell] = {spell, id, msg, timer, icon, bartype, spellId, colorId, modid}
                end
            end
        end
        DBM:RegisterCallback ("DBM_TimerStart", dbm_timer_callback)
    end

    --record Bigwigs timers shown at /details spells.
    --this is also usage to create weakauras directly from details!
    function Details:RegisterBigWigsCallBack()
        --if the user is also using DBM, ignore registering another callback
        if (BigWigsLoader and not _G.DBM) then
            function Details:BigWigs_StartBar(event, module, spellid, bar_text, time, icon, ...)
                local currentCombat = Details:GetCurrentCombat()
                if (not currentCombat.__destroyed) then --async events, need to check for combat destruction
                    ---@type combattime
                    local combatTime = currentCombat:GetCombatTime()
                    table.insert(currentCombat.bossTimers, {"bw", combatTime, spellid, bar_text, time, icon})

                    spellid = tostring(spellid)
                    if (not current_table_bigwigs[spellid]) then
                        current_table_bigwigs[spellid] = {(type(module) == "string" and module) or (module and module.moduleName) or "", spellid or "", bar_text or "", time or 0, icon or ""}
                    end
                end
            end

            if (BigWigsLoader.RegisterMessage) then
                BigWigsLoader.RegisterMessage(Details, "BigWigs_StartBar")
            end
        end
    end

    Details.Schedules.NewTimer(5, Details.RegisterBigWigsCallBack, Details)
end
