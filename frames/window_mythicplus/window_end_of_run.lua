
local Details = _G.Details
local debugmode = false --print debug lines
local verbosemode = false --auto open the chart panel
local addonName, Details222 = ...
local mPlus = Details222.MythicPlusBreakdown
local detailsFramework = DetailsFramework
local _

local CreateFrame = CreateFrame
local UnitExists = UnitExists
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UIParent = UIParent
local PixelUtil = PixelUtil
local C_Timer = C_Timer

local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")

local mythicDungeonCharts = Details222.MythicPlus.Charts.Listener
local mythicDungeonFrames = Details222.MythicPlus.Frames

--debug
_G.MythicDungeonFrames = mythicDungeonFrames
--/run _G.MythicDungeonFrames.ShowEndOfMythicPlusPanel(true)

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
-- /run _G.DetailsMythicDungeonChartHandler.ShowEndOfMythicPlusPanel()

--show a small panel telling the chart is ready to show
function mythicDungeonFrames.ShowEndOfMythicPlusPanel(bIsDebug)
	--check if is enabled
	if (not Details.mythic_plus.show_damage_graphic) then
		return
	end

	if (bIsDebug) then
		Details222.MythicPlus.Level = Details222.MythicPlus.Level or 2
	end

	--create the panel
	if (not mythicDungeonFrames.ReadyFrame) then
		mythicDungeonFrames.ReadyFrame = CreateFrame("frame", "DetailsMythicDungeonReadyFrame", UIParent, "BackdropTemplate")
		local readyFrame = mythicDungeonFrames.ReadyFrame
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
		readyFrame:SetPoint("center", UIParent, "center", 350, 0)
		readyFrame:SetFrameStrata("LOW")
		readyFrame:EnableMouse(true)
		readyFrame:SetMovable(true)
		readyFrame:Hide()

		--register to libwindow
		local LibWindow = LibStub("LibWindow-1.1")
		LibWindow.RegisterConfig(readyFrame, Details.mythic_plus.finished_run_frame)
		LibWindow.RestorePosition(readyFrame)
		LibWindow.MakeDraggable(readyFrame)
		LibWindow.SavePosition(readyFrame)

		--waiting for loot label
		local waitingForLootLabel = DetailsFramework:CreateLabel(readyFrame, "Waiting for loot", 12, "silver")
		waitingForLootLabel:SetPoint("bottom", readyFrame, "bottom", 0, 54)
		waitingForLootLabel:Hide()
		local waitingForLootDotsAnimationLabel = DetailsFramework:CreateLabel(readyFrame, "...", 12, "silver")
		waitingForLootDotsAnimationLabel:SetPoint("left", waitingForLootLabel, "right", 0, 0)
		waitingForLootDotsAnimationLabel:Hide()

		--make a text dot animation, which will show no dots at start and then "." then ".." then "..." and back to "" and so on
		function readyFrame.StartTextDotAnimation()
			--update the Waiting for Loot labels 
			waitingForLootLabel:Show()
			waitingForLootDotsAnimationLabel:Show()

			local dots = waitingForLootDotsAnimationLabel
			local dotsCount = 0
			local maxDots = 3
			local maxLoops = 24

			local dotsTimer = C_Timer.NewTicker(0.5, function()
				dotsCount = dotsCount + 1

				if (dotsCount > maxDots) then
					dotsCount = 0
				end

				local dotsText = ""
				for i = 1, dotsCount do
					dotsText = dotsText .. "."
				end

				dots:SetText(dotsText)
			end, maxLoops)

			waitingForLootDotsAnimationLabel.dotsTimer = dotsTimer
		end

		function readyFrame.StopTextDotAnimation()
			waitingForLootLabel:Hide()
			waitingForLootDotsAnimationLabel:Hide()
			if (waitingForLootDotsAnimationLabel.dotsTimer) then
				waitingForLootDotsAnimationLabel.dotsTimer:Cancel()
			end
		end

		readyFrame:SetScript("OnHide", function(self)
			readyFrame.StopTextDotAnimation()
		end)

		--warning footer
		local warningFooter = DetailsFramework:CreateLabel(readyFrame, "Under development.", 9, "yellow")
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

						readyFrame.StopTextDotAnimation()

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
	end --end of creating of the readyFrame

	--mythic+ finished, showing the readyFrame for the user

	local readyFrame = mythicDungeonFrames.ReadyFrame
	readyFrame:Show()

	readyFrame.StartTextDotAnimation()

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

Details222.MythicPlus.IsMythicPlus = function()
	return C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo() and true or false
end
