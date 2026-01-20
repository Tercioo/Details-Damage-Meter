


--[=[
    You don't need to get the library object. There is no LibStub.
    There is one global function to call to retrieve a player info table.
    There is two global functions to register and unregister a function to receive callbacks.
    
    API:

    local playerInfo = GetPlayerInfo(playerName)
    Example: /dump GetPlayerInfo(UnitName("player"))

    --to register callbacks, this function is triggered when any event happen.
    local myCallbackFunction = function(eventId, playerInfo)
        if (eventId == PlayerInfoEnums.Callbacks.DURABILITY_UPDATE) then --"DURABILITY_UPDATE"
            print("Player:", playerInfo.name, "Durability:", playerInfo.durability, "Lowest Gear Durability:", playerInfo.lowestGearDurability)
        elseif (eventId == PlayerInfoEnums.Callbacks.SPECID_UPDATE) then --"SPECID_UPDATE"
            print("Player:", playerInfo.name, "SpecId:", playerInfo.specId)
        elseif (eventId == PlayerInfoEnums.Callbacks.ITEMLEVEL_UPDATE) then --"ITEMLEVEL_UPDATE"
            print("Player:", playerInfo.name, "ItemLevel:", playerInfo.itemLevel)
        elseif (eventId == PlayerInfoEnums.Callbacks.TALENTS_UPDATE) then --"TALENTS_UPDATE"
            print("Player:", playerInfo.name, "Talents:", playerInfo.talents)
        end
    end
    RegisterPlayerInfoCallback(myCallbackFunction) --player info library

    --to unregister use:
    UnregisterPlayerInfoCallback(myCallbackFunction) --player info library
--]=]


--[[

últimas alteraçoes (11 de dezembro de 2025):
o que fazer ainda:
- adicionar heroTalentId para o playerInfo
- adicionar talentVersion para o playerInfo dizendo se é vanilla, etc.
- testar comm com 2 clientes
- testar comm repetidas (que fica enviando uma após a outra)
- testar o que já esta feito
- testar sem acecomm
- testar para hacks

- testar o tamanho da string que está sendo enviada
- fazer o cache de cvar ser salvo e carregado na inicialização
- fazer pegar os talentos do classic (pandaria) e remix: legion

- fazer enviar a mythic stone
- enviar textos
- enviar nicknames

- vanilla: fazer a lista de spec/texture para as demais classes.

--]]



--[=[
search keys:
~internal
~comms
~timers
~callbacks

~unitinfo
~equipment
~opennotes
~cooldowns
~keystones


Please refer to the docs.txt within this file folder for a guide on how to use this library.
If you get lost on implementing the lib, be free to contact Tercio on Details! discord: https://discord.gg/AGSzAZX or email to terciob@gmail.com
--PLAYER_AVG_ITEM_LEVEL_UPDATE
UnitID:
    UnitID use: "player", "target", "raid18", "party3", etc...
    If passing the unit name, use GetUnitName(unitId, true) or Ambiguate(playerName, 'none')

Code Rules:
    - When a function or variable name refers to 'Player', it indicates the local player.
    - When 'Unit' is use instead, it indicates any entity.
    - Internal callbacks are the internal communication of the library, e.g. when an event triggers it send to all modules that registered that event.
    - Public callbacks are callbacks registered by an external addon.

TODO:
    - add into gear info how many tier set parts the player has
    - raid lockouts normal-heroic-mythic

BUGS:
    - after a /reload, it is not starting new tickers for spells under cooldown

--]=]

do
    --return
end

---@class classictalentinfo : table
---@field isExceptional boolean
---@field talentID number
---@field known boolean
---@field maxRank number
---@field hasGoldBorder boolean
---@field tier number
---@field selected boolean
---@field icon number
---@field grantedByAura boolean
---@field meetsPreviewPrereq boolean
---@field previewRank number
---@field meetsPrereq boolean
---@field name string
---@field isPVPTalentUnlocked boolean
---@field column number
---@field rank number
---@field available boolean
---@field spellID number

---@class enum_talentversion : table
---@field Vanilla number
---@field Pandaria number
---@field Legion number
---@field Dragonflight number
---@field HeroTalents number

---@class enum_callbacks : table
---@field DURABILITY_UPDATE string
---@field SPECID_UPDATE string
---@field ITEMLEVEL_UPDATE string
---@field TALENTS_UPDATE string
---@field KEYSTONE_UPDATE string

---@class playerinfo_enum : table
---@field TalentVersion enum_talentversion
---@field Callbacks enum_callbacks

---@class Enum : table

---@diagnostic disable-next-line: undefined-global
local Enum = Enum

local thisVersion = 1

PLAYER_INFO_VERSION = PLAYER_INFO_VERSION or 0

if (PLAYER_INFO_VERSION < thisVersion) then
    PLAYER_INFO_VERSION = thisVersion
else
    return
end

--~const

local debug = false
local debugCommReceived = false
local debugFullDataCommReceived = false
local canRunTests = false
local CONST_DEBUG_COMM_PROCESSING = false
local DIAGNOSTIC_COMMRECEIVED_ENABLED = false

local CONST_COMM_PREFIX = "PITB"
local CONST_COMM_FULLINFO_PREFIX = "F"
local CONST_COMM_BURST_BUFFER_COUNT = 9
local CONST_COMM_DURABILITY_PREFIX = "D"
local CONST_COMM_SPECID_PREFIX = "S"
local CONST_COMM_ILEVEL_PREFIX = "I"
local CONST_COMM_TALENTS_PREFIX = "T"
local CONST_COMM_REQUEST_FULLINFO_PREFIX = "R"
local CONST_COMM_KEYSTONE_PREFIX = "K"

local GetContainerNumSlots = GetContainerNumSlots or C_Container.GetContainerNumSlots
local GetContainerItemID = GetContainerItemID or C_Container.GetContainerItemID
local GetContainerItemLink = GetContainerItemLink or C_Container.GetContainerItemLink

local printog = _G.print
local print = function(...) if (debug) then printog(...) end end

local screamMessageSent = {}
local scream = function(...)
    local message = ...
    if (screamMessageSent[message]) then
        return
    end
    screamMessageSent[message] = true
    printog("|cFFFFAA00[PlayerInfo|Details!]|r", ...)
    printog(debugstack())
end

---@diagnostic disable-next-line: undefined-global
local GetSpecialization = C_SpecializationInfo and C_SpecializationInfo.GetSpecialization or GetSpecialization or function() return 0 end
---@diagnostic disable-next-line: undefined-global
local GetSpecializationInfo = C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo or GetSpecializationInfo or function() return 0 end
---@diagnostic disable-next-line: undefined-global
local IsEventValid = C_EventUtils.IsEventValid
local versionString, revision, launchDate, gameVersion = GetBuildInfo()
local unpack = table.unpack or _G.unpack

--a list of functions to be executed after the player enters in the world
local tests = {}
local runTests = function()
    if not debug then return end
    if not canRunTests then return end
    for i = 1, #tests do
        local testFunc = tests[i]
        xpcall(testFunc, geterrorhandler())
    end
end

---@type playerinfo_enum
local enum = {
    TalentVersion = {
        Vanilla = 0,
        Legion = 1,
        Dragonflight = 2,
        HeroTalents = 3,
        Pandaria = 4,
    },

    Callbacks = {
        DURABILITY_UPDATE = "DURABILITY_UPDATE",
        SPECID_UPDATE = "SPECID_UPDATE",
        ITEMLEVEL_UPDATE = "ITEMLEVEL_UPDATE",
        TALENTS_UPDATE = "TALENTS_UPDATE",
        KEYSTONE_UPDATE = "KEYSTONE_UPDATE",
    },
}

---@type keystoneinfo
local keystoneTablePrototype = {
    level = 0,
    mapID = 0,
    challengeMapID = 0,
    classID = 0,
    rating = 0,
    mythicPlusMapID = 0,
    specID = 0,
}

_G.PlayerInfoEnums = enum --[[GLOBAL]]
_G.PlayerInfoData = _G.PlayerInfoData or {} --[[GLOBAL]]

--> helpers

---pack a table into a string separating values with commas
---example: table: {1, 2, 3, 4, 5, 6, 7, 8, 9}
---returned string: "9,1,2,3,4,5,6,7,8,9", where the first number is the total size of table
---@param table table
---@return string
local t_pack = function(table)
    local tableSize = #table
    local newString = "" .. tableSize .. ","
    for i = 1, tableSize do
        newString = newString .. table[i] .. ","
    end
    newString = newString:gsub(",$", "")
    return newString
end

local red = function(str)
    return "|cFFFF0000" .. str .. "|r"
end

local yellow = function(str)
    return "|cFFFFFF00" .. str .. "|r"
end


local _, _, _, buildInfo = GetBuildInfo()
local isTimewalkWoW = function()
    if (buildInfo < 40000) then
        return true
    end
end

local isClassicEra = function()
    if (buildInfo < 20000) then
        return true
    end
end

local gameVersionHasMythicPlus = function()
    return C_ChallengeMode.ClearKeystone and true
end

---merge a key-value table into a single string separating values with commas, where the first index is the key and the second index is the value
---example: {key1 = value1, key2 = value2, key3 = value3}
---returned string: "key1,value1,key2,value2,key3,value3"
---use unpackhash to rebuild the table
local t_packhash = function(table)
    local newString = ""
    for key, value in pairs(table) do
        newString = newString .. key .. "," .. value .. ","
    end
    newString = newString:gsub(",$", "")
    return newString
end

---unpack a string of data into a indexed table, starting from the startIndex also returns the next index to start reading
---expected data: "3,1,2,3,4,5,6,7,8" or {3,1,2,3,4,5,6,7,8}, with the example, the returned table is: {1, 2, 3} and the next index to read is 5 (the second return value)
---@param data string|table
---@param startIndex number?
---@return table, number
local t_unpack = function(data, startIndex)
    local splittedTable

    if (type(data) == "table") then
        splittedTable = data
    else
        splittedTable = {}
        for value in data:gmatch("[^,]+") do
            splittedTable[#splittedTable+1] = value
        end
    end

    local currentIndex = startIndex or 1
    local currentTableSize = tonumber(splittedTable[currentIndex])
    if (not currentTableSize) then
        error("PI: table.unpack: invalid table size.")
    end

    startIndex = (startIndex and startIndex + 1) or 2
    local endIndex = currentIndex + currentTableSize
    local result = {}

    for i = startIndex, endIndex do
        local value = splittedTable[i]
        local asNumber = tonumber(value)
        if (asNumber) then
            table.insert(result, asNumber)
        else
            table.insert(result, value)
        end
    end

    local nextIndex = endIndex + 1
    if (not splittedTable[nextIndex]) then
        return result, 0
    end

    return result, endIndex + 1 --return the position of the last index plus 1 to account for the table size index
end

---unpack a string into a key-value table
---example: "key1,value1,key2,value2,key3,value3" returns {key1 = value1, key2 = value2, key3 = value3}
---@param data string
---@return table
local t_unpackhash = function(data)
    local splittedTable = {}
    for value in data:gmatch("[^,]+") do
        splittedTable[#splittedTable+1] = value
    end

    local result = {}
    for i = 1, #splittedTable, 2 do
        result[splittedTable[i]] = splittedTable[i+1]
    end

    return result
end

--~comms diagnostics
---@class diagnostics : table
---@field onCommReceived fun(stringData:string, sender:string) --prints the uncompressed data received from comms

local diagnostics = {
    onCommReceived = function(stringData, sender)
        print("PlayerInfo: Comm received from:", sender, "data:", stringData)
    end
}

--~comms ~comm
---@class comm : table
---@field aceComm table
---@field eventFrame frame
---@field hasAceComm boolean
---@field isSendingFullUpdate boolean
---@field fullUpdateData string[] un-encoded dataStrings to be send on the next full update
---@field SendData fun(encodedString:string, commChannel:string) send a comm to the target channel, the data must be already compressed and encoded by PrepareData()
---@field PrepareData fun(dataString:string):string|nil compress and encode a string
---@field CanSendComm fun():boolean return true if the player is in a raid or party
---@field ScheduleSendPlayerFullUpdate fun() schedule to send a full player info update to the group
---@field IsSendingFullUpdate fun(self:comm):boolean return true if a full update is being sent
---@field SetSendingFullUpdate fun(self:comm, value:boolean) set if a full update is being sent
---@field AddToFullUpdate fun(self:comm, encodedData:string) add data to be send on the next full update

local getCommChannel = function()
    if IsInRaid() then
        return "RAID"
    elseif IsInGroup() then
        return "PARTY"
    end
    return nil
end

---@type comm
---@diagnostic disable-next-line: missing-fields
local commHandler = {
    aceComm = {}, --if an instance of AceComm exists, it will be embed here
    hasAceComm = false,
    eventFrame = CreateFrame("frame"), --event frame to handle comm events
    isSendingFullUpdate = false,
    IsSendingFullUpdate = function(self) return self.isSendingFullUpdate end,
    SetSendingFullUpdate = function(self, value)
        self.isSendingFullUpdate = value

        if not value then
            local dataString = CONST_COMM_FULLINFO_PREFIX .. "#"

            for i = 1, #self.fullUpdateData do
                if (i == #self.fullUpdateData) then
                    dataString = dataString .. self.fullUpdateData[i]
                else
                    dataString = dataString .. self.fullUpdateData[i] .. "#"
                end
            end

            print("PI:", yellow("Sending full update, data:"), dataString)

            local dataEncoded = self.PrepareData(dataString)

            self.SendData(dataEncoded, getCommChannel())

            --wipe the full update data after finishing sending
            wipe(self.fullUpdateData)

        end
    end,
    fullUpdateData = {},
}

function commHandler:AddToFullUpdate(dataString)
    self.fullUpdateData[#self.fullUpdateData+1] = dataString
end

local handleCommDataFunctions = {}

local registerComm = function()
    local onReceiveComm = function(event, prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID, bIsSafe)
        --check if the data belong to us
        if (prefix == CONST_COMM_PREFIX) then
            sender = Ambiguate(sender, "none")

            --don't receive comms from the player it self
            local playerName = UnitName("player")
            if (playerName == sender) then
                --return
            end

            local encodedData = text

            --decode
            local dataDecoded = C_EncodingUtil.DecodeBase64(encodedData)
            if (not dataDecoded) then
                print(red("problem decoding base64 from player:"), sender, "data:", text)
                return nil
            end

            --decompress
            local dataString = C_EncodingUtil.DecompressString(dataDecoded, Enum.CompressionMethod.Deflate)
            if (not dataString) then
                print(red("UncompressedRun(dataDecoded): C_EncodingUtil.DecompressString failed"), "from player:", sender, "data:", text)
                return nil
            end

            if (DIAGNOSTIC_COMMRECEIVED_ENABLED) then
                diagnostics.onCommReceived(dataString, sender)
            end

            if (type(dataString) ~= "string") then
                print(red("Invalid data from player:"), sender, "data:", text, "data type is:", type(dataString))
                return nil
            end

            --get the first byte of the data, it indicates what type of data was transmitted
            local dataTypePrefix = dataString:match("^.")
            if (not dataTypePrefix) then
                print(red("Invalid dataTypePrefix from player:"), sender, "data:", dataString, "dataTypePrefix:", dataTypePrefix)
                return nil
            end

            if dataTypePrefix == CONST_COMM_FULLINFO_PREFIX then
                dataString = dataString:sub(3)
                local dataParts = {strsplit("#", dataString)}

                if debugFullDataCommReceived then
                    print("PI: fullComm #dataParts:", #dataParts)
                end

                for i = 1, #dataParts do
                    local thisDataString = dataParts[i]
                    local thisDataTypePrefix = thisDataString:match("^.")

                    if debugFullDataCommReceived then
                        print("PI: fullComm thisDataTypePrefix:", thisDataTypePrefix, "thisDataPart:", thisDataString)
                    end

                    local dataHandlerFunc = handleCommDataFunctions[thisDataTypePrefix]
                    if not dataHandlerFunc then
                        print(red("FULL > No data handler for dataTypePrefix:"), thisDataTypePrefix, "from player:", sender, "data:", dataString)
                    else
                        --remove data type prefix
                        thisDataString = thisDataString:sub(2)
                        dataHandlerFunc(sender, thisDataString)
                    end
                end
            else
                --remove data type prefix
                dataString = dataString:sub(2)
                local dataHandlerFunc = handleCommDataFunctions[dataTypePrefix]
                if not dataHandlerFunc then
                    print(red("No data handler for dataTypePrefix:"), dataTypePrefix, "from player:", sender, "data:", dataString)
                    return nil
                end
                dataHandlerFunc(sender, dataString)
            end
        end
    end

    local aceComm = LibStub:GetLibrary("AceComm-3.0", true)
    if (aceComm) then
        --if there is an instance of ace comm, use it to avoid comms sending away without order
        aceComm:Embed(commHandler.aceComm)
        commHandler.aceComm.OnReceiveComm = onReceiveComm
        commHandler.aceComm:RegisterComm(CONST_COMM_PREFIX, "OnReceiveComm")
        commHandler.hasAceComm = true
    else
        commHandler.eventFrame:RegisterEvent("CHAT_MSG_ADDON")
        commHandler.eventFrame:SetScript("OnEvent", onReceiveComm)
        ---@diagnostic disable-next-line: undefined-field
        C_ChatInfo.RegisterAddonMessagePrefix(CONST_COMM_PREFIX)
    end
end

--wait one frame for other libs to load
C_Timer.After(0, registerComm)

local resendTicker
local waitCombatDropAndResend = function()
    if (resendTicker) then
        return
    end

    resendTicker = C_Timer.NewTicker(1, function(ticker)
        if (not InCombatLockdown()) then
            resendTicker:Cancel()
            resendTicker = nil
            --resend full update
            commHandler.ScheduleSendPlayerFullUpdate()
        end
    end)
end

function commHandler.CanSendComm()
    --is dlc 12 or higher
    if gameVersion >= 120000 then
        --test if the player is in combat, if so, do not send comms
        if (IsInRaid() or IsInGroup()) and InCombatLockdown() then
            waitCombatDropAndResend()
            return false
        end
    end

    if CONST_DEBUG_COMM_PROCESSING then
        return true
    end

    return IsInRaid() or IsInGroup()
end

---this function expect the data to be already compressed and encoded
---@param encodedString string
---@param commChannel string
function commHandler.SendData(encodedString, commChannel)
    if (commChannel == "GUILD") then
        if not IsInGuild() then return end
    elseif (commChannel == "RAID") then
        if not IsInRaid() then
            return
        end
        if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
            commChannel = "INSTANCE_CHAT"
        end
    elseif (commChannel == "PARTY") then
        if not IsInGroup() then
            return
        end
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            commChannel = "INSTANCE_CHAT"
        end
    end

    if not commChannel then
        return
    end

    if (commHandler.hasAceComm) then
        --double check if can send comm
        if not commHandler.CanSendComm() then
            return
        end

        local result = commHandler.aceComm:SendCommMessage(CONST_COMM_PREFIX, encodedString, commChannel)
    else
        --double check if can send comm
        if not commHandler.CanSendComm() then
            return
        end
        ---@diagnostic disable-next-line: undefined-field
        C_ChatInfo.SendAddonMessage(CONST_COMM_PREFIX, encodedString, commChannel)
    end
end

function commHandler.PrepareData(dataString)
    --compress
    local compressedData = C_EncodingUtil.CompressString(dataString, Enum.CompressionMethod.Deflate)
    if (not compressedData) then
        print("PrepareData: C_EncodingUtil.CompressString failed", "dataString:", dataString)
        return nil
    end

    --encode
    local encodedData = C_EncodingUtil.EncodeBase64(compressedData)
    if (not encodedData) then
        print("PrepareData: C_EncodingUtil.EncodeBase64 failed", "compressedData:", compressedData)
        return nil
    end

    return encodedData
end

--~callbacks
--when this version of the library is replacing an older, pick the registered callbacks from the old one
local registeredCallbacks = _G.PlayerInfoData.registeredCallbacks or {}
_G.PlayerInfoData.registeredCallbacks = registeredCallbacks

--~test this (not tested yet - Dec,11,2025)

---@class callbacks : table
---@field SendCallback fun(eventId:string, data:table) send a callback to all registered functions

local handleCallbacks = {
    SendCallback = function(eventId, thisPlayerInfo)
        for _, callbackFunc in ipairs(registeredCallbacks) do
            xpcall(callbackFunc, geterrorhandler(), eventId, thisPlayerInfo)
        end
    end,
}

---@param func fun(eventId:string, playerInfo:playerinfo)
_G.RegisterPlayerInfoCallback = function(func) --[[GLOBAL]]
    --check if the function is already registered
    for _, registeredFunc in ipairs(registeredCallbacks) do
        if (registeredFunc == func) then
            return
        end
    end
    registeredCallbacks[#registeredCallbacks + 1] = func
end

_G.UnregisterPlayerInfoCallback = function(func) --[[GLOBAL]]
    for i = #registeredCallbacks, 1, -1 do
        if (registeredCallbacks[i] == func) then
            table.remove(registeredCallbacks, i)
        end
    end
end


--test comm
tests[#tests + 1] = function()
    print("PI: Testing comm...")
    --sending comm test
    commHandler.SendData("Hello World", "GUILD")
end

local CONST_CVAR_TEMPCACHE = "PlayerInfoTempCache"
local CONST_CVAR_TEMPCACHE_DEBUG = "PlayerInfoTempCacheDebug"

C_CVar.RegisterCVar(CONST_CVAR_TEMPCACHE)
C_CVar.RegisterCVar(CONST_CVAR_TEMPCACHE_DEBUG)

local saveCacheOnCVar = function(data)
    C_CVar.SetCVar(CONST_CVAR_TEMPCACHE, data)
end

local getCacheFromCVar = function()
    local data = C_CVar.GetCVar(CONST_CVAR_TEMPCACHE)
    return data
end


local classicTalents = {
    MAGE = {
        [27] = 135807,
        [31] = 135826,
        [75] = 136170,
        [421] = 136222,
        [76] = 135892,
        [77] = 136129,
        [63] = 135857,
        [78] = 135463,
        [24] = 135806,
        [28] = 135815,
        [32] = 135903,
        [1141] = 135813,
        [1649] = 135989,
        [64] = 135852,
        [80] = 136096,
        [33] = 136115,
        [81] = 136116,
        [66] = 135860,
        [82] = 136006,
        [25] = 135827,
        [29] = 135808,
        [34] = 135818,
        [83] = 136153,
        [1142] = 136208,
        [1650] = 136011,
        [68] = 135836,
        [35] = 135817,
        [85] = 135733,
        [741] = 136141,
        [73] = 135855,
        [70] = 135850,
        [86] = 136031,
        [26] = 135812,
        [30] = 135821,
        [1639] = 135820,
        [87] = 136048,
        [69] = 135865,
        [71] = 135988,
        [72] = 135841,
        [88] = 135856,
        [67] = 135849,
        [65] = 135864,
        [37] = 135846,
        [62] = 135840,
        [38] = 135842,
        [61] = 135845,
        [74] = 135894,
        [23] = 135805,
        [36] = 135824
    },
}

local playerInfoDatabase = {}

local _errors = {}
local inGroup = false

local raidUnitIdStringCache = {}
for i = 1, 40 do
    raidUnitIdStringCache[i] = "raid" .. i
end
local partyUnitIdStringCache = {}
for i = 1, 4 do
    partyUnitIdStringCache[i] = "party" .. i
end

---@type table<string, string> [unitId] = playerName
local cacheUnitId = {}
local refreshCacheUnitId = function()
    wipe(cacheUnitId)

    local amountPlayersInGroup = GetNumGroupMembers()

    local isInRaid = IsInRaid()

    if not isInRaid and IsInGroup() then
        amountPlayersInGroup = amountPlayersInGroup - 1
        cacheUnitId["player"] = UnitName("player")
    end

    for i = 1, amountPlayersInGroup do
        local unitId = (isInRaid and raidUnitIdStringCache[i] or partyUnitIdStringCache[i])
        local playerName = GetUnitName(unitId, true)
        if (playerName) then
            playerName = Ambiguate(playerName, "none")
            cacheUnitId[unitId] = playerName
        end
    end
end

---@class playerinfo : table
---@field name string
---@field className string
---@field classSysName string
---@field classId number
---@field level number
---@field specId number?
---@field itemLevel number?
---@field durability number?
---@field lowestGearDurability number?
---@field talents table|string?
---@field keystoneInfo table?

local getPlayerInfo = function(playerName)
    ---@type playerinfo
    local thisPlayerInfo = playerInfoDatabase[playerName]
    if (not thisPlayerInfo) then
        local className, classSysName, classId = UnitClass(playerName)
        local level = UnitLevel(playerName)
        thisPlayerInfo = {
            name = playerName,
            className = className,
            classSysName = classSysName,
            classId = classId,
            level = level,
        }

        if (gameVersionHasMythicPlus()) then
            thisPlayerInfo.keystoneInfo = CopyTable(keystoneTablePrototype)
        end

        playerInfoDatabase[playerName] = thisPlayerInfo
    end
    return thisPlayerInfo
end

local getLocalPlayerInfo = function()
    local playerName = UnitName("player")
    local thisPlayerInfo = getPlayerInfo(playerName)
    return thisPlayerInfo
end

_G.GetPlayerInfo = function(identifier) --[[GLOBAL]]
    local playerName = cacheUnitId[identifier] or identifier
    return playerInfoDatabase[playerName]
end

local isExpansion_Dragonflight = function()
	if (gameVersion >= 100000) then
		return true
	end
end

local isVanilla = function()
    if (gameVersion < 20000) then
        return true
    end
end

local isClassic = function()
    if (gameVersion >= 50000 and gameVersion < 60000) then
        return true
    end
end

local isRetail = function()
    if (gameVersion >= 110000) then
        return true
    end
end

---iterate over all player equipment slots and get the item links
---@return table<number, string> equipmentInfo [slotId] = itemLink
local getPlayerEquipmentInfo = function()
    local equipmentInfo = {}
    for slotId = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
        local itemLink = GetInventoryItemLink("player", slotId)
        if (itemLink) then
            equipmentInfo[#equipmentInfo+1] = itemLink
        end
    end
    return equipmentInfo
end

local getDurability
do --> durability (good on vanilla)
    ---@return number durability between zero and one hundred indicating the player gear durability
    ---@return number lowestGearDurability between zero and one hundred, the lowest durability item percentage of all the player gear
    getDurability = function()
        local durabilityTotalPercent, totalItems = 0, 0
        --hold the lowest item durability of all the player gear
        --this prevent the case where the player has an average of 80% durability but an item with 15% durability
        local lowestGearDurability = 100

        for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
            local durability, maxDurability = GetInventoryItemDurability(i)
            if (durability and maxDurability) then
                local itemDurability = durability / maxDurability * 100

                if (itemDurability < lowestGearDurability) then
                    lowestGearDurability = itemDurability
                end

                durabilityTotalPercent = durabilityTotalPercent + itemDurability
                totalItems = totalItems + 1
            end
        end

        if (totalItems == 0) then
            return 100, lowestGearDurability
        end

        local durability = floor(durabilityTotalPercent / totalItems)
        lowestGearDurability = floor(lowestGearDurability)

        local thisPlayerInfo = getLocalPlayerInfo()
        thisPlayerInfo.durability, thisPlayerInfo.lowestGearDurability = durability, lowestGearDurability

        if commHandler.CanSendComm() then
            --print("I CAn Send CoMMS")
            local dataString = CONST_COMM_DURABILITY_PREFIX .. t_pack({durability, lowestGearDurability})
            if commHandler:IsSendingFullUpdate() then
                commHandler:AddToFullUpdate(dataString)
            else
                local encodedData = commHandler.PrepareData(dataString)
                if CONST_DEBUG_COMM_PROCESSING then
                    print("Durability String:", dataString)
                    print("Durability Encoded:", encodedData)
                end
                commHandler.SendData(encodedData, getCommChannel())
            end
        else
            --print("CANNOT SEND DURABILITTY COm")
        end

        return durability, lowestGearDurability
    end

    --when the player received durability data from another player in the group
    handleCommDataFunctions[CONST_COMM_DURABILITY_PREFIX] = function(senderName, packedData)
        local durabilityData, _ = t_unpack(packedData, 1)
        local durability = durabilityData[1]
        local lowestGearDurability = durabilityData[2]

        local remotePlayerInfo = getPlayerInfo(senderName)
        remotePlayerInfo.durability = durability
        remotePlayerInfo.lowestGearDurability = lowestGearDurability

        if debugCommReceived then
            print("PI: received durability comm", type(durability), durability, type(lowestGearDurability), lowestGearDurability)
        end

        if CONST_DEBUG_COMM_PROCESSING then
            dumpt(remotePlayerInfo)
        end

        handleCallbacks.SendCallback(PlayerInfoEnums.Callbacks.DURABILITY_UPDATE, remotePlayerInfo)
    end

    ---@test durability
    tests[#tests + 1] = function()
        local durability, lowestDurability = getDurability()
        print("PI: Player Durability:", durability, "Lowest Gear Durability:", lowestDurability)
    end
end --end durability

local getSpecId
do --> specializationid
    ---@return number specid the current specId of the player
    getSpecId = function()
        --specialization functions will return zero if thee functions does not exists in the game flavor
        local specId = 0
        ---@diagnostic disable-next-line: missing-parameter
        local spec = GetSpecialization()

        local thisPlayerInfo = getLocalPlayerInfo()

        if (spec) then
            ---@diagnostic disable-next-line: missing-parameter
            specId = GetSpecializationInfo(spec)
            if (specId and specId > 0) then
                thisPlayerInfo.specId = specId
                if commHandler.CanSendComm() then
                    local dataString = CONST_COMM_SPECID_PREFIX .. t_pack({specId})
                    if commHandler:IsSendingFullUpdate() then
                        commHandler:AddToFullUpdate(dataString)
                    else
                        local encodedData = commHandler.PrepareData(dataString)
                        commHandler.SendData(encodedData, getCommChannel())
                    end
                end
                return specId
            end
        end
        return 0
    end

    handleCommDataFunctions[CONST_COMM_SPECID_PREFIX] = function(senderName, dataString)
        local specIdData, _ = t_unpack(dataString, 1)
        local specId = specIdData[1]
        specId = tonumber(specId) or 0

        local remotePlayerInfo = getPlayerInfo(senderName)
        remotePlayerInfo.specId = specId

        if debugCommReceived then
            print("PI: received SpecID comm", type(specId), specId)
        end

        handleCallbacks.SendCallback(PlayerInfoEnums.Callbacks.SPECID_UPDATE, remotePlayerInfo)
    end

    ---@test specializationid
    tests[#tests + 1] = function()
        local specId = getSpecId()
        print("PI: Player SpecId:", specId)
    end
end --end specializationid

local getItemLevel
do --> item level (good on vanilla)
    ---@return number itemLevel the average item level of the player rounded to nearest integer
    getItemLevel = function()
        local thisPlayerInfo = getLocalPlayerInfo()

        if (_G.GetAverageItemLevel) then
            local _, itemLevel = GetAverageItemLevel()
            itemLevel = floor(itemLevel) or 0
            thisPlayerInfo.itemLevel = itemLevel

            if commHandler.CanSendComm() then
                local dataString = CONST_COMM_ILEVEL_PREFIX .. t_pack({itemLevel})
                if commHandler:IsSendingFullUpdate() then
                    commHandler:AddToFullUpdate(dataString)
                else
                    local encodedData = commHandler.PrepareData(dataString)
                    if CONST_DEBUG_COMM_PROCESSING then
                        print("PI: Item Level String:", dataString)
                        print("PI: Item Level Encoded:", encodedData)
                    end
                    commHandler.SendData(encodedData, getCommChannel())
                end
            end

            return itemLevel
        else
            thisPlayerInfo.itemLevel = 0
            return 0
        end
    end

    handleCommDataFunctions[CONST_COMM_ILEVEL_PREFIX] = function(senderName, packedData)
        local itemLevelData, _ = t_unpack(packedData, 1)
        local itemLevel = itemLevelData[1]

        local remotePlayerInfo = getPlayerInfo(senderName)
        remotePlayerInfo.itemLevel = itemLevel

        if debugCommReceived then
            print("PI: received item level comm", type(itemLevel), itemLevel)
        end

        if CONST_DEBUG_COMM_PROCESSING then
            dumpt(remotePlayerInfo)
        end

        handleCallbacks.SendCallback(PlayerInfoEnums.Callbacks.ITEMLEVEL_UPDATE, remotePlayerInfo)
    end

    ---@tests item level
    tests[#tests + 1] = function()
        local itemLevel = getItemLevel()
        print("PI: Player Item Level:", itemLevel)
    end
end --end item level

local getKeystone
do
    local makeArrayToComm = function(keystoneInfo)
        local arrayToSend = {
            keystoneInfo.level,
            keystoneInfo.mapID,
            keystoneInfo.challengeMapID,
            keystoneInfo.classID,
            keystoneInfo.rating,
            keystoneInfo.mythicPlusMapID,
            keystoneInfo.specID,
        }
        return arrayToSend
    end

    local makeKeystoneFromComm = function(packedData)
        local keystoneData, _ = t_unpack(packedData, 1)
        local keystoneInfo = {
            level = keystoneData[1],
            mapID = keystoneData[2],
            challengeMapID = keystoneData[3],
            classID = keystoneData[4],
            rating = keystoneData[5],
            mythicPlusMapID = keystoneData[6],
            specID = keystoneData[7],
        }
        return keystoneInfo
    end

    local sendKeystoneData = function()
        local thisPlayerInfo = getLocalPlayerInfo()
        if commHandler.CanSendComm() then
            local keystoneInfo = thisPlayerInfo.keystoneInfo
            if not keystoneInfo or keystoneInfo.level < 1 then
                return
            end

            local dataString = CONST_COMM_KEYSTONE_PREFIX .. t_pack(makeArrayToComm(keystoneInfo))
            if commHandler:IsSendingFullUpdate() then
                commHandler:AddToFullUpdate(dataString)
            else
                local encodedData = commHandler.PrepareData(dataString)
                if CONST_DEBUG_COMM_PROCESSING then
                    print("PI: Keystone String:", dataString)
                    print("PI: Keystone Encoded:", encodedData)
                end
                commHandler.SendData(encodedData, getCommChannel())
            end
        end
    end

    local getMythicPlusMapID = function()
        for backpackId = 0, 4 do
            for slotId = 1, GetContainerNumSlots(backpackId) do
                local itemId = GetContainerItemID(backpackId, slotId)
                if (itemId == LIB_OPEN_RAID_MYTHICKEYSTONE_ITEMID or itemId == 180653) then
                    local itemLink = GetContainerItemLink(backpackId, slotId)
                    local destroyedItemLink = itemLink:gsub("|", "")
                    local _, _, _, mythicPlusMapID = strsplit(":", destroyedItemLink)
                    return tonumber(mythicPlusMapID)
                end
            end
        end
    end

    local updatePlayerKeystoneInfo = function(thisPlayerInfo)
        local level = C_MythicPlus.GetOwnedKeystoneLevel() or 0
        local mapId = C_MythicPlus.GetOwnedKeystoneMapID() or 0
        local mythicPlusMapId = getMythicPlusMapID() or 0
        local challengeMapId = C_MythicPlus.GetOwnedKeystoneChallengeMapID() or 0

        local _, _, playerClassId = UnitClass("player")
        local classId = playerClassId

        local ratingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
        local rating = ratingSummary and ratingSummary.currentSeasonScore or 0

        local specId = GetSpecializationInfo(GetSpecialization()) or 0

        local keystoneInfo = thisPlayerInfo.keystoneInfo
        keystoneInfo.level = level
        keystoneInfo.mapID = mapId
        keystoneInfo.challengeMapID = challengeMapId
        keystoneInfo.classID = classId
        keystoneInfo.rating = rating
        keystoneInfo.mythicPlusMapID = mythicPlusMapId
        keystoneInfo.specID = specId
    end

    local keystoneChangedTimer

    local checkForKeystoneChange = function()
        --clear the timer reference
        keystoneChangedTimer = nil

        --check if the player has a keystone in the backpack by quering the keystone level
        local level = C_MythicPlus.GetOwnedKeystoneLevel()
        if (not level) then
            return
        end
        local mapId = C_MythicPlus.GetOwnedKeystoneMapID()
        local thisPlayerInfo = getLocalPlayerInfo()

        if (thisPlayerInfo.keystoneInfo.level ~= level or thisPlayerInfo.keystoneInfo.mapID ~= mapId) then
            updatePlayerKeystoneInfo(thisPlayerInfo)
            sendKeystoneData()
        end
    end

    local bagUpdateEventFrame = _G["PlayerInfoBagUpdateFrame"] or CreateFrame("frame", "PlayerInfoBagUpdateFrame")
    if gameVersionHasMythicPlus() then
        --bagUpdateEventFrame:RegisterEvent("BAG_UPDATE")
        --bagUpdateEventFrame:RegisterEvent("ITEM_CHANGED")
    end
    bagUpdateEventFrame:SetScript("OnEvent", function(bagUpdateEventFrame, event, ...)
        if (keystoneChangedTimer) then
            return
        else
            keystoneChangedTimer = C_Timer.NewTimer(2, checkForKeystoneChange)
        end
    end)

    getKeystone = function()
        if not gameVersionHasMythicPlus() then
            return
        end

        local thisPlayerInfo = getLocalPlayerInfo()
        updatePlayerKeystoneInfo(thisPlayerInfo)
        sendKeystoneData()

        return thisPlayerInfo.keystoneInfo
    end

    handleCommDataFunctions[CONST_COMM_KEYSTONE_PREFIX] = function(senderName, packedData)
        local receivedKeystoneInfo = makeKeystoneFromComm(packedData)

        if debugCommReceived then
            print("PI: received keystone comm", type(receivedKeystoneInfo), receivedKeystoneInfo)
        end

        local remotePlayerInfo = getPlayerInfo(senderName)
        local keystoneInfo = remotePlayerInfo.keystoneInfo
        keystoneInfo.level = receivedKeystoneInfo.level
        keystoneInfo.mapID = receivedKeystoneInfo.mapID
        keystoneInfo.challengeMapID = receivedKeystoneInfo.challengeMapID
        keystoneInfo.classID = receivedKeystoneInfo.classID
        keystoneInfo.rating = receivedKeystoneInfo.rating
        keystoneInfo.mythicPlusMapID = receivedKeystoneInfo.mythicPlusMapID
        keystoneInfo.specID = receivedKeystoneInfo.specID

        if CONST_DEBUG_COMM_PROCESSING then
            dumpt(remotePlayerInfo)
        end

        handleCallbacks.SendCallback(PlayerInfoEnums.Callbacks.KEYSTONE_UPDATE, remotePlayerInfo)
    end

    ---@tests item level
    tests[#tests + 1] = function()
        local thisPlayerInfo = getLocalPlayerInfo()
        local keystoneInfo = thisPlayerInfo.keystoneInfo
        if keystoneInfo then
            for k,v in pairs(keystoneInfo) do
                print("   ", k, v)
            end
        end
    end
end

local getTalents
do --> talents
    local getTalentVersion = function()
        if (gameVersion >= 1 and gameVersion <= 40000) then --vanilla tbc wotlk cataclysm
            return enum.TalentVersion.Vanilla
        elseif (gameVersion >= 50000 and gameVersion <= 69999) then --panda wod
            return enum.TalentVersion.Pandaria
        elseif (gameVersion >= 70000 and gameVersion <= 100000) then --legion bfa shadowlands
            return enum.TalentVersion.Legion
        elseif (gameVersion >= 100000 and gameVersion <= 110000) then --dragonflight
            return enum.TalentVersion.Dragonflight
        elseif (gameVersion >= 110000 and gameVersion <= 130000) then --dragonflight
            return enum.TalentVersion.HeroTalents
        end
    end

    ---era, tbc
    ---@return table talents [talentId1, rank1, talentId2, rank2, ...]
    local getVanillaTalents = function()
        local result = {}
        for tabIndex = 1, 3 do
            local numTalents = GetNumTalents(tabIndex)
            for i = 1, MAX_NUM_TALENTS do
                if (i <= numTalents) then
                    local talentInfoQuery = {};
                    talentInfoQuery.specializationIndex = tabIndex
                    talentInfoQuery.talentIndex = i
                    talentInfoQuery.isInspect = false
                    talentInfoQuery.isPet = false
                    talentInfoQuery.groupIndex = PlayerTalentFrame.talentGroup

                    ---@type classictalentinfo
                    local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)

                    if (talentInfo) then
                        local talentId = talentInfo.talentID
                        local rank = talentInfo.rank
                        result[#result + 1] = talentId
                        result[#result + 1] = rank
                    end
                end
            end
        end

        return result
    end

    local buildVanillaTalents = function()
        local b = {}
        for tabIndex = 1, 3 do
            local numTalents = GetNumTalents(tabIndex)
            for i = 1, MAX_NUM_TALENTS do
                if (i <= numTalents) then
                    local talentInfoQuery = {};
                    talentInfoQuery.specializationIndex = tabIndex
                    talentInfoQuery.talentIndex = i
                    talentInfoQuery.isInspect = false
                    talentInfoQuery.isPet = false
                    talentInfoQuery.groupIndex = PlayerTalentFrame.talentGroup

                    ---@type classictalentinfo
                    local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)

                    if (talentInfo) then
                        local talentId = talentInfo.talentID
                        local icon = talentInfo.icon
                        b[talentId] = icon
                    end
                end
            end
        end

        dumpt(b)
    end

    ---@return string
    local getDragonlightTalentAsString = function()
        local activeConfigID = C_ClassTalents.GetActiveConfigID()
        if (activeConfigID and activeConfigID > 0) then
            return C_Traits.GenerateImportString(activeConfigID)
        end
        return ""
    end

    local getHeroTalents = function()
        local configId = C_ClassTalents.GetActiveConfigID()
        if (not configId) then
            return
        end
        local configInfo = C_Traits.GetConfigInfo(configId)
        if (configInfo) then
            for treeIndex, treeId in ipairs(configInfo.treeIDs) do
                local treeNodes = C_Traits.GetTreeNodes(treeId)
                for nodeIdIndex, treeNodeID in ipairs(treeNodes) do
                    local traitNodeInfo = C_Traits.GetNodeInfo(configId, treeNodeID)
                    if (traitNodeInfo) then
                        local activeEntry = traitNodeInfo.activeEntry
                        if (activeEntry) then
                            local entryId = activeEntry.entryID
                            local rank = activeEntry.rank
                            if (rank > 0) then
                                local entryInfo = C_Traits.GetEntryInfo(configId, entryId)
                                if (entryInfo and not entryInfo.definitionID and entryInfo.subTreeID) then
                                    return entryInfo.subTreeID
                                end
                            end
                        end
                    end
                end
            end
        end
        return
    end

    ---@return string
    local dragonFlightTalents = function()
        ---@type string
        local talents = getDragonlightTalentAsString()
        return talents
    end

    ---@return string
    local getPandariaTalents = function()
        ---@type string
        local talents = ""

		local talentGroup = C_SpecializationInfo.GetActiveSpecGroup()

		if (DetailsFramework.IsPandaWow()) then
			for tier = 1, MAX_NUM_TALENT_TIERS do
				local tierAvailable, selectedTalent, tierUnlockLevel = GetTalentTierInfo(tier, 1, false)

				if (selectedTalent) then
					local talentInfoQuery = {}
					talentInfoQuery.tier = tier
					talentInfoQuery.column = selectedTalent
					talentInfoQuery.groupIndex = talentGroup
					talentInfoQuery.isInspect = false
					talentInfoQuery.target = "player"

					---@type talenttierinfo
					local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery)
					if (talentInfo) then
						local talentId = talentInfo.talentID
						talents = talents .. "" .. talentId .. ","
					end
				end
			end
		else
			for i = 1, 7 do
				for o = 1, 3 do
					local talentID, name, texture, selected, available = GetTalentInfo(i, o, 1)
					--print("talentID:", talentID, "name:", name, "texture:", texture, "selected:", selected, "available:", available)
					if (talentID) then
						if (selected) then
							talents = "" .. talentID .. ","
							break
						end
					end
				end
			end
		end

		--remove the comma after the last talent id
		if (talents:sub(-1) == ",") then
			talents = talents:sub(1, -2)
		end

        return talents
    end

    ---@return number
    local getHeroTalentId = function()
        --if is tww or midnight, append hero talents
        if (gameVersion >= 110000 and gameVersion <= 129999) then --tww and midnight
            ---@type number?
            local heroTalentId = getHeroTalents()
            if (heroTalentId) then
                return heroTalentId
            end
        end
        return 0
    end

    getTalents = function()
        --classic era
        if isClassicEra() then
            PlayerTalentFrame_LoadUI()
        else
            local addonName, title, notes, canLoad, reasonCantLoad = C_AddOns.GetAddOnInfo("Blizzard_TalentUI")
            --tbc
            if reasonCantLoad ~= "MISSING" and TalentFrame_LoadUI and not C_AddOns.IsAddOnLoaded("Blizzard_TalentUI") then
                TalentFrame_LoadUI()
            end
        end

        local thisPlayerInfo = getLocalPlayerInfo()

        local talents
        local talentVersion = getTalentVersion()

        --[[
            talent string format:
            all version start with a prefix indicating the version followed by @
            vanilla: table of talentId and rank: {talentId1, rank1, talentId2, rank2, ...}
            dragonflight: string generated by C_Traits.GenerateImportString(activeConfigID)
            hero talents (tww and midnight): append to dragonflight string "@HT" .. heroTalentId
            prefixes:
            V@ - vanilla
            D@ - dragonflight
            T@ - tww midnight
        ]]

        if (talentVersion == enum.TalentVersion.Vanilla) then
            ---@cast talents table
            talents = getVanillaTalents()
            table.insert(talents, 1, "V@")

        elseif (talentVersion == enum.TalentVersion.Dragonflight) then
            ---@cast talents string
            talents = dragonFlightTalents()
            talents = "D@" .. talents

        elseif (talentVersion == enum.TalentVersion.HeroTalents) then --ttw midnight
            ---@cast talents string
            talents = dragonFlightTalents()
            talents = "T@" .. talents
            local heroTalentId = getHeroTalentId()
            if (heroTalentId and heroTalentId > 0) then
                if (type(talents) == "string") then
                    talents = talents .. "@HT" .. heroTalentId
                end
            end

        elseif (talentVersion == enum.TalentVersion.Pandaria) then --pandaria wod
            ---@cast talents string
            talents = getPandariaTalents()
            talents = "P@" .. talents
        end

        thisPlayerInfo.talents = talents

        --send to group
        if commHandler.CanSendComm() then
            local dataString = CONST_COMM_TALENTS_PREFIX .. t_pack(type(talents) == "table" and talents or {talents})
            if commHandler:IsSendingFullUpdate() then
                commHandler:AddToFullUpdate(dataString)
            else
                local encodedData = commHandler.PrepareData(dataString)
                if CONST_DEBUG_COMM_PROCESSING then
                    print("PI: Talents String:", dataString)
                    print("PI: Talents Encoded:", encodedData)
                end
                commHandler.SendData(encodedData, getCommChannel())
            end
        end

        return talents
    end

    ---on receive a comm with player talents
    ---@param senderName string
    ---@param packedData string
    handleCommDataFunctions[CONST_COMM_TALENTS_PREFIX] = function(senderName, packedData)
        ---@type table
        local talentsData = t_unpack(packedData, 1)
        ---@type string
        local talentsDataString = talentsData[1]

        if (not talentsDataString or type(talentsDataString) ~= "string" or talentsDataString == "") then
            if debugCommReceived then
                print("PI: invalid talent comm:", talentsDataString, type(talentsDataString), "Is empty string:", talentsDataString == "")
            end
            return
        end

        local talentsVersion, talents, extraInfo = strsplit("@", talentsDataString)

        if debugCommReceived then
            print("PI: received talent comm", talentsVersion, talents, extraInfo)
        end

        local remotePlayerInfo = getPlayerInfo(senderName)
        remotePlayerInfo.talents = talents

        if CONST_DEBUG_COMM_PROCESSING then
            dumpt(remotePlayerInfo)
        end

        handleCallbacks.SendCallback(PlayerInfoEnums.Callbacks.TALENTS_UPDATE, remotePlayerInfo)
    end

    --talents comm
    --[=[
        local remotePlayerInfo = getPlayerInfo(senderName)
        remotePlayerInfo.durability = durability
        remotePlayerInfo.lowestGearDurability = lowestGearDurability

        handleCallbacks.SendCallback("DURABILITY_UPDATE", remotePlayerInfo)
]=]

    ---@test talents
    tests[#tests + 1] = function()
        local talents = getTalents()
        --C_Timer.After(5, function()
        --    buildVanillaTalents()
        --end)
        print("PI: Player Talents:", talents)
    end
end --end talents


--each function will update the local player first and than send to group ~full
local playerFullUpdate = function()
    --this will trigger 4 comms at the same time, need to create a way to send all this data in a single comm
    commHandler:SetSendingFullUpdate(true)
        getDurability()
        getSpecId()
        getItemLevel()
        getTalents()
        getKeystone()
    commHandler:SetSendingFullUpdate(false)
end

local scheduledUpdate
function commHandler.ScheduleSendPlayerFullUpdate()
    if (scheduledUpdate) then
        return
    end

    scheduledUpdate = C_Timer.NewTimer(2, function()
        playerFullUpdate()
        scheduledUpdate = nil
    end)
end

---@diagnostic disable-next-line: undefined-global
local eventFrame = PlayerInfoTerciobEventFrame or CreateFrame("frame", "PlayerInfoTerciobEventFrame", UIParent)

local eventsToRegister = {
    "PLAYER_LOGIN",
    "UPDATE_INVENTORY_DURABILITY",
    "PLAYER_EQUIPMENT_CHANGED",
    "PLAYER_SPECIALIZATION_CHANGED",
    "ACTIVE_PLAYER_SPECIALIZATION_CHANGED",
    "PLAYER_TALENT_UPDATE",
    "TALENTS_INVOLUNTARILY_RESET",
    "TRAIT_CONFIG_UPDATED",
    "TRAIT_TREE_CURRENCY_INFO_UPDATED",
    "PLAYER_PVP_TALENT_UPDATE",
    "GROUP_ROSTER_UPDATE",
}

for _, eventName in ipairs(eventsToRegister) do
    if IsEventValid(eventName) then
        eventFrame:RegisterEvent(eventName)
    end
end

local schedules = {}
local setSchedule = function(id, func)
    if (schedules[id]) then
        return
    end
    schedules[id] = C_Timer.NewTimer(1, function()
        func()
        schedules[id] = nil
    end)
end

local equipmentChanged = function()
    getItemLevel()
    getDurability()
end

local specTalentChanged = function()
    getSpecId()
    getTalents()
end

local askForGroupMembersData = function()
    if (commHandler.CanSendComm()) then
        local dataString = CONST_COMM_REQUEST_FULLINFO_PREFIX
        local encodedData = commHandler.PrepareData(dataString)
        commHandler.SendData(encodedData, getCommChannel())
    end
end

--when the player received durability data from another player in the group
handleCommDataFunctions[CONST_COMM_REQUEST_FULLINFO_PREFIX] = function(senderName, packedData)
    --a player in the raid is requesting full info, send it
    if commHandler.CanSendComm() then
        commHandler.ScheduleSendPlayerFullUpdate()
    end
end

eventFrame:SetScript("OnEvent", function(self, event, ...) --print("EVENT")
    if (event == "PLAYER_LOGIN") then --~login
        runTests()
        refreshCacheUnitId()
        playerFullUpdate()
        askForGroupMembersData()

    --schedules to avoid executing multiple times in a short period
    elseif (event == "UPDATE_INVENTORY_DURABILITY") then
        setSchedule("UPDATE_INVENTORY_DURABILITY", getDurability)

    elseif (event == "PLAYER_EQUIPMENT_CHANGED") then
        setSchedule("PLAYER_EQUIPMENT_CHANGED", equipmentChanged)

    elseif (event == "PLAYER_SPECIALIZATION_CHANGED" or event == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_TALENT_UPDATE" or event == "TALENTS_INVOLUNTARILY_RESET") then
        setSchedule("PLAYER_SPECIALIZATION_CHANGED", specTalentChanged)

    elseif (event == "GROUP_ROSTER_UPDATE") then
        local wasInGroup = inGroup
        inGroup = IsInGroup()

        if (inGroup) then
            refreshCacheUnitId()

            if (not wasInGroup) then
                --just joined a group, send full update
                commHandler.ScheduleSendPlayerFullUpdate()
            else
                --just updated group members, schedule to send data
                commHandler.ScheduleSendPlayerFullUpdate()
            end
        else
            --just left group
            if (wasInGroup) then
                refreshCacheUnitId()
                --clear all remote player info data
                for playerName, _ in pairs(playerInfoDatabase) do
                    if (playerName ~= UnitName("player")) then
                        playerInfoDatabase[playerName] = nil
                    end
                end
            end
        end
    end
end)
