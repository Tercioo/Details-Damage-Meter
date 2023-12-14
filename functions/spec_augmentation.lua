
local addonName, Details222 = ...
local Details = Details
local _

local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit

local augmentationFunctions = Details222.SpecHelpers[1473]
local augmentationCache = Details222.SpecHelpers[1473].augmentation_cache

local playerRealmName = GetRealmName()





function augmentationFunctions.BuffIn(token, time, sourceSerial, sourceName, sourceFlags, targetSerial, targetName, targetFlags, targetFlags2, spellId, spellName, spellschool, auraType, amount)
    if (not UnitAffectingCombat("player")) then --need documentation
        return
    end

    if (spellId == 395152) then --ebom might on third parties
        local auraName, texture, count, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, v1, v2, v3, v4, v5 = Details:FindBuffCastedByUnitName(targetName, spellId, sourceName)
        local attributeGained = v2

        if (type(attributeGained) == "number") then
            augmentationCache.ebon_might[targetSerial] = augmentationCache.ebon_might[targetSerial] or {}
            local evokerInfo = {sourceSerial, sourceName, sourceFlags, attributeGained}
            table.insert(augmentationCache.ebon_might[targetSerial], evokerInfo)
            --print("ebom might added, cache:", Details.augmentation_cache, #augmentationCache.ebon_might[targetSerial])
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
        augmentationCache.prescience[targetSerial] = augmentationCache.prescience[targetSerial] or {}
        local evokerInfo = {sourceSerial, sourceName, sourceFlags, amount}
        table.insert(augmentationCache.prescience[targetSerial], evokerInfo)

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
        local bFound = false
        augmentationCache.ebon_might[targetSerial] = augmentationCache.ebon_might[targetSerial] or {}

        for index, evokerInfo in ipairs(augmentationCache.ebon_might[targetSerial]) do
            if (evokerInfo[1] == sourceSerial) then
                local auraName, texture, count, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, auraSpellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, v1, v2, v3, v4, v5 = Details:FindBuffCastedByUnitName(targetName, spellId, sourceName)
                local attributeGained = v2

                if (type(attributeGained) == "number") then
                    evokerInfo[4] = attributeGained
                    bFound = true
                    break
                end
            end
        end

        if (not bFound) then
            local auraName, texture, count, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, auraSpellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, v1, v2, v3, v4, v5 = Details:FindBuffCastedByUnitName(targetName, spellId, sourceName)
            local attributeGained = v2
            if (type(attributeGained) == "number") then
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
    if (spellId == 395152) then
        if (augmentationCache.ebon_might[targetSerial]) then
            --print("tinha buff", targetName, targetSerial)
            for index, evokerInfo in ipairs(augmentationCache.ebon_might[targetSerial]) do
                if (evokerInfo[1] == sourceSerial) then
                    --print("ebom might finished, removing from cache:", Details.augmentation_cache, #augmentationCache.ebon_might[targetSerial])
                    table.remove(augmentationCache.ebon_might[targetSerial], index)
                    --print("ebom might finished, removing from cache:", Details.augmentation_cache, #augmentationCache.ebon_might[targetSerial])
                    break
                end
            end
        end

    elseif (spellId == 413984) then
        if (augmentationCache.ss[targetSerial]) then
            for index, evokerInfo in ipairs(augmentationCache.ss[targetSerial]) do
                if (evokerInfo[1] == sourceSerial) then
                    table.remove(augmentationCache.ss[targetSerial], index)
                    break
                end
            end
        end

    elseif (spellId == 410089) then
        if (augmentationCache.prescience[targetSerial]) then
            for index, evokerInfo in ipairs(augmentationCache.prescience[targetSerial]) do
                if (evokerInfo[1] == sourceSerial) then
                    table.remove(augmentationCache.prescience[targetSerial], index)
                    break
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