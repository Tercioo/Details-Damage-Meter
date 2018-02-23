

--> dungeon file



--local pointer to details object
local Details = _G._detalhes
local debugmode = true

--constants
local CONST_USE_PLAYER_EDPS = false

--> Generate damage chart for mythic dungeon runs

--[=[
The chart table needs to be stored saparated from the combat
Should the chart data be volatile?

--]=]

local mythicDungeonCharts = Details:CreateEventListener()

function mythicDungeonCharts:Debug (...)
	if (debugmode) then
		print ("Details! DungeonCharts (debug.Alpha " .. Details.build_counter .. "." .. Details.realversion .. " ): ", ...)
	end
end

local addPlayerDamage = function (unitName, unitRealm)
	
	--get the combatlog name
	local CLName
	if (unitRealm and unitRealm ~= "") then
		CLName = unitName .. "-" .. unitRealm
	else
		CLName = unitName
	end
	
	--get the player data
	local playerData = mythicDungeonCharts.ChartTable.Players [CLName]
	
	--if this is the first tick for the player, ignore the damage done on this tick
	--this is done to prevent a tick tick with all the damage the player did on the previous segment
	local bIsFirstTick = false
	
	--check if the player data doesn't exists
	if (not playerData) then
		playerData = {
			Name = unitName,
			ChartData = {max_value = 0},
			Class = select (2, UnitClass (CLName)),
			
			--spec zero for now, need to retrive later during combat
			Spec = 0,
			
			--last damage to calc difference
			LastDamage = 0,
			
			--if started a new combat, need to reset the lastdamage
			LastCombatID = -1,
		}
		
		mythicDungeonCharts.ChartTable.Players [CLName] = playerData
		bIsFirstTick = true
	end
	
	--get the current combat
	local currentCombat = Details:GetCombat (DETAILS_SEGMENTID_CURRENT)
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
				
				--mythicDungeonCharts:Debug ("Combat changed for player", CLName)
			end

			local actorTable = currentCombat:GetActor (DETAILS_ATTRIBUTE_DAMAGE, CLName)
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
					tinsert (playerData.ChartData, eDps)
					--mythicDungeonCharts:Debug ("Added dps for " , CLName, ":", eDps)
					
					if (eDps > playerData.ChartData.max_value) then
						playerData.ChartData.max_value = eDps
					end
				else
					--calc the difference and add to the table
					local damageDiff = floor (damageDone - playerData.LastDamage)
					playerData.LastDamage = damageDone				
					
					--add the damage to the chart table
					tinsert (playerData.ChartData, damageDiff)
					--mythicDungeonCharts:Debug ("Added damage for " , CLName, ":", damageDiff)
					
					if (damageDiff > playerData.ChartData.max_value) then
						playerData.ChartData.max_value = damageDiff
					end
				end
			else
				--player still didn't made anything on this combat, so just add zero
				tinsert (playerData.ChartData, 0)
			end
		end
	end
end

local tickerCallback = function (tickerObject)
	
	--check if is inside the dungeon
	local inInstance = IsInInstance();
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
		local unitName, unitRealm = UnitName ("party" .. i)
		if (unitName) then
			addPlayerDamage (unitName, unitRealm)
		end
	end
	
	addPlayerDamage (UnitName ("player"))
end

function mythicDungeonCharts:OnBossDefeated()

	local currentCombat = Details:GetCurrentCombat()
	local segmentType = currentCombat:GetCombatType()
	local bossInfo = currentCombat:GetBossInfo()
	
	print (mythicDungeonCharts.ChartTable, mythicDungeonCharts.ChartTable.Running, segmentType, bossInfo)
	
	if (mythicDungeonCharts.ChartTable and mythicDungeonCharts.ChartTable.Running and bossInfo) then

		local copiedBossInfo = Details:GetFramework().table.copy ({}, bossInfo)
		tinsert (mythicDungeonCharts.ChartTable.BossDefeated, {time() - mythicDungeonCharts.ChartTable.StartTime, copiedBossInfo, currentCombat:GetCombatTime()})
		mythicDungeonCharts:Debug ("Boss defeated, time saved", currentCombat:GetCombatTime())
	else
		if (mythicDungeonCharts.ChartTable.EndTime ~= -1) then
			local now = time()
			--check if the dungeon just ended
			if (mythicDungeonCharts.ChartTable.EndTime + 2 >= now) then
			
				if (bossInfo) then
					local copiedBossInfo = Details:GetFramework().table.copy ({}, bossInfo)
					tinsert (mythicDungeonCharts.ChartTable.BossDefeated, {time() - mythicDungeonCharts.ChartTable.StartTime, copiedBossInfo, currentCombat:GetCombatTime()})
					mythicDungeonCharts:Debug ("Boss defeated, time saved, but used time aproximation:", mythicDungeonCharts.ChartTable.EndTime + 2, now, currentCombat:GetCombatTime())
				end
			end
		else
			mythicDungeonCharts:Debug ("Boss defeated, but no chart capture is running")
		end
	end
end

function mythicDungeonCharts:OnStartMythicDungeon()

	if (not Details.mythic_plus.show_damage_graphic) then
		mythicDungeonCharts:Debug ("Dungeon started, no capturing mythic dungeon chart data, disabled on profile")
		return
	else
		mythicDungeonCharts:Debug ("Dungeon started, new capture started")
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
	
	mythicDungeonCharts.ChartTable.Ticker = C_Timer.NewTicker (1, tickerCallback)
	
	_detalhes.mythic_plus.last_mythicrun_chart = mythicDungeonCharts.ChartTable
end

function mythicDungeonCharts:OnEndMythicDungeon()
	if (mythicDungeonCharts.ChartTable and mythicDungeonCharts.ChartTable.Running) then
		mythicDungeonCharts.ChartTable.Running = false
		mythicDungeonCharts.ChartTable.ElapsedTime = time() - mythicDungeonCharts.ChartTable.StartTime
		mythicDungeonCharts.ChartTable.EndTime = time()
		mythicDungeonCharts.ChartTable.Ticker:Cancel()
		
		local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
		mythicDungeonCharts.ChartTable.DungeonName = name
		
		mythicDungeonCharts:Debug ("Dungeon ended, chart data capture stopped")
		
		mythicDungeonCharts.ShowChart()
	else
		mythicDungeonCharts:Debug ("Dungeon ended, no chart data was running")
	end
end

mythicDungeonCharts:RegisterEvent ("COMBAT_MYTHICDUNGEON_START", "OnStartMythicDungeon")
mythicDungeonCharts:RegisterEvent ("COMBAT_MYTHICDUNGEON_END", "OnEndMythicDungeon")
mythicDungeonCharts:RegisterEvent ("COMBAT_BOSS_DEFEATED", "OnBossDefeated")

function mythicDungeonCharts.ShowChart()

	if (not mythicDungeonCharts.Frame) then

		mythicDungeonCharts.Frame = CreateFrame ("frame", "DetailsMythicDungeonChartFrame", UIParent)
		local f = mythicDungeonCharts.Frame

		f:SetSize (1210, 600)
		f:SetPoint ("center", UIParent, "center", 0, 0)
		f:SetFrameStrata ("LOW")
		f:EnableMouse (true)
		f:SetMovable (true)
		f:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
		f:SetBackdropColor (0, 0, 0, 0.9)
		f:SetBackdropBorderColor (0, 0, 0, 1)
		
		tinsert (UISpecialFrames, "DetailsMythicDungeonChartFrame")
		
		--register to libwindow
		local LibWindow = LibStub ("LibWindow-1.1")
		LibWindow.RegisterConfig (f, Details.mythic_plus.mythicrun_chart_frame)
		LibWindow.RestorePosition (f)
		LibWindow.MakeDraggable (f)
		LibWindow.SavePosition (f)
		
		f.ChartFrame = Details:GetFramework():CreateChartPanel (f, 1200, 600, "DetailsMythicDungeonChartGraphicFrame")
		f.ChartFrame:SetPoint ("topleft", f, "topleft", 5, 0)
		
		f.ChartFrame:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
		f.ChartFrame:SetBackdropColor (0, 0, 0, 0.0)
		f.ChartFrame:SetBackdropBorderColor (0, 0, 0, 0)
		
		f.ChartFrame.CloseButton:Hide()
		
		f.BossWidgetsFrame = CreateFrame ("frame", "$parentBossFrames", f)
		f.BossWidgetsFrame:SetFrameLevel (f:GetFrameLevel()+10)
		f.BossWidgetsFrame.Widgets = {}
		
		function f.ChartFrame.RefreshBossTimeline (self, bossTable, elapsedTime)
			
			for i, bossTable in ipairs (mythicDungeonCharts.ChartTable.BossDefeated) do
				
				local bossWidget = f.BossWidgetsFrame.Widgets [i]
				if (not bossWidget) then
					local newBossWidget = CreateFrame ("frame", "$parentBossWidget" .. i, f.BossWidgetsFrame)
					newBossWidget:SetSize (64, 32)
					newBossWidget:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
					newBossWidget:SetBackdropColor (0, 0, 0, 0.1)
					newBossWidget:SetBackdropBorderColor (0, 0, 0, 0)
					
					local bossAvatar = Details:GetFramework():CreateImage (newBossWidget, "", 64, 32, "border")
					bossAvatar:SetPoint ("bottomleft", newBossWidget, "bottomleft", 0, 0)
					newBossWidget.AvatarTexture = bossAvatar
					
					local verticalLine = Details:GetFramework():CreateImage (newBossWidget, "", 1, f.ChartFrame.Graphic:GetHeight(), "overlay")
					verticalLine:SetColorTexture (1, 1, 1, 0.3)
					verticalLine:SetPoint ("bottomleft", newBossWidget, "bottomright", 0, 0)
					
					local timeText = Details:GetFramework():CreateLabel (newBossWidget)
					timeText:SetPoint ("bottomright", newBossWidget, "bottomright", 0, 0)
					newBossWidget.TimeText = timeText
					
					local timeBackground = Details:GetFramework():CreateImage (newBossWidget, "", 30, 12, "artwork")
					timeBackground:SetColorTexture (0, 0, 0, 0.5)
					timeBackground:SetPoint ("topleft", timeText, "topleft", -2, 2)
					timeBackground:SetPoint ("bottomright", timeText, "bottomright", 2, 0)
					
					f.BossWidgetsFrame.Widgets [i] = newBossWidget
					bossWidget = newBossWidget
				end
				
				local chartLength = f.ChartFrame.Graphic:GetWidth()
				local secondsPerPixel = chartLength / elapsedTime
				local xPosition = bossTable[1] * secondsPerPixel
				
				bossWidget:SetPoint ("bottomright", f.ChartFrame.Graphic, "bottomleft", xPosition, 0)
				
				bossWidget.TimeText:SetText (Details:GetFramework():IntegerToTimer (bossTable[1]))
				
				if (bossTable[2].bossimage) then
					bossWidget.AvatarTexture:SetTexture (bossTable[2].bossimage)
				else
					local bossAvatar = Details:GetBossPortrait (nil, nil, bossTable[2].name, bossTable[2].ej_instance_id)
					bossWidget.AvatarTexture:SetTexture (bossAvatar)
				end
			end
		end

	end

	mythicDungeonCharts.Frame.ChartFrame:Reset()
	
	if (not mythicDungeonCharts.ChartTable) then
		--load the last mythic dungeon run chart
		local t = {}
		Details:GetFramework().table.copy (t, Details.mythic_plus.last_mythicrun_chart)
		mythicDungeonCharts.ChartTable = t
	end
	
	local charts = mythicDungeonCharts.ChartTable.Players
	
	for playerName, playerTable in pairs (charts) do
		
		local chartData = playerTable.ChartData
		local lineName = playerTable.Name
		
		local lineColor = {1, 1, 1, 1}
		local classColor = RAID_CLASS_COLORS [playerTable.Class]
		if (classColor) then
			lineColor [1] = classColor.r
			lineColor [2] = classColor.g
			lineColor [3] = classColor.b
			
			--print (playerName, playerTable.Class)
		end
		
		local combatTime = mythicDungeonCharts.ChartTable.ElapsedTime
		local texture = "line"
		
		--lowess smooth
		--chartData = mythicDungeonCharts.LowessSmoothing (chartData, 75)
		chartData = mythicDungeonCharts.Frame.ChartFrame:CalcLowessSmoothing (chartData, 75)
		
		local maxValue = 0
		for i = 1, #chartData do
			if (chartData [i] > maxValue) then
				maxValue = chartData [i]
			end
		end
		chartData.max_value = maxValue
		
		mythicDungeonCharts.Frame.ChartFrame:AddLine (chartData, lineColor, lineName, combatTime, texture, "SMA")		

		--[=[
		local smoothFactor = 0.075
		local forecastSmoothFactor = 1 - smoothFactor
		local lastForecast = chartData[1]
		local chartLag = {lastForecast}
		local maxValue = lastForecast
		
		for i = 2, #chartData do
			local forecast = (chartData[i] * smoothFactor) + (lastForecast * forecastSmoothFactor)
			tinsert (chartLag, forecast)
			lastForecast = forecast
			
			if (forecast > maxValue) then
				maxValue = forecast
			end
		end
		chartLag.max_value = maxValue

		mythicDungeonCharts.Frame.ChartFrame:AddLine (chartLag, lineColor, lineName, combatTime, texture, "SMA")		
		--]=]
	end
	
	
	mythicDungeonCharts.Frame.ChartFrame:RefreshBossTimeline (mythicDungeonCharts.ChartTable.BossDefeated, mythicDungeonCharts.ChartTable.ElapsedTime)
	
	--generate boss time table
	local bossTimeTable = {}
	for i, bossTable in ipairs (mythicDungeonCharts.ChartTable.BossDefeated) do
		local combatTime = bossTable [3] or math.random (10, 30)

		tinsert (bossTimeTable, bossTable[1])
		tinsert (bossTimeTable, bossTable[1] - combatTime)
	end
	
	mythicDungeonCharts.Frame.ChartFrame:AddOverlay (bossTimeTable, {1, 1, 1, 0.05}, "Boss Combat Time", "")
	
	
	local phrase = " Average Dps (under development)\npress Escape to hide, Details! Alpha Build." .. _detalhes.build_counter .. "." .. _detalhes.realversion
	
	mythicDungeonCharts.Frame.ChartFrame:SetTitle (mythicDungeonCharts.ChartTable.DungeonName and mythicDungeonCharts.ChartTable.DungeonName .. phrase or phrase)
	Details:GetFramework():SetFontSize (mythicDungeonCharts.Frame.ChartFrame.chart_title, 14)
	
	
end

--C_Timer.After (1, mythicDungeonCharts.ShowChart)

-- endd
