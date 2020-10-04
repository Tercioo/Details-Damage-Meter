
local Details = _G.Details
local bit = _G.bit
local DETAILS_ATTRIBUTE_DAMAGE = _G.DETAILS_ATTRIBUTE_DAMAGE
local DF = _G.DetailsFramework
local tonumber = _G.tonumber
local select = _G.select
local strsplit = _G.strsplit
local floor = _G.floor
local tremove = _G.tremove

Details.packFunctions = {}

--lookup actor information tables
local actorInformation = {}
local actorInformationIndexes = {}
local actorDamageInfo = {}
local actorHealInformation = {}

--flags
local REACTION_HOSTILE	=	0x00000040
local IS_GROUP_OBJECT 	= 	0x00000007
local REACTION_FRIENDLY	=	0x00000010
local OBJECT_TYPE_MASK =	0x0000FC00
local OBJECT_TYPE_OBJECT =	0x00004000
local OBJECT_TYPE_PETGUARDIAN =	0x00003000
local OBJECT_TYPE_GUARDIAN =	0x00002000
local OBJECT_TYPE_PET =		0x00001000
local OBJECT_TYPE_NPC =		0x00000800
local OBJECT_TYPE_PLAYER =	0x00000400

local INDEX_EXPORT_FLAG = 1
local INDEX_COMBAT_START_TIME = 2
local INDEX_COMBAT_END_TIME = 3
local INDEX_COMBAT_START_DATE = 4
local INDEX_COMBAT_END_DATE = 5
local INDEX_COMBAT_NAME = 6

local TOTAL_INDEXES_FOR_COMBAT_INFORMATION = 6

local entitySerialCounter = 0

function Dexport() --test case
    local combat = Details:GetCurrentCombat()
    local readyToSendData = Details.packFunctions.PackCombatData(combat, 0x1)
    local newCombatWithData = Details.packFunctions.UnPackCombatData(readyToSendData)
end

--pack the combat
function Details.packFunctions.PackCombatData(combatObject, flags)

    --0x1 damage
    --0x2 healing
    --0x4 energy
    --0x8 misc

    table.wipe(actorInformation)
    table.wipe(actorInformationIndexes)
    table.wipe(actorDamageInfo)
    table.wipe(actorHealInformation)

    --reset the serial counter
    entitySerialCounter = 0

    local isBossEncouter = combatObject.is_boss
    local startDate, endDate = combatObject:GetDate()

    local startCombatTime = combatObject:GetStartTime() or 0
    local endCombatTime = combatObject:GetEndTime() or 0
    local combatInfo = {
        floor(startCombatTime), --1
        floor(endCombatTime), --2
        startDate, --3
        endDate, --4
        isBossEncouter and isBossEncouter.encounter or "Unknown Enemy" --5
    }

    if (bit.band(flags, 0x1) ~= 0) then
        Details.packFunctions.PackDamage(combatObject)
    end

    if (bit.band(flags, 0x2) ~= 0) then
        Details.packFunctions.PackHeal(combatObject)
    end

    --> prepare data to send over network
        local exportedString = flags .. ","

        --add the combat info
        for index, data in ipairs(combatInfo) do
            exportedString = exportedString .. data .. ","
        end

        --add the actor references table
        for index, data in ipairs(actorInformation) do
            exportedString = exportedString .. data .. ","
        end

        --add the damage actors data
        if (bit.band(flags, 0x1) ~= 0) then
            exportedString = exportedString .. "!D" .. ","
            for index, data in ipairs(actorDamageInfo) do
                exportedString = exportedString .. data .. ","
            end
        end

        --add the heal actors data
        if (bit.band(flags, 0x2) ~= 0) then
            exportedString = exportedString .. "!H" .. ","
            for index, data in ipairs(actorHealInformation) do
                exportedString = exportedString .. data .. ","
            end
        end

        --print("finished export", exportedString) --debug

        --compress
        local LibDeflate = _G.LibStub:GetLibrary("LibDeflate")
        local dataCompressed = LibDeflate:CompressDeflate(exportedString, {level = 9})
        local dataEncoded = LibDeflate:EncodeForWoWAddonChannel(dataCompressed)

        return dataEncoded
end

function Details.packFunctions.GenerateSerialNumber()
    local serialNumber = entitySerialCounter
    entitySerialCounter = entitySerialCounter + 1
    return serialNumber
end

--[[
    actor flag IDs
    1: player friendly
    2: player enemy
    3: enemy npc pet
    4: enemy npc non-pet
    5: friendly npc pet
    6: friendly non-npc
    7: unknown entity type
]]

local packActorFlag = function(actor)
    if (actor.grupo) then
        --it's a player in the group
        return 1
    end

    local flag = actor.flag_original or 0

    --check hostility
    if (bit.band(flag, REACTION_HOSTILE) ~= 0) then
        --is hostile
        if (bit.band(flag, OBJECT_TYPE_PLAYER) == 0) then
            --isn't a player
            if (bit.band(flag, OBJECT_TYPE_PETGUARDIAN) ~= 0) then
                --is pet
                return 3
            else
                --is enemy npc
                return 4
            end
        else
            --is enemy player
            return 2
        end
    else
        --is friendly
        if (bit.band(flag, OBJECT_TYPE_PLAYER) == 0) then
            --is player
            return 1
        else
            --isn't a player
            if (bit.band(flag, OBJECT_TYPE_PETGUARDIAN) ~= 0) then
                --is friendly pet
                return 5
            else
                --is a friendly entity, most likely a npc
                return 6
            end
        end
    end

    return 7
end

local unpackActorFlag = function(flag)
    --convert to integer
    flag = tonumber(flag)

    if (flag == 1) then --player
        return 0x511

    elseif (flag == 2) then --enemy player
        return 0x548

    elseif (flag == 3) then --enemy pet with player or AI controller
        return 0x1A48

    elseif (flag == 4) then --enemy npc
        return 0xA48

    elseif (flag == 5) then --friendly pet
        return 0x1914

    elseif (flag == 6) then --friendly npc
        return 0xA14

    elseif (flag == 7) then --unknown entity
        return 0x4A28
    end
end

local isActorInGroup = function(class, flag)
    if (bit.band (flag, IS_GROUP_OBJECT) ~= 0 and class ~= "UNKNOW" and class ~= "UNGROUPPLAYER" and class ~= "PET") then
        return true
    end
    return false
end

--[[
    actor class IDs
    1-12: player class Id
    20: "PET"
    21: "UNKNOW"
    22: "UNGROUPPLAYER"
    23: "ENEMY"
    24: "MONSTER"
]]

local detailsClassIndexToFileName = {
    [20] = "PET",
    [21] = "UNKNOW",
    [22] = "UNGROUPPLAYER",
    [23] = "ENEMY",
    [24] = "MONSTER",
}

local packActorClass = function(actor)
    local classId = DF.ClassFileNameToIndex[actor.classe]
    if (classId) then
        return classId
    elseif (classId == "PET") then
        return 20
    elseif (classId == "UNKNOW") then
        return 21
    elseif (classId == "UNGROUPPLAYER") then
        return 22
    elseif (classId == "ENEMY") then
        return 23
    elseif (classId == "MONSTER") then
        return 24
    end

    return 21
end

local unpackActorClass = function(classId)
    --convert to integer
    classId = tonumber(classId)

    local classFileName = DF.ClassIndexToFileName[classId]
    if (not classFileName) then
        classFileName = detailsClassIndexToFileName[classId]
    end

    return classFileName
end

--[[
    actor serial
    creature: C12345 (numbers are the npcId)
    player: P
--]]

local packActorSerial = function(actor)
    local serial = actor.serial
    if (serial:match("^C") == "C") then
        local npcId = tonumber(select(6, strsplit("-", serial)) or 0)
        return "C" .. npcId

    elseif (serial:match("^P") == "P") then
        return "P"
    
    elseif (serial == "") then
        return "C12345"
    end
end

local unpackActorSerial = function(serialNumber)
    --player serial
    if (serialNumber:match("^P")) then
        return "Player-1-" .. Details.packFunctions.GenerateSerialNumber()

    elseif (serialNumber:match("^C")) then
        return "Creature-0-0-0-0-" .. serialNumber:gsub("C", "") .."-" .. Details.packFunctions.GenerateSerialNumber()
    end
end

function Details.packFunctions.AddActorInformation(actor)
    --the next index to use on the actor info table
    local currentIndex = #actorInformation + 1

    --calculate where this actor will be placed on the combatData table
    local indexOnCombatDataTable = TOTAL_INDEXES_FOR_COMBAT_INFORMATION + currentIndex

    --add the actor start information index
    actorInformationIndexes[actor.nome] = indexOnCombatDataTable
    
    --index 1: actor name
    actorInformation[currentIndex] = actor.nome or "unnamed" --[1]

    --index 2: actor flag
    actorInformation[currentIndex + 1] = packActorFlag(actor) --[2]

    --index 3: actor serial
    actorInformation[currentIndex + 2] = packActorSerial(actor) or "" --[3]

    --index 4: actor class
    actorInformation[currentIndex + 3] = packActorClass(actor) --[4]

    --index 5: actor spec
    actorInformation[currentIndex + 4] = actor.spec or 0 --[5]

    return indexOnCombatDataTable
end

function Details.packFunctions.RetriveActorInformation(combatData, index)
    --name [1]
    local actorName = combatData[index]
    if (not actorName) then
        return
    end

    --flag [2]
    local actorFlag = combatData[index + 1]
    actorFlag = unpackActorFlag(actorFlag)

    --serial [3]
    local serialNumber = combatData[index + 2]
    serialNumber = unpackActorSerial(serialNumber)

    --class [4]
    local class = combatData[index + 3]
    class = unpackActorClass(class)

    --spec [5]
    local spec = tonumber(combatData[index + 4])

    --return the values
    return actorName, actorFlag, serialNumber, class, spec
end

function Details.packFunctions.PackDamage(combatObject)
    local allActors = combatObject[DETAILS_ATTRIBUTE_DAMAGE]._ActorTable

    --fill the actor information table
    for i = 1, #allActors do
        --get the actor object
        local actor = allActors[i]
        --check if already has the actor information
        local indexToActorInfo = actorInformationIndexes[actor.nome] --actor name
        if (not indexToActorInfo) then
            --need to add the actor general information into the actor information table
            indexToActorInfo = Details.packFunctions.AddActorInformation(actor)
        end
    end

    local spellSize = 0

    for i = 1, #allActors do
        --get the actor object
        local actor = allActors[i]
        local indexToActorInfo = actorInformationIndexes[actor.nome]

        --where the information of this actor starts
        local currentIndex = #actorDamageInfo + 1

        --[1] index where is stored the this actor info like name, class, spec, etc
        actorDamageInfo[currentIndex] = indexToActorInfo  --[1]

        --[2 - 6]
        actorDamageInfo [currentIndex + 1] = floor(actor.total)              --[2]
        actorDamageInfo [currentIndex + 2] = floor(actor.totalabsorbed)      --[3]
        actorDamageInfo [currentIndex + 3] = floor(actor.damage_taken)       --[4]
        actorDamageInfo [currentIndex + 4] = floor(actor.friendlyfire_total) --[5]
        actorDamageInfo [currentIndex + 5] = floor(actor.total_without_pet)  --[6]

        --[=[]]
        --damage taken from (not passing, this list can be rebuilt with spell targets)
        local damageTakenFrom = actor.damage_from
        actorDamageInfo[#actorDamageInfo+1] = Details.packFunctions.CountTableEntriesValid(damageTakenFrom)

        for actorName, _ in pairs(damageTakenFrom) do
            local actorInfoIndex = actorInformationIndexes[actorName]
            if (actorInfoIndex) then
                actorDamageInfo[#actorDamageInfo+1] = actorInfoIndex
            end
        end
        --]=]

        local spellContainer = actor.spells._ActorTable

        --reserve an index to tell the length of spells
        actorDamageInfo [currentIndex + 1] = 0
        local reservedSpellSizeIndex = #actorDamageInfo
        local totalSpellIndexes = 0

        for spellId, spellInfo in pairs(spellContainer) do
            local spellDamage = spellInfo.total
            local spellHits = spellInfo.counter
            local spellTargets = spellInfo.targets
            local spellCasts = 0

            actorDamageInfo [currentIndex + 1] = floor(spellId)
            actorDamageInfo [currentIndex + 1] = floor(spellDamage)
            actorDamageInfo [currentIndex + 1] = floor(spellHits)

            --build targets
            local targetsSize = Details.packFunctions.CountTableEntriesValid(spellTargets)
            actorDamageInfo[#actorDamageInfo + 1] = targetsSize
            totalSpellIndexes = totalSpellIndexes + 3 + targetsSize

            for actorName, damageDone in pairs(spellTargets) do
                local actorInfoIndex = actorInformationIndexes[actorName]
                if (actorInfoIndex) then
                    actorDamageInfo[#actorDamageInfo + 1] = actorInfoIndex
                    actorDamageInfo[#actorDamageInfo + 1] = floor(damageDone)
                    spellSize = spellSize + 2
                end
            end

            spellSize = spellSize + 1
        end

        --amount of indexes spells are using
        actorDamageInfo[reservedSpellSizeIndex] = totalSpellIndexes

    end

    print ("spellSize (debug):", spellSize, #actorDamageInfo)
end

--------------------------------------------------------------------------------------------------------------------------------
--> unpack

--@currentCombat: details! combat object
--@combatData: array with strings with combat information
--@tablePosition: first index of the first damage actor
function Details.packFunctions.UnPackDamage(currentCombat, combatData, tablePosition)

    --get the damage container
    local damageContainer = currentCombat[DETAILS_ATTRIBUTE_DAMAGE]

    --loop from 1 to 199, the amount of actors store is unknown
    --todo: it's only unpacking the first actor from the table, e.g. theres izimode and eye of corruption, after export it only shows the eye of corruption
    --table position does not move forward
    for i = 1, 199 do
        --actor information index in the combatData table
        --this index gives the position where the actor name, class, spec are stored
        local actorReference = tonumber(combatData[tablePosition]) --[1]
        local actorName, actorFlag, serialNumber, class, spec = Details.packFunctions.RetriveActorInformation(combatData, actorReference)

        --check if all damage actors has been processed
        --if there's no actor name it means it reached the end
        if (not actorName) then
            print("damage END index:", i, actorReference, "tablePosition:", tablePosition, "value:", combatData[tablePosition])
            break
        end

        --creata the actor object
        local actorObject = damageContainer:GetOrCreateActor(serialNumber, actorName, actorFlag, true)
        --set the actor class, spec and group
        actorObject.classe = class
        actorObject.spec = spec
        actorObject.grupo = isActorInGroup(class, actorFlag)

        --> copy back the base damage
            actorObject.total =               tonumber(combatData[tablePosition+1]) --[2]
            actorObject.totalabsorbed =       tonumber(combatData[tablePosition+2]) --[3]
            actorObject.damage_taken =        tonumber(combatData[tablePosition+3]) --[4]
            actorObject.friendlyfire_total =  tonumber(combatData[tablePosition+4]) --[5]
            actorObject.total_without_pet  =  tonumber(combatData[tablePosition+5]) --[6]

            tablePosition = tablePosition + 6 --increase table position

        --[=[]]
        --> copy back the damage_from
            --this index stores the amount of indexes used to store the actor references
            local damageFrom_Size = tonumber(combatData[tablePosition]) --[7]
            tablePosition = tablePosition + 1 --increase table position [8]

            if (damageFrom_Size > 0) then
                --restore data damage taken data, table position is on the first damage taken index
                for o = tablePosition, (tablePosition + damageFrom_Size - 1) do
                    local actorReferenceIndex = tonumber(combatData[o])
                    local actorName = Details.packFunctions.RetriveActorInformation(combatData, actorReferenceIndex)
                    actorObject.damage_from[actorName] = true
                end
            end

        tablePosition = tablePosition + damageFrom_Size --increase table position [?]
        --]=]

        --> copy back the actor spells
            --amount of indexes used to store spells for this actor
            local spellsSize = tonumber(combatData[tablePosition]) --[7]
            tablePosition = tablePosition + 1

            local spellIndex = tablePosition
            while(spellIndex < tablePosition + spellsSize) do
                local spellId = combatData [spellIndex] --[1]
                local spellDamage = combatData [spellIndex+1] --[2]
                local spellHits = combatData [spellIndex+2] --[3]

                local targetsSize = combatData [spellIndex+3] --[4]
                local targetTable = Details.packFunctions.UnpackTable(combatData, spellIndex+4, true)

                local spellObject = actorObject.spells:PegaHabilidade(spellId, true) --this one need some translation
                spellObject.total = spellDamage
                spellObject.counter = spellHits
                spellObject.targets = targetTable

                spellIndex = spellIndex + targetsSize + 4
            end

    end

    return tablePosition
end

function Details.packFunctions.PackHeal(combatObject)
    local allActors = combatObject[DETAILS_ATTRIBUTE_HEAL]._ActorTable

    --fill the actor information table
    for i = 1, #allActors do
        --get the actor object
        local actor = allActors[i]
        --check if already has the actor information
        local indexToActorInfo = actorInformationIndexes[actor.nome] --actor name
        if (not indexToActorInfo) then
            --need to add the actor general information into the actor information table
            indexToActorInfo = Details.packFunctions.AddActorInformation(actor)
        end
    end

    for i = 1, #allActors do
        --get the actor object
        local actor = allActors[i]

        --check if already hs the actor information
        local indexToActorInfo = actorInformationIndexes[actor.nome] --actor name
        if (not indexToActorInfo) then
            --need to add the actor general information into the actor information table
            indexToActorInfo = Details.packFunctions.AddActorInformation(actor)
        end

        --where the information of this actor starts
        local currentIndex = #actorHealInformation + 1

        --[1] index where is stored the this actor general information
        actorHealInformation[currentIndex] = indexToActorInfo                    --[1]

        --[2 - 6]
        actorHealInformation [currentIndex + 1] = floor(actor.total)                    --[2]
        actorHealInformation [currentIndex + 2] = floor(actor.totalabsorb)              --[3]
        actorHealInformation [currentIndex + 3] = floor(actor.totalover)                --[4]
        actorHealInformation [currentIndex + 4] = floor(actor.healing_taken)            --[5]
        actorHealInformation [currentIndex + 5] = floor(actor.totalover_without_pet)    --[6]

    end
end

--------------------------------------------------------------------------------------------------------------------------------
--> unpack

function Details.packFunctions.UnPackHeal(currentCombat, combatData, tablePosition)
    --get the damage container
    local healContainer = currentCombat[DETAILS_ATTRIBUTE_HEAL]

    for i = 1, 199 do
        --this is the same as damage, all comments for the code are there
        local actorInfoIndex = tonumber(combatData[tablePosition]) --[1]
        local actorName, actorFlag, serialNumber, class, spec = Details.packFunctions.RetriveActorInformation(combatData, actorInfoIndex)

        --if there's no actor name it means it reached the end
        if (not actorName) then
            print("Heal loop has been stopped", "index:", i, "tablePosition:", tablePosition, "value:", combatData[tablePosition])
            break
        end

        --creata the actor object
        local actorObject = healContainer:GetOrCreateActor(serialNumber, actorName, actorFlag, true)
        --set the actor class, spec and group
        actorObject.classe = class
        actorObject.spec = spec
        actorObject.grupo = isActorInGroup(class, actorFlag)

        --> copy the base healing
        actorObject.total =                 tonumber(combatData[tablePosition+1]) --[2]
        actorObject.totalabsorb =           tonumber(combatData[tablePosition+2]) --[3]
        actorObject.totalover =             tonumber(combatData[tablePosition+3]) --[4]
        actorObject.healing_taken =         tonumber(combatData[tablePosition+4]) --[5]
        actorObject.totalover_without_pet  = tonumber(combatData[tablePosition+5]) --[6]

        --advance the table position
        local indexesUsed = 6
        tablePosition = tablePosition + indexesUsed
    end

    return tablePosition
end

--what this function receives?
--@packedCombatData: packed combat, ready to be unpacked
function Details.packFunctions.UnPackCombatData(packedCombatData)
    local LibDeflate = _G.LibStub:GetLibrary("LibDeflate")
    local dataCompressed = LibDeflate:DecodeForWoWAddonChannel(packedCombatData)
    local combatDataString = LibDeflate:DecompressDeflate(dataCompressed)

    --[=
    local function count(text, pattern)
        return select(2, text:gsub(pattern, ""))
    end
    --]=]

    local combatData = {}
    local amountOfIndexes = count(combatDataString, ",") + 1
    print ("amountOfIndexes (debug):", amountOfIndexes)

    while (amountOfIndexes > 0) do

        local splitPart = {strsplit(",", combatDataString, 4000)} --strsplit(): Stack overflow, max allowed: 4000

        if (#splitPart == 4000 and amountOfIndexes > 4000) then

            print ("#combatDataString (debug) must be > 4000:", amountOfIndexes)
            for i = 1, 3999 do
                combatData[#combatData+1] = splitPart[i]
            end

            --get get part that couldn't be read this loop
            combatDataString = splitPart[4000]
            amountOfIndexes = amountOfIndexes - 3999

            print ("#combatDataString (debug) left over:", amountOfIndexes)
        else
            for i = 1, #splitPart do
                combatData[#combatData+1] = splitPart[i]
            end
            
            amountOfIndexes = amountOfIndexes - #splitPart
        end
    end

    print("total indexes (debug):", #combatData)

    --if true then return end

    local flags = tonumber(combatData[INDEX_EXPORT_FLAG])

    local tablePosition = TOTAL_INDEXES_FOR_COMBAT_INFORMATION + 1 --[[ +1 to jump to damage ]]
    --tablePosition now have the first index of the actorInforTable

    --stop the combat if already in one
    if (Details.in_combat) then
        Details:EndCombat()
    end

    --start a new combat
    Details:StartCombat()
    --get the current combat
    local currentCombat = Details:GetCurrentCombat()

    --check if this export has include damage info
    if (bit.band(flags, 0x1) ~= 0) then
        --find the index where the damage information start
        for i = tablePosition, #combatData do
            if (combatData[i] == "!D") then
                tablePosition = i + 1;
                break
            end
        end

        --unpack damage
        tablePosition = Details.packFunctions.UnPackDamage(currentCombat, combatData, tablePosition)
    end

    if (bit.band(flags, 0x2) ~= 0) then
        --find the index where the heal information start
        for i = tablePosition, #combatData do
            if (combatData[i] == "!H") then
                tablePosition = i + 1;
                break
            end
        end

        --unpack heal
        Details.packFunctions.UnPackHeal(currentCombat, combatData, tablePosition)
    end

    --all done, end combat
    Details:EndCombat()

    --set the start and end of combat time and date
    currentCombat:SetStartTime(combatData[INDEX_COMBAT_START_TIME])
    currentCombat:SetEndTime(combatData[INDEX_COMBAT_END_TIME])
    currentCombat:SetDate(combatData[INDEX_COMBAT_START_DATE], combatData[INDEX_COMBAT_END_DATE])
    currentCombat.enemy = combatData[INDEX_COMBAT_NAME]

    --debug: delete the segment just created (debug)
    --[[
    local combat2 = _detalhes.tabela_historico.tabelas[2]
    if (combat2) then
        tremove (_detalhes.tabela_historico.tabelas, 1)
        _detalhes.tabela_historico.tabelas[1] = combat2
        _detalhes.tabela_vigente = combat2
    end
    --]]
end



--get the amount of entries of a hash table
function Details.packFunctions.CountTableEntries(hasTable)
    local amount = 0
    for _ in pairs(hasTable) do
        amount = amount + 1
    end
    return amount
end

--get the amount of entries and check for validation
function Details.packFunctions.CountTableEntriesValid(hasTable)
    local amount = 0
    for actorName, _ in pairs(hasTable) do
        if (actorInformationIndexes[actorName]) then
            amount = amount + 1
        end
    end
    return amount
end

--stract some indexes of a table
local selectIndexes = function(table, startIndex, amountIndexes)
    local values = {}
    for i = startIndex, amountIndexes do
        values[#values+1] = tonumber(table[i]) or 0
    end
    return unpack(values)
end

function Details.packFunctions.UnpackTable(table, index, isPair, valueAsTable, amountOfValues)
    local result = {}
    local reservedIndexes = table[index]
    local indexStart = index+1
    local indexEnd = reservedIndexes+index

    if (isPair) then
        amountOfValues = amountOfValues or 2
        for i = indexStart, indexEnd, amountOfValues do
            if (valueAsTable) then
                local key = tonumber(table[i])
                result[key] = {selectIndexes(table, i+1, amountOfValues-1)}
            else
                local key = tonumber(table[i])
                local value = tonumber(table[i+1])
                result[key] = value
            end
        end
    else
        for i = indexStart, indexEnd do
            local value = tonumber(table[i])
            result[#result+1] = value
        end
    end

    return result
end