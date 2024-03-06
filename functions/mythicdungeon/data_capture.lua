
local Details = _G.Details
local addonName, Details222 = ...
local detailsFramework = DetailsFramework
local _

local debugmode = false --print debug lines
local verbosemode = false --auto open the chart panel
local UnitClass = UnitClass
local IsInInstance = IsInInstance
local GetNumGroupMembers = GetNumGroupMembers
local GetInstanceInfo = GetInstanceInfo
local time = time
local floor = math.floor
local C_Timer = C_Timer
local C_ChallengeMode = C_ChallengeMode

--constants
local CONST_USE_PLAYER_EDPS = false


--Generate damage chart for mythic dungeon runs

--[=[
The chart table needs to be stored saparated from the combat
Should the chart data be volatile?

--]=]

local mythicDungeonFrames = Details222.MythicPlus.Frames
local mythicDungeonCharts = Details222.MythicPlus.Charts.Listener

--debug
_G.DetailsMythicDungeonChartHandler = mythicDungeonCharts
--DetailsMythicDungeonChartHandler.ChartTable.Players["playername"].ChartData = {max_value = 0}

function mythicDungeonCharts:Debug(...)
	if (debugmode or verbosemode) then
		print("Details! DungeonCharts: ", ...)
	end
end

local addPlayerDamage = function(unitCleuName)
	--get the player data
	local playerData = mythicDungeonCharts.ChartTable.Players[unitCleuName]

	--if this is the first tick for the player, ignore the damage done on this tick
	--this is done to prevent a tick tick with all the damage the player did on the previous segment
	local bIsFirstTick = false

	--check if the player data doesn't exists
	if (not playerData) then
		playerData = {
			Name = detailsFramework:RemoveRealmName(unitCleuName),
			ChartData = {max_value = 0},
			Class = select(2, UnitClass(Details:Ambiguate(unitCleuName))),

			--spec zero for now, need to retrive later during combat
			Spec = 0,

			--last damage to calc difference
			LastDamage = 0,

			--if started a new combat, need to reset the lastdamage
			LastCombatID = -1,
		}

		mythicDungeonCharts.ChartTable.Players[unitCleuName] = playerData
		bIsFirstTick = true
	end

	--get the current combat
	local currentCombat = Details:GetCombat(DETAILS_SEGMENTID_CURRENT)
	if (currentCombat) then
		local isOverallSegment = false

		local mythicDungeonInfo = currentCombat.is_mythic_dungeon
		if (mythicDungeonInfo) then
			if (mythicDungeonInfo.TrashOverallSegment or mythicDungeonInfo.OverallSegment) then
				isOverallSegment = true
			end
		end

		if (not isOverallSegment) then
			--check if the combat has changed
			local segmentId = currentCombat.combat_id
			if (segmentId ~= playerData.LastCombatID) then
				playerData.LastDamage = 0
				playerData.LastCombatID = segmentId
				--mythicDungeonCharts:Debug("Combat changed for player", unitCleuName)
			end

			local actorTable = currentCombat:GetActor(DETAILS_ATTRIBUTE_DAMAGE, unitCleuName)
			if (actorTable) then
				--update the player spec
				playerData.Spec = actorTable.spec

				if (bIsFirstTick) then
					--ignore previous damage
					playerData.LastDamage = actorTable.total
				end

				--get the damage done
				local damageDone = actorTable.total

				--check which data is used, dps or damage done
				if (CONST_USE_PLAYER_EDPS) then
					local eDps = damageDone / currentCombat:GetCombatTime()

					--add the damage to the chart table
					table.insert(playerData.ChartData, eDps)
					--mythicDungeonCharts:Debug("Added dps for " , unitCleuName, ":", eDps)

					if (eDps > playerData.ChartData.max_value) then
						playerData.ChartData.max_value = eDps
					end
				else
					--calc the difference and add to the table
					local damageDiff = floor(damageDone - playerData.LastDamage)
					playerData.LastDamage = damageDone

					--add the damage to the chart table
					table.insert(playerData.ChartData, damageDiff)
					--mythicDungeonCharts:Debug("Added damage for " , unitCleuName, ":", damageDiff)

					if (damageDiff > playerData.ChartData.max_value) then
						playerData.ChartData.max_value = damageDiff
					end
				end
			else
				--player still didn't made anything on this combat, so just add zero
				table.insert(playerData.ChartData, 0)
			end
		end
	end
end

local tickerCallback = function(tickerObject)
	--check if is inside the dungeon
	local inInstance = IsInInstance()
	if (not inInstance) then
		mythicDungeonCharts:OnEndMythicDungeon()
		return
	end

	--check if still running the dungeon
	if (not mythicDungeonCharts.ChartTable or not mythicDungeonCharts.ChartTable.Running) then
		tickerObject:Cancel()
		return
	end

	--tick damage
	local totalPlayers = GetNumGroupMembers()
	for i = 1, totalPlayers-1 do
		---@type cleuname
		local cleuName = Details:GetFullName("party" .. i)
		if (cleuName) then
			addPlayerDamage(cleuName)
		end
	end

	addPlayerDamage(Details:GetFullName("player"))
end

function mythicDungeonCharts:OnBossDefeated()
	local currentCombat = Details:GetCurrentCombat()
	local segmentType = currentCombat:GetCombatType()
	local bossInfo = currentCombat:GetBossInfo()
	local mythicLevel = C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo()

	if (mythicLevel and mythicLevel > 0) then
		if (mythicDungeonCharts.ChartTable and mythicDungeonCharts.ChartTable.Running and bossInfo) then

			local copiedBossInfo = Details:GetFramework().table.copy({}, bossInfo)
			table.insert(mythicDungeonCharts.ChartTable.BossDefeated, {time() - mythicDungeonCharts.ChartTable.StartTime, copiedBossInfo, currentCombat:GetCombatTime()})
			mythicDungeonCharts:Debug("Boss defeated, time saved", currentCombat:GetCombatTime())
		else
			if (mythicDungeonCharts.ChartTable and mythicDungeonCharts.ChartTable.EndTime ~= -1) then
				local now = time()
				--check if the dungeon just ended
				if (mythicDungeonCharts.ChartTable.EndTime + 2 >= now) then

					if (bossInfo) then
						local copiedBossInfo = Details:GetFramework().table.copy({}, bossInfo)
						table.insert(mythicDungeonCharts.ChartTable.BossDefeated, {time() - mythicDungeonCharts.ChartTable.StartTime, copiedBossInfo, currentCombat:GetCombatTime()})
						mythicDungeonCharts:Debug("Boss defeated, time saved, but used time aproximation:", mythicDungeonCharts.ChartTable.EndTime + 2, now, currentCombat:GetCombatTime())
					end
				end
			else
				mythicDungeonCharts:Debug("Boss defeated, but no chart capture is running")
			end
		end
	else
		mythicDungeonCharts:Debug("Boss defeated, but isn't a mythic dungeon boss fight")
	end
end

function mythicDungeonCharts:OnStartMythicDungeon()
	if (not Details.mythic_plus.show_damage_graphic) then
		mythicDungeonCharts:Debug("Dungeon started, no capturing mythic dungeon chart data, disabled on profile")
		if (verbosemode) then
			mythicDungeonCharts:Debug("OnStartMythicDungeon() not allowed")
		end
		return
	else
		mythicDungeonCharts:Debug("Dungeon started, new capture started")
	end

	mythicDungeonCharts.ChartTable = {
		Running = true,
		Players = {},
		ElapsedTime = 0,
		StartTime = time(),
		EndTime = -1,
		DungeonName = "",

		--store when each boss got defeated in comparison with the StartTime
		BossDefeated = {},
	}

	mythicDungeonCharts.ChartTable.Ticker = C_Timer.NewTicker(1, tickerCallback)

	--save the chart for development
	if (debugmode) then
		Details.mythic_plus.last_mythicrun_chart = mythicDungeonCharts.ChartTable
	end

	if (verbosemode) then
		mythicDungeonCharts:Debug("OnStartMythicDungeon() success")
	end
end

function mythicDungeonCharts:OnEndMythicDungeon()
	if (mythicDungeonCharts.ChartTable and mythicDungeonCharts.ChartTable.Running) then

		--stop capturinfg
		mythicDungeonCharts.ChartTable.Running = false
		mythicDungeonCharts.ChartTable.ElapsedTime = time() - mythicDungeonCharts.ChartTable.StartTime
		mythicDungeonCharts.ChartTable.EndTime = time()
		mythicDungeonCharts.ChartTable.Ticker:Cancel()

		local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
		mythicDungeonCharts.ChartTable.DungeonName = name

		--check if is inside the dungeon
		--many players just leave the dungeon in order the re-enter and start the run again, the chart window is showing in these cases data to an imcomplete run.
		local isInsideDungeon = IsInInstance()
		if (not isInsideDungeon) then
			mythicDungeonCharts:Debug("OnEndMythicDungeon() player wasn't inside the dungeon.")
			return
		end

		if (verbosemode) then
			mythicDungeonCharts:Debug("OnEndMythicDungeon() success!")
		end
	else
		mythicDungeonCharts:Debug("Dungeon ended, no chart data was running")
		if (verbosemode) then
			mythicDungeonCharts:Debug("OnEndMythicDungeon() fail")
		end
	end
end

mythicDungeonCharts:RegisterEvent("COMBAT_MYTHICDUNGEON_START", "OnStartMythicDungeon")
mythicDungeonCharts:RegisterEvent("COMBAT_MYTHICDUNGEON_END", "OnEndMythicDungeon")
mythicDungeonCharts:RegisterEvent("COMBAT_BOSS_DEFEATED", "OnBossDefeated")


--SetPortraitTexture(texture, unitId)
-- /run _G.DetailsMythicDungeonChartHandler.ShowChart(); DetailsMythicDungeonChartFrame.ShowChartFrame()
-- /run mythicDungeonFrames.ShowEndOfMythicPlusPanel()









