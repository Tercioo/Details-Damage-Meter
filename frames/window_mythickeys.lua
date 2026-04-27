
local addonName, Details222 = ...
local Details = _G.Details
local Loc = LibStub("AceLocale-3.0"):GetLocale( "Details" )
local _ = nil
local detailsFramework = DetailsFramework


if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
	SLASH_KEYSTONE1 = "/keystone"
	SLASH_KEYSTONE2 = "/keys"
	SLASH_KEYSTONE3 = "/key"

	local noMythicPlusAddonMsg = Loc["STRING_NO_MYTHIC_PLUS_ADDON"]

	--header
	local keystoneHeaderTable = {
		{text = CLASS, width = 40, canSort = true, dataType = "number", order = "DESC", offset = 0},
		{text = Loc["STRING_FORGE_FILTER_PLAYERNAME"], width = 100, canSort = true, dataType = "string", order = "DESC", offset = 0},
		{text = LEVEL, width = 46, canSort = true, dataType = "number", order = "DESC", offset = 0, selected = true},
		{text = Loc["STRING_OPTIONS_PERFORMANCE_DUNGEON"], width = 150, canSort = true, dataType = "string", order = "DESC", offset = 0},
		{text = RATING, width = 50, canSort = true, dataType = "number", order = "DESC", offset = 0},
		{text = Loc["STRING_TELEPORT"], width = 60, canSort = false, offset = 0},
		--{text = Loc["STRING_LIKES_YOU_GAVE"], width = 24, canSort = false, offset = 0, name = "likesGiven", columnSpan = 1},
		--{text = "", width = 129, canSort = false, offset = 0, name = "likesGiven"},
	}

	local buttonsCreated = {}
	local CONST_SCROLL_LINE_HEIGHT = 22
	local CONST_WINDOW_WIDTH = 460
	local CONST_WINDOW_HEIGHT = 626
	local CONST_SCROLL_LINE_AMOUNT = 21

	local detailsKeystoneInfoFrame = detailsFramework:CreateSimplePanel(UIParent, CONST_WINDOW_WIDTH, CONST_WINDOW_HEIGHT, "M+ Keystones (/key, /keys, /keystone)", "DetailsKeystoneInfoFrame")
	detailsKeystoneInfoFrame:Hide()

	--pre create 30 protected buttons
	for i = 1, 30 do
		local teleportButton = CreateFrame("button", nil, detailsKeystoneInfoFrame, "InsecureActionButtonTemplate, BackdropTemplate")
		teleportButton:SetAttribute("type", "spell")
		teleportButton:RegisterForClicks("AnyDown")
		teleportButton:SetFrameLevel(detailsKeystoneInfoFrame:GetFrameLevel() + 10)
		teleportButton:SetSize(keystoneHeaderTable[6].width - 10, CONST_SCROLL_LINE_HEIGHT - 2)
		teleportButton:Hide()
		buttonsCreated[i] = teleportButton

		teleportButton.Icon = teleportButton:CreateTexture("$parentIcon", "overlay")
		teleportButton.Icon:SetSize(CONST_SCROLL_LINE_HEIGHT - 2, CONST_SCROLL_LINE_HEIGHT - 2)
		teleportButton.Icon:SetPoint("left", teleportButton, "left", 2, 0)
		--detailsFramework:SetMask(teleportButton.Icon, [[Interface\AddOns\Details\images\masks\portal_mask.tga]])
		teleportButton.Text = teleportButton:CreateFontString("$parentText", "overlay", "GameFontNormal")
		teleportButton.Text:SetPoint("left", teleportButton.Icon, "right", 2, 0)
		teleportButton.Text:SetTextColor(1, 1, 1, 1)
		--teleportButton.Text:SetText("Teleport")
		teleportButton.Text:SetText("")
		teleportButton.CastBar = detailsFramework:CreateCastBar(teleportButton, "DetailsMythicPlusKeysCastBar" .. i, {DontUpdateAlpha=true,FillOnInterrupt=false, NoFadeEffects=true})
		teleportButton.CastBar:Hide()

		if detailsFramework.IsTWWWow() then
			teleportButton.CastBar:SetUnit("player")
		end

		teleportButton.CastBar:SetAllPoints()
		teleportButton.CastBar:SetHook("OnShow", function(self)
			local line = self:GetParent() and self:GetParent():GetParent()
			if (line and line.teleportButton) then
				if (self.spellID ~= line.teleportButton.spellId) then
					self:SetAlpha(0)
				end
			end
		end)
		teleportButton.CastBar:HookScript("OnUpdate", function(self, event, ...)
			local line = self:GetParent() and self:GetParent():GetParent()
			if (line and line.teleportButton) then
				if (self.spellID ~= line.teleportButton.spellId) then
					self:SetAlpha(0)
				end
			end
		end)
		teleportButton.CastBar:HookScript("OnEvent", function(self, event, ...)
			do return end
			if (event == "UNIT_SPELLCAST_START") then
				local line = self:GetParent() and self:GetParent():GetParent()
				if (line and line ~= UIParent and line.teleportButton) then
					if (self.spellID ~= line.teleportButton.spellId) then
						self:SetAlpha(0)
					else
						self:SetAlpha(1)
					end
				end
				teleportButton.CastBar.Text:Hide()
				teleportButton.CastBar.Icon:Hide()
				teleportButton.CastBar.Spark:SetHeight(40)
			end
			if (event == "UNIT_SPELLCAST_INTERRUPTED") then
				teleportButton.CastBar:Hide()
			end
		end)
	end

--    detailsKeystoneInfoFrame:SetBackdropColor(.1, .1, .1, 0)
--    detailsKeystoneInfoFrame:SetBackdropBorderColor(.1, .1, .1, 0)
--    detailsFramework:AddRoundedCornersToFrame(detailsKeystoneInfoFrame, {
--		roundness = 6,
--		color = {.1, .1, .1, 0.98},
--		border_color = {.05, .05, .05, 0.834},
--	})

	detailsKeystoneInfoFrame.TitleBar:AdjustPointsOffset(-1, 1)
	local point1, frame1, point2, offSetX, offSetY = detailsKeystoneInfoFrame.TitleBar:GetPoint(2)
	detailsKeystoneInfoFrame.TitleBar:SetPoint(point1, frame1, point2, offSetX+2, offSetY+1)
	detailsKeystoneInfoFrame.TitleBar:SetHeight(detailsKeystoneInfoFrame.TitleBar:GetHeight() + 2)

	local footer = CreateFrame("frame", "$parentFooter", detailsKeystoneInfoFrame, "BackdropTemplate")
	detailsFramework:ApplyStandardBackdrop(footer)
	footer:SetPoint("bottomleft", detailsKeystoneInfoFrame, "bottomleft", 0, 0)
	footer:SetPoint("bottomright", detailsKeystoneInfoFrame, "bottomright", 0, 0)
	footer:SetHeight(74)

	local currentDungeons = LIB_OPEN_RAID_MYTHIC_PLUS_CURRENT_SEASON
	local lastButton

	local buttonSize = 46
	local spaceBetweenButtons = 5

	--a fontstring positioned at the topleft of the footer with the text "teleporters:"
	local teleportersLabel = footer:CreateFontString(nil, "overlay", "GameFontNormal")
	teleportersLabel:SetPoint("topleft", footer, "topleft", 58, -9)
	teleportersLabel:SetText(Loc["STRING_TELEPORTERS"])
	teleportersLabel:Hide()

	local cooldownBlocker = CreateFrame("frame", "$parentCooldownBlocker", footer, "BackdropTemplate")
	cooldownBlocker:SetPoint("topleft", footer, "topleft", 140, -5)
	cooldownBlocker:SetSize(8 * (buttonSize + spaceBetweenButtons) - spaceBetweenButtons, buttonSize)
	cooldownBlocker:SetFrameLevel(footer:GetFrameLevel() + 10)
	cooldownBlocker:EnableMouse(true)
	cooldownBlocker:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]]})
	cooldownBlocker:SetBackdropColor(.1, .1, .1, 0.8)
	cooldownBlocker:Hide()

	cooldownBlocker.cooldownText = cooldownBlocker:CreateFontString(nil, "overlay", "GameFontNormal")
	cooldownBlocker.cooldownText:SetPoint("center", cooldownBlocker, "center", 0, 0)
	cooldownBlocker.cooldownText:SetTextColor(1, 1, 1, 0.25)
	cooldownBlocker.cooldownText:SetText("Cooldown")
	detailsFramework:SetFontSize(cooldownBlocker.cooldownText, 20)

	local spellIdToCheckCooldown
	local teleporterButtons = {}
	local frameAboveTeleporterButtons = CreateFrame("frame", "$parentFrameAboveTeleporterButtons", footer, "BackdropTemplate")
	frameAboveTeleporterButtons:SetAllPoints()
	frameAboveTeleporterButtons:SetFrameLevel(footer:GetFrameLevel() + 2)
	frameAboveTeleporterButtons:EnableMouse(false)
	frameAboveTeleporterButtons.Frames = {}

	footer:SetScript("OnUpdate", function()
		if (spellIdToCheckCooldown) then
			local cooldownInfo = C_Spell.GetSpellCooldown(spellIdToCheckCooldown)
			if (cooldownInfo) then
				local start, duration = cooldownInfo.startTime, cooldownInfo.duration
				if (start > 0) then
					cooldownBlocker:Show()
					cooldownBlocker.cooldownText:SetText(detailsFramework:IntegerToCooldownTime((start + duration) - GetTime()) .. "\n remaining")
				else
					cooldownBlocker:Hide()
					cooldownBlocker.cooldownText:SetText("")
				end
			end
		end

		for i = 1, #teleporterButtons do
			local thisTeleportButton = teleporterButtons[i]
			local spellId = thisTeleportButton.spellId
			if (C_SpellBook.IsSpellInSpellBook(spellId)) then
				frameAboveTeleporterButtons.Frames[i]:Hide()
			else
				frameAboveTeleporterButtons.Frames[i]:Show()
			end
		end
	end)

	for i = 1, #currentDungeons do --array of mapIds from GetInstanceInfo()
		local mapId = currentDungeons[i]
		local teleportButton = CreateFrame("button", nil, footer, "InsecureActionButtonTemplate, BackdropTemplate")
		teleportButton:SetAttribute("type", "spell")
		teleportButton:RegisterForClicks("AnyDown")
		teleporterButtons[#teleporterButtons+1] = teleportButton
		teleportButton:SetFrameLevel(footer:GetFrameLevel() + 1)

		teleportButton:SetScript("OnEnter", function(self)
			GameCooltip:Preset(2)
			GameCooltip:SetOwner(self, "bottom", "top", 0, 5)
			GameCooltip:AddLine(self.dungeonName, "", 1)
			GameCooltip:Show()
		end)

		teleportButton:SetScript("OnLeave", function(self)
			GameCooltip:Hide()
		end)

		local dungeonAcronym = teleportButton:CreateFontString(nil, "overlay", "GameFontNormal")
		dungeonAcronym:SetPoint("bottom", teleportButton, "bottom", 0, 0)
		teleportButton.DungeonAcronym = dungeonAcronym

		teleportButton:SetSize(buttonSize, buttonSize)

		local blockTeleporter = CreateFrame("frame", nil, frameAboveTeleporterButtons)
		blockTeleporter:SetSize(buttonSize, buttonSize)
		blockTeleporter:Hide()
		blockTeleporter.Texture = blockTeleporter:CreateTexture(nil, "overlay")
		blockTeleporter.Texture:SetAllPoints()
		blockTeleporter.Texture:SetColorTexture(0.1, 0.1, 0.1, 0.8)
		blockTeleporter:SetScript("OnEnter", function()
			GameCooltip:Preset(2)
			GameCooltip:SetOwner(blockTeleporter, "bottom", "top", 0, 5)
			GameCooltip:AddLine(Loc["STRING_NO_TELEPORTER"], "", 1)
			GameCooltip:Show()
		end)
		blockTeleporter:SetScript("OnLeave", function()
			GameCooltip:Hide()
		end)
		frameAboveTeleporterButtons.Frames[#frameAboveTeleporterButtons.Frames + 1] = blockTeleporter

		for spellId, thisMapId in pairs(LIB_OPEN_RAID_MYTHIC_PLUS_TELEPORT_SPELLS) do
			if (mapId == thisMapId) then
				teleportButton:SetAttribute("spell", spellId)
				teleportButton.spellId = spellId
				spellIdToCheckCooldown = spellId

				for challengeModeMapId, dungeonInfo in pairs(LIB_OPEN_RAID_MYTHIC_PLUS_MAPINFO) do
					if (dungeonInfo[6] == mapId) then
						teleportButton:SetNormalTexture(dungeonInfo[4])
						teleportButton:SetPushedTexture(dungeonInfo[4])
						teleportButton:SetHighlightTexture(dungeonInfo[4])

						local dungeonName = dungeonInfo[1] or "Unknown Dungeon"
						dungeonAcronym:SetText(detailsFramework.string.Acronym(dungeonName))
						teleportButton.dungeonName = dungeonName
						break
					end
				end
			end
		end

		if (not lastButton) then
			teleportButton:SetPoint("topleft", footer, "topleft", 2, -5)
			blockTeleporter:SetPoint("topleft", footer, "topleft", 2, -5)
			lastButton = teleportButton
		else
			teleportButton:SetPoint("left", lastButton, "right", spaceBetweenButtons, 0)
			blockTeleporter:SetPoint("left", lastButton, "right", spaceBetweenButtons, 0)
			lastButton = teleportButton
		end
	end

	local backgroundGradientTexture = detailsFramework:CreateTexture(footer, {gradient = "vertical", fromColor = {0, 0, 0, 0}, toColor = {0, 0, 0, 0.3}}, 1, 30, "artwork", {0, 1, 0, 1})
	backgroundGradientTexture:SetPoint("topleft", footer, "topleft", 0, 0)
	backgroundGradientTexture:SetPoint("topright", footer, "topright", 0, 0)

	local GetSpellCooldown = C_Spell and C_Spell.GetSpellCooldown or GetSpellCooldown

    local openKeysPanel = function()
    end

	function SlashCmdList.KEYSTONE(msg, editbox)
        openKeysPanel()
    end

    openKeysPanel = function()
        local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
        if (openRaidLib) then
            if (not DetailsKeystoneInfoFrame.Created) then
                DetailsKeystoneInfoFrame.Created = true

                ---@type detailsframework
                local detailsFramework = detailsFramework

                local backdrop_color = {.2, .2, .2, 0.2}
                local backdrop_color_on_enter = {.8, .8, .8, 0.4}

                local backdrop_color_inparty = {.3, .3, .99, 0.4}
                local backdrop_color_on_enter_inparty = {.5, .5, 1, 0.4}

                local backdrop_color_inguild = {.5, .8, .5, 0.2}
                local backdrop_color_on_enter_inguild = {.5, 1, .5, 0.4}

                local f = DetailsKeystoneInfoFrame
                f:ClearAllPoints()
                f:SetPoint("center", UIParent, "center", 0, 0)

                f:SetScript("OnMouseDown", nil) --disable framework native moving scripts
                f:SetScript("OnMouseUp", nil) --disable framework native moving scripts

                local LibWindow = LibStub("LibWindow-1.1")
                LibWindow.RegisterConfig(f, Details.keystone_frame.position)
                LibWindow.MakeDraggable(f)
                LibWindow.RestorePosition(f)

                f:SetScript("OnEvent", function(self, event, ...)
                    if (f:IsShown()) then
                        if (event == "GUILD_ROSTER_UPDATE") then
                            self:RefreshData()
                        end
                    end
                end)

                --select key addon
                local selectAddonFrame = CreateFrame("frame", "DetailsMythicPlusSelectAddonFrame", f, "BackdropTemplate")
                selectAddonFrame:SetPoint("center", f, "center", 5, -5)
                selectAddonFrame:SetSize(270, 200)
                detailsFramework:ApplyStandardBackdrop(selectAddonFrame)
                selectAddonFrame:Hide()
                f.SelectAddonFrame = selectAddonFrame
                selectAddonFrame.currentSelected = nil

                local selectAddOnLabel = selectAddonFrame:CreateFontString(nil, "overlay", "GameFontNormal")
                selectAddOnLabel:SetPoint("topleft", selectAddonFrame, "topleft", 2, -2)
                selectAddOnLabel:SetText("Choose which adddon should handle /key:")
                selectAddonFrame.Title = selectAddOnLabel

                local redoSelectionLabel = selectAddonFrame:CreateFontString(nil, "overlay", "GameFontNormal")
                redoSelectionLabel:SetPoint("bottomleft", selectAddonFrame, "bottomleft", 2, 2)
                redoSelectionLabel:SetText("Click 'Select Addon' in the bottom right\ncorner to change again another time.")
                redoSelectionLabel:SetJustifyH("LEFT")
                selectAddonFrame.RedoSelectionLabel = redoSelectionLabel

                local selectSection = function()
                end

                local selectAddonButton = detailsFramework:CreateButton(f, function() selectAddonFrame:Show() end, 64, 20, "select addon for /key")
                selectAddonButton:SetPoint("bottomright", f, "bottomright", 2, 17)
                selectAddonButton.textcolor = "gray"
                selectAddonButton.alpha = 0.9
                selectAddonButton:Hide()

                --checkbox for dnd --Details.slashk_dnd
                local dndCheckbox = detailsFramework:CreateSwitch(f, function(_, _, checked) Details.slashk_dnd = checked; LIB_OPEN_RAID_MYTHIC_PLUS_DND = checked end, Details.slashk_dnd)
                dndCheckbox:SetTemplate(detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
                dndCheckbox:SetAsCheckBox()
                dndCheckbox:SetPoint("bottomright", f, "bottomright", -36, 23)
                dndCheckbox.tooltip = Loc["STRING_KEYSTONE_DND_TOOLTIP"]
                dndCheckbox.Text = dndCheckbox:CreateFontString("$parentText", "overlay", "GameFontNormal")
                dndCheckbox.Text:SetText(Loc["STRING_ENABLE_DO_NOT_DISTURB"])
                dndCheckbox.Text:SetText("D.N.D.")
                dndCheckbox.Text:SetPoint("left", dndCheckbox.widget, "right", 5, 0)
                detailsFramework:SetFontSize(dndCheckbox.Text, 10)

                ---@type df_radiooptions[]
                local mainTabSelectorRadioOptions = {{
                        name = "Details!",
                        set = function()end,
                        param = "details",
                        get = function()end,
                        texture = [[Interface\AddOns\Details\images\minimap]],
                        texcoord = {0, 1, 0, 1},
                        mask = nil,
                        width = 20,
                        height = 20,
                        text_size = 12,
                        callback = selectSection,
                    }}

                if (_G.BigWigsLoader) then
                    table.insert(mainTabSelectorRadioOptions, {
                        name = "BigWigs", --localize-me
                        set = function()end,
                        param = "bigwigs",
                        get = function()end,
                        texture = [[Interface\AddOns\BigWigs\Media\Icons\minimap_raid.tga]],
                        texcoord = {0, 1, 0, 1},
                        mask = nil,
                        width = 20,
                        height = 20,
                        text_size = 12,
                        callback = selectSection,
                    })
                end

                if (_G.AstralKeys) then
                    table.insert(mainTabSelectorRadioOptions, {
                        name = "Astral Keys", --localize-me
                        set = function()end,
                        param = "astralkeys",
                        get = function()end,
                        texture = [[Interface\AddOns\AstralKeys\Media\Astral_minimap.tga]],
                        texcoord = {0, 1, 0, 1},
                        mask = nil,
                        width = 20,
                        height = 20,
                        text_size = 12,
                        callback = selectSection,
                    })
                end

                ---@type df_framelayout_options
                local radioGroupLayout = {
                    min_width = 50,
                    height = 30,
                    start_x = 5,
                    start_y = -5,
                    offset_y = 35,
                    icon_offset_x = 5,
                    amount_per_line = 1,
                    is_vertical = false,
                    grow_down = true,
                }

                local radioGroupSettings = {
                    --backdrop = {},
                    --backdrop_color = {0, 0, 0, 0},
                    --backdrop_border_color = {0, 0, 0, 0},
                    rounded_corner_preset = {
                        color = {.075, .075, .075, 1},
                        border_color = {.2, .2, .2, 1},
                        roundness = 8,
                    },
                    checked_texture = [[Interface\BUTTONS\UI-CheckBox-Check]],
                    checked_texture_offset_x = 0,
                    checked_texture_offset_y = 0,

                    on_create_checkbox = function(radioGroup, checkBox)
                        local icon = checkBox.Icon.widget
                        local selectedTexture = checkBox:CreateTexture(checkBox:GetName() .. "SelectedTexture", "border")
                        selectedTexture:SetTexture([[Interface\ExtraButton\Default]])
                        selectedTexture:SetTexCoord(155/256, 256/256, 40/128, 87/128)
                        selectedTexture:SetSize(150, 47)
                        selectedTexture:SetVertexColor(1, 1, 1, 0.834)
                        selectedTexture:SetPoint("topleft", icon, "topright", -5, -1)
                        selectedTexture:SetPoint("bottomleft", icon, "bottomright", -5, 1)
                        checkBox.SelectedTexture = selectedTexture
                        checkBox.SelectedTexture:Hide()
                    end,

                    on_click_option = function(radioGroup, checkBox, fixedParam, optionId)
                        local radioCheckboxes = radioGroup:GetAllCheckboxes()
                        for i = 1, #radioCheckboxes do
                            local thisCheckBox = radioCheckboxes[i]
                            thisCheckBox.SelectedTexture:Hide()
                            selectAddonFrame.currentSelected = fixedParam
                        end
                    end
                }

                ---@type df_radiogroup
                local selectAddonRadioGroup = detailsFramework:CreateRadioGroup(selectAddonFrame, mainTabSelectorRadioOptions, "$parentSelector", radioGroupSettings, radioGroupLayout)
                selectAddonRadioGroup:SetPoint("topleft", selectAddonFrame, "topleft", 2, -30)
                selectAddonRadioGroup:SetBackdrop(nil)

                --okay button to confirm
                local okayButton = detailsFramework:CreateButton(selectAddonFrame, function()
                    selectAddonFrame:Hide()
                    Details.slashk_addon = selectAddonFrame.currentSelected
                    end, 64, 20, "Okay")
                okayButton:SetPoint("bottom", selectAddonFrame, "bottom", 0, 30)
                okayButton:SetTemplate(detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))

                local foundAdded = false

                for i = 1, #mainTabSelectorRadioOptions do
                    local thisCheckBox = mainTabSelectorRadioOptions[i]
                    local param = thisCheckBox.param
                    if (param == Details.slashk_addon) then
                        selectAddonRadioGroup:Select(i)
                        foundAdded = true
                        break
                    end
                end

                if (not foundAdded) then
                    selectAddonRadioGroup:Select(1)
                    Details.slashk_addon = "details"
                end

                if (not Details.slashk_addon_first) then
                    if (_G.BigWigsLoader or _G.AstralKeys) then
                        --selectAddonFrame:Show()
                        --Details.slashk_addon_first = true
                    end
                end

                selectAddonFrame.currentSelected = Details.slashk_addon

                local scaleBar = detailsFramework:CreateScaleBar(f, Details.keystone_frame)
                scaleBar:SetAlpha(0.5)
                scaleBar.label:AdjustPointsOffset(-8, 0)
                f:SetScale(Details.keystone_frame.scale)

                local statusBar = detailsFramework:CreateStatusBar(f)
                statusBar.text = statusBar:CreateFontString(nil, "overlay", "GameFontNormal")
                statusBar.text:SetPoint("left", statusBar, "left", 5, 0)
                statusBar.text:SetText("By Terciob | From Details! Damage Meter")
                detailsFramework:SetFontSize(statusBar.text, 12)
                detailsFramework:SetFontColor(statusBar.text, "gray")

                local requestFromGuildButton = detailsFramework:CreateButton(f, function()
                    local guildName = GetGuildInfo("player")
                    if (guildName) then
                        f:RegisterEvent("GUILD_ROSTER_UPDATE")

                        C_Timer.NewTicker(1, function()
                            f:RefreshData()
                        end, 30)

                        C_Timer.After(30, function()
                            f:UnregisterEvent("GUILD_ROSTER_UPDATE")
                        end)
                        C_GuildInfo.GuildRoster()

                        openRaidLib.RequestKeystoneDataFromGuild()
                    end
                end, 100, 22, Loc["STRING_KEYSTONE_REQUEST_FROM_GUILD"])
                requestFromGuildButton:SetPoint("bottomleft", statusBar, "topleft", 2, 54)
                requestFromGuildButton:SetTemplate(detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
                requestFromGuildButton:SetIcon("UI-RefreshButton", 20, 20, "overlay", {0, 1, 0, 1}, "lawngreen")
                requestFromGuildButton:SetFrameLevel(f:GetFrameLevel()+5)
                f.RequestFromGuildButton = requestFromGuildButton
                --requestFromGuildButton:Hide()

                local recentPlayersFrame = CreateFrame("frame", nil, f, "BackdropTemplate")
                recentPlayersFrame:SetPoint("bottomleft", footer, "topleft", 0, 0)
                recentPlayersFrame:SetPoint("bottomright", footer, "topright", 0, 0)
                recentPlayersFrame:SetHeight(102)
                detailsFramework:ApplyStandardBackdrop(recentPlayersFrame)
                recentPlayersFrame:SetBackdropBorderColor(0, 0, 0, 0)
                f.RecentPlayersFrame = recentPlayersFrame

                recentPlayersFrame:Hide()

                recentPlayersFrame.Title = recentPlayersFrame:CreateFontString(nil, "overlay", "GameFontNormal")
                recentPlayersFrame.Title:SetPoint("bottomleft", recentPlayersFrame, "topleft", 3, 3)
                recentPlayersFrame.Title:SetText(Loc["STRING_RECENT_PLAYERS"])
                recentPlayersFrame:SetAlpha(0.834)
                detailsFramework:SetFontSize(recentPlayersFrame.Title, 12)

                local backgroundGradientTexture = detailsFramework:CreateTexture(recentPlayersFrame, {gradient = "vertical", fromColor = {0, 0, 0, 0.3}, toColor = {0, 0, 0, 0}}, 1, 60, "artwork", {0, 1, 0, 1})
                backgroundGradientTexture:SetPoint("bottomleft", recentPlayersFrame, "bottomleft", 0, 0)
                backgroundGradientTexture:SetPoint("bottomright", recentPlayersFrame, "bottomright", 0, 0)

                --grid scroll box for pick an aura and add it to tracking list of black list
                ---@type df_gridscrollbox_options
                local gridScrollBoxOptions = {
                    width = recentPlayersFrame:GetWidth() - 24,
                    height = recentPlayersFrame:GetHeight() - 6,
                    line_amount = 3,
                    line_height = 32,
                    columns_per_line = 5,
                    vertical_padding = 2,
                    horizontal_padding = 2,
                }

                local allRecentFriendsButtons = {}

                ---@class recent_friend_button : df_button
                ---@field specIcon texture
                ---@field roleIcon texture
                ---@field playerName fontstring
                ---@field activityType fontstring
                ---@field addToFriendsButton df_button
                ---@field runId number

                local openScoreBoardAtRunId = function(button)
                    if not DetailsMythicPlus then
                        Details:Msg(Loc["STRING_KEYSTONE_NO_MYTHICPLUS_ADDON"])
                        return
                    end
                    local dfButton = button.MyObject
                    local runId = dfButton.runId
                    if (runId) then
                        DetailsMythicPlus.Open(runId)
                    end
                end

                local onEnterRecentButton = function(self)
                    local dfButton = self.MyObject
                    GameCooltip:Preset(2)
                    GameCooltip:SetOwner(self)
                    GameCooltip:AddLine(Loc["STRING_KEYSTONE_CLICK_TO_VIEW_SCOREBOARD"])
                    if (not DetailsMythicPlus) then
                        --GameCooltip:AddLine("Install 'Details! Damage Meter Mythic+' addon.", "", 1, "#FFF33030")
                        GameCooltip:AddLine(Loc["STRING_KEYSTONE_NO_MYTHICPLUS_ADDON"], "", 1, "#FFF33030")
                        GameCooltip:AddLine(noMythicPlusAddonMsg, "", 1, "#FFFFFF00")
                        GameCooltip:SetOption("FixedWidth", 320)
                    end
                    GameCooltip:Show()
                end

                local onLeaveRecentButton = function(self)
                    GameCooltip:Hide()
                end

                --each line has more than 1 selection button, this function creates these buttons on each line
                local createRecentPlayerButton = function(line, lineIndex, columnIndex)
                    local width = gridScrollBoxOptions.width / gridScrollBoxOptions.columns_per_line - 1
                    local height = gridScrollBoxOptions.line_height
                    if (not height) then
                        height = 30
                    end

                    ---@type recent_friend_button
                    local button = detailsFramework:CreateButton(line, openScoreBoardAtRunId, width, 32)
                    button.textsize = 11
                    button:SetAlpha(0.934)

                    detailsFramework:ApplyStandardBackdrop(button)
                    local r, g, b = detailsFramework:GetDefaultBackdropColor()
                    button.__background:SetColorTexture(r, g, b, 0.2)
                    button:SetBackdropBorderColor(0, 0, 0, 0.25)

                    button:SetHook("OnEnter", onEnterRecentButton)
                    button:SetHook("OnLeave", onLeaveRecentButton)

                    allRecentFriendsButtons[#allRecentFriendsButtons+1] = button

                    local iconSize = 14

                    --specIcon
                    local specIcon = button:CreateTexture(nil, "overlay")
                    specIcon:SetSize(iconSize, iconSize)
                    specIcon:SetPoint("topleft", button.widget, "topleft", 3, -3)
                    specIcon:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]]) --placeholder icon

                    --role icon
                    local roleIcon = button:CreateTexture(nil, "overlay")
                    roleIcon:SetSize(iconSize, iconSize)
                    roleIcon:SetPoint("left", specIcon, "right", 1, 1)
                    roleIcon:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]]) --placeholder icon

                    --player name
                    local playerName = button:CreateFontString(nil, "overlay", "GameFontNormal")
                    playerName:SetPoint("left", roleIcon, "right", 2, 0)
                    playerName:SetText("Player Name") --place holder
                    detailsFramework:SetFontSize(playerName, 10)

                    --type
                    local activityType = button:CreateFontString(nil, "overlay", "GameFontNormal")
                    activityType:SetPoint("bottomleft", button.widget, "bottomleft", 3, 1)
                    activityType:SetText("Activity Type") --place holder
                    detailsFramework:SetFontSize(activityType, 9)

                    local addFriendButtonSize = 16

                    --add to friends list
                    local addToFriendsButton = detailsFramework:CreateButton(button.widget, function(self)
                        local dfButton = self.MyObject

                        --open the add friend dialog
                        FriendsFrameAddFriendButton_OnClick()
                        --write the friend name in the editbox
                        AddFriendNameEditBox:SetText(dfButton.playerName)
                        --click on the accept button
                        AddFriendEntryFrameAcceptButton:Click()

                        C_Timer.After(1, function()
                            local info = C_FriendList.GetFriendInfo(dfButton.playerName)
                            if (info and info.name) then
                                local timeWhen = detailsFramework.string.FormatDateByLocale(dfButton.recentPlayerTable[2], false)
                                local finalText = ""

                                local challengeMapId, level, onTime, runId = dfButton.recentPlayerTable[8], dfButton.recentPlayerTable[9], dfButton.recentPlayerTable[10], dfButton.recentPlayerTable[11]
                                local challengeMapInfo = LIB_OPEN_RAID_MYTHIC_PLUS_MAPINFO[challengeMapId]
                                if (challengeMapInfo) then
                                    local zoneName, challengeMapId, timeLimit, texture, textureBackground, mapId, teleportSpellId = unpack(challengeMapInfo)
                                    local shortName = detailsFramework.string.Acronym(zoneName)
                                    finalText = shortName .. " +" .. level
                                end

                                C_FriendList.SetFriendNotes(dfButton.playerName, "Added from Details! /keys.\n" .. timeWhen .. " Key: " .. finalText)
                            end
                        end)
    --[=[
    recentPlayerTable = {
    ["1"] = "mplus",
    [2] = 1755048825,
    ["3"] = "Yaxa",
    [4] = 1,
    [5] = 72,
    [6] = 2441,
    [7] = 1,
    [8] = 391,
    [9] = 2,
    ["10"] = true,
    [11] = 173,
    }
    --]=]

                    end, addFriendButtonSize, addFriendButtonSize)
                    addToFriendsButton:SetText("")
                    addToFriendsButton:SetPoint("bottomright", button, "bottomright", -2, 0)
                    addToFriendsButton.Texture = addToFriendsButton:CreateTexture(nil, "overlay")
                    addToFriendsButton.Texture:SetAllPoints()
                    addToFriendsButton.Texture:SetTexture("Interface\\FriendsFrame\\UI-Toast-FriendRequestIcon")
                    addToFriendsButton.Texture:SetTexCoord(.1, .9, .1, .9)
                    addToFriendsButton.Texture:SetVertexColor(detailsFramework:ParseColors("#FFF5F520"))

                    addToFriendsButton.tooltip = Loc["STRING_KEYSTONE_ADD_TO_FRIENDS_TOOLTIP"]

                    --[=[
                    local addToBnetButton = detailsFramework:CreateButton(button.widget, function()
                        --add the player to the bnet friends list
                    end, addFriendButtonSize, addFriendButtonSize)
                    addToBnetButton:SetText("")
                    addToBnetButton:SetPoint("right", addToFriendsButton, "left", 0, 0)
                    addToBnetButton.Texture = addToBnetButton:CreateTexture(nil, "overlay")
                    addToBnetButton.Texture:SetAllPoints()
                    addToBnetButton.Texture:SetTexture("Interface\\FriendsFrame\\UI-Toast-FriendRequestIcon")
                    addToBnetButton.Texture:SetTexCoord(.1, .9, .1, .9)
                    addToBnetButton.Texture:SetVertexColor(detailsFramework:ParseColors("#FF46A0D4"))
                    --]=]

                    local highlightTexture = button:CreateTexture(nil, "highlight")
                    highlightTexture:SetAllPoints()
                    highlightTexture:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
                    highlightTexture:SetBlendMode("ADD")
                    highlightTexture:SetAlpha(0.5)
                    highlightTexture:SetDesaturation(0.8)

                    --set the children members
                    button.specIcon = specIcon
                    button.roleIcon = roleIcon
                    button.playerName = playerName
                    button.activityType = activityType
                    button.addToFriendsButton = addToFriendsButton
                    --button.addToBnetButton = addToBnetButton

                    return button
                end

                local roleCoords = {
                    ["DAMAGER"] = {0, 0.25, 0, 0.5},
                    ["HEALER"] = {0.25, 0.5, 0, 0.5},
                    ["TANK"] = {0.5, 0.75, 0, 0.5},
                    ["NONE"] = {0.75, 1, 0, 0.5},
                }

                ---when the scroll is refreshing the line, the line will call this function for each selection button on it
                ---@param dfButton df_button
                ---@param recentPlayerTable table
                local refreshRecentFriends = function(dfButton, recentPlayerTable)
                    ---@cast dfButton recent_friend_button
                    local activityType, timeWhen, playerName, classId, specId, mapId, playedTogetherAmount, param1, param2, param3, param4 = Details:UnpackRecentPlayerTable(recentPlayerTable)

                    local mapInfo = C_Map.GetMapInfo(mapId)

                    --character name
                    dfButton.playerName:SetText(detailsFramework:AddClassColorToText(detailsFramework:RemoveRealmName(playerName), detailsFramework.ClassIndexToFileName[classId]))

                    --spec icon
                    dfButton.roleIcon:SetTexture("")

                    if (specId > 20) then
                        local specIcon, L, R, T, B = Details:GetSpecIcon(specId, false)
                        dfButton.specIcon:SetTexture(specIcon)
                        dfButton.specIcon:SetTexCoord(L, R, T, B)

                        --update role icon
                        local id, name, description, icon, role, classFile, className = GetSpecializationInfoByID(specId)
                        local texture L, R, T, B = detailsFramework:GetRoleIconAndCoords(role)

                        dfButton.roleIcon:SetTexture([[Interface\LFGFRAME\RoleIcons]])
                        dfButton.roleIcon:SetTexCoord(unpack(roleCoords[role]))

                    elseif (classId > 0) then
                        local classIcon, L, R, T, B = Details:GetClassIcon(detailsFramework.ClassIndexToFileName[classId], false)
                        dfButton.specIcon:SetTexture(classIcon)
                        dfButton.specIcon:SetTexCoord(L, R, T, B)
                    else
                        dfButton.specIcon:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]])
                    end

                    if (activityType == "mplus") then
                        local challengeMapId, level, onTime, runId = param1, param2, param3, param4
                        local challengeMapInfo = LIB_OPEN_RAID_MYTHIC_PLUS_MAPINFO[challengeMapId]
                        if (challengeMapInfo) then
                            local zoneName, challengeMapId, timeLimit, texture, textureBackground, mapId, teleportSpellId = unpack(challengeMapInfo)
                            local shortName = detailsFramework.string.Acronym(zoneName)
                            local finalText = shortName .. " +" .. level

                            local bAddAfterText, bAddSpace = false, true
                            local textureInfo = detailsFramework:CreateTextureInfo(texture, 18, 18, 0, 1, 0, 1, 256, 128)
                            finalText = detailsFramework:AddTextureToText(finalText, textureInfo, bAddSpace, bAddAfterText)

                            local onTimeColor = onTime and "FFA8E7A8" or "FFD69A9A"

                            local ignoreYear = true
                            local date = detailsFramework.string.FormatDateByLocale(timeWhen, ignoreYear)

                            finalText = finalText .. "   |cFFFFFF00" .. date .. "|r"

                            dfButton.activityType:SetText("|c" .. onTimeColor .. finalText .. "|r")
                            dfButton.runId = runId
                            dfButton.addToFriendsButton.playerName = playerName
                        else
                            dfButton.activityType:SetText("M+")
                        end
                    end

                    dfButton.recentPlayerTable = recentPlayerTable
                    dfButton.addToFriendsButton.recentPlayerTable = recentPlayerTable
                end

                local tbdData = {} --~grid
                local gridScrollBox = detailsFramework:CreateGridScrollBox(recentPlayersFrame, "DetailsMythicPlusRecentPlayersGrid", refreshRecentFriends, tbdData, createRecentPlayerButton, gridScrollBoxOptions)
                recentPlayersFrame.GridScrollBox = gridScrollBox
                gridScrollBox:SetPoint("topleft", recentPlayersFrame, "topleft", 0, 0)
                gridScrollBox:SetBackdrop({})
                gridScrollBox:SetBackdropColor(0, 0, 0, 0)
                gridScrollBox:SetBackdropBorderColor(0, 0, 0, 0)
                gridScrollBox.__background:Hide()
                gridScrollBox:Show()

                local headerOnClickCallback = function(headerFrame, columnHeader)
                    f.RefreshData()
                end

                local headerOptions = {
                    padding = 1,
                    header_backdrop_color = {.3, .3, .3, .8},
                    header_backdrop_color_selected = {.9, .9, 0, 1},
                    use_line_separators = false,
                    line_separator_color = {.1, .1, .1, .5},
                    line_separator_width = 1,
                    line_separator_height = CONST_WINDOW_HEIGHT-30,
                    line_separator_gap_align = true,
                    header_click_callback = headerOnClickCallback,
                }

                f.Header = detailsFramework:CreateHeader(f, keystoneHeaderTable, headerOptions, "DetailsKeystoneInfoFrameHeader")
                f.Header:SetPoint("topleft", f, "topleft", 2, -25)

                --scroll -~refresh
                local refreshScrollLines = function(self, data, offset, totalLines)
                    local RaiderIO = _G.RaiderIO
                    local faction = UnitFactionGroup("player") --this can get problems with 9.2.5 cross faction raiding

                    --for i = 1, GetNumGuildMembers() do
                    --end

                    for i = 1, totalLines do
                        local index = i + offset
                        local unitTable = data[index]

                        if (unitTable) then
                            local line = self:GetLine(i)

                            local unitName, level, mapID, challengeMapID, classID, rating, mythicPlusMapID, classIconTexture, iconTexCoords, mapName, inMyParty, isOnline, isGuildMember, specId = unpack(unitTable)
                            local challengeMapInfo = LIB_OPEN_RAID_MYTHIC_PLUS_MAPINFO[challengeMapID]

                            line.unitName = unitName

                            if (mapName == "") then
                                mapName = "user need update details!"
                            end

                            local rioProfile
                            if (RaiderIO) then
                                local playerName, playerRealm = unitName:match("(.+)%-(.+)")
                                if (playerName and playerRealm) then
                                    rioProfile = RaiderIO.GetProfile(playerName, playerRealm, faction == "Horde" and 2 or 1)
                                    if (rioProfile) then
                                        rioProfile = rioProfile.mythicKeystoneProfile
                                    end
                                else
                                    rioProfile = RaiderIO.GetProfile(unitName, GetRealmName(), faction == "Horde" and 2 or 1)
                                    if (rioProfile) then
                                        rioProfile = rioProfile.mythicKeystoneProfile
                                    end
                                end
                            end

                            local unitRole = detailsFramework.UnitGroupRolesAssigned(unitName)
                            if (specId and specId > 20) then
                                local id, name, description, icon, role, classFile, className = GetSpecializationInfoByID(specId)
                                unitRole = role
                                local specIcon, L, R, T, B = Details:GetSpecIcon(specId, false)
                                line.icon:SetTexture(specIcon)
                                line.icon:SetTexCoord(L, R, T, B)
                            else
                                line.icon:SetTexture(classIconTexture)
                                local L, R, T, B = unpack(iconTexCoords)
                                line.icon:SetTexCoord(L+0.02, R-0.02, T+0.02, B-0.02)
                            end

                            local role = unitRole
                            if (role == "DAMAGER") then
                                line.roleIcon:SetAtlas("GM-icon-role-dps")
                            elseif (role == "HEALER") then
                                line.roleIcon:SetAtlas("GM-icon-role-healer")
                            elseif (role == "TANK") then
                                line.roleIcon:SetAtlas("GM-icon-role-tank")
                            else
                                line.roleIcon:SetColorTexture(.1, .1, .1, .3)
                            end

                            --remove the realm name from the player name (if any)
                            local unitNameNoRealm = detailsFramework:RemoveRealmName(unitName)
                            line.playerNameText.text = unitNameNoRealm
                            line.keystoneLevelText.text = level

                            local shortMapName = mapName
                            if (mapName and mapName:find(":")) then
                                shortMapName = mapName:match(":%s*(.+)")
                            end

                            local mapTexture = challengeMapInfo and challengeMapInfo[4]
                            if (mapTexture) then
                                local bAddAfterText, bAddSpace = false, true
                                local textureInfo = detailsFramework:CreateTextureInfo(mapTexture, 20, 20, 0, 1, 0, 1, 256, 128)
                                local textWithTexture = detailsFramework:AddTextureToText(shortMapName, textureInfo, bAddSpace, bAddAfterText)
                                line.dungeonNameText.text = textWithTexture
                            else
                                line.dungeonNameText.text = shortMapName
                            end

                            detailsFramework:TruncateText(line.dungeonNameText, 150)
                            line.classicDungeonNameText.text = "" --mapNameChallenge
                            detailsFramework:TruncateText(line.classicDungeonNameText, 120)
                            line.inMyParty = inMyParty > 0
                            line.inMyGuild = isGuildMember

                            local likesGiven = DetailsMythicPlus and DetailsMythicPlus.GetRunIdLikesGivenByPlayerSelf and DetailsMythicPlus.GetRunIdLikesGivenByPlayerSelf(unitName) or {}
                            line.LikesGivenText:SetText(#likesGiven)

                            local refreshRunDropdown = function(self)
                                local options = {}
                                local unitName = self.playerName
                                local runIdsWhereLikesWereGiven = DetailsMythicPlus and DetailsMythicPlus.GetRunIdLikesGivenByPlayerSelf and DetailsMythicPlus.GetRunIdLikesGivenByPlayerSelf(unitName)
                                if (runIdsWhereLikesWereGiven and #runIdsWhereLikesWereGiven > 0) then
                                    for j = 1, #runIdsWhereLikesWereGiven do
                                        local runId = runIdsWhereLikesWereGiven[j]

                                        --dumpt(DetailsMythicPlus.GetRunIdLikesGivenByPlayerSelf("Anseis")) --development debug

                                        ---@type dropdownoption
                                        local option = {
                                            label = DetailsMythicPlus.GetSimpleDescription(runId),
                                            onclick = function()
                                                DetailsMythicPlus.Open(runId)
                                            end
                                        }
                                        options[#options + 1] = option
                                    end
                                end

                                return options
                            end

                            if (not line.selectRunDropdown:IsOpen()) then
                                line.selectRunDropdown:SetFunction(refreshRunDropdown)
                                line.selectRunDropdown.playerName = unitName
                                line.selectRunDropdown:Refresh()
                            end

                            if (challengeMapInfo) then
                                local texture = LIB_OPEN_RAID_MYTHIC_PLUS_MAPINFO[challengeMapID][4]
                                local spellId = LIB_OPEN_RAID_MYTHIC_PLUS_MAPINFO[challengeMapID][7]

                                if (spellId and line.teleportButton.spellId ~= spellId) then
                                    local spellCooldownInfo = GetSpellCooldown(spellId)
                                    local start = spellCooldownInfo.startTime
                                    local cooldownDuration = spellCooldownInfo.duration

                                    line.teleportButton.Icon:SetTexture(texture)
                                    local haveSet, errorText = pcall(function()
                                        if ((start and start >= 1) or not C_SpellBook.IsSpellInSpellBook(spellId)) then
                                            line.blockTeleporterButton:Show()
                                            line.blockTeleporterButton.Text:SetText("")
                                            line.blockTeleporterButton.Icon:SetTexture("")

                                            if (not InCombatLockdown()) then
                                                line.teleportButton:Show()
                                                line.teleportButton:SetParent(line)

                                                if (C_SpellBook.IsSpellInSpellBook(spellId)) then
                                                    line.teleportButton.Text:SetText(detailsFramework:IntegerToCooldownTime((start + cooldownDuration) - GetTime()))
                                                else
                                                    line.teleportButton.Text:SetText("")
                                                    line.teleportButton.Icon:SetTexture("")
                                                    --line.blockTeleporterButton.Text:SetText(Loc["STRING_TELEPORT"])
                                                    line.blockTeleporterButton.Text:SetText("")
                                                    line.blockTeleporterButton.Icon:SetTexture(texture)
                                                end
                                            end

                                            return --get out from pcall
                                        end

                                        if (not InCombatLockdown()) then
                                            line.teleportButton:Show()
                                            line.teleportButton:SetAttribute("spell", spellId)
                                            line.teleportButton.spellId = spellId
                                            --line.teleportButton.Text:SetText(Loc["STRING_TELEPORT"])
                                            line.teleportButton.Text:SetText("")
                                            line.teleportButton:SetParent(line)
                                            line.blockTeleporterButton:Hide()
                                        else
                                            line.teleportButton.Text:SetText("In Combat") --is legal?
                                            line.blockTeleporterButton.Text:SetText("")
                                            line.blockTeleporterButton.Icon:SetTexture("")
                                            line.blockTeleporterButton:Show()
                                        end
                                    end)

                                    if (not haveSet) then
                                        print("ERROR:", errorText)
                                    end
                                end
                            else
                                --line.teleportButton:SetAttribute("spell", nil)
                            end

                            if (rioProfile) then
                                local score = rioProfile.currentScore or 0
                                local previousScore = rioProfile.previousScore or 0
                                if (previousScore > score) then
                                    score = previousScore
                                    line.ratingText.text = rating .. " (" .. score .. ")"
                                else
                                    line.ratingText.text = rating
                                end
                            else
                                line.ratingText.text = rating
                            end

                            if (line.inMyParty) then
                                line:SetBackdropColor(unpack(backdrop_color_inparty))
                            elseif (isGuildMember) then
                                line:SetBackdropColor(unpack(backdrop_color_inguild))
                            else
                                line:SetBackdropColor(unpack(backdrop_color))
                            end

                            if (isOnline) then
                                line.playerNameText.textcolor = "white"
                                line.keystoneLevelText.textcolor = "white"
                                line.dungeonNameText.textcolor = "white"
                                line.classicDungeonNameText.textcolor = "white"
                                line.ratingText.textcolor = "white"
                                line.icon:SetAlpha(1)
                            else
                                line.playerNameText.textcolor = "gray"
                                line.keystoneLevelText.textcolor = "gray"
                                line.dungeonNameText.textcolor = "gray"
                                line.classicDungeonNameText.textcolor = "gray"
                                line.ratingText.textcolor = "gray"
                                line.icon:SetAlpha(.6)
                            end
                        end
                    end

                    local likesGivenHeader = f.Header:GetHeaderColumnByName("likesGiven")
                    if (likesGivenHeader and not likesGivenHeader.helpButton) then
                        local helpButton = CreateFrame("button", "$parentHelpButton", likesGivenHeader, "BackdropTemplate")
                        helpButton:SetSize(24, 24)
                        helpButton:SetPoint("right", likesGivenHeader, "right", -2, 0)
                        helpButton:SetNormalTexture("Interface/Buttons/AdventureGuideMicrobuttonAlert")
                        helpButton:SetHighlightTexture("Interface/Buttons/AdventureGuideMicrobuttonAlert")
                        helpButton:SetPushedTexture("Interface/Buttons/AdventureGuideMicrobuttonAlert")
                        helpButton:SetScript("OnEnter", function()
                            GameCooltip:Preset(2)
                            GameCooltip:SetOwner(helpButton, "bottom", "top", 0, 5)
                            GameCooltip:AddLine(Loc["STRING_KEYSTONE_LIFETIME_LIKES_YOU_GAVE"], "", 1)
                            GameCooltip:Show()
                        end)
                        helpButton:SetScript("OnLeave", function()
                            GameCooltip:Hide()
                        end)
                        likesGivenHeader.helpButton = helpButton
                    end
                end

                local scrollFrame = detailsFramework:CreateScrollBox(f, "$parentScroll", refreshScrollLines, {}, CONST_WINDOW_WIDTH-10, CONST_WINDOW_HEIGHT-121, CONST_SCROLL_LINE_AMOUNT, CONST_SCROLL_LINE_HEIGHT)
                scrollFrame:SetBackdropBorderColor(0, 0, 0, 0)
                detailsFramework:ReskinSlider(scrollFrame)
                scrollFrame.ScrollBar:AdjustPointsOffset(-23, -1)
                scrollFrame.ScrollBar:SetFrameLevel(scrollFrame:GetFrameLevel() + 5)
                scrollFrame.ScrollBar:SetHeight(scrollFrame.ScrollBar:GetHeight() - 20)
                local point1, frame1, point2, offSetX, offSetY = scrollFrame.ScrollBar:GetPoint(2)
                scrollFrame.ScrollBar:SetPoint(point1, frame1, point2, offSetX, offSetY + 22)

                scrollFrame:SetPoint("topleft", f.Header, "bottomleft", -1, -1)
                scrollFrame:SetPoint("topright", f.Header, "bottomright", 0, -1)

                local lineOnEnter = function(self)
                    if (self.inMyParty) then
                        self:SetBackdropColor(unpack(backdrop_color_on_enter_inparty))
                    elseif (self.inMyGuild) then
                        self:SetBackdropColor(unpack(backdrop_color_on_enter_inguild))
                    else
                        self:SetBackdropColor(unpack(backdrop_color_on_enter))
                    end
                end
                local lineOnLeave = function(self)
                    if (self.inMyParty) then
                        self:SetBackdropColor(unpack(backdrop_color_inparty))
                    elseif (self.inMyGuild) then
                        self:SetBackdropColor(unpack(backdrop_color_inguild))
                    else
                        self:SetBackdropColor(unpack(backdrop_color))
                    end
                end

                local refreshDropdown = function(self)
                    return {}
                end

                local createLineForScroll = function(self, index)
                    local line = CreateFrame("frame", "$parentLine" .. index, self, "BackdropTemplate")
                    line:SetPoint("topleft", self, "topleft", 1, -((index-1) * (CONST_SCROLL_LINE_HEIGHT + 1)) - 1)
                    line:SetSize(scrollFrame:GetWidth() - 2, CONST_SCROLL_LINE_HEIGHT)

                    line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
                    line:SetBackdropColor(unpack(backdrop_color))

                    detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)

                    line:SetScript("OnEnter", lineOnEnter)
                    line:SetScript("OnLeave", lineOnLeave)

                    --class icon
                    local icon = line:CreateTexture("$parentClassIcon", "overlay")
                    icon:SetSize(CONST_SCROLL_LINE_HEIGHT - 2, CONST_SCROLL_LINE_HEIGHT - 2)

                    local roleIcon = line:CreateTexture("$parentRoleIcon", "overlay")
                    roleIcon:SetSize(CONST_SCROLL_LINE_HEIGHT+2, CONST_SCROLL_LINE_HEIGHT+2)
                    roleIcon:SetPoint("left", icon, "right", -1, 0)

                    --player name
                    local playerNameText = detailsFramework:CreateLabel(line, "")

                    --keystone level
                    local keystoneLevelText = detailsFramework:CreateLabel(line, "")

                    --dungeon name
                    local dungeonNameText = detailsFramework:CreateLabel(line, "")
                    detailsFramework:SetFontSize(dungeonNameText, 10)

                    --classic dungeon name
                    local classicDungeonNameText = detailsFramework:CreateLabel(line, "")

                    --player rating
                    local ratingText = detailsFramework:CreateLabel(line, "")

                    --cast teleport button
                    local teleportButton = buttonsCreated[index]
                    --teleportButton:SetBackdrop({bgFile = "Interface\\AddOns\\Details\\images\\background", tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}})
                    --teleportButton:SetBackdropColor(0.2, 0.2, 0.2, 0.8)

                    local blockTeleporterButton = CreateFrame("button", "$parentBlockTeleporterButton", line)
                    blockTeleporterButton:SetAllPoints(teleportButton)
                    blockTeleporterButton:SetFrameLevel(teleportButton:GetFrameLevel() + 10)
                    blockTeleporterButton:EnableMouse(true)

                    blockTeleporterButton.Icon = blockTeleporterButton:CreateTexture(nil, "overlay")
                    blockTeleporterButton.Icon:SetSize(CONST_SCROLL_LINE_HEIGHT - 2, CONST_SCROLL_LINE_HEIGHT - 2)
                    blockTeleporterButton.Icon:SetPoint("left", blockTeleporterButton, "left", 2, 0)
                    blockTeleporterButton.Icon:SetAlpha(0.3)
                    blockTeleporterButton.Icon:SetDesaturation(0.8)
                    detailsFramework:SetMask(blockTeleporterButton.Icon, [[Interface\AddOns\Details\images\masks\portal_mask.tga]])
                    blockTeleporterButton.Text = blockTeleporterButton:CreateFontString(nil, "overlay", "GameFontNormal")
                    blockTeleporterButton.Text:SetPoint("left", blockTeleporterButton.Icon, "right", 2, 0)
                    blockTeleporterButton.Text:SetAlpha(0.3)
                    detailsFramework:SetFontColor(blockTeleporterButton.Text, "gray")

                    local likesGivenText = detailsFramework:CreateLabel(line, "")
                    local selectRunDropdown = detailsFramework:CreateDropDown(line, refreshDropdown, 1, 112, 20, "selectRunDropdown", "$parentDropdown", detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
                    selectRunDropdown.widget:SetFrameLevel(line:GetFrameLevel() + 16)

                    line.icon = icon
                    line.roleIcon = roleIcon
                    line.playerNameText = playerNameText
                    line.keystoneLevelText = keystoneLevelText
                    line.dungeonNameText = dungeonNameText
                    line.classicDungeonNameText = classicDungeonNameText
                    line.ratingText = ratingText
                    line.teleportButton = teleportButton
                    line.blockTeleporterButton = blockTeleporterButton
                    line.LikesGivenText = likesGivenText
                    line.selectRunDropdown = selectRunDropdown

                    line:AddFrameToHeaderAlignment(icon)
                    line:AddFrameToHeaderAlignment(playerNameText)
                    line:AddFrameToHeaderAlignment(keystoneLevelText)
                    line:AddFrameToHeaderAlignment(dungeonNameText)
                    --line:AddFrameToHeaderAlignment(classicDungeonNameText)
                    line:AddFrameToHeaderAlignment(ratingText)
                    line:AddFrameToHeaderAlignment(teleportButton)
                    line:AddFrameToHeaderAlignment(likesGivenText)
                    line:AddFrameToHeaderAlignment(selectRunDropdown)

                    line:AlignWithHeader(f.Header, "left")
                    return line
                end

                --create lines
                for i = 1, CONST_SCROLL_LINE_AMOUNT do
                    scrollFrame:CreateLine(createLineForScroll)
                end

                local recentPlayers = Details:GetRecentPlayers()
                local recentPlayerCopy = detailsFramework.table.copy({}, recentPlayers)
                recentPlayers = recentPlayerCopy

                --for i = #recentPlayers, 1, -1 do
                --	local playerData = recentPlayers[i]
                --	if (playerData[3] == "fakePlayer1") then
                --		table.remove(recentPlayers, i)
                --	end
                --end

                --table.wipe(recentPlayers)
                --[=[
                    recentPlayers[#recentPlayers+1] = {"mplus", time()-3600, "fakePlayer1", 8, 63, 2526, 2, 402, 6, false, 172}
                    recentPlayers[#recentPlayers+1] = {"mplus", time()-3600, "fakePlayer1", 8, 63, 2526, 2, 402, 6, true, 171}
                    recentPlayers[#recentPlayers+1] = {"mplus", time()-3600, "fakePlayer1", 8, 63, 2526, 2, 402, 6, true, 170}
                    recentPlayers[#recentPlayers+1] = {"mplus", time()-3600, "fakePlayer1", 8, 63, 2526, 2, 402, 6, true, 0}
                    recentPlayers[#recentPlayers+1] = {"mplus", time()-3600, "fakePlayer1", 8, 63, 2526, 2, 402, 6, false, 0}
                    recentPlayers[#recentPlayers+1] = {"mplus", time()-3600, "fakePlayer1", 8, 63, 2526, 2, 402, 6, true, 0}
                    recentPlayers[#recentPlayers+1] = {"mplus", time()-3600, "fakePlayer1", 8, 63, 2526, 2, 402, 6, true, 0}
                    recentPlayers[#recentPlayers+1] = {"mplus", time()-3600, "fakePlayer1", 8, 63, 2526, 2, 402, 6, true, 0}
                    recentPlayers[#recentPlayers+1] = {"mplus", time()-3600, "fakePlayer1", 8, 63, 2526, 2, 402, 6, true, 0}
                    recentPlayers[#recentPlayers+1] = {"mplus", time()-3600, "fakePlayer1", 8, 63, 2526, 2, 402, 6, true, 0}
                    recentPlayers[#recentPlayers+1] = {"mplus", time()-3600, "fakePlayer1", 8, 63, 2526, 2, 402, 6, true, 0}
                --]=]

                function f.RefreshData() --~refreshdata
                    local newData = {}
                    newData.offlineGuildPlayers = {}
                    local keystoneData = openRaidLib.GetAllKeystonesInfo()



                    f.RecentPlayersFrame.GridScrollBox:SetData(recentPlayers) --Details:GetRecentPlayers()
                    f.RecentPlayersFrame.GridScrollBox:Refresh()

                    --need to know if any line has its dropdown open
                    local lines = scrollFrame:GetLines()

                    --unit name
                    local unitNameOnLineWithDropdownOpened

                    for i = 1, #lines do
                        local dropdown = lines[i].selectRunDropdown
                        if (dropdown:IsOpen()) then
                            unitNameOnLineWithDropdownOpened = lines[i].unitName
                            break
                        end
                    end

                    --[=[
                        ["Exudragão"] =  {
                            ["mapID"] = 2526,
                            ["challengeMapID"] = 402,
                            ["mythicPlusMapID"] = 0,
                            ["rating"] = 215,
                            ["classID"] = 13,
                            ["level"] = 6,
                        },
                    --]=]

                    if (false) then
                        keystoneData["FakePlayer"] =  {
                                ["mapID"] = 1763,
                                ["challengeMapID"] = 244,
                                ["mythicPlusMapID"] = 0,
                                ["rating"] = 215,
                                ["classID"] = 13,
                                ["level"] = 6,
                            }
                        keystoneData["Gimsei"] =  {
                                ["mapID"] = 2441, --1763,
                                ["challengeMapID"] = 391, --244,
                                ["mythicPlusMapID"] = 0,
                                ["rating"] = 215,
                                ["classID"] = 13,
                                ["level"] = 6,
                            }
                        keystoneData["Gimsi"] =  {
                                ["mapID"] = 2441, --1763,
                                ["challengeMapID"] = 391, --244,
                                ["mythicPlusMapID"] = 0,
                                ["rating"] = 215,
                                ["classID"] = 13,
                                ["level"] = 6,
                            }
                        keystoneData["FakePlaywer"] =  {
                                ["mapID"] = 1763,
                                ["challengeMapID"] = 244,
                                ["mythicPlusMapID"] = 0,
                                ["rating"] = 215,
                                ["classID"] = 13,
                                ["level"] = 6,
                            }
                    end

                    local guildUsers = {}
                    local totalMembers, onlineMembers, onlineAndMobileMembers = GetNumGuildMembers()

                    --[=[
                    local unitsInMyGroup = {
                        [Details:GetFullName("player")] = true,
                    }
                    for i = 1, GetNumGroupMembers() do
                        local unitName = Details:GetFullName("party" .. i)
                        unitsInMyGroup[unitName] = true
                    end
                    --]=]

                    --create a string to use into the gsub call when removing the realm name from the player name, by default all player names returned from GetGuildRosterInfo() has PlayerName-RealmName format
                    local realmNameGsub = "%-.*"
                    local guildName = GetGuildInfo("player")

                    if (guildName) then
                        for i = 1, totalMembers do
                            local fullName, rank, rankIndex, level, class, zone, note, officernote, online, isAway, classFileName, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
                            if (fullName) then
                                fullName = fullName:gsub(realmNameGsub, "")
                                if (online) then
                                    guildUsers[fullName] = true
                                end
                            else
                                break
                            end
                        end
                    end

                    local playersAdded = {}

                    --from open raid lib
                    if (keystoneData) then
                        local unitsAdded = {}
                        local isOnline = true

                        for unitName, keystoneInfo in pairs(keystoneData) do
                            local classId = keystoneInfo.classID
                            local classIcon = [[Interface\GLUES\CHARACTERCREATE\UI-CharacterCreate-Classes]]
                            local coords = CLASS_ICON_TCOORDS
                            local _, class = GetClassInfo(classId)
                            local specId = keystoneInfo.specID or 0

                            local mapName = C_ChallengeMode.GetMapUIInfo(keystoneInfo.mythicPlusMapID)
                            if (not mapName) then
                                mapName = C_ChallengeMode.GetMapUIInfo(keystoneInfo.challengeMapID)
                            end
                            if (not mapName and keystoneInfo.mapID) then
                                mapName = C_ChallengeMode.GetMapUIInfo(keystoneInfo.mapID)
                            end

                            mapName = mapName or "map name not found"

                            --local mapInfoChallenge = C_Map.GetMapInfo(keystoneInfo.challengeMapID)
                            --local mapNameChallenge = mapInfoChallenge and mapInfoChallenge.name or ""

                            local isInMyParty = UnitInParty(unitName) and (string.byte(unitName, 1) + string.byte(unitName, 2)) or 0
                            local isGuildMember = guildName and guildUsers[unitName] and true

                            if (keystoneInfo.level > 0 or keystoneInfo.rating > 0) then
                                local keystoneTable = {
                                    unitName,
                                    keystoneInfo.level,
                                    keystoneInfo.mapID,
                                    keystoneInfo.challengeMapID,
                                    keystoneInfo.classID,
                                    keystoneInfo.rating,
                                    keystoneInfo.mythicPlusMapID,
                                    classIcon,
                                    coords[class],
                                    mapName, --10
                                    isInMyParty,
                                    isOnline, --is false when the unit is from the cache
                                    isGuildMember, --is a guild member
                                    specId,
                                    --mapNameChallenge,
                                }

                                newData[#newData+1] = keystoneTable --this is the table added into the keystone cache
                                unitsAdded[unitName] = true

                                --is this unitName listed as a player in the player's guild?
                                if (isGuildMember) then
                                    --store the player information into a cache
                                    keystoneTable.guild_name = guildName
                                    keystoneTable.date = time()
                                    Details.keystone_cache[unitName] = keystoneTable
                                end
                            end
                        end

                        local cutoffDate = time() - (86400 * 7) --7 days
                        for unitName, keystoneTable in pairs(Details.keystone_cache) do
                            --this unit in the cache isn't shown?
                            if (not unitsAdded[unitName] and keystoneTable.guild_name == guildName and keystoneTable.date > cutoffDate) then
                                if (keystoneTable[2] > 0 or keystoneTable[6] > 0) then
                                    keystoneTable[11] = UnitInParty(unitName) and (string.byte(unitName, 1) + string.byte(unitName, 2)) or 0 --isInMyParty
                                    keystoneTable[12] = false --isOnline
                                    newData[#newData+1] = keystoneTable
                                    unitsAdded[unitName] = true
                                end
                            end
                        end
                    end


                    --get which column is currently selected and the sort order
                    local columnIndex, order = f.Header:GetSelectedColumn()
                    local sortByIndex = 2

                    --sort by player class
                    if (columnIndex == 1) then
                        sortByIndex = 5

                    --sort by player name
                    elseif (columnIndex == 2) then
                        sortByIndex = 1

                    --sort by keystone level
                    elseif (columnIndex == 3) then
                        sortByIndex = 2

                    --sort by dungeon name
                    elseif (columnIndex == 4) then
                        sortByIndex = 3

                    --sort by classic dungeon name
                    --elseif (columnIndex == 5) then
                    --	sortByIndex = 4

                    --sort by mythic+ ranting
                    elseif (columnIndex == 5) then
                        sortByIndex = 6
                    end

                    if (order == "DESC") then
                        table.sort(newData, function(t1, t2) return t1[sortByIndex] > t2[sortByIndex] end)
                    else
                        table.sort(newData, function(t1, t2) return t1[sortByIndex] < t2[sortByIndex] end)
                    end

                    --remove offline guild players from the list
                    for i = #newData, 1, -1 do
                        local keystoneTable = newData[i]
                        if (not keystoneTable[12]) then
                            table.remove(newData, i)
                            newData.offlineGuildPlayers[#newData.offlineGuildPlayers+1] = keystoneTable
                        end
                    end

                    newData.offlineGuildPlayers = detailsFramework.table.reverse(newData.offlineGuildPlayers)

                    --put players in the group at the top of the list
                    if (IsInGroup() and not IsInRaid()) then
                        local playersInTheParty = {}
                        for i = #newData, 1, -1 do
                            local keystoneTable = newData[i]
                            if (keystoneTable[11] > 0) then
                                playersInTheParty[#playersInTheParty+1] = keystoneTable
                                table.remove(newData, i)
                            end
                        end

                        if (#playersInTheParty > 0) then
                            table.sort(playersInTheParty, function(t1, t2) return t1[11] > t2[11] end)
                            for i = 1, #playersInTheParty do
                                local keystoneTable = playersInTheParty[i]
                                table.insert(newData, 1, keystoneTable)
                            end
                        end
                    end

                    --reinsert offline guild players into the data
                    local offlinePlayers = newData.offlineGuildPlayers
                    for i = 1, #offlinePlayers do
                        local keystoneTable = offlinePlayers[i]
                        newData[#newData+1] = keystoneTable
                    end

                    scrollFrame:SetData(newData)
                    scrollFrame:Refresh()

                    if (unitNameOnLineWithDropdownOpened) then
                        for i = 1, #lines do
                            local unitName = lines[i].unitName
                            if (unitName == unitNameOnLineWithDropdownOpened) then
                                lines[i].selectRunDropdown:Open()
                                break
                            end
                        end
                    end
                end

                function f.OnKeystoneUpdate(unitId, keystoneInfo, allKeystonesInfo)
                    if (f:IsShown()) then
                        f.RefreshData()
                    end
                end

                f:SetScript("OnHide", function()
                    openRaidLib.UnregisterCallback(DetailsKeystoneInfoFrame, "KeystoneUpdate", "OnKeystoneUpdate")
                end)

                f:SetScript("OnUpdate", function(self, deltaTime)
                    if (not self.lastUpdate) then
                        self.lastUpdate = 0
                    end

                    self.lastUpdate = self.lastUpdate + deltaTime
                    if (self.lastUpdate > 3) then
                        self.lastUpdate = 0
                        self.RefreshData()
                    end
                end)

                f.lastGuildRequest = GetTime()
                local guildName = GetGuildInfo("player")
                if (guildName) then
                    f.RequestFromGuildButton:Click()
                end
            end

            --show the frame
            if (DetailsKeystoneInfoFrame:IsShown()) then
                DetailsKeystoneInfoFrame:Hide()
                return
            else
                DetailsKeystoneInfoFrame:Show()
            end

            openRaidLib.RegisterCallback(DetailsKeystoneInfoFrame, "KeystoneUpdate", "OnKeystoneUpdate")

            local guildName = GetGuildInfo("player")
            if (guildName) then
                --call an update on the guild roster
                if (C_GuildInfo and C_GuildInfo.GuildRoster) then
                    C_GuildInfo.GuildRoster()
                end
                DetailsKeystoneInfoFrame.RequestFromGuildButton:Enable()

                if (DetailsKeystoneInfoFrame.lastGuildRequest and GetTime() - DetailsKeystoneInfoFrame.lastGuildRequest > 60) then
                    DetailsKeystoneInfoFrame.lastGuildRequest = GetTime()
                    DetailsKeystoneInfoFrame.RequestFromGuildButton:Click()
                end
            else
                DetailsKeystoneInfoFrame.RequestFromGuildButton:Disable()
            end

            --openRaidLib.WipeKeystoneData()

            if (IsInRaid()) then
                openRaidLib.RequestKeystoneDataFromRaid()
            elseif (IsInGroup()) then
                openRaidLib.RequestKeystoneDataFromParty()
            end

            DetailsKeystoneInfoFrame.RefreshData()
        end
    end

    Details222.MythicKeys.OpenKeysPanel = function()
        openKeysPanel()
    end
end