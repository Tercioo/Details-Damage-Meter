
local addonName, Details222 = ...
local Details = Details
local _

---@type detailsframework
local detailsFramework = DetailsFramework

local CONST_SPELLID_EBONMIGHT = 395152
local CONST_SPELLID_SS = 413984
local CONST_SPELLID_PRESCIENCE = 410089
local CONST_SPELLID_EONS_BREATH = 409560
local CONST_SPELLID_TANK_SHIELD = 360827
local CONST_SPELLID_INFERNOBLESS = 410263

local UnitExists = UnitExists
local GetSpellInfo = Details222.GetSpellInfo
local UnitAuraBySpellName = C_UnitAuras.GetAuraDataBySpellName

local augmentationFunctions = Details222.SpecHelpers[1473]
local augmentationCache = Details222.SpecHelpers[1473].augmentation_cache

local getAmountOfBuffsAppliedBySpellId = function(spellId)
    local amountBuffs = 0
    local spellName = GetSpellInfo(spellId)

    for i, unitId in ipairs(Details222.UnitIdCache.Party) do
        if (UnitExists(unitId)) then
            if UnitAuraBySpellName(unitId, spellName) then
                amountBuffs = amountBuffs + 1
            end
        else
            break
        end
    end

    return amountBuffs
end

local eventListener = Details:CreateEventListener()
eventListener:RegisterEvent("COMBAT_PLAYER_LEAVING", function(eventName, combatObject)
    --check if the expansion the player is playing has the augmentation evokers
    if (not detailsFramework.ExpansionHasAugEvoker()) then
        return
    end

    --close the time on the current amount of prescience stacks the evoker have
    ---@type combat
    local combat = Details:GetCurrentCombat()

    local amountOfAugEvokers = 0

    ---@type actorcontainer
    local damageContainer = combat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
    ---@type actor[]
    local players = {}
    ---@type actor
    local augEvokerObject

    for index, actorObject in damageContainer:ListActors() do
        --is this actor an augmentation evoker?
        if (actorObject.spec == 1473) then
            amountOfAugEvokers = amountOfAugEvokers + 1
            augEvokerObject = actorObject
            players[#players+1] = actorObject

        elseif (actorObject:IsPlayer()) then
            players[#players+1] = actorObject
        end
    end

    if (amountOfAugEvokers == 1 and augEvokerObject) then
        local breathOfEonsDamage = 0
        local infernoBlessingDamage = 0
        local fateMirrorDamage = 0
        local blisteringScalesDamage = 0

        --all players found in the damage container
        for i = 1, #players do
            ---@actor
            local playerObject = players[i]
            local spellContainer = playerObject:GetSpellContainer("spell")

            --get the damage done by this player, where the spell is a spell of the evoker

            local breathOfEons = spellContainer:GetSpell(CONST_SPELLID_EONS_BREATH)
            local infornoBlessing = spellContainer:GetSpell(CONST_SPELLID_INFERNOBLESS)
            local blisteringScales = spellContainer:GetSpell(CONST_SPELLID_TANK_SHIELD)
            local fateMirror = spellContainer:GetSpell(CONST_SPELLID_SS)

            if (breathOfEons and breathOfEons.total >= 1) then
                breathOfEonsDamage = breathOfEonsDamage + breathOfEons.total
            end

            if (infornoBlessing and infornoBlessing.total >= 1) then
                infernoBlessingDamage = infernoBlessingDamage + infornoBlessing.total
            end

            if (blisteringScales and blisteringScales.total >= 1) then
                blisteringScalesDamage = blisteringScalesDamage + blisteringScales.total
            end

            if (fateMirror and fateMirror.total >= 1) then
                fateMirrorDamage = fateMirrorDamage + fateMirror.total
            end
        end

        local augmentedSpellContainer = augEvokerObject.augmentedSpellsContainer

        --add the damage of each spell to a special spell container within the augmentation damage object
        if (breathOfEonsDamage > 0) then
            local bCanCreateSpellIfMissing = true
            local breathOfEonsSpell = augmentedSpellContainer:GetOrCreateSpell(CONST_SPELLID_EONS_BREATH, bCanCreateSpellIfMissing, "SPELL_DAMAGE")
            breathOfEonsSpell.total = breathOfEonsDamage
        end

        if (infernoBlessingDamage > 0) then
            local bCanCreateSpellIfMissing = true
            local infernoBlessingSpell = augmentedSpellContainer:GetOrCreateSpell(CONST_SPELLID_INFERNOBLESS, bCanCreateSpellIfMissing, "SPELL_DAMAGE")
            infernoBlessingSpell.total = infernoBlessingDamage
        end

        if (blisteringScalesDamage > 0) then
            local bCanCreateSpellIfMissing = true
            local blisteringScalesSpell = augmentedSpellContainer:GetOrCreateSpell(CONST_SPELLID_TANK_SHIELD, bCanCreateSpellIfMissing, "SPELL_DAMAGE")
            blisteringScalesSpell.total = blisteringScalesDamage
        end

        if (fateMirrorDamage > 0) then
            local bCanCreateSpellIfMissing = true
            local fateMirrorSpell = augmentedSpellContainer:GetOrCreateSpell(CONST_SPELLID_SS, bCanCreateSpellIfMissing, "SPELL_DAMAGE")
            fateMirrorSpell.total = fateMirrorDamage
        end
    end
end)

--this is called from the parser when a buff is applied and the spellId is registered in the augmentation_aura_list
function augmentationFunctions.BuffIn(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, spellschool, auraType, amount)
    if (not Details.in_combat) then --when the player enter and leave combat, it tracks which players had buffs applied
        return
    end

    if (spellId == 395152) then --ebom might on third parties
        local auraName, texture, count, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, _, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, v1, v2, v3, v4, v5 = Details:FindBuffCastedByUnitName(targetName, spellId, sourceName)
        local attributeGained = v2

        --unit already have the buff from this evoker
        if (type(attributeGained) == "number") then
            if (augmentationCache.ebon_might[targetSerial]) then
                for index, evokerInfo in ipairs(augmentationCache.ebon_might[targetSerial]) do
                    if (evokerInfo[1] == sourceSerial) then
                        evokerInfo[4] = attributeGained
                        return
                    end
                end
            end

            augmentationCache.ebon_might[targetSerial] = augmentationCache.ebon_might[targetSerial] or {}
            local evokerInfo = {sourceSerial, sourceName, sourceFlags, attributeGained}
            table.insert(augmentationCache.ebon_might[targetSerial], evokerInfo)
        end

    elseif (spellId == 413984) then --ss
        if (UnitExists(targetName) and targetName ~= Details.playername) then
            local auraName, texture, count, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, v1, v2, v3, v4, v5 = Details:FindBuffCastedByUnitName(targetName, spellId, sourceName)
            local versaGained = v1
            if (type(versaGained) == "number") then
                augmentationCache.ss[targetSerial] = augmentationCache.ss[targetSerial] or {}
                local ssInfo = {sourceSerial, sourceName, sourceFlags, versaGained}
                table.insert(augmentationCache.ss[targetSerial], ssInfo)
            end
        end

    elseif (spellId == 410089) then --prescience
        --added Prescience to a player (targetName)
        augmentationCache.prescience[targetSerial] = augmentationCache.prescience[targetSerial] or {}
        local evokerInfo = {sourceSerial, sourceName, sourceFlags, amount}
        table.insert(augmentationCache.prescience[targetSerial], evokerInfo)

        ---@type combat
        local currentCombat = Details:GetCurrentCombat()
        ---@type actor
        local evokerUtilityObject = currentCombat:GetContainer(DETAILS_ATTRIBUTE_MISC):GetOrCreateActor(sourceSerial, sourceName, sourceFlags, true)
        local stackInfo = evokerUtilityObject.cleu_prescience_time
        if (not stackInfo) then
            stackInfo = {
                currentStacks = 0,
                stackTime = {0, 0, 0, 0, 0},
                latestStackUpdateTime = GetTime()
            }
            evokerUtilityObject.cleu_prescience_time = stackInfo
        end

        local prescienceApplied = getAmountOfBuffsAppliedBySpellId(CONST_SPELLID_PRESCIENCE)

        if (prescienceApplied > 0) then
            local currentAmountOfApplications = stackInfo.currentStacks
            if (currentAmountOfApplications >= 1 and currentAmountOfApplications <= 5) then
                --the the time the evoker had this amount of stacks
                local timeOfTheLastEvent = stackInfo.latestStackUpdateTime
                local timeNow = GetTime()
                local timeDiff = timeNow - timeOfTheLastEvent
                if (timeDiff > 0) then
                    stackInfo.stackTime[currentAmountOfApplications] = stackInfo.stackTime[currentAmountOfApplications] + timeDiff
                end
            end

            stackInfo.latestStackUpdateTime = GetTime()
            stackInfo.currentStacks = prescienceApplied
        end

    elseif (spellId == 409560) then --eons breath
        local unitIDAffected = Details:FindUnitIDByUnitSerial(targetSerial)
        if (unitIDAffected) then
            local duration, expirationTime = Details:FindDebuffDuration(unitIDAffected, spellId, Details:Ambiguate(sourceName))
            if (duration) then
                local breathTargets = augmentationCache.breath_targets[targetSerial]
                if (not breathTargets) then
                    augmentationCache.breath_targets[targetSerial] = {}
                    breathTargets = augmentationCache.breath_targets[targetSerial]
                end

                --evoker serial, evoker name, evoker flags, target unitID, unixtime, duration, expirationTime (GetTime + duration)
                local eonsBreathInfo = {sourceSerial, sourceName, sourceFlags, unitIDAffected, time, duration, expirationTime}
                table.insert(breathTargets, eonsBreathInfo)
            end
        end

    elseif (spellId == 360827) then --tank shield
        augmentationCache.shield[targetSerial] = augmentationCache.shield[targetSerial] or {}
        local evokerInfo = {sourceSerial, sourceName, sourceFlags, amount}
        table.insert(augmentationCache.shield[targetSerial], evokerInfo)

    elseif (spellId == 410263) then --inferno bless
        augmentationCache.infernobless[targetSerial] = augmentationCache.infernobless[targetSerial] or {}
        local evokerInfo = {sourceSerial, sourceName, sourceFlags}
        table.insert(augmentationCache.infernobless[targetSerial], evokerInfo)
    end
end



function augmentationFunctions.BuffRefresh(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, spellschool, tipo, amount)
    if (spellId == 395152) then
        if (augmentationCache.ebon_might[targetSerial]) then
            for index, evokerInfo in ipairs(augmentationCache.ebon_might[targetSerial]) do
                if (evokerInfo[1] == sourceSerial) then
                    local auraName, texture, count, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, auraSpellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, v1, v2, v3, v4, v5 = Details:FindBuffCastedByUnitName(targetName, spellId, sourceName)
                    local attributeGained = v2

                    if (type(attributeGained) == "number") then
                        evokerInfo[4] = attributeGained
                        return
                    end
                end
            end

            local auraName, texture, count, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, auraSpellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, v1, v2, v3, v4, v5 = Details:FindBuffCastedByUnitName(targetName, spellId, sourceName)
            local attributeGained = v2
            if (type(attributeGained) == "number") then
                Details222.DebugMsg("Ebon Might Refreshed!, but the evoker was not found in the cache (1), adding:", sourceName, sourceSerial, targetName, targetSerial)
                table.insert(augmentationCache.ebon_might[targetSerial], {sourceSerial, sourceName, sourceFlags, attributeGained})
            end
        else
            local auraName, texture, count, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, auraSpellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, v1, v2, v3, v4, v5 = Details:FindBuffCastedByUnitName(targetName, spellId, sourceName)
            local attributeGained = v2
            if (type(attributeGained) == "number") then
                Details222.DebugMsg("Ebon Might Refreshed!, but the evoker was not found in the cache (2), adding:", sourceName, sourceSerial, targetName, targetSerial)
                augmentationCache.ebon_might[targetSerial] = {} --This is needed because the cache was nil
                table.insert(augmentationCache.ebon_might[targetSerial], {sourceSerial, sourceName, sourceFlags, attributeGained})
            end
        end

    elseif (spellId == 413984) then --ss
        if (UnitExists(targetName) and targetName ~= Details.playername) then
            local auraName, texture, count, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, v1, v2, v3, v4, v5 = Details:FindBuffCastedByUnitName (targetName, spellId, sourceName)
            local versaGained = v1

            if (type(versaGained) == "number") then
                local bFound = false
                augmentationCache.ss[targetSerial] = augmentationCache.ss[targetSerial] or {}

                for index, evokerInfo in ipairs(augmentationCache.ss[targetSerial]) do
                    if (evokerInfo[1] == sourceSerial) then
                        evokerInfo[4] = versaGained
                        bFound = true
                        break
                    end
                end

                if (not bFound) then
                    table.insert(augmentationCache.ss[targetSerial], {sourceSerial, sourceName, sourceFlags, versaGained})
                end
            end
        end

    elseif (spellId == 410089) then
        local bFound = false
        augmentationCache.prescience[targetSerial] = augmentationCache.prescience[targetSerial] or {}

        for index, evokerInfo in ipairs(augmentationCache.prescience[targetSerial]) do
            if (evokerInfo[1] == sourceSerial) then
                evokerInfo[4] = amount
                bFound = true
                break
            end
        end

        if (not bFound) then
            table.insert(augmentationCache.prescience[targetSerial], {sourceSerial, sourceName, sourceFlags, amount})
        end
    end
end



function augmentationFunctions.BuffOut(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, spellSchool, tipo, amount)
    if (not Details.in_combat) then --when the player enter and leave combat, it tracks which players had buffs applied
        --return
    end

    if (spellId == 395152) then --ebon might
        if (augmentationCache.ebon_might[targetSerial]) then
            for index, evokerInfo in ipairs(augmentationCache.ebon_might[targetSerial]) do
                if (evokerInfo[1] == sourceSerial) then
                    table.remove(augmentationCache.ebon_might[targetSerial], index)
                    break
                end
            end
        end

    elseif (spellId == 413984) then --ss
        if (augmentationCache.ss[targetSerial]) then
            for index, evokerInfo in ipairs(augmentationCache.ss[targetSerial]) do
                if (evokerInfo[1] == sourceSerial) then
                    table.remove(augmentationCache.ss[targetSerial], index)
                    break
                end
            end
        end

    elseif (spellId == 410089) then --prescience
        if (augmentationCache.prescience[targetSerial]) then
            for index, evokerInfo in ipairs(augmentationCache.prescience[targetSerial]) do
                if (evokerInfo[1] == sourceSerial) then
                    table.remove(augmentationCache.prescience[targetSerial], index)
                    break
                end
            end

            ---@combat
            local currentCombat = Details:GetCurrentCombat()
            local evokerUtilityObject = currentCombat:GetContainer(DETAILS_ATTRIBUTE_MISC):GetOrCreateActor(sourceSerial, sourceName, sourceFlags, true)
            local stackInfo = evokerUtilityObject.cleu_prescience_time

            if (stackInfo) then
                local prescienceApplied = getAmountOfBuffsAppliedBySpellId(CONST_SPELLID_PRESCIENCE)
                if (prescienceApplied >= 0) then
                    local currentAmountOfApplications = stackInfo.currentStacks
                    if (currentAmountOfApplications >= 1 and currentAmountOfApplications <= 5) then
                        --the the time the evoker had this amount of stacks
                        local timeOfTheLastEvent = stackInfo.latestStackUpdateTime
                        local timeNow = GetTime()
                        local timeDiff = timeNow - timeOfTheLastEvent
                        if (timeDiff > 0) then
                            stackInfo.stackTime[currentAmountOfApplications] = stackInfo.stackTime[currentAmountOfApplications] + timeDiff
                        end
                    end

                    stackInfo.latestStackUpdateTime = GetTime()
                    stackInfo.currentStacks = prescienceApplied
                end
            end
        end

    elseif (spellId == 360827) then
        if (augmentationCache.shield[targetSerial]) then
            for index, evokerInfo in ipairs(augmentationCache.shield[targetSerial]) do
                if (evokerInfo[1] == sourceSerial) then
                    table.remove(augmentationCache.shield[targetSerial], index)
                    break
                end
            end
        end

    elseif (spellId == 410263) then
        if (augmentationCache.infernobless[targetSerial]) then
            for index, evokerInfo in ipairs(augmentationCache.infernobless[targetSerial]) do
                if (evokerInfo[1] == sourceSerial) then
                    table.remove(augmentationCache.infernobless[targetSerial], index)
                    break
                end
            end
        end
    end
end