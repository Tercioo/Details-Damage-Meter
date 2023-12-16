

local dversion = 491
local major, minor = "DetailsFramework-1.0", dversion
local DF, oldminor = LibStub:NewLibrary(major, minor)

if (not DF) then
	DetailsFrameworkCanLoad = false
	return
end

_G["DetailsFramework"] = DF

---@cast DF detailsframework

DetailsFrameworkCanLoad = true
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

local _
local type = type
local unpack = unpack
local upper = string.upper
local string_match = string.match
local tinsert = table.insert
local abs = _G.abs
local tremove = _G.tremove

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE

local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapDenied = UnitIsTapDenied

SMALL_NUMBER = 0.000001
ALPHA_BLEND_AMOUNT = 0.8400251

DF.dversion = dversion

DF.AuthorInfo = {
	Name = "Terciob",
	Discord = "https://discord.gg/AGSzAZX",
}

function DF:Msg(msg, ...)
	print("|cFFFFFFAA" .. (self.__name or "Details!Framework:") .. "|r ", msg, ...)
end

function DF:MsgWarning(msg, ...)
	print("|cFFFFFFAA" .. (self.__name or "Details!Framework") .. "|r |cFFFFAA00[Warning]|r", msg, ...)
end

DF.internalFunctions = DF.internalFunctions or {}

local PixelUtil = PixelUtil or DFPixelUtil
if (not PixelUtil) then
	--check if is in classic, TBC, or WotLK wow, if it is, build a replacement for PixelUtil
	local gameVersion = GetBuildInfo()
	if (gameVersion:match("%d") == "1" or gameVersion:match("%d") == "2" or gameVersion:match("%d") == "3") then
		PixelUtil = {
			SetWidth = function(self, width) self:SetWidth(width) end,
			SetHeight = function(self, height) self:SetHeight(height) end,
			SetSize = function(self, width, height) self:SetSize(width, height) end,
			SetPoint = function(self, ...) self:SetPoint(...) end,
		}
	end
end

---return r, g, b, a for the default backdrop color used in addons
---@return number
---@return number
---@return number
---@return number
function DF:GetDefaultBackdropColor()
	return 0.1215, 0.1176, 0.1294, 0.8
end

---return if the wow version the player is playing is dragonflight or an expansion after it
---@return boolean
function DF.IsDragonflightAndBeyond()
	return select(4, GetBuildInfo()) >= 100000
end

---return if the wow version the player is playing is dragonflight
---@return boolean
function DF.IsDragonflight()
	local _, _, _, buildInfo = GetBuildInfo()
	if (buildInfo < 110000 and buildInfo >= 100000) then
		return true
	end
	return false
end

---return if the wow version the player is playing is a classic version of wow
---@return boolean
function DF.IsTimewalkWoW()
    local _, _, _, buildInfo = GetBuildInfo()
    if (buildInfo < 40000) then
        return true
    end
	return false
end

---return if the wow version the player is playing is the vanilla version of wow
---@return boolean
function DF.IsClassicWow()
    local _, _, _, buildInfo = GetBuildInfo()
    if (buildInfo < 20000) then
        return true
    end
	return false
end

---return true if the player is playing in the TBC version of wow
---@return boolean
function DF.IsTBCWow()
    local _, _, _, buildInfo = GetBuildInfo()
    if (buildInfo < 30000 and buildInfo >= 20000) then
        return true
    end
	return false
end

---return true if the player is playing in the WotLK version of wow
---@return boolean
function DF.IsWotLKWow()
    local _, _, _, buildInfo = GetBuildInfo()
    if (buildInfo < 40000 and buildInfo >= 30000) then
        return true
    end
	return false
end

---return true if the player is playing in the WotLK version of wow with the retail api
---@return boolean
function DF.IsNonRetailWowWithRetailAPI()
    local _, _, _, buildInfo = GetBuildInfo()
    if (buildInfo < 40000 and buildInfo >= 30401) or (buildInfo < 20000 and buildInfo >= 11404) then
        return true
    end
	return false
end
DF.IsWotLKWowWithRetailAPI = DF.IsNonRetailWowWithRetailAPI -- this is still in use

---return true if the version of wow the player is playing is the shadowlands
function DF.IsShadowlandsWow()
    local _, _, _, buildInfo = GetBuildInfo()
    if (buildInfo < 100000 and buildInfo >= 90000) then
        return true
    end
	return false
end

---for classic wow, get the role using the texture from the talents frame
local roleBySpecTextureName = {
	DruidBalance = "DAMAGER",
	DruidFeralCombat = "DAMAGER",
	DruidRestoration = "HEALER",

	HunterBeastMastery = "DAMAGER",
	HunterMarksmanship = "DAMAGER",
	HunterSurvival = "DAMAGER",

	MageArcane = "DAMAGER",
	MageFrost = "DAMAGER",
	MageFire = "DAMAGER",

	PaladinCombat = "DAMAGER",
	PaladinHoly = "HEALER",
	PaladinProtection = "TANK",

	PriestHoly = "HEALER",
	PriestDiscipline = "HEALER",
	PriestShadow = "DAMAGER",

	RogueAssassination = "DAMAGER",
	RogueCombat = "DAMAGER",
	RogueSubtlety = "DAMAGER",

	ShamanElementalCombat = "DAMAGER",
	ShamanEnhancement = "DAMAGER",
	ShamanRestoration = "HEALER",

	WarlockCurses = "DAMAGER",
	WarlockDestruction = "DAMAGER",
	WarlockSummoning = "DAMAGER",

	WarriorArm = "DAMAGER",
	WarriorArms = "DAMAGER",
	WarriorFury = "DAMAGER",
	WarriorProtection = "TANK",

	DeathKnightBlood = "TANK",
	DeathKnightFrost = "DAMAGER",
	DeathKnightUnholy = "DAMAGER",
}

---classic, tbc and wotlk role guesser based on the weights of each talent tree
---@return string
function DF:GetRoleByClassicTalentTree()
	if (not DF.IsTimewalkWoW()) then
		return "NONE"
	end

	--amount of tabs existing
	local numTabs = GetNumTalentTabs() or 3

	--store the background textures for each tab
	local pointsPerSpec = {}

	for i = 1, (MAX_TALENT_TABS or 3) do
		if (i <= numTabs) then
			--tab information
			local name, iconTexture, pointsSpent, fileName = GetTalentTabInfo(i)
			if (name) then
				tinsert(pointsPerSpec, {name, pointsSpent, fileName})
			end
		end
	end

	local MIN_SPECS = 4

	--put the spec with more talent point to the top
	table.sort(pointsPerSpec, function(t1, t2) return t1[2] > t2[2] end)

	--get the spec with more points spent
	local spec = pointsPerSpec[1]
	if (spec and spec[2] >= MIN_SPECS) then
		local specName = spec[1]
		local spentPoints = spec[2]
		local specTexture = spec[3]

		local role = roleBySpecTextureName[specTexture]
		return role or "NONE"
	end
	return "DAMAGER"
end

---return the role of the unit, this is safe to use for all versions of wow
---@param unitId string
---@param bUseSupport boolean?
---@param specId number?
---@return string
function DF.UnitGroupRolesAssigned(unitId, bUseSupport, specId)
	if (not DF.IsTimewalkWoW()) then --Was function exist check. TBC has function, returns NONE. -Flamanis 5/16/2022
		local role = UnitGroupRolesAssigned(unitId)

		if (specId == 1473 and bUseSupport) then
			return "SUPPORT"
		end

		if (role == "NONE" and UnitIsUnit(unitId, "player")) then
			local specializationIndex = GetSpecialization() or 0
			local id, name, description, icon, role, primaryStat = GetSpecializationInfo(specializationIndex)
			if (id == 1473 and bUseSupport) then
				return "SUPPORT"
			end
			return id and role or "NONE"
		end

		return role
	else
		--attempt to guess the role by the player spec
		local classLoc, className = UnitClass(unitId)
		if (className == "MAGE" or className == "ROGUE" or className == "HUNTER" or className == "WARLOCK") then
			return "DAMAGER"
		end

		if (Details) then
			--attempt to get the role from Details! Damage Meter
			local guid = UnitGUID(unitId)
			if (guid) then
				local role = Details.cached_roles[guid]
				if (role) then
					return role
				end
			end
		end

		local role = DF:GetRoleByClassicTalentTree()
		return role
	end
end

---return the specializationid of the player it self
---@return number|nil
function DF.GetSpecialization()
	if (GetSpecialization) then
		return GetSpecialization()
	end
	return nil
end

---return the specializationid using the specId
---@param specId unknown
function DF.GetSpecializationInfoByID(specId)
	if (GetSpecializationInfoByID) then
		return GetSpecializationInfoByID(specId)
	end
	return nil
end

function DF.GetSpecializationInfo(...)
	if (GetSpecializationInfo) then
		return GetSpecializationInfo(...)
	end
	return nil
end

function DF.GetSpecializationRole(...)
	if (GetSpecializationRole) then
		return GetSpecializationRole(...)
	end
	return nil
end

--[=[ dump of C_EncounterJournal
	["GetEncountersOnMap"] = function,
	["SetPreviewMythicPlusLevel"] = function,
	["GetLootInfoByIndex"] = function,
	["GetSlotFilter"] = function,
	["IsEncounterComplete"] = function,
	["SetTab"] = function,
	["ResetSlotFilter"] = function,
	["OnOpen"] = function,
	["InstanceHasLoot"] = function,
	["GetSectionIconFlags"] = function,
	["SetPreviewPvpTier"] = function,
	["GetEncounterJournalLink"] = function,
	["GetInstanceForGameMap"] = function,
	["GetSectionInfo"] = function,
	["GetLootInfo"] = function,
	["GetDungeonEntrancesForMap"] = function,
	["OnClose"] = function,
	["SetSlotFilter"] = function,
--]=]

--build dummy encounter journal functions if they doesn't exists
--this is done for compatibility with classic and if in the future EJ_ functions are moved to C_
---@class EncounterJournal : table
---@field EJ_GetInstanceForMap fun(mapId: number)
---@field EJ_GetInstanceInfo fun(journalInstanceID: number)
---@field EJ_SelectInstance fun(journalInstanceID: number)
---@field EJ_GetEncounterInfoByIndex fun(index: number, journalInstanceID: number?)
---@field EJ_GetEncounterInfo fun(journalEncounterID: number)
---@field EJ_SelectEncounter fun(journalEncounterID: number)
---@field EJ_GetSectionInfo fun(sectionID: number)
---@field EJ_GetCreatureInfo fun(index: number, journalEncounterID: number?)
---@field EJ_SetDifficulty fun(difficultyID: number)
---@field EJ_GetNumLoot fun(): number
DF.EncounterJournal = {
	EJ_GetInstanceForMap = EJ_GetInstanceForMap or function() return nil end,
	EJ_GetInstanceInfo = EJ_GetInstanceInfo or function() return nil end,
	EJ_SelectInstance = EJ_SelectInstance or function() return nil end,
	EJ_GetEncounterInfoByIndex = EJ_GetEncounterInfoByIndex or function() return nil end,
	EJ_GetEncounterInfo = EJ_GetEncounterInfo or function() return nil end,
	EJ_SelectEncounter = EJ_SelectEncounter or function() return nil end,
	EJ_GetSectionInfo = EJ_GetSectionInfo or function() return nil end,
	EJ_GetCreatureInfo = EJ_GetCreatureInfo or function() return nil end,
	EJ_SetDifficulty = EJ_SetDifficulty or function() return nil end,
	EJ_GetNumLoot = EJ_GetNumLoot or function() return 0 end,
}

--will always give a very random name for our widgets
local init_counter = math.random(1, 1000000)

DF.LabelNameCounter = DF.LabelNameCounter or init_counter
DF.PictureNameCounter = DF.PictureNameCounter or init_counter
DF.BarNameCounter = DF.BarNameCounter or init_counter
DF.DropDownCounter = DF.DropDownCounter or init_counter
DF.PanelCounter = DF.PanelCounter or init_counter
DF.SimplePanelCounter = DF.SimplePanelCounter or init_counter
DF.ButtonCounter = DF.ButtonCounter or init_counter
DF.SliderCounter = DF.SliderCounter or init_counter
DF.SwitchCounter = DF.SwitchCounter or init_counter
DF.SplitBarCounter = DF.SplitBarCounter or init_counter

DF.FRAMELEVEL_OVERLAY = 750
DF.FRAMELEVEL_BACKGROUND = 150

DF.FrameWorkVersion = tostring(dversion)
function DF:PrintVersion()
	print("Details! Framework Version:", DF.FrameWorkVersion)
end

--get the working folder
do
	local path = string.match(debugstack(1, 1, 0), "AddOns\\(.+)fw.lua")
	if (path) then
		DF.folder = "Interface\\AddOns\\" .. path
	else
		--if not found, try to use the last valid one
		DF.folder = DF.folder or ""
	end
end

DF.debug = false

function DF:GetFrameworkFolder()
	return DF.folder
end

function DF:SetFrameworkDebugState(state)
	DF.debug = state
end


DF.embeds = DF.embeds or {}
local embedFunctions = {
	"RemoveRealName",
	"table",
	"BuildDropDownFontList",
	"SetFontSize",
	"SetFontFace",
	"SetFontColor",
	"GetFontSize",
	"GetFontFace",
	"SetFontOutline",
	"trim",
	"Msg",
	"CreateFlashAnimation",
	"Fade",
	"NewColor",
	"IsHtmlColor",
	"ParseColors",
	"BuildMenu",
	"ShowTutorialAlertFrame",
	"GetNpcIdFromGuid",
	"SetAsOptionsPanel",
	"GetPlayerRole",
	"GetCharacterTalents",
	"GetCharacterPvPTalents",

	"CreateDropDown",
	"CreateButton",
	"CreateColorPickButton",
	"CreateLabel",
	"CreateBar",
	"CreatePanel",
	"CreateFillPanel",
	"ColorPick",
	"IconPick",
	"CreateSimplePanel",
	"CreateChartPanel",
	"CreateImage",
	"CreateScrollBar",
	"CreateSwitch",
	"CreateSlider",
	"CreateSplitBar",
	"CreateTextEntry",
	"Create1PxPanel",
	"CreateOptionsFrame",
	"NewSpecialLuaEditorEntry",
	"ShowPromptPanel",
	"ShowTextPromptPanel",
	"www_icons",
	"GetTemplate",
	"InstallTemplate",
	"GetFrameworkFolder",
	"ShowPanicWarning",
	"SetFrameworkDebugState",
	"FindHighestParent",
	"OpenInterfaceProfile",
	"CreateInCombatTexture",
	"CreateAnimationHub",
	"CreateAnimation",
	"CreateScrollBox",
	"CreateBorder",
	"FormatNumber",
	"IntegerToTimer",
	"QuickDispatch",
	"Dispatch",
	"CommaValue",
	"RemoveRealmName",
	"Trim",
	"CreateGlowOverlay",
	"CreateAnts",
	"CreateFrameShake",
	"RegisterScriptComm",
	"SendScriptComm",
}

function DF:Embed(target)
	for k, v in pairs(embedFunctions) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

function DF:FadeFrame(frame, t)
	if (t == 0) then
		frame.hidden = false
		frame.faded = false
		frame.fading_out = false
		frame.fading_in = false
		frame:Show()
		frame:SetAlpha(1)

	elseif (t == 1) then
		frame.hidden = true
		frame.faded = true
		frame.fading_out = false
		frame.fading_in = false
		frame:SetAlpha(0)
		frame:Hide()
	end
end

------------------------------------------------------------------------------------------------------------
--table

DF.table = {}

---find a value inside a table and return the index
---@param t table
---@param value any
---@return integer|nil
function DF.table.find(t, value)
	for i = 1, #t do
		if (t[i] == value) then
			return i
		end
	end
end

---get a value from a table using a path, e.g. getfrompath(tbl, "a.b.c") is the same as tbl.a.b.c
---@param t table
---@param path string
---@return any
function DF.table.getfrompath(t, path)
	if (path:match("%.") or path:match("%[")) then
		local value

		for key in path:gmatch("[%w_]+") do
			value = t[key] or t[tonumber(key)]

			--check if the value is nil, if it is, the key does not exists in the table
			if (not value) then
				return
			end

			--update t for the next iteration
			t = value
		end

		return value
	else
		return t[path] or t[tonumber(path)]
	end
end

---set the value of a table using a path, e.g. setfrompath(tbl, "a.b.c", 10) is the same as tbl.a.b.c = 10
---@param t table
---@param path string
---@param value any
---@return boolean?
function DF.table.setfrompath(t, path, value)
	if (path:match("%.") or path:match("%[")) then
		local lastTable
		local lastKey

		for key in path:gmatch("[%w_]+") do
			lastTable = t
			lastKey = key

			--update t for the next iteration
			t = t[key] or t[tonumber(key)]
		end

		if (lastTable and lastKey) then
			lastTable[lastKey] = value
			return true
		end
	else
		t[path] = value
		return true
	end

	return false
end

---find the value inside the table, and it it's not found, add it
---@param t table
---@param index integer|any
---@param value any
---@return boolean
function DF.table.addunique(t, index, value)
	if (not value) then
		value = index
		index = #t + 1
	end

	for i = 1, #t do
		if (t[i] == value) then
			return false
		end
	end

	tinsert(t, index, value)
	return true
end

---get the table 't' and reverse the order of the values within it
---@param t table
---@return table
function DF.table.reverse(t)
	local new = {}
	local index = 1
	for i = #t, 1, -1 do
		new[index] = t[i]
		index = index + 1
	end
	return new
end

---copy the values from table2 to table1 overwriting existing values, ignores __index and __newindex, keys pointing to a UIObject are preserved
---@param t1 table
---@param t2 table
---@return table
function DF.table.duplicate(t1, t2)
	for key, value in pairs(t2) do
		if (key ~= "__index" and key ~= "__newindex") then
			--preserve a wowObject passing it to the new table with copying it
			if (type(value) == "table" and table.GetObjectType and table:GetObjectType()) then
				t1[key] = value

			elseif (type(value) == "table") then
				t1[key] = t1[key] or {}
				DF.table.copy(t1[key], t2[key])

			else
				t1[key] = value
			end
		end
	end

	return t1
end

---copy the values from table2 to table1 overwriting existing values, ignores __index and __newindex, threat UIObjects as regular tables
---@param t1 table
---@param t2 table
---@return table
function DF.table.copy(t1, t2)
	for key, value in pairs(t2) do
		if (key ~= "__index" and key ~= "__newindex") then
			if (type(value) == "table") then
				t1[key] = t1[key] or {}
				DF.table.copy(t1[key], t2[key])
			else
				t1[key] = value
			end
		end
	end
	return t1
end

---copy from table2 to table1 overwriting values but do not copy data that cannot be compressed
---@param t1 table
---@param t2 table
---@return table
function DF.table.copytocompress(t1, t2)
	for key, value in pairs(t2) do
		if (key ~= "__index" and type(value) ~= "function") then
			if (type(value) == "table") then
				if (not value.GetObjectType) then
					t1[key] = t1[key] or {}
					DF.table.copytocompress(t1[key], t2[key])
				end
			else
				t1 [key] = value
			end
		end
	end
	return t1
end

---remove from table1 the values that are also on table2
---@param table1 table the table to have the values removed
---@param table2 table the reference table
function DF.table.removeduplicate(table1, table2)
    for key, value in pairs(table2) do
        if (type(value) == "table") then
            if (type(table1[key]) == "table") then
                DF.table.removeduplicate(table1[key], value)
				if (not next(table1[key])) then
					table1[key] = nil
				end
            end
        else
			if (type(table1[key]) == "number" and type(value) == "number") then
				if (DF:IsNearlyEqual(table1[key], value, 0.0001)) then
					table1[key] = nil
				end
			else
            	if (table1[key] == value) then
	                table1[key] = nil
            	end
			end
        end
    end
end

---add the indexes of table2 into the end of the table table1
---@param t1 table
---@param t2 table
---@return table
function DF.table.append(t1, t2)
	for i = 1, #t2 do
		t1[#t1+1] = t2[i]
	end
	return t1
end

---copy values that does exist on table2 but not on table1
---@param t1 table
---@param t2 table
---@return table
function DF.table.deploy(t1, t2)
	for key, value in pairs(t2) do
		if (type(value) == "table") then
			t1[key] = t1[key] or {}
			DF.table.deploy(t1[key], t2[key])
		elseif (t1[key] == nil) then
			t1[key] = value
		end
	end
	return t1
end

local function tableToString(t, resultString, deep, seenTables)
    resultString = resultString or ""
    deep = deep or 0
    seenTables = seenTables or {}

    if seenTables[t] then
        resultString = resultString .. "--CIRCULAR REFERENCE\n"
        return resultString
    end

    local space = string.rep("   ", deep)

    seenTables[t] = true

    for key, value in pairs(t) do
		local valueType = type(value)

		if (type(key) == "function") then
			key = "#function#"
		elseif (type(key) == "table") then
			key = "#table#"
		end

		if (type(key) ~= "string" and type(key) ~= "number") then
			key = "unknown?"
		end

        if (valueType == "table") then
			local sUIObjectType = value.GetObjectType and value:GetObjectType()
			if (sUIObjectType) then
				if (type(key) == "number") then
					resultString = resultString .. space .. "[" .. key .. "] = |cFFa9ffa9 " .. sUIObjectType .. " {|r\n"
				else
					resultString = resultString .. space .. "[\"" .. key .. "\"] = |cFFa9ffa9 " .. sUIObjectType .. " {|r\n"
				end
			else
				if (type(key) == "number") then
					resultString = resultString .. space .. "[" .. key .. "] = |cFFa9ffa9 {|r\n"
				else
					resultString = resultString .. space .. "[\"" .. key .. "\"] = |cFFa9ffa9 {|r\n"
				end
			end
            resultString = resultString .. tableToString(value, nil, deep + 1, seenTables)
            resultString = resultString .. space .. "|cFFa9ffa9},|r\n"

		elseif (valueType == "string") then
			resultString = resultString .. space .. "[\"" .. key .. "\"] = \"|cFFfff1c1" .. value .. "|r\",\n"

		elseif (valueType == "number") then
			resultString = resultString .. space .. "[\"" .. key .. "\"] = |cFF94CEA8" .. value .. "|r,\n"

		elseif (valueType == "function") then
			resultString = resultString .. space .. "[\"" .. key .. "\"] = |cFFC586C0function|r,\n"

		elseif (valueType == "boolean") then
			resultString = resultString .. space .. "[\"" .. key .. "\"] = |cFF99d0ff" .. (value and "true" or "false") .. "|r,\n"
		end
    end

    return resultString
end

local function tableToStringSafe(t)
    local seenTables = {}
    return tableToString(t, nil, 0, seenTables)
end

---get the contends of table 't' and return it as a string
---@param t table
---@param resultString string
---@param deep integer
---@return string
function DF.table.dump(t, resultString, deep)

	if true then return tableToStringSafe(t) end

	resultString = resultString or ""
	deep = deep or 0
	local space = ""
	for i = 1, deep do
		space = space .. "   "
	end

	for key, value in pairs(t) do
		local valueType = type(value)

		if (type(key) == "function") then
			key = "#function#"
		elseif (type(key) == "table") then
			key = "#table#"
		end

		if (type(key) ~= "string" and type(key) ~= "number") then
			key = "unknown?"
		end

		if (valueType == "table") then
			if (type(key) == "number") then
				resultString = resultString .. space .. "[" .. key .. "] = |cFFa9ffa9 {|r\n"
			else
				resultString = resultString .. space .. "[\"" .. key .. "\"] = |cFFa9ffa9 {|r\n"
			end
			resultString = resultString .. DF.table.dump (value, nil, deep+1)
			resultString = resultString .. space .. "|cFFa9ffa9},|r\n"

		elseif (valueType == "string") then
			resultString = resultString .. space .. "[\"" .. key .. "\"] = \"|cFFfff1c1" .. value .. "|r\",\n"

		elseif (valueType == "number") then
			resultString = resultString .. space .. "[\"" .. key .. "\"] = |cFFffc1f4" .. value .. "|r,\n"

		elseif (valueType == "function") then
			resultString = resultString .. space .. "[\"" .. key .. "\"] = function()end,\n"

		elseif (valueType == "boolean") then
			resultString = resultString .. space .. "[\"" .. key .. "\"] = |cFF99d0ff" .. (value and "true" or "false") .. "|r,\n"
		end
	end

	return resultString
end

---grab a text and split it into lines adding each line to an array table
---@param text string
---@return table
function DF:SplitTextInLines(text)
	local lines = {}
	local position = 1
	local startScope, endScope = text:find("\n", position, true)

	while (startScope) do
		if (startScope ~= 1) then
			tinsert(lines, text:sub(position, startScope-1))
		end
		position = endScope + 1
		startScope, endScope = text:find("\n", position, true)
	end

	if (position <= #text) then
		tinsert(lines, text:sub(position))
	end

	return lines
end

DF.strings = {}

---receive an array and output a string with the values separated by commas
---if bDoCompression is true, the string will be compressed using LibDeflate
---@param t table
---@param bDoCompression boolean|nil
---@return string
function DF.strings.tabletostring(t, bDoCompression)
	local newString = ""
	for i = 1, #t do
		newString = newString .. t[i] .. ","
	end

	newString = newString:sub(1, -2)

	if (bDoCompression) then
		local LibDeflate = LibStub:GetLibrary("LibDeflate")
		if (LibDeflate) then
			newString = LibDeflate:CompressDeflate(newString, {level = 9})
		end
	end

	return newString
end

function DF.strings.stringtotable(thisString, bDoCompression)
	if (bDoCompression) then
		local LibDeflate = LibStub:GetLibrary("LibDeflate")
		if (LibDeflate) then
			thisString = LibDeflate:DecompressDeflate(thisString)
		end
	end

	local newTable = {strsplit(",", thisString)}
	return newTable
end

DF.www_icons = {
	texture = "feedback_sites",
	wowi = {0, 0.7890625, 0, 37/128},
	curse = {0, 0.7890625, 38/123, 79/128},
	mmoc = {0, 0.7890625, 80/123, 123/128},
}

local symbol_1K, symbol_10K, symbol_1B
if (GetLocale() == "koKR") then
	symbol_1K, symbol_10K, symbol_1B = "천", "만", "억"

elseif (GetLocale() == "zhCN") then
	symbol_1K, symbol_10K, symbol_1B = "千", "万", "亿"

elseif (GetLocale() == "zhTW") then
	symbol_1K, symbol_10K, symbol_1B = "千", "萬", "億"
end

---get the game localization and return which symbol need to be used after formatting numbers, this is for asian languages
---@return string
---@return string
---@return string
function DF:GetAsianNumberSymbols()
	if (GetLocale() == "koKR") then
		return "천", "만", "억"

	elseif (GetLocale() == "zhCN") then
		return "千", "万", "亿"

	elseif (GetLocale() == "zhTW") then
		return "千", "萬", "億"
	else
		--return korean as default (if the language is western)
		return "천", "만", "억"
	end
end

if (symbol_1K) then
	---if symbol_1K is valid, the game has an Asian localization, 'DF.FormatNumber' will use Asian symbols to format numbers
	---@param number number
	---@return string
	function DF.FormatNumber(number)
		if (number > 99999999) then
			return format("%.2f", number/100000000) .. symbol_1B
		elseif (number > 999999) then
			return format("%.2f", number/10000) .. symbol_10K
		elseif (number > 99999) then
			return floor(number/10000) .. symbol_10K
		elseif (number > 9999) then
			return format("%.1f", (number/10000)) .. symbol_10K
		elseif (number > 999) then
			return format("%.1f", (number/1000)) .. symbol_1K
		end
		return format("%.1f", number)
	end
else
	---if symbol_1K isn't valid, 'DF.FormatNumber' will use western symbols to format numbers
	---@param number number
	---@return string|number
	function DF.FormatNumber(number)
		if (number > 999999999) then
			return format("%.2f", number/1000000000) .. "B"
		elseif (number > 999999) then
			return format("%.2f", number/1000000) .. "M"
		elseif (number > 99999) then
			return floor(number/1000) .. "K"
		elseif (number > 999) then
			return format("%.1f", (number/1000)) .. "K"
		end
		return floor(number)
	end
end

---format a number with commas
---@param self table
---@param value number
---@return string
function DF:CommaValue(value)
	if (not value) then
		return "0"
	end

	value = floor(value)
	if (value == 0) then
		return "0"
	end

	--source http://richard.warburton.it
	local left, num, right = string_match (value, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)','%1,'):reverse()) .. right
end

---call the function 'callback' for each group member passing the unitID and the extra arguments
---@param self table
---@param callback function
---@vararg any
function DF:GroupIterator(callback, ...)
	if (IsInRaid()) then
		for i = 1, GetNumGroupMembers() do
			DF:QuickDispatch(callback, "raid" .. i, ...)
		end

	elseif (IsInGroup()) then
		for i = 1, GetNumGroupMembers() - 1 do
			DF:QuickDispatch(callback, "party" .. i, ...)
		end
		DF:QuickDispatch(callback, "player", ...)

	else
		DF:QuickDispatch(callback, "player", ...)
	end
end

---receives an object and a percent amount, then calculate the return value by multiplying the min value of the object width or height by the percent received
---@param uiObject uiobject
---@param percent number
---@return number
function DF:GetSizeFromPercent(uiObject, percent)
	local width, height = uiObject:GetSize()
	local minValue = math.min(width, height)
	return minValue * percent
end

---get an integer an format it as string with the time format 16:45
---@param self table
---@param value number
---@return string
function DF:IntegerToTimer(value) --~formattime
	return "" .. math.floor(value/60) .. ":" .. string.format("%02.f", value%60)
end

---remove the realm name from a name
---@param self table
---@param name string
---@return string, number
function DF:RemoveRealmName(name)
	return name:gsub(("%-.*"), "")
end

---remove the owner name of the pet or guardian
---@param self table
---@param name string
---@return string, number
function DF:RemoveOwnerName(name)
	return name:gsub((" <.*"), "")
end

---remove realm and owner names also remove brackets from spell actors
---@param self table
---@param name string
---@return string
function DF:CleanUpName(name)
	name =  DF:RemoveRealmName(name)
	name = DF:RemoveOwnerName(name)
	name = name:gsub("%[%*%]%s", "")
	return name
end

---remove the realm name from a name
---@param self table
---@param name string
---@return string, number
function DF:RemoveRealName(name)
	return name:gsub(("%-.*"), "")
end

---get the UIObject of type 'FontString' named fontString and set the font size to the maximum value of the arguments
---@param self table
---@param fontString fontstring
---@vararg number
function DF:SetFontSize(fontString, ...)
	local font, _, flags = fontString:GetFont()
	fontString:SetFont(font, math.max(...), flags)
end

---get the UIObject of type 'FontString' named fontString and set the font to the argument fontface
---@param self table
---@param fontString fontstring
---@param fontface string
function DF:SetFontFace(fontString, fontface)
	local font = SharedMedia:Fetch("font", fontface, true)
	if (font) then
		fontface = font
	end

	local _, size, flags = fontString:GetFont()
	return fontString:SetFont(fontface, size, flags)
end

---get the FontString passed and set the font color
---@param self table
---@param fontString fontstring
---@param r any
---@param g number?
---@param b number?
---@param a number?
function DF:SetFontColor(fontString, r, g, b, a)
	r, g, b, a = DF:ParseColors(r, g, b, a)
	fontString:SetTextColor(r, g, b, a)
end

---get the FontString passed and set the font shadow color and offset
---@param self table
---@param fontString fontstring
---@param r any
---@param g number?
---@param b number?
---@param a number?
---@param x number?
---@param y number?
function DF:SetFontShadow(fontString, r, g, b, a, x, y)
	r, g, b, a = DF:ParseColors(r, g, b, a)
	fontString:SetShadowColor(r, g, b, a)

	local offSetX, offSetY = fontString:GetShadowOffset()
	x = x or offSetX
	y = y or offSetY

	fontString:SetShadowOffset(x, y)
end

---get the FontString object passed and set the rotation of the text shown
---@param self table
---@param fontString fontstring
---@param degrees number
function DF:SetFontRotation(fontString, degrees) --deprecated, use fontString:SetRotation(degrees) | retail use fontString:SetRotation(math.rad(degrees))
	if (type(degrees) == "number") then
		if (not fontString.__rotationAnimation) then
			fontString.__rotationAnimation = DF:CreateAnimationHub(fontString)
			fontString.__rotationAnimation.rotator = DF:CreateAnimation(fontString.__rotationAnimation, "rotation", 1, 0, 0)
			fontString.__rotationAnimation.rotator:SetEndDelay(10^8)
			fontString.__rotationAnimation.rotator:SetSmoothProgress(1)
		end
		fontString.__rotationAnimation.rotator:SetDegrees(degrees)
		fontString.__rotationAnimation:Play()
		fontString.__rotationAnimation:Pause()
	end
end

---receives a string and a color and return the string wrapped with the color using |c and |r scape codes
---@param self table
---@param text string
---@param color any
---@return string
function DF:AddColorToText(text, color) --wrap text with a color
	local r, g, b = DF:ParseColors(color)
	if (not r) then
		return text
	end

	local hexColor = DF:FormatColor("hex", r, g, b)

	text = "|c" .. hexColor .. text .. "|r"

	return text
end

---receives a string 'text' and a class name and return the string wrapped with the class color using |c and |r scape codes
---@param self table
---@param text string
---@param className string
---@return string
function DF:AddClassColorToText(text, className)
	if (type(className) ~= "string") then
		return DF:RemoveRealName(text)

	elseif (className == "UNKNOW" or className == "PET") then
		return DF:RemoveRealName(text)
	end

	local color = RAID_CLASS_COLORS[className]
	if (color) then
		text = "|c" .. color.colorStr .. DF:RemoveRealName(text) .. "|r"
	else
		return DF:RemoveRealName(text)
	end

	return text
end

---returns the class icon texture coordinates and texture file path
---@param class string
---@return number, number, number, number, string
function DF:GetClassTCoordsAndTexture(class)
	local l, r, t, b = unpack(CLASS_ICON_TCOORDS[class])
	return l, r, t, b, [[Interface\WORLDSTATEFRAME\Icons-Classes]]
end

---create a string with the spell icon and the spell name using |T|t scape codes to add the icon inside the string
---@param self table
---@param spellId any
---@return string
function DF:MakeStringFromSpellId(spellId)
	local spellName, _, spellIcon = GetSpellInfo(spellId)
	if (spellName) then
		return "|T" .. spellIcon .. ":16:16:0:0:64:64:4:60:4:60|t " .. spellName
	end
	return ""
end

---wrap 'text' with the class icon of 'playerName' using |T|t scape codes
---@param text string
---@param playerName string
---@param englishClassName string this is the english class name, not the localized one, english class name is upper case
---@param useSpec boolean|nil
---@param iconSize number|nil
---@return string
function DF:AddClassIconToText(text, playerName, englishClassName, useSpec, iconSize)
	local size = iconSize or 16

	local spec
	if (useSpec) then
		if (Details) then
			local GUID = UnitGUID(playerName)
			if (GUID) then
				spec = Details.cached_specs[GUID]
				if (spec) then
					spec = spec
				end
			end
		end
	end

	if (spec) then --if spec is valid, the user has Details! installed
		local specString = ""
		local L, R, T, B = unpack(Details.class_specs_coords[spec])
		if (L) then
			specString = "|TInterface\\AddOns\\Details\\images\\spec_icons_normal:" .. size .. ":" .. size .. ":0:0:512:512:" .. (L * 512) .. ":" .. (R * 512) .. ":" .. (T * 512) .. ":" .. (B * 512) .. "|t"
			return specString .. " " .. text
		end
	end

	if (englishClassName) then
		local classString = ""
		--Details.class_coords uses english class names as keys and the values are tables containing texture coordinates
		local L, R, T, B = unpack(Details.class_coords[englishClassName])
		if (L) then
			local imageSize = 128
			classString = "|TInterface\\AddOns\\Details\\images\\classes_small:" .. size .. ":" .. size .. ":0:0:" .. imageSize .. ":" .. imageSize .. ":" .. (L * imageSize) .. ":" .. (R * imageSize) .. ":" .. (T * imageSize) .. ":" .. (B * imageSize) .. "|t"
			return classString .. " " .. text
		end
	end

	return text
end

---create a table with information about a texture
---@param texture any
---@param textureWidth any
---@param textureHeight any
---@param imageWidth any
---@param imageHeight any
---@param left any
---@param right any
---@param top any
---@param bottom any
---@return table
function DF:CreateTextureInfo(texture, textureWidth, textureHeight, left, right, top, bottom, imageWidth, imageHeight)
	local textureInfo = {
		texture = texture,
		width = textureWidth or 16,
		height = textureHeight or 16,
		coords = {left or 0, right or 1, top or 0, bottom or 1},
	}

	textureInfo.imageWidth = imageWidth or textureInfo.width
	textureInfo.imageHeight = imageHeight or textureInfo.height

	return textureInfo
end

---add a texture to the start or end of a string
---@param text string
---@param textureInfo table
---@param bAddSpace any
---@param bAddAfterText any
---@return string
function DF:AddTextureToText(text, textureInfo, bAddSpace, bAddAfterText)
	local texture = textureInfo.texture
	local textureWidth = textureInfo.width
	local textureHeight = textureInfo.height
	local imageWidth = textureInfo.imageWidth or textureWidth
	local imageHeight = textureInfo.imageHeight or textureHeight
	local left, right, top, bottom = unpack(textureInfo.coords)
	left = left or 0
	right = right or 1
	top = top or 0
	bottom = bottom or 1

	if (bAddAfterText) then
		local newString = text .. (bAddSpace and " " or "") .. "|T" .. texture .. ":" .. textureWidth .. ":" .. textureHeight .. ":0:0:" .. imageWidth .. ":" .. imageHeight .. ":" .. (left * imageWidth) .. ":" .. (right * imageWidth) .. ":" .. (top * imageHeight) .. ":" .. (bottom * imageHeight) .. "|t"
		return newString
	else
		local newString = "|T" .. texture .. ":" .. textureWidth .. ":" .. textureHeight .. ":0:0:" .. imageWidth .. ":" .. imageHeight .. ":" .. (left * imageWidth) .. ":" .. (right * imageWidth) .. ":" .. (top * imageHeight) .. ":" .. (bottom * imageHeight) .. "|t" .. (bAddSpace and " " or "") .. text
		return newString
	end
end

---return the size of a fontstring
---@param fontString table
---@return number
function DF:GetFontSize(fontString)
	local _, size = fontString:GetFont()
	return size
end

---return the font of a fontstring
---@param fontString table
---@return string
function DF:GetFontFace(fontString)
	local fontface = fontString:GetFont()
	return fontface
end

local ValidOutlines = {
	["NONE"] = true,
	["MONOCHROME"] = true,
	["OUTLINE"] = true,
	["THICKOUTLINE"] = true,
}

DF.FontOutlineFlags = {
	{"NONE", "None"},
	{"MONOCHROME", "Monochrome"},
	{"OUTLINE", "Outline"},
	{"THICKOUTLINE", "Thick Outline"},
	{"OUTLINEMONOCHROME", "Outline & Monochrome"},
	{"THICKOUTLINEMONOCHROME", "Thick Outline & Monochrome"},
}

---set the outline of a fontstring, outline is a black border around the text, can be "NONE", "MONOCHROME", "OUTLINE" or "THICKOUTLINE"
---@param fontString table
---@param outline any
function DF:SetFontOutline(fontString, outline)
	local font, fontSize = fontString:GetFont()
	if (outline) then
		if (type(outline) == "string") then
			outline = outline:upper()
		end

		if (ValidOutlines[outline]) then
			outline = outline

		elseif (type(outline) == "boolean" and outline) then
			outline = "OUTLINE"

		elseif (type(outline) == "boolean" and not outline) then
			outline = "" --"NONE"

		elseif (outline == 1) then
			outline = "OUTLINE"

		elseif (outline == 2) then
			outline = "THICKOUTLINE"
		end
	end
	outline = (not outline or outline == "NONE") and "" or outline

	fontString:SetFont(font, fontSize, outline)
end

---remove spaces from the start and end of the string
---@param string string
---@return string
function DF:Trim(string)
	return DF:trim(string)
end
function DF:trim(string)
	local from = string:match"^%s*()"
	return from > #string and "" or string:match(".*%S", from)
end


---truncate removing at a maximum of 10 character from the string
---@param fontString table
---@param maxWidth number
function DF:TruncateTextSafe(fontString, maxWidth)
	local text = fontString:GetText()
	local numIterations = 10

	while (fontString:GetStringWidth() > maxWidth) do
		text = strsub(text, 1, #text-1)
		fontString:SetText(text)
		if (#text <= 1) then
			break
		end

		numIterations = numIterations - 1
		if (numIterations <= 0) then
			break
		end
	end

	text = DF:CleanTruncateUTF8String(text)
	fontString:SetText(text)
end

---truncate removing characters from the string until the maxWidth is reach
---@param fontString table
---@param maxWidth number
function DF:TruncateText(fontString, maxWidth)
	local text = fontString:GetText()

	while (fontString:GetStringWidth() > maxWidth) do
		text = strsub(text, 1, #text - 1)
		fontString:SetText(text)
		if (string.len(text) <= 1) then
			break
		end
	end

	text = DF:CleanTruncateUTF8String(text)
	fontString:SetText(text)
end

---@param text string
---@return string
function DF:CleanTruncateUTF8String(text)
	if type(text) == "string" and text ~= "" then
		local b1 = (#text > 0) and strbyte(strsub(text, #text, #text)) or nil
		local b2 = (#text > 1) and strbyte(strsub(text, #text-1, #text)) or nil
		local b3 = (#text > 2) and strbyte(strsub(text, #text-2, #text)) or nil

		if b1 and b1 >= 194 and b1 <= 244 then
			text = strsub (text, 1, #text - 1)

		elseif b2 and b2 >= 224 and b2 <= 244 then
			text = strsub (text, 1, #text - 2)

		elseif b3 and b3 >= 240 and b3 <= 244 then
			text = strsub (text, 1, #text - 3)
		end
	end

	return text
end

---truncate the amount of numbers used to show the fraction part of a number
---@param number number
---@param fractionDigits number
---@return number
function DF:TruncateNumber(number, fractionDigits)
	fractionDigits = fractionDigits or 2
	local truncatedNumber = number

	--local truncatedNumber = format("%." .. fractionDigits .. "f", number) --4x slower than:
	--http://lua-users.org/wiki/SimpleRound
	local mult = 10 ^ fractionDigits
	if (number >= 0) then
		truncatedNumber = floor(number * mult + 0.5) / mult
	else
		truncatedNumber = ceil(number * mult + 0.5) / mult
	end

	return truncatedNumber
end

---attempt to get the ID of an npc from a GUID
---@param GUID string
---@return number
function DF:GetNpcIdFromGuid(GUID)
	local npcId = select(6, strsplit("-", GUID ))
	if (npcId) then
		npcId = tonumber(npcId)
		return npcId or 0
	end
	return 0
end

function DF.SortOrder1(t1, t2)
	return t1[1] > t2[1]
end
function DF.SortOrder2(t1, t2)
	return t1[2] > t2[2]
end
function DF.SortOrder3(t1, t2)
	return t1[3] > t2[3]
end
function DF.SortOrder1R(t1, t2)
	return t1[1] < t2[1]
end
function DF.SortOrder2R(t1, t2)
	return t1[2] < t2[2]
end
function DF.SortOrder3R(t1, t2)
	return t1[3] < t2[3]
end

--return a list of spells from the player spellbook
function DF:GetSpellBookSpells()
    local spellNamesInSpellBook = {}
	local spellIdsInSpellBook = {}

    for i = 1, GetNumSpellTabs() do
        local tabName, tabTexture, offset, numSpells, isGuild, offspecId = GetSpellTabInfo(i)

        if (offspecId == 0 and tabTexture ~= 136830) then --don't add spells found in the General tab
            offset = offset + 1
            local tabEnd = offset + numSpells

            for j = offset, tabEnd - 1 do
                local spellType, spellId = GetSpellBookItemInfo(j, "player")

                if (spellId) then
                    if (spellType ~= "FLYOUT") then
                        local spellName = GetSpellInfo(spellId)
                        if (spellName) then
                            spellNamesInSpellBook[spellName] = true
							spellIdsInSpellBook[#spellIdsInSpellBook+1] = spellId
                        end
                    else
                        local _, _, numSlots, isKnown = GetFlyoutInfo(spellId)
                        if (isKnown and numSlots > 0) then
                            for k = 1, numSlots do
                                local spellID, overrideSpellID, isKnown = GetFlyoutSlotInfo(spellId, k)
                                if (isKnown) then
                                    local spellName = GetSpellInfo(spellID)
                                    spellNamesInSpellBook[spellName] = true
									spellIdsInSpellBook[#spellIdsInSpellBook+1] = spellID
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return spellNamesInSpellBook, spellIdsInSpellBook
end

---return a table of passive talents, format: [spellId] = true
---@return {Name: string, ID: number, Texture: any, IsSelected: boolean}[]
function DF:GetAllTalents()
	local allTalents = {}

	local configId = C_ClassTalents.GetActiveConfigID()
	if (configId) then
		local configInfo = C_Traits.GetConfigInfo(configId)
		--get the spells from the SPEC from talents
		for treeIndex, treeId in ipairs(configInfo.treeIDs) do
			local treeNodes = C_Traits.GetTreeNodes(treeId)
			for nodeIdIndex, treeNodeID in ipairs(treeNodes) do
				local traitNodeInfo = C_Traits.GetNodeInfo(configId, treeNodeID)
				if (traitNodeInfo) then
					local activeEntry = traitNodeInfo.activeEntry
					local entryIds = traitNodeInfo.entryIDs
					for i = 1, #entryIds do
						local entryId = entryIds[i] --number
						local traitEntryInfo = C_Traits.GetEntryInfo(configId, entryId)
						local borderTypes = Enum.TraitNodeEntryType
						if (traitEntryInfo.type) then -- == borderTypes.SpendCircle
							local definitionId = traitEntryInfo.definitionID
							local traitDefinitionInfo = C_Traits.GetDefinitionInfo(definitionId)
							local spellId = traitDefinitionInfo.overriddenSpellID or traitDefinitionInfo.spellID
							local spellName, _, spellTexture = GetSpellInfo(spellId)
							if (spellName) then
								local talentInfo = {Name = spellName, ID = spellId, Texture = spellTexture, IsSelected = (activeEntry and activeEntry.rank and activeEntry.rank > 0) or false}
								allTalents[#allTalents+1] = talentInfo
							end
						end
					end
				end
			end
		end
	end

	return allTalents
end

---return a table where keys are spellIds (number) and the value is true
---@return table<number, boolean>
function DF:GetAvailableSpells()
    local completeListOfSpells = {}

    --this line might not be compatible with classic
    --local specId, specName, _, specIconTexture = GetSpecializationInfo(GetSpecialization())
    --local classNameLoc, className, classId = UnitClass("player") --not in use
    local locPlayerRace, playerRace, playerRaceId = UnitRace("player")

    --get racials from the general tab
	local generalTabIndex = 1
    local tabName, tabTexture, offset, numSpells, isGuild, offspecId = GetSpellTabInfo(generalTabIndex)
    offset = offset + 1
    local tabEnd = offset + numSpells
    for entryOffset = offset, tabEnd - 1 do
        local spellType, spellId = GetSpellBookItemInfo(entryOffset, "player")
        local spellData = LIB_OPEN_RAID_COOLDOWNS_INFO[spellId]
        if (spellData) then
            local raceId = spellData.raceid
            if (raceId) then
                if (type(raceId) == "table") then
                    if (raceId[playerRaceId]) then
                        spellId = C_SpellBook.GetOverrideSpell(spellId)
                        local spellName = GetSpellInfo(spellId)
                        local bIsPassive = IsPassiveSpell(spellId, "player")
                        if (spellName and not bIsPassive) then
                            completeListOfSpells[spellId] = true
                        end
                    end

                elseif (type(raceId) == "number") then
                    if (raceId == playerRaceId) then
                        spellId = C_SpellBook.GetOverrideSpell(spellId)
                        local spellName = GetSpellInfo(spellId)
                        local bIsPassive = IsPassiveSpell(spellId, "player")
                        if (spellName and not bIsPassive) then
                            completeListOfSpells[spellId] = true
                        end
                    end
                end
            end
        end
    end

	--get spells from the Spec spellbook
	local amountOfTabs = GetNumSpellTabs()
    for i = 2, amountOfTabs-1 do --starting at index 2 to ignore the general tab
        local tabName, tabTexture, offset, numSpells, isGuild, offSpecId, shouldHide, specID = GetSpellTabInfo(i)
		local bIsOffSpec = offSpecId ~= 0
		offset = offset + 1
		local tabEnd = offset + numSpells
		for entryOffset = offset, tabEnd - 1 do
			local spellType, spellId = GetSpellBookItemInfo(entryOffset, "player")
			if (spellId) then
				if (spellType == "SPELL") then
					spellId = C_SpellBook.GetOverrideSpell(spellId)
					local spellName = GetSpellInfo(spellId)
					local bIsPassive = IsPassiveSpell(spellId, "player")
					if (spellName and not bIsPassive) then
						completeListOfSpells[spellId] = bIsOffSpec == false
					end
				end
			end
		end
    end

    --get class shared spells from the spell book
	--[=[
    local tabName, tabTexture, offset, numSpells, isGuild, offSpecId = GetSpellTabInfo(2)
	local bIsOffSpec = offSpecId ~= 0
    offset = offset + 1
    local tabEnd = offset + numSpells
    for entryOffset = offset, tabEnd - 1 do
        local spellType, spellId = GetSpellBookItemInfo(entryOffset, "player")
        if (spellId) then
            if (spellType == "SPELL") then
                spellId = C_SpellBook.GetOverrideSpell(spellId)
                local spellName = GetSpellInfo(spellId)
                local bIsPassive = IsPassiveSpell(spellId, "player")

				if (spellName and not bIsPassive) then
                    completeListOfSpells[spellId] = bIsOffSpec == false
                end
            end
        end
    end
	--]=]

    local getNumPetSpells = function()
        --'HasPetSpells' contradicts the name and return the amount of pet spells available instead of a boolean
        return HasPetSpells()
    end

    --get pet spells from the pet spellbook
    local numPetSpells = getNumPetSpells()
    if (numPetSpells) then
        for i = 1, numPetSpells do
            local spellName, _, unmaskedSpellId = GetSpellBookItemName(i, "pet")
            if (unmaskedSpellId) then
                unmaskedSpellId = C_SpellBook.GetOverrideSpell(unmaskedSpellId)
                local bIsPassive = IsPassiveSpell(unmaskedSpellId, "pet")
                if (spellName and not bIsPassive) then
                    completeListOfSpells[unmaskedSpellId] = true
                end
            end
        end
    end

    return completeListOfSpells
end


------------------------------------------------------------------------------------------------------------------------
--flash animation
local onFinishFlashAnimation = function(self)
	if (self.showWhenDone) then
		self.frame:SetAlpha(1)
	else
		self.frame:SetAlpha(0)
		self.frame:Hide()
	end

	if (self.onFinishFunc) then
		self:onFinishFunc(self.frame)
	end
end

local stopAnimation_Method = function(self)
	local FlashAnimation = self.FlashAnimation
	FlashAnimation:Stop()
end

local startFlash_Method = function(self, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, loopType)
	local flashAnimation = self.FlashAnimation

	local fadeIn = flashAnimation.fadeIn
	local fadeOut = flashAnimation.fadeOut

	fadeIn:Stop()
	fadeOut:Stop()

	fadeIn:SetDuration(fadeInTime or 1)
	fadeIn:SetEndDelay(flashInHoldTime or 0)

	fadeOut:SetDuration(fadeOutTime or 1)
	fadeOut:SetEndDelay(flashOutHoldTime or 0)

	flashAnimation.duration = flashDuration
	flashAnimation.loopTime = flashAnimation:GetDuration()
	flashAnimation.finishAt = GetTime() + flashDuration
	flashAnimation.showWhenDone = showWhenDone

	flashAnimation:SetLooping(loopType or "REPEAT")

	self:Show()
	self:SetAlpha(0)
	flashAnimation:Play()
end

function DF:CreateFlashAnimation(frame, onFinishFunc, onLoopFunc)
	local flashAnimation = frame:CreateAnimationGroup()

	flashAnimation.fadeOut = flashAnimation:CreateAnimation("Alpha")
	flashAnimation.fadeOut:SetOrder(1)
	flashAnimation.fadeOut:SetFromAlpha(0)
	flashAnimation.fadeOut:SetToAlpha(1)

	flashAnimation.fadeIn = flashAnimation:CreateAnimation("Alpha")
	flashAnimation.fadeIn:SetOrder(2)
	flashAnimation.fadeIn:SetFromAlpha(1)
	flashAnimation.fadeIn:SetToAlpha(0)

	frame.FlashAnimation = flashAnimation
	flashAnimation.frame = frame
	flashAnimation.onFinishFunc = onFinishFunc

	flashAnimation:SetScript("OnLoop", onLoopFunc)
	flashAnimation:SetScript("OnFinished", onFinishFlashAnimation)

	frame.Flash = startFlash_Method
	frame.Stop = stopAnimation_Method

	return flashAnimation
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--anchoring

function DF:CheckPoints(point1, point2, point3, point4, point5, object)
	if (not point1 and not point2) then
		return "topleft", object.widget:GetParent(), "topleft", 0, 0
	end

	if (type(point1) == "string") then
		local frameGlobal = _G[point1]
		if (frameGlobal and type(frameGlobal) == "table" and frameGlobal.GetObjectType) then
			return DF:CheckPoints(frameGlobal, point2, point3, point4, point5, object)
		end

	elseif (type(point2) == "string") then
		local frameGlobal = _G[point2]
		if (frameGlobal and type(frameGlobal) == "table" and frameGlobal.GetObjectType) then
			return DF:CheckPoints(point1, frameGlobal, point3, point4, point5, object)
		end
	end

	if (type(point1) == "string" and type(point2) == "table") then --setpoint("left", frame, _, _, _)
		if (not point3 or type(point3) == "number") then --setpoint("left", frame, 10, 10)
			point1, point2, point3, point4, point5 = point1, point2, point1, point3, point4
		end

	elseif (type(point1) == "string" and type(point2) == "number") then --setpoint("topleft", x, y)
		point1, point2, point3, point4, point5 = point1, object.widget:GetParent(), point1, point2, point3

	elseif (type(point1) == "number") then --setpoint(x, y)
		point1, point2, point3, point4, point5 = "topleft", object.widget:GetParent(), "topleft", point1, point2

	elseif (type(point1) == "table") then --setpoint(frame, x, y)
		point1, point2, point3, point4, point5 = "topleft", point1, "topleft", point2, point3
	end

	if (not point2) then
		point2 = object.widget:GetParent()
	elseif (point2.dframework) then
		point2 = point2.widget
	end

	return point1 or "topleft", point2, point3 or "topleft", point4 or 0, point5 or 0
end

---@class df_anchor : table
---@field side number 1-8: topleft to top (clockwise); 9: center; 10-13: inside left right top bottom; 14-17: inside topleft, bottomleft bottomright topright
---@field x number
---@field y number

DF.AnchorPoints = {
	"Top Left",
	"Left",
	"Bottom Left",
	"Bottom",
	"Bottom Right",
	"Right",
	"Top Right",
	"Top",
	"Center",
	"Inside Left",
	"Inside Right",
	"Inside Top",
	"Inside Bottom",
	"Inside Top Left",
	"Inside Bottom Left",
	"Inside Bottom Right",
	"Inside Top Right",
}

local anchoringFunctions = {
	function(frame, anchorTo, offSetX, offSetY) --1 TOP LEFT
		frame:ClearAllPoints()
		frame:SetPoint("bottomleft", anchorTo, "topleft", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --2 LEFT
		frame:ClearAllPoints()
		frame:SetPoint("right", anchorTo, "left", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --3 BOTTOM LEFT
		frame:ClearAllPoints()
		frame:SetPoint("topleft", anchorTo, "bottomleft", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --4 BOTTOM
		frame:ClearAllPoints()
		frame:SetPoint("top", anchorTo, "bottom", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --5 BOTTOM RIGHT
		frame:ClearAllPoints()
		frame:SetPoint("topright", anchorTo, "bottomright", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --6 RIGHT
		frame:ClearAllPoints()
		frame:SetPoint("left", anchorTo, "right", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --7 TOP RIGHT
		frame:ClearAllPoints()
		frame:SetPoint("bottomright", anchorTo, "topright", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --8 TOP
		frame:ClearAllPoints()
		frame:SetPoint("bottom", anchorTo, "top", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --9 CENTER
		frame:ClearAllPoints()
		frame:SetPoint("center", anchorTo, "center", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --10 INSIDE LEFT
		frame:ClearAllPoints()
		frame:SetPoint("left", anchorTo, "left", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --11 INSIDE RIGHT
		frame:ClearAllPoints()
		frame:SetPoint("right", anchorTo, "right", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --12 INSIDE TOP
		frame:ClearAllPoints()
		frame:SetPoint("top", anchorTo, "top", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --13 INSIDE BOTTOM
		frame:ClearAllPoints()
		frame:SetPoint("bottom", anchorTo, "bottom", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --14 INSIDE TOPLEFT to TOPLEFT
		frame:ClearAllPoints()
		frame:SetPoint("topleft", anchorTo, "topleft", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --15 INSIDE BOTTOMLEFT to BOTTOMLEFT
		frame:ClearAllPoints()
		frame:SetPoint("bottomleft", anchorTo, "bottomleft", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --16 INSIDE BOTTOMRIGHT to BOTTOMRIGHT
		frame:ClearAllPoints()
		frame:SetPoint("bottomright", anchorTo, "bottomright", offSetX, offSetY)
	end,

	function(frame, anchorTo, offSetX, offSetY) --17 INSIDE TOPRIGHT to TOPRIGHT
		frame:ClearAllPoints()
		frame:SetPoint("topright", anchorTo, "topright", offSetX, offSetY)
	end,
}

---set the anchor point using a df_anchor table
---@param widget uiobject
---@param anchorTable df_anchor
---@param anchorTo uiobject?
function DF:SetAnchor(widget, anchorTable, anchorTo)
	anchorTo = anchorTo or widget:GetParent()
	anchoringFunctions[anchorTable.side](widget, anchorTo, anchorTable.x, anchorTable.y)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--colors

	--add a new color name, the color can be query using DetailsFramework:ParseColors(colorName)
	function DF:NewColor(colorName, red, green, blue, alpha)
		assert(type(colorName) == "string", "DetailsFramework:NewColor(): colorName must be a string.")
		--assert(not DF.alias_text_colors[colorName], "DetailsFramework:NewColor(): colorName already exists.")

		red, green, blue, alpha = DetailsFramework:ParseColors(red, green, blue, alpha)
		local colorTable = DetailsFramework:FormatColor("table", red, green, blue, alpha)

		DF.alias_text_colors[colorName] = colorTable

		return colorTable
	end

	local colorTableMixin = {
		GetColor = function(self)
			return self.r, self.g, self.b, self.a
		end,

		SetColor = function(self, r, g, b, a)
			r, g, b, a = DF:ParseColors(r, g, b, a)
			self.r = r or self.r
			self.g = g or self.g
			self.b = b or self.b
			self.a = a or self.a
		end,

		IsColorTable = true,
	}

	---convert a any format of color to any other format of color
	---@param newFormat string
	---@param r number|string
	---@param g number|nil
	---@param b number|nil
	---@param a number|nil
	---@param decimalsAmount number|nil
	---@return string|table|number|nil
	---@return number|nil
	---@return number|nil
	---@return number|nil
	function DF:FormatColor(newFormat, r, g, b, a, decimalsAmount)
		a = a or 1
		r, g, b, a = DF:ParseColors(r, g, b, a)
		decimalsAmount = decimalsAmount or 4

		r = DF:TruncateNumber(r, decimalsAmount)
		g = DF:TruncateNumber(g, decimalsAmount)
		b = DF:TruncateNumber(b, decimalsAmount)
		a = DF:TruncateNumber(a, decimalsAmount)

		if (newFormat == "commastring") then
			return r .. ", " .. g .. ", " .. b .. ", " .. a

		elseif (newFormat == "tablestring") then
			return "{" .. r .. ", " .. g .. ", " .. b .. ", " .. a .. "}"

		elseif (newFormat == "table") then
			return {r, g, b, a}

		elseif (newFormat == "tablemembers") then
			return {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}

		elseif (newFormat == "numbers") then
			return r, g, b, a

		elseif (newFormat == "hex") then
			return format("%.2x%.2x%.2x%.2x", a * 255, r * 255, g * 255, b * 255)
		end
	end

	function DF:CreateColorTable(r, g, b, a)
		local t  = {
			r = r or 1,
			g = g or 1,
			b = b or 1,
			a = a or 1,
		}
		DF:Mixin(t, colorTableMixin)
		return t
	end

	---return true if DF.alias_text_colors has the colorName as a key
	---DF.alias_text_colors is a table where key is a color name and value is an indexed table with the r g b values
	---@param colorName any
	---@return unknown
	function DF:IsHtmlColor(colorName)
		return DF.alias_text_colors[colorName]
	end

	---get the values passed and return r g b a color values
	---the function accept color name, tables with r g b a members, indexed tables with r g b a values, numbers, html hex color
	---@param red any
	---@param green any
	---@param blue any
	---@param alpha any
	---@return number
	---@return number
	---@return number
	---@return number
	function DF:ParseColors(red, green, blue, alpha)
		local firstParameter = red

		--the first value passed is a table?
		if (type(firstParameter) == "table") then
			local colorTable = red

			if (colorTable.IsColorTable) then
				--using colorTable mixin
				return colorTable:GetColor()

			elseif (not colorTable[1] and colorTable.r) then
				--{["r"] = 1, ["g"] = 1, ["b"] = 1}
				red, green, blue, alpha = colorTable.r, colorTable.g, colorTable.b, colorTable.a

			else
				--{1, .7, .2, 1}
				red, green, blue, alpha = unpack(colorTable)
			end

		--the first value passed is a string?
		elseif (type(firstParameter) == "string") then
			local colorString = red
			--hexadecimal
			if (string.find(colorString, "#")) then
				colorString = colorString:gsub("#","")
				if (string.len(colorString) == 8) then --with alpha
					red, green, blue, alpha = tonumber("0x" .. colorString:sub(3, 4))/255, tonumber("0x" .. colorString:sub(5, 6))/255, tonumber("0x" .. colorString:sub(7, 8))/255, tonumber("0x" .. colorString:sub(1, 2))/255
				else
					red, green, blue, alpha = tonumber("0x" .. colorString:sub(1, 2))/255, tonumber("0x" .. colorString:sub(3, 4))/255, tonumber("0x" .. colorString:sub(5, 6))/255, 1
				end
			else
				--name of the color
				local colorTable = DF.alias_text_colors[colorString]
				if (colorTable) then
					red, green, blue, alpha = unpack(colorTable)

				--string with number separated by comma
				elseif (colorString:find(",")) then
					local r, g, b, a = strsplit(",", colorString)
					red, green, blue, alpha = tonumber(r), tonumber(g), tonumber(b), tonumber(a)

				else
					--no color found within the string, return default color
					red, green, blue, alpha = unpack(DF.alias_text_colors.none)
				end
			end
		end

		if (not red or type(red) ~= "number") then
			red = 1
		end
		if (not green) or type(green) ~= "number" then
			green = 1
		end
		if (not blue or type(blue) ~= "number") then
			blue = 1
		end
		if (not alpha or type(alpha) ~= "number") then
			alpha = 1
		end

		--saturate the values before returning to make sure they are on the 0 to 1 range
		return Saturate(red), Saturate(green), Saturate(blue), Saturate(alpha)
	end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--tutorials
	function DF:ShowTutorialAlertFrame(maintext, desctext, clickfunc)
		local TutorialAlertFrame = _G.DetailsFrameworkAlertFrame

		if (not TutorialAlertFrame) then

			TutorialAlertFrame = CreateFrame("frame", "DetailsFrameworkAlertFrame", UIParent, "MicroButtonAlertTemplate")
			TutorialAlertFrame.isFirst = true
			TutorialAlertFrame:SetPoint("left", UIParent, "left", -20, 100)
			TutorialAlertFrame:SetFrameStrata("TOOLTIP")
			TutorialAlertFrame:Hide()

			TutorialAlertFrame:SetScript("OnMouseUp", function(self)
				if (self.clickfunc and type(self.clickfunc) == "function") then
					self.clickfunc()
				end
				self:Hide()
			end)
			TutorialAlertFrame:Hide()
		end

		--
		TutorialAlertFrame.label = type(maintext) == "string" and maintext or type(desctext) == "string" and desctext or ""
		MicroButtonAlert_SetText (TutorialAlertFrame, alert.label)
		--

		TutorialAlertFrame.clickfunc = clickfunc
		TutorialAlertFrame:Show()
	end

	function DF:CreateOptionsFrame(name, title, template)
		template = template or 1

		if (template == 2) then
			local newOptionsFrame = CreateFrame("frame", name, UIParent, "ButtonFrameTemplate")
			tinsert(UISpecialFrames, name)

			newOptionsFrame:SetSize(500, 200)
			newOptionsFrame.RefreshOptions = DF.internalFunctions.RefreshOptionsPanel
			newOptionsFrame.widget_list = {}

			newOptionsFrame:SetScript("OnMouseDown", function(self, button)
				if (button == "RightButton") then
					if (self.moving) then
						self.moving = false
						self:StopMovingOrSizing()
					end
					return newOptionsFrame:Hide()
				elseif (button == "LeftButton" and not self.moving) then
					self.moving = true
					self:StartMoving()
				end
			end)

			newOptionsFrame:SetScript("OnMouseUp", function(self)
				if (self.moving) then
					self.moving = false
					self:StopMovingOrSizing()
				end
			end)

			newOptionsFrame:SetMovable(true)
			newOptionsFrame:EnableMouse(true)
			newOptionsFrame:SetFrameStrata("DIALOG")
			newOptionsFrame:SetToplevel(true)
			newOptionsFrame:Hide()
			newOptionsFrame:SetPoint("center", UIParent, "center")
			newOptionsFrame.TitleText:SetText(title)

			return newOptionsFrame

		elseif (template == 1) then
			local newOptionsFrame = CreateFrame("frame", name, UIParent)
			tinsert(UISpecialFrames, name)

			newOptionsFrame:SetSize(500, 200)
			newOptionsFrame.RefreshOptions = DF.internalFunctions.RefreshOptionsPanel
			newOptionsFrame.widget_list = {}

			newOptionsFrame:SetScript("OnMouseDown", function(self, button)
				if (button == "RightButton") then
					if (self.moving) then
						self.moving = false
						self:StopMovingOrSizing()
					end
					return newOptionsFrame:Hide()
				elseif (button == "LeftButton" and not self.moving) then
					self.moving = true
					self:StartMoving()
				end
			end)

			newOptionsFrame:SetScript("OnMouseUp", function(self)
				if (self.moving) then
					self.moving = false
					self:StopMovingOrSizing()
				end
			end)

			newOptionsFrame:SetMovable(true)
			newOptionsFrame:EnableMouse(true)
			newOptionsFrame:SetFrameStrata("DIALOG")
			newOptionsFrame:SetToplevel(true)
			newOptionsFrame:Hide()
			newOptionsFrame:SetPoint("center", UIParent, "center")

			newOptionsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
			edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1,
			insets = {left = 1, right = 1, top = 1, bottom = 1}})
			newOptionsFrame:SetBackdropColor(0, 0, 0, .7)

			local textureTitle = newOptionsFrame:CreateTexture(nil, "artwork")
			textureTitle:SetTexture([[Interface\CURSOR\Interact]])
			textureTitle:SetTexCoord(0, 1, 0, 1)
			textureTitle:SetVertexColor(1, 1, 1, 1)
			textureTitle:SetPoint("topleft", newOptionsFrame, "topleft", 2, -3)
			textureTitle:SetWidth(36)
			textureTitle:SetHeight(36)

			local titleLabel = DF:NewLabel(newOptionsFrame, nil, "$parentTitle", nil, title, nil, 20, "yellow")
			titleLabel:SetPoint("left", textureTitle, "right", 2, -1)
			DF:SetFontOutline (titleLabel, true)

			local closeButton = CreateFrame("Button", nil, newOptionsFrame, "UIPanelCloseButton")
			closeButton:SetWidth(32)
			closeButton:SetHeight(32)
			closeButton:SetPoint("TOPRIGHT",  newOptionsFrame, "TOPRIGHT", -3, -3)
			closeButton:SetFrameLevel(newOptionsFrame:GetFrameLevel()+1)

			return newOptionsFrame
		end
	end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--~templates

local latinLanguageIds = {"enUS", "deDE", "esES", "esMX", "frFR", "itIT", "ptBR"}
local latinLanguageIdsMap = {
	["enUS"] = true,
	["deDE"] = true,
	["esES"] = true,
	["esMX"] = true,
	["frFR"] = true,
	["itIT"] = true,
	["ptBR"] = true,
}

local alphbets = {
	[latinLanguageIds] = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"},
	["zhCN"] = {},
}

--fonts
DF.font_templates = DF.font_templates or {}

--detect which language is the client and select the font accordingly
local clientLanguage = GetLocale()
if (clientLanguage == "enGB") then
	clientLanguage = "enUS"
end

DF.ClientLanguage = clientLanguage

function DF:DetectTextLanguage(text)
	for i = 1, #text do
		--or not
	end
end

--returns which region the language the client is running, return "western", "russia" or "asia"
function DF:GetClientRegion()
	if (clientLanguage == "zhCN" or clientLanguage == "koKR" or clientLanguage == "zhTW") then
		return "asia"
	elseif (clientLanguage == "ruRU") then
		return "russia"
	else
		return "western"
	end
end

DF.registeredFontPaths = DF.registeredFontPaths or {}
-- ~language ~locale ~fontpath
function DF:GetBestFontPathForLanguage(languageId)
	local fontPath = DF.registeredFontPaths[languageId]
	if (fontPath) then
		return fontPath
	end

	--font paths gotten from creating a FontString with template "GameFontNormal" and getting the font returned from FontString:GetFont()
	if (languageId == "enUS" or languageId == "deDE" or languageId == "esES" or languageId == "esMX" or languageId == "frFR" or languageId == "itIT" or languageId == "ptBR") then
		return [[Fonts\FRIZQT__.TTF]]

	elseif (languageId == "ruRU") then
		return [[Fonts\FRIZQT___CYR.TTF]]

	elseif (languageId == "zhCN") then
		return [[Fonts\ARKai_T.ttf]]

	elseif (languageId == "zhTW") then
		return [[Fonts\blei00d.TTF]]

	elseif (languageId == "koKR") then
		return [[Fonts\2002.TTF]]
	end

	--the locale passed doesn't exists, so pass the enUS
	return [[Fonts\FRIZQT__.TTF]]
end

function DF:IsLatinLanguage(languageId)
	return latinLanguageIdsMap[languageId]
end

--return the best font to use for the client language
function DF:GetBestFontForLanguage(languageId, western, cyrillic, china, korean, taiwan)
	if (not languageId) then
		languageId = DF.ClientLanguage
	end

	if (languageId == "enUS" or languageId == "deDE" or languageId == "esES" or languageId == "esMX" or languageId == "frFR" or languageId == "itIT" or languageId == "ptBR") then
		return western or "Friz Quadrata TT"

	elseif (languageId == "ruRU") then
		return cyrillic or "Friz Quadrata TT"

	elseif (languageId == "zhCN") then
		return china or "AR CrystalzcuheiGBK Demibold"

	elseif (languageId == "koKR") then
		return korean or "2002"

	elseif (languageId == "zhTW") then
		return taiwan or "AR CrystalzcuheiGBK Demibold"
	end
end

--DF.font_templates ["ORANGE_FONT_TEMPLATE"] = {color = "orange", size = 11, font = "Accidental Presidency"}
--DF.font_templates ["OPTIONS_FONT_TEMPLATE"] = {color = "yellow", size = 12, font = "Accidental Presidency"}
DF.font_templates["ORANGE_FONT_TEMPLATE"] = {color = "orange", size = 10, font = DF:GetBestFontForLanguage()}
DF.font_templates["OPTIONS_FONT_TEMPLATE"] = {color = "yellow", size = 9.6, font = DF:GetBestFontForLanguage()}

--dropdowns
DF.dropdown_templates = DF.dropdown_templates or {}
DF.dropdown_templates["OPTIONS_DROPDOWN_TEMPLATE"] = {
	backdrop = {
		edgeFile = [[Interface\Buttons\WHITE8X8]],
		edgeSize = 1,
		bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
		tileSize = 64,
		tile = true
	},

	backdropcolor = {1, 1, 1, .7},
	backdropbordercolor = {0, 0, 0, 1},
	onentercolor = {1, 1, 1, .9},
	onenterbordercolor = {1, 1, 1, 1},

	dropicon = "Interface\\BUTTONS\\arrow-Down-Down",
	dropiconsize = {16, 16},
	dropiconpoints = {-2, -3},
}

DF.dropdown_templates["OPTIONS_DROPDOWNDARK_TEMPLATE"] = {
	backdrop = {
		edgeFile = [[Interface\Buttons\WHITE8X8]],
		edgeSize = 1,
		bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
		tileSize = 64,
		tile = true
	},

	backdropcolor = {0.1215, 0.1176, 0.1294, 0.8000},
	backdropbordercolor = {.2, .2, .2, 1},
	onentercolor = {.5, .5, .5, .9},
	onenterbordercolor = {.4, .4, .4, 1},

	dropicon = "Interface\\BUTTONS\\arrow-Down-Down",
	dropiconsize = {16, 16},
	dropiconpoints = {-2, -3},
}

--switches
DF.switch_templates = DF.switch_templates or {}
DF.switch_templates["OPTIONS_CHECKBOX_TEMPLATE"] = {
	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdropcolor = {1, 1, 1, .5},
	backdropbordercolor = {0, 0, 0, 1},
	width = 18,
	height = 18,
	enabled_backdropcolor = {1, 1, 1, .5},
	disabled_backdropcolor = {1, 1, 1, .2},
	onenterbordercolor = {1, 1, 1, 1},
}
DF.switch_templates["OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"] = {
	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdropcolor = {1, 1, 1, .5},
	backdropbordercolor = {0, 0, 0, 1},
	width = 18,
	height = 18,
	enabled_backdropcolor = {1, 1, 1, .5},
	disabled_backdropcolor = {1, 1, 1, .5},
	onenterbordercolor = {1, 1, 1, 1},
}

--buttons
DF.button_templates = DF.button_templates or {}
DF.button_templates["OPTIONS_BUTTON_TEMPLATE"] = {
	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdropcolor = {1, 1, 1, .5},
	backdropbordercolor = {0, 0, 0, 1},
}

DF.button_templates["OPTIONS_BUTTON_GOLDENBORDER_TEMPLATE"] = {
	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdropcolor = {1, 1, 1, .5},
	backdropbordercolor = {1, 0.785, 0, 1},
}

--sliders
DF.slider_templates = DF.slider_templates or {}
DF.slider_templates["OPTIONS_SLIDER_TEMPLATE"] = {
	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdropcolor = {1, 1, 1, .5},
	backdropbordercolor = {0, 0, 0, 1},
	onentercolor = {1, 1, 1, .5},
	onenterbordercolor = {1, 1, 1, 1},
	thumbtexture = [[Interface\Tooltips\UI-Tooltip-Background]],
	thumbwidth = 16,
	thumbheight = 14,
	thumbcolor = {0, 0, 0, 0.5},
}

---install a template
---@param widgetType string
---@param templateName string
---@param template table
---@param parentName any
---@return table
function DF:InstallTemplate(widgetType, templateName, template, parentName)
	local newTemplate = {}

	--if has a parent, just copy the parent to the new template
	if (parentName and type(parentName) == "string") then
		local parentTemplate = DF:GetTemplate(widgetType, parentName)
		if (parentTemplate) then
			DF.table.copy(newTemplate, parentTemplate)
		end
	end

	--copy the template passed into the new template
	DF.table.copy(newTemplate, template)

	widgetType = string.lower(widgetType)

	local templateTable
	if (widgetType == "font") then
		templateTable = DF.font_templates

		local font = template.font
		if (font) then
			--fonts passed into the template has default to western
			--the framework will get the game client language and change the font if needed
			font = DF:GetBestFontForLanguage(nil, font)
		end

	elseif (widgetType == "dropdown") then
		templateTable = DF.dropdown_templates

	elseif (widgetType == "button") then
		templateTable = DF.button_templates

	elseif (widgetType == "switch") then
		templateTable = DF.switch_templates

	elseif (widgetType == "slider") then
		templateTable = DF.slider_templates
	end

	templateTable[templateName] = newTemplate
	return newTemplate
end

function DF:GetTemplate(widgetType, templateName)
	widgetType = string.lower(widgetType)
	local templateTable

	if (widgetType == "font") then
		templateTable = DF.font_templates

	elseif (widgetType == "dropdown") then
		templateTable = DF.dropdown_templates

	elseif (widgetType == "button") then
		templateTable = DF.button_templates

	elseif (widgetType == "switch") then
		templateTable = DF.switch_templates

	elseif (widgetType == "slider") then
		templateTable = DF.slider_templates
	end

	return templateTable[templateName]
end

function DF.GetParentName(frame)
	local parentName = frame:GetName()
	if (not parentName) then
		error("Details! FrameWork: called $parent but parent was no name.", 2)
	end
	return parentName
end

function DF:Error (errortext)
	print("|cFFFF2222Details! Framework Error|r:", errortext, self.GetName and self:GetName(), self.WidgetType, debugstack (2, 3, 0))
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--members

DF.GlobalWidgetControlNames = {
	textentry = "DF_TextEntryMetaFunctions",
	button = "DF_ButtonMetaFunctions",
	panel = "DF_PanelMetaFunctions",
	dropdown = "DF_DropdownMetaFunctions",
	label = "DF_LabelMetaFunctions",
	normal_bar = "DF_NormalBarMetaFunctions",
	image = "DF_ImageMetaFunctions",
	slider = "DF_SliderMetaFunctions",
	split_bar = "DF_SplitBarMetaFunctions",
	aura_tracker = "DF_AuraTracker",
	healthBar = "DF_healthBarMetaFunctions",
	timebar = "DF_TimeBarMetaFunctions",
}

function DF:AddMemberForWidget(widgetName, memberType, memberName, func)
	if (DF.GlobalWidgetControlNames[widgetName]) then
		if (type(memberName) == "string" and (memberType == "SET" or memberType == "GET")) then
			if (func) then
				local widgetControlObject = _G [DF.GlobalWidgetControlNames[widgetName]]

				if (memberType == "SET") then
					widgetControlObject["SetMembers"][memberName] = func
				elseif (memberType == "GET") then
					widgetControlObject["GetMembers"][memberName] = func
				end
			else
				if (DF.debug) then
					error("Details! Framework: AddMemberForWidget invalid function.")
				end
			end
		else
			if (DF.debug) then
				error("Details! Framework: AddMemberForWidget unknown memberName or memberType.")
			end
		end
	else
		if (DF.debug) then
			error("Details! Framework: AddMemberForWidget unknown widget type: " .. (widgetName or "") .. ".")
		end
	end
end

-----------------------------

function DF:OpenInterfaceProfile()
	-- OptionsFrame1/2 should be registered if created with DF:CreateAddOn, so open to them directly
	if self.OptionsFrame1 then
		if SettingsPanel then
			--SettingsPanel:OpenToCategory(self.OptionsFrame1.name)
			local category = SettingsPanel:GetCategoryList():GetCategory(self.OptionsFrame1.name)
			if category then
				SettingsPanel:Open()
				SettingsPanel:SelectCategory(category)
				if self.OptionsFrame2 and category:HasSubcategories() then
					for _, subcategory in pairs(category:GetSubcategories()) do
						if subcategory:GetName() == self.OptionsFrame2.name then
							SettingsPanel:SelectCategory(subcategory)
							break
						end
					end
				end
			end
			return
		elseif InterfaceOptionsFrame_OpenToCategory then
			InterfaceOptionsFrame_OpenToCategory (self.OptionsFrame1)
			if self.OptionsFrame2 then
				InterfaceOptionsFrame_OpenToCategory (self.OptionsFrame2)
			end
			return
		end
	end

	-- fallback (broken as of ElvUI Skins in version 12.18+... maybe fix/change will come)
	InterfaceOptionsFrame_OpenToCategory (self.__name)
	InterfaceOptionsFrame_OpenToCategory (self.__name)
	for i = 1, 100 do
		local button = _G ["InterfaceOptionsFrameAddOnsButton" .. i]
		if (button) then
			local text = _G ["InterfaceOptionsFrameAddOnsButton" .. i .. "Text"]
			if (text) then
				text = text:GetText()
				if (text == self.__name) then
					local toggle = _G ["InterfaceOptionsFrameAddOnsButton" .. i .. "Toggle"]
					if (toggle) then
						if (toggle:GetNormalTexture():GetTexture():find("PlusButton")) then
							--is minimized, need expand
							toggle:Click()
							_G ["InterfaceOptionsFrameAddOnsButton" .. i+1]:Click()
						elseif (toggle:GetNormalTexture():GetTexture():find("MinusButton")) then
							--isn't minimized
							_G ["InterfaceOptionsFrameAddOnsButton" .. i+1]:Click()
						end
					end
					break
				end
			end
		else
			self:Msg("Couldn't not find the profile panel.")
			break
		end
	end
end

-----------------------------
---copy all members from #2 ... to #1 object
---@param object table
---@param ... any
---@return any
function DF:Mixin(object, ...) --safe copy from blizz api
	for i = 1, select("#", ...) do
		local mixin = select(i, ...)
		for key, value in pairs(mixin) do
			object[key] = value
		end
	end
	return object
end

-----------------------------
--animations

---create an animation 'hub' which is an animationGroup but with some extra functions
---@param parent uiobject
---@param onPlay function?
---@param onFinished function?
---@return animationgroup
function DF:CreateAnimationHub(parent, onPlay, onFinished)
	local newAnimation = parent:CreateAnimationGroup()
	newAnimation:SetScript("OnPlay", onPlay)
	newAnimation:SetScript("OnFinished", onFinished)
	newAnimation:SetScript("OnStop", onFinished)
	newAnimation.NextAnimation = 1
	return newAnimation
end

function DF:CreateAnimation(animation, animationType, order, duration, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
	local anim = animation:CreateAnimation(animationType)
	anim:SetOrder(order or animation.NextAnimation)
	anim:SetDuration(duration)

	animationType = string.upper(animationType)

	if (animationType == "ALPHA") then
		anim:SetFromAlpha(arg1)
		anim:SetToAlpha(arg2)

	elseif (animationType == "SCALE") then
		if (DF.IsDragonflight() or DF.IsNonRetailWowWithRetailAPI()) then
			anim:SetScaleFrom(arg1, arg2)
			anim:SetScaleTo(arg3, arg4)
		else
			anim:SetFromScale(arg1, arg2)
			anim:SetToScale(arg3, arg4)
		end
		anim:SetOrigin(arg5 or "center", arg6 or 0, arg7 or 0) --point, x, y

	elseif (animationType == "ROTATION") then
		anim:SetDegrees(arg1) --degree
		--print("SetOrigin", arg2, arg3, arg4)
		anim:SetOrigin(arg2 or "center", arg3 or 0, arg4 or 0) --point, x, y

	elseif (animationType == "TRANSLATION") then
		anim:SetOffset(arg1, arg2)
	end

	animation.NextAnimation = animation.NextAnimation + 1
	return anim
end

---receives an uiobject, when its parent get hover overed, starts the fade in animation
---start the fade out animation when the mouse leaves the parent
---@param UIObject uiobject
---@param fadeInTime number
---@param fadeOutTime number
---@param fadeInAlpha number
---@param fadeOutAlpha number
function DF:CreateFadeAnimation(UIObject, fadeInTime, fadeOutTime, fadeInAlpha, fadeOutAlpha)
	fadeInTime = fadeInTime or 0.1
	fadeOutTime = fadeOutTime or 0.1
	fadeInAlpha = fadeInAlpha or 1
	fadeOutAlpha = fadeOutAlpha or 0

	local fadeInAnimationHub = DF:CreateAnimationHub(UIObject, function() UIObject:Show(); UIObject:SetAlpha(fadeOutAlpha) end, function() UIObject:SetAlpha(fadeInAlpha) end)
	local fadeIn = DF:CreateAnimation(fadeInAnimationHub, "Alpha", 1, fadeInTime, fadeOutAlpha, fadeInAlpha)

	local fadeOutAnimationHub = DF:CreateAnimationHub(UIObject, nil, function() UIObject:Hide(); UIObject:SetAlpha(0) end)
	local fadeOut = DF:CreateAnimation(fadeOutAnimationHub, "Alpha", 2, fadeOutTime, fadeInAlpha, fadeOutAlpha)

	local scriptFrame
	--hook the parent OnEnter and OnLeave
	if (UIObject:IsObjectType("FontString") or UIObject:IsObjectType("Texture")) then
		scriptFrame = UIObject:GetParent()
	else
		scriptFrame = UIObject
	end

	---@cast scriptFrame frame
	scriptFrame:HookScript("OnEnter", function() fadeOutAnimationHub:Stop(); fadeInAnimationHub:Play() end)
	scriptFrame:HookScript("OnLeave", function() fadeInAnimationHub:Stop(); fadeOutAnimationHub:Play() end)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--frame shakes

--frame shakes rely on OnUpdate scripts, we are using a built-in OnUpdate so is guarantee it'll run
local FrameshakeUpdateFrame = DetailsFrameworkFrameshakeControl or CreateFrame("frame", "DetailsFrameworkFrameshakeControl", UIParent)
--store the frame which has frame shakes registered
FrameshakeUpdateFrame.RegisteredFrames = FrameshakeUpdateFrame.RegisteredFrames or {}

FrameshakeUpdateFrame.RegisterFrame = function(newFrame)
	--add the frame into the registered frames to update
	DF.table.addunique(FrameshakeUpdateFrame.RegisteredFrames, newFrame)
end

--forward declared
local frameshake_DoUpdate

FrameshakeUpdateFrame:SetScript("OnUpdate", function(self, deltaTime)
	for i = 1, #FrameshakeUpdateFrame.RegisteredFrames do
		local parent = FrameshakeUpdateFrame.RegisteredFrames [i]
		--check if there's a shake running
		if (parent.__frameshakes.enabled > 0) then
			--update all shakes for this frame
			for i = 1, #parent.__frameshakes do
				local shakeObject = parent.__frameshakes [i]
				if (shakeObject.IsPlaying) then
					frameshake_DoUpdate(parent, shakeObject, deltaTime)
				end
			end
		end
	end
end)

local frameshake_ShakeFinished = function(parent, shakeObject)
	if (shakeObject.IsPlaying) then
		shakeObject.IsPlaying = false
		shakeObject.TimeLeft = 0
		shakeObject.IsFadingOut = false
		shakeObject.IsFadingIn = false

		--update the amount of shake running on this frame
		parent.__frameshakes.enabled = parent.__frameshakes.enabled - 1

		--restore the default anchors, in case where deltaTime was too small that didn't triggered an update
		for i = 1, #shakeObject.Anchors do
			local anchor = shakeObject.Anchors [i]

			--automatic anchoring and reanching needs to the reviwed in the future
			if (#anchor == 1) then
				local anchorTo = unpack(anchor)
				parent:ClearAllPoints()
				parent:SetPoint(anchorTo)

			elseif (#anchor == 2) then
				local anchorTo, point1 = unpack(anchor)
				parent:ClearAllPoints()
				parent:SetPoint(anchorTo, point1)

			elseif (#anchor == 3) then
				local anchorTo, point1, point2 = unpack(anchor)
				parent:SetPoint(anchorTo, point1, point2)

			elseif (#anchor == 5) then
				local anchorName1, anchorTo, anchorName2, point1, point2 = unpack(anchor)
				parent:SetPoint(anchorName1, anchorTo, anchorName2, point1, point2)
			end
		end
	end
end

--already declared above the update function
frameshake_DoUpdate = function(parent, shakeObject, deltaTime)
	--check delta time
	deltaTime = deltaTime or 0

	--update time left
	shakeObject.TimeLeft = max(shakeObject.TimeLeft - deltaTime, 0)

	if (shakeObject.TimeLeft > 0) then
		--update fade in and out
		if (shakeObject.IsFadingIn) then
			shakeObject.IsFadingInTime = shakeObject.IsFadingInTime + deltaTime
		end
		if (shakeObject.IsFadingOut) then
			shakeObject.IsFadingOutTime = shakeObject.IsFadingOutTime + deltaTime
		end

		--check if can disable fade in
		if (shakeObject.IsFadingIn and shakeObject.IsFadingInTime > shakeObject.FadeInTime) then
			shakeObject.IsFadingIn = false
		end

		--check if can enable fade out
		if (not shakeObject.IsFadingOut and shakeObject.TimeLeft < shakeObject.FadeOutTime) then
			shakeObject.IsFadingOut = true
			shakeObject.IsFadingOutTime = shakeObject.FadeOutTime - shakeObject.TimeLeft
		end

		--update position
		local scaleShake = min(shakeObject.IsFadingIn and (shakeObject.IsFadingInTime / shakeObject.FadeInTime) or 1, shakeObject.IsFadingOut and (1 - shakeObject.IsFadingOutTime / shakeObject.FadeOutTime) or 1)

		if (scaleShake > 0) then
			--delate the time by the frequency on both X and Y offsets
			shakeObject.XSineOffset = shakeObject.XSineOffset + (deltaTime * shakeObject.Frequency)
			shakeObject.YSineOffset = shakeObject.YSineOffset + (deltaTime * shakeObject.Frequency)

			--calc the new position
			local newX, newY
			if (shakeObject.AbsoluteSineX) then
				--absoluting only the sine wave, passing a negative scale will reverse the absolute direction
				newX = shakeObject.Amplitude * abs(math.sin(shakeObject.XSineOffset)) * scaleShake * shakeObject.ScaleX
			else
				newX = shakeObject.Amplitude * math.sin(shakeObject.XSineOffset) * scaleShake * shakeObject.ScaleX
			end

			if (shakeObject.AbsoluteSineY) then
				newY = shakeObject.Amplitude * abs(math.sin(shakeObject.YSineOffset)) * scaleShake * shakeObject.ScaleY
			else
				newY = shakeObject.Amplitude * math.sin(shakeObject.YSineOffset) * scaleShake * shakeObject.ScaleY
			end

			--apply the offset to the frame anchors
			for i = 1, #shakeObject.Anchors do
				local anchor = shakeObject.Anchors [i]

				if (#anchor == 1 or #anchor == 3) then
					local anchorTo, point1, point2 = unpack(anchor)
					point1 = point1 or 0
					point2 = point2 or 0
					parent:SetPoint(anchorTo, point1 + newX, point2 + newY)

				elseif (#anchor == 5) then
					local anchorName1, anchorTo, anchorName2, point1, point2 = unpack(anchor)
					parent:SetPoint(anchorName1, anchorTo, anchorName2, point1 + newX, point2 + newY)
				end
			end
		end
	else
		frameshake_ShakeFinished(parent, shakeObject)
	end
end

local frameshake_stop = function(parent, shakeObject)
	frameshake_ShakeFinished(parent, shakeObject)
end

--scale direction scales the X and Y coordinates, scale strength scales the amplitude and frequency
local frameshake_play = function(parent, shakeObject, scaleDirection, scaleAmplitude, scaleFrequency, scaleDuration)
	--check if is already playing
	if (shakeObject.TimeLeft > 0) then
		--reset the time left
		shakeObject.TimeLeft = shakeObject.Duration

		if (shakeObject.IsFadingOut) then
			if (shakeObject.FadeInTime > 0) then
				shakeObject.IsFadingIn = true
				--scale the current fade out into fade in, so it starts the fade in at the point where it was fading out
				shakeObject.IsFadingInTime = shakeObject.FadeInTime * (1 - shakeObject.IsFadingOutTime / shakeObject.FadeOutTime)
			else
				shakeObject.IsFadingIn = false
				shakeObject.IsFadingInTime = 0
			end

			--disable fade out and enable fade in
			shakeObject.IsFadingOut = false
			shakeObject.IsFadingOutTime = 0
		end
	else
		--create a new random offset
		shakeObject.XSineOffset = math.pi * 2 * math.random()
		shakeObject.YSineOffset = math.pi * 2 * math.random()

		--store the initial position if case it needs a reset
		shakeObject.StartedXSineOffset = shakeObject.XSineOffset
		shakeObject.StartedYSineOffset = shakeObject.YSineOffset

		--check if there's a fade in time
		if (shakeObject.FadeInTime > 0) then
			shakeObject.IsFadingIn = true
		else
			shakeObject.IsFadingIn = false
		end

		shakeObject.IsFadingInTime = 0
		shakeObject.IsFadingOut = false
		shakeObject.IsFadingOutTime = 0

		--apply custom scale
		shakeObject.ScaleX = (scaleDirection or 1) * shakeObject.OriginalScaleX
		shakeObject.ScaleY = (scaleDirection or 1) * shakeObject.OriginalScaleY
		shakeObject.Frequency = (scaleFrequency or 1) * shakeObject.OriginalFrequency
		shakeObject.Amplitude = (scaleAmplitude or 1) * shakeObject.OriginalAmplitude
		shakeObject.Duration = (scaleDuration or 1) * shakeObject.OriginalDuration

		--update the time left
		shakeObject.TimeLeft = shakeObject.Duration

		--check if is dynamic points
		if (shakeObject.IsDynamicAnchor) then
			wipe(shakeObject.Anchors)
			for i = 1, parent:GetNumPoints() do
				local p1, p2, p3, p4, p5 = parent:GetPoint(i)
				shakeObject.Anchors[#shakeObject.Anchors+1] = {p1, p2, p3, p4, p5}
			end
		end

		--update the amount of shake running on this frame
		parent.__frameshakes.enabled = parent.__frameshakes.enabled + 1

		if (not parent:GetScript("OnUpdate")) then
			parent:SetScript("OnUpdate", function()end)
		end
	end

	shakeObject.IsPlaying = true

	frameshake_DoUpdate(parent, shakeObject)
end

local frameshake_SetConfig = function(parent, shakeObject, duration, amplitude, frequency, absoluteSineX, absoluteSineY, scaleX, scaleY, fadeInTime, fadeOutTime)
	shakeObject.Amplitude = amplitude or shakeObject.Amplitude
	shakeObject.Frequency = frequency or shakeObject.Frequency
	shakeObject.Duration = duration or shakeObject.Duration
	shakeObject.FadeInTime = fadeInTime or shakeObject.FadeInTime
	shakeObject.FadeOutTime = fadeOutTime or shakeObject.FadeOutTime
	shakeObject.ScaleX  = scaleX or shakeObject.ScaleX
	shakeObject.ScaleY = scaleY or shakeObject.ScaleY

	if (absoluteSineX ~= nil) then
		shakeObject.AbsoluteSineX = absoluteSineX
	end

	if (absoluteSineY ~= nil) then
		shakeObject.AbsoluteSineY = absoluteSineY
	end

	shakeObject.OriginalScaleX = shakeObject.ScaleX
	shakeObject.OriginalScaleY = shakeObject.ScaleY
	shakeObject.OriginalFrequency = shakeObject.Frequency
	shakeObject.OriginalAmplitude = shakeObject.Amplitude
	shakeObject.OriginalDuration = shakeObject.Duration
end

---@class frameshake : table
---@field Amplitude number
---@field Frequency number
---@field Duration number
---@field FadeInTime number
---@field FadeOutTime number
---@field ScaleX number
---@field ScaleY number
---@field AbsoluteSineX boolean
---@field AbsoluteSineY boolean
---@field IsPlaying boolean
---@field TimeLeft number
---@field OriginalScaleX number
---@field OriginalScaleY number
---@field OriginalFrequency number
---@field OriginalAmplitude number
---@field OriginalDuration number
---@field PlayFrameShake fun(parent:uiobject, shakeObject:frameshake, scaleDirection:number?, scaleAmplitude:number?, scaleFrequency:number?, scaleDuration:number?)
---@field StopFrameShake fun(parent:uiobject, shakeObject:frameshake)
---@field SetFrameShakeSettings fun(parent:uiobject, shakeObject:frameshake, duration:number?, amplitude:number?, frequency:number?, absoluteSineX:boolean?, absoluteSineY:boolean?, scaleX:number?, scaleY:number?, fadeInTime:number?, fadeOutTime:number?)

---create a frame shake object
---@param parent uiobject
---@param duration number?
---@param amplitude number?
---@param frequency number?
---@param absoluteSineX boolean?
---@param absoluteSineY boolean?
---@param scaleX number?
---@param scaleY number?
---@param fadeInTime number?
---@param fadeOutTime number?
---@param anchorPoints table?
---@return frameshake
function DF:CreateFrameShake(parent, duration, amplitude, frequency, absoluteSineX, absoluteSineY, scaleX, scaleY, fadeInTime, fadeOutTime, anchorPoints)
	--create the shake table
	local frameShake = {
		Amplitude = amplitude or 2,
		Frequency = frequency or 5,
		Duration = duration or 0.3,
		FadeInTime = fadeInTime or 0.01,
		FadeOutTime = fadeOutTime or 0.01,
		ScaleX  = scaleX or 0.2,
		ScaleY = scaleY or 1,
		AbsoluteSineX = absoluteSineX,
		AbsoluteSineY = absoluteSineY,
		--
		IsPlaying = false,
		TimeLeft = 0,
	}

	frameShake.OriginalScaleX = frameShake.ScaleX
	frameShake.OriginalScaleY = frameShake.ScaleY
	frameShake.OriginalFrequency = frameShake.Frequency
	frameShake.OriginalAmplitude = frameShake.Amplitude
	frameShake.OriginalDuration = frameShake.Duration

	if (type(anchorPoints) ~= "table") then
		frameShake.IsDynamicAnchor = true
		frameShake.Anchors = {}
	else
		frameShake.Anchors = anchorPoints
	end

	--inject frame shake table into the frame
	if (not parent.__frameshakes) then
		parent.__frameshakes = {
			enabled = 0,
		}
		parent.PlayFrameShake = frameshake_play
		parent.StopFrameShake = frameshake_stop
		parent.UpdateFrameShake = frameshake_DoUpdate
		parent.SetFrameShakeSettings = frameshake_SetConfig

		--register the frame within the frame shake updater
		FrameshakeUpdateFrame.RegisterFrame (parent)
	end

	tinsert(parent.__frameshakes, frameShake)

	return frameShake
end


-----------------------------
--glow overlay

local glow_overlay_play = function(self)
	if (not self:IsShown()) then
		self:Show()
	end
	if (self.animOut) then
		if (self.animOut:IsPlaying()) then
			self.animOut:Stop()
		end
		if (not self.animIn:IsPlaying()) then
			self.animIn:Stop()
			self.animIn:Play()
		end
	elseif (self.ProcStartAnim) then
		if (not self.ProcStartAnim:IsPlaying()) then
			self.ProcStartAnim:Play()
		end
		if (not self.ProcLoop:IsPlaying()) then
			--self.ProcLoop:Play()
		end
	end
end

local glow_overlay_stop = function(self)
	if (self.animOut) then
		if (self.animOut:IsPlaying()) then
			self.animOut:Stop()
		end
		if (self.animIn:IsPlaying()) then
			self.animIn:Stop()
		end
	elseif (self.ProcStartAnim) then
		if (self.ProcStartAnim:IsPlaying()) then
			self.ProcStartAnim:Stop()
		end
	end
	if (self:IsShown()) then
		self:Hide()
	end
end

local glow_overlay_setcolor = function(self, antsColor, glowColor)
	if (antsColor) then
		local r, g, b, a = DF:ParseColors(antsColor)
		self.AntsColor = {r, g, b, a}
		if (self.ants) then
			self.ants:SetVertexColor(r, g, b, a)
		elseif (self.ProcLoopFlipbook) then
			self.ProcLoopFlipbook:SetVertexColor(r, g, b) --no alpha because of animation
			local anim1 = self.ProcLoop:GetAnimations()
			anim1:SetToAlpha(a)
		end
	end

	if (glowColor) then
		local r, g, b, a = DF:ParseColors(glowColor)
		self.GlowColor = {r, g, b, a}
		if (self.outerGlow) then
			self.outerGlow:SetVertexColor(r, g, b, a)
		elseif (self.ProcStartFlipbook) then
			self.ProcStartFlipbook:SetVertexColor(r, g, b) --no alpha because of animation
			local anim1, anim2, anim3 = self.ProcStartAnim:GetAnimations()
			anim1:SetToAlpha(a)
			anim3:SetFromAlpha(a)
		end
	end
end

local glow_overlay_onshow = function(self)
	glow_overlay_play (self)
end

local glow_overlay_onhide = function(self)
	glow_overlay_stop (self)
end

--this is most copied from the wow client code, few changes applied to customize it
function DF:CreateGlowOverlay (parent, antsColor, glowColor)
	local pName = parent:GetName()
	local fName = pName and (pName.."Glow2") or "OverlayActionGlow" .. math.random(1, 10000000)
	if fName and string.len(fName) > 50 then -- shorten to work around too long names
		fName = strsub(fName, string.len(fName)-49)
	end
	local glowFrame = CreateFrame("frame", fName, parent, "ActionBarButtonSpellActivationAlert")
	glowFrame:HookScript ("OnShow", glow_overlay_onshow)
	glowFrame:HookScript ("OnHide", glow_overlay_onhide)

	glowFrame.Play = glow_overlay_play
	glowFrame.Stop = glow_overlay_stop
	glowFrame.SetColor = glow_overlay_setcolor

	glowFrame:SetColor(antsColor, glowColor)

	glowFrame:Hide()

	parent.overlay = glowFrame
	local frameWidth, frameHeight = parent:GetSize()

	local scale = 1.4

	--Make the height/width available before the next frame:
	parent.overlay:SetSize(frameWidth * scale, frameHeight * scale)
	parent.overlay:SetPoint("TOPLEFT", parent, "TOPLEFT", -frameWidth * 0.32, frameHeight * 0.36)
	parent.overlay:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", frameWidth * 0.32, -frameHeight * 0.36)

	if (glowFrame.outerGlow) then
		glowFrame.outerGlow:SetScale(1.2)
	end
	if (glowFrame.ProcStartFlipbook) then
		glowFrame.ProcStartAnim:Stop()
		glowFrame.ProcStartFlipbook:ClearAllPoints()
		--glowFrame.ProcStartFlipbook:SetAllPoints()
		--glowFrame.ProcStartFlipbook:SetSize(frameWidth * scale, frameHeight * scale)
		glowFrame.ProcStartFlipbook:SetPoint("TOPLEFT", glowFrame, "TOPLEFT", -frameWidth * scale, frameHeight * scale)
		glowFrame.ProcStartFlipbook:SetPoint("BOTTOMRIGHT", glowFrame, "BOTTOMRIGHT", frameWidth * scale, -frameHeight * scale)
	end
	glowFrame:EnableMouse(false)
	return glowFrame
end

--custom glow with ants animation
local ants_set_texture_offset = function(self, leftOffset, rightOffset, topOffset, bottomOffset)
	leftOffset = leftOffset or 0
	rightOffset = rightOffset or 0
	topOffset = topOffset or 0
	bottomOffset = bottomOffset or 0

	self:ClearAllPoints()
	self:SetPoint("topleft", leftOffset, topOffset)
	self:SetPoint("bottomright", rightOffset, bottomOffset)
end

function DF:CreateAnts (parent, antTable, leftOffset, rightOffset, topOffset, bottomOffset, antTexture)
	leftOffset = leftOffset or 0
	rightOffset = rightOffset or 0
	topOffset = topOffset or 0
	bottomOffset = bottomOffset or 0

	local f = CreateFrame("frame", nil, parent)
	f:SetPoint("topleft", leftOffset, topOffset)
	f:SetPoint("bottomright", rightOffset, bottomOffset)

	f.SetOffset = ants_set_texture_offset

	local t = f:CreateTexture(nil, "overlay")
	t:SetAllPoints()
	t:SetTexture(antTable.Texture)
	t:SetBlendMode(antTable.BlendMode or "ADD")
	t:SetVertexColor(DF:ParseColors(antTable.Color or "white"))
	f.Texture = t

	f.AntTable = antTable

	f:SetScript("OnUpdate", function(self, deltaTime)
		AnimateTexCoords (t, self.AntTable.TextureWidth, self.AntTable.TextureHeight, self.AntTable.TexturePartsWidth, self.AntTable.TexturePartsHeight, self.AntTable.AmountParts, deltaTime, self.AntTable.Throttle or 0.025)
	end)

	return f
end

--[=[ --test ants
do
	local f = DF:CreateAnts (UIParent)
end
--]=]

-----------------------------
--borders

local default_border_color1 = .5
local default_border_color2 = .3
local default_border_color3 = .1

local SetBorderAlpha = function(self, alpha1, alpha2, alpha3)
	self.Borders.Alpha1 = alpha1 or self.Borders.Alpha1
	self.Borders.Alpha2 = alpha2 or self.Borders.Alpha2
	self.Borders.Alpha3 = alpha3 or self.Borders.Alpha3

	for _, texture in ipairs(self.Borders.Layer1) do
		texture:SetAlpha(self.Borders.Alpha1)
	end
	for _, texture in ipairs(self.Borders.Layer2) do
		texture:SetAlpha(self.Borders.Alpha2)
	end
	for _, texture in ipairs(self.Borders.Layer3) do
		texture:SetAlpha(self.Borders.Alpha3)
	end
end

local SetBorderColor = function(self, r, g, b)
	for _, texture in ipairs(self.Borders.Layer1) do
		texture:SetColorTexture(r, g, b)
	end
	for _, texture in ipairs(self.Borders.Layer2) do
		texture:SetColorTexture(r, g, b)
	end
	for _, texture in ipairs(self.Borders.Layer3) do
		texture:SetColorTexture(r, g, b)
	end
end

local SetLayerVisibility = function(self, layer1Shown, layer2Shown, layer3Shown)
	for _, texture in ipairs(self.Borders.Layer1) do
		texture:SetShown (layer1Shown)
	end

	for _, texture in ipairs(self.Borders.Layer2) do
		texture:SetShown (layer2Shown)
	end

	for _, texture in ipairs(self.Borders.Layer3) do
		texture:SetShown (layer3Shown)
	end
end

function DF:CreateBorder(parent, alpha1, alpha2, alpha3)
	parent.Borders = {
		Layer1 = {},
		Layer2 = {},
		Layer3 = {},
		Alpha1 = alpha1 or default_border_color1,
		Alpha2 = alpha2 or default_border_color2,
		Alpha3 = alpha3 or default_border_color3,
	}

	parent.SetBorderAlpha = SetBorderAlpha
	parent.SetBorderColor = SetBorderColor
	parent.SetLayerVisibility = SetLayerVisibility

	local border1 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border1, "topleft", parent, "topleft", -1, 1)
	PixelUtil.SetPoint(border1, "bottomleft", parent, "bottomleft", -1, -1)
	border1:SetColorTexture(0, 0, 0, alpha1 or default_border_color1)
	local border2 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border2, "topleft", parent, "topleft", -2, 2)
	PixelUtil.SetPoint(border2, "bottomleft", parent, "bottomleft", -2, -2)
	border2:SetColorTexture(0, 0, 0, alpha2 or default_border_color2)
	local border3 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border3, "topleft", parent, "topleft", -3, 3)
	PixelUtil.SetPoint(border3, "bottomleft", parent, "bottomleft", -3, -3)
	border3:SetColorTexture(0, 0, 0, alpha3 or default_border_color3)

	tinsert(parent.Borders.Layer1, border1)
	tinsert(parent.Borders.Layer2, border2)
	tinsert(parent.Borders.Layer3, border3)

	local border1 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border1, "topleft", parent, "topleft", 0, 1)
	PixelUtil.SetPoint(border1, "topright", parent, "topright", 1, 1)
	border1:SetColorTexture(0, 0, 0, alpha1 or default_border_color1)
	local border2 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border2, "topleft", parent, "topleft", -1, 2)
	PixelUtil.SetPoint(border2, "topright", parent, "topright", 2, 2)
	border2:SetColorTexture(0, 0, 0, alpha2 or default_border_color2)
	local border3 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border3, "topleft", parent, "topleft", -2, 3)
	PixelUtil.SetPoint(border3, "topright", parent, "topright", 3, 3)
	border3:SetColorTexture(0, 0, 0, alpha3 or default_border_color3)

	tinsert(parent.Borders.Layer1, border1)
	tinsert(parent.Borders.Layer2, border2)
	tinsert(parent.Borders.Layer3, border3)

	local border1 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border1, "topright", parent, "topright", 1, 0)
	PixelUtil.SetPoint(border1, "bottomright", parent, "bottomright", 1, -1)
	border1:SetColorTexture(0, 0, 0, alpha1 or default_border_color1)
	local border2 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border2, "topright", parent, "topright", 2, 1)
	PixelUtil.SetPoint(border2, "bottomright", parent, "bottomright", 2, -2)
	border2:SetColorTexture(0, 0, 0, alpha2 or default_border_color2)
	local border3 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border3, "topright", parent, "topright", 3, 2)
	PixelUtil.SetPoint(border3, "bottomright", parent, "bottomright", 3, -3)
	border3:SetColorTexture(0, 0, 0, alpha3 or default_border_color3)

	tinsert(parent.Borders.Layer1, border1)
	tinsert(parent.Borders.Layer2, border2)
	tinsert(parent.Borders.Layer3, border3)

	local border1 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border1, "bottomleft", parent, "bottomleft", 0, -1)
	PixelUtil.SetPoint(border1, "bottomright", parent, "bottomright", 0, -1)
	border1:SetColorTexture(0, 0, 0, alpha1 or default_border_color1)
	local border2 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border2, "bottomleft", parent, "bottomleft", -1, -2)
	PixelUtil.SetPoint(border2, "bottomright", parent, "bottomright", 1, -2)
	border2:SetColorTexture(0, 0, 0, alpha2 or default_border_color2)
	local border3 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border3, "bottomleft", parent, "bottomleft", -2, -3)
	PixelUtil.SetPoint(border3, "bottomright", parent, "bottomright", 2, -3)
	border3:SetColorTexture(0, 0, 0, alpha3 or default_border_color3)

	tinsert(parent.Borders.Layer1, border1)
	tinsert(parent.Borders.Layer2, border2)
	tinsert(parent.Borders.Layer3, border3)
end

--DFNamePlateBorder as copy from "NameplateFullBorderTemplate" -> DF:CreateFullBorder (name, parent)
local DFNamePlateBorderTemplateMixin = {};

function DFNamePlateBorderTemplateMixin:SetVertexColor(r, g, b, a)
	for i, texture in ipairs(self.Textures) do
		texture:SetVertexColor(r, g, b, a);
	end
end

function DFNamePlateBorderTemplateMixin:GetVertexColor()
	for i, texture in ipairs(self.Textures) do
		return texture:GetVertexColor();
	end
end

function DFNamePlateBorderTemplateMixin:SetBorderSizes(borderSize, borderSizeMinPixels, upwardExtendHeightPixels, upwardExtendHeightMinPixels)
	self.borderSize = borderSize;
	self.borderSizeMinPixels = borderSizeMinPixels;
	self.upwardExtendHeightPixels = upwardExtendHeightPixels;
	self.upwardExtendHeightMinPixels = upwardExtendHeightMinPixels;
end

function DFNamePlateBorderTemplateMixin:UpdateSizes()
	local borderSize = self.borderSize or 1;
	local minPixels = self.borderSizeMinPixels or 2;

	local upwardExtendHeightPixels = self.upwardExtendHeightPixels or borderSize;
	local upwardExtendHeightMinPixels = self.upwardExtendHeightMinPixels or minPixels;

	PixelUtil.SetWidth(self.Left, borderSize, minPixels);
	PixelUtil.SetPoint(self.Left, "TOPRIGHT", self, "TOPLEFT", 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels);
	PixelUtil.SetPoint(self.Left, "BOTTOMRIGHT", self, "BOTTOMLEFT", 0, -borderSize, 0, minPixels);

	PixelUtil.SetWidth(self.Right, borderSize, minPixels);
	PixelUtil.SetPoint(self.Right, "TOPLEFT", self, "TOPRIGHT", 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels);
	PixelUtil.SetPoint(self.Right, "BOTTOMLEFT", self, "BOTTOMRIGHT", 0, -borderSize, 0, minPixels);

	PixelUtil.SetHeight(self.Bottom, borderSize, minPixels);
	PixelUtil.SetPoint(self.Bottom, "TOPLEFT", self, "BOTTOMLEFT", 0, 0);
	PixelUtil.SetPoint(self.Bottom, "TOPRIGHT", self, "BOTTOMRIGHT", 0, 0);

	if self.Top then
		PixelUtil.SetHeight(self.Top, borderSize, minPixels);
		PixelUtil.SetPoint(self.Top, "BOTTOMLEFT", self, "TOPLEFT", 0, 0);
		PixelUtil.SetPoint(self.Top, "BOTTOMRIGHT", self, "TOPRIGHT", 0, 0);
	end
end

function DF:CreateFullBorder (name, parent)
	local border = CreateFrame("Frame", name, parent)
	border:SetAllPoints()
	border:SetIgnoreParentScale(true)
	border:SetFrameLevel(border:GetParent():GetFrameLevel())
	border.Textures = {}
	Mixin(border, DFNamePlateBorderTemplateMixin)

	local left = border:CreateTexture("$parentLeft", "BACKGROUND", nil, -8)
	--left:SetDrawLayer("BACKGROUND", -8)
	left:SetColorTexture(1, 1, 1, 1)
	left:SetWidth(1.0)
	left:SetPoint("TOPRIGHT", border, "TOPLEFT", 0, 1.0)
	left:SetPoint("BOTTOMRIGHT", border, "BOTTOMLEFT", 0, -1.0)
	border.Left = left
	tinsert(border.Textures, left)

	local right = border:CreateTexture("$parentRight", "BACKGROUND", nil, -8)
	--right:SetDrawLayer("BACKGROUND", -8)
	right:SetColorTexture(1, 1, 1, 1)
	right:SetWidth(1.0)
	right:SetPoint("TOPLEFT", border, "TOPRIGHT", 0, 1.0)
	right:SetPoint("BOTTOMLEFT", border, "BOTTOMRIGHT", 0, -1.0)
	border.Right = right
	tinsert(border.Textures, right)

	local bottom = border:CreateTexture("$parentBottom", "BACKGROUND", nil, -8)
	--bottom:SetDrawLayer("BACKGROUND", -8)
	bottom:SetColorTexture(1, 1, 1, 1)
	bottom:SetHeight(1.0)
	bottom:SetPoint("TOPLEFT", border, "BOTTOMLEFT", 0, 0)
	bottom:SetPoint("TOPRIGHT", border, "BOTTOMRIGHT", 0, 0)
	border.Bottom = bottom
	tinsert(border.Textures, bottom)

	local top = border:CreateTexture("$parentTop", "BACKGROUND", nil, -8)
	--top:SetDrawLayer("BACKGROUND", -8)
	top:SetColorTexture(1, 1, 1, 1)
	top:SetHeight(1.0)
	top:SetPoint("BOTTOMLEFT", border, "TOPLEFT", 0, 0)
	top:SetPoint("BOTTOMRIGHT", border, "TOPRIGHT", 0, 0)
	border.Top = top
	tinsert(border.Textures, top)

	return border
end

function DF:CreateBorderSolid (parent, size)

end

function DF:CreateBorderWithSpread(parent, alpha1, alpha2, alpha3, size, spread)
	parent.Borders = {
		Layer1 = {},
		Layer2 = {},
		Layer3 = {},
		Alpha1 = alpha1 or default_border_color1,
		Alpha2 = alpha2 or default_border_color2,
		Alpha3 = alpha3 or default_border_color3,
	}

	parent.SetBorderAlpha = SetBorderAlpha
	parent.SetBorderColor = SetBorderColor
	parent.SetLayerVisibility = SetLayerVisibility

	size = size or 1
	local minPixels = 1
	local spread = 0

	--left
	local border1 = parent:CreateTexture(nil, "background")
	border1:SetColorTexture(0, 0, 0, alpha1 or default_border_color1)
	PixelUtil.SetPoint(border1, "topleft", parent, "topleft", -1 + spread, 1 + (-spread), 0, 0)
	PixelUtil.SetPoint(border1, "bottomleft", parent, "bottomleft", -1 + spread, -1 + spread, 0, 0)
	PixelUtil.SetWidth (border1, size, minPixels)

	local border2 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border2, "topleft", parent, "topleft", -2 + spread, 2 + (-spread))
	PixelUtil.SetPoint(border2, "bottomleft", parent, "bottomleft", -2 + spread, -2 + spread)
	border2:SetColorTexture(0, 0, 0, alpha2 or default_border_color2)
	PixelUtil.SetWidth (border2, size, minPixels)

	local border3 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border3, "topleft", parent, "topleft", -3 + spread, 3 + (-spread))
	PixelUtil.SetPoint(border3, "bottomleft", parent, "bottomleft", -3 + spread, -3 + spread)
	border3:SetColorTexture(0, 0, 0, alpha3 or default_border_color3)
	PixelUtil.SetWidth (border3, size, minPixels)

	tinsert(parent.Borders.Layer1, border1)
	tinsert(parent.Borders.Layer2, border2)
	tinsert(parent.Borders.Layer3, border3)

	--top
	local border1 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border1, "topleft", parent, "topleft", 0 + spread, 1 + (-spread))
	PixelUtil.SetPoint(border1, "topright", parent, "topright", 1 + (-spread), 1 + (-spread))
	border1:SetColorTexture(0, 0, 0, alpha1 or default_border_color1)
	PixelUtil.SetHeight(border1, size, minPixels)

	local border2 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border2, "topleft", parent, "topleft", -1 + spread, 2 + (-spread))
	PixelUtil.SetPoint(border2, "topright", parent, "topright", 2 + (-spread), 2 + (-spread))
	border2:SetColorTexture(0, 0, 0, alpha2 or default_border_color2)
	PixelUtil.SetHeight(border2, size, minPixels)

	local border3 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border3, "topleft", parent, "topleft", -2 + spread, 3 + (-spread))
	PixelUtil.SetPoint(border3, "topright", parent, "topright", 3 + (-spread), 3 + (-spread))
	border3:SetColorTexture(0, 0, 0, alpha3 or default_border_color3)
	PixelUtil.SetHeight(border3, size, minPixels)

	tinsert(parent.Borders.Layer1, border1)
	tinsert(parent.Borders.Layer2, border2)
	tinsert(parent.Borders.Layer3, border3)

	--right
	local border1 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border1, "topright", parent, "topright", 1 + (-spread), 0 + (-spread))
	PixelUtil.SetPoint(border1, "bottomright", parent, "bottomright", 1 + (-spread), -1 + spread)
	border1:SetColorTexture(0, 0, 0, alpha1 or default_border_color1)
	PixelUtil.SetWidth (border1, size, minPixels)

	local border2 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border2, "topright", parent, "topright", 2 + (-spread), 1 + (-spread))
	PixelUtil.SetPoint(border2, "bottomright", parent, "bottomright", 2 + (-spread), -2 + spread)
	border2:SetColorTexture(0, 0, 0, alpha2 or default_border_color2)
	PixelUtil.SetWidth (border2, size, minPixels)

	local border3 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border3, "topright", parent, "topright", 3 + (-spread), 2 + (-spread))
	PixelUtil.SetPoint(border3, "bottomright", parent, "bottomright", 3 + (-spread), -3 + spread)
	border3:SetColorTexture(0, 0, 0, alpha3 or default_border_color3)
	PixelUtil.SetWidth (border3, size, minPixels)

	tinsert(parent.Borders.Layer1, border1)
	tinsert(parent.Borders.Layer2, border2)
	tinsert(parent.Borders.Layer3, border3)

	local border1 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border1, "bottomleft", parent, "bottomleft", 0 + spread, -1 + spread)
	PixelUtil.SetPoint(border1, "bottomright", parent, "bottomright", 0 + (-spread), -1 + spread)
	border1:SetColorTexture(0, 0, 0, alpha1 or default_border_color1)
	PixelUtil.SetHeight(border1, size, minPixels)

	local border2 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border2, "bottomleft", parent, "bottomleft", -1 + spread, -2 + spread)
	PixelUtil.SetPoint(border2, "bottomright", parent, "bottomright", 1 + (-spread), -2 + spread)
	border2:SetColorTexture(0, 0, 0, alpha2 or default_border_color2)
	PixelUtil.SetHeight(border2, size, minPixels)

	local border3 = parent:CreateTexture(nil, "background")
	PixelUtil.SetPoint(border3, "bottomleft", parent, "bottomleft", -2 + spread, -3 + spread)
	PixelUtil.SetPoint(border3, "bottomright", parent, "bottomright", 2 + (-spread), -3 + spread)
	border3:SetColorTexture(0, 0, 0, alpha3 or default_border_color3)
	PixelUtil.SetHeight(border3, size, minPixels)

	tinsert(parent.Borders.Layer1, border1)
	tinsert(parent.Borders.Layer2, border2)
	tinsert(parent.Borders.Layer3, border3)

end

function DF:ReskinSlider(slider, heightOffset)
	if (slider.slider) then
		slider.cima:SetNormalTexture([[Interface\Buttons\Arrow-Up-Up]])
		slider.cima:SetPushedTexture([[Interface\Buttons\Arrow-Up-Down]])
		slider.cima:SetDisabledTexture([[Interface\Buttons\Arrow-Up-Disabled]])
		slider.cima:GetNormalTexture():ClearAllPoints()
		slider.cima:GetPushedTexture():ClearAllPoints()
		slider.cima:GetDisabledTexture():ClearAllPoints()
		slider.cima:GetNormalTexture():SetPoint("center", slider.cima, "center", 1, 1)
		slider.cima:GetPushedTexture():SetPoint("center", slider.cima, "center", 1, 1)
		slider.cima:GetDisabledTexture():SetPoint("center", slider.cima, "center", 1, 1)
		slider.cima:SetSize(16, 16)

		slider.baixo:SetNormalTexture([[Interface\Buttons\Arrow-Down-Up]])
		slider.baixo:SetPushedTexture([[Interface\Buttons\Arrow-Down-Down]])
		slider.baixo:SetDisabledTexture([[Interface\Buttons\Arrow-Down-Disabled]])
		slider.baixo:GetNormalTexture():ClearAllPoints()
		slider.baixo:GetPushedTexture():ClearAllPoints()
		slider.baixo:GetDisabledTexture():ClearAllPoints()
		slider.baixo:GetNormalTexture():SetPoint("center", slider.baixo, "center", 1, -5)
		slider.baixo:GetPushedTexture():SetPoint("center", slider.baixo, "center", 1, -5)
		slider.baixo:GetDisabledTexture():SetPoint("center", slider.baixo, "center", 1, -5)
		slider.baixo:SetSize(16, 16)

		slider.slider:cimaPoint(0, 13)
		slider.slider:baixoPoint(0, -13)
		slider.slider.thumb:SetTexture([[Interface\AddOns\Details\images\icons2]])
		slider.slider.thumb:SetTexCoord(482/512, 492/512, 104/512, 120/512)
		slider.slider.thumb:SetSize(12, 12)
		slider.slider.thumb:SetVertexColor(0.6, 0.6, 0.6, 0.95)

	else
		--up button
		local offset = 1 --space between the scrollbox and the scrollar

		local backgroundColor_Red = 0.1
		local backgroundColor_Green = 0.1
		local backgroundColor_Blue = 0.1
		local backgroundColor_Alpha = 1
		local backdrop_Alpha = 0.3

		do
			local normalTexture = slider.ScrollBar.ScrollUpButton.Normal
			normalTexture:SetTexture([[Interface\Buttons\Arrow-Up-Up]])
			normalTexture:SetTexCoord(0, 1, .2, 1)

			normalTexture:SetPoint("topleft", slider.ScrollBar.ScrollUpButton, "topleft", offset, 0)
			normalTexture:SetPoint("bottomright", slider.ScrollBar.ScrollUpButton, "bottomright", offset, 0)

			local pushedTexture = slider.ScrollBar.ScrollUpButton.Pushed
			pushedTexture:SetTexture([[Interface\Buttons\Arrow-Up-Down]])
			pushedTexture:SetTexCoord(0, 1, .2, 1)

			pushedTexture:SetPoint("topleft", slider.ScrollBar.ScrollUpButton, "topleft", offset, 0)
			pushedTexture:SetPoint("bottomright", slider.ScrollBar.ScrollUpButton, "bottomright", offset, 0)

			local disabledTexture = slider.ScrollBar.ScrollUpButton.Disabled
			disabledTexture:SetTexture([[Interface\Buttons\Arrow-Up-Disabled]])
			disabledTexture:SetTexCoord(0, 1, .2, 1)
			disabledTexture:SetAlpha(.5)

			disabledTexture:SetPoint("topleft", slider.ScrollBar.ScrollUpButton, "topleft", offset, 0)
			disabledTexture:SetPoint("bottomright", slider.ScrollBar.ScrollUpButton, "bottomright", offset, 0)

			slider.ScrollBar.ScrollUpButton:SetSize(16, 16)

			if (not slider.ScrollBar.ScrollUpButton.BackgroundTexture) then
				local backgroundTexture = slider.ScrollBar.ScrollUpButton:CreateTexture(nil, "border")
				slider.ScrollBar.ScrollUpButton.BackgroundTexture = backgroundTexture

				backgroundTexture:SetColorTexture(backgroundColor_Red, backgroundColor_Green, backgroundColor_Blue)
				backgroundTexture:SetAlpha(backgroundColor_Alpha)

				backgroundTexture:SetPoint("topleft", slider.ScrollBar.ScrollUpButton, "topleft", 1, 0)
				backgroundTexture:SetPoint("bottomright", slider.ScrollBar.ScrollUpButton, "bottomright", -1, 0)
			end

			DF:Mixin(slider.ScrollBar.ScrollUpButton, BackdropTemplateMixin)
			slider.ScrollBar.ScrollUpButton:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
			slider.ScrollBar.ScrollUpButton:SetBackdropBorderColor(0, 0, 0, backdrop_Alpha)
		end

		--down button
		do
			local normalTexture = slider.ScrollBar.ScrollDownButton.Normal
			normalTexture:SetTexture([[Interface\Buttons\Arrow-Down-Up]])
			normalTexture:SetTexCoord(0, 1, 0, .8)

			normalTexture:SetPoint("topleft", slider.ScrollBar.ScrollDownButton, "topleft", offset, -4)
			normalTexture:SetPoint("bottomright", slider.ScrollBar.ScrollDownButton, "bottomright", offset, -4)

			local pushedTexture = slider.ScrollBar.ScrollDownButton.Pushed
			pushedTexture:SetTexture([[Interface\Buttons\Arrow-Down-Down]])
			pushedTexture:SetTexCoord(0, 1, 0, .8)

			pushedTexture:SetPoint("topleft", slider.ScrollBar.ScrollDownButton, "topleft", offset, -4)
			pushedTexture:SetPoint("bottomright", slider.ScrollBar.ScrollDownButton, "bottomright", offset, -4)

			local disabledTexture = slider.ScrollBar.ScrollDownButton.Disabled
			disabledTexture:SetTexture([[Interface\Buttons\Arrow-Down-Disabled]])
			disabledTexture:SetTexCoord(0, 1, 0, .8)
			disabledTexture:SetAlpha(.5)

			disabledTexture:SetPoint("topleft", slider.ScrollBar.ScrollDownButton, "topleft", offset, -4)
			disabledTexture:SetPoint("bottomright", slider.ScrollBar.ScrollDownButton, "bottomright", offset, -4)

			slider.ScrollBar.ScrollDownButton:SetSize(16, 16)

			if (not slider.ScrollBar.ScrollDownButton.BackgroundTexture) then
				local backgroundTexture = slider.ScrollBar.ScrollDownButton:CreateTexture(nil, "border")
				slider.ScrollBar.ScrollDownButton.BackgroundTexture = backgroundTexture

				backgroundTexture:SetColorTexture(backgroundColor_Red, backgroundColor_Green, backgroundColor_Blue)
				backgroundTexture:SetAlpha(backgroundColor_Alpha)

				backgroundTexture:SetPoint("topleft", slider.ScrollBar.ScrollDownButton, "topleft", 1, 0)
				backgroundTexture:SetPoint("bottomright", slider.ScrollBar.ScrollDownButton, "bottomright", -1, 0)
			end

			DF:Mixin(slider.ScrollBar.ScrollDownButton, BackdropTemplateMixin)
			slider.ScrollBar.ScrollDownButton:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
			slider.ScrollBar.ScrollDownButton:SetBackdropBorderColor(0, 0, 0, backdrop_Alpha)
		end

		--if the parent has a editbox, this is a code editor
		if (slider:GetParent().editbox) then
			slider.ScrollBar:SetPoint("TOPLEFT", slider, "TOPRIGHT", 12 + offset, -6)
			slider.ScrollBar:SetPoint("BOTTOMLEFT", slider, "BOTTOMRIGHT", 12 + offset, 6 + (heightOffset and heightOffset*-1 or 0))

		else
			slider.ScrollBar:SetPoint("TOPLEFT", slider, "TOPRIGHT", 6, -16)
			slider.ScrollBar:SetPoint("BOTTOMLEFT", slider, "BOTTOMRIGHT", 6, 16 + (heightOffset and heightOffset*-1 or 0))
		end

		slider.ScrollBar.ThumbTexture:SetColorTexture(.5, .5, .5, .3)
		slider.ScrollBar.ThumbTexture:SetSize(14, 8)

		if (not slider.ScrollBar.SliderTexture) then
			local alpha = 1
			local offset = 1
			slider.ScrollBar.SliderTexture = slider.ScrollBar:CreateTexture(nil, "background")
			slider.ScrollBar.SliderTexture:SetColorTexture(backgroundColor_Red, backgroundColor_Green, backgroundColor_Blue)
			slider.ScrollBar.SliderTexture:SetAlpha(backgroundColor_Alpha)
			slider.ScrollBar.SliderTexture:SetPoint("TOPLEFT", slider.ScrollBar, "TOPLEFT", offset, -2)
			slider.ScrollBar.SliderTexture:SetPoint("BOTTOMRIGHT", slider.ScrollBar, "BOTTOMRIGHT", -offset, 2)
		end

		DF:Mixin(slider.ScrollBar, BackdropTemplateMixin)
		slider.ScrollBar:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
		slider.ScrollBar:SetBackdropBorderColor(0, 0, 0, backdrop_Alpha)
	end
end

function DF:GetCurrentClassName()
	local className = UnitClass("player")
	return className
end

function DF:GetCurrentSpecName()
	local specIndex = DF.GetSpecialization()
	if (specIndex) then
		local specId, specName = DF.GetSpecializationInfo(specIndex)
		if (specId and specId ~= 0) then
			return specName
		end
	end
end

function DF:GetCurrentSpec()
	local specIndex = DF.GetSpecialization()
	if (specIndex) then
		local specId = DF.GetSpecializationInfo(specIndex)
		if (specId and specId ~= 0) then
			return specId
		end
	end
end

function DF:GetCurrentSpecId()
	return DF:GetCurrentSpec()
end

local specs_per_class = {
	["DEMONHUNTER"] = {577, 581},
	["DEATHKNIGHT"] = {250, 251, 252},
	["WARRIOR"] = {71, 72, 73},
	["MAGE"] = {62, 63, 64},
	["ROGUE"] = {259, 260, 261},
	["DRUID"] = {102, 103, 104, 105},
	["HUNTER"] = {253, 254, 255},
	["SHAMAN"] = {262, 263, 254},
	["PRIEST"] = {256, 257, 258},
	["WARLOCK"] = {265, 266, 267},
	["PALADIN"] = {65, 66, 70},
	["MONK"] = {268, 269, 270},
	["EVOKER"] = {1467, 1468, 1473},
}


function DF:GetClassSpecIDs(engClass)
	return specs_per_class[engClass]
end
function DF:GetClassSpecIds(engClass) --naming conventions
	return DF:GetClassSpecIDs(engClass)
end

local dispatch_error = function(context, errortext)
	DF:Msg( (context or "<no context>") .. " |cFFFF9900error|r: " .. (errortext or "<no error given>"))
end

--call a function with payload, if the callback doesn't exists, quit silently
function DF:QuickDispatch(func, ...)
	if (type(func) ~= "function") then
		return
	end

	local okay, errortext = xpcall(func, geterrorhandler(), ...)

	if (not okay) then
		--trigger an error msg
		dispatch_error(_, errortext)
		return
	end

	return true
end

---call a function in safe mode with payload
---@param func function
---@param ... any
---@return any
function DF:Dispatch(func, ...)
	if (type(func) ~= "function") then
		return dispatch_error(_, "DetailsFramework:Dispatch(func) expect a function as parameter 1.")
	end
	return select(2, xpcall(func, geterrorhandler(), ...))

	--[=[
		local dispatchResult = {xpcall(func, geterrorhandler(), ...)}
		local okay = dispatchResult[1]

		if (not okay) then
			return false
		end

		tremove(dispatchResult, 1)

		return unpack(dispatchResult)
	--]=]
end

--[=[
	DF:CoreDispatch(func, context, ...)
	safe call a function making an error window with what caused, context and traceback of the error
	this func is only used inside the framework for sensitive calls where the func must run without errors
	@func = the function which will be called
	@context = what made the function be called
	... parameters to pass in the function call
--]=]
function DF:CoreDispatch(context, func, ...)
	if (type(func) ~= "function") then
		local stack = debugstack(2)
		local errortext = "D!Framework " .. context .. " error: invalid function to call\n====================\n" .. stack .. "\n====================\n"
		error(errortext)
	end

	local okay, result1, result2, result3, result4 = xpcall(func, geterrorhandler(), ...)

	--if (not okay) then --when using pcall
		--local stack = debugstack(2)
		--local errortext = "D!Framework (" .. context .. ") error: " .. result1 .. "\n====================\n" .. stack .. "\n====================\n"
		--error(errortext)
	--end

	return result1, result2, result3, result4
end


DF.ClassIndexToFileName = {
	[6] = "DEATHKNIGHT",
	[1] = "WARRIOR",
	[4] = "ROGUE",
	[8] = "MAGE",
	[5] = "PRIEST",
	[3] = "HUNTER",
	[9] = "WARLOCK",
	[12] = "DEMONHUNTER",
	[7] = "SHAMAN",
	[11] = "DRUID",
	[10] = "MONK",
	[2] = "PALADIN",
	[13] = "EVOKER",
}


DF.ClassFileNameToIndex = {
	["WARRIOR"] = 1,
	["PALADIN"] = 2,
	["HUNTER"] = 3,
	["ROGUE"] = 4,
	["PRIEST"] = 5,
	["DEATHKNIGHT"] = 6,
	["SHAMAN"] = 7,
	["MAGE"] = 8,
	["WARLOCK"] = 9,
	["MONK"] = 10,
	["DRUID"] = 11,
	["DEMONHUNTER"] = 12,
	["EVOKER"] = 13,
}
DF.ClassCache = {}

function DF:GetClassList()
	if (next (DF.ClassCache)) then
		return DF.ClassCache
	end

	for className, classIndex in pairs(DF.ClassFileNameToIndex) do
		local classTable = C_CreatureInfo.GetClassInfo(classIndex)
		if classTable then
			local t = {
				ID = classIndex,
				Name = classTable.className,
				Texture = [[Interface\GLUES\CHARACTERCREATE\UI-CharacterCreate-Classes]],
				TexCoord = CLASS_ICON_TCOORDS[className],
				FileString = className,
			}
			table.insert(DF.ClassCache, t)
		end
	end

	return DF.ClassCache
end

--hardcoded race list
DF.RaceList = {
	[1] = "Human",
	[2] = "Orc",
	[3] = "Dwarf",
	[4] = "NightElf",
	[5] = "Scourge",
	[6] = "Tauren",
	[7] = "Gnome",
	[8] = "Troll",
	[9] = "Goblin",
	[10] = "BloodElf",
	[11] = "Draenei",
	[22] = "Worgen",
	[24] = "Pandaren",
}

DF.AlliedRaceList = {
	[27] = "Nightborne",
	[29] = "HighmountainTauren",
	[31] = "VoidElf",
	[33] = "LightforgedDraenei",
	[35] = "ZandalariTroll",
	[36] = "KulTiran",
	[38] = "DarkIronDwarf",
	[40] = "Vulpera",
	[41] = "MagharOrc",
}

local slotIdToIcon = {
	[1] = "Interface\\ICONS\\" .. "INV_Helmet_29", --head
	[2] = "Interface\\ICONS\\" .. "INV_Jewelry_Necklace_07", --neck
	[3] = "Interface\\ICONS\\" .. "INV_Shoulder_25", --shoulder
	[5] = "Interface\\ICONS\\" .. "INV_Chest_Cloth_08", --chest
	[6] = "Interface\\ICONS\\" .. "INV_Belt_15", --waist
	[7] = "Interface\\ICONS\\" .. "INV_Pants_08", --legs
	[8] = "Interface\\ICONS\\" .. "INV_Boots_Cloth_03", --feet
	[9] = "Interface\\ICONS\\" .. "INV_Bracer_07", --wrist
	[10] = "Interface\\ICONS\\" .. "INV_Gauntlets_17", --hands
	[11] = "Interface\\ICONS\\" .. "INV_Jewelry_Ring_22", --finger 1
	[12] = "Interface\\ICONS\\" .. "INV_Jewelry_Ring_22", --finger 2
	[13] = "Interface\\ICONS\\" .. "INV_Jewelry_Talisman_07", --trinket 1
	[14] = "Interface\\ICONS\\" .. "INV_Jewelry_Talisman_07", --trinket 2
	[15] = "Interface\\ICONS\\" .. "INV_Misc_Cape_19", --back
	[16] = "Interface\\ICONS\\" .. "INV_Sword_39", --main hand
	[17] = "Interface\\ICONS\\" .. "INV_Sword_39", --off hand
}

function DF:GetArmorIconByArmorSlot(equipSlotId)
	return slotIdToIcon[equipSlotId] or ""
end


--store and return a list of character races, always return the non-localized value
DF.RaceCache = {}
function DF:GetCharacterRaceList()
	if (next (DF.RaceCache)) then
		return DF.RaceCache
	end

	for i = 1, 100 do
		local raceInfo = C_CreatureInfo.GetRaceInfo(i)
		if (raceInfo and DF.RaceList [raceInfo.raceID]) then
			tinsert(DF.RaceCache, {Name = raceInfo.raceName, FileString = raceInfo.clientFileString, ID = raceInfo.raceID})
		end

		if IS_WOW_PROJECT_MAINLINE then
			local alliedRaceInfo = C_AlliedRaces.GetRaceInfoByID(i)
			if (alliedRaceInfo and DF.AlliedRaceList [alliedRaceInfo.raceID]) then
				tinsert(DF.RaceCache, {Name = alliedRaceInfo.maleName, FileString = alliedRaceInfo.raceFileString, ID = alliedRaceInfo.raceID})
			end
		end
	end

	return DF.RaceCache
end

--get a list of talents for the current spec the player is using
--if onlySelected return an index table with only the talents the character has selected
--if onlySelectedHash return a hash table with [spelID] = true
function DF:GetCharacterTalents(bOnlySelected, bOnlySelectedHash)
	local talentList = {}
	local version, build, date, tocversion = GetBuildInfo()

	if (tocversion >= 70000 and tocversion <= 99999) then
		for i = 1, 7 do
			for o = 1, 3 do
				local talentID, name, texture, selected, available = GetTalentInfo(i, o, 1)
				if (bOnlySelectedHash) then
					if (selected) then
						talentList[talentID] = true
						break
					end
				elseif (bOnlySelected) then
					if (selected) then
						table.insert(talentList, {Name = name, ID = talentID, Texture = texture, IsSelected = selected})
						break
					end
				else
					table.insert(talentList, {Name = name, ID = talentID, Texture = texture, IsSelected = selected})
				end
			end
		end

	elseif (tocversion >= 100000) then
		if (not bOnlySelected) then
			return DF:GetAllTalents()
		end

		local configId = C_ClassTalents.GetActiveConfigID()
		if (configId) then
			local configInfo = C_Traits.GetConfigInfo(configId)
			--get the spells from the SPEC from talents
			for treeIndex, treeId in ipairs(configInfo.treeIDs) do
				local treeNodes = C_Traits.GetTreeNodes(treeId)

				for nodeIdIndex, treeNodeID in ipairs(treeNodes) do
					local traitNodeInfo = C_Traits.GetNodeInfo(configId, treeNodeID)

					if (traitNodeInfo) then
						local activeEntry = traitNodeInfo.activeEntry
						local entryIds = traitNodeInfo.entryIDs

						for i = 1, #entryIds do
							local entryId = entryIds[i] --number
							local traitEntryInfo = C_Traits.GetEntryInfo(configId, entryId)
							local borderTypes = Enum.TraitNodeEntryType

							if (traitEntryInfo.type) then -- == borderTypes.SpendCircle
								local definitionId = traitEntryInfo.definitionID
								local traitDefinitionInfo = C_Traits.GetDefinitionInfo(definitionId)
								local spellId = traitDefinitionInfo.overriddenSpellID or traitDefinitionInfo.spellID
								local spellName, _, spellTexture = GetSpellInfo(spellId)
								local bIsSelected = (activeEntry and activeEntry.rank and activeEntry.rank > 0) or false
								if (spellName and bIsSelected) then
									local talentInfo = {Name = spellName, ID = spellId, Texture = spellTexture, IsSelected = true}
									if (bOnlySelectedHash) then
										talentList[spellId] = talentInfo
									else
										table.insert(talentList, talentInfo)
									end
								end
							end
						end
					end
				end
			end
		end
	end

	return talentList
end

function DF:GetCharacterPvPTalents(onlySelected, onlySelectedHash)
	if (onlySelected or onlySelectedHash) then
		local talentsSelected = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
		local talentList = {}
		for _, talentID in ipairs(talentsSelected) do
			local _, talentName, texture = GetPvpTalentInfoByID (talentID)
			if (onlySelectedHash) then
				talentList [talentID] = true
			else
				tinsert(talentList, {Name = talentName, ID = talentID, Texture = texture, IsSelected = true})
			end
		end
		return talentList

	else
		local alreadyAdded = {}
		local talentList = {}
		for i = 1, 4 do --4 slots - get talents available in each one
			local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo (i)
			if (slotInfo) then
				for _, talentID in ipairs(slotInfo.availableTalentIDs) do
					if (not alreadyAdded [talentID]) then
						local _, talentName, texture, selected = GetPvpTalentInfoByID (talentID)
						tinsert(talentList, {Name = talentName, ID = talentID, Texture = texture, IsSelected = selected})
						alreadyAdded [talentID] = true
					end
				end
			end
		end
		return talentList
	end
end

DF.GroupTypes = {
	{Name = "Arena", ID = "arena"},
	{Name = "Battleground", ID = "pvp"},
	{Name = "Raid", ID = "raid"},
	{Name = "Dungeon", ID = "party"},
	{Name = "Scenario", ID = "scenario"},
	{Name = "Open World", ID = "none"},
}
function DF:GetGroupTypes()
	return DF.GroupTypes
end

DF.RoleTypes = {
	{Name = _G.DAMAGER, ID = "DAMAGER", Texture = _G.INLINE_DAMAGER_ICON},
	{Name = _G.HEALER, ID = "HEALER", Texture = _G.INLINE_HEALER_ICON},
	{Name = _G.TANK, ID = "TANK", Texture = _G.INLINE_TANK_ICON},
}
function DF:GetRoleTypes()
	return DF.RoleTypes
end

local roleTexcoord = {
	DAMAGER = "72:130:69:127",
	HEALER = "72:130:2:60",
	TANK = "5:63:69:127",
	NONE = "139:196:69:127",
}

local roleTextures = {
	DAMAGER = "Interface\\LFGFRAME\\UI-LFG-ICON-ROLES",
	TANK = "Interface\\LFGFRAME\\UI-LFG-ICON-ROLES",
	HEALER = "Interface\\LFGFRAME\\UI-LFG-ICON-ROLES",
	NONE = "Interface\\LFGFRAME\\UI-LFG-ICON-ROLES",
}

local roleTexcoord2 = {
	DAMAGER = {72/256, 130/256, 69/256, 127/256},
	HEALER = {72/256, 130/256, 2/256, 60/256},
	TANK = {5/256, 63/256, 69/256, 127/256},
	NONE = {139/256, 196/256, 69/256, 127/256},
}

function DF:GetRoleIconAndCoords(role)
	local texture = roleTextures[role]
	local coords = roleTexcoord2[role]
	return texture, unpack(coords)
end

function DF:AddRoleIconToText(text, role, size)
	if (role and type(role) == "string") then
		local coords = GetTexCoordsForRole(role)
		if (coords) then
			if (type(text) == "string" and role ~= "NONE") then
				size = size or 14
				text = "|TInterface\\LFGFRAME\\UI-LFG-ICON-ROLES:" .. size .. ":" .. size .. ":0:0:256:256:" .. roleTexcoord[role] .. "|t " .. text
				return text
			end
		end
	end

	return text
end

function DF:GetRoleTCoordsAndTexture(roleID)
	local texture, l, r, t, b = DF:GetRoleIconAndCoords(roleID)
	return l, r, t, b, texture
end

-- TODO: maybe make this auto-generaded some day?...
DF.CLEncounterID = {
	{ID = 2423, Name = "The Tarragrue"},
	{ID = 2433, Name = "The Eye of the Jailer"},
	{ID = 2429, Name = "The Nine"},
	{ID = 2432, Name = "Remnant of Ner'zhul"},
	{ID = 2434, Name = "Soulrender Dormazain"},
	{ID = 2430, Name = "Painsmith Raznal"},
	{ID = 2436, Name = "Guardian of the First Ones"},
	{ID = 2431, Name = "Fatescribe Roh-Kalo"},
	{ID = 2422, Name = "Kel'Thuzad"},
	{ID = 2435, Name = "Sylvanas Windrunner"},
}

function DF:GetPlayerRole()
	local assignedRole = DF.UnitGroupRolesAssigned("player")
	if (assignedRole == "NONE") then
		local spec = DF.GetSpecialization()
		return spec and DF.GetSpecializationRole (spec) or "NONE"
	end
	return assignedRole
end

function DF:GetCLEncounterIDs()
	return DF.CLEncounterID
end

DF.ClassSpecs = {
	["DEMONHUNTER"] = {
		[577] = true,
		[581] = true,
	},
	["DEATHKNIGHT"] = {
		[250] = true,
		[251] = true,
		[252] = true,
	},
	["WARRIOR"] = {
		[71] = true,
		[72] = true,
		[73] = true,
	},
	["MAGE"] = {
		[62] = true,
		[63] = true,
		[64] = true,
	},
	["ROGUE"] = {
		[259] = true,
		[260] = true,
		[261] = true,
	},
	["DRUID"] = {
		[102] = true,
		[103] = true,
		[104] = true,
		[105] = true,
	},
	["HUNTER"] = {
		[253] = true,
		[254] = true,
		[255] = true,
	},
	["SHAMAN"] = {
		[262] = true,
		[263] = true,
		[264] = true,
	},
	["PRIEST"] = {
		[256] = true,
		[257] = true,
		[258] = true,
	},
	["WARLOCK"] = {
		[265] = true,
		[266] = true,
		[267] = true,
	},
	["PALADIN"] = {
		[65] = true,
		[66] = true,
		[70] = true,
	},
	["MONK"] = {
		[268] = true,
		[269] = true,
		[270] = true,
	},
	["EVOKER"] = {
		[1467] = true,
		[1468] = true,
		[1473] = true,
	},
}

DF.SpecListByClass = {
	["DEMONHUNTER"] = {
		577,
		581,
	},
	["DEATHKNIGHT"] = {
		250,
		251,
		252,
	},
	["WARRIOR"] = {
		71,
		72,
		73,
	},
	["MAGE"] = {
		62,
		63,
		64,
	},
	["ROGUE"] = {
		259,
		260,
		261,
	},
	["DRUID"] = {
		102,
		103,
		104,
		105,
	},
	["HUNTER"] = {
		253,
		254,
		255,
	},
	["SHAMAN"] = {
		262,
		263,
		264,
	},
	["PRIEST"] = {
		256,
		257,
		258,
	},
	["WARLOCK"] = {
		265,
		266,
		267,
	},
	["PALADIN"] = {
		65,
		66,
		70,
	},
	["MONK"] = {
		268,
		269,
		270,
	},
	["EVOKER"] = {
		1467,
		1468,
		1473,
	},
}

---return if the specId is a valid spec, it'll return false for specIds from the tutorial area
---@param self table
---@param specId number
function DF:IsValidSpecId(specId)
	local _, class = UnitClass("player")
	local specs = DF.ClassSpecs[class]
	return specs and specs[specId] and true or false
end

--given a class and a  specId, return if the specId is a spec from the class passed
function DF:IsSpecFromClass(class, specId)
	return DF.ClassSpecs[class] and DF.ClassSpecs[class][specId]
end

--return a has table where specid is the key and 'true' is the value
function DF:GetClassSpecs(class)
	return DF.ClassSpecs [class]
end

--return a numeric table with spec ids
function DF:GetSpecListFromClass(class)
	return DF.SpecListByClass [class]
end

--return a list with specIds as keys and spellId as value
function DF:GetSpellsForRangeCheck()
	return SpellRangeCheckListBySpec
end

--return a list with specIds as keys and spellId as value
function DF:GetRangeCheckSpellForSpec(specId)
	return SpellRangeCheckListBySpec[specId]
end


--key is instanceId from GetInstanceInfo()
-- /dump GetInstanceInfo()
DF.BattlegroundSizes = {
	[2245] = 15, --Deepwind Gorge
	[2106] = 10, --Warsong Gulch
	[2107] = 15, --Arathi Basin
	[566] = 15, --Eye of the Storm
	[30]  = 40,	--Alterac Valley
	[628] = 40, --Isle of Conquest
	[761] = 10, --The Battle for Gilneas
	[726] = 10, --Twin Peaks
	[727] = 10, --Silvershard Mines
	[998] = 10, --Temple of Kotmogu
	[2118] = 40, --Battle for Wintergrasp
	[1191] = 25, --Ashran
	[1803] = 10, --Seething Shore
}

function DF:GetBattlegroundSize(instanceInfoMapId)
	return DF.BattlegroundSizes[instanceInfoMapId]
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--execute range

	function DF.GetExecuteRange(unitId)
		unitId = unitId or "player"

		local classLoc, class = UnitClass(unitId)
		local spec = GetSpecialization()

		if (spec and class) then
			--prist
			if (class == "PRIEST") then
				--playing as shadow?
				local specID = GetSpecializationInfo(spec)
				if (specID and specID ~= 0) then
					if (specID == 258) then --shadow
						local _, _, _, using_SWDeath = GetTalentInfo(5, 2, 1)
						if (using_SWDeath) then
							return 0.20
						end
					end
				end

			elseif (class == "MAGE") then
				--playing fire mage?
				local specID = GetSpecializationInfo(spec)
				if (specID and specID ~= 0) then
					if (specID == 63) then --fire
						local _, _, _, using_SearingTouch = GetTalentInfo(1, 3, 1)
						if (using_SearingTouch) then
							return 0.30
						end
					end
				end

			elseif (class == "WARRIOR") then
				--is playing as a Arms warrior?
				local specID = GetSpecializationInfo(spec)
				if (specID and specID ~= 0) then

					if (specID == 71) then --arms
						local _, _, _, using_Massacre = GetTalentInfo(3, 1, 1)
						if (using_Massacre) then
							--if using massacre, execute can be used at 35% health in Arms spec
							return 0.35
						end
					end

					if (specID == 71 or specID == 72) then --arms or fury
						return 0.20
					end
				end

			elseif (class == "HUNTER") then
				local specID = GetSpecializationInfo(spec)
				if (specID and specID ~= 0) then
					if (specID == 253) then --beast mastery
						--is using killer instinct?
						local _, _, _, using_KillerInstinct = GetTalentInfo(1, 1, 1)
						if (using_KillerInstinct) then
							return 0.35
						end
					end
				end

			elseif (class == "PALADIN") then
				local specID = GetSpecializationInfo(spec)
				if (specID and specID ~= 0) then
					if (specID == 70) then --retribution paladin
						--is using hammer of wrath?
						local _, _, _, using_HammerOfWrath = GetTalentInfo(2, 3, 1)
						if (using_HammerOfWrath) then
							return 0.20
						end
					end
				end
			end
		end
	end


------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--delta seconds reader

if (not DetailsFrameworkDeltaTimeFrame) then
	CreateFrame("frame", "DetailsFrameworkDeltaTimeFrame", UIParent)
end

local deltaTimeFrame = DetailsFrameworkDeltaTimeFrame
deltaTimeFrame:SetScript("OnUpdate", function(self, deltaTime)
	self.deltaTime = deltaTime
end)

function GetWorldDeltaSeconds()
	return deltaTimeFrame.deltaTime
end

function DF:GetWorldDeltaSeconds()
	return deltaTimeFrame.deltaTime
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--build the global script channel for scripts communication
--send and retrieve data sent by othe users in scripts
--Usage:
--DetailsFramework:RegisterScriptComm (ID, function(sourcePlayerName, ...) end)
--DetailsFramework:SendScriptComm (ID, ...)

	local aceComm = LibStub:GetLibrary ("AceComm-3.0", true)
	local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0", true)
	local LibDeflate = LibStub:GetLibrary ("LibDeflate", true)

	DF.RegisteredScriptsComm = DF.RegisteredScriptsComm or {}

	function DF.OnReceiveScriptComm (...)
		local prefix, encodedString, channel, commSource = ...

		local decodedString = LibDeflate:DecodeForWoWAddonChannel (encodedString)
		if (decodedString) then
			local uncompressedString = LibDeflate:DecompressDeflate (decodedString)
			if (uncompressedString) then
				local data = {LibAceSerializer:Deserialize (uncompressedString)}
				if (data[1]) then
					local ID = data[2]
					if (ID) then
						local sourceName = data[4]
						if (Ambiguate (sourceName, "none") == commSource) then
							local func = DF.RegisteredScriptsComm [ID]
							if (func) then
								DF:MakeFunctionSecure(func)
								DF:Dispatch (func, commSource, select(5, unpack(data))) --this use xpcall
							end
						end
					end
				end
			end
		end
	end

	function DF:RegisterScriptComm (ID, func)
		if (ID) then
			if (type(func) == "function") then
				DF.RegisteredScriptsComm [ID] = func
			else
				DF.RegisteredScriptsComm [ID] = nil
			end
		end
	end

	function DF:SendScriptComm (ID, ...)
		if (DF.RegisteredScriptsComm [ID]) then
			local sourceName = UnitName ("player") .. "-" .. GetRealmName()
			local data = LibAceSerializer:Serialize (ID, UnitGUID("player"), sourceName, ...)
			data = LibDeflate:CompressDeflate (data, {level = 9})
			data = LibDeflate:EncodeForWoWAddonChannel (data)
			aceComm:SendCommMessage ("_GSC", data, "PARTY")
		end
	end

	if (aceComm and LibAceSerializer and LibDeflate) then
		aceComm:RegisterComm ("_GSC", DF.OnReceiveScriptComm)
	end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--debug

DF.DebugMixin = {

	debug = true,

	CheckPoint = function(self, checkPointName, ...)
		print(self:GetName(), checkPointName, ...)
	end,

	CheckVisibilityState = function(self, widget)

		self = widget or self

		local width, height = self:GetSize()
		width = floor(width)
		height = floor(height)

		local numPoints = self:GetNumPoints()

		print("shown:", self:IsShown(), "visible:", self:IsVisible(), "alpha:", self:GetAlpha(), "size:", width, height, "points:", numPoints)
	end,

	CheckStack = function(self)
		local stack = debugstack()
		Details:Dump (stack)
	end,

}

-----------------------------------------------------------------------------------------------------------------------------------------------------------

--returns if the unit is tapped (gray health color when another player hit the unit first)
function DF:IsUnitTapDenied (unitId)
	return unitId and not UnitPlayerControlled(unitId) and UnitIsTapDenied(unitId)
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------
--pool

do
    local get = function(self)
        local object = tremove(self.notUse, #self.notUse)
        if (object) then
            tinsert(self.inUse, object)
			if (self.onAcquire) then
				DF:QuickDispatch(self.onAcquire, object)
			end
			return object, false
        else
            --need to create the new object
            local newObject = self.newObjectFunc(self, unpack(self.payload))
            if (newObject) then
				tinsert(self.inUse, newObject)
				if (self.onAcquire) then
					DF:QuickDispatch(self.onAcquire, newObject)
				end
				return newObject, true
            end
        end
	end

	local get_all_inuse = function(self)
		return self.inUse;
	end

    local release = function(self, object)
        for i = #self.inUse, 1, -1 do
            if (self.inUse[i] == object) then
                tremove(self.inUse, i)
                tinsert(self.notUse, object)

				if (self.onRelease) then
					DF:QuickDispatch(self.onRelease, object)
				end
                break
            end
        end
    end

    local reset = function(self)
        for i = #self.inUse, 1, -1 do
            local object = tremove(self.inUse, i)
            tinsert(self.notUse, object)

			if (self.onReset) then
				DF:QuickDispatch(self.onReset, object)
			end
        end
	end

	--only hide objects in use, do not disable them
		local hide = function(self)
			for i = #self.inUse, 1, -1 do
				self.inUse[i]:Hide()
			end
		end

	--only show objects in use, do not enable them
		local show = function(self)
			for i = #self.inUse, 1, -1 do
				self.inUse[i]:Show()
			end
		end

	--return the amount of objects
		local getamount = function(self)
			return #self.notUse + #self.inUse, #self.notUse, #self.inUse
		end

    local poolMixin = {
		Get = get,
		GetAllInUse = get_all_inuse,
        Acquire = get,
        Release = release,
        Reset = reset,
        ReleaseAll = reset,
		Hide = hide,
		Show = show,
		GetAmount = getamount,

		SetCallbackOnRelease = function(self, func)
			self.onRelease = func
		end,

		SetOnReset = function(self, func)
			self.onReset = func
		end,
		SetCallbackOnReleaseAll = function(self, func)
			self.onReset = func
		end,

		SetOnAcquire = function(self, func)
			self.onAcquire = func
		end,
		SetCallbackOnGet = function(self, func)
			self.onAcquire = func
		end,
    }

    function DF:CreatePool(func, ...)
        local t = {}
        DetailsFramework:Mixin(t, poolMixin)

        t.inUse = {}
        t.notUse = {}
        t.newObjectFunc = func
        t.payload = {...}

        return t
	end

	--alias
	function DF:CreateObjectPool(func, ...)
		return DF:CreatePool(func, ...)
	end
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------
--forbidden functions on scripts

	--these are functions which scripts cannot run due to security issues
	local forbiddenFunction = {
		--block mail, trades, action house, banks
		["C_AuctionHouse"] 	= true,
		["C_Bank"] = true,
		["C_GuildBank"] = true,
		["SetSendMailMoney"] = true,
		["SendMail"]		= true,
		["SetTradeMoney"]	= true,
		["AddTradeMoney"]	= true,
		["PickupTradeMoney"]	= true,
		["PickupPlayerMoney"]	= true,
		["AcceptTrade"]		= true,

		--frames
		["BankFrame"] 		= true,
		["TradeFrame"]		= true,
		["GuildBankFrame"] 	= true,
		["MailFrame"]		= true,
		["EnumerateFrames"] = true,

		--block run code inside code
		["RunScript"] = true,
		["securecall"] = true,
		["setfenv"] = true,
		["getfenv"] = true,
		["loadstring"] = true,
		["pcall"] = true,
		["xpcall"] = true,
		["getglobal"] = true,
		["setmetatable"] = true,
		["DevTools_DumpCommand"] = true,
		["ChatEdit_SendText"] = true,

		--avoid creating macros
		["SetBindingMacro"] = true,
		["CreateMacro"] = true,
		["EditMacro"] = true,
		["hash_SlashCmdList"] = true,
		["SlashCmdList"] = true,

		--block guild commands
		["GuildDisband"] = true,
		["GuildUninvite"] = true,

		--other things
		["C_GMTicketInfo"] = true,

		--deny messing addons with script support
		["PlaterDB"] = true,
		["_detalhes_global"] = true,
		["WeakAurasSaved"] = true,
	}

	local C_RestrictedSubFunctions = {
		["C_GuildInfo"] = {
			["RemoveFromGuild"] = true,
		},
	}

	--not in use, can't find a way to check within the environment handle
	local addonRestrictedFunctions = {
		["DetailsFramework"] = {
			["SetEnvironment"] = true,
		},

		["Plater"] = {
			["ImportScriptString"] = true,
			["db"] = true,
		},

		["WeakAuras"] = {
			["Add"] = true,
			["AddMany"] = true,
			["Delete"] = true,
			["NewAura"] = true,
		},
	}

    local C_SubFunctionsTable = {}
    for globalTableName, functionTable in pairs(C_RestrictedSubFunctions) do
        C_SubFunctionsTable [globalTableName] = {}
        for functionName, functionObject in pairs(_G[globalTableName]) do
            if (not functionTable[functionName]) then
                C_SubFunctionsTable [globalTableName][functionName] = functionObject
            end
        end
    end

	DF.DefaultSecureScriptEnvironmentHandle = {
		__index = function(env, key)

			if (forbiddenFunction[key]) then
				return nil

			elseif (key == "_G") then
				return env

			elseif (C_SubFunctionsTable[key]) then
				return C_SubFunctionsTable[key]
			end

			return _G[key]
		end
	}

	function DF:SetEnvironment(func, environmentHandle, newEnvironment)
		environmentHandle = environmentHandle or DF.DefaultSecureScriptEnvironmentHandle
		newEnvironment = newEnvironment or {}

		setmetatable(newEnvironment, environmentHandle)
		_G.setfenv(func, newEnvironment)
	end

	function DF:MakeFunctionSecure(func)
		return DF:SetEnvironment(func)
	end


-----------------------------------------------------------------------------------------------------------------------------------------------------------

---receives an object and print debug info about its visibility
---use to know why a frame is not showing
---@param UIObject any
function DF:DebugVisibility(UIObject)
	local bIsShown = UIObject:IsShown()
	print("Is Shown:", bIsShown and "|cFF00FF00true|r" or "|cFFFF0000false|r")

	print("Alpha > 0:", UIObject:GetAlpha() > 0 and "|cFF00FF00true|r" or "|cFFFF0000false|r")

	local bIsVisible = UIObject:IsVisible()
	print("Is Visible:", bIsVisible and "|cFF00FF00true|r" or "|cFFFF0000false|r")

	local width, height = UIObject:GetSize()
	print("Width:", width > 0 and "|cFF00FF00" .. width .. "|r" or "|cFFFF00000|r")
	print("Height:", height > 0 and "|cFF00FF00" .. height .. "|r" or "|cFFFF00000|r")

	local numPoints = UIObject:GetNumPoints()
	print("Num Points:", numPoints > 0 and "|cFF00FF00" .. numPoints .. "|r" or "|cFFFF00000|r")
end

local benchmarkTime = 0
local bBenchmarkEnabled = false
function _G.__benchmark(bNotPrintResult)
	if (not bBenchmarkEnabled) then
		bBenchmarkEnabled = true
		debugprofilestop()
		benchmarkTime = debugprofilestop()
	else
		local elapsed = debugprofilestop() - benchmarkTime
		bBenchmarkEnabled = false

		if (bNotPrintResult) then
			return elapsed
		end

		print("Elapsed Time:", elapsed)
		return elapsed
	end
end

