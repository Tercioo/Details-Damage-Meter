
local Details = _G.Details
local debugmode = false --print debug lines
local verbosemode = false --auto open the chart panel
local addonName, Details222 = ...
local mPlus = Details222.MythicPlusBreakdown

---@type detailsframework
local detailsFramework = DetailsFramework
local _

local CreateFrame = CreateFrame
local UnitExists = UnitExists
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UIParent = UIParent
local PixelUtil = PixelUtil
local C_Timer = C_Timer
local GameTooltip = GameTooltip

local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")

local mythicDungeonCharts = Details222.MythicPlus.Charts.Listener
local mythicDungeonFrames = Details222.MythicPlus.Frames

local CONST_DEBUG_MODE = false

--debug
_G.MythicDungeonFrames = mythicDungeonFrames
--/run _G.MythicDungeonFrames.ShowEndOfMythicPlusPanel(true)

---@class animatedtexture : texture, df_frameshake
---@field CreateRandomBounceSettings function
---@field BounceFrameShake df_frameshake

---@class playerbanner : frame
---@field FadeInAnimation animationgroup
---@field BackgroundBannerTextureScaleAnimation animationgroup
---@field BackgroundBannerFlashTextureColorAnimation animationgroup
---@field BounceFrameShake df_frameshake
---@field NextLootSquare number
---@field LootSquares details_lootsquare[]
---@field LevelUpFrame frame
---@field LevelUpTextFrame frame
---@field LevelFontString fontstring
---@field DungeonTexture texture
---@field DungeonBorderTexture texture
---@field FlashTexture texture
---@field LootSquare frame
---@field LootIcon texture
---@field LootIconBorder texture
---@field LootItemLevel fontstring
---@field unitId string
---@field unitName string
---@field PlayerNameFontString fontstring
---@field BackgroundBannerTexture animatedtexture
---@field BackgroundBannerFlashTexture animatedtexture
---@field RoleIcon texture
---@field Portrait texture
---@field Border texture
---@field Name fontstring
---@field AnimIn animationgroup
---@field AnimOut animationgroup
---@field ClearLootSquares fun(self:playerbanner)
---@field GetLootSquare fun(self:playerbanner):details_lootsquare

---@class details_lootsquare : frame
---@field LootIcon texture
---@field LootIconBorder texture
---@field LootItemLevel fontstring
---@field itemLink string

local createLootSquare = function(playerBanner, name, parent, lootIndex)
	---@type details_lootsquare
	local lootSquare = CreateFrame("frame", playerBanner:GetName() .. "LootSquare" .. lootIndex, parent)
	lootSquare:SetSize(46, 46)
	lootSquare:SetFrameLevel(parent:GetFrameLevel()+1)
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
	detailsFramework:SetFontSize(lootItemLevel, 12)
	lootSquare.LootItemLevel = lootItemLevel

	return lootSquare
end

local createPlayerBanner = function(parent, name)
    local template = "ChallengeModeBannerPartyMemberTemplate"

	---@type playerbanner
    local playerBanner = CreateFrame("frame", name, parent, template)
	playerBanner:SetAlpha(1)
	playerBanner:EnableMouse(true)
	playerBanner:SetFrameLevel(parent:GetFrameLevel()+2)

	--make an fade in animation
	local fadeInAnimation = detailsFramework:CreateAnimationHub(playerBanner, function() playerBanner:Show() end, function() playerBanner:SetAlpha(1) end)
	detailsFramework:CreateAnimation(fadeInAnimation, "Alpha", 1, 0.1, 0, 1)
	playerBanner.FadeInAnimation = fadeInAnimation

	--there's already a role icon on .RoleIcon, created from the template

    local playerNameFontString = playerBanner:CreateFontString("$parentPlayerNameText", "overlay", "GameFontNormal")
    playerNameFontString:SetTextColor(1, 1, 1)
    playerNameFontString:SetPoint("top", playerBanner, "bottom", -1, -7)
    detailsFramework:SetFontSize(playerNameFontString, 12)
	playerBanner.PlayerNameFontString = playerNameFontString

	local playerNameBackgroundTexture = playerBanner:CreateTexture("$parentPlayerNameBackgroundTexture", "overlay", nil, 6)
	playerNameBackgroundTexture:SetTexture([[Interface\Cooldown\LoC-ShadowBG]])
	playerNameBackgroundTexture:SetSize(68, 12)
	playerNameBackgroundTexture:SetPoint("center", playerNameFontString, "center", 0, 0)

	local createPlayerBannerBackgroundTexture = function(playerBanner, color, drawLevel)
		local backgroundBannerTexture = playerBanner:CreateTexture("$parentBannerTexture", "background", nil, 0)
		---@cast backgroundBannerTexture animatedtexture
		backgroundBannerTexture:SetTexture([[Interface\ACHIEVEMENTFRAME\GuildTabard]])
		backgroundBannerTexture:SetDrawLayer("background", drawLevel or 0)
		backgroundBannerTexture:SetSize(63, 129)
		backgroundBannerTexture:SetTexCoord(5/128, 68/128, 123/256, 252/256)
		backgroundBannerTexture:SetPoint("topleft", playerBanner, "bottomleft", -5, playerBanner:GetHeight()/2)
		backgroundBannerTexture:SetPoint("topright", playerBanner, "bottomright", 4, playerBanner:GetHeight()/2)
		local r, g, b = detailsFramework:ParseColors(color or "dark1")
		backgroundBannerTexture:SetVertexColor(r, g, b)
		return backgroundBannerTexture
	end

	do
		playerBanner.BackgroundBannerFlashTexture = createPlayerBannerBackgroundTexture(playerBanner, "white", -1)
		--create a color animation for playerBanner.BackgroundBannerFlashTexture, the color start as white and goes to dark1
		--the start delay for this animation is 0.2
		local backgroundBannerFlashTextureColorAnimation = detailsFramework:CreateAnimationHub(playerBanner.BackgroundBannerFlashTexture, function() end, function() playerBanner.BackgroundBannerFlashTexture:SetVertexColor(0.1, 0.1, 0.1) end)
		local colorAnim = detailsFramework:CreateAnimation(backgroundBannerFlashTextureColorAnimation, "VertexColor", 1, 0.2, "white", "dark1")
		colorAnim:SetStartDelay(0.175)
		playerBanner.BackgroundBannerFlashTextureColorAnimation = backgroundBannerFlashTextureColorAnimation
	end

	do
		playerBanner.BackgroundBannerTexture = createPlayerBannerBackgroundTexture(playerBanner)

		function playerBanner.BackgroundBannerTexture:CreateRandomBounceSettings()
			local duration = RandomFloatInRange(0.78, 0.82)
			local amplitude = RandomFloatInRange(4.50, 5.5)
			local frequency = RandomFloatInRange(19.8, 20.8)
			local absoluteSineX = false
			local absoluteSineY = true
			local scaleX = 0
			local scaleY = RandomFloatInRange(0.90, 1.1)
			local fadeInTime = 0
			local fadeOutTime = RandomFloatInRange(0.7, 0.8)

			return duration, amplitude, frequency, absoluteSineX, absoluteSineY, scaleX, scaleY, fadeInTime, fadeOutTime
		end

		local lossOfMomentum = 0.75
		local duration = 0.8
		local amplitude = 5
		local frequency = 20
		local absoluteSineX = false
		local absoluteSineY = true
		local scaleX = 0
		local scaleY = 1
		local fadeInTime = 0
		local fadeOutTime = lossOfMomentum
		local backgroundBannerTextureFS2 = detailsFramework:CreateFrameShake(playerBanner.BackgroundBannerTexture, duration, amplitude, frequency, absoluteSineX, absoluteSineY, scaleX, scaleY, fadeInTime, fadeOutTime)
		playerBanner.BackgroundBannerTexture.BounceFrameShake = backgroundBannerTextureFS2

		--scale animation for backgroundBannerTexture, which starts at 1 x 0 y and goes to 1 x 1 y, anchor top
		local backgroundBannerTextureScaleAnimation = detailsFramework:CreateAnimationHub(playerBanner.BackgroundBannerTexture, function() end, function() playerBanner.BackgroundBannerTexture:SetSize(63, 129) end)
		detailsFramework:CreateAnimation(backgroundBannerTextureScaleAnimation, "Scale", 1, 0.25, 1, 0, 1, 1, "top", 0, 0)
		playerBanner.BackgroundBannerTextureScaleAnimation = backgroundBannerTextureScaleAnimation
	end

	local backgroundBannerBorderTexture = playerBanner:CreateTexture("$parentBannerBorderTexture", "highlight", nil, -1)
	backgroundBannerBorderTexture:SetAtlas("UI-Achievement-Guild-Flag-Outline")
	backgroundBannerBorderTexture:SetSize(63, 129)
	backgroundBannerBorderTexture:SetPoint("topleft", playerBanner, "bottomleft", -5, playerBanner:GetHeight()/2)
	backgroundBannerBorderTexture:SetPoint("topright", playerBanner, "bottomright", 4, playerBanner:GetHeight()/2)

    local dungeonTexture = playerBanner:CreateTexture("$parentDungeonTexture", "artwork")
    dungeonTexture:SetTexCoord(25/512, 360/512, 50/512, 290/512)
    dungeonTexture:SetSize(50, 39)
    dungeonTexture:SetPoint("top", playerBanner,"bottom", 0, -16)
    dungeonTexture:SetAlpha(0.9934)
	playerBanner.DungeonTexture = dungeonTexture

    local dungeonBorderTexture = playerBanner:CreateTexture("$parentDungeonBorder", "border")
    dungeonBorderTexture:SetTexture([[Interface\BUTTONS\UI-EmptySlot]])
    dungeonBorderTexture:SetDrawLayer("border", 0)
    dungeonBorderTexture:ClearAllPoints()
    dungeonBorderTexture:SetPoint("topleft", dungeonTexture,"topleft", -17, 15)
    dungeonBorderTexture:SetPoint("bottomright", dungeonTexture,"bottomright", 18, -15)
    dungeonBorderTexture:SetAlpha(1)
	playerBanner.DungeonBorderTexture = dungeonBorderTexture

	--load this addon, required to have access to the garrison templates
	if (not C_AddOns.IsAddOnLoaded("Blizzard_GarrisonTemplates")) then
		C_AddOns.LoadAddOn("Blizzard_GarrisonTemplates")
	end

	--animation for the key leveling up
	local levelUpFrame = CreateFrame("frame", "$LevelUpFrame", playerBanner, "GarrisonFollowerLevelUpTemplate")
	levelUpFrame:SetPoint("top", dungeonTexture, "bottom", 0, 44)
	levelUpFrame:SetScale(0.9)
	levelUpFrame.Text:SetText("")
	playerBanner.LevelUpFrame = levelUpFrame
	levelUpFrame:SetFrameLevel(playerBanner:GetFrameLevel()+1)

	local levelUpTextFrame = CreateFrame("frame", "$LevelUpTextFrame", playerBanner)
	levelUpTextFrame:SetPoint("top", dungeonTexture, "bottom", -1, -14)
	levelUpTextFrame:SetFrameLevel(playerBanner:GetFrameLevel()+2)
	levelUpTextFrame:SetSize(1, 1)
	playerBanner.LevelUpTextFrame = levelUpTextFrame
																										--scaleX, scaleY, fadeInTime, fadeOutTime
	local shakeAnimation = detailsFramework:CreateFrameShake(levelUpTextFrame, 0.8, 2, 200, false, false, 0, 1, 0.5, 0.15)
	local shakeAnimation2 = detailsFramework:CreateFrameShake(levelUpTextFrame, 0.5, 1, 200, false, false, 0, 1, 0, 0)

    local levelFontString = levelUpTextFrame:CreateFontString("$parentLVLText", "artwork", "GameFontNormal")
    levelFontString:SetTextColor(1, 1, 1)
    levelFontString:SetPoint("center", levelUpTextFrame, "center", 0, 0)
    detailsFramework:SetFontSize(levelFontString, 20)
	levelFontString:SetText("")
	playerBanner.LevelFontString = levelFontString

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
			playerBanner.LevelUpFrame:Show()
			playerBanner.LevelUpFrame:SetAlpha(1)
			playerBanner.LevelUpFrame.Anim:Play()
			animationGroup:Play()
		end)

		C_Timer.After(0.7 + 0.5, function()
			levelFontString:SetText(newLevel or "")
		end)

		C_Timer.After(1.65, function()
			levelUpTextFrame:PlayFrameShake(shakeAnimation2)
		end)
	end

	local flashTexture = playerBanner:CreateTexture("$parentFlashTexture", "overlay", nil, 6)
	flashTexture:SetAtlas("UI-Achievement-Guild-Flag-Outline")
	flashTexture:SetSize(63, 129)
	flashTexture:SetPoint("topleft", playerBanner, "bottomleft", -5, playerBanner:GetHeight()/2)
	flashTexture:SetPoint("topright", playerBanner, "bottomright", 4, playerBanner:GetHeight()/2)
	flashTexture:Hide()
	playerBanner.FlashTexture = flashTexture

	detailsFramework:CreateFlashAnimation(flashTexture)
	--flashTexture:Flash(0.1, 0.5, 0.01)

	playerBanner.LootSquares = {}

	local lootSquareAmount = 2

	for i = 1, lootSquareAmount do
		local lootSquare = createLootSquare(playerBanner, name, parent, i)
		if (i == 1) then
			lootSquare:SetPoint("top", playerBanner, "bottom", 0, -90)
		else
			lootSquare:SetPoint("top", playerBanner.LootSquares[i-1], "bottom", 0, -2)
		end
		playerBanner.LootSquares[i] = lootSquare
		playerBanner["lootSquare" .. i] = lootSquare
	end

	function playerBanner:ClearLootSquares()
		playerBanner.NextLootSquare = 1

		for _, lootSquare in ipairs(self.LootSquares) do
			lootSquare:Hide()
			lootSquare.itemLink = nil
			lootSquare.LootIcon:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
			lootSquare.LootItemLevel:SetText("")
		end
	end

	function playerBanner:GetLootSquare()
		local lootSquareIdx = playerBanner.NextLootSquare
		playerBanner.NextLootSquare = lootSquareIdx + 1
		local lootSquare = playerBanner.LootSquares[lootSquareIdx]
		lootSquare:Show()
		return lootSquare
	end

	return playerBanner
end

local updatPlayerBanner = function(unitId, bannerIndex)
	if (CONST_DEBUG_MODE) then
		--print("updating player banner for unit:", unitId, "bannerIndex:", bannerIndex)
		if (not UnitExists(unitId)) then
			unitId = "player"
		end
	end

	if (UnitExists(unitId)) then
		local readyFrame = DetailsMythicDungeonReadyFrame
		local unitName = Details:GetFullName(unitId)
		local libOpenRaid = LibStub("LibOpenRaid-1.0", true)

		---@type playerbanner
		local playerBanner = readyFrame.PlayerBanners[bannerIndex]
		readyFrame.playerCacheByName[unitName] = playerBanner
		playerBanner.unitId = unitId
		playerBanner.unitName = unitName
		playerBanner:Show()

		playerBanner.FadeInAnimation:Play()
		playerBanner.BackgroundBannerTextureScaleAnimation:Play()
		playerBanner.BackgroundBannerFlashTextureColorAnimation:Play()

		playerBanner.BackgroundBannerTexture:SetFrameShakeSettings(playerBanner.BackgroundBannerTexture.BounceFrameShake, playerBanner.BackgroundBannerTexture:CreateRandomBounceSettings())
		playerBanner.BackgroundBannerTexture:PlayFrameShake(playerBanner.BackgroundBannerTexture.BounceFrameShake)

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
							--unitBanner.FlashTexture:Flash()
							--print("keystone upgraded for", Details:GetFullName(unitId), unitKeystoneInfo.level, "old was:", oldKeystoneLevel)
							--C_Timer.After(0.1, function() unitBanner.FlashTexture:Stop() end)
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

if (CONST_DEBUG_MODE) then
	C_Timer.After(3, function()
		C_AddOns.LoadAddOn("Blizzard_ChallengesUI");
		_G.MythicDungeonFrames.ShowEndOfMythicPlusPanel()
	end)
end

--show a small panel telling the chart is ready to show
function mythicDungeonFrames.ShowEndOfMythicPlusPanel()
	--check if is enabled
	if (not Details.mythic_plus.show_damage_graphic) then
		return
	end

	if (CONST_DEBUG_MODE) then
		Details222.MythicPlus.Level = Details222.MythicPlus.Level or 2
	end

	--create the panel if it doesn't exist
	if (not mythicDungeonFrames.ReadyFrame) then
		local textColor = {1, 0.8196, 0, 1}
		local textSize = 11

		mythicDungeonFrames.ReadyFrame = CreateFrame("frame", "DetailsMythicDungeonReadyFrame", UIParent, "BackdropTemplate")
		local readyFrame = mythicDungeonFrames.ReadyFrame
		readyFrame:SetSize(355, 390)
		readyFrame:SetPoint("center", UIParent, "center", 350, 0)
		readyFrame:SetFrameStrata("LOW")
		readyFrame:EnableMouse(true)
		readyFrame:SetMovable(true)
		readyFrame:Hide()

		---@type playerbanner[]
		readyFrame.playerCacheByName = {}

		do
			--register to libwindow
			local LibWindow = LibStub("LibWindow-1.1")
			LibWindow.RegisterConfig(readyFrame, Details.mythic_plus.finished_run_frame)
			LibWindow.RestorePosition(readyFrame)
			LibWindow.MakeDraggable(readyFrame)
			LibWindow.SavePosition(readyFrame)

			--set to use rounded corner
			local roundedCornerTemplate = {
				roundness = 6,
				color = {.1, .1, .1, 0.5},
				--border_color = {.05, .05, .05, 0.834},
			}
			detailsFramework:AddRoundedCornersToFrame(readyFrame, roundedCornerTemplate)
		end

		readyFrame.entryAnimationDuration = 0.1

		--this frame is required due to the animation, the readyFrame and the contentFrame has their own animations
		mythicDungeonFrames.ReadyFrameTop = CreateFrame("frame", "DetailsMythicDungeonReadyTopFrame", UIParent, "BackdropTemplate")
		mythicDungeonFrames.ReadyFrameTop:SetPoint("bottomleft", readyFrame, "topleft", 0, 0)
		mythicDungeonFrames.ReadyFrameTop:SetPoint("bottomright", readyFrame, "topright", 0, 0)
		mythicDungeonFrames.ReadyFrameTop:SetHeight(1)
		readyFrame.TopFrame = mythicDungeonFrames.ReadyFrameTop

		local openingAnimationHub = detailsFramework:CreateAnimationHub(readyFrame, function() end, function() readyFrame:SetWidth(355); end)
		detailsFramework:CreateAnimation(openingAnimationHub, "Scale", 1, readyFrame.entryAnimationDuration, 0, 1, 1, 1, "center", 0, 0)
		readyFrame.OpeningAnimation = openingAnimationHub

		do --backdrop textures
			local maskTexture = readyFrame:CreateMaskTexture("$parentDungeonBackdropTextureMaskTexture", "artwork")
			maskTexture:SetTexture([[Interface\AddOns\Details\images\masks\white_rounded_512x512.png]])
			maskTexture:SetPoint("topleft", readyFrame, "topleft", 0, 0)
			maskTexture:SetPoint("bottomright", readyFrame, "bottomright", 0, 0)

			--backdrop gradient from bottom to top
			---@type df_gradienttable
			local gradientTable = {gradient = "vertical", fromColor = {0, 0, 0, 0.8}, toColor = "transparent"}
			local gradientBelowTheLine = detailsFramework:CreateTexture(readyFrame, gradientTable, 1, readyFrame:GetHeight()/3, "artwork", {0, 1, 0, 1}, "backgroundGradient")
			gradientBelowTheLine:SetPoint("bottoms", 0, 0)
			gradientBelowTheLine:AddMaskTexture(maskTexture)

			local dungeonBackdropTexture = readyFrame:CreateTexture("$parentDungeonBackdropTexture", "artwork", nil, -2)
			dungeonBackdropTexture:SetTexCoord(0.05, 0.70, 0.1, 0.82)
			dungeonBackdropTexture:SetVertexColor(0.2, 0.2, 0.2, 0.8)
			dungeonBackdropTexture:SetDesaturation(0.65)
			dungeonBackdropTexture:SetAlpha(0.834)
			dungeonBackdropTexture:SetAllPoints()
			dungeonBackdropTexture:AddMaskTexture(maskTexture)
			readyFrame.DungeonBackdropTexture = dungeonBackdropTexture

			local anotherBackdropTexture = readyFrame:CreateTexture("$parentAnotherBackdropTexture", "artwork", nil, -3)
			anotherBackdropTexture:SetTexture([[Interface\GLUES\Models\UI_HighmountainTauren\7HM_RapidSimpleMask]])
			anotherBackdropTexture:AddMaskTexture(maskTexture)
			anotherBackdropTexture:SetAllPoints()
			anotherBackdropTexture:SetVertexColor(0.467, 0.416, 0.639, 1)
			readyFrame.AnotherBackdropTexture = anotherBackdropTexture
		end

		--frame to place all texture that goes behind the readyFrame
		local backgroundFrame = CreateFrame("frame", "DetailsMythicDungeonBackgroundFrame", readyFrame)
		backgroundFrame:SetAllPoints()
		backgroundFrame:SetFrameLevel(readyFrame:GetFrameLevel()-1)
		readyFrame.BackgroundFrame = backgroundFrame

		--frame to place all texture that goes in front of the readyFrame, doing this, we call fade in this frame making all texts gently show up
		local contentFrame = CreateFrame("frame", "$parentContentFrame", readyFrame)
		readyFrame.ContentFrame = contentFrame
		--animation to fade in the content frame
		local contentFrameFadeInAnimation = detailsFramework:CreateAnimationHub(contentFrame, function() contentFrame:Show() end, function() contentFrame:SetAlpha(1) end)
		detailsFramework:CreateAnimation(contentFrameFadeInAnimation, "Alpha", 1, 0.3, 0, 1)
		readyFrame.ContentFrameFadeInAnimation = contentFrameFadeInAnimation

		do
			--use the same textures from the original end of dungeon panel
			local spikes = mythicDungeonFrames.ReadyFrameTop:CreateTexture("$parentSkullCircle", "overlay")
			spikes:SetSize(100, 100)
			spikes:SetPoint("center", readyFrame, "top", 0, 30)
			spikes:SetAtlas("ChallengeMode-SpikeyStar")
			spikes:SetAlpha(1)
			spikes:SetIgnoreParentAlpha(true)
			readyFrame.YellowSpikeCircle = spikes

			local yellowFlash = mythicDungeonFrames.ReadyFrameTop:CreateTexture("$parentYellowFlash", "artwork")
			yellowFlash:SetSize(120, 120)
			yellowFlash:SetPoint("center", readyFrame, "top", 0, 30)
			yellowFlash:SetAtlas("BossBanner-RedFlash")
			yellowFlash:SetAlpha(0)
			yellowFlash:SetBlendMode("ADD")
			yellowFlash:SetIgnoreParentAlpha(true)
			readyFrame.YellowFlash = yellowFlash

			readyFrame.Level = mythicDungeonFrames.ReadyFrameTop:CreateFontString("$parentLevelText", "overlay", "GameFontNormalWTF2Outline")
			readyFrame.Level:SetPoint("center", readyFrame.YellowSpikeCircle, "center", 0, 0)
			readyFrame.Level:SetText("")

			--create the animation for the yellow flash
			local flashAnimHub = detailsFramework:CreateAnimationHub(yellowFlash, function() yellowFlash:SetAlpha(0) end, function() yellowFlash:SetAlpha(0) end)
			local flashAnim1 = detailsFramework:CreateAnimation(flashAnimHub, "Alpha", 1, 0.5, 0, 1)
			local flashAnim2 = detailsFramework:CreateAnimation(flashAnimHub, "Alpha", 2, 0.5, 1, 0)

			--create the animation for the yellow spike circle
			local spikeCircleAnimHub = detailsFramework:CreateAnimationHub(spikes, function() spikes:SetAlpha(0); spikes:SetScale(1) end, function() flashAnimHub:Play(); spikes:SetSize(100, 100); spikes:SetScale(1); spikes:SetAlpha(1) end)
			local alphaAnim1 = detailsFramework:CreateAnimation(spikeCircleAnimHub, "Alpha", 1, 0.2960000038147, 0, 1)
			local scaleAnim1 = detailsFramework:CreateAnimation(spikeCircleAnimHub, "Scale", 1, 0.21599999070168, 5, 5, 1, 1, "center", 0, 0)

			readyFrame.YellowSpikeCircle.OnShowAnimation = spikeCircleAnimHub
		end

		readyFrame.leftFiligree = contentFrame:CreateTexture("$parentLeftFiligree", "artwork")
		readyFrame.leftFiligree:SetAtlas("BossBanner-LeftFillagree")
		readyFrame.leftFiligree:SetSize(72, 43)
		readyFrame.leftFiligree:SetPoint("bottom", readyFrame, "top", -50, 2)

		readyFrame.rightFiligree = contentFrame:CreateTexture("$parentRightFiligree", "artwork")
		readyFrame.rightFiligree:SetAtlas("BossBanner-RightFillagree")
		readyFrame.rightFiligree:SetSize(72, 43)
		readyFrame.rightFiligree:SetPoint("bottom", readyFrame, "top", 50, 2)

		--create the bottom filligree using BossBanner-BottomFillagree atlas
		readyFrame.bottomFiligree = contentFrame:CreateTexture("$parentBottomFiligree", "artwork")
		readyFrame.bottomFiligree:SetAtlas("BossBanner-BottomFillagree")
		readyFrame.bottomFiligree:SetSize(66, 28)
		readyFrame.bottomFiligree:SetPoint("bottom", readyFrame, "bottom", 0, -19)

		local titleLabel = detailsFramework:CreateLabel(contentFrame, "Details! Mythic Run Completed!", 12, "yellow")
		titleLabel:SetPoint("top", readyFrame, "top", 0, -7)
		titleLabel.textcolor = textColor

		---@type df_closebutton
		local closeButton = detailsFramework:CreateCloseButton(contentFrame, "$parentCloseButton")
		closeButton:SetPoint("topright", readyFrame, "topright", -2, -2)
		closeButton:SetScale(1.4)
		closeButton:SetAlpha(0.823)
		closeButton:SetScript("OnClick", function(self)
			readyFrame:Hide()
		end)

		--warning footer
		local warningFooter = detailsFramework:CreateLabel(contentFrame, "Under development", 9, "orange")
		warningFooter:SetPoint("bottomright", readyFrame, "bottomright", -5, 5)
		warningFooter:SetAlpha(0.5)

		--waiting for loot label
		local waitingForLootLabel = detailsFramework:CreateLabel(contentFrame, "Waiting for loot", 12, "silver")
		waitingForLootLabel:SetPoint("bottom", readyFrame, "bottom", 0, 54)
		waitingForLootLabel:Hide()
		local waitingForLootDotsAnimationLabel = detailsFramework:CreateLabel(contentFrame, "...", 12, "silver")
		waitingForLootDotsAnimationLabel:SetPoint("left", waitingForLootLabel, "right", 0, 0)
		waitingForLootDotsAnimationLabel:Hide()

		---@type texture
		local topRedLineTexture = backgroundFrame:CreateTexture("$parentBannerTop", "border")
		topRedLineTexture:SetAtlas("BossBanner-BgBanner-Top")
		topRedLineTexture:SetPoint("top", backgroundFrame, "top", 0, 34)
		local topTextureAnimGroup = detailsFramework:CreateAnimationHub(topRedLineTexture, function()end, function() topRedLineTexture:SetSize(388, 112) end)
		topRedLineTexture.Animation = topTextureAnimGroup
		local animDuration = 0.3
		detailsFramework:CreateAnimation(topTextureAnimGroup, "Scale", 1, animDuration, 0, 1, 1, 1, "center", 0, 0)
		readyFrame.TopRedLineTexture = topRedLineTexture

		local bottomRedLineTexture = backgroundFrame:CreateTexture("$parentBannerBottom", "border")
		bottomRedLineTexture:SetAtlas("BossBanner-BgBanner-Bottom")
		bottomRedLineTexture:SetPoint("bottom", backgroundFrame, "bottom", 0, -25)
		local bottomTextureAnimGroup = detailsFramework:CreateAnimationHub(bottomRedLineTexture, function()end, function() bottomRedLineTexture:SetSize(388, 112) end)
		bottomRedLineTexture.Animation = bottomTextureAnimGroup
		detailsFramework:CreateAnimation(bottomTextureAnimGroup, "Scale", 1, animDuration, 0, 1, 0.5, 1, "center", 0, 0)
		readyFrame.BottomRedLineTexture = bottomRedLineTexture

		--local leftRedLineTexture = backgroundFrame:CreateTexture("$parentBannerLeft", "border")
		--leftRedLineTexture:SetAtlas("BossBanner-BgBanner-Top")
		--leftRedLineTexture:SetPoint("topleft", backgroundFrame, "topleft", 0, 0)
		--leftRedLineTexture:SetPoint("bottomleft", backgroundFrame, "bottomleft", 0, 0)
		--leftRedLineTexture:SetWidth(388)
		--leftRedLineTexture:SetRotation(-1.5708)

		--local centerGradient = backgroundFrame:CreateTexture("$parentCenterGradient", "artwork")
		--centerGradient:SetAtlas("BossBanner-BgBanner-Mid")
		--centerGradient:SetPoint("center", backgroundFrame, "center", 0, 0)
		--centerGradient:SetSize(355, 390)


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
			mythicDungeonFrames.ReadyFrameTop:Hide()
		end)

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
		readyFrame.ShowBreakdownButton = detailsFramework:CreateButton(contentFrame, showBreakdownFunc, 145, 30, "Show Breakdown")
		PixelUtil.SetPoint(readyFrame.ShowBreakdownButton, "topleft", readyFrame, "topleft", 31, -30)
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
		readyFrame.ShowChartButton = detailsFramework:CreateButton(contentFrame, showChartFunc, 145, 30, "Show Damage Graphic")
		PixelUtil.SetPoint(readyFrame.ShowChartButton, "left", readyFrame.ShowBreakdownButton, "right", 6, 0)
		PixelUtil.SetSize(readyFrame.ShowChartButton, 145, 32)
		readyFrame.ShowChartButton:SetBackdrop(nil)
		readyFrame.ShowChartButton:SetIcon([[Interface\AddOns\Details\images\icons2.png]], 16, 16, "overlay", {42/512, 75/512, 153/512, 187/512}, {.7, .7, .7, 1}, nil, 0, 0)
		readyFrame.ShowChartButton.textcolor = textColor
        detailsFramework:AddRoundedCornersToFrame(readyFrame.ShowChartButton.widget, roundedCornerPreset)

		--disable feature check box (dont show this again)
		local on_switch_enable = function(self, _, value)
			Details.mythic_plus.show_damage_graphic = not value
		end

		local elapsedTimeLabel = detailsFramework:CreateLabel(contentFrame, "Run Time:", textSize, textColor)
		--elapsedTimeLabel:SetPoint("topleft", leftAnchor, "bottomleft", 0, -8)
		elapsedTimeLabel:SetPoint("topleft", readyFrame, "topleft", 5, -70)
		local elapsedTimeAmount = detailsFramework:CreateLabel(contentFrame, "00:00", textSize, textColor)
		elapsedTimeAmount:SetPoint("left", elapsedTimeLabel, "left", 130, 0)

		local timeNotInCombatLabel = detailsFramework:CreateLabel(contentFrame, "Time not in combat:", textSize, "orangered")
		timeNotInCombatLabel:SetPoint("topleft", elapsedTimeLabel, "bottomleft", 0, -5)
		local timeNotInCombatAmount = detailsFramework:CreateLabel(contentFrame, "00:00", textSize, "orangered")
		timeNotInCombatAmount:SetPoint("left", timeNotInCombatLabel, "left", 130, 0)

		local youBeatTheTimerLabel = detailsFramework:CreateLabel(contentFrame, "", textSize, "white")
		youBeatTheTimerLabel:SetPoint("topleft", timeNotInCombatLabel, "bottomleft", 0, -5)

		--local keystoneUpgradeLabel = detailsFramework:CreateLabel(readyFrame, "Keystone Upgrade:", textSize, "white")
		--keystoneUpgradeLabel:SetPoint("topleft", youBeatTheTimerLabel, "bottomleft", 0, -5)

		local rantingLabel = detailsFramework:CreateLabel(contentFrame, "", textSize, textColor)
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

					local effectiveILvl, nop, baseItemLevel = GetDetailedItemLevelInfo(itemLink)

					local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
					itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
					expacID, setID, isCraftingReagent = GetItemInfo(itemLink)

					--print("equip loc:", itemEquipLoc)
					--unitBanner:ClearLootSquares()
					if (effectiveILvl > 300 and baseItemLevel > 5) then --avoid showing loot that isn't items
						local lootSquare = unitBanner:GetLootSquare()
						lootSquare.itemLink = itemLink --will error if this the thrid lootSquare (creates only 2 per banner)

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

		local notAgainSwitch, notAgainLabel = detailsFramework:CreateSwitch(contentFrame, on_switch_enable, not Details.mythic_plus.show_damage_graphic, _, _, _, _, _, _, _, _, _, Loc ["STRING_MINITUTORIAL_BOOKMARK4"], detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"), "GameFontHighlightLeft")
		notAgainLabel.textcolor = "orange"
		notAgainSwitch:ClearAllPoints()
		notAgainLabel:SetPoint("left", notAgainSwitch, "right", 2, 0)
		notAgainSwitch:SetPoint("bottomleft", readyFrame, "bottomleft", 5, 5)
		notAgainSwitch:SetAsCheckBox()
		notAgainSwitch:SetSize(12, 12)
		notAgainSwitch:SetAlpha(0.5)
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

	readyFrame.TopFrame:Show()
	readyFrame.YellowSpikeCircle.OnShowAnimation:Play()

	readyFrame.TopRedLineTexture:Hide()
	readyFrame.BottomRedLineTexture:Hide()
	readyFrame.ContentFrame:SetAlpha(0)

	readyFrame.Level:SetText(Details222.MythicPlus.Level or "")

	--hide the lootSquare
	for i = 1, #readyFrame.PlayerBanners do
		readyFrame.PlayerBanners[i]:ClearLootSquares()
	end

	for i = 1, #readyFrame.PlayerBanners do
		readyFrame.PlayerBanners[i]:Hide()
	end

	C_Timer.After(0, function()
		readyFrame.OpeningAnimation:Play()
	end)

	C_Timer.After(readyFrame.entryAnimationDuration+0.05, function()
		readyFrame.TopRedLineTexture:Show()
		readyFrame.BottomRedLineTexture:Show()
		readyFrame.TopRedLineTexture.Animation:Play()
		readyFrame.BottomRedLineTexture.Animation:Play()

		C_Timer.After(0.3, function()
			readyFrame.ContentFrameFadeInAnimation:Play()
		end)
	end)

	readyFrame.StartTextDotAnimation()

	--/run PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_KEYSTONE_UPGRADE);
	--PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_COMPLETE_NO_UPGRADE);

	--fin the overall mythic dungeon combat, starting with the current combat
	---@type combat
	local overallMythicDungeonCombat = Details:GetCurrentCombat()

	--if the latest segment isn't the overall mythic dungeon segment, then find it
	if (overallMythicDungeonCombat:GetCombatType() ~= DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
		--get a table with all segments
		local segmentsTable = Details:GetCombatSegments()
		for i = 1, #segmentsTable do
			local segment = segmentsTable[i]
			if (segment:GetCombatType() == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
				overallMythicDungeonCombat = segment
				break
			end
		end
	end

	--update the run time and time not in combat
	local elapsedTime = Details222.MythicPlus.time or 1507
	readyFrame.ElapsedTimeAmountLabel.text = detailsFramework:IntegerToTimer(elapsedTime)

	if (overallMythicDungeonCombat:GetCombatType() == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
		local combatTime = overallMythicDungeonCombat:GetCombatTime()
		local notInCombat = elapsedTime - combatTime
		readyFrame.TimeNotInCombatAmountLabel.text = detailsFramework:IntegerToTimer(notInCombat) .. " (" .. math.floor(notInCombat / elapsedTime * 100) .. "%)"
	else
		readyFrame.TimeNotInCombatAmountLabel.text = "Unknown for this run"
	end

	local mythicDungeonInfo = overallMythicDungeonCombat:GetMythicDungeonInfo()

	if (not mythicDungeonInfo) then
		return
	end

	---@type details_instanceinfo
	local instanceInfo = Details:GetInstanceInfo(mythicDungeonInfo.MapID) or Details:GetInstanceInfo(Details:GetCurrentCombat().mapId)

	if (instanceInfo) then
		readyFrame.DungeonBackdropTexture:SetTexture(instanceInfo.iconLore)
	else
		readyFrame.DungeonBackdropTexture:SetTexture(overallMythicDungeonCombat.is_mythic_dungeon.DungeonTexture)
	end

	wipe(readyFrame.playerCacheByName)

	if (Details222.MythicPlus.OnTime) then
		readyFrame.YouBeatTheTimerLabel:SetFormattedText(CHALLENGE_MODE_COMPLETE_BEAT_TIMER .. " | " .. CHALLENGE_MODE_COMPLETE_KEYSTONE_UPGRADED, Details222.MythicPlus.KeystoneUpgradeLevels) --"You beat the timer!"
		readyFrame.YouBeatTheTimerLabel.textcolor = "limegreen"
		--readyFrame.KeystoneUpgradeLabel:SetFormattedText(CHALLENGE_MODE_COMPLETE_KEYSTONE_UPGRADED, Details222.MythicPlus.KeystoneUpgradeLevels)
		PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_KEYSTONE_UPGRADE)
		C_Timer.After(0.020, function()
			--PlaySoundFile([[Interface\AddOns\Details\sounds\bassdrop2.mp3]])
		end)
	else
		readyFrame.YouBeatTheTimerLabel.textcolor = "white"
		readyFrame.YouBeatTheTimerLabel.text = CHALLENGE_MODE_COMPLETE_TIME_EXPIRED --"Time expired!"
		--readyFrame.KeystoneUpgradeLabel.text = CHALLENGE_MODE_COMPLETE_TRY_AGAIN --"Try again! Beat the timer to upgrade your keystone!"
		PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_COMPLETE_NO_UPGRADE)
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

	C_Timer.After(0.6, function()
		local playersFound = 0
		local playerBannerIndex = 1
		do --update the player banner
			C_Timer.After(RandomFloatInRange(0.1, 0.15), function()
				if (updatPlayerBanner("player", playerBannerIndex)) then
					playersFound = playersFound + 1
				end
			end)
		end

		local unitCount = 1
		for bannerIndex = 2, #readyFrame.PlayerBanners do
			C_Timer.After(RandomFloatInRange(bannerIndex/5-0.075, bannerIndex/5+0.075), function()
				if (updatPlayerBanner("party"..unitCount, bannerIndex)) then
					playersFound = playersFound + 1
				end
				unitCount = unitCount + 1
			end)
		end
	end)

	C_Timer.After(2.5, updateKeysStoneLevel)
end

Details222.MythicPlus.IsMythicPlus = function()
	return C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo() and true or false
end
