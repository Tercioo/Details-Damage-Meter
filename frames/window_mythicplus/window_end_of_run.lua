
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
local SOUNDKIT = SOUNDKIT
local C_EventUtils = C_EventUtils
local C_AddOns = C_AddOns

local GetItemInfo = GetItemInfo or C_Item.GetItemInfo
local GetItemIcon = GetItemIcon or C_Item.GetItemIcon
local GetDetailedItemLevelInfo = GetDetailedItemLevelInfo or C_Item.GetDetailedItemLevelInfo --C_Item.GetDetailedItemLevelInfo does not return a table

local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")

local mythicDungeonCharts = Details222.MythicPlus.Charts.Listener
local mythicDungeonFrames = Details222.MythicPlus.Frames

local CONST_DEBUG_MODE = false
local LOOT_DEBUG_MODE = false

local readyFrameName = "DetailsMythicDungeonFinishedRunFrame"

--fallback if the class color isn't found
local defaultColor = {r = 0.9, g = 0.9, b = 0.9}

local playerBannerSettings = {
	background_width = 286,
	background_height = 64,
	playername_background_width = 68,
	playername_background_height = 12,
	playername_fontsize = 12,
	playername_fontcolor = {1, 1, 1},
	dungeon_texture_width = 45,
	dungeon_texture_height = 45,
	loot_square_width = 32,
	loot_square_height = 32,
	loot_square_amount = 2,
	trans_anim_duration = 0.5, --time that the translation animation takes to move the banner from right to left
}


function Details222.Debug.SetMythicPlusDebugState(bState)
	if (bState == nil) then
		bState = not CONST_DEBUG_MODE
	end
	CONST_DEBUG_MODE = bState
	Details:Msg("mythic+ debug mode:", tostring(CONST_DEBUG_MODE))
end

---@return boolean CONST_DEBUG_MODE, boolean LOOT_DEBUG_MODE
function Details222.Debug.GetMythicPlusDebugState()
	return CONST_DEBUG_MODE, LOOT_DEBUG_MODE
end

function Details222.Debug.SetMythicPlusLootDebugState(bState)
	if (bState == nil) then
		bState = not LOOT_DEBUG_MODE
	end
	LOOT_DEBUG_MODE = bState
	Details:Msg("mythic+ loot debug mode:", tostring(LOOT_DEBUG_MODE))
end

--debug
_G.MythicDungeonFrames = mythicDungeonFrames
--/run _G.MythicDungeonFrames.ShowEndOfMythicPlusPanel()

---@class animatedtexture : texture, df_frameshake
---@field CreateRandomBounceSettings function
---@field BounceFrameShake df_frameshake

---@class playerbanner : frame
---@field index number
---@field BackgroundBannerMaskTexture texture
---@field BackgroundBannerGradient texture
---@field FadeInAnimation animationgroup
---@field BackgroundShowAnim animationgroup
---@field DungeonBackdropShowAnim animationgroup
---@field BackgroundGradientAnim animationgroup
---@field BackgroundBannerFlashTextureColorAnimation animationgroup
---@field BounceFrameShake df_frameshake
---@field NextLootSquare number
---@field LootSquares details_lootsquare[]
---@field LevelUpFrame frame
---@field LevelUpTextFrame frame
---@field WaitingForLootLabel df_label
---@field RantingLabel df_label
---@field LevelFontString fontstring
---@field KeyStoneDungeonTexture texture
---@field DungeonBorderTexture texture
---@field FlashTexture texture
---@field LootSquare frame
---@field LootIcon texture
---@field LootIconBorder texture
---@field LootItemLevel fontstring
---@field unitId string
---@field unitName string
---@field PlayerNameFontString fontstring
---@field PlayerNameBackgroundTexture texture
---@field DungeonBackdropTexture texture
---@field BackgroundBannerTexture animatedtexture
---@field BackgroundBannerFlashTexture animatedtexture
---@field RoleIcon texture
---@field Portrait texture
---@field Border texture
---@field Name fontstring
---@field AnimIn animationgroup
---@field AnimOut animationgroup
---@field StartTextDotAnimation fun(self:playerbanner)
---@field StopTextDotAnimation fun(self:playerbanner)
---@field ClearLootSquares fun(self:playerbanner)
---@field GetLootSquare fun(self:playerbanner):details_lootsquare

---@class details_lootsquare : frame
---@field LootIcon texture
---@field LootIconBorder texture
---@field LootItemLevel fontstring
---@field LootItemLevelBackgroundTexture texture
---@field itemLink string
---@field ShadowTexture texture

---@class details_loot_cache : table
---@field playerName string
---@field itemLink string
---@field effectiveILvl number
---@field itemQuality number
---@field itemID number
---@field time number

---@class lootframe : frame
---@field LootCache details_loot_cache[]

---@class details_mplus_endframe : frame
---@field unitCacheByName playerbanner[]
---@field entryAnimationDuration number
---@field AutoCloseTimeBar df_timebar
---@field OpeningAnimation animationgroup
---@field HeaderFadeInAnimation animationgroup
---@field HeaderTexture texture
---@field TopFrame frame
---@field ContentFrame frame
---@field ContentFrameFadeInAnimation animationgroup
---@field YellowSpikeCircle texture
---@field YellowFlash texture
---@field Level fontstring
---@field leftFiligree texture
---@field rightFiligree texture
---@field bottomFiligree texture
---@field CloseButton df_closebutton
---@field ConfigButton df_button
---@field ShowBreakdownButton df_button
---@field ShowChartButton df_button
---@field PlayerBanners playerbanner[]
---@field YouBeatTheTimerLabel fontstring
---@field RantingLabel df_label
---@field ElapsedTimeIcon texture
---@field ElapsedTimeText fontstring
---@field OutOfCombatIcon texture
---@field OutOfCombatText fontstring
---@field SandTimeIcon texture
---@field KeylevelText fontstring
---@field StrongArmIcon texture


--frame to handle loot events
local lootFrame = CreateFrame("frame", "DetailsEndOfMythicLootFrame", UIParent)
lootFrame:RegisterEvent("BOSS_KILL")

if (C_EventUtils.IsEventValid("ENCOUNTER_LOOT_RECEIVED")) then
	lootFrame:RegisterEvent("ENCOUNTER_LOOT_RECEIVED")
end

--register the loot players looted at the end of the mythic dungeon
lootFrame.LootCache = {}

--currently being called after a updatPlayerBanner()
function lootFrame.UpdateUnitLoot(playerBanner)
	---@cast playerBanner playerbanner
	local unitId = playerBanner.unitId
	local unitName = playerBanner.unitName

	local timeNow = GetTime()
	local lootCache = lootFrame.LootCache[unitName]
	if (not lootCache) then
		return
	end

	---@type details_loot_cache[]
	local lootCandidates = {}

	if (LOOT_DEBUG_MODE) then
		if (UnitIsUnit("player", unitId)) then
			Details:Msg("Loot UpdateUnitLoot:", unitName, GetTime())
		end
	end

	if (#lootCache > 0) then
		playerBanner:StopTextDotAnimation()
	end

	if (lootCache) then
		local lootCacheSize = #lootCache
		if (lootCacheSize > 0) then
			local lootIndex = 1
			for i = lootCacheSize, 1, -1 do
				---@type details_loot_cache
				local lootInfo = lootCache[i]
				if (timeNow - lootInfo.time < 10) then
					lootCandidates[lootIndex] = lootInfo
					lootIndex = lootIndex + 1
				end
				table.remove(lootCache, i)

				if (LOOT_DEBUG_MODE) then
					if (UnitIsUnit("player", unitId)) then
						Details:Msg("Loot ENTRY REMOVED:", unitName, GetTime())
					end
				end
			end
		end
	end

	for i = 1, #lootCandidates do
		local lootInfo = lootCandidates[i]
		local itemLink = lootInfo.itemLink
		local effectiveILvl = lootInfo.effectiveILvl
		local itemQuality = lootInfo.itemQuality
		local itemID = lootInfo.itemID

		local lootSquare = playerBanner:GetLootSquare() --internally controls the loot square index
		lootSquare.itemLink = itemLink --will error if this the thrid lootSquare (creates only 2 per banner)

		local rarityColor = --[[GLOBAL]] ITEM_QUALITY_COLORS[itemQuality]
		lootSquare.LootIcon:SetTexture(C_Item.GetItemIconByID(itemID))
		lootSquare.LootIconBorder:SetVertexColor(rarityColor.r, rarityColor.g, rarityColor.b, 1)
		lootSquare.LootItemLevel:SetText(effectiveILvl or "0")

		--update size
		lootSquare.LootIcon:SetSize(playerBannerSettings.loot_square_width, playerBannerSettings.loot_square_height)
		lootSquare.LootIconBorder:SetSize(playerBannerSettings.loot_square_width, playerBannerSettings.loot_square_height)

		lootSquare:Show()

		if (LOOT_DEBUG_MODE) then
			if (UnitIsUnit("player", unitId)) then
				Details:Msg("Loot DISPLAYED:", unitName, GetTime())
			end
		end
	end
end

--debug data to test encounter loot received event:
--/run _G.DetailsEndOfMythicLootFrame:OnEvent("ENCOUNTER_LOOT_RECEIVED", 1, 207788, "|cffa335ee|Hitem:207788::::::::60:264::16:5:7208:6652:1501:5858:6646:1:28:1279:::|h[Shadowgrasp Totem]|h|r", 1, "Fera", "EVOKER")

lootFrame:SetScript("OnEvent", function(self, event, ...)
	if (event == "BOSS_KILL") then
		local encounterID, name = ...;

	elseif (event == "ENCOUNTER_LOOT_RECEIVED") then
		local lootEncounterId, itemID, itemLink, quantity, unitName, className = ...

		unitName = Ambiguate(unitName, "none")

		local _, instanceType = GetInstanceInfo()
		if (instanceType == "party" or CONST_DEBUG_MODE) then
			local effectiveILvl, nop, baseItemLevel = GetDetailedItemLevelInfo(itemLink)

			local bIsAccountBound = C_Item.IsItemBindToAccountUntilEquip(itemLink)

			local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
			itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
			expacID, setID, isCraftingReagent = GetItemInfo(itemLink)

			if (mythicDungeonFrames.ReadyFrame and mythicDungeonFrames.ReadyFrame:IsVisible()) then
				local unitBanner = mythicDungeonFrames.ReadyFrame.unitCacheByName[unitName]
				if (unitBanner) then
					unitBanner:StopTextDotAnimation()
				end
			end

			if (Details.debug) then
				Details222.DebugMsg("Loot Received:", unitName, itemLink, effectiveILvl, itemQuality, baseItemLevel, "itemType:", itemType, "itemSubType:", itemSubType, "itemEquipLoc:", itemEquipLoc)
			end

			if (effectiveILvl > 480 and baseItemLevel > 5 and not bIsAccountBound) then --avoid showing loot that isn't items
				lootFrame.LootCache[unitName] = lootFrame.LootCache[unitName] or {}
				---@type details_loot_cache
				local lootCacheTable = {
					playerName = unitName,
					itemLink = itemLink,
					effectiveILvl = effectiveILvl,
					itemQuality = itemQuality, --this is a number
					itemID = itemID,
					time = GetTime()
				}
				table.insert(lootFrame.LootCache[unitName], lootCacheTable)

				if (LOOT_DEBUG_MODE) then
					Details:Msg("Loot ADDED:", unitName, itemLink, effectiveILvl, itemQuality, baseItemLevel)
				end

				--check if the end of mythic plus frame is opened and call a function to update the loot frame of the player
				if (mythicDungeonFrames.ReadyFrame and mythicDungeonFrames.ReadyFrame:IsVisible()) then
					C_Timer.After(1.5, function()
						local unitBanner = mythicDungeonFrames.ReadyFrame.unitCacheByName[unitName]
						if (unitBanner) then
							lootFrame.UpdateUnitLoot(unitBanner)
						end
					end)
				end
			else
				if (LOOT_DEBUG_MODE) then
					Details:Msg("Loot SKIPPED:", unitName, itemLink, effectiveILvl, itemQuality, baseItemLevel, bIsAccountBound)
				end
			end
		end
	end
end)

---@param playerBanner playerbanner
---@param name string
---@param parent frame
---@param lootIndex number
local createLootSquare = function(playerBanner, name, parent, lootIndex)
	---@type details_lootsquare
	local lootSquare = CreateFrame("frame", playerBanner:GetName() .. "LootSquare" .. lootIndex, parent)
	lootSquare:SetSize(46, 46)
	lootSquare:SetFrameLevel(parent:GetFrameLevel()+10)
	lootSquare:Hide()

	lootSquare:SetScript("OnEnter", function(self)
		if (self.itemLink) then
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			GameTooltip:SetHyperlink(lootSquare.itemLink)
			GameTooltip:Show()

			self:SetScript("OnUpdate", function()
				if (IsShiftKeyDown()) then
					GameTooltip_ShowCompareItem()
				else
					GameTooltip_HideShoppingTooltips(GameTooltip)
				end
			end)
		end
	end)

	lootSquare:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		self:SetScript("OnUpdate", nil)
	end)

	local shadowTexture = playerBanner:CreateTexture("$parentShadowTexture", "artwork")
	shadowTexture:SetTexture([[Interface\AddOns\Details\images\end_of_mplus_banner_mask.png]])
	shadowTexture:SetTexCoord(441/512, 511/512, 81/512, 151/512)
	shadowTexture:SetSize(32, 32)
	shadowTexture:SetVertexColor(0.05, 0.05, 0.05, 0.6)
	shadowTexture:SetPoint("center", lootSquare, "center", 0, 0)
	lootSquare.ShadowTexture = shadowTexture

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
	lootItemLevel:SetPoint("bottom", lootSquare, "bottom", 0, -4)
	lootItemLevel:SetTextColor(1, 1, 1)
	detailsFramework:SetFontSize(lootItemLevel, 11)
	lootSquare.LootItemLevel = lootItemLevel

	local lootItemLevelBackgroundTexture = lootSquare:CreateTexture("$parentItemLevelBackgroundTexture", "artwork", nil, 6)
	lootItemLevelBackgroundTexture:SetTexture([[Interface\Cooldown\LoC-ShadowBG]])
	lootItemLevelBackgroundTexture:SetPoint("bottomleft", lootSquare, "bottomleft", -7, -3)
	lootItemLevelBackgroundTexture:SetPoint("bottomright", lootSquare, "bottomright", 7, -15)
	lootItemLevelBackgroundTexture:SetHeight(10)
	lootSquare.LootItemLevelBackgroundTexture = lootItemLevelBackgroundTexture

	return lootSquare
end

local createPlayerBanner = function(parent, name, index)
	if (not C_AddOns.IsAddOnLoaded("Blizzard_ChallengesUI")) then
		C_AddOns.LoadAddOn("Blizzard_ChallengesUI")
	end

	--this template is from Blizzard_ChallengesUI.xml
    local template = "ChallengeModeBannerPartyMemberTemplate"

	---@type playerbanner
    local playerBanner = CreateFrame("frame", name, parent, template)
	playerBanner.index = index
	playerBanner:SetAlpha(1)
	playerBanner:EnableMouse(true)
	playerBanner:SetFrameLevel(parent:GetFrameLevel()+2)
	--size is set on the template

	--make an fade in animation
	local fadeInAnimation = detailsFramework:CreateAnimationHub(playerBanner, function() playerBanner:Show() end, function() playerBanner:SetAlpha(1) end)
	detailsFramework:CreateAnimation(fadeInAnimation, "Alpha", 1, 0.2, 0, 1)
	playerBanner.FadeInAnimation = fadeInAnimation

	--there's already a role icon on .RoleIcon, created from the template

    local playerNameFontString = playerBanner:CreateFontString("$parentPlayerNameText", "overlay", "GameFontNormal")
    playerNameFontString:SetTextColor(unpack(playerBannerSettings.playername_fontcolor))
    playerNameFontString:SetPoint("bottom", playerBanner, "bottom", 0, 0)
    detailsFramework:SetFontSize(playerNameFontString, playerBannerSettings.playername_fontsize)
	playerBanner.PlayerNameFontString = playerNameFontString

	local playerNameBackgroundTexture = playerBanner:CreateTexture("$parentPlayerNameBackgroundTexture", "overlay", nil, 6)
	playerNameBackgroundTexture:SetTexture([[Interface\Cooldown\LoC-ShadowBG]])
	playerNameBackgroundTexture:SetSize(playerBannerSettings.playername_background_width, playerBannerSettings.playername_background_height)
	playerNameBackgroundTexture:SetPoint("center", playerNameFontString, "center", 0, 0)
	playerBanner.PlayerNameBackgroundTexture = playerNameBackgroundTexture

	local createPlayerBannerBackgroundTexture = function(playerBanner)
		---@cast playerBanner playerbanner
		local backgroundBannerTexture = playerBanner:CreateTexture("$parentBannerTexture", "background", nil, -1)
		---@cast backgroundBannerTexture animatedtexture
		backgroundBannerTexture:SetTexture([[Interface\AddOns\Details\images\end_of_mplus_banner_mask.png]])
		backgroundBannerTexture:SetSize(playerBannerSettings.background_width, playerBannerSettings.background_height)
		backgroundBannerTexture:SetPoint("topright", playerBanner, "topleft", playerBanner:GetHeight()/2, 0)
		backgroundBannerTexture:SetPoint("bottomright", playerBanner, "bottomleft", playerBanner:GetHeight()/2, 0)
		local r, g, b = detailsFramework:ParseColors("dark1")
		backgroundBannerTexture:SetVertexColor(r, g, b)
		backgroundBannerTexture:SetAlpha(0.95)

		--backdrop gradient from bottom to top
		local maskTexture = playerBanner:CreateMaskTexture("$parentBackgroundBannerMaskTexture", "artwork")
		maskTexture:SetTexture([[Interface\AddOns\Details\images\end_of_mplus_banner_mask.png]])
		maskTexture:SetPoint("topright", backgroundBannerTexture, "topright", 0, 0)
		maskTexture:SetSize(backgroundBannerTexture:GetSize())
		playerBanner.BackgroundBannerMaskTexture = maskTexture

		---@type df_gradienttable
		local gradientTable = {gradient = "vertical", fromColor = {0.01, 0.01, 0.01, 0.5}, toColor = "transparent"}
		local gradientBelowTheLine = detailsFramework:CreateTexture(playerBanner, gradientTable, 1, 64, "background", {0, 1, 0, 1}, "BackgroundGradient", "$parentBackgroundGradient")
		gradientBelowTheLine:SetDrawLayer("background", 1)
		gradientBelowTheLine:SetPoint("bottomleft", backgroundBannerTexture, "bottomleft", 0, 0)
		gradientBelowTheLine:SetPoint("bottomright", backgroundBannerTexture, "bottomright", 0, 0)
		gradientBelowTheLine:AddMaskTexture(maskTexture)
		playerBanner.BackgroundBannerGradient = gradientBelowTheLine

		local dungeonBackdropTexture = playerBanner:CreateTexture("$parentDungeonBackdropTexture", "background", nil, 0)
		dungeonBackdropTexture:SetVertexColor(0.2, 0.2, 0.2, 0.8)
		dungeonBackdropTexture:SetDesaturation(0.5)
		dungeonBackdropTexture:SetAlpha(0.5)
		dungeonBackdropTexture:SetHeight(61)
		dungeonBackdropTexture:SetPoint("bottomleft", backgroundBannerTexture, "bottomleft", 0, 0)
		dungeonBackdropTexture:SetPoint("bottomright", backgroundBannerTexture, "bottomright", 0, 0)
		--image height = 244 = 48 pixels
		local topStart = 49 --pixel start for the lorebg image
		local pixelsPerImage = 48
		local topCoord = (topStart + ((playerBanner.index - 1) * pixelsPerImage)) / 512
		local bottomCoord = (topStart + (playerBanner.index * pixelsPerImage)) / 512
		dungeonBackdropTexture:SetTexCoord(35/512, 291/512, topCoord, bottomCoord)
		dungeonBackdropTexture:AddMaskTexture(maskTexture)
		playerBanner.DungeonBackdropTexture = dungeonBackdropTexture

		return backgroundBannerTexture
	end

	do
		---@type animatedtexture
		local bannerFlash = playerBanner:CreateTexture("$parentBannerTexture", "background", nil, 0)
		bannerFlash:SetAlpha(0)
		bannerFlash:SetTexture([[Interface\AddOns\Details\images\end_of_mplus_banner_mask.png]])
		bannerFlash:SetSize(playerBannerSettings.background_width, playerBannerSettings.background_height)
		bannerFlash:SetPoint("topright", playerBanner, "topleft", playerBanner:GetHeight()/2, 0)
		bannerFlash:SetPoint("bottomright", playerBanner, "bottomleft", playerBanner:GetHeight()/2, 0)
		playerBanner.BackgroundBannerFlashTexture = bannerFlash

		--create a color animation for playerBanner.BackgroundBannerFlashTexture, the color start as white and goes to dark1
		--the start delay for this animation is 0.2
		local backgroundBannerFlashTextureColorAnimation = detailsFramework:CreateAnimationHub(playerBanner.BackgroundBannerFlashTexture, function() end, function() playerBanner.BackgroundBannerFlashTexture:SetVertexColor(0.1, 0.1, 0.1, 0) end)
		local alpha1 = detailsFramework:CreateAnimation(backgroundBannerFlashTextureColorAnimation, "Alpha", 1, 0.1, 0, 0.3)
		local alpha2 = detailsFramework:CreateAnimation(backgroundBannerFlashTextureColorAnimation, "Alpha", 2, 0.1, 0.6, 0)
		local scale1 = detailsFramework:CreateAnimation(backgroundBannerFlashTextureColorAnimation, "Scale", 1, 0.1, 1, 0, 1, 1, "TOP")
		alpha2:SetStartDelay(0.075)
		playerBanner.BackgroundBannerFlashTextureColorAnimation = backgroundBannerFlashTextureColorAnimation
	end

	do
		playerBanner.BackgroundBannerTexture = createPlayerBannerBackgroundTexture(playerBanner)

		function playerBanner.BackgroundBannerTexture:CreateRandomBounceSettings()
			local duration = RandomFloatInRange(0.78 + (playerBanner.index/10), 0.82 + (playerBanner.index/10))
			local amplitude = RandomFloatInRange(4.50, 5.5)
			local frequency = RandomFloatInRange(19.8, 20.8)
			local absoluteSineX = false
			local absoluteSineY = false
			local scaleX = RandomFloatInRange(0.90, 1.1)
			local scaleY = 0
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
		local fadeInTime = 0.5
		local fadeOutTime = lossOfMomentum
		local backgroundBannerTextureFS2 = detailsFramework:CreateFrameShake(playerBanner.BackgroundBannerTexture, duration, amplitude, frequency, absoluteSineX, absoluteSineY, scaleX, scaleY, fadeInTime, fadeOutTime)
		playerBanner.BackgroundBannerTexture.BounceFrameShake = backgroundBannerTextureFS2

		local onPlayAnim = function(self)
			if (Details.mythic_plus.finished_run_frame_options.grow_direction == "left") then
				self.ScaleAnim:SetOrigin("RIGHT", 0, 0)

			elseif (Details.mythic_plus.finished_run_frame_options.grow_direction == "right") then
				self.ScaleAnim:SetOrigin("LEFT", 0, 0)
			end
		end

		playerBannerSettings.trans_anim_duration = 0.5

		local backgroundShowAnim = detailsFramework:CreateAnimationHub(playerBanner.BackgroundBannerTexture, onPlayAnim, function() playerBanner.BackgroundBannerTexture:SetSize(playerBannerSettings.background_width, playerBannerSettings.background_height) end)
		backgroundShowAnim.ScaleAnim = detailsFramework:CreateAnimation(backgroundShowAnim, "Scale", 1, playerBannerSettings.trans_anim_duration, 0, 1, 1, 1, "RIGHT")
		playerBanner.BackgroundShowAnim = backgroundShowAnim

		local dungeonBackdropTextureAnim = detailsFramework:CreateAnimationHub(playerBanner.DungeonBackdropTexture, onPlayAnim, function() playerBanner.DungeonBackdropTexture:SetSize(playerBannerSettings.background_width, 61) end)
		dungeonBackdropTextureAnim.ScaleAnim = detailsFramework:CreateAnimation(dungeonBackdropTextureAnim, "Scale", 1, playerBannerSettings.trans_anim_duration, 0, 1, 1, 1, "RIGHT")
		dungeonBackdropTextureAnim.AlphaAnim = detailsFramework:CreateAnimation(dungeonBackdropTextureAnim, "Alpha", 1, playerBannerSettings.trans_anim_duration+0.1, 0, playerBanner.DungeonBackdropTexture:GetAlpha())
		playerBanner.DungeonBackdropShowAnim = dungeonBackdropTextureAnim

		--create the same animations for the texture playerBanner.BackgroundGradient
		local backgroundGradientAnim = detailsFramework:CreateAnimationHub(playerBanner.BackgroundBannerGradient, onPlayAnim, function() playerBanner.BackgroundBannerGradient:SetSize(playerBannerSettings.background_width, playerBannerSettings.background_height) end)
		backgroundGradientAnim.ScaleAnim = detailsFramework:CreateAnimation(backgroundGradientAnim, "Scale", 1, playerBannerSettings.trans_anim_duration, 0, 1, 1, 1, "RIGHT")
		backgroundGradientAnim.ScaleAnim:SetStartDelay(0.05)
		playerBanner.BackgroundGradientAnim = backgroundGradientAnim
	end

    local keyStoneDungeonTexture = playerBanner:CreateTexture("$parentDungeonTexture", "artwork")
    keyStoneDungeonTexture:SetTexCoord(36/512, 375/512, 50/512, 290/512)
    keyStoneDungeonTexture:SetSize(playerBannerSettings.dungeon_texture_width, playerBannerSettings.dungeon_texture_height)
    keyStoneDungeonTexture:SetPoint("right", playerBanner,"left", -16, 0)
    keyStoneDungeonTexture:SetAlpha(0.9934)
	detailsFramework:SetMask(keyStoneDungeonTexture, [[Interface\FrameGeneral\UIFrameIconMask]])
	playerBanner.KeyStoneDungeonTexture = keyStoneDungeonTexture

    local dungeonBorderTexture = playerBanner:CreateTexture("$parentDungeonBorder", "border")
    dungeonBorderTexture:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
	dungeonBorderTexture:SetTexCoord(441/512, 511/512, 81/512, 151/512)
    dungeonBorderTexture:SetDrawLayer("border", 0)
    dungeonBorderTexture:ClearAllPoints()
	dungeonBorderTexture:SetSize(playerBannerSettings.dungeon_texture_width+2, playerBannerSettings.dungeon_texture_height+2)
	dungeonBorderTexture:SetPoint("center", keyStoneDungeonTexture, "center", 0, 0)
    dungeonBorderTexture:SetAlpha(1)
	dungeonBorderTexture:SetVertexColor(0, 0, 0)
	playerBanner.DungeonBorderTexture = dungeonBorderTexture

	--load this addon, required to have access to the garrison templates
	if (not C_AddOns.IsAddOnLoaded("Blizzard_GarrisonTemplates")) then
		C_AddOns.LoadAddOn("Blizzard_GarrisonTemplates")
	end

	if (not C_AddOns.IsAddOnLoaded("Blizzard_ChallengesUI")) then
		C_AddOns.LoadAddOn("Blizzard_ChallengesUI")
	end

	--animation for the key leveling up
	local levelUpFrame = CreateFrame("frame", "$LevelUpFrame", playerBanner, "GarrisonFollowerLevelUpTemplate")
	levelUpFrame:SetPoint("top", keyStoneDungeonTexture, "bottom", 0, 44)
	levelUpFrame:SetScale(0.9)
	levelUpFrame.Text:SetText("")
	playerBanner.LevelUpFrame = levelUpFrame
	levelUpFrame:SetFrameLevel(playerBanner:GetFrameLevel()+1)

	local levelUpTextFrame = CreateFrame("frame", "$LevelUpTextFrame", playerBanner)
	levelUpTextFrame:SetPoint("top", keyStoneDungeonTexture, "bottom", -1, 0)
	levelUpTextFrame:SetFrameLevel(playerBanner:GetFrameLevel()+2)
	levelUpTextFrame:SetSize(1, 1)
	playerBanner.LevelUpTextFrame = levelUpTextFrame
																										--scaleX, scaleY, fadeInTime, fadeOutTime
	local shakeAnimation = detailsFramework:CreateFrameShake(levelUpTextFrame, 0.8, 2, 200, false, false, 0, 1, 0.5, 0.15)
	local shakeAnimation2 = detailsFramework:CreateFrameShake(levelUpTextFrame, 0.5, 1, 200, false, false, 0, 1, 0, 0)

    local levelFontString = levelUpTextFrame:CreateFontString("$parentLVLText", "artwork", "GameFontNormal")
    levelFontString:SetPoint("bottom", keyStoneDungeonTexture, "bottom", 0, -4)
    levelFontString:SetTextColor(1, 1, 1)
    detailsFramework:SetFontSize(levelFontString, 15)
	levelFontString:SetText("")
	playerBanner.LevelFontString = levelFontString

	local levelFontStringBackgroundTexture = levelUpTextFrame:CreateTexture("$parentItemLevelBackgroundTexture", "artwork", nil, 6)
	levelFontStringBackgroundTexture:SetTexture([[Interface\Cooldown\LoC-ShadowBG]])
	levelFontStringBackgroundTexture:SetPoint("bottomleft", keyStoneDungeonTexture, "bottomleft", -10, -3)
	levelFontStringBackgroundTexture:SetPoint("bottomright", keyStoneDungeonTexture, "bottomright", 10, -15)
	levelFontStringBackgroundTexture:SetHeight(12)
	levelUpTextFrame.LevelFontStringBackgroundTexture = levelFontStringBackgroundTexture

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

	local rantingLabel = detailsFramework:CreateLabel(playerBanner, "", 14, "green")
	rantingLabel:SetPoint("right", playerBanner, "left", -144, 0)
	playerBanner.RantingLabel = rantingLabel

	local waitingForLootDotsAnimationLabel = detailsFramework:CreateLabel(playerBanner, "...", 20, "silver") --~dots
	waitingForLootDotsAnimationLabel:SetDrawLayer("overlay", 6)
	waitingForLootDotsAnimationLabel:SetAlpha(0.5)
	waitingForLootDotsAnimationLabel:SetPoint("right", keyStoneDungeonTexture, "left", -12, 0)
	waitingForLootDotsAnimationLabel:Hide()
	playerBanner.WaitingForLootLabel = waitingForLootDotsAnimationLabel

	--make a text dot animation, which will show no dots at start and then "." then ".." then "..." and back to "" and so on
	function playerBanner:StartTextDotAnimation()
		--update the Waiting for Loot labels
		local dotsString = self.WaitingForLootLabel
		dotsString:Show()

		local dotsCount = 0
		local maxDots = 3
		local maxLoops = 200

		local dotsTimer = C_Timer.NewTicker(0.5+RandomFloatInRange(-0.003, 0.003), function()
			dotsCount = dotsCount + 1

			if (dotsCount > maxDots) then
				dotsCount = 0
			end

			local dotsText = ""
			for i = 1, dotsCount do
				dotsText = dotsText .. "."
			end

			dotsString:SetText(dotsText)
		end, maxLoops)

		dotsString.dotsTimer = dotsTimer
	end

	function playerBanner:StopTextDotAnimation()
		local dotsString = self.WaitingForLootLabel
		dotsString:Hide()
		if (dotsString.dotsTimer) then
			dotsString.dotsTimer:Cancel()
		end
	end

	playerBanner.LootSquares = {}

	for i = 1, playerBannerSettings.loot_square_amount do
		local lootSquare = createLootSquare(playerBanner, name, parent, i)
		if (i == 1) then
			lootSquare:SetPoint("right", playerBanner, "left", -90, 0)
		else
			lootSquare:SetPoint("right", playerBanner.LootSquares[i-1], "left", -2, 0)
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

--changes the orientation of the player banners to horizontal or vertical, following the current settings
---@param readyFrame details_mplus_endframe
local setOrientation = function(readyFrame, mythicDungeonInfo, overallMythicDungeonCombat)
	local settingsTable = Details.mythic_plus.finished_run_frame_options
	local orientation = settingsTable.orientation
	local growDirection = settingsTable.grow_direction

	readyFrame:SetFrameStrata("FULLSCREEN")

	---@type details_instanceinfo
	local instanceInfo = Details:GetInstanceInfo(mythicDungeonInfo.MapID) or Details:GetInstanceInfo(Details:GetCurrentCombat().mapId)

	if (orientation == "horizontal") then
		readyFrame:SetSize(256, 350)

		if (growDirection == "left") then
			--when the grow direction if to the left, the readyFrame is anchored to the right side of the ui parent
			--header texture
			readyFrame.HeaderTexture:ClearAllPoints()
			readyFrame.HeaderTexture:SetPoint("topright", readyFrame, "topright", -7, 0)
			readyFrame.HeaderTexture:SetTexCoord(257/512, 1, 234/512, 298/512)
			readyFrame.HeaderTexture:SetSize(296, 64)

			readyFrame.AutoCloseTimeBar:SetSize(readyFrame.HeaderTexture:GetWidth(), 25)
			readyFrame.AutoCloseTimeBar:ClearAllPoints()
			readyFrame.AutoCloseTimeBar:SetPoint("topright", readyFrame.HeaderTexture, "topright", 0, -22)
			readyFrame.AutoCloseTimeBar:SetTimer(Details.mythic_plus.autoclose_time, true)
			readyFrame.AutoCloseTimeBar:SetColor(1, 0.7, 0.0, 0.9)
			readyFrame.AutoCloseTimeBar:SetDirection("left")
			readyFrame.AutoCloseTimeBar:SetFrameLevel(readyFrame:GetFrameLevel()+1)
			readyFrame.AutoCloseTimeBar:ShowSpark(false)
			readyFrame.AutoCloseTimeBar:SetAlpha(0.7)
			readyFrame.AutoCloseTimeBar:ShowTimer(false)

			local buttonSize = 14

			readyFrame.ElapsedTimeIcon:ClearAllPoints()
			readyFrame.OutOfCombatIcon:ClearAllPoints()
			readyFrame.ElapsedTimeIcon:SetSize(buttonSize, buttonSize)
			readyFrame.OutOfCombatIcon:SetSize(buttonSize, buttonSize)
			readyFrame.ElapsedTimeIcon:SetPoint("topleft", readyFrame.HeaderTexture, "topleft", 51, -5)
			readyFrame.OutOfCombatIcon:SetPoint("left", readyFrame.ElapsedTimeIcon, "right", 45, 0)

			readyFrame.ShowChartButton:ClearAllPoints()
			PixelUtil.SetPoint(readyFrame.ShowChartButton, "right", readyFrame.ElapsedTimeIcon, "left", -3, 0)
			PixelUtil.SetSize(readyFrame.ShowChartButton, 50, 32)

			readyFrame.SandTimeIcon:ClearAllPoints()
			readyFrame.SandTimeIcon:SetSize(buttonSize, buttonSize) --original size is 32x60, need to adjust to the correct size
			readyFrame.SandTimeIcon:SetPoint("left", readyFrame.OutOfCombatIcon, "right", 40, 0)

			readyFrame.StrongArmIcon:ClearAllPoints()
			readyFrame.StrongArmIcon:SetSize(buttonSize, buttonSize)
			readyFrame.StrongArmIcon:SetPoint("left", readyFrame.SandTimeIcon, "right", 18, 0)

			readyFrame.CloseButton:ClearAllPoints()
			readyFrame.CloseButton:SetPoint("topright", readyFrame.HeaderTexture, "topright", -5, -5)

			readyFrame.ConfigButton:ClearAllPoints()
			readyFrame.ConfigButton:SetPoint("right", readyFrame.CloseButton, "left", -3, 0)
			readyFrame.ConfigButton.widget:GetNormalTexture():Show()

			local okay = pcall(function()
				local objTracker = _G["ObjectiveTrackerFrame"]
				if (objTracker) then
					objTracker.Header.MinimizeButton:Click()
				end
			end)
			if (not okay) then
				Details:Msg("failed 0x8660")
			end

			--widgets are anchored to the left side of the player banner and the player banner has its right side anchored to the right side of the readyFrame
			for i = 1, #readyFrame.PlayerBanners do
				--player banner
				local playerBanner = readyFrame.PlayerBanners[i]
				playerBanner:StartTextDotAnimation()

				playerBanner:ClearAllPoints()
				if (i == 1) then
					playerBanner:SetPoint("topright", readyFrame, "topright", -5, -25)
				else
					playerBanner:SetPoint("topright", readyFrame.PlayerBanners[i-1], "bottomright", 0, -5)
				end

				if (instanceInfo) then
					playerBanner.DungeonBackdropTexture:SetTexture(instanceInfo.iconLore)
				else
					playerBanner.DungeonBackdropTexture:SetTexture(overallMythicDungeonCombat.is_mythic_dungeon.DungeonTexture)
				end

				playerBanner.RantingLabel:ClearAllPoints()
				playerBanner.RantingLabel:SetPoint("right", playerBanner, "left", -154, 0)

				--background texture
				--playerBanner.BackgroundBannerTexture:ClearAllPoints()
				--playerBanner.BackgroundBannerTexture:SetPoint("topright", playerBanner, "topleft", playerBanner:GetHeight()/2, 0)
				--playerBanner.BackgroundBannerTexture:SetPoint("bottomright", playerBanner, "bottomleft", playerBanner:GetHeight()/2, 0)
				--playerBanner.BackgroundBannerTexture:SetSize(playerBannerSettings.background_width, playerBannerSettings.background_height)
				--playerBanner.BackgroundBannerTexture:SetTexCoord(256/512, 1, 0, 68/512)

				--dungeon texture is the small square icon showing a picture to identify the dungeon
				playerBanner.KeyStoneDungeonTexture:ClearAllPoints()
				playerBanner.KeyStoneDungeonTexture:SetPoint("right", playerBanner, "left", -8, 0) --right side attach to the left side of the player banner, growing to the left
				playerBanner.KeyStoneDungeonTexture:SetSize(playerBannerSettings.dungeon_texture_width, playerBannerSettings.dungeon_texture_height)

				--loot squares
				for j = 1, playerBannerSettings.loot_square_amount do
					local lootSquare = playerBanner.LootSquares[j]
					lootSquare:SetSize(playerBannerSettings.loot_square_width, playerBannerSettings.loot_square_height)
					lootSquare:ClearAllPoints()
					if (j == 1) then
						lootSquare:SetPoint("right", playerBanner.KeyStoneDungeonTexture, "left", -7, 0)
					else
						lootSquare:SetPoint("right", playerBanner.LootSquares[j-1], "left", -2, 0)
					end
				end

				--role icon
				playerBanner.RoleIcon:ClearAllPoints()
				--playerBanner.RoleIcon:SetPoint("center", playerBanner, "bottom", 0, 16)
				playerBanner.RoleIcon:SetPoint("center", playerBanner, "top", 0, -5)
				playerBanner.RoleIcon:SetSize(18, 18)
				playerBanner.RoleIcon:SetAlpha(0.834)
			end

		elseif (growDirection == "right") then
			--when the grow direction if to the right, the readyFrame is anchored to the left side of the ui parent
			--widgets are anchored to the right side of the player banner and the player banner has its left side anchored to the left side of the readyFrame
			for i = 1, #readyFrame.PlayerBanners do

			end
		end
	end
end

local updateRatingLevel = function(playerBanner, unitId)
	local ratingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unitId)
	if (ratingSummary) then
		local rating = ratingSummary.currentSeasonScore or 0
		local color = C_ChallengeMode.GetDungeonScoreRarityColor(rating)
		if (not color) then
			color = _G["HIGHLIGHT_FONT_COLOR"]
		end

		local oldRatingLevel = Details.PlayerRatings[Details:GetFullName(unitId)]
		local diff = 0
		if (oldRatingLevel) then
			diff = rating - oldRatingLevel
		end

		local s = "%s"
		playerBanner.RantingLabel:SetText(s:format(color:WrapTextInColorCode(_G["CHALLENGE_COMPLETE_DUNGEON_SCORE_FORMAT_TEXT"]:format(rating, diff))))
	end
end

local updatPlayerBanner = function(unitId, bannerIndex)
	if (CONST_DEBUG_MODE) then
		--print("updating player banner for unit:", unitId, "bannerIndex:", bannerIndex)
		if (not UnitExists(unitId)) then
			unitId = "player"
		end
	end

	if (UnitExists(unitId)) then
		local readyFrame = _G[readyFrameName]
		local unitName = Details:GetFullName(unitId)
		local libOpenRaid = LibStub("LibOpenRaid-1.0", true)

		---@type playerbanner
		local playerBanner = readyFrame.PlayerBanners[bannerIndex]
		readyFrame.unitCacheByName[unitName] = playerBanner
		playerBanner.unitId = unitId
		playerBanner.unitName = unitName
		playerBanner:Show()

		--update the border to match the class color
		local classColor = RAID_CLASS_COLORS[select(2, UnitClass(unitId))] or defaultColor
		playerBanner.Border:SetVertexColor(classColor.r, classColor.g, classColor.b)

		playerBanner.BackgroundShowAnim:Play()
		playerBanner.DungeonBackdropShowAnim:Play()
		playerBanner.BackgroundGradientAnim:Play()

		playerBanner.FadeInAnimation:Play() --fade in the whole player banner
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
				playerBanner.KeyStoneDungeonTexture:SetTexture(instanceInfo.iconLore)
			else
				playerBanner.KeyStoneDungeonTexture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
			end
		else
			playerBanner.KeyStoneDungeonTexture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
			playerBanner.LevelFontString:SetText("")
		end

		updateRatingLevel(playerBanner, unitId)

		C_Timer.After(3, function()
			updateRatingLevel(playerBanner, unitId)
		end)

		lootFrame.UpdateUnitLoot(playerBanner)
		return true
	end
end

local updateKeysStoneLevel = function()
	--update the player banners
	local libOpenRaid = LibStub("LibOpenRaid-1.0", true)
	---@type details_mplus_endframe
	local readyFrame = _G[readyFrameName]

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
					--	unitBanner.KeyStoneDungeonTexture:SetTexture(thisInstanceInfo.iconLore)
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
								unitBanner.KeyStoneDungeonTexture:SetTexture(instanceInfo.iconLore)
							else
								unitBanner.KeyStoneDungeonTexture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
							end

							--this character had its keystone upgraded
							--unitBanner.FlashTexture:Flash()
							--print("keystone upgraded for", Details:GetFullName(unitId), unitKeystoneInfo.level, "old was:", oldKeystoneLevel)
							--C_Timer.After(0.1, function() unitBanner.FlashTexture:Stop() end)
						end
					end

					--print("keystone level updated for", Details:GetFullName(unitId), unitKeystoneInfo.level)
				else
					unitBanner.KeyStoneDungeonTexture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
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
	C_Timer.After(2, function()
		C_AddOns.LoadAddOn("Blizzard_ChallengesUI");
		_G["DetailsEndOfMythicLootFrame"]:GetScript("OnEvent")(_G["DetailsEndOfMythicLootFrame"], "ENCOUNTER_LOOT_RECEIVED", 1, 207788, "|cffa335ee|Hitem:207788::::::::60:264::16:5:7208:6652:1501:5858:6646:1:28:1279:::|h[Shadowgrasp Totem]|h|r", 1, UnitName("player"), select(2, UnitClass("player")))
		_G["DetailsEndOfMythicLootFrame"]:GetScript("OnEvent")(_G["DetailsEndOfMythicLootFrame"], "ENCOUNTER_LOOT_RECEIVED", 1, 207788, "|cffa335ee|Hitem:207788::::::::60:264::16:5:7208:6652:1501:5858:6646:1:28:1279:::|h[Shadowgrasp Totem]|h|r", 1, UnitName("player"), select(2, UnitClass("player")))

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

		---@type details_mplus_endframe
		mythicDungeonFrames.ReadyFrame = CreateFrame("frame", readyFrameName, UIParent, "BackdropTemplate")
		local readyFrame = mythicDungeonFrames.ReadyFrame
		readyFrame:SetSize(355, 390)
		readyFrame:SetPoint("right", UIParent, "right", 0, 0)
		readyFrame:SetFrameStrata("LOW")
		readyFrame:EnableMouse(true)
		readyFrame:SetMovable(true)
		readyFrame:Hide()

		local backgroundGradient = readyFrame:CreateTexture("$parentBackgroundGradient", "background", nil, 0)
		backgroundGradient:SetTexture([[Interface\AddOns\Details\images\gradient_black_transparent.png]], nil, nil, "TRILINEAR")
		backgroundGradient:SetPoint("topleft", readyFrame, "topleft", 0, 0)
		backgroundGradient:SetPoint("bottomright", readyFrame, "bottomright", 0, 0)
		backgroundGradient:SetWidth(readyFrame:GetWidth())

		---@type playerbanner[]
		readyFrame.unitCacheByName = {}

		do
			--register to libwindow
			local LibWindow = LibStub("LibWindow-1.1")
			LibWindow.RegisterConfig(readyFrame, Details.mythic_plus.finished_run_panel3)
			LibWindow.MakeDraggable(readyFrame)

			if (Details.mythic_plus.finished_run_panel3.point) then
				LibWindow.RestorePosition(readyFrame)
			else
				LibWindow.SavePosition(readyFrame)
			end

			--set to use rounded corner
			local roundedCornerTemplate = {
				roundness = 6,
				color = {.1, .1, .1, 0.5},
				--border_color = {.05, .05, .05, 0.834},
			}
			--detailsFramework:AddRoundedCornersToFrame(readyFrame, roundedCornerTemplate)
		end

		readyFrame.entryAnimationDuration = 0.1

		local headerTexture = readyFrame:CreateTexture("$parentHeaderTexture", "artwork", nil, 1)
		headerTexture:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
		headerTexture:SetTexCoord(320/512, 498/512, 161/512, 192/512)
		headerTexture:SetSize(178, 31)
		headerTexture:SetVertexColor(0.251, 0.251, 0.251, 0.823)
		readyFrame.HeaderTexture = headerTexture

		local headerFadeInAnimation = detailsFramework:CreateAnimationHub(headerTexture, function()headerTexture:SetAlpha(0)end, function()headerTexture:SetAlpha(0.823)end)
		local headerAnimFadeIn = detailsFramework:CreateAnimation(headerFadeInAnimation, "Alpha", 1, 0.3, 0, 1)
		headerAnimFadeIn:SetStartDelay(0.8)

		readyFrame.HeaderFadeInAnimation = headerFadeInAnimation

		--clock texture and icon to show the total time elapsed
		local elapsedTimeIcon = readyFrame:CreateTexture("$parentClockIcon", "artwork", nil, 2)
		elapsedTimeIcon:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
		elapsedTimeIcon:SetTexCoord(172/512, 235/512, 84/512, 147/512)
		readyFrame.ElapsedTimeIcon = elapsedTimeIcon

		local elapsedTimeText = readyFrame:CreateFontString("$parentClockText", "artwork", "GameFontNormal")
		elapsedTimeText:SetTextColor(1, 1, 1)
		detailsFramework:SetFontSize(elapsedTimeText, 11)
		elapsedTimeText:SetText("00:00")
		elapsedTimeText:SetPoint("left", elapsedTimeIcon, "right", 3, 0)
		readyFrame.ElapsedTimeText = elapsedTimeText

		--another clock texture and icon to show the wasted time (time out of combat)
		local outOfCombatIcon = readyFrame:CreateTexture("$parentClockIcon2", "artwork", nil, 2)
		outOfCombatIcon:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
		outOfCombatIcon:SetTexCoord(172/512, 235/512, 84/512, 147/512)
		outOfCombatIcon:SetVertexColor(detailsFramework:ParseColors("orangered"))
		readyFrame.OutOfCombatIcon = outOfCombatIcon

		local outOfCombatText = readyFrame:CreateFontString("$parentClockText2", "artwork", "GameFontNormal")
		outOfCombatText:SetTextColor(1, 1, 1)
		detailsFramework:SetFontSize(outOfCombatText, 11)
		detailsFramework:SetFontColor(outOfCombatText, "orangered")
		outOfCombatText:SetText("00:00")
		outOfCombatText:SetPoint("left", outOfCombatIcon, "right", 3, 0)
		readyFrame.OutOfCombatText = outOfCombatText

		--create the sandtime icon and a text to show the keystone level
		local sandTimeIcon = readyFrame:CreateTexture("$parentSandTimeIcon", "artwork", nil, 2)
		sandTimeIcon:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
		sandTimeIcon:SetTexCoord(81/512, 137/512, 83/512, 143/512)
		readyFrame.SandTimeIcon = sandTimeIcon

		local sandTimeText = readyFrame:CreateFontString("$parentSandTimeText", "artwork", "GameFontNormal")
		sandTimeText:SetTextColor(1, 1, 1)
		detailsFramework:SetFontSize(sandTimeText, 11)
		sandTimeText:SetText("0")
		sandTimeText:SetPoint("left", sandTimeIcon, "right", 1, 0)
		readyFrame.KeylevelText = sandTimeText

		--create a strong arm texture and a text to show the ranting of the player
		local strongArmIcon = readyFrame:CreateTexture("$parentStrongArmIcon", "artwork", nil, 2)
		strongArmIcon:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
		strongArmIcon:SetTexCoord(84/512, 145/512, 151/512, 215/512)
		readyFrame.StrongArmIcon = strongArmIcon

		local rantingLabel = detailsFramework:CreateLabel(readyFrame, "", textSize, textColor)
		rantingLabel:SetPoint("left", strongArmIcon, "right", 3, 0)
		readyFrame.RantingLabel = rantingLabel

		--this frame is required due to the animation, the readyFrame and the contentFrame has their own animations
		mythicDungeonFrames.ReadyFrameTop = CreateFrame("frame", "DetailsMythicDungeonReadyTopFrame", UIParent, "BackdropTemplate")
		mythicDungeonFrames.ReadyFrameTop:SetPoint("bottomleft", readyFrame, "topleft", 0, 0)
		mythicDungeonFrames.ReadyFrameTop:SetPoint("bottomright", readyFrame, "topright", 0, 0)
		mythicDungeonFrames.ReadyFrameTop:SetHeight(1)
		readyFrame.TopFrame = mythicDungeonFrames.ReadyFrameTop

		local openingAnimationHub = detailsFramework:CreateAnimationHub(readyFrame, function() end, function() readyFrame:SetWidth(355); end)
		readyFrame.OpeningAnimation = openingAnimationHub
		detailsFramework:CreateAnimation(openingAnimationHub, "Scale", 1, readyFrame.entryAnimationDuration, 0, 1, 1, 1, "center", 0, 0)



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
			spikes:Hide()

			local yellowFlash = mythicDungeonFrames.ReadyFrameTop:CreateTexture("$parentYellowFlash", "artwork")
			yellowFlash:SetSize(120, 120)
			yellowFlash:SetPoint("center", readyFrame, "top", 0, 30)
			--yellowFlash:SetAtlas("BossBanner-RedFlash")
			yellowFlash:SetAlpha(0)
			yellowFlash:SetBlendMode("ADD")
			yellowFlash:SetIgnoreParentAlpha(true)
			readyFrame.YellowFlash = yellowFlash

			readyFrame.Level = mythicDungeonFrames.ReadyFrameTop:CreateFontString("$parentLevelText", "overlay", "GameFontNormalWTF2Outline")
			--readyFrame.Level:SetPoint("center", readyFrame.YellowSpikeCircle, "center", 0, 0)
			--readyFrame.Level:SetText("")

			--create the animation for the yellow flash
			local flashAnimHub = detailsFramework:CreateAnimationHub(yellowFlash, function() yellowFlash:SetAlpha(0) end, function() yellowFlash:SetAlpha(0) end)
			local flashAnim1 = detailsFramework:CreateAnimation(flashAnimHub, "Alpha", 1, 0.5, 0, 1)
			local flashAnim2 = detailsFramework:CreateAnimation(flashAnimHub, "Alpha", 2, 0.5, 1, 0)

			--create the animation for the yellow spike circle
			local spikeCircleAnimHub = detailsFramework:CreateAnimationHub(spikes, function() spikes:SetAlpha(0); spikes:SetScale(1) end, function() flashAnimHub:Play(); spikes:SetSize(100, 100); spikes:SetScale(1); spikes:SetAlpha(1) end)
			local alphaAnim1 = detailsFramework:CreateAnimation(spikeCircleAnimHub, "Alpha", 1, 0.2960000038147, 0, 1)
			local scaleAnim1 = detailsFramework:CreateAnimation(spikeCircleAnimHub, "Scale", 1, 0.21599999070168, 5, 5, 1, 1, "center", 0, 0)
			--readyFrame.YellowSpikeCircle.OnShowAnimation = spikeCircleAnimHub
		end

		do
			readyFrame.leftFiligree = contentFrame:CreateTexture("$parentLeftFiligree", "artwork")
			readyFrame.leftFiligree:SetAtlas("BossBanner-LeftFillagree")
			readyFrame.leftFiligree:SetSize(72, 43)
			readyFrame.leftFiligree:SetPoint("bottom", readyFrame, "top", -50, 2)
			readyFrame.leftFiligree:Hide()

			readyFrame.rightFiligree = contentFrame:CreateTexture("$parentRightFiligree", "artwork")
			readyFrame.rightFiligree:SetAtlas("BossBanner-RightFillagree")
			readyFrame.rightFiligree:SetSize(72, 43)
			readyFrame.rightFiligree:SetPoint("bottom", readyFrame, "top", 50, 2)
			readyFrame.rightFiligree:Hide()

			--create the bottom filligree using BossBanner-BottomFillagree atlas
			readyFrame.bottomFiligree = contentFrame:CreateTexture("$parentBottomFiligree", "artwork")
			readyFrame.bottomFiligree:SetAtlas("BossBanner-BottomFillagree")
			readyFrame.bottomFiligree:SetSize(66, 28)
			readyFrame.bottomFiligree:SetPoint("bottom", readyFrame, "bottom", 0, -19)
			readyFrame.bottomFiligree:Hide()
		end

		local titleLabel = detailsFramework:CreateLabel(contentFrame, "Details! Mythic Run Completed!", 12, "yellow")
		titleLabel:SetPoint("top", readyFrame, "top", 0, -7)
		titleLabel:Hide()
		titleLabel.textcolor = textColor

		---@type df_closebutton
		local closeButton = detailsFramework:CreateCloseButton(contentFrame, "$parentCloseButton")
		closeButton:SetPoint("topright", readyFrame, "topright", -2, -2)
		closeButton:SetScale(1.0)
		closeButton:SetAlpha(0.823)
		closeButton:SetScript("OnClick", function(self)
			readyFrame:Hide()
		end)
		readyFrame.CloseButton = closeButton

		local configButtonOnClick = function()
			Details:OpenOptionsWindow(Details:GetInstance(1), false, 18)
		end
		readyFrame.ConfigButton = detailsFramework:CreateButton(contentFrame, configButtonOnClick, 32, 32, "")
		readyFrame.ConfigButton:SetAlpha(0.823)
		readyFrame.ConfigButton:SetSize(closeButton:GetSize())

		local normalTexture = readyFrame.ConfigButton:CreateTexture(nil, "overlay")
		normalTexture:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
		normalTexture:SetTexCoord(79/512, 113/512, 0/512, 36/512)
		normalTexture:SetDesaturated(true)

		local pushedTexture = readyFrame.ConfigButton:CreateTexture(nil, "overlay")
		pushedTexture:SetTexture([[Interface\AddOns\Details\images\end_of_mplus.png]], nil, nil, "TRILINEAR")
		pushedTexture:SetTexCoord(114/512, 148/512, 0/512, 36/512)
		pushedTexture:SetDesaturated(true)

		local highlightTexture = readyFrame.ConfigButton:CreateTexture(nil, "highlight")
		highlightTexture:SetTexture([[Interface\BUTTONS\redbutton2x]], nil, nil, "TRILINEAR")
		highlightTexture:SetTexCoord(116/256, 150/256, 0, 39/128)
		highlightTexture:SetDesaturated(true)

		readyFrame.ConfigButton:SetTexture(normalTexture, highlightTexture, pushedTexture, normalTexture)

		--waiting for loot label
		local waitingForLootLabel = detailsFramework:CreateLabel(contentFrame, "Waiting for loot", 12, "silver")
		waitingForLootLabel:SetPoint("bottom", readyFrame, "bottom", 0, 54)
		waitingForLootLabel:Hide()

		--auto close time bar
		local autoCloseTimeBar = detailsFramework:CreateTimeBar(contentFrame, [[Interface\AddOns\Details\images\bar_serenity]])
		autoCloseTimeBar:SetHook("OnTimerEnd", function()
			readyFrame:Hide()
		end)
		readyFrame.AutoCloseTimeBar = autoCloseTimeBar

		readyFrame:SetScript("OnHide", function(self)
			--hide the dotString on all player banners
			for i = 1, #readyFrame.PlayerBanners do
				readyFrame.PlayerBanners[i]:StopTextDotAnimation()
			end
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
		--readyFrame.ShowBreakdownButton:SetBackdrop(nil)
		readyFrame.ShowBreakdownButton:SetIcon([[Interface\AddOns\Details\images\icons2.png]], 16, 16, "overlay", {84/512, 120/512, 153/512, 187/512}, {.7, .7, .7, 1}, nil, 0, 0)
		readyFrame.ShowBreakdownButton.textcolor = textColor
        detailsFramework:AddRoundedCornersToFrame(readyFrame.ShowBreakdownButton.widget, roundedCornerPreset)
		leftAnchor = readyFrame.ShowBreakdownButton
		readyFrame.ShowBreakdownButton:Disable()
		readyFrame.ShowBreakdownButton:Hide()

		--show graphic button
		local showChartFunc = function(self)
			mythicDungeonCharts.ShowChart()
			readyFrame:Hide()
		end

		---@type df_button
		readyFrame.ShowChartButton = detailsFramework:CreateButton(contentFrame, showChartFunc, 50, 30, "Chart")
		--set the template
		--readyFrame.ShowChartButton:SetTemplate(detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
		--readyFrame.ShowChartButton:SetBackdrop(nil)
		readyFrame.ShowChartButton:SetIcon([[Interface\AddOns\Details\images\end_of_mplus.png]], 16, 16, "overlay", {153/512, 185/512, 0, 32/512}, {1, 1, 1, 1}, nil, 0, 0)
		readyFrame.ShowChartButton.textcolor = textColor
        --detailsFramework:AddRoundedCornersToFrame(readyFrame.ShowChartButton.widget, roundedCornerPreset)

		local elapsedTimeLabel = detailsFramework:CreateLabel(contentFrame, "Run Time:", textSize, textColor)
		elapsedTimeLabel:SetPoint("topleft", readyFrame, "topleft", 5, -70)
		local elapsedTimeAmount = detailsFramework:CreateLabel(contentFrame, "00:00", textSize, textColor)
		elapsedTimeAmount:SetPoint("left", elapsedTimeLabel, "left", 130, 0)
		elapsedTimeLabel:Hide()
		elapsedTimeAmount:Hide()

		local timeNotInCombatLabel = detailsFramework:CreateLabel(contentFrame, "Time not in combat:", textSize, "orangered")
		timeNotInCombatLabel:SetPoint("topleft", elapsedTimeLabel, "bottomleft", 0, -5)
		local timeNotInCombatAmount = detailsFramework:CreateLabel(contentFrame, "00:00", textSize, "orangered")
		timeNotInCombatAmount:SetPoint("left", timeNotInCombatLabel, "left", 130, 0)
		timeNotInCombatLabel:Hide()
		timeNotInCombatAmount:Hide()

		readyFrame.PlayerBanners = {}
		for i = 1, 5 do
			local playerBanner = createPlayerBanner(readyFrame, "$parentPlayerBanner" .. i, i)
			readyFrame.PlayerBanners[#readyFrame.PlayerBanners+1] = playerBanner
		end
	end --end of creating of the readyFrame

	--< end of mythic+ end of run frame creation >--

	--mythic+ finished, showing the readyFrame for the user
	local readyFrame = mythicDungeonFrames.ReadyFrame
	readyFrame:Show()

	readyFrame.TopFrame:Show()
	--readyFrame.YellowSpikeCircle.OnShowAnimation:Play()

	readyFrame.ContentFrame:SetAlpha(0)

	--readyFrame.Level:SetText(Details222.MythicPlus.Level or "")
	readyFrame.KeylevelText:SetText(Details222.MythicPlus.Level or "")

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
		C_Timer.After(0.3, function()
			readyFrame.ContentFrameFadeInAnimation:Play()
		end)
	end)

	--readyFrame.HeaderFadeInAnimation
	readyFrame.HeaderTexture:SetAlpha(0)
	readyFrame.HeaderFadeInAnimation:Play()

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
	readyFrame.ElapsedTimeText:SetText(detailsFramework:IntegerToTimer(elapsedTime))

	if (overallMythicDungeonCombat:GetCombatType() == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
		local combatTime = overallMythicDungeonCombat:GetCombatTime()
		local notInCombat = elapsedTime - combatTime
		readyFrame.OutOfCombatText:SetText(detailsFramework:IntegerToTimer(notInCombat))
	else
		readyFrame.OutOfCombatText:SetText("00:00")
	end

	local mythicDungeonInfo = overallMythicDungeonCombat:GetMythicDungeonInfo()

	if (not mythicDungeonInfo and not CONST_DEBUG_MODE) then
		return
	end

	setOrientation(readyFrame, mythicDungeonInfo, overallMythicDungeonCombat)

	wipe(readyFrame.unitCacheByName)

	if (Details222.MythicPlus.OnTime) then
		--beat the timer
		PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_KEYSTONE_UPGRADE)
		C_Timer.After(0.020, function()
			--PlaySoundFile([[Interface\AddOns\Details\sounds\bassdrop2.mp3]])
		end)
	else
		--did not beat the timer
		PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_COMPLETE_NO_UPGRADE)
	end

	if (Details222.MythicPlus.NewDungeonScore and Details222.MythicPlus.OldDungeonScore) then
		local gainedScore = Details222.MythicPlus.NewDungeonScore - Details222.MythicPlus.OldDungeonScore
		local color = C_ChallengeMode.GetDungeonScoreRarityColor(Details222.MythicPlus.NewDungeonScore)
		if (not color) then
			color = _G["HIGHLIGHT_FONT_COLOR"]
		end
		local textToFormat = "%d"
		readyFrame.RantingLabel.text = color:WrapTextInColorCode(textToFormat:format(Details222.MythicPlus.NewDungeonScore or 0)) --, gainedScore
		readyFrame.RantingLabel.textcolor = "limegreen"
	else
		readyFrame.RantingLabel.text = "0000"
	end

	C_Timer.After(0.6, function()
		local playersFound = 0
		local playerBannerIndex = 1
		do --update the player banner
			C_Timer.After(0.1, function()
				if (updatPlayerBanner("player", playerBannerIndex)) then
					playersFound = playersFound + 1
				end
			end)
		end

		local unitCount = 1
		local delay = 0.3
		for bannerIndex = 2, #readyFrame.PlayerBanners do
			C_Timer.After(delay, function() --RandomFloatInRange(bannerIndex/5-0.075, bannerIndex/5+0.075)
				if (updatPlayerBanner("party"..unitCount, bannerIndex)) then
					playersFound = playersFound + 1
				end
				unitCount = unitCount + 1
			end)
			delay = delay + 0.3
		end
	end)

	C_Timer.After(2.5, updateKeysStoneLevel)
end

Details222.MythicPlus.IsMythicPlus = function()
	return C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo() and true or false
end
