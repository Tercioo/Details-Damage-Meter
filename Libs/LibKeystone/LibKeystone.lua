--@curseforge-project-slug: libkeystone@
if WOW_PROJECT_ID ~= 1 then return end -- Retail

local LKS = LibStub:NewLibrary("LibKeystone", 11)
if not LKS then return end -- No upgrade needed

LKS.callbackMap = LKS.callbackMap or {}
LKS.frame = LKS.frame or CreateFrame("Frame")
LKS.isGuildHidden = LKS.isGuildHidden or false

local callbackMap = LKS.callbackMap
local type, error = type, error

do
	local result = C_ChatInfo.RegisterAddonMessagePrefix("LibKS")
	-- 0=success, 1=duplicate, 2=invalid, 3=toomany
	if type(result) == "number" and result > 1 then
		error("LibKeystone: Failed to register the addon prefix.")
	end
end

function LKS.Register(addon, func)
	if type(addon) ~= "table" or addon == LKS then
		error("LibKeystone: The function lib.Register expects your own addon object as the first arg.")
	end

	local t = type(func)
	if t == "function" then
		callbackMap[addon] = func
	else
		error("LibKeystone: The function lib.Register expects your own function as the second arg.")
	end
end

function LKS.Unregister(addon)
	if type(addon) ~= "table" or addon == LKS then
		error("LibKeystone: The function lib.Unregister expects your own addon object.")
	end
	callbackMap[addon] = nil
end

function LKS.SetGuildHidden(isHidden)
	if type(isHidden) ~= "boolean" then
		error("LibKeystone: The function lib.SetGuildHidden expects a boolean value.")
	end
	LKS.isGuildHidden = isHidden
end

local GetInfo
do
	-- Normal APIs
	local GetOwnedKeystoneLevel, GetOwnedKeystoneChallengeMapID = C_MythicPlus.GetOwnedKeystoneLevel, C_MythicPlus.GetOwnedKeystoneChallengeMapID
	local GetPlayerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary

	-- Timerunning APIs
	local GetContainerNumSlots, GetContainerItemID, GetContainerItemLink = C_Container.GetContainerNumSlots, C_Container.GetContainerItemID, C_Container.GetContainerItemLink
	local IsItemKeystoneByID, PlayerIsTimerunning = C_Item.IsItemKeystoneByID, PlayerIsTimerunning
	local strsplit = string.split
	function GetInfo()
		-- Keystone level
		local keyLevel = GetOwnedKeystoneLevel()
		if type(keyLevel) ~= "number" then
			keyLevel = 0
		end
		-- Keystone challenge ID [https://wago.tools/db2/MapChallengeMode]
		-- You can pass this ID into `C_ChallengeMode.GetMapUIInfo()` to get info like the name
		local keyChallengeMapID = GetOwnedKeystoneChallengeMapID()
		if type(keyChallengeMapID) ~= "number" then
			keyChallengeMapID = 0
		end

		if keyLevel == 0 and keyChallengeMapID == 0 and PlayerIsTimerunning and PlayerIsTimerunning() then
			for currentBag = 0, 4 do -- 0=Backpack, 1/2/3/4=Bags
				local slots = GetContainerNumSlots(currentBag)
				for currentSlot = 1, slots do
					local itemID = GetContainerItemID(currentBag, currentSlot)
					if itemID and IsItemKeystoneByID(itemID) then
						local itemLink = GetContainerItemLink(currentBag, currentSlot)
						if type(itemLink) == "string" then
							local _, _, _, strChallengeMapID, strLevel = strsplit(":", itemLink)
							local challengeMapID = tonumber(strChallengeMapID)
							local level = tonumber(strLevel)
							if challengeMapID and level then
								keyChallengeMapID = challengeMapID
								keyLevel = level
								break
							end
						end
					end
				end
			end
		end

		-- M+ rating
		local playerRatingSummary = GetPlayerMythicPlusRatingSummary("player")
		local playerRating = 0
		if type(playerRatingSummary) == "table" and type(playerRatingSummary.currentSeasonScore) == "number" then
			playerRating = playerRatingSummary.currentSeasonScore
		end
		return keyLevel, keyChallengeMapID, playerRating
	end
end

local SendAddonMessage, CTimerNewTimer = C_ChatInfo.SendAddonMessage, C_Timer.NewTimer
local GetTime = GetTime
local next, securecallfunction = next, securecallfunction
local throttleTime = 3 -- Seconds
do
	local throttleTable = {
		GUILD = 0,
		PARTY = 0,
	}
	local timerTable = {}
	local functionTable
	local tonumber, match, format = tonumber, string.match, string.format
	local Ambiguate = Ambiguate

	do
		local IsInGroup, IsInGuild = IsInGroup, IsInGuild
		local function SendToParty()
			if timerTable.PARTY then
				timerTable.PARTY:Cancel()
				timerTable.PARTY = nil
			end
			if IsInGroup() then
				local keyLevel, keyChallengeMapID, playerRating = GetInfo()
				local result = SendAddonMessage("LibKS", format("%d,%d,%d", keyLevel, keyChallengeMapID, playerRating), "PARTY")
				if result == 3 or result == 8 or result == 9 then -- AddonMessageThrottle, ChannelThrottle, GeneralError
					timerTable.PARTY = CTimerNewTimer(throttleTime, SendToParty)
				end
			end
		end
		local function SendToGuild()
			if timerTable.GUILD then
				timerTable.GUILD:Cancel()
				timerTable.GUILD = nil
			end
			if IsInGuild() then
				local keyLevel, keyChallengeMapID, playerRating = GetInfo()
				if keyLevel ~= 0 and LKS.isGuildHidden then
					keyLevel, keyChallengeMapID = -1, -1
				end
				local result = SendAddonMessage("LibKS", format("%d,%d,%d", keyLevel, keyChallengeMapID, playerRating), "GUILD")
				if result == 3 or result == 8 or result == 9 then -- AddonMessageThrottle, ChannelThrottle, GeneralError
					timerTable.GUILD = CTimerNewTimer(throttleTime, SendToGuild)
				end
			end
		end
		functionTable = {
			PARTY = SendToParty,
			GUILD = SendToGuild,
		}
	end

	local currentLevel, currentMap = nil, nil
	local function DidKeystoneChange()
		local keyLevel, keyChallengeMapID = GetInfo()
		if keyLevel ~= currentLevel or keyChallengeMapID ~= currentMap then
			currentLevel, currentMap = keyLevel, keyChallengeMapID
			local t = GetTime()
			if t - throttleTable.PARTY > throttleTime then
				throttleTable.PARTY = t
				functionTable.PARTY()
			elseif not timerTable.PARTY then
				timerTable.PARTY = CTimerNewTimer((throttleTime+0.1)-(t-throttleTable.PARTY), functionTable.PARTY)
			end
		end
	end
	LKS.frame:SetScript("OnEvent", function(self, event, prefix, msg, channel, sender)
		if event == "CHAT_MSG_ADDON" then
			if prefix == "LibKS" and throttleTable[channel] then
				if msg == "R" then
					local t = GetTime()
					if t - throttleTable[channel] > throttleTime then
						throttleTable[channel] = t
						functionTable[channel]()
					elseif not timerTable[channel] then
						timerTable[channel] = CTimerNewTimer((throttleTime+0.1)-(t-throttleTable[channel]), functionTable[channel])
					end
					return
				end

				local keyLevelStr, keyChallengeMapIDStr, playerRatingStr = match(msg, "^(%d+),(%d+),(%d+)$")
				if keyLevelStr and keyChallengeMapIDStr and playerRatingStr then
					local keyLevel = tonumber(keyLevelStr)
					local keyChallengeMapID = tonumber(keyChallengeMapIDStr)
					local playerRating = tonumber(playerRatingStr)
					if keyLevel and keyChallengeMapID and playerRating then
						local shortName = Ambiguate(sender, "none")
						for _,func in next, callbackMap do
							securecallfunction(func, keyLevel, keyChallengeMapID, playerRating, shortName, channel)
						end
					end
				end
			end
		elseif event == "CHALLENGE_MODE_COMPLETED" then -- We start listening to events at the end of a Mythic+ to check if a player gets a new keystone
			currentLevel, currentMap = GetInfo()
			self:RegisterEvent("ITEM_CHANGED")
			self:RegisterEvent("ITEM_PUSH")
			self:RegisterEvent("PLAYER_LEAVING_WORLD")
		elseif event == "PLAYER_LEAVING_WORLD" then -- Stop listening to events when we leave the dungeon
			self:UnregisterEvent("ITEM_CHANGED")
			self:UnregisterEvent("ITEM_PUSH")
			self:UnregisterEvent(event)
		elseif event == "ITEM_CHANGED" or (event == "ITEM_PUSH" and msg == 4352494) then -- We automatically broadcast newly received keystones, but only at the end of a Mythic+
			-- Check if the player got a new keystone from the NPC (ITEM_CHANGED) or the chest (ITEM_PUSH)
			CTimerNewTimer(1, DidKeystoneChange) -- There can sometimes be delay with the API updating, especially on PTR, so wait 1 second before checking
		end
	end)
	LKS.frame:RegisterEvent("CHAT_MSG_ADDON")
	LKS.frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
end

do
	local throttleSendTable = {
		GUILD = 0,
		PARTY = 0,
	}
	local statusCheckTable = {
		GUILD = IsInGuild,
		PARTY = IsInGroup,
	}
	local timers = {}
	local pName = UnitNameUnmodified("player")
	function LKS.Request(channel)
		if not throttleSendTable[channel] then
			error("LibKeystone: The function lib.Request expects a channel type of PARTY or GUILD.")
		else
			local keyLevel, keyChallengeMapID, playerRating = GetInfo()
			if keyLevel ~= 0 and LKS.isGuildHidden and channel == "GUILD" then
				keyLevel, keyChallengeMapID = -1, -1
			end
			for _,func in next, callbackMap do
				securecallfunction(func, keyLevel, keyChallengeMapID, playerRating, pName, channel) -- This allows us to show our own stats when not grouped
			end
			if statusCheckTable[channel]() then
				local t = GetTime()
				if t - throttleSendTable[channel] > throttleTime then
					if timers[channel] then
						timers[channel]:Cancel()
						timers[channel] = nil
					end
					throttleSendTable[channel] = t
					SendAddonMessage("LibKS", "R", channel)
				elseif not timers[channel] then
					timers[channel] = CTimerNewTimer((throttleTime+0.1)-(t-throttleSendTable[channel]), function() LKS.Request(channel) end)
				end
			end
		end
	end
end
