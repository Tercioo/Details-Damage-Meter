
--local pointer to details object
local Details = _G.Details
local debugmode = false --print debug lines
local verbosemode = false --auto open the chart panel
local _
local addonName, Details222 = ...
local mPlus = Details222.MythicPlusBreakdown
local detailsFramework = DetailsFramework

local Loc = _G.LibStub("AceLocale-3.0"):GetLocale( "Details" )

--constants
local CONST_USE_PLAYER_EDPS = false

--Generate damage chart for mythic dungeon runs

--[=[
The chart table needs to be stored saparated from the combat
Should the chart data be volatile?

--]=]

local mythicDungeonCharts = Details:CreateEventListener()
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

		mythicDungeonCharts:Debug("Dungeon ended successfully, chart data capture stopped, scheduling to open the window.")

		C_Timer.After(0.1, function()
			
		end)

		--the run is valid, schedule to open the chart window
		Details.mythic_plus.delay_to_show_graphic = 1
		C_Timer.After(Details.mythic_plus.delay_to_show_graphic, mythicDungeonCharts.ShowReadyPanel)

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

local createPlayerBanner = function(parent, name)
    local template = "ChallengeModeBannerPartyMemberTemplate"
    local playerFrame = CreateFrame("frame", name, parent, template)
	playerFrame:SetAlpha(1)
	playerFrame:EnableMouse(true)
	playerFrame:SetFrameLevel(parent:GetFrameLevel()+2)

    local playerNameFontString = playerFrame:CreateFontString("$parentPlayerNameText", "overlay", "GameFontNormal")
    playerNameFontString:SetTextColor(1, 1, 1)
    playerNameFontString:SetPoint("top", playerFrame, "bottom", -1, -7)
    DetailsFramework:SetFontSize(playerNameFontString, 12)
	playerFrame.PlayerNameFontString = playerNameFontString

	local playerNameBackgroundTexture = playerFrame:CreateTexture("$parentPlayerNameBackgroundTexture", "overlay", nil, 6)
	playerNameBackgroundTexture:SetTexture([[Interface\Cooldown\LoC-ShadowBG]])
	playerNameBackgroundTexture:SetSize(68, 12)
	playerNameBackgroundTexture:SetPoint("center", playerNameFontString, "center", 0, 0)

    local backgroundBannerTexture = playerFrame:CreateTexture("$parentBannerTexture", "background", nil, 0)
    backgroundBannerTexture:SetTexture([[Interface\ACHIEVEMENTFRAME\GuildTabard]])
    backgroundBannerTexture:SetDrawLayer("background", 0)
    backgroundBannerTexture:SetSize(63, 129)
    backgroundBannerTexture:SetTexCoord(5/128, 68/128, 123/256, 252/256)
    backgroundBannerTexture:SetPoint("topleft", playerFrame, "bottomleft", -5, playerFrame:GetHeight()/2)
    backgroundBannerTexture:SetPoint("topright", playerFrame, "bottomright", 4, playerFrame:GetHeight()/2)
    backgroundBannerTexture:SetVertexColor(.1, .1, .1)
	playerFrame.BackgroundBannerTexture = backgroundBannerTexture

	local backgroundBannerBorderTexture = playerFrame:CreateTexture("$parentBannerBorderTexture", "highlight", nil, -1)
	backgroundBannerBorderTexture:SetAtlas("UI-Achievement-Guild-Flag-Outline")
	backgroundBannerBorderTexture:SetSize(63, 129)
	backgroundBannerBorderTexture:SetPoint("topleft", playerFrame, "bottomleft", -5, playerFrame:GetHeight()/2)
	backgroundBannerBorderTexture:SetPoint("topright", playerFrame, "bottomright", 4, playerFrame:GetHeight()/2)

    local dungeonTexture = playerFrame:CreateTexture("$parentDungeonTexture", "artwork")
    dungeonTexture:SetTexCoord(25/512, 360/512, 50/512, 290/512)
    dungeonTexture:SetSize(50, 39)
    dungeonTexture:SetPoint("top", playerFrame,"bottom", 0, -16)
    dungeonTexture:SetAlpha(0.9934)
	playerFrame.DungeonTexture = dungeonTexture

    local dungeonBorderTexture = playerFrame:CreateTexture("$parentDungeonBorder", "border")
    dungeonBorderTexture:SetTexture([[Interface\BUTTONS\UI-EmptySlot]])
    dungeonBorderTexture:SetDrawLayer("border", 0)
    dungeonBorderTexture:ClearAllPoints()
    dungeonBorderTexture:SetPoint("topleft", dungeonTexture,"topleft", -17, 15)
    dungeonBorderTexture:SetPoint("bottomright", dungeonTexture,"bottomright", 18, -15)
    dungeonBorderTexture:SetAlpha(1)
	playerFrame.DungeonBorderTexture = dungeonBorderTexture

	--load this addon, required to have access to the garrison templates
	if (not C_AddOns.IsAddOnLoaded("Blizzard_GarrisonTemplates")) then
		C_AddOns.LoadAddOn("Blizzard_GarrisonTemplates")
	end

	--animation for the key leveling up
	local levelUpFrame = CreateFrame("frame", "$LevelUpFrame", playerFrame, "GarrisonFollowerLevelUpTemplate")
	levelUpFrame:SetPoint("top", dungeonTexture, "bottom", 0, 44)
	levelUpFrame:SetScale(0.9)
	levelUpFrame.Text:SetText("")
	playerFrame.LevelUpFrame = levelUpFrame
	levelUpFrame:SetFrameLevel(playerFrame:GetFrameLevel()+1)

	local levelUpTextFrame = CreateFrame("frame", "$LevelUpTextFrame", playerFrame)
	levelUpTextFrame:SetPoint("top", dungeonTexture, "bottom", -1, -14)
	levelUpTextFrame:SetFrameLevel(playerFrame:GetFrameLevel()+2)
	levelUpTextFrame:SetSize(1, 1)
	playerFrame.LevelUpTextFrame = levelUpTextFrame
																										--scaleX, scaleY, fadeInTime, fadeOutTime
	local shakeAnimation = detailsFramework:CreateFrameShake(levelUpTextFrame, 0.8, 2, 200, false, false, 0, 1, 0.5, 0.15)
	local shakeAnimation2 = detailsFramework:CreateFrameShake(levelUpTextFrame, 0.5, 1, 200, false, false, 0, 1, 0, 0)

    local levelFontString = levelUpTextFrame:CreateFontString("$parentLVLText", "artwork", "GameFontNormal")
    levelFontString:SetTextColor(1, 1, 1)
    levelFontString:SetPoint("center", levelUpTextFrame, "center", 0, 0)
    DetailsFramework:SetFontSize(levelFontString, 20)
	levelFontString:SetText("")
	playerFrame.LevelFontString = levelFontString

	--> animations for levelFontString
	local animationGroup = levelFontString:CreateAnimationGroup("DetailsMythicLevelTextAnimationGroup")
	animationGroup:SetLooping("NONE")
	levelFontString.AnimationGroup = animationGroup

	do
		levelFontString.translation = animationGroup:CreateAnimation("TRANSLATION")
		levelFontString.translation:SetTarget(levelFontString)
		levelFontString.translation:SetOrder(1)
		levelFontString.translation:SetDuration(0.096000000834465)
		levelFontString.translation:SetOffset(0, -4)
		levelFontString.translation = animationGroup:CreateAnimation("TRANSLATION")
		levelFontString.translation:SetTarget(levelFontString)
		levelFontString.translation:SetOrder(2)
		levelFontString.translation:SetDuration(0.11599999666214)
		levelFontString.translation:SetOffset(0, 16)
		levelFontString.rotation = animationGroup:CreateAnimation("ROTATION")
		levelFontString.rotation:SetTarget(levelFontString)
		levelFontString.rotation:SetOrder(3)
		levelFontString.rotation:SetDuration(0.096000000834465)
		levelFontString.rotation:SetDegrees(20)
		levelFontString.rotation:SetOrigin("center", 0, 0)
		levelFontString.rotation = animationGroup:CreateAnimation("ROTATION")
		levelFontString.rotation:SetTarget(levelFontString)
		levelFontString.rotation:SetOrder(4)
		levelFontString.rotation:SetDuration(0.096000000834465)
		levelFontString.rotation:SetDegrees(-20)
		levelFontString.rotation:SetOrigin("center", 0, 0)
		levelFontString.rotation = animationGroup:CreateAnimation("ROTATION")
		levelFontString.rotation:SetTarget(levelFontString)
		levelFontString.rotation:SetOrder(5)
		levelFontString.rotation:SetDuration(0.195999994874)
		levelFontString.rotation:SetDegrees(360)
		levelFontString.rotation:SetOrigin("center", 0, 0)
		levelFontString.translation = animationGroup:CreateAnimation("TRANSLATION")
		levelFontString.translation:SetTarget(levelFontString)
		levelFontString.translation:SetOrder(6)
		levelFontString.translation:SetDuration(0.21599999070168)
		levelFontString.translation:SetOffset(0, 9)
		levelFontString.translation = animationGroup:CreateAnimation("TRANSLATION")
		levelFontString.translation:SetTarget(levelFontString)
		levelFontString.translation:SetOrder(7)
		levelFontString.translation:SetDuration(0.046000000089407)
		levelFontString.translation:SetOffset(0, -24)
	end

	function levelUpTextFrame.PlayAnimations(newLevel)
		levelUpTextFrame:PlayFrameShake(shakeAnimation)

		C_Timer.After(0.7, function()
			playerFrame.LevelUpFrame:Show()
			playerFrame.LevelUpFrame:SetAlpha(1)
			playerFrame.LevelUpFrame.Anim:Play()
			animationGroup:Play()
		end)

		C_Timer.After(0.7 + 0.5, function()
			levelFontString:SetText(newLevel or "")
		end)

		C_Timer.After(1.65, function()
			levelUpTextFrame:PlayFrameShake(shakeAnimation2)
		end)
	end

	local flashTexture = playerFrame:CreateTexture("$parentFlashTexture", "overlay", nil, 6)
	flashTexture:SetAtlas("UI-Achievement-Guild-Flag-Outline")
	flashTexture:SetSize(63, 129)
	flashTexture:SetPoint("topleft", playerFrame, "bottomleft", -5, playerFrame:GetHeight()/2)
	flashTexture:SetPoint("topright", playerFrame, "bottomright", 4, playerFrame:GetHeight()/2)
	flashTexture:Hide()
	playerFrame.flashTexture = flashTexture

	detailsFramework:CreateFlashAnimation(flashTexture)
	--flashTexture:Flash(0.1, 0.5, 0.01)

	local lootSquare = CreateFrame("frame", name, parent)
	lootSquare:SetSize(46, 46)
	lootSquare:SetPoint("top", playerFrame, "bottom", 0, -90)
	lootSquare:SetFrameLevel(parent:GetFrameLevel()+1)
	playerFrame.LootSquare = lootSquare
	lootSquare:Hide()

	lootSquare:SetScript("OnEnter", function(self)
		if (self.itemLink) then
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			GameTooltip:SetHyperlink(lootSquare.itemLink)
			GameTooltip:Show()
		end
	end)

	lootSquare:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	local lootIcon = lootSquare:CreateTexture("$parentLootIcon", "artwork")
	lootIcon:SetSize(46, 46)
	lootIcon:SetPoint("center", lootSquare, "center", 0, 0)
	lootIcon:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
	lootSquare.LootIcon = lootIcon

	local lootIconBorder = lootSquare:CreateTexture("$parentLootSquareBorder", "overlay")
	lootIconBorder:SetTexture([[Interface\COMMON\WhiteIconFrame]])
	lootIconBorder:SetTexCoord(0, 1, 0, 1)
	lootIconBorder:SetSize(46, 46)
	lootIconBorder:SetPoint("center", lootIcon, "center", 0, 0)
	lootSquare.LootIconBorder = lootIconBorder

	local lootItemLevel = lootSquare:CreateFontString("$parentLootItemLevel", "overlay", "GameFontNormal")
	lootItemLevel:SetPoint("top", lootSquare, "bottom", 0, -2)
	lootItemLevel:SetTextColor(1, 1, 1)
	DetailsFramework:SetFontSize(lootItemLevel, 12)
	lootSquare.LootItemLevel = lootItemLevel

	return playerFrame
end


local updatPlayerBanner = function(unitId, bannerIndex)
	if (UnitExists(unitId)) then
		local readyFrame = DetailsMythicDungeonReadyFrame
		local unitName = Details:GetFullName(unitId)
		local libOpenRaid = LibStub("LibOpenRaid-1.0", true)

		local playerBanner = readyFrame.PlayerBanners[bannerIndex]
		readyFrame.playerCacheByName[unitName] = playerBanner
		playerBanner.unitId = unitId
		playerBanner.unitName = unitName
		playerBanner:Show()

		SetPortraitTexture(playerBanner.Portrait, unitId)

		unitName = detailsFramework:RemoveRealmName(unitName)
		playerBanner.PlayerNameFontString:SetText(unitName)
		detailsFramework:TruncateText(playerBanner.PlayerNameFontString, 60)

		local role = UnitGroupRolesAssigned(unitId)
		if (role == "TANK" or role == "HEALER" or role == "DAMAGER") then
			playerBanner.RoleIcon:SetAtlas(GetMicroIconForRole(role), TextureKitConstants.IgnoreAtlasSize)
			playerBanner.RoleIcon:Show()
		else
			playerBanner.RoleIcon:Hide()
		end

		local playerKeystoneInfo = libOpenRaid.GetKeystoneInfo(unitId)
		if (playerKeystoneInfo) then
			---@type details_instanceinfo
			local instanceInfo = Details:GetInstanceInfo(playerKeystoneInfo.mapID)

			playerBanner.LevelFontString:SetText(playerKeystoneInfo.level or "")

			if (instanceInfo) then
				playerBanner.DungeonTexture:SetTexture(instanceInfo.iconLore)
			else
				playerBanner.DungeonTexture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
			end
		else
			playerBanner.DungeonTexture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
			playerBanner.LevelFontString:SetText("")
		end
		return true
	end
end


local updateKeysStoneLevel = function()
	--update the player banners
	local libOpenRaid = LibStub("LibOpenRaid-1.0", true)
	local readyFrame = DetailsMythicDungeonReadyFrame

	for bannerIndex = 1, #readyFrame.PlayerBanners do
		local unitBanner = readyFrame.PlayerBanners[bannerIndex]
		if (unitBanner) then
			local unitId = unitBanner.unitId
			if (UnitExists(unitId)) then
				local unitKeystoneInfo = libOpenRaid.GetKeystoneInfo(unitId)
				--print("Unit Exists:", unitBanner.unitName, unitId, "updating keystone level", unitKeystoneInfo)
				if (unitKeystoneInfo) then
					--if (instanceInfo) then
					--	---@type details_instanceinfo
					--	local thisInstanceInfo = Details:GetInstanceInfo(unitKeystoneInfo.mapID)
					--	unitBanner.DungeonTexture:SetTexture(thisInstanceInfo.iconLore)
					--end

					--unitBanner.LevelFontString:SetText(unitKeystoneInfo.level)
					--print("setting player", unitBanner.unitName, "keystone level to", unitKeystoneInfo.level)

					local oldKeystoneLevel = Details.KeystoneLevels[Details:GetFullName(unitId)]

					if (oldKeystoneLevel and oldKeystoneLevel >= 2) then
						if (unitKeystoneInfo.level > oldKeystoneLevel) then
							C_Timer.After(0.5, function()
								unitBanner.LevelUpTextFrame.PlayAnimations(unitKeystoneInfo.level)
							end)

							---@type details_instanceinfo
							local instanceInfo = Details:GetInstanceInfo(unitKeystoneInfo.mapID)

							if (instanceInfo) then
								unitBanner.DungeonTexture:SetTexture(instanceInfo.iconLore)
							else
								unitBanner.DungeonTexture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
							end

							--this character had its keystone upgraded
							--unitBanner.flashTexture:Flash()
							--print("keystone upgraded for", Details:GetFullName(unitId), unitKeystoneInfo.level, "old was:", oldKeystoneLevel)
							--C_Timer.After(0.1, function() unitBanner.flashTexture:Stop() end)
						end
					end

					--print("keystone level updated for", Details:GetFullName(unitId), unitKeystoneInfo.level)
				else
					unitBanner.DungeonTexture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
					unitBanner.LevelFontString:SetText("")
				end
			end
		end
	end
end

--SetPortraitTexture(texture, unitId)
-- /run _G.DetailsMythicDungeonChartHandler.ShowChart(); DetailsMythicDungeonChartFrame.ShowChartFrame()
-- /run _G.DetailsMythicDungeonChartHandler.ShowReadyPanel()

--show a small panel telling the chart is ready to show
function mythicDungeonCharts.ShowReadyPanel(bIsDebug)
	--check if is enabled
	if (not Details.mythic_plus.show_damage_graphic) then
		return
	end

	if (bIsDebug) then
		Details222.MythicPlus.Level = Details222.MythicPlus.Level or 2
	end

	--feature under development
	if (Details222.MythicPlus.Level and Details222.MythicPlus.Level < 28 and not Details.user_is_patreon_supporter) then
		--create the panel
		if (not mythicDungeonCharts.ReadyFrame) then
			mythicDungeonCharts.ReadyFrame = CreateFrame("frame", "DetailsMythicDungeonReadyFrame", UIParent, "BackdropTemplate")
			local readyFrame = mythicDungeonCharts.ReadyFrame

			local textColor = {1, 0.8196, 0, 1}
			local textSize = 11

			local roundedCornerTemplate = {
				roundness = 6,
				color = {.1, .1, .1, 0.98},
				border_color = {.05, .05, .05, 0.834},
			}

			detailsFramework:AddRoundedCornersToFrame(readyFrame, roundedCornerTemplate)

			local titleLabel = DetailsFramework:CreateLabel(readyFrame, "Details! Mythic Run Completed!", 12, "yellow")
			titleLabel:SetPoint("top", readyFrame, "top", 0, -7)
			titleLabel.textcolor = textColor

			local closeButton = detailsFramework:CreateCloseButton(readyFrame, "$parentCloseButton")
			closeButton:SetPoint("topright", readyFrame, "topright", -2, -2)
			closeButton:SetScale(1.4)
			closeButton:SetAlpha(0.823)

			readyFrame:SetSize(255, 120)
			readyFrame:SetPoint("center", UIParent, "center", 300, 0)
			readyFrame:SetFrameStrata("LOW")
			readyFrame:EnableMouse(true)
			readyFrame:SetMovable(true)
			--DetailsFramework:ApplyStandardBackdrop(readyFrame)
			--DetailsFramework:CreateTitleBar (readyFrame, "Details! Mythic Run Completed!")

			readyFrame:Hide()

			--register to libwindow
			local LibWindow = LibStub("LibWindow-1.1")
			LibWindow.RegisterConfig(readyFrame, Details.mythic_plus.mythicrun_chart_frame_ready)
			LibWindow.RestorePosition(readyFrame)
			LibWindow.MakeDraggable(readyFrame)
			LibWindow.SavePosition(readyFrame)

			--show button
			---@type df_button
			readyFrame.ShowChartButton = DetailsFramework:CreateButton(readyFrame, function() mythicDungeonCharts.ShowChart(); readyFrame:Hide() end, 80, 20, "Show Damage Graphic")
			readyFrame.ShowChartButton:SetTemplate(DetailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
			readyFrame.ShowChartButton:SetPoint("topleft", readyFrame, "topleft", 5, -30)
			readyFrame.ShowChartButton:SetIcon([[Interface\AddOns\Details\images\icons2.png]], 16, 16, "overlay", {42/512, 75/512, 153/512, 187/512}, {.7, .7, .7, 1}, nil, 0, 0)
			readyFrame.ShowChartButton.textcolor = textColor

			--discart button
			--readyFrame.DiscartButton = DetailsFramework:CreateButton(readyFrame, function() readyFrame:Hide() end, 80, 20, Loc ["STRING_DISCARD"])
			--readyFrame.DiscartButton:SetTemplate(DetailsFramework:GetTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE"))
			--readyFrame.DiscartButton:SetPoint("right", readyFrame.ShowChartButton, "left", -5, 0)

			--disable feature check box (dont show this again)
			local on_switch_enable = function(self, _, value)
				Details.mythic_plus.show_damage_graphic = not value
			end

			local notAgainSwitch, notAgainLabel = DetailsFramework:CreateSwitch(readyFrame, on_switch_enable, not Details.mythic_plus.show_damage_graphic, _, _, _, _, _, _, _, _, _, Loc ["STRING_MINITUTORIAL_BOOKMARK4"], DetailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"), "GameFontHighlightLeft")
			notAgainSwitch:ClearAllPoints()
			notAgainLabel:SetPoint("left", notAgainSwitch, "right", 2, 0)
			notAgainSwitch:SetPoint("bottomleft", readyFrame, "bottomleft", 5, 5)
			notAgainSwitch:SetAsCheckBox()
			notAgainLabel.textSize = textSize

			local timeNotInCombatLabel = DetailsFramework:CreateLabel(readyFrame, "Time not in combat:", textSize, "orangered")
			timeNotInCombatLabel:SetPoint("bottomleft", notAgainSwitch, "topleft", 0, 7)
			local timeNotInCombatAmount = DetailsFramework:CreateLabel(readyFrame, "00:00", textSize, "orangered")
			timeNotInCombatAmount:SetPoint("left", timeNotInCombatLabel, "left", 130, 0)

			local elapsedTimeLabel = DetailsFramework:CreateLabel(readyFrame, "Run Time:", textSize, textColor)
			elapsedTimeLabel:SetPoint("bottomleft", timeNotInCombatLabel, "topleft", 0, 5)
			local elapsedTimeAmount = DetailsFramework:CreateLabel(readyFrame, "00:00", textSize, textColor)
			elapsedTimeAmount:SetPoint("left", elapsedTimeLabel, "left", 130, 0)

			readyFrame.TimeNotInCombatAmountLabel = timeNotInCombatAmount
			readyFrame.ElapsedTimeAmountLabel = elapsedTimeAmount
		end

		mythicDungeonCharts.ReadyFrame:Show()

		--update the run time and time not in combat
		local elapsedTime = Details222.MythicPlus.time or 1507
		mythicDungeonCharts.ReadyFrame.ElapsedTimeAmountLabel.text = DetailsFramework:IntegerToTimer(elapsedTime)

		local overallMythicDungeonCombat = Details:GetCurrentCombat()
		if (overallMythicDungeonCombat:GetCombatType() == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
			local combatTime = overallMythicDungeonCombat:GetCombatTime()
			local notInCombat = elapsedTime - combatTime
			mythicDungeonCharts.ReadyFrame.TimeNotInCombatAmountLabel.text = DetailsFramework:IntegerToTimer(notInCombat) .. " (" .. math.floor(notInCombat / elapsedTime * 100) .. "%)"
		end

		return
	end

	--create the panel
	if (not mythicDungeonCharts.ReadyFrame) then
		mythicDungeonCharts.ReadyFrame = CreateFrame("frame", "DetailsMythicDungeonReadyFrame", UIParent, "BackdropTemplate")
		local readyFrame = mythicDungeonCharts.ReadyFrame
		readyFrame.playerCacheByName = {}

		local textColor = {1, 0.8196, 0, 1}
		local textSize = 11

		local roundedCornerTemplate = {
			roundness = 6,
			color = {.1, .1, .1, 0.98},
			border_color = {.05, .05, .05, 0.834},
		}

		detailsFramework:AddRoundedCornersToFrame(readyFrame, roundedCornerTemplate)

		local titleLabel = DetailsFramework:CreateLabel(readyFrame, "Details! Mythic Run Completed!", 12, "yellow")
		titleLabel:SetPoint("top", readyFrame, "top", 0, -7)
		titleLabel.textcolor = textColor

		local closeButton = detailsFramework:CreateCloseButton(readyFrame, "$parentCloseButton")
		closeButton:SetPoint("topright", readyFrame, "topright", -2, -2)
		closeButton:SetScale(1.4)
		closeButton:SetAlpha(0.823)

		readyFrame:SetSize(355, 390)
		readyFrame:SetPoint("center", UIParent, "center", 300, 0)
		readyFrame:SetFrameStrata("LOW")
		readyFrame:EnableMouse(true)
		readyFrame:SetMovable(true)
		readyFrame:Hide()

		--register to libwindow
		local LibWindow = LibStub("LibWindow-1.1")
		LibWindow.RegisterConfig(readyFrame, Details.mythic_plus.mythicrun_chart_frame_ready)
		LibWindow.RestorePosition(readyFrame)
		LibWindow.MakeDraggable(readyFrame)
		LibWindow.SavePosition(readyFrame)

		--warning footer
		local warningFooter = DetailsFramework:CreateLabel(readyFrame, "You are seeing this because it's a 28 or above. Under development.", 9, "yellow")
		warningFooter:SetPoint("bottom", readyFrame, "bottom", 0, 20)

        local roundedCornerPreset = {
            color = {.075, .075, .075, 1},
            border_color = {.2, .2, .2, 1},
            roundness = 8,
        }

		local leftAnchor

		--show m+ run breakdown
		local showBreakdownFunc = function()
			mPlus.ShowSummary()
		end
		---@type df_button
		readyFrame.ShowBreakdownButton = DetailsFramework:CreateButton(readyFrame, showBreakdownFunc, 145, 30, "Show Breakdown")
		PixelUtil.SetPoint(readyFrame.ShowBreakdownButton, "topleft", readyFrame, "topleft", 5, -30)
		PixelUtil.SetSize(readyFrame.ShowBreakdownButton, 145, 32)
		readyFrame.ShowBreakdownButton:SetBackdrop(nil)
		readyFrame.ShowBreakdownButton:SetIcon([[Interface\AddOns\Details\images\icons2.png]], 16, 16, "overlay", {84/512, 120/512, 153/512, 187/512}, {.7, .7, .7, 1}, nil, 0, 0)
		readyFrame.ShowBreakdownButton.textcolor = textColor
        detailsFramework:AddRoundedCornersToFrame(readyFrame.ShowBreakdownButton.widget, roundedCornerPreset)
		leftAnchor = readyFrame.ShowBreakdownButton
		readyFrame.ShowBreakdownButton:Disable()

		--show graphic button
		local showChartFunc = function(self)
			mythicDungeonCharts.ShowChart()
			readyFrame:Hide()
		end
		---@type df_button
		readyFrame.ShowChartButton = DetailsFramework:CreateButton(readyFrame, showChartFunc, 145, 30, "Show Damage Graphic")
		PixelUtil.SetPoint(readyFrame.ShowChartButton, "left", readyFrame.ShowBreakdownButton, "right", 5, 0)
		PixelUtil.SetSize(readyFrame.ShowChartButton, 145, 32)
		readyFrame.ShowChartButton:SetBackdrop(nil)
		readyFrame.ShowChartButton:SetIcon([[Interface\AddOns\Details\images\icons2.png]], 16, 16, "overlay", {42/512, 75/512, 153/512, 187/512}, {.7, .7, .7, 1}, nil, 0, 0)
		readyFrame.ShowChartButton.textcolor = textColor
        detailsFramework:AddRoundedCornersToFrame(readyFrame.ShowChartButton.widget, roundedCornerPreset)


		--disable feature check box (dont show this again)
		local on_switch_enable = function(self, _, value)
			Details.mythic_plus.show_damage_graphic = not value
		end

		local elapsedTimeLabel = DetailsFramework:CreateLabel(readyFrame, "Run Time:", textSize, textColor)
		elapsedTimeLabel:SetPoint("topleft", leftAnchor, "bottomleft", 0, -8)
		local elapsedTimeAmount = DetailsFramework:CreateLabel(readyFrame, "00:00", textSize, textColor)
		elapsedTimeAmount:SetPoint("left", elapsedTimeLabel, "left", 130, 0)

		local timeNotInCombatLabel = DetailsFramework:CreateLabel(readyFrame, "Time not in combat:", textSize, "orangered")
		timeNotInCombatLabel:SetPoint("topleft", elapsedTimeLabel, "bottomleft", 0, -5)
		local timeNotInCombatAmount = DetailsFramework:CreateLabel(readyFrame, "00:00", textSize, "orangered")
		timeNotInCombatAmount:SetPoint("left", timeNotInCombatLabel, "left", 130, 0)

		local youBeatTheTimerLabel = DetailsFramework:CreateLabel(readyFrame, "", textSize, "white")
		youBeatTheTimerLabel:SetPoint("topleft", timeNotInCombatLabel, "bottomleft", 0, -5)

		--local keystoneUpgradeLabel = DetailsFramework:CreateLabel(readyFrame, "Keystone Upgrade:", textSize, "white")
		--keystoneUpgradeLabel:SetPoint("topleft", youBeatTheTimerLabel, "bottomleft", 0, -5)

		local rantingLabel = DetailsFramework:CreateLabel(readyFrame, "", textSize, textColor)
		--rantingLabel:SetPoint("topleft", keystoneUpgradeLabel, "bottomleft", 0, -5)
		rantingLabel:SetPoint("topleft", youBeatTheTimerLabel, "bottomleft", 0, -5)

		readyFrame.PlayerBanners = {}
		for i = 1, 5 do
			local playerBanner = createPlayerBanner(readyFrame, "$parentPlayerBanner" .. i)
			readyFrame.PlayerBanners[#readyFrame.PlayerBanners+1] = playerBanner
			if (i == 1) then
				playerBanner:SetPoint("topleft", rantingLabel.widget, "bottomleft", 0, -22)
			else
				playerBanner:SetPoint("topleft", readyFrame.PlayerBanners[i-1], "topright", 10, 0)
			end
		end

		--frame to handle loot events
		local lootFrame = CreateFrame("frame", "$parentLootFrame", readyFrame)
		lootFrame:RegisterEvent("BOSS_KILL");
		lootFrame:RegisterEvent("ENCOUNTER_LOOT_RECEIVED")

		local bossKillEncounterId

		lootFrame:SetScript("OnEvent", function(self, event, ...)
			if (event == "BOSS_KILL") then
				local encounterID, name = ...;
				bossKillEncounterId = encounterID
				--print("BOSS_KILL", GetTime(), bossKillEncounterId)

			elseif (event == "ENCOUNTER_LOOT_RECEIVED") then
				local lootEncounterId, itemID, itemLink, quantity, playerName, className = ...
				--print("ENCOUNTER_LOOT_RECEIVED", GetTime(), lootEncounterId, bossKillEncounterId)

				--print("no ambig:", playerName, "with ambig:", Ambiguate(playerName, "none")) --debug
				playerName = Ambiguate(playerName, "none")
				local unitBanner = readyFrame.playerCacheByName[playerName]

				if (not unitBanner) then
					--print("no unitBanner for player", playerName, "aborting.")
					return
				end

				local _, instanceType = GetInstanceInfo()
				--print("Is encounter the same:", lootEncounterId == bossKillEncounterId)
				if (instanceType == "party") then -- or instanceType == "raid" --lootEncounterId == bossKillEncounterId and 
					--print("all good showing loot for player", playerName)
					local lootSquare = unitBanner.LootSquare
					lootSquare.itemLink = itemLink

					local effectiveILvl = GetDetailedItemLevelInfo(itemLink)

					local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
					itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
					expacID, setID, isCraftingReagent = GetItemInfo(itemLink)

					--print("equip loc:", itemEquipLoc)

					if (effectiveILvl > 300) then --avoid showing loot that isn't items

						local rarityColor = ITEM_QUALITY_COLORS[itemQuality]
						lootSquare.LootIconBorder:SetVertexColor(rarityColor.r, rarityColor.g, rarityColor.b, 1)

						lootSquare.LootIcon:SetTexture(GetItemIcon(itemID))
						lootSquare.LootItemLevel:SetText(effectiveILvl or "0")

						--print("loot info:", itemLink, effectiveILvl, itemQuality)
						lootSquare:Show()
					end
				end
			end
		end)

		--[=[
		Details222.MythicPlus.MapID = mapID
		Details222.MythicPlus.Level = level --level of the key just finished
		Details222.MythicPlus.OnTime = onTime
		Details222.MythicPlus.KeystoneUpgradeLevels = keystoneUpgradeLevels
		Details222.MythicPlus.PracticeRun = practiceRun
		Details222.MythicPlus.OldDungeonScore = oldDungeonScore
		Details222.MythicPlus.NewDungeonScore = newDungeonScore
		Details222.MythicPlus.IsAffixRecord = isAffixRecord
		Details222.MythicPlus.IsMapRecord = isMapRecord
		Details222.MythicPlus.PrimaryAffix = primaryAffix
		Details222.MythicPlus.IsEligibleForScore = isEligibleForScore
		Details222.MythicPlus.UpgradeMembers = upgradeMembers
		Details222.MythicPlus.DungeonName = dungeonName
		Details222.MythicPlus.DungeonID = id
		Details222.MythicPlus.TimeLimit = timeLimit
		Details222.MythicPlus.Texture = texture
		Details222.MythicPlus.BackgroundTexture = backgroundTexture
		--]=]

		local notAgainSwitch, notAgainLabel = DetailsFramework:CreateSwitch(readyFrame, on_switch_enable, not Details.mythic_plus.show_damage_graphic, _, _, _, _, _, _, _, _, _, Loc ["STRING_MINITUTORIAL_BOOKMARK4"], DetailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"), "GameFontHighlightLeft")
		notAgainSwitch:ClearAllPoints()
		notAgainLabel:SetPoint("left", notAgainSwitch, "right", 2, 0)
		notAgainSwitch:SetPoint("bottomleft", readyFrame, "bottomleft", 5, 5)
		notAgainSwitch:SetAsCheckBox()
		notAgainSwitch:SetSize(12, 12)
		notAgainLabel.textsize = 9

		readyFrame.TimeNotInCombatAmountLabel = timeNotInCombatAmount
		readyFrame.ElapsedTimeAmountLabel = elapsedTimeAmount
		readyFrame.YouBeatTheTimerLabel = youBeatTheTimerLabel
		readyFrame.KeystoneUpgradeLabel = keystoneUpgradeLabel
		readyFrame.RantingLabel = rantingLabel
	end

	local readyFrame = mythicDungeonCharts.ReadyFrame
	readyFrame:Show()

	for i = 1, #readyFrame.PlayerBanners do
		--hide the lootSquare
		readyFrame.PlayerBanners[i].LootSquare:Hide()
	end

	wipe(readyFrame.playerCacheByName)

	--update the run time and time not in combat
	local elapsedTime = Details222.MythicPlus.time or 1507
	readyFrame.ElapsedTimeAmountLabel.text = DetailsFramework:IntegerToTimer(elapsedTime)

	C_Timer.After(1.5, function()
		local overallMythicDungeonCombat = Details:GetCurrentCombat()
		--print("overall combat type:", overallMythicDungeonCombat:GetCombatType(), overallMythicDungeonCombat:GetCombatType() == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL)
		if (overallMythicDungeonCombat:GetCombatType() == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
			local combatTime = overallMythicDungeonCombat:GetCombatTime()
			local notInCombat = elapsedTime - combatTime
			readyFrame.TimeNotInCombatAmountLabel.text = DetailsFramework:IntegerToTimer(notInCombat) .. " (" .. math.floor(notInCombat / elapsedTime * 100) .. "%)"
		else
			readyFrame.TimeNotInCombatAmountLabel.text = "Unknown for this run"
		end
	end)

	if (Details222.MythicPlus.OnTime) then
		readyFrame.YouBeatTheTimerLabel:SetFormattedText(CHALLENGE_MODE_COMPLETE_BEAT_TIMER .. " | " .. CHALLENGE_MODE_COMPLETE_KEYSTONE_UPGRADED, Details222.MythicPlus.KeystoneUpgradeLevels) --"You beat the timer!"
		readyFrame.YouBeatTheTimerLabel.textcolor = "limegreen"
		--readyFrame.KeystoneUpgradeLabel:SetFormattedText(CHALLENGE_MODE_COMPLETE_KEYSTONE_UPGRADED, Details222.MythicPlus.KeystoneUpgradeLevels)
	else
		readyFrame.YouBeatTheTimerLabel.textcolor = "white"
		readyFrame.YouBeatTheTimerLabel.text = CHALLENGE_MODE_COMPLETE_TIME_EXPIRED --"Time expired!"
		--readyFrame.KeystoneUpgradeLabel.text = CHALLENGE_MODE_COMPLETE_TRY_AGAIN --"Try again! Beat the timer to upgrade your keystone!"
	end

	if (Details222.MythicPlus.NewDungeonScore and Details222.MythicPlus.OldDungeonScore) then
		local gainedScore = Details222.MythicPlus.NewDungeonScore - Details222.MythicPlus.OldDungeonScore
		local color = C_ChallengeMode.GetDungeonScoreRarityColor(Details222.MythicPlus.NewDungeonScore)
		if (not color) then
			color = HIGHLIGHT_FONT_COLOR
		end
		readyFrame.RantingLabel.text = CHALLENGE_COMPLETE_DUNGEON_SCORE:format(color:WrapTextInColorCode(CHALLENGE_COMPLETE_DUNGEON_SCORE_FORMAT_TEXT:format(Details222.MythicPlus.NewDungeonScore, gainedScore)))
		readyFrame.RantingLabel.textcolor = "limegreen"
	else
		readyFrame.RantingLabel.text = ""
	end

	for i = 1, #readyFrame.PlayerBanners do
		readyFrame.PlayerBanners[i]:Hide()
	end

	local playersFound = 0
	local playerBannerIndex = 1
	do --update the player banner
		if (updatPlayerBanner("player", playerBannerIndex)) then
			playersFound = playersFound + 1
		end
	end

	local unitCount = 1
	for bannerIndex = 2, #readyFrame.PlayerBanners do
		if (updatPlayerBanner("party"..unitCount, bannerIndex)) then
			playersFound = playersFound + 1
		end
		unitCount = unitCount + 1
	end

	for i = playersFound+1, #readyFrame.PlayerBanners do
		readyFrame.PlayerBanners[i]:Hide()
	end

	C_Timer.After(2.5, updateKeysStoneLevel)
end

-- /run _G.DetailsMythicDungeonChartHandler.ShowReadyPanel()

function mythicDungeonCharts.ShowChart()
	if (not mythicDungeonCharts.Frame) then
		mythicDungeonCharts.Frame = CreateFrame("frame", "DetailsMythicDungeonChartFrame", UIParent, "BackdropTemplate")
		local dungeonChartFrame = mythicDungeonCharts.Frame

		dungeonChartFrame:SetSize(1200, 620)
		dungeonChartFrame:SetPoint("center", UIParent, "center", 0, 0)
		dungeonChartFrame:SetFrameStrata("LOW")
		dungeonChartFrame:EnableMouse(true)
		dungeonChartFrame:SetMovable(true)
		DetailsFramework:ApplyStandardBackdrop(dungeonChartFrame)

		--minimized frame
		mythicDungeonCharts.FrameMinimized = CreateFrame("frame", "DetailsMythicDungeonChartFrameminimized", UIParent, "BackdropTemplate")
		local fMinimized = mythicDungeonCharts.FrameMinimized

		fMinimized:SetSize(160, 24)
		fMinimized:SetPoint("center", UIParent, "center", 0, 0)
		fMinimized:SetFrameStrata("LOW")
		fMinimized:EnableMouse(true)
		fMinimized:SetMovable(true)
		fMinimized:Hide()
		DetailsFramework:ApplyStandardBackdrop(fMinimized)

		dungeonChartFrame.IsMinimized = false

		--titlebar
			local titlebar = CreateFrame("frame", nil, dungeonChartFrame, "BackdropTemplate")
			titlebar:SetPoint("topleft", dungeonChartFrame, "topleft", 2, -3)
			titlebar:SetPoint("topright", dungeonChartFrame, "topright", -2, -3)
			titlebar:SetHeight(20)
			titlebar:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
			titlebar:SetBackdropColor(.5, .5, .5, 1)
			titlebar:SetBackdropBorderColor(0, 0, 0, 1)

			--title
			local titleLabel = Details.gump:NewLabel(titlebar, titlebar, nil, "titulo", "Plugins", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
			titleLabel:SetPoint("center", titlebar , "center")
			titleLabel:SetPoint("top", titlebar , "top", 0, -5)
			dungeonChartFrame.TitleText = titleLabel

		--titlebar when minimized
			local titlebarMinimized = CreateFrame("frame", nil, fMinimized, "BackdropTemplate")
			titlebarMinimized:SetPoint("topleft", fMinimized, "topleft", 2, -3)
			titlebarMinimized:SetPoint("topright", fMinimized, "topright", -2, -3)
			titlebarMinimized:SetHeight(20)
			titlebarMinimized:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
			titlebarMinimized:SetBackdropColor(.5, .5, .5, 1)
			titlebarMinimized:SetBackdropBorderColor(0, 0, 0, 1)

			--title
			local titleLabelMinimized = Details.gump:NewLabel(titlebarMinimized, titlebarMinimized, nil, "titulo", "Dungeon Run Chart", "GameFontHighlightLeft", 10, {227/255, 186/255, 4/255})
			titleLabelMinimized:SetPoint("left", titlebarMinimized , "left", 4, 0)
			--titleLabelMinimized:SetPoint("top", titlebarMinimized , "top", 0, -5)
			dungeonChartFrame.TitleTextMinimized = titleLabelMinimized

		table.insert(UISpecialFrames, "DetailsMythicDungeonChartFrame")

		--register to libwindow
		local LibWindow = LibStub("LibWindow-1.1")
		LibWindow.RegisterConfig(dungeonChartFrame, Details.mythic_plus.mythicrun_chart_frame)
		LibWindow.RestorePosition(dungeonChartFrame)
		LibWindow.MakeDraggable(dungeonChartFrame)
		LibWindow.SavePosition(dungeonChartFrame)

		LibWindow.RegisterConfig(fMinimized, Details.mythic_plus.mythicrun_chart_frame_minimized)
		LibWindow.RestorePosition(fMinimized)
		LibWindow.MakeDraggable(fMinimized)
		LibWindow.SavePosition(fMinimized)

		dungeonChartFrame.ChartFrame = Details:GetFramework():CreateChartPanel(dungeonChartFrame, 1200, 600, "DetailsMythicDungeonChartGraphicFrame")
		dungeonChartFrame.ChartFrame:SetPoint("topleft", dungeonChartFrame, "topleft", 5, -20)

		dungeonChartFrame.ChartFrame.FrameInUse = {}
		dungeonChartFrame.ChartFrame.FrameFree = {}
		dungeonChartFrame.ChartFrame.TextureID = 1

		dungeonChartFrame.ChartFrame.ShowHeader = true
		dungeonChartFrame.ChartFrame.HeaderOnlyIndicator = true
		dungeonChartFrame.ChartFrame.HeaderShowOverlays = false

		dungeonChartFrame.ChartFrame.Graphic.DrawLine = mythicDungeonCharts.CustomDrawLine

		dungeonChartFrame.ChartFrame:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
		dungeonChartFrame.ChartFrame:SetBackdropColor(0, 0, 0, 0.0)
		dungeonChartFrame.ChartFrame:SetBackdropBorderColor(0, 0, 0, 0)

		dungeonChartFrame.ChartFrame:EnableMouse(false)

		dungeonChartFrame.ChartFrame.CloseButton:Hide()

		dungeonChartFrame.BossWidgetsFrame = CreateFrame("frame", "$parentBossFrames", dungeonChartFrame, "BackdropTemplate")
		dungeonChartFrame.BossWidgetsFrame:SetFrameLevel(dungeonChartFrame:GetFrameLevel()+10)
		dungeonChartFrame.BossWidgetsFrame.Widgets = {}

		dungeonChartFrame.BossWidgetsFrame.GraphPin = dungeonChartFrame.BossWidgetsFrame:CreateTexture(nil, "overlay")
		dungeonChartFrame.BossWidgetsFrame.GraphPin:SetTexture([[Interface\BUTTONS\UI-RadioButton]])
		dungeonChartFrame.BossWidgetsFrame.GraphPin:SetTexCoord(17/64, 32/64, 0, 1)
		dungeonChartFrame.BossWidgetsFrame.GraphPin:SetSize(16, 16)

		dungeonChartFrame.BossWidgetsFrame.GraphPinGlow = dungeonChartFrame.BossWidgetsFrame:CreateTexture(nil, "artwork")
		dungeonChartFrame.BossWidgetsFrame.GraphPinGlow:SetTexture([[Interface\Calendar\EventNotificationGlow]])
		dungeonChartFrame.BossWidgetsFrame.GraphPinGlow:SetTexCoord(0, 1, 0, 1)
		dungeonChartFrame.BossWidgetsFrame.GraphPinGlow:SetSize(14, 14)
		dungeonChartFrame.BossWidgetsFrame.GraphPinGlow:SetBlendMode("ADD")
		dungeonChartFrame.BossWidgetsFrame.GraphPinGlow:SetPoint("center", dungeonChartFrame.BossWidgetsFrame.GraphPin, "center", 0, 0)

		dungeonChartFrame:Hide()

		function dungeonChartFrame.ShowChartFrame()
			if (dungeonChartFrame.IsMinimized) then
				dungeonChartFrame.IsMinimized = false
				fMinimized:Hide()
				dungeonChartFrame:Show()
			else
				dungeonChartFrame:Show()
			end
		end

		local closeButton = CreateFrame("button", "$parentCloseButton", dungeonChartFrame, "UIPanelCloseButton")
		closeButton:GetNormalTexture():SetDesaturated(true)
		closeButton:SetWidth(24)
		closeButton:SetHeight(24)
		closeButton:SetPoint("topright", dungeonChartFrame, "topright", 0, -1)
		closeButton:SetFrameLevel(dungeonChartFrame:GetFrameLevel()+16)

		local minimizeButton = CreateFrame("button", "$parentCloseButton", dungeonChartFrame, "UIPanelCloseButton")
		minimizeButton:GetNormalTexture():SetDesaturated(true)
		minimizeButton:SetWidth(24)
		minimizeButton:SetHeight(24)
		minimizeButton:SetPoint("right", closeButton, "left", 2, 0)
		minimizeButton:SetFrameLevel(dungeonChartFrame:GetFrameLevel()+16)
		minimizeButton:SetNormalTexture([[Interface\BUTTONS\UI-Panel-HideButton-Up]])
		minimizeButton:SetPushedTexture([[Interface\BUTTONS\UI-Panel-HideButton-Down]])
		minimizeButton:SetHighlightTexture([[Interface\BUTTONS\UI-Panel-MinimizeButton-Highlight]])

		local closeButtonWhenMinimized = CreateFrame("button", "$parentCloseButton", fMinimized, "UIPanelCloseButton")
		closeButtonWhenMinimized:GetNormalTexture():SetDesaturated(true)
		closeButtonWhenMinimized:SetWidth(24)
		closeButtonWhenMinimized:SetHeight(24)
		closeButtonWhenMinimized:SetPoint("topright", fMinimized, "topright", 0, -1)
		closeButtonWhenMinimized:SetFrameLevel(fMinimized:GetFrameLevel()+16)

		local minimizeButtonWhenMinimized = CreateFrame("button", "$parentCloseButton", fMinimized, "UIPanelCloseButton")
		minimizeButtonWhenMinimized:GetNormalTexture():SetDesaturated(true)
		minimizeButtonWhenMinimized:SetWidth(24)
		minimizeButtonWhenMinimized:SetHeight(24)
		minimizeButtonWhenMinimized:SetPoint("right", closeButtonWhenMinimized, "left", 2, 0)
		minimizeButtonWhenMinimized:SetFrameLevel(fMinimized:GetFrameLevel()+16)
		minimizeButtonWhenMinimized:SetNormalTexture([[Interface\BUTTONS\UI-Panel-HideButton-Up]])
		minimizeButtonWhenMinimized:SetPushedTexture([[Interface\BUTTONS\UI-Panel-HideButton-Down]])
		minimizeButtonWhenMinimized:SetHighlightTexture([[Interface\BUTTONS\UI-Panel-MinimizeButton-Highlight]])

		closeButtonWhenMinimized:SetScript("OnClick", function()
			dungeonChartFrame.IsMinimized = false
			fMinimized:Hide()
			minimizeButtonWhenMinimized:SetNormalTexture([[Interface\BUTTONS\UI-Panel-HideButton-Up]])
			minimizeButtonWhenMinimized:SetPushedTexture([[Interface\BUTTONS\UI-Panel-HideButton-Down]])
		end)

		--replace the default click function
		local minimize_func = function(self)
			if (dungeonChartFrame.IsMinimized) then
				dungeonChartFrame.IsMinimized = false
				fMinimized:Hide()
				dungeonChartFrame:Show()
				minimizeButtonWhenMinimized:SetNormalTexture([[Interface\BUTTONS\UI-Panel-HideButton-Up]])
				minimizeButtonWhenMinimized:SetPushedTexture([[Interface\BUTTONS\UI-Panel-HideButton-Down]])
			else
				dungeonChartFrame.IsMinimized = true
				dungeonChartFrame:Hide()
				fMinimized:Show()
				minimizeButtonWhenMinimized:SetNormalTexture([[Interface\BUTTONS\UI-Panel-CollapseButton-Up]])
				minimizeButtonWhenMinimized:SetPushedTexture([[Interface\BUTTONS\UI-Panel-CollapseButton-Up]])
			end
		end

		minimizeButton:SetScript("OnClick", minimize_func)
		minimizeButtonWhenMinimized:SetScript("OnClick", minimize_func)

		--enabled box
		-- /run _G.DetailsMythicDungeonChartHandler.ShowChart(); DetailsMythicDungeonChartFrame.ShowChartFrame()
		local on_switch_enable = function(_, _, state)
			Details.mythic_plus.show_damage_graphic = state
		end
		local enabledSwitch, enabledLabel = Details.gump:CreateSwitch(dungeonChartFrame, on_switch_enable, Details.mythic_plus.show_damage_graphic, _, _, _, _, _, _, _, _, _, "Enabled", Details.gump:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"), "GameFontHighlightLeft")
		enabledSwitch:SetAsCheckBox()
		enabledSwitch.tooltip = "Show this chart at the end of a mythic dungeon run.\n\nIf disabled, you can reactivate it again at the options panel > streamer settings."
		enabledLabel:SetPoint("right", minimizeButton, "left", -22, 0)
		enabledSwitch:SetSize(16, 16)
		Details.gump:SetFontColor(enabledLabel, "gray")
		enabledSwitch.checked_texture:SetVertexColor(.75, .75, .75)

		local leftDivisorLine = dungeonChartFrame.BossWidgetsFrame:CreateTexture(nil, "overlay")
		leftDivisorLine:SetSize(2, dungeonChartFrame.ChartFrame.Graphic:GetHeight())
		leftDivisorLine:SetColorTexture(1, 1, 1, 1)
		leftDivisorLine:SetPoint("bottomleft", dungeonChartFrame.ChartFrame.Graphic.TextFrame, "bottomleft", -2, 0)

		local bottomDivisorLine = dungeonChartFrame.BossWidgetsFrame:CreateTexture(nil, "overlay")
		bottomDivisorLine:SetSize(dungeonChartFrame.ChartFrame.Graphic:GetWidth(), 2)
		bottomDivisorLine:SetColorTexture(1, 1, 1, 1)
		bottomDivisorLine:SetPoint("bottomleft", dungeonChartFrame.ChartFrame.Graphic.TextFrame, "bottomleft", 0, 0)

		dungeonChartFrame.ChartFrame.Graphic:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
		dungeonChartFrame.ChartFrame.Graphic:SetBackdropColor(.5, .50, .50, 0.8)
		dungeonChartFrame.ChartFrame.Graphic:SetBackdropBorderColor(0, 0, 0, 0.5)

		function dungeonChartFrame.ChartFrame.RefreshBossTimeline(self, bossTable, elapsedTime)
			for i, bossTable in ipairs(mythicDungeonCharts.ChartTable.BossDefeated) do
				local bossWidget = dungeonChartFrame.BossWidgetsFrame.Widgets [i]

				if (not bossWidget) then
					local newBossWidget = CreateFrame("frame", "$parentBossWidget" .. i, dungeonChartFrame.BossWidgetsFrame, "BackdropTemplate")
					newBossWidget:SetSize(64, 32)
					newBossWidget:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
					newBossWidget:SetBackdropColor(0, 0, 0, 0.1)
					newBossWidget:SetBackdropBorderColor(0, 0, 0, 0)

					local bossAvatar = Details:GetFramework():CreateImage(newBossWidget, "", 64, 32, "border")
					bossAvatar:SetPoint("bottomleft", newBossWidget, "bottomleft", 0, 0)
					newBossWidget.AvatarTexture = bossAvatar

					local verticalLine = Details:GetFramework():CreateImage(newBossWidget, "", 1, dungeonChartFrame.ChartFrame.Graphic:GetHeight(), "overlay")
					verticalLine:SetColorTexture(1, 1, 1, 0.3)
					verticalLine:SetPoint("bottomleft", newBossWidget, "bottomright", 0, 0)

					local timeText = Details:GetFramework():CreateLabel(newBossWidget)
					timeText:SetPoint("bottomright", newBossWidget, "bottomright", 0, 0)
					newBossWidget.TimeText = timeText

					local timeBackground = Details:GetFramework():CreateImage(newBossWidget, "", 30, 12, "artwork")
					timeBackground:SetColorTexture(0, 0, 0, 0.5)
					timeBackground:SetPoint("topleft", timeText, "topleft", -2, 2)
					timeBackground:SetPoint("bottomright", timeText, "bottomright", 2, 0)

					dungeonChartFrame.BossWidgetsFrame.Widgets [i] = newBossWidget
					bossWidget = newBossWidget
				end

				local chartLength = dungeonChartFrame.ChartFrame.Graphic:GetWidth()
				local secondsPerPixel = chartLength / elapsedTime
				local xPosition = bossTable[1] * secondsPerPixel

				bossWidget:SetPoint("bottomright", dungeonChartFrame.ChartFrame.Graphic, "bottomleft", xPosition, 0)

				bossWidget.TimeText:SetText(Details:GetFramework():IntegerToTimer(bossTable[1]))

				if (bossTable[2].bossimage) then
					bossWidget.AvatarTexture:SetTexture(bossTable[2].bossimage)
				else
					local bossAvatar = Details:GetBossPortrait(nil, nil, bossTable[2].name, bossTable[2].ej_instance_id)
					bossWidget.AvatarTexture:SetTexture(bossAvatar)
				end
			end
		end
	end

	mythicDungeonCharts.Frame.ChartFrame:Reset()

	if (not mythicDungeonCharts.ChartTable) then
		if (debugmode) then
			--development
			if (Details.mythic_plus.last_mythicrun_chart) then
				--load the last mythic dungeon run chart
				local t = {}
				Details:GetFramework().table.copy(t, Details.mythic_plus.last_mythicrun_chart)
				mythicDungeonCharts.ChartTable = t
				mythicDungeonCharts:Debug("no valid data, saved data loaded")

			else
				mythicDungeonCharts:Debug("no valid data and no saved data, canceling")
				mythicDungeonCharts.Frame:Hide()
				return
			end

		else
			mythicDungeonCharts.Frame:Hide()
			mythicDungeonCharts:Debug("no data found, canceling")

			if (verbosemode) then
				mythicDungeonCharts:Debug("mythicDungeonCharts.ShowChart() failed: no chart table")
			end
			return
		end
	end

	local charts = mythicDungeonCharts.ChartTable.Players
	local classDuplicated = {}

	mythicDungeonCharts.PlayerGraphIndex = {}

	for playerName, playerTable in pairs(charts) do
		local chartData = playerTable.ChartData
		local lineName = playerTable.Name

		classDuplicated[playerTable.Class] = (classDuplicated[playerTable.Class] or 0) + 1

		local lineColor
		if (playerTable.Class) then
			local classColor = mythicDungeonCharts.ClassColors[playerTable.Class .. classDuplicated[playerTable.Class]]
			if (classColor) then
				lineColor = {classColor.r, classColor.g, classColor.b}
			else
				lineColor = {1, 1, 1}
			end
		else
			lineColor = {1, 1, 1}
		end

		local combatTime = mythicDungeonCharts.ChartTable.ElapsedTime
		local texture = "line"

		--lowess smooth
		--chartData = mythicDungeonCharts.LowessSmoothing (chartData, 75)
		chartData = mythicDungeonCharts.Frame.ChartFrame:CalcLowessSmoothing(chartData, 75)

		local maxValue = 0
		for i = 1, #chartData do
			if (chartData [i] > maxValue) then
				maxValue = chartData[i]
			end
		end
		chartData.max_value = maxValue

		mythicDungeonCharts.Frame.ChartFrame:AddLine(chartData, lineColor, lineName, combatTime, texture, "SMA")
		table.insert(mythicDungeonCharts.PlayerGraphIndex, playerName)
	end

	mythicDungeonCharts.Frame.ChartFrame:RefreshBossTimeline(mythicDungeonCharts.ChartTable.BossDefeated, mythicDungeonCharts.ChartTable.ElapsedTime)

	--generate boss time table
	local bossTimeTable = {}
	for i, bossTable in ipairs(mythicDungeonCharts.ChartTable.BossDefeated) do
		local combatTime = bossTable [3] or math.random(10, 30)

		table.insert(bossTimeTable, bossTable[1])
		table.insert(bossTimeTable, bossTable[1] - combatTime)
	end

	mythicDungeonCharts.Frame.ChartFrame:AddOverlay(bossTimeTable, {1, 1, 1, 0.05}, "Show Boss", "")

	--local phrase = " Average Dps (under development)\npress Escape to hide, Details! Alpha Build." .. _detalhes.build_counter .. "." .. _detalhes.realversion
	local phrase = "Details!: Average Dps for "

	mythicDungeonCharts.Frame.ChartFrame:SetTitle("")
	Details:GetFramework():SetFontSize(mythicDungeonCharts.Frame.ChartFrame.chart_title, 14)

	mythicDungeonCharts.Frame.TitleText:SetText(mythicDungeonCharts.ChartTable.DungeonName and phrase .. mythicDungeonCharts.ChartTable.DungeonName or phrase)

	mythicDungeonCharts.Frame.ShowChartFrame()

	if (verbosemode) then
		mythicDungeonCharts:Debug("mythicDungeonCharts.ShowChart() success")
	end
end

local showID = 0
local HideTooltip = function(ticker)
	if (showID == ticker.ShowID) then
		GameCooltip2:Hide()
		mythicDungeonCharts.Frame.BossWidgetsFrame.GraphPin:Hide()
		mythicDungeonCharts.Frame.BossWidgetsFrame.GraphPinGlow:Hide()
	end
end

local PixelFrameOnEnter = function(self)
	local playerName = self.PlayerName
	--get the percent from the pixel height relative to the chart window
	local dps = self.Height / mythicDungeonCharts.Frame.ChartFrame:GetHeight()
	--multiply the max dps with the percent
	dps = mythicDungeonCharts.Frame.ChartFrame.Graphic.max_value * dps

	mythicDungeonCharts.Frame.BossWidgetsFrame.GraphPin:SetPoint("center", self, "center", 0, 0)
	mythicDungeonCharts.Frame.BossWidgetsFrame.GraphPin:Show()
	mythicDungeonCharts.Frame.BossWidgetsFrame.GraphPinGlow:Show()

	GameCooltip2:Preset(2)
	GameCooltip2:SetOption("FixedWidth", 100)
	GameCooltip2:SetOption("TextSize", 10)
	local onlyName = Details:GetOnlyName(playerName)
	GameCooltip2:AddLine(onlyName)

	local classIcon, L, R, B, T = Details:GetClassIcon(mythicDungeonCharts.ChartTable.Players [playerName] and mythicDungeonCharts.ChartTable.Players [playerName].Class)
	GameCooltip2:AddIcon (classIcon, 1, 1, 16, 16, L, R, B, T)

	GameCooltip2:AddLine(Details:GetCurrentToKFunction()(nil, floor(dps)))

	GameCooltip2:SetOwner(self)
	GameCooltip2:Show()
	showID = showID + 1
end

local PixelFrameOnLeave = function(self)
	local timer = C_Timer.NewTimer(1, HideTooltip)
	timer.ShowID = showID
end

local TAXIROUTE_LINEFACTOR = 128 / 126 -- Multiplying factor for texture coordinates
local TAXIROUTE_LINEFACTOR_2 = TAXIROUTE_LINEFACTOR / 2 -- Half of that

function mythicDungeonCharts:CustomDrawLine (C, sx, sy, ex, ey, w, color, layer, linetexture, graphIndex)
	local relPoint = "BOTTOMLEFT"

	if sx == ex then
		if sy == ey then
			return
		else
			return self:DrawVLine(C, sx, sy, ey, w, color, layer)
		end

	elseif sy == ey then
		return self:DrawHLine(C, sx, ex, sy, w, color, layer)
	end

	if not C.GraphLib_Lines then
		C.GraphLib_Lines = {}
		C.GraphLib_Lines_Used = {}
	end

	local T = tremove(C.GraphLib_Lines) or C:CreateTexture(nil, "ARTWORK")

	if linetexture then --this data series texture
		T:SetTexture(linetexture)

	elseif C.CustomLine then --overall chart texture
		T:SetTexture(C.CustomLine)

	else --no texture assigned, use default
		T:SetTexture(TextureDirectory.."line")
	end

	table.insert(C.GraphLib_Lines_Used, T)

	T:SetDrawLayer(layer or "ARTWORK")

	T:SetVertexColor(color[1], color[2], color[3], color[4])
	-- Determine dimensions and center point of line
	local dx, dy = ex - sx, ey - sy
	local cx, cy = (sx + ex) / 2, (sy + ey) / 2

	-- Normalize direction if necessary
	if (dx < 0) then
		dx, dy = -dx, -dy
	end

	-- Calculate actual length of line
	local l = sqrt((dx * dx) + (dy * dy))

	-- Sin and Cosine of rotation, and combination (for later)
	local s, c = -dy / l, dx / l
	local sc = s * c

	-- Calculate bounding box size and texture coordinates
	local Bwid, Bhgt, BLx, BLy, TLx, TLy, TRx, TRy, BRx, BRy
	if (dy >= 0) then
		Bwid = ((l * c) - (w * s)) * TAXIROUTE_LINEFACTOR_2
		Bhgt = ((w * c) - (l * s)) * TAXIROUTE_LINEFACTOR_2
		BLx, BLy, BRy = (w / l) * sc, s * s, (l / w) * sc
		BRx, TLx, TLy, TRx = 1 - BLy, BLy, 1 - BRy, 1 - BLx
		TRy = BRx
	else
		Bwid = ((l * c) + (w * s)) * TAXIROUTE_LINEFACTOR_2
		Bhgt = ((w * c) + (l * s)) * TAXIROUTE_LINEFACTOR_2
		BLx, BLy, BRx = s * s, -(l / w) * sc, 1 + (w / l) * sc
		BRy, TLx, TLy, TRy = BLx, 1 - BRx, 1 - BLx, 1 - BLy
		TRx = TLy
	end

	-- Thanks Blizzard for adding (-)10000 as a hard-cap and throwing errors!
	-- The cap was added in 3.1.0 and I think it was upped in 3.1.1
	-- (way less chance to get the error)
	if TLx > 10000 then TLx = 10000 elseif TLx < -10000 then TLx = -10000 end
	if TLy > 10000 then TLy = 10000 elseif TLy < -10000 then TLy = -10000 end
	if BLx > 10000 then BLx = 10000 elseif BLx < -10000 then BLx = -10000 end
	if BLy > 10000 then BLy = 10000 elseif BLy < -10000 then BLy = -10000 end
	if TRx > 10000 then TRx = 10000 elseif TRx < -10000 then TRx = -10000 end
	if TRy > 10000 then TRy = 10000 elseif TRy < -10000 then TRy = -10000 end
	if BRx > 10000 then BRx = 10000 elseif BRx < -10000 then BRx = -10000 end
	if BRy > 10000 then BRy = 10000 elseif BRy < -10000 then BRy = -10000 end

	-- Set texture coordinates and anchors
	T:ClearAllPoints()
	T:SetTexCoord(TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy)
	T:SetPoint("BOTTOMLEFT", C, relPoint, cx - Bwid, cy - Bhgt)
	T:SetPoint("TOPRIGHT", C, relPoint, cx + Bwid, cy + Bhgt)
	T:Show()

	local playerName = mythicDungeonCharts.PlayerGraphIndex [graphIndex]
	if (mythicDungeonCharts.Frame.ChartFrame.TextureID % 3 == 0 and playerName) then

		local pixelFrame = tremove(mythicDungeonCharts.Frame.ChartFrame.FrameFree)
		if (not pixelFrame) then
			local newFrame = CreateFrame("frame", nil, mythicDungeonCharts.Frame.ChartFrame, "BackdropTemplate")
			newFrame:SetSize(1, 1)

			--newFrame:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 2, tile = true})
			--newFrame:SetBackdropColor(0, 0, 0, 1)
			newFrame:SetScript("OnEnter", PixelFrameOnEnter)
			newFrame:SetScript("OnLeave", PixelFrameOnLeave)

			pixelFrame = newFrame
		end

		pixelFrame:SetPoint("BOTTOMLEFT", C, relPoint, cx - Bwid, cy - Bhgt)
		pixelFrame:SetPoint("TOPRIGHT", C, relPoint, cx + Bwid, cy + Bhgt)

		table.insert(mythicDungeonCharts.Frame.ChartFrame.FrameInUse, pixelFrame)
		pixelFrame.PlayerName = playerName
		pixelFrame.Height = ey

	end

	mythicDungeonCharts.Frame.ChartFrame.TextureID = mythicDungeonCharts.Frame.ChartFrame.TextureID + 1
	return T
end


mythicDungeonCharts.ClassColors = {
	["HUNTER1"] = { r = 0.67, g = 0.83, b = 0.45, colorStr = "ffabd473" },
	["HUNTER2"] = { r = 0.47, g = 0.63, b = 0.25, colorStr = "ffabd473" },
	["HUNTER3"] = { r = 0.27, g = 0.43, b = 0.05, colorStr = "ffabd473" },

	["WARLOCK1"] = { r = 0.53, g = 0.53, b = 0.93, colorStr = "ff8788ee" },
	["WARLOCK2"] = { r = 0.33, g = 0.33, b = 0.73, colorStr = "ff8788ee" },
	["WARLOCK3"] = { r = 0.13, g = 0.13, b = 0.53, colorStr = "ff8788ee" },

	["PRIEST1"] = { r = 1.0, g = 1.0, b = 1.0, colorStr = "ffffffff" },
	["PRIEST2"] = { r = 0.8, g = 0.8, b = 0.8, colorStr = "ffffffff" },
	["PRIEST3"] = { r = 0.6, g = 0.6, b = 0.6, colorStr = "ffffffff" },

	["PALADIN1"] = { r = 0.96, g = 0.55, b = 0.73, colorStr = "fff58cba" },
	["PALADIN2"] = { r = 0.76, g = 0.35, b = 0.53, colorStr = "fff58cba" },
	["PALADIN3"] = { r = 0.56, g = 0.15, b = 0.33, colorStr = "fff58cba" },

	["MAGE1"] = { r = 0.25, g = 0.78, b = 0.92, colorStr = "ff3fc7eb" },
	["MAGE2"] = { r = 0.05, g = 0.58, b = 0.72, colorStr = "ff3fc7eb" },
	["MAGE3"] = { r = 0.0, g = 0.38, b = 0.52, colorStr = "ff3fc7eb" },

	["ROGUE1"] = { r = 1.0, g = 0.96, b = 0.41, colorStr = "fffff569" },
	["ROGUE2"] = { r = 0.8, g = 0.76, b = 0.21, colorStr = "fffff569" },
	["ROGUE3"] = { r = 0.6, g = 0.56, b = 0.01, colorStr = "fffff569" },

	["DRUID1"] = { r = 1.0, g = 0.49, b = 0.04, colorStr = "ffff7d0a" },
	["DRUID2"] = { r = 0.8, g = 0.29, b = 0.04, colorStr = "ffff7d0a" },
	["DRUID3"] = { r = 0.6, g = 0.09, b = 0.04, colorStr = "ffff7d0a" },

	["SHAMAN1"] = { r = 0.0, g = 0.44, b = 0.87, colorStr = "ff0070de" },
	["SHAMAN2"] = { r = 0.0, g = 0.24, b = 0.67, colorStr = "ff0070de" },
	["SHAMAN3"] = { r = 0.0, g = 0.04, b = 0.47, colorStr = "ff0070de" },

	["WARRIOR1"] = { r = 0.78, g = 0.61, b = 0.43, colorStr = "ffc79c6e" },
	["WARRIOR2"] = { r = 0.58, g = 0.41, b = 0.23, colorStr = "ffc79c6e" },
	["WARRIOR3"] = { r = 0.38, g = 0.21, b = 0.03, colorStr = "ffc79c6e" },

	["DEATHKNIGHT1"] = { r = 0.77, g = 0.12 , b = 0.23, colorStr = "ffc41f3b" },
	["DEATHKNIGHT2"] = { r = 0.57, g = 0.02 , b = 0.03, colorStr = "ffc41f3b" },
	["DEATHKNIGHT3"] = { r = 0.37, g = 0.02 , b = 0.03, colorStr = "ffc41f3b" },

	["MONK1"] = { r = 0.0, g = 1.00 , b = 0.59, colorStr = "ff00ff96" },
	["MONK2"] = { r = 0.0, g = 0.8 , b = 0.39, colorStr = "ff00ff96" },
	["MONK3"] = { r = 0.0, g = 0.6 , b = 0.19, colorStr = "ff00ff96" },

	["DEMONHUNTER1"] = { r = 0.64, g = 0.19, b = 0.79, colorStr = "ffa330c9" },
	["DEMONHUNTER2"] = { r = 0.44, g = 0.09, b = 0.59, colorStr = "ffa330c9" },
	["DEMONHUNTER3"] = { r = 0.24, g = 0.09, b = 0.39, colorStr = "ffa330c9" },

	["EVOKER1"] = { r = 0.0, g = 1.00 , b = 0.59, colorStr = "FF205F45" },
	["EVOKER2"] = { r = 0.0, g = 0.8 , b = 0.39, colorStr = "FF126442" },
	["EVOKER3"] = { r = 0.0, g = 0.6 , b = 0.19, colorStr = "FF274B3C" },
};

if (debugmode) then
	--C_Timer.After(1, mythicDungeonCharts.ShowChart)
end

Details222.MythicPlus = {
	IsMythicPlus = function()
		return C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo() and true or false
	end,
}