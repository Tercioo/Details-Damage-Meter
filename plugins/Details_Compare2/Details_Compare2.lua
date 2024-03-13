
do
	local Details = Details
	if (not Details) then
		print("Details! Not Found.")
		return
	end

	local CONST_COMPARETYPE_SPEC = 1
	local CONST_COMPARETYPE_SEGMENT = 2

	--compare two or more players
	--'main player' is the player who opened the comparison window and will be compared to the other players
	--'another player' is a terms used to refer to the other players being compared to the main player
	--the scrollboxes for the main player being compared are created in the compare frame, the scrollboxes for the other players are created in the compareplayerframe

	--search ~start to go to the start of the main code

	local weakTable = {__mode = "v"}

	---@class compare : frame
	---@field mainPlayerObject actor the actor object of the main player being compared
	---@field isComparisonTab boolean indicates this frame is part of the comparison tab
	---@field mainSpellTable spelltable the spell table of the main player being compared
	---@field mainTargetTable comparetargettable[]
	---@field comparisonFrames compareplayerframe[] these are the frames that are used to show data from other players
	---@field mainSpellFrameScroll comparescrollbox scrollbox for the main player spells
	---@field mainTargetFrameScroll comparescrollbox scrollbox for the main player targets
	---@field mainPlayerName df_label a text to show the player name above the main main frame scroll, indicates the name of the player being compared
	---@field comparisonScrollFrameIndex number the index of the next comparison scroll frame to be created or getten, when the comparison is reset, this index is reset to 0
	---@field __background texture a texture from ApplyStandardBackdrop()
	---@field comparisonSpellTable comparespelltable[] hold the spell data for all other players which will be compared with the main player
	---@field comparisonTargetTable comparetargettable[] hold the target data for all other players which will be compared with the main player
	---@field radioGroup df_radiogroup a radio group to select the comparison type
	---@field radioGroupBackgroundTexture texture a background texture for the radio group
	---@field
	---@field GetCompareFrame fun():compareplayerframe return a frame which has two scrolls, one for spells and another for targets, is used to show data of another player
	---@field ResetComparisonFrames fun() reset all comparison frames
	---@field RefreshAllComparisonScrollFrames fun() refresh all comparison scroll frames
	---@field GetMainPlayerName fun():actorname return the actor name of the actor being compared
	---@field GetMainPlayerObject fun():actor return the actor object of the actor being compared
	---@field GetMainSpellTable fun():spelltable return the spell table of the actor being compared
	---@field GetMainTargetTable fun():table return the target table of the actor being compared
	---@field GetAllComparisonFrames fun():compareplayerframe[] return all comparison frames

	---@class compareplayerframe : frame object containing two scrollboxes, one for spells and another for targets, is used to show comparison data of another player
	---@field spellsScroll comparescrollbox
	---@field targetsScroll comparescrollbox
	---@field titleIcon df_image shows the combat icon
	---@field titleLabel df_label text to show the player name or segment name above the frame scroll, indicates the name or segment being compared
	---@field playerObject actor
	---@field mainPlayer actor
	---@field mainSpellTable spelltable
	---@field mainTargetTable comparetargettable
	---@field combatTimeLabel df_label

	---@class comparespelltable : spelltable
	---@field spellId number?
	---@field total number?
	---@field spellName string?
	---@field spellIcon string?
	---@field amount number?
	---@field rawSpellTable spelltable?
	---@field line comparescrollline?
	---@field mainSpellAmount number? amount done by the main player
	---@field npcId number?

	---@class comparetargettable : table
	---@field targetName string?
	---@field amount number?
	---@field originalName string? the actor name without alterations
	---@field rawPlayerObject actor?
	---@field total number?
	---@field line comparescrollline?
	---@field mainTargetAmount number?

	---@class comparepettable : spelltable
	---@field rawSpellTable spelltable

	---@class compareactortable : table
	---@field actor actor
	---@field total number
	---@field combat combat

	---@class comparesettings : table
	---@field compare_type number

	---@class comparescrollbox : df_scrollbox
	---@field lineHeight number
	---@field scrollWidth number
	---@field fontSize number
	---@field playerObject actor
	---@field bIsMain boolean

	---@class comparescrollline : button
	---@field spellIcon texture
	---@field spellName fontstring
	---@field spellAmount fontstring
	---@field spellPercent fontstring
	---@field lineType "MainPlayerSpell"|"MainPlayerTarget"|"OtherPlayerTarget"|"OtherPlayerSpell"
	---@field spellId number
	---@field spellTable comparespelltable
	---@field BackgroundColor number[]
	---@field targetTable comparetargettable
	---@field targetName string

	local _
	local ipairs = ipairs
	local unpack = _G.unpack

	--> minimal details version required to run this plugin
	local MINIMAL_DETAILS_VERSION_REQUIRED = 136
	local COMPARETWO_VERSION = "v1.0.0"

	--> create a plugin object
	local compareTwo = Details:NewPluginObject("Details_Compare2", _G.DETAILSPLUGIN_ALWAYSENABLED)

	---@type detailsframework
	local detailsFramework = DetailsFramework

	--> set the description
	compareTwo:SetPluginDescription("Replaces the default comparison window on the player breakdown.")

	local sortByTotalKey = function(t1, t2)
		return t1.total > t2.total
	end

	--> when receiving an event from details, handle it here
	local handle_details_event = function(event, ...)
		if (event == "COMBAT_PLAYER_ENTER") then

		elseif (event == "COMBAT_PLAYER_LEAVE") then

		elseif (event == "PLUGIN_DISABLED") then
			--> plugin has been disabled at the details options panel

		elseif (event == "PLUGIN_ENABLED") then
			--> plugin has been enabled at the details options panel

		elseif (event == "DETAILS_DATA_SEGMENTREMOVED") then
			--> old segment got deleted by the segment limit

		elseif (event == "DETAILS_DATA_RESET") then
			--> combat data got wiped

		end
	end

	function compareTwo.InstallAdvancedCompareWindow()
        --colors to use on percent number
		local red = "FFFFAAAA"
		local green = "FFAAFFAA"
		local plus = red .. "-"
		local minor = green .. "+"

		local comparisonFrameSettings = {
			--main player scroll frame
			mainScrollWidth = 250,
			petColor = "|cFFCCBBBB",

			--spell scroll
			spellScrollHeight = 300,
			spellLineAmount = 14,
			spellLineHeight = 20,

			--target scroll
			targetScrollHeight = 130,
			targetScrollLineAmount = 6,
			targetScrollLineHeight = 20,

			--comparison scrolls
			comparisonScrollWidth = 140,
			targetMaxLines = 16,
			targetTooltipLineHeight = 16,

			compareTitleIconSize = 15,

			--font settings
			fontSize = 10,
			playerNameSize = 11,
			playerNameYOffset = 15,

			spellIconAlpha = 0.923,

			--line colors
			lineOnEnterColor = {.85, .85, .85, .5},

			--tooltips
			tooltipBorderColor = {.2, .2, .2, .9},
		}

		local comparisonLineContrast = {{1, 1, 1, .1}, {1, 1, 1, 0}}
		local latestLinesHighlighted = {}
		local comparisonTooltips = {nextTooltip = 0}
		local comparisonTargetTooltips = {nextTooltip = 0}

		local resetTargetComparisonTooltip = function()
			comparisonTargetTooltips.nextTooltip = 0
			for _, tooltip in ipairs(comparisonTargetTooltips) do
				for i = 1, #tooltip.lines do
					local line = tooltip.lines [i]
					line.spellIcon:SetTexture("")
					line.spellName:SetText("")
					line.spellAmount:SetText("")
					line.spellPercent:SetText("")
					line:Hide()
				end

				tooltip:Hide()
				tooltip:ClearAllPoints()
			end
		end

		local resetComparisonTooltip = function()
			comparisonTooltips.nextTooltip = 0
			for _, tooltip in ipairs(comparisonTooltips) do
				tooltip:Hide()
				tooltip:ClearAllPoints()
			end
		end

		local getTargetComparisonTooltip = function()
			comparisonTargetTooltips.nextTooltip = comparisonTargetTooltips.nextTooltip + 1
			local tooltip = comparisonTargetTooltips [comparisonTargetTooltips.nextTooltip]

			if (tooltip) then
				return tooltip
			end

			tooltip = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
			tooltip:SetFrameStrata("tooltip")
			tooltip:SetSize(1, 1)
			detailsFramework:CreateBorder(tooltip)
			tooltip:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
			tooltip:SetBackdropColor(.2, .2, .2, .99)
			tooltip:SetBackdropBorderColor(unpack(comparisonFrameSettings.tooltipBorderColor))
			tooltip:SetHeight(77)

			local bg_color = {0.5, 0.5, 0.5}
			local bg_texture = [[Interface\AddOns\Details\images\bar_background]]
			local bg_alpha = 1
			local bg_height = 12
			local colors = {{26/255, 26/255, 26/255}, {19/255, 19/255, 19/255}, {26/255, 26/255, 26/255}, {34/255, 39/255, 42/255}, {42/255, 51/255, 60/255}}

			--player name label
			tooltip.player_name_label = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.player_name_label:SetPoint("bottomleft", tooltip, "topleft", 1, 2)
			tooltip.player_name_label:SetTextColor(1, .7, .1, .834)
			detailsFramework:SetFontSize(tooltip.player_name_label, 11)

			local name_bg = tooltip:CreateTexture(nil, "artwork")
			name_bg:SetTexture(bg_texture)
			name_bg:SetPoint("bottomleft", tooltip, "topleft", 0, 1)
			name_bg:SetPoint("bottomright", tooltip, "topright", 0, 1)
			name_bg:SetHeight(bg_height + 2)
			name_bg:SetAlpha(bg_alpha)
			name_bg:SetVertexColor(unpack(colors[2]))

			comparisonTargetTooltips [comparisonTargetTooltips.nextTooltip] = tooltip

			tooltip.lines = {}

			local lineHeight = comparisonFrameSettings.targetTooltipLineHeight
			local fontSize = 10

			for i = 1, comparisonFrameSettings.targetMaxLines do
				local line = CreateFrame("frame", nil, tooltip, "BackdropTemplate")
				line:SetPoint("topleft", tooltip, "topleft", 0, -(i-1) *(lineHeight + 1))
				line:SetPoint("topright", tooltip, "topright", 0, -(i-1) *(lineHeight + 1))
				line:SetHeight(lineHeight)

				line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
				line:SetBackdropColor(0, 0, 0, 0.2)

				local spellIcon = line:CreateTexture("$parentIcon", "overlay")
				spellIcon:SetSize(lineHeight -2 , lineHeight - 2)

				local spellName = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
				local spellAmount = line:CreateFontString("$parentAmount", "overlay", "GameFontNormal")
				local spellPercent = line:CreateFontString("$parentPercent", "overlay", "GameFontNormal")

				detailsFramework:SetFontSize(spellName, fontSize)
				detailsFramework:SetFontSize(spellAmount, fontSize)
				detailsFramework:SetFontSize(spellPercent, fontSize)

				spellIcon:SetPoint("left", line, "left", 2, 0)
				spellName:SetPoint("left", spellIcon, "right", 2, 0)
				spellAmount:SetPoint("right", line, "right", -2, 0)
				spellPercent:SetPoint("right", line, "right", -40, 0)

				spellName:SetJustifyH("left")
				spellAmount:SetJustifyH("right")
				spellPercent:SetJustifyH("right")

				line.spellIcon = spellIcon
				line.spellName = spellName
				line.spellAmount = spellAmount
				line.spellPercent = spellPercent

				tooltip.lines [#tooltip.lines+1] = line

				if (i % 2 == 0) then
					line:SetBackdropColor(unpack(comparisonLineContrast [1]))
					line.BackgroundColor = comparisonLineContrast [1]
				else
					line:SetBackdropColor(unpack(comparisonLineContrast [2]))
					line.BackgroundColor = comparisonLineContrast [2]
				end
			end

			return tooltip
		end

		local getComparisonTooltip = function()
			comparisonTooltips.nextTooltip = comparisonTooltips.nextTooltip + 1
			local tooltip = comparisonTooltips [comparisonTooltips.nextTooltip]

			if (tooltip) then
				return tooltip
			end

			tooltip = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
			tooltip:SetFrameStrata("tooltip")
			tooltip:SetSize(1, 1)
			detailsFramework:CreateBorder(tooltip)
			tooltip:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
			tooltip:SetBackdropColor(0, 0, 0, 1)
			tooltip:SetBackdropBorderColor(unpack(comparisonFrameSettings.tooltipBorderColor))
			tooltip:SetHeight(77)

			comparisonTooltips [comparisonTooltips.nextTooltip] = tooltip

			--prototype
			local y = -3
			local x_start = 2

			local bg_color = {0.5, 0.5, 0.5}
			local bg_texture = [[Interface\AddOns\Details\images\bar_background]]
			local bg_alpha = 1
			local bg_height = 12
			local colors = {{26/255, 26/255, 26/255}, {19/255, 19/255, 19/255}, {26/255, 26/255, 26/255}, {34/255, 39/255, 42/255}, {42/255, 51/255, 60/255}}

			local background = tooltip:CreateTexture(nil, "border")
			background:SetTexture([[Interface\SPELLBOOK\Spellbook-Page-1]])
			background:SetTexCoord(.6, 0.1, 0, 0.64453125)
			background:SetVertexColor(0, 0, 0, 0.2)
			background:SetPoint("topleft", tooltip, "topleft", 0, 0)
			background:SetPoint("bottomright", tooltip, "bottomright", 0, 0)

			--player name label
			tooltip.player_name_label = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.player_name_label:SetPoint("bottomleft", tooltip, "topleft", 1, 2)
			tooltip.player_name_label:SetTextColor(1, .7, .1, .834)
			detailsFramework:SetFontSize(tooltip.player_name_label, 11)

			local name_bg = tooltip:CreateTexture(nil, "artwork")
			name_bg:SetTexture(bg_texture)
			name_bg:SetPoint("bottomleft", tooltip, "topleft", 0, 1)
			name_bg:SetPoint("bottomright", tooltip, "topright", 0, 1)
			name_bg:SetHeight(bg_height + 2)
			name_bg:SetAlpha(bg_alpha)
			name_bg:SetVertexColor(unpack(colors[2]))

			--cast line
			tooltip.casts_label = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.casts_label:SetPoint("topleft", tooltip, "topleft", x_start, -2 +(y*0))
			tooltip.casts_label:SetText("Casts:")
			tooltip.casts_label:SetJustifyH("left")
			tooltip.casts_label2 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.casts_label2:SetPoint("topright", tooltip, "topright", -x_start, -2 +(y*0))
			tooltip.casts_label2:SetText("0")
			tooltip.casts_label2:SetJustifyH("right")
			tooltip.casts_label3 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.casts_label3:SetPoint("topright", tooltip, "topright", -x_start - 46, -2 +(y*0))
			tooltip.casts_label3:SetText("0")
			tooltip.casts_label3:SetJustifyH("right")

			--hits
			tooltip.hits_label = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.hits_label:SetPoint("topleft", tooltip, "topleft", x_start, -14 +(y*1))
			tooltip.hits_label:SetText("Hits:")
			tooltip.hits_label:SetJustifyH("left")
			tooltip.hits_label2 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.hits_label2:SetPoint("topright", tooltip, "topright", -x_start, -14 +(y*1))
			tooltip.hits_label2:SetText("0")
			tooltip.hits_label2:SetJustifyH("right")
			tooltip.hits_label3 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.hits_label3:SetPoint("topright", tooltip, "topright", -x_start - 46, -14 +(y*1))
			tooltip.hits_label3:SetText("0")
			tooltip.hits_label3:SetJustifyH("right")

			--average
			tooltip.average_label = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.average_label:SetPoint("topleft", tooltip, "topleft", x_start, -26 +(y*2))
			tooltip.average_label:SetText("Average:")
			tooltip.average_label:SetJustifyH("left")
			tooltip.average_label2 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.average_label2:SetPoint("topright", tooltip, "topright", -x_start, -26 +(y*2))
			tooltip.average_label2:SetText("0")
			tooltip.average_label2:SetJustifyH("right")
			tooltip.average_label3 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.average_label3:SetPoint("topright", tooltip, "topright", -x_start - 46, -26 +(y*2))
			tooltip.average_label3:SetText("0")
			tooltip.average_label3:SetJustifyH("right")

			--critical
			tooltip.crit_label = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.crit_label:SetPoint("topleft", tooltip, "topleft", x_start, -38 +(y*3))
			tooltip.crit_label:SetText("Critical:")
			tooltip.crit_label:SetJustifyH("left")
			tooltip.crit_label2 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.crit_label2:SetPoint("topright", tooltip, "topright", -x_start, -38 +(y*3))
			tooltip.crit_label2:SetText("0")
			tooltip.crit_label2:SetJustifyH("right")
			tooltip.crit_label3 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.crit_label3:SetPoint("topright", tooltip, "topright", -x_start - 46, -38 +(y*3))
			tooltip.crit_label3:SetText("0")
			tooltip.crit_label3:SetJustifyH("right")

			--uptime
			tooltip.uptime_label = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.uptime_label:SetPoint("topleft", tooltip, "topleft", x_start, -50 +(y*4))
			tooltip.uptime_label:SetText("Uptime:")
			tooltip.uptime_label:SetJustifyH("left")
			tooltip.uptime_label2 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.uptime_label2:SetPoint("topright", tooltip, "topright", -x_start, -50 +(y*4))
			tooltip.uptime_label2:SetText("0")
			tooltip.uptime_label2:SetJustifyH("right")
			tooltip.uptime_label3 = tooltip:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			tooltip.uptime_label3:SetPoint("topright", tooltip, "topright", -x_start - 46, -50 +(y*4))
			tooltip.uptime_label3:SetText("0")
			tooltip.uptime_label3:SetJustifyH("right")

			for i = 1, 5 do
				local bg_line1 = tooltip:CreateTexture(nil, "artwork")
				bg_line1:SetTexture(bg_texture)
				bg_line1:SetPoint("topleft", tooltip, "topleft", 0, -2 +(((i-1) * 12) * -1) +(y *(i-1)) + 2)
				bg_line1:SetPoint("topright", tooltip, "topright", -0, -2 +(((i-1) * 12) * -1)  +(y *(i-1)) + 2)
				bg_line1:SetHeight(bg_height + 4)
				bg_line1:SetAlpha(bg_alpha)
				bg_line1:SetVertexColor(unpack(colors[i]))
			end

			return tooltip
		end

		--fill the tooltip for the main player being compared
		--actualPlayerName is the name of the player being compared, playerName can be the name of a pet
		local fillMainSpellTooltip = function(line, rawSpellTable, actualPlayerName, playerName)
			local tooltip = getComparisonTooltip()
			local formatFunc = Details:GetCurrentToKFunction()
			local spellId = rawSpellTable.id

			tooltip.player_name_label:SetText(Details:GetOnlyName(actualPlayerName))

			local fullPercent = "100%"
			local noData = "-"

			--amount of casts
			local combatObject = Details:GetCombatFromBreakdownWindow()
			local castAmount = combatObject:GetSpellCastAmount(playerName, GetSpellInfo(spellId))
			local playerMiscObject = combatObject:GetActor(DETAILS_ATTRIBUTE_MISC, playerName)

			if (castAmount > 0) then
				tooltip.casts_label2:SetText(fullPercent)
				tooltip.casts_label3:SetText(castAmount)
				detailsFramework:SetFontColor(tooltip.casts_label2, "gray")
				detailsFramework:SetFontColor(tooltip.casts_label3, "white")
			else
				tooltip.casts_label2:SetText(noData)
				tooltip.casts_label3:SetText(noData)
				detailsFramework:SetFontColor(tooltip.casts_label2, "silver")
				detailsFramework:SetFontColor(tooltip.casts_label3, "silver")
			end

			--hit amount
			tooltip.hits_label2:SetText(fullPercent)
			detailsFramework:SetFontColor(tooltip.hits_label2, "gray")
			tooltip.hits_label3:SetText(rawSpellTable.counter)
			detailsFramework:SetFontColor(tooltip.hits_label3, "white")

			--average
			tooltip.average_label2:SetText(fullPercent)
			detailsFramework:SetFontColor(tooltip.average_label2, "gray")
			local average = rawSpellTable.total / rawSpellTable.counter
			tooltip.average_label3:SetText(formatFunc(_, average))

			--critical strikes
			tooltip.crit_label2:SetText(fullPercent)
			detailsFramework:SetFontColor(tooltip.crit_label2, "gray")
			tooltip.crit_label3:SetText(rawSpellTable.c_amt)

			--uptime
			local uptime = 0
			if (playerMiscObject) then
				local spell = playerMiscObject.debuff_uptime_spells and playerMiscObject.debuff_uptime_spells._ActorTable and playerMiscObject.debuff_uptime_spells._ActorTable [spellId]
				if (spell) then
					local minutos, segundos = floor(spell.uptime / 60), floor(spell.uptime % 60)
					uptime = spell.uptime
					tooltip.uptime_label2:SetText(fullPercent)
					tooltip.uptime_label3:SetText(minutos .. "m " .. segundos .. "s")

					detailsFramework:SetFontColor(tooltip.uptime_label2, "gray")
					detailsFramework:SetFontColor(tooltip.uptime_label3, "white")
				else
					tooltip.uptime_label2:SetText(noData)
					tooltip.uptime_label3:SetText(noData)
					detailsFramework:SetFontColor(tooltip.uptime_label2, "gray")
					detailsFramework:SetFontColor(tooltip.uptime_label3, "gray")
				end
			else
				tooltip.uptime_label2:SetText(noData)
				tooltip.uptime_label3:SetText(noData)
				detailsFramework:SetFontColor(tooltip.uptime_label2, "gray")
				detailsFramework:SetFontColor(tooltip.uptime_label3, "gray")
			end

			--show tooltip
			tooltip:SetPoint("bottom", line, "top", 0, 2)
			tooltip:SetWidth(line:GetWidth())
			tooltip:Show()

			--highlight line
			line:SetBackdropColor(unpack(comparisonFrameSettings.lineOnEnterColor))
			latestLinesHighlighted [#latestLinesHighlighted + 1] = line

			return true, castAmount, rawSpellTable.counter, average, rawSpellTable.c_amt, uptime
		end

		local getPercentComparison = function(value1, value2)
			if (value1 == 0 and value2 == 0) then
				return "|c" .. minor .. "0%|r"

			elseif (value1 >= value2) then
				local diff = value1 - value2
				local up

				if (diff == 0 or value2 == 0) then
					up = "0"
				else
					up = diff / value2 * 100
					up = floor(up)

					if (up > 999) then
						up = "" .. 999
					end
				end

				return "|c" .. minor .. up .. "%|r"
			else
				local diff = value2 - value1
				local down

				if (diff == 0 or value1 == 0) then
					down = "0"
				else
					down = diff / value1 * 100
					down = floor(down)
					if (down > 999) then
						down = "" .. 999
					end
				end

				return "|c" .. plus .. down .. "%|r"
			end
		end

		--fill the tooltip for comparison lines
		--actualPlayerName is the name of the player being compared, playerName can be the name of a pet
		local fillComparisonSpellTooltip = function(line, rawSpellTable, actualPlayerName, playerName, mainCastAmount, mainHitCounter, mainAverageDamage, mainCritAmount, mainAuraUptime)
			local tooltip = getComparisonTooltip()
			local formatFunc = Details:GetCurrentToKFunction()
			local spellId = rawSpellTable.id
			local noData = "-"

			tooltip.player_name_label:SetText(Details:GetOnlyName(actualPlayerName))

			--amount of casts
			local combatObject = Details:GetCombatFromBreakdownWindow()
			local playerMiscObject = combatObject:GetActor(DETAILS_ATTRIBUTE_MISC, playerName)

			local castAmount = combatObject:GetSpellCastAmount(playerName, GetSpellInfo(spellId))
			if (castAmount > 0) then
				tooltip.casts_label2:SetText(getPercentComparison(mainCastAmount, castAmount))
				tooltip.casts_label3:SetText(castAmount)
				detailsFramework:SetFontColor(tooltip.casts_label2, "white")
				detailsFramework:SetFontColor(tooltip.casts_label3, "white")
			else
				tooltip.casts_label2:SetText(noData)
				tooltip.casts_label3:SetText(noData)
				detailsFramework:SetFontColor(tooltip.casts_label2, "silver")
				detailsFramework:SetFontColor(tooltip.casts_label3, "silver")
			end

			--hits
			tooltip.hits_label2:SetText(getPercentComparison(mainHitCounter, rawSpellTable.counter))
			tooltip.hits_label3:SetText(rawSpellTable.counter)
			detailsFramework:SetFontColor(tooltip.hits_label2, "white")
			detailsFramework:SetFontColor(tooltip.hits_label3, "white")

			--average
			local average = rawSpellTable.total / rawSpellTable.counter
			tooltip.average_label2:SetText(getPercentComparison(mainAverageDamage, average))
			tooltip.average_label3:SetText(formatFunc(_, average))
			detailsFramework:SetFontColor(tooltip.average_label3, "white")
			detailsFramework:SetFontColor(tooltip.average_label2, "white")

			--critical strikes
			tooltip.crit_label2:SetText(getPercentComparison(mainCritAmount, rawSpellTable.c_amt))
			tooltip.crit_label3:SetText(rawSpellTable.c_amt)
			detailsFramework:SetFontColor(tooltip.crit_label2, "white")
			detailsFramework:SetFontColor(tooltip.crit_label2, "white")

			--uptime
			local uptime = 0
			if (playerMiscObject) then
				local spell = playerMiscObject.debuff_uptime_spells and playerMiscObject.debuff_uptime_spells._ActorTable and playerMiscObject.debuff_uptime_spells._ActorTable [spellId]
				if (spell) then
					local minutos, segundos = floor(spell.uptime / 60), floor(spell.uptime % 60)
					uptime = spell.uptime
					tooltip.uptime_label2:SetText(getPercentComparison(mainAuraUptime, uptime))
					tooltip.uptime_label3:SetText(minutos .. "m " .. segundos .. "s")

					detailsFramework:SetFontColor(tooltip.uptime_label2, "white")
					detailsFramework:SetFontColor(tooltip.uptime_label3, "white")
				else
					tooltip.uptime_label2:SetText(noData)
					tooltip.uptime_label3:SetText(noData)
					detailsFramework:SetFontColor(tooltip.uptime_label2, "gray")
					detailsFramework:SetFontColor(tooltip.uptime_label3, "gray")
				end
			else
				tooltip.uptime_label2:SetText(noData)
				tooltip.uptime_label3:SetText(noData)
				detailsFramework:SetFontColor(tooltip.uptime_label2, "gray")
				detailsFramework:SetFontColor(tooltip.uptime_label3, "gray")
			end

			--show tooltip
			tooltip:SetPoint("bottom", line, "top", 0, 2)
			tooltip:SetWidth(line:GetWidth())
			tooltip:Show()

			--highlight line
			line:SetBackdropColor(unpack(comparisonFrameSettings.lineOnEnterColor))
			latestLinesHighlighted [#latestLinesHighlighted + 1] = line
		end

		---@param compareScrollLine comparescrollline
		local comparisonLineOnEnter = function(compareScrollLine)
			---@type comparescrollbox
			local scrollFrame = compareScrollLine:GetParent()
			local comparePlugin

			if (scrollFrame.bIsMain) then
				--comparescrollbox > compare
				comparePlugin = scrollFrame:GetParent()
			else
				--comparescrollbox > compareplayerframe > compare
				comparePlugin = scrollFrame:GetParent():GetParent()
			end

			---@cast comparePlugin compare

			--check if this is a mainline (from the main player) or a compareplayer line (from another player)
			if (compareScrollLine.lineType == "MainPlayerSpell" or compareScrollLine.lineType == "OtherPlayerSpell") then
				--get data
				---@type comparespelltable
				local spellTable = compareScrollLine.spellTable
				local isPet = spellTable.npcId
				local npcId = spellTable.npcId
				local spellId = spellTable.spellId

				local mainPlayerObject = comparePlugin.GetMainPlayerObject()
				local mainSpellFrameScroll = comparePlugin.mainSpellFrameScroll

				--store the spell information from the main tooltip
				local mainHasTooltip, castAmount, hitCounter, averageDamage, critAmount, auraUptime

				--iterate on the main player scroll and find the line corresponding to the same spell hovered over
				--doesn't matter if the hovered over line is already the main line, the search will be performed
				local mainFrameLines = mainSpellFrameScroll:GetLines()
				for i = 1, #mainFrameLines do
					---@type comparescrollline
					local line = mainFrameLines[i]
					if (line.spellTable and line:IsShown()) then
						if (isPet) then
							if (line.spellTable.spellId == spellId and line.spellTable.npcId == npcId) then
								--main line for the hover over spell
								local rawSpellTable = line.spellTable.rawSpellTable
								mainHasTooltip, castAmount, hitCounter, averageDamage, critAmount, auraUptime = fillMainSpellTooltip(line, rawSpellTable, mainPlayerObject:Name(), line.spellTable.originalName)
								break
							end
						else
							if (line.spellTable.spellId == spellId and not line.spellTable.npcId) then
								--main line for the hover over spell
								local rawSpellTable = line.spellTable.rawSpellTable
								mainHasTooltip, castAmount, hitCounter, averageDamage, critAmount, auraUptime = fillMainSpellTooltip(line, rawSpellTable, mainPlayerObject:Name(), mainPlayerObject:Name())
								break
							end
						end
					end
				end

				if (mainHasTooltip) then
					local allComparisonFrames = comparePlugin.GetAllComparisonFrames()

					--iterate among all other comparison scrolls
					for compareFrameIdx = 1, #allComparisonFrames do
						---@type compareplayerframe
						local comparisonFrame = allComparisonFrames[compareFrameIdx]
						if (comparisonFrame:IsShown()) then
							local spellScrollBox = comparisonFrame.spellsScroll
							local playerObject = comparisonFrame.playerObject
							local playerName = playerObject:Name()

							local frameLines = spellScrollBox:GetFrames()
							for lineIdx = 1, #frameLines do
								local line = frameLines[lineIdx]
								if (line.spellTable and line:IsShown() and line.spellTable.rawSpellTable) then
									if (isPet) then
										if (line.spellTable.spellId == spellId and line.spellTable.npcId == npcId) then
											--line for the hover over spell in a comparison scroll frame
											local rawSpellTable = line.spellTable.rawSpellTable
											fillComparisonSpellTooltip(line, rawSpellTable, playerName, line.spellTable.originalName, castAmount, hitCounter, averageDamage, critAmount, auraUptime)
										end
									else
										if (line.spellTable.spellId == spellId and not line.spellTable.npcId) then
											--line for the hover over spell in a comparison scroll frame
											local rawSpellTable = line.spellTable.rawSpellTable
											fillComparisonSpellTooltip(line, rawSpellTable, playerName, playerName, castAmount, hitCounter, averageDamage, critAmount, auraUptime)
										end
									end
								end
							end
						end
					end
				end

			elseif (compareScrollLine.lineType == "MainPlayerTarget" or compareScrollLine.lineType == "OtherPlayerTarget") then
				local targetName = compareScrollLine.targetTable.originalName
				local attribute = Details:GetDisplayTypeFromBreakdownWindow()

				local mainPlayerObject = comparePlugin.GetMainPlayerObject()
				local damageDoneBySpell = {}

				--find the main line
				--iterate on the main player scroll and find the line
				local mainLine
				local mainSpellFrameScroll = comparePlugin.mainTargetFrameScroll
				local mainFrameLines = mainSpellFrameScroll:GetLines()

				for i = 1, #mainFrameLines do
					local line = mainFrameLines[i]
					if (line.targetTable and line:IsShown()) then
						if (line.targetTable.originalName == targetName) then
							mainLine = line
							break
						end
					end
				end

				if (not mainLine) then
					return
				end

				--spells
				for spellId, spellTable in pairs(mainPlayerObject:GetActorSpells()) do
					local damageOnTarget = spellTable.targets[targetName]
					if (damageOnTarget and damageOnTarget > 0) then
						damageDoneBySpell [#damageDoneBySpell + 1] = {spellTable, damageOnTarget, mainPlayerObject:Name(), mainPlayerObject, false}
					end
				end

				--pets
				for _, petName in ipairs(mainPlayerObject:Pets()) do
					local petObject = Details:GetCombatFromBreakdownWindow():GetActor(attribute, petName)
					if (petObject) then
						for spellId, spellTable in pairs(petObject:GetActorSpells()) do
							local damageOnTarget = spellTable.targets [targetName]
							if (damageOnTarget and damageOnTarget > 0) then
								damageDoneBySpell [#damageDoneBySpell + 1] = {spellTable, damageOnTarget, petName, petObject, detailsFramework:GetNpcIdFromGuid(petObject.serial)}
							end
						end
					end
				end

				table.sort(damageDoneBySpell, detailsFramework.SortOrder2)

				local tooltip = getTargetComparisonTooltip()
				local formatFunc = Details:GetCurrentToKFunction()
				local mainHasTooltip = false
				tooltip.player_name_label:SetText(mainPlayerObject:GetDisplayName())

				for i = 1, #damageDoneBySpell do
					local damageTable = damageDoneBySpell [i]
					local spellTable = damageTable [1]
					local damageDone = damageTable [2]
					local actorName = damageTable [3]
					local actorObject = damageTable [4]
					local npcId = damageTable [5]

					local spellName, _, spellIcon = Details.GetSpellInfo(spellTable.id)

					local line = tooltip.lines [i]
					if (not line) then
						break
					end

					if (npcId) then
						spellName = spellName .. "(" .. comparisonFrameSettings.petColor .. actorName:gsub(" <.*", "") .. "|r)"
					end

					line.spellName:SetText(spellName)
					detailsFramework:TruncateText(line.spellName, mainSpellFrameScroll:GetWidth() - 110)

					line.spellIcon:SetTexture(spellIcon)
					line.spellIcon:SetTexCoord(.1, .9, .1, .9)
					line.spellAmount:SetText("100%")
					detailsFramework:SetFontColor(line.spellAmount, "gray")
					line.spellPercent:SetText(formatFunc(_, damageDone))

					line:Show()
					mainHasTooltip = true
				end

				--comparison
				if (mainHasTooltip) then
					local allComparisonFrames = comparePlugin.GetAllComparisonFrames()
					local combatObject = Details:GetCombatFromBreakdownWindow()

					--iterate among all other comparison scrolls
					for i = 1, #allComparisonFrames do
						local comparisonFrame = allComparisonFrames [i]
						if (comparisonFrame:IsShown()) then
							local scrollBox = comparisonFrame.targetsScroll
							local playerObject = comparisonFrame.playerObject

							local targetLines = scrollBox:GetFrames()
							for o = 1, #targetLines do
								local line = targetLines [o]
								if (line and line.targetTable and line:IsShown()) then
									if (line.targetTable.originalName == targetName) then

										--get a tooltip for this actor
										local actorTooltip = getTargetComparisonTooltip()

										actorTooltip:SetPoint("bottom", line, "top", 0, 2)
										actorTooltip:SetWidth(line:GetWidth())
										actorTooltip:SetHeight(min(comparisonFrameSettings.targetMaxLines, #damageDoneBySpell) * comparisonFrameSettings.targetTooltipLineHeight + comparisonFrameSettings.targetMaxLines)
										actorTooltip:Show()

										actorTooltip.player_name_label:SetText(playerObject:GetDisplayName())

										--highlight line
										line:SetBackdropColor(unpack(comparisonFrameSettings.lineOnEnterColor))
										latestLinesHighlighted [#latestLinesHighlighted + 1] = line

										--iterate among all spells in the first tooltip and fill here
										--if is a pet line, need to get the data from the player pet instead


										for a = 1, #damageDoneBySpell do
											local damageTable = damageDoneBySpell [a]
											local spellTable = damageTable [1]
											local damageDone = damageTable [2]
											local actorName = damageTable [3]
											local actorObject = damageTable [4]
											local npcId = damageTable [5]

											local foundSpell

											-- i is also the tooltip line index

											if (not npcId) then
												local spellObject = playerObject:GetSpell(spellTable.id)
												if (spellObject) then
													local damageOnTarget = spellObject.targets [targetName] or 0
													if (damageOnTarget > 0) then
														--this actor did damage on this target, add into the tooltip
														local tooltipLine = actorTooltip.lines [a]
														if (not tooltipLine) then
															break
														end

														local spellName, _, spellIcon = Details.GetSpellInfo(spellTable.id)

														tooltipLine.spellName:SetText("")
														tooltipLine.spellIcon:SetTexture(spellIcon)
														tooltipLine.spellIcon:SetTexCoord(.1, .9, .1, .9)

														-- calculate percent
														local mainSpellDamageOnTarget = 0
														-- find this spell in the main actor table
														for u = 1, #damageDoneBySpell do
															local mainSpell = damageDoneBySpell [u]

															local spellTableMain = damageTable [1]
															local damageDoneMain = damageTable [2]
															local actorNameMain = damageTable [3]
															local actorObjectMain = damageTable [4]
															local npcIdMain = damageTable [5]

															if (not npcIdMain and spellTableMain.id == spellObject.id) then
																--found the spell in the main table
																mainSpellDamageOnTarget = damageDoneMain
																break
															end
														end

														tooltipLine.spellAmount:SetText(getPercentComparison(mainSpellDamageOnTarget, damageOnTarget))
														tooltipLine.spellPercent:SetText(formatFunc(_, damageOnTarget))

														tooltipLine:Show()
														foundSpell = true
													end
												end
											else
												--iterate among all pets the player has and find one with the same npcId
												for _, petName in ipairs(playerObject:Pets()) do
													local petObject = combatObject:GetActor(attribute, petName)
													if (petObject) then
														local petNpcId = detailsFramework:GetNpcIdFromGuid(petObject.serial)
														if (petNpcId and petNpcId == npcId) then
															--found the correct pet
															local spellObject = petObject:GetSpell(spellTable.id)
															if (spellObject) then
																local damageOnTarget = spellObject.targets [targetName] or 0
																if (damageOnTarget > 0) then
																	--this pet did damage on this target, add into the tooltip

																	local tooltipLine = actorTooltip.lines [a]
																	if (not tooltipLine) then
																		break
																	end

																	-- calculate percent
																	local mainSpellDamageOnTarget = 0
																	-- find this spell in the main actor table
																	for u = 1, #damageDoneBySpell do
																		local mainSpell = damageDoneBySpell [u]

																		local spellTableMain = damageTable [1]
																		local damageDoneMain = damageTable [2]
																		local actorNameMain = damageTable [3]
																		local actorObjectMain = damageTable [4]
																		local npcIdMain = damageTable [5]

																		if (npcIdMain and npcIdMain == petNpcId and spellTableMain.id == spellObject.id) then
																			--found the spell in the main table
																			mainSpellDamageOnTarget = damageDoneMain
																			break
																		end
																	end

																	local spellName, _, spellIcon = Details.GetSpellInfo(spellTable.id)

																	tooltipLine.spellName:SetText("")
																	tooltipLine.spellIcon:SetTexture(spellIcon)
																	tooltipLine.spellIcon:SetTexCoord(.1, .9, .1, .9)
																	tooltipLine.spellAmount:SetText(getPercentComparison(mainSpellDamageOnTarget, damageOnTarget))
																	tooltipLine.spellPercent:SetText(formatFunc(_, damageOnTarget))

																	tooltipLine:Show()
																	foundSpell = true
																end
															end
														end
													end
												end

											end

											if (not foundSpell) then
												--add an empty line in the tooltip
												local tooltipLine = actorTooltip.lines [a]
												if (tooltipLine) then
													tooltipLine:Show()
												end
											end
										end

										--break the loop to find the correct line
										break
									end
								end
							end
						end
					end
				end

				--highlight line
				mainLine:SetBackdropColor(unpack(comparisonFrameSettings.lineOnEnterColor))
				latestLinesHighlighted [#latestLinesHighlighted + 1] = mainLine

				tooltip:SetPoint("bottom", mainLine, "top", 0, 2)
				tooltip:SetWidth(mainLine:GetWidth())
				tooltip:SetHeight(min(comparisonFrameSettings.targetMaxLines, #damageDoneBySpell) * comparisonFrameSettings.targetTooltipLineHeight + comparisonFrameSettings.targetMaxLines)
				tooltip:Show()
			end
		end

		local comparisonLineOnLeave = function(self)
			for i = #latestLinesHighlighted, 1, -1 do
				local line = latestLinesHighlighted [i]
				line:SetBackdropColor(unpack(line.BackgroundColor))
				tremove(latestLinesHighlighted, i)
			end

			resetComparisonTooltip()
			resetTargetComparisonTooltip()
		end

		---build a spell and target list for the passed actorObject
		---@param actorObject actor
		---@param combatObject combat
		---@param displayId attributeid
		---@return comparespelltable[]
		---@return comparetargettable[]
		local buildSpellAndTargetTables = function(actorObject, combatObject, displayId)
			local allPlayerSpells = actorObject:GetActorSpells()
			---@type comparespelltable[]
			local resultSpellTable = {}

			--spells
			for spellId, spellTable in pairs(allPlayerSpells) do
				local spellName, _, spellIcon = Details.GetSpellInfo(spellId)
				---@type comparespelltable
				local compareSpellTable = {
					spellId,
					spellTable.total,
					total = spellTable.total,
					spellName = spellName,
					spellIcon = spellIcon,
					spellId = spellId,
					amount = spellTable.total,
					rawSpellTable = spellTable
				}
				resultSpellTable[#resultSpellTable + 1] = compareSpellTable
			end

			--pets
			local petAbilities = {}
			for _, petName in ipairs(actorObject:Pets()) do
				local petObject = combatObject:GetActor(displayId, petName)
				if (petObject) then
					local allPetSpells = petObject:GetActorSpells()
					local petNpcId = detailsFramework:GetNpcIdFromGuid(petObject.serial)
					for spellId, spellTable in pairs(allPetSpells) do
						---@type comparepettable
						local comparePetTable = petAbilities[spellId] or {total = 0, rawSpellTable = spellTable}
						petAbilities[spellId] = comparePetTable
						petAbilities[spellId].total = petAbilities[spellId].total + spellTable.total
					end
				end
			end

			--pet spells
			for spellId, petSpellTable in pairs(petAbilities) do
				local spellName, _, spellIcon = Details.GetSpellInfo(spellId)
				resultSpellTable[#resultSpellTable + 1] = {
					spellId,
					petSpellTable.total,
					total = petSpellTable.total,
					spellName = spellName,
					spellIcon = spellIcon,
					spellId = spellId,
					amount = petSpellTable.total,
					rawSpellTable = petSpellTable.rawSpellTable
				}
			end

			table.sort(resultSpellTable, sortByTotalKey)

			--build the target list for the main player
			---@type comparetargettable[]
			local resultTargetTable = {}
			for targetName, amountDone in pairs(actorObject.targets) do
				---@type comparetargettable
				local compareTargetTable = {
					targetName,
					amountDone,
					total = amountDone,
					targetName = Details:RemoveOwnerName(targetName),
					amount = amountDone,
					originalName = targetName,
					rawPlayerObject = actorObject
				}
				resultTargetTable[#resultTargetTable + 1] = compareTargetTable
			end

			table.sort(resultTargetTable, sortByTotalKey)

			return resultSpellTable, resultTargetTable
		end

		--main tab function to be executed when the tab is opened
		---called when the tab is opened
		---@param tab table
		---@param playerActorObject actor
		---@param combat combat
		local onOpenCompareTab = function(tab, playerActorObject, combat)
			---@type compare
			local comparePlugin = tab.frame

			compareTwo.tabFrame = tab
			compareTwo.playerActorObject = playerActorObject
			compareTwo.combatObject = combat

			--update player name
			comparePlugin.mainPlayerObject = playerActorObject
			comparePlugin.mainSpellFrameScroll.mainPlayerObject = playerActorObject

			--reset the comparison scroll frame
			comparePlugin.ResetComparisonFrames()
			resetComparisonTooltip()
			resetTargetComparisonTooltip()

			--get the data to fill the main player spell and target scrollbox
			local displayId = Details:GetDisplayTypeFromBreakdownWindow()
			---@type comparespelltable[], comparetargettable[]
			local mainPlayerSpellTable, mainPlayerTargetTable = buildSpellAndTargetTables(playerActorObject, combat, displayId)

			--update the two main scroll frames
			comparePlugin.mainSpellFrameScroll:SetData(mainPlayerSpellTable)
			comparePlugin.mainSpellFrameScroll:Refresh()
			comparePlugin.mainTargetFrameScroll:SetData(mainPlayerTargetTable)
			comparePlugin.mainTargetFrameScroll:Refresh()
			comparePlugin.mainSpellTable = mainPlayerSpellTable
			comparePlugin.mainTargetTable = mainPlayerTargetTable

			comparePlugin.combatTimeLabel.text = detailsFramework:CreateAtlasString(Details:GetTextureAtlas("small-clock"), 10, 10) .. " " .. detailsFramework:IntegerToTimer(combat:GetCombatTime())

			--depending on what data the user wants to compare, the data captue is different
			--perform a search on the same combat when comparing the main player with other players using the same specialization.
			--perform a seach on the next segments when comparing the main player against itself.
			--to keep the consistency, sort these players with the max amount of damage or healing they have done

			---table with all other players that will be compared with the main player
			---@type compareactortable[]
			local actorObjectsToCompare = {}
			setmetatable(actorObjectsToCompare, weakTable)

			local maxCompares = compareTwo.db.max_compares

			--~start

			if (compareTwo.db.compare_type == CONST_COMPARETYPE_SEGMENT) then
				--get the segmentId from the combat
				local segmentId = combat:GetSegmentSlotId()
				--get the segments table
				local segmentsTable = Details:GetCombatSegments()

				--iterate among all segments after the this combat
				for i = segmentId+1, #segmentsTable do
					---@type combat
					local combatObject = segmentsTable[i]
					---@type actorcontainer
					local actorContainer = combatObject:GetContainer(displayId)
					---@type actor
					local actorObject = actorContainer:GetActor(playerActorObject:Name())

					if (actorObject and actorObject ~= playerActorObject) then
						---@type compareactortable
						local actorCompareTable = {
							actor = actorObject,
							total = actorObject.total,
							combat = combatObject
						}
						actorObjectsToCompare[#actorObjectsToCompare + 1] = setmetatable(actorCompareTable, weakTable)

						--stop the loop the the max amount of compares is reached
						if (#actorObjectsToCompare >= maxCompares) then
							break
						end
					end
				end

				comparePlugin.mainPlayerName.text = combat:GetCombatName()

			elseif (compareTwo.db.compare_type == CONST_COMPARETYPE_SPEC) then
				local actorContainer = combat:GetContainer(displayId)
				for _, actorObject in actorContainer:ListActors() do
					if (actorObject:IsPlayer() and actorObject:IsGroupPlayer() and actorObject.spec == playerActorObject.spec and actorObject.serial ~= playerActorObject.serial) then
						---@type compareactortable
						local actorCompareTable = {
							actor = actorObject,
							total = actorObject.total,
							combat = combat
						}
						actorObjectsToCompare[#actorObjectsToCompare + 1] = setmetatable(actorCompareTable, weakTable)

						--stop the loop the the max amount of compares is reached
						if (#actorObjectsToCompare >= maxCompares) then
							break
						end
					end
				end

				comparePlugin.mainPlayerName.text = playerActorObject:GetDisplayName()
				table.sort(actorObjectsToCompare, sortByTotalKey)
			end

			---hold the spell data for all other players which will be compared with the main player
			---@type comparespelltable[]
			comparePlugin.comparisonSpellTable = {}

			---hold the target data for all other players which will be compared with the main player
			---@type comparetargettable[]
			comparePlugin.comparisonTargetTable = {}

			--iterate among found actors eligible for comparison and build their spell and target tables
			for idx = 1, #actorObjectsToCompare do
				--other player with the same spec
				local actorCompareTable = actorObjectsToCompare[idx]

				if (not actorCompareTable) then
					print("index", idx, "is nil, actorObjectsToCompare", #actorObjectsToCompare, "maxCompares", maxCompares)
				end

				local playerObject = actorCompareTable.actor
				local combatObject = actorCompareTable.combat

				--build the spell and target tables for this player
				---@type comparespelltable[], comparetargettable[]
				local otherPlayerSpellTable, otherPlayerTargetTable = buildSpellAndTargetTables(playerObject, combatObject, displayId)

				comparePlugin.comparisonSpellTable[#comparePlugin.comparisonSpellTable + 1] = otherPlayerSpellTable
				comparePlugin.comparisonTargetTable[#comparePlugin.comparisonTargetTable + 1] = otherPlayerTargetTable

				---@type compareplayerframe
				local comparisonFrame = comparePlugin.GetCompareFrame()
				--store the main actor object
				comparisonFrame.mainPlayer = playerActorObject
				--store the main player spelltable and targettable
				comparisonFrame.mainSpellTable = mainPlayerSpellTable
				comparisonFrame.mainTargetTable = mainPlayerTargetTable
				--store the another player actorobject and name
				comparisonFrame.playerObject = playerObject

				comparisonFrame.combatTimeLabel.text = detailsFramework:CreateAtlasString(Details:GetTextureAtlas("small-clock"), 10, 10) .. " " .. detailsFramework:IntegerToTimer(combatObject:GetCombatTime())

				--depending on the compare mode, the "player name" will be the segment name or the player name
				if (compareTwo.db.compare_type == CONST_COMPARETYPE_SPEC) then
					comparisonFrame.titleLabel.text = detailsFramework:RemoveRealmName(playerObject:Name())

				elseif (compareTwo.db.compare_type == CONST_COMPARETYPE_SEGMENT) then
					local combatIcon, subIcon = combatObject:GetCombatIcon()
					detailsFramework:SetAtlas(comparisonFrame.titleIcon, subIcon or combatIcon)
					comparisonFrame.titleIcon:SetSize(comparisonFrameSettings.compareTitleIconSize, comparisonFrameSettings.compareTitleIconSize)

					local bOnlyName = true
					comparisonFrame.titleLabel.text = combatObject:GetCombatName(bOnlyName)
					--the combat name can sometimes have pharentesis, remove them
					comparisonFrame.titleLabel.text = comparisonFrame.titleLabel.text:gsub("%(.*%)", "")
					detailsFramework:TruncateText(comparisonFrame.titleLabel, 124)
				end

				--iterate among spells of the main player and check if the spell exists on this player
				---@type comparespelltable[]
				local otherPlayerResultSpellTable = {}

				for mainIdx = 1, #mainPlayerSpellTable do
					local mainSpellTable = mainPlayerSpellTable[mainIdx]
					local bFound = false

					--iterate among spells of the other player and check if the spell exists on the main player
					--if the spell exists, insert the comparespelltable into otherPlayerResultSpellTable
					for otherIdx = 1, #otherPlayerSpellTable do
						local otherSpellTable = otherPlayerSpellTable[otherIdx]

						--check if this is a pet
						if (mainSpellTable.npcId) then
							--match the npcId before match the spellId
							if (otherSpellTable.npcId == mainSpellTable.npcId) then
								if (otherSpellTable.spellId == mainSpellTable.spellId) then
									bFound = true
									--insert the amount of the main spell in the table
									otherSpellTable.mainSpellAmount = mainSpellTable.amount
									otherPlayerResultSpellTable[#otherPlayerResultSpellTable+1] = otherSpellTable
									break
								end
							end
						else
							if (otherSpellTable.spellId == mainSpellTable.spellId) then
								bFound = true
								--insert the amount of the main spell in the table
								otherSpellTable.mainSpellAmount = mainSpellTable.amount
								otherPlayerResultSpellTable[#otherPlayerResultSpellTable+1] = otherSpellTable
								break
							end
						end
					end

					if (not bFound) then
						otherPlayerResultSpellTable[#otherPlayerResultSpellTable+1] = {0, 0, spellName = "", spellIcon = "", spellId = 0, amount = 0}
					end
				end

				--update the spell scrollbox of the compared another player compareframe
				comparisonFrame.spellsScroll.playerObject = playerObject
				comparisonFrame.spellsScroll:SetData(otherPlayerResultSpellTable)
				comparisonFrame.spellsScroll:Refresh()

				--iterate among targets of the main player and check if the target exists on another player
				---@type comparetargettable[]
				local otherPlayerResultTargetsTable = {}

				for mainIdx = 1, #mainPlayerTargetTable do
					local mainTargetTable = mainPlayerTargetTable[mainIdx]
					local bFound = false

					--iterate among targets of the other player and check if the target exists on the main player
					--if the target exists, insert the comparetargettable into otherPlayerResultTargetsTable
					for otherIdx = 1, #otherPlayerTargetTable do
						local otherTargetTable = otherPlayerTargetTable[otherIdx]

						if (otherTargetTable.originalName == mainTargetTable.originalName) then
							bFound = true
							--insert the amount of the main spell in the table
							otherTargetTable.mainTargetAmount = mainTargetTable.amount
							otherPlayerResultTargetsTable[#otherPlayerResultTargetsTable+1] = otherTargetTable
							break
						end
					end

					if (not bFound) then
						otherPlayerResultTargetsTable[#otherPlayerResultTargetsTable+1] = {"", 0, targetName = "", amount = 0, originalName = ""}
					end
				end

				--update the target scrollbox of the compared another player compareframe
				comparisonFrame.targetsScroll:SetData(otherPlayerResultTargetsTable)
				comparisonFrame.targetsScroll:Refresh()
			end
		end

		--called when the tab is created
		---@param tab frame
		---@param comparePlugin compare
		local playerComparisonCreate = function(tab, comparePlugin)
			comparePlugin.isComparisonTab = true

			function compareTwo.Refresh()
				onOpenCompareTab(compareTwo.tabFrame, compareTwo.playerActorObject, compareTwo.combatObject)
			end

			---return the actor name of the actor being compared
			---@return actorname
			function comparePlugin.GetMainPlayerName()
				return comparePlugin.mainPlayerObject:Name()
			end

			---return the actor object of the actor being compared
			---@return actor
			function comparePlugin.GetMainPlayerObject()
				return comparePlugin.mainPlayerObject
			end

			---return the spell table of the actor being compared
			---@return spelltable
			function comparePlugin.GetMainSpellTable()
				return comparePlugin.mainSpellTable
			end

			---return the target table of the actor being compared
			---@return table
			function comparePlugin.GetMainTargetTable()
				return comparePlugin.mainTargetTable
			end

			function comparePlugin.GetAllComparisonFrames()
				return comparePlugin.comparisonFrames
			end

			local selectCompareMode = function(fixedParam, radioButtonId)
				local currentCompareMode = compareTwo.db.compare_type
				if (currentCompareMode == radioButtonId) then
					return
				end
				compareTwo.db.compare_type = radioButtonId
				compareTwo.Refresh()
			end

			--create a radio group to select between comparing players of the same spec or the player itself against other segments
			---@type df_radiooptions[]
			local mainTabSelectorRadioOptions = {
				{
					name = "Compare Same Spec", --localize-me
					set = function()end,
					param = "player",
					get = function() return compareTwo.db.compare_type == CONST_COMPARETYPE_SPEC end,
					texture = [[Interface\AddOns\Details\images\icons2.png]],
					width = 32,
					height = 32,
					text_size = 20,
					texcoord = {0, 64/512, 211/512, 275/512},
					callback = selectCompareMode,
					mask = [[Interface\COMMON\common-iconmask]],
				},
				{
					name = "Compare Segments", --localize-me
					set = function()end,
					param = "segment",
					get = function() return compareTwo.db.compare_type == CONST_COMPARETYPE_SEGMENT end,
					texture = [[Interface\AddOns\Details\images\icons2.png]],
					texcoord = {65/512, 128/512, 211/512, 275/512},
					width = 32,
					height = 32,
					text_size = 20,
					callback = selectCompareMode,
					mask = [[Interface\COMMON\common-iconmask]],
				}
			}

			---@type df_framelayout_options
			local radioGroupLayout = {
				min_width = 350,
				height = 42,
				start_x = 5,
				start_y = -5, --the size of each checkbox is 50, the start_y is the initial offset of the Y anchor, as the radio group height is 50, this make it be centered aligned
				icon_offset_x = 5,
			}

			local radioGroupSettings = {
				rounded_corner_preset = {
					color = {.075, .075, .075, 1},
					border_color = {.2, .2, .2, 1},
					roundness = 8,
				},

				checked_texture = [[Interface\AddOns\Details\images\checked_texture1]],
				checked_texture_offset_x = 0,
				checked_texture_offset_y = 0,

				backdrop_color = {0, 0, 0, 0},

				on_create_checkbox = function(radioGroup, checkBox)
					local icon = checkBox.Icon.widget
					local selectedTexture = checkBox:CreateTexture(checkBox:GetName() .. "SelectedTexture", "border")
					selectedTexture:SetTexture([[Interface\CovenantRenown\CovenantRenownScrollMask]])
					selectedTexture:SetTexCoord(0, 1, 0, 1)
					selectedTexture:SetSize(375, 32)
					selectedTexture:SetVertexColor(1, 1, 1, 0.2)
					selectedTexture:SetPoint("left", icon, "right", -85, 0)
					checkBox.SelectedTexture = selectedTexture
					checkBox.SelectedTexture:Hide()
				end,

				on_click_option = function(radioGroup, checkBox, fixedParam, optionId)
					local radioCheckboxes = radioGroup:GetAllCheckboxes()
					for i = 1, #radioCheckboxes do
						local thisCheckBox = radioCheckboxes[i]
						thisCheckBox.SelectedTexture:Hide()
					end
					checkBox.SelectedTexture:Show()
				end
			}

			local radioGroup = detailsFramework:CreateRadioGroup(comparePlugin, mainTabSelectorRadioOptions, "$parentMainTabSelector", radioGroupSettings, radioGroupLayout)
			radioGroup:SetPoint("bottomleft", comparePlugin, "bottomleft", 5, 5)
			comparePlugin.radioGroup = radioGroup

			--get all checkboxes from the radio group
			local radioCheckboxes = radioGroup:GetAllCheckboxes()
			for i = 1, #radioCheckboxes do
				local thisCheckBox = radioCheckboxes[i]
				if (thisCheckBox:GetChecked()) then
					thisCheckBox.SelectedTexture:Show()
				end
			end

			local radioGroupBackgroundTexture = comparePlugin:CreateTexture(nil, "artwork")
			radioGroupBackgroundTexture:SetColorTexture(.2, .2, .2, 0.834)
			radioGroupBackgroundTexture:SetPoint("bottomleft", comparePlugin, "bottomleft", 5, 8)
			radioGroupBackgroundTexture:SetPoint("bottomright", comparePlugin, "bottomright", -2, 2)
			radioGroupBackgroundTexture:SetHeight(35)
			comparePlugin.radioGroupBackgroundTexture = radioGroupBackgroundTexture

			--create a slider to select how many comparison frames will be shown
			local minValue, maxValue = 4, 16
			local currentValue = compareTwo.db.max_compares
			local scrollStep = 1
			local bIsDecimals = false
			local amountOfComparisonsSlider = detailsFramework:CreateSlider(comparePlugin, 160, 20, minValue, maxValue, scrollStep, currentValue, bIsDecimals)
			amountOfComparisonsSlider:SetPoint("bottomright", comparePlugin, "bottomright", -30, 14)
			amountOfComparisonsSlider:SetTemplate("MODERN_SLIDER_TEMPLATE")
			local bObeyStep = true
			amountOfComparisonsSlider:SetObeyStepOnDrag(bObeyStep)
			amountOfComparisonsSlider:SetHook("OnValueChanged", function(self, fixedValue, value)
				if (value == compareTwo.db.max_compares) then
					return
				end
				value = math.floor(value)
				compareTwo.db.max_compares = value
				compareTwo.Refresh()
			end)
			comparePlugin.comparisonFramesSlider = amountOfComparisonsSlider

			---create a line for the main player spells(scroll box with the spells the player used)
			---@param self comparescrollbox
			---@param index number
			---@return comparescrollline
			local createScrollLine = function(self, index)
				local lineHeight = self.lineHeight
				local lineWidth = self.scrollWidth
				local fontSize = self.fontSize

				---@type comparescrollline
				local line = CreateFrame("button", "$parentLine" .. index, self, "BackdropTemplate")
				line:SetPoint("topleft", self, "topleft", 1, -((index-1) *(lineHeight+1)))
				line:SetSize(lineWidth -2, lineHeight)

				line:SetScript("OnEnter", comparisonLineOnEnter)
				line:SetScript("OnLeave", comparisonLineOnLeave)

				line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
				line:SetBackdropColor(0, 0, 0, 0.2)

				local spellIcon = line:CreateTexture("$parentIcon", "overlay")
				spellIcon:SetSize(lineHeight -2 , lineHeight - 2)
				detailsFramework:SetMask(spellIcon, [[Interface\COMMON\common-iconmask]])
				spellIcon:SetAlpha(comparisonFrameSettings.spellIconAlpha)

				local spellName = line:CreateFontString("$parentName", "overlay", "GameFontNormal")
				local spellAmount = line:CreateFontString("$parentAmount", "overlay", "GameFontNormal")
				local spellPercent = line:CreateFontString("$parentPercent", "overlay", "GameFontNormal")
				detailsFramework:SetFontSize(spellName, fontSize)
				detailsFramework:SetFontSize(spellAmount, fontSize)
				detailsFramework:SetFontSize(spellPercent, fontSize)

				spellIcon:SetPoint("left", line, "left", 2, 0)
				spellName:SetPoint("left", spellIcon, "right", 2, 0)
				spellAmount:SetPoint("right", line, "right", -2, 0)
				spellPercent:SetPoint("right", line, "right", -50, 0)

				spellName:SetJustifyH("left")
				spellAmount:SetJustifyH("right")
				spellPercent:SetJustifyH("right")

				line.spellIcon = spellIcon
				line.spellName = spellName
				line.spellAmount = spellAmount
				line.spellPercent = spellPercent

				return line
			end

			--the refresh function receives an already prepared table and just update the lines
			local mainPlayerRefreshSpellScroll = function(self, data, offset, totalLines)
				for i = 1, totalLines do
					local index = i + offset
					local spellTable = data[index]

					if (spellTable) then
						---@type comparescrollline
						local line = self:GetLine(i)

						--store the line into the spell table
						spellTable.line = line
						line.spellTable = spellTable

						local spellId = spellTable.spellId
						local spellName = spellTable.spellName
						local spellIcon = spellTable.spellIcon
						local amountDone = spellTable.amount

						line.spellId = spellId

						line.spellIcon:SetTexture(spellIcon)
						line.spellIcon:SetTexCoord(.1, .9, .1, .9)

						line.spellName:SetText(spellName)
						detailsFramework:TruncateText(line.spellName, line:GetWidth() - 70)

						local formatFunc = Details:GetCurrentToKFunction()
						line.spellAmount:SetText(formatFunc(_, amountDone))

						if (i % 2 == 0) then
							line:SetBackdropColor(unpack(comparisonLineContrast [1]))
							line.BackgroundColor = comparisonLineContrast[1]
						else
							line:SetBackdropColor(unpack(comparisonLineContrast [2]))
							line.BackgroundColor = comparisonLineContrast[2]
						end
					end
				end
			end

			--refresh a target scroll
			local mainPlayerRefreshTargetScroll = function(self, data, offset, totalLines)
				for i = 1, totalLines do
					local index = i + offset
					local targetTable = data[index]

					if (targetTable) then
						---@type comparescrollline
						local line = self:GetLine(i)

						--store the line into the target table
						targetTable.line = line
						line.targetTable = targetTable

						local targetName = targetTable.targetName
						local amountDone = targetTable.amount

						line.targetName = targetName

						line.spellIcon:SetTexture("") --todo - fill this texture
						line.spellIcon:SetTexCoord(.1, .9, .1, .9)

						line.spellName:SetText(targetName)
						detailsFramework:TruncateText(line.spellName, line:GetWidth() - 50)

						local formatFunc = Details:GetCurrentToKFunction()
						line.spellAmount:SetText(formatFunc(_, amountDone))

						if (i % 2 == 0) then
							line:SetBackdropColor(unpack(comparisonLineContrast [1]))
							line.BackgroundColor = comparisonLineContrast [1]
						else
							line:SetBackdropColor(unpack(comparisonLineContrast [2]))
							line.BackgroundColor = comparisonLineContrast [2]
						end
					end
				end
			end

			--main player spells scroll ~playerscroll
			---@type comparescrollbox
			local mainSpellsFrameScroll = detailsFramework:CreateScrollBox(comparePlugin, "$parentComparisonMainPlayerSpellsScroll", mainPlayerRefreshSpellScroll, {}, comparisonFrameSettings.mainScrollWidth, comparisonFrameSettings.spellScrollHeight, comparisonFrameSettings.spellLineAmount, comparisonFrameSettings.spellLineHeight)
			mainSpellsFrameScroll:SetPoint("topleft", comparePlugin, "topleft", 5, -30)
			mainSpellsFrameScroll.lineHeight = comparisonFrameSettings.spellLineHeight
			mainSpellsFrameScroll.scrollWidth = comparisonFrameSettings.mainScrollWidth
			mainSpellsFrameScroll.fontSize = comparisonFrameSettings.fontSize
			mainSpellsFrameScroll.bIsMain = true

			mainSpellsFrameScroll:HookScript("OnVerticalScroll", function(self, offset)
				comparePlugin.RefreshAllComparisonScrollFrames()
			end)

			--create lines
			for i = 1, comparisonFrameSettings.spellLineAmount do
				---@type comparescrollline
				local line = mainSpellsFrameScroll:CreateLine(createScrollLine)
				line.lineType = "MainPlayerSpell"
			end
			detailsFramework:ReskinSlider(mainSpellsFrameScroll)

			comparePlugin.mainSpellFrameScroll = mainSpellsFrameScroll

			--main player targets(scroll box with enemies the player applied damage)
			---@type comparescrollbox
			local mainTargetFrameScroll = detailsFramework:CreateScrollBox(comparePlugin, "$parentComparisonMainPlayerTargetsScroll", mainPlayerRefreshTargetScroll, {}, comparisonFrameSettings.mainScrollWidth, comparisonFrameSettings.targetScrollHeight, comparisonFrameSettings.targetScrollLineAmount, comparisonFrameSettings.targetScrollLineHeight)
			mainTargetFrameScroll:SetPoint("topleft", mainSpellsFrameScroll, "bottomleft", 0, -20)
			mainTargetFrameScroll.lineHeight = comparisonFrameSettings.targetScrollLineHeight
			mainTargetFrameScroll.scrollWidth = comparisonFrameSettings.mainScrollWidth
			mainTargetFrameScroll.fontSize = comparisonFrameSettings.fontSize
			mainTargetFrameScroll.bIsMain = true

			--create lines
			for i = 1, comparisonFrameSettings.targetScrollLineAmount do
				local line = mainTargetFrameScroll:CreateLine(createScrollLine)
				line.lineType = "MainPlayerTarget"
			end
			detailsFramework:ReskinSlider(mainTargetFrameScroll)

			comparePlugin.mainTargetFrameScroll = mainTargetFrameScroll

			--main player name
			comparePlugin.mainPlayerName = detailsFramework:CreateLabel(mainSpellsFrameScroll, "")
			comparePlugin.mainPlayerName:SetPoint("topleft", mainSpellsFrameScroll, "topleft", 2, comparisonFrameSettings.playerNameYOffset)
			comparePlugin.mainPlayerName.fontsize = comparisonFrameSettings.playerNameSize


			--gradient below the spellsScroll using the atlas "BossBanner-BgBanner-Top"
			local gradientBottom = detailsFramework:CreateTexture(comparePlugin, "BossBanner-BgBanner-Top", 1, 20, "border")
			gradientBottom:SetPoint("topleft", mainSpellsFrameScroll, "bottomleft", -12, 6)
			gradientBottom:SetPoint("topright", mainSpellsFrameScroll, "bottomright", 12, 6)
			comparePlugin.bottomGradient = gradientBottom

			--combat time shown below the spellscroll ~time
			---@type df_label
			comparePlugin.combatTimeLabel = detailsFramework:CreateLabel(comparePlugin, "")
			comparePlugin.combatTimeLabel:SetPoint("top", mainSpellsFrameScroll, "bottom", 0, -1)
			comparePlugin.combatTimeLabel.fontsize = comparisonFrameSettings.playerNameSize - 1
			comparePlugin.combatTimeLabel:SetAlpha(0.834)

			--create the framework for the comparing players
			local settings = {
				--comparison frame
				height = 600,
			}

			---@type compareplayerframe[]
			comparePlugin.comparisonFrames = {}
			comparePlugin.comparisonScrollFrameIndex = 0

			function comparePlugin.ResetComparisonFrames()
				comparePlugin.comparisonScrollFrameIndex = 0
				for _, comparisonFrame in ipairs(comparePlugin.comparisonFrames) do
					comparisonFrame:Hide()
					comparisonFrame.playerObject = nil
					comparisonFrame.spellsScroll.playerObject = nil
				end
			end

			---this function refreshes the target scroll of a compareanotherplayerframe
			---compareframe is the frame that shows the data of another player being compared with the main player
			---@param self comparescrollbox
			---@param data comparetargettable[]
			---@param offset number
			---@param totalLines number
			local comparisonPlayerRefreshTargetScroll  = function(self, data, offset, totalLines)
				offset = FauxScrollFrame_GetOffset(mainSpellsFrameScroll)

				for i = 1, totalLines do
					local index = i + offset
					---@type comparetargettable
					local targetTable = data[index] --unknown type yet

					if (targetTable) then
						---@type comparescrollline
						local line = self:GetLine(i)
						line:SetWidth(comparisonFrameSettings.comparisonScrollWidth - 2)

						--store the line into the target table
						targetTable.line = line
						line.targetTable = targetTable

						line.spellIcon:SetTexture("")

						local mainPlayerAmount = targetTable.mainTargetAmount
						local amountDone = targetTable.amount

						if (mainPlayerAmount) then
							local formatFunc = Details:GetCurrentToKFunction()

							if (mainPlayerAmount > amountDone) then
								local diff = mainPlayerAmount - amountDone
								local up = diff / amountDone * 100
								up = floor(up)
								if (up > 999) then
									up = 999
								end
								line.spellPercent:SetText("|c" .. minor .. up .. "%|r")

							else
								local diff = amountDone - mainPlayerAmount
								local down = diff / mainPlayerAmount * 100
								down = floor(down)
								if (down > 999) then
									down = 999
								end
								line.spellPercent:SetText("|c" .. plus .. down .. "%|r")
							end

							line.spellAmount:SetText(formatFunc(_, amountDone))
						else
							line.spellPercent:SetText("")
							line.spellAmount:SetText("")
						end

						if (i % 2 == 0) then
							line:SetBackdropColor(unpack(comparisonLineContrast[1]))
							line.BackgroundColor = comparisonLineContrast[1]
						else
							line:SetBackdropColor(unpack(comparisonLineContrast[2]))
							line.BackgroundColor = comparisonLineContrast[2]
						end
					end
				end
			end

			---refreshes the spell scroll on a comparison compareanotherplayerframe
			---@param self comparescrollbox
			---@param data comparetargettable[]
			---@param offset number
			---@param totalLines number
			local comparisonPlayerRefreshSpellScroll = function(self, data, offset, totalLines)
				offset = FauxScrollFrame_GetOffset(mainSpellsFrameScroll)

				for i = 1, totalLines do
					local index = i + offset
					---@type comparespelltable
					local spellTable = data[index]

					if (spellTable) then
						---@type comparescrollline
						local line = self:GetLine(i)
						line:SetWidth(comparisonFrameSettings.comparisonScrollWidth - 2)

						--store the line into the spell table
						spellTable.line = line
						line.spellTable = spellTable

						local spellId = spellTable.spellId
						local spellName = spellTable.spellName
						local spellIcon = spellTable.spellIcon
						local amountDone = spellTable.amount

						line.spellId = spellId

						line.spellIcon:SetTexture(spellIcon)
						line.spellIcon:SetTexCoord(.1, .9, .1, .9)

						line.spellName:SetText("") --won't show the spell name, only the icon

						local percent = 1

						local mainFrame = self:GetParent().mainPlayer
						local mainSpellTable = self:GetParent().mainSpellTable
						local mainPlayerAmount = spellTable.mainSpellAmount

						if (mainPlayerAmount) then
							local formatFunc = Details:GetCurrentToKFunction()

							if (mainPlayerAmount > amountDone) then
								local diff = mainPlayerAmount - amountDone
								local up

								if (diff == 0 or mainPlayerAmount == 0) then --stop div by zero ptr
									up = "0"
								else
									up = diff / amountDone * 100
									up = floor(up)
									if (up > 999) then
										up = 999
									end
								end
								line.spellPercent:SetText("|c" .. minor .. up .. "%|r")

							else
								local down
								local diff = amountDone - mainPlayerAmount
								if (diff == 0 or mainPlayerAmount == 0) then --stop div by zero ptr
									down = "0"
								else
									down = diff / mainPlayerAmount * 100
									down = floor(down)
									if (down > 999) then
										down = 999
									end
								end
								line.spellPercent:SetText("|c" .. plus .. down .. "%|r")
							end

							line.spellAmount:SetText(formatFunc(_, amountDone))
						else
							line.spellPercent:SetText("")
							line.spellAmount:SetText("")
						end

						if (i % 2 == 0) then
							line:SetBackdropColor(unpack(comparisonLineContrast[1]))
							line.BackgroundColor = comparisonLineContrast[1]
						else
							line:SetBackdropColor(unpack(comparisonLineContrast[2]))
							line.BackgroundColor = comparisonLineContrast[2]
						end
					end
				end
			end

			function comparePlugin.RefreshAllComparisonScrollFrames()
				for _, comparisonFrame in ipairs(comparePlugin.comparisonFrames) do
					comparisonFrame.spellsScroll:Refresh()
					comparisonFrame.targetsScroll:Refresh()
				end
			end

			--get a frame which has two scrolls, one for spells and another for targets
			--if the frame does not exists, create it
			---@return compareplayerframe
			function comparePlugin.GetCompareFrame()
				comparePlugin.comparisonScrollFrameIndex = comparePlugin.comparisonScrollFrameIndex + 1

				local comparisonFrame = comparePlugin.comparisonFrames[comparePlugin.comparisonScrollFrameIndex]
				if (comparisonFrame) then
					comparisonFrame:Show()
					return comparisonFrame
				end

				--if the line requested does exist, create it
				---@type compareplayerframe
				local newComparisonFrame = CreateFrame("frame", "DetailsComparisonFrame" .. comparePlugin.comparisonScrollFrameIndex, comparePlugin, "BackdropTemplate")
				comparePlugin.comparisonFrames[comparePlugin.comparisonScrollFrameIndex] = newComparisonFrame
				newComparisonFrame:SetSize(comparisonFrameSettings.comparisonScrollWidth, settings.height)

				if (comparePlugin.comparisonScrollFrameIndex == 1) then
					newComparisonFrame:SetPoint("topleft", mainSpellsFrameScroll, "topright", 30, 0)
				else
					newComparisonFrame:SetPoint("topleft", comparePlugin.comparisonFrames [comparePlugin.comparisonScrollFrameIndex - 1], "topright", 10, 0)
				end

				--texture to show the combat icon at the left side of the titleLabel
				newComparisonFrame.titleIcon = detailsFramework:CreateTexture(newComparisonFrame)
				newComparisonFrame.titleIcon:SetPoint("topleft", newComparisonFrame, "topleft", 0, comparisonFrameSettings.playerNameYOffset)

				--player name shown above the scrolls
				---@type df_label
				newComparisonFrame.titleLabel = detailsFramework:CreateLabel(newComparisonFrame, "")
				newComparisonFrame.titleLabel:SetPoint("left", newComparisonFrame.titleIcon, "right", 2, 0)
				newComparisonFrame.titleLabel.fontsize = comparisonFrameSettings.playerNameSize

				--grandient texture above the comparison frame
				local gradientTitle = detailsFramework:CreateTexture(newComparisonFrame, {gradient = "vertical", fromColor = {0, 0, 0, 0.25}, toColor = "transparent"}, 1, 16, "artwork", {0, 1, 0, 1})
				gradientTitle:SetPoint("bottomleft", newComparisonFrame, "topleft", 0, 0)
				gradientTitle:SetPoint("bottomright", newComparisonFrame, "topright", 0, 0)

				--spells scroll
				---@type comparescrollbox
				local spellsScroll = detailsFramework:CreateScrollBox(newComparisonFrame, "$parentComparisonPlayerSpellsScroll", comparisonPlayerRefreshSpellScroll, {}, comparisonFrameSettings.comparisonScrollWidth, comparisonFrameSettings.spellScrollHeight, comparisonFrameSettings.spellLineAmount, comparisonFrameSettings.spellLineHeight)
				spellsScroll:SetPoint("topleft", newComparisonFrame, "topleft", 0, 0)
				spellsScroll.lineHeight = comparisonFrameSettings.spellLineHeight
				spellsScroll.scrollWidth = comparisonFrameSettings.mainScrollWidth
				spellsScroll.fontSize = comparisonFrameSettings.fontSize
				--hide the scrollbar of a df_scrollbox
				_G[spellsScroll:GetName() .. "ScrollBar"]:Hide()

				--create lines
				for i = 1, comparisonFrameSettings.spellLineAmount do
					local line = spellsScroll:CreateLine(createScrollLine)
					line.lineType = "OtherPlayerSpell"
				end
				detailsFramework:ReskinSlider(spellsScroll)

				newComparisonFrame.spellsScroll = spellsScroll

				--gradient below the spellsScroll using the atlas "BossBanner-BgBanner-Top"
				local gradientBottom = detailsFramework:CreateTexture(newComparisonFrame, "BossBanner-BgBanner-Top", 1, 20, "border")
				gradientBottom:SetPoint("topleft", spellsScroll, "bottomleft", -12, 6)
				gradientBottom:SetPoint("topright", spellsScroll, "bottomright", 12, 6)
				newComparisonFrame.bottomGradient = gradientBottom

				--combat time shown below the spellscroll ~time
				---@type df_label
				newComparisonFrame.combatTimeLabel = detailsFramework:CreateLabel(newComparisonFrame, "")
				newComparisonFrame.combatTimeLabel:SetPoint("top", spellsScroll, "bottom", 0, -1)
				newComparisonFrame.combatTimeLabel.fontsize = comparisonFrameSettings.playerNameSize - 1
				newComparisonFrame.combatTimeLabel:SetAlpha(0.834)

				--targets scroll
				---@type comparescrollbox
				local targetsScroll = detailsFramework:CreateScrollBox(newComparisonFrame, "$parentComparisonPlayerTargetsScroll", comparisonPlayerRefreshTargetScroll, {}, comparisonFrameSettings.comparisonScrollWidth, comparisonFrameSettings.targetScrollHeight, comparisonFrameSettings.targetScrollLineAmount, comparisonFrameSettings.targetScrollLineHeight)
				targetsScroll:SetPoint("topleft", newComparisonFrame, "topleft", 0, -comparisonFrameSettings.spellScrollHeight - 20)
				targetsScroll.lineHeight = comparisonFrameSettings.spellLineHeight
				targetsScroll.scrollWidth = comparisonFrameSettings.mainScrollWidth
				targetsScroll.fontSize = comparisonFrameSettings.fontSize
				--hide the scrollbar of a df_scrollbox
				_G[targetsScroll:GetName() .. "ScrollBar"]:Hide()

				--create lines
				for i = 1, comparisonFrameSettings.targetScrollLineAmount do
					local line = targetsScroll:CreateLine(createScrollLine)
					line.lineType = "OtherPlayerTarget"
				end
				detailsFramework:ReskinSlider(targetsScroll)

				newComparisonFrame.targetsScroll = targetsScroll

				return newComparisonFrame
			end

			if (not comparePlugin.__background) then
				detailsFramework:ApplyStandardBackdrop(comparePlugin)
				comparePlugin.__background:SetAlpha(0.6)
			end
		end

		local iconTableCompare = {
			texture = [[Interface\AddOns\Details\images\icons]],
			--coords = {363/512, 381/512, 0/512, 17/512},
			coords = {383/512, 403/512, 0/512, 15/512},
			width = 16,
			height = 14,
		}

		Details:CreatePlayerDetailsTab("New Compare", "Compare", --[1] tab name [2] localized name
			function(tabOBject, playerObject)  --[2] condition

				local attribute = Details:GetDisplayTypeFromBreakdownWindow()
				local combat = Details:GetCombatFromBreakdownWindow()

				if (attribute > 2) then
					return false
				end

				local playerSpec = playerObject.spec or "no-spec"
				local playerSerial = playerObject.serial
				local showTab = false

				for index, actor in ipairs(combat [attribute]._ActorTable) do
					if (actor.spec == playerSpec and actor.serial ~= playerSerial) then
						showTab = true
						break
					end
				end

				if (showTab) then
					return true
				end

				--return false
				return true --debug?
			end,

			onOpenCompareTab, --[3] fill function

			nil, --[4] onclick

			playerComparisonCreate, --[5] oncreate
			iconTableCompare, --[6] icon table

			{
				attributes = {
					[1] = {1, 2, 3, 4, 5, 6, 7, 8},
					[2] = {1, 2, 3, 4, 5, 6, 7, 8},
				},
				tabNameToReplace = "Compare",
				bIsCompareTab = true,
			} --replace tab [attribute] = [sub attributes]
		)
	end

---------------------------------------------------------------------------------------------------------------------------------------

	function compareTwo:OnEvent(_, event, ...)
		if (event == "ADDON_LOADED") then
			local AddonName = select(1, ...)
			if (AddonName == "Details_Compare2") then
				--> every plugin must have a OnDetailsEvent function
				function compareTwo:OnDetailsEvent(event, ...)
					return handle_details_event(event, ...)
				end

				local defaultSettings = {
					compare_type = CONST_COMPARETYPE_SPEC, --1 == player, 2 == segment
					max_compares = 4,
				}

				--> Install: install -> if successful installed; saveddata -> a table saved inside details db, used to save small amount of data like configs
				local install, saveddata = Details:InstallPlugin("RAID", "Compare 2.0", "Interface\\Icons\\Ability_Warrior_BattleShout", compareTwo, "DETAILS_PLUGIN_COMPARETWO_WINDOW", MINIMAL_DETAILS_VERSION_REQUIRED, "Terciob", COMPARETWO_VERSION, defaultSettings)
				if (type(install) == "table" and install.error) then
					print(install.error)
				end

				--> registering details events we need
				Details:RegisterEvent(compareTwo, "COMBAT_PLAYER_ENTER") --when details creates a new segment, not necessary the player entering in combat.
				Details:RegisterEvent(compareTwo, "COMBAT_PLAYER_LEAVE") --when details finishs a segment, not necessary the player leaving the combat.
				Details:RegisterEvent(compareTwo, "DETAILS_DATA_RESET") --details combat data has been wiped

				compareTwo.InstallAdvancedCompareWindow()

				--this plugin does not show in lists of plugins
				compareTwo.NoMenu = true
			end
		end
	end
end