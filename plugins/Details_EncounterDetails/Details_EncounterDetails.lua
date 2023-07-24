
local addonId, edTable = ...
local AceLocale = LibStub("AceLocale-3.0")
local Loc = AceLocale:GetLocale("Details_EncounterDetails")
local Details = Details
local _

local openAtStartup = "false"

local isDebug = false
local function DebugMessage(...)
	if (isDebug) then
		print("|cFFFFFF00EBreakDown|r:", ...)
	end
end

local PLUGIN_REAL_NAME = "DETAILS_PLUGIN_ENCOUNTER_DETAILS"

edTable.PluginAbsoluteName = PLUGIN_REAL_NAME

local _GetSpellInfo = Details.getspellinfo --wow api local
local CreateFrame = CreateFrame --wow api local
local GetTime = GetTime --wow api local
local GetCursorPosition = GetCursorPosition --wow api local
local GameTooltip = GameTooltip --wow api local
local GameCooltip = GameCooltip2

local ipairs = ipairs
local pairs = pairs
local bitBand = bit.band

--create the plugin object
local encounterDetails = Details:NewPluginObject("Details_EncounterDetails", DETAILSPLUGIN_ALWAYSENABLED)
table.insert(UISpecialFrames, "Details_EncounterDetails")
edTable.PluginObject = encounterDetails

EncounterDetailsGlobal = encounterDetails --[[GLOBAL]]

edTable.defaultBackgroundColor = {0.5, 0.5, 0.5, 0.3}
edTable.defaultBackgroundColor_OnEnter = {0.5, 0.5, 0.5, 0.7}
edTable.defaultBackdrop = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true}

local edFrame = encounterDetails.Frame
edFrame.DefaultBarHeight = 20
edFrame.CooltipStatusbarAlpha = .834
edFrame.DefaultBarTexture = "Interface\\AddOns\\Details\\images\\bar_serenity"
edFrame.encounterSummaryWidgets = {}
encounterDetails:SetPluginDescription("Raid encounters summary, show basic stuff like dispels, interrupts and also graphic charts, boss emotes and the Weakaura Creation Tool.")

--main combat object
local _combat_object

encounterDetails.name = "Encounter Breakdown"
encounterDetails.debugmode = false

function encounterDetails:FormatCooltipSettings()
	GameCooltip:SetType("tooltip")
	GameCooltip:SetOption("StatusBarTexture", [[Interface\AddOns\Details\images\bar_serenity]])
	GameCooltip:SetOption("StatusBarHeightMod", 0)
	GameCooltip:SetOption("FixedWidth", 280)
	GameCooltip:SetOption("TextSize", 11)
	GameCooltip:SetOption("LeftBorderSize", -4)
	GameCooltip:SetOption("RightBorderSize", 5)
	GameCooltip:SetOption("ButtonsYMod", 0)
	GameCooltip:SetOption("YSpacingMod", -1)
end

encounterDetails.CooltipLineHeight = 18

--main object frame functions
local function CreatePluginFrames(data)
	--saved data if any
	encounterDetails.data = data or {}

	--record if button is shown
	encounterDetails.showing = false

	--record if boss window is open or not
	encounterDetails.window_open = false
	encounterDetails.combat_boss_found = false

	--OnEvent Table
	function encounterDetails:OnDetailsEvent(event, ...)
		--when main frame became hide
		if (event == "HIDE") then --plugin hidded, disabled
			self.open = false

		--when main frame is shown on screen
		elseif (event == "SHOW") then --plugin hidded, disabled
			self.open = true
			encounterDetails:RefreshScale()

		--when details finish his startup and are ready to work
		elseif (event == "DETAILS_STARTED") then
			if (openAtStartup) then
				C_Timer.After(0.1, function()
					--Details:OpenPlugin('Encounter Breakdown')
				end)
			end

			--check if details are in combat, if not check if the last fight was a boss fight
			if (not encounterDetails:IsInCombat()) then
				--get the current combat table
				_combat_object = encounterDetails:GetCombat()
				--check if was a boss fight
				encounterDetails:WasEncounter()
			end

			local string_damage_done_func = [[
				--get the current combat
				local currentCombat = Details:GetCurrentCombat() 
				--total damage done by the raid group
				local raidGroupDamageDone = currentCombat:GetTotal(DETAILS_ATTRIBUTE_DAMAGE, nil, DETAILS_TOTALS_ONLYGROUP)
				return raidGroupDamageDone or 0
			]]
			Details:TimeDataRegister("Raid Damage Done", string_damage_done_func, nil, "Encounter Details", "v1.0", [[Interface\ICONS\Ability_DualWield]], true, true)

			if (encounterDetails.db.show_icon == 4) then
				encounterDetails:ShowIcon()
			elseif (encounterDetails.db.show_icon == 5) then
				encounterDetails:AutoShowIcon()
			end

		elseif (event == "COMBAT_PLAYER_ENTER") then --combat started
			if (encounterDetails.showing and encounterDetails.db.hide_on_combat) then
				--EncounterDetails:HideIcon()
				encounterDetails:CloseWindow()
			end

			encounterDetails.current_whisper_table = {}

		elseif (event == "COMBAT_PLAYER_LEAVE") then
			--combat leave and enter always send current combat table
			_combat_object = select(1, ...)
			--check if was a boss fight
			encounterDetails:WasEncounter()

			if (encounterDetails.combat_boss_found) then
				encounterDetails.combat_boss_found = false
			end

			if (encounterDetails.db.show_icon == 5) then
				encounterDetails:AutoShowIcon()
			end

			local chartName = "Raid Damage Done"
			local combatUniquieID = _combat_object:GetCombatNumber()
			local chartData = _combat_object:GetTimeData(chartName)

			if (chartData) then
				EncounterDetailsDB.chartData[combatUniquieID] = EncounterDetailsDB.chartData[combatUniquieID] or {}
				EncounterDetailsDB.chartData[combatUniquieID][chartName] = chartData
				--store when this chart was created to cleanup later
				chartData.__time = time()
				--remove the time data from the combat object
				_combat_object:EraseTimeData(chartName)
			end

			local whisperTable = encounterDetails.current_whisper_table
			if (whisperTable and _combat_object.is_boss and _combat_object.is_boss.name) then
				whisperTable.boss = _combat_object.is_boss.name
				table.insert(encounterDetails.boss_emotes_table, 1, whisperTable)

				if (#encounterDetails.boss_emotes_table > encounterDetails.db.max_emote_segments) then
					table.remove(encounterDetails.boss_emotes_table, encounterDetails.db.max_emote_segments+1)
				end
			end

		elseif (event == "COMBAT_BOSS_FOUND") then
			encounterDetails.combat_boss_found = true
			if (encounterDetails.db.show_icon == 5) then
				encounterDetails:AutoShowIcon()
			end

		elseif (event == "DETAILS_DATA_RESET") then
			if (encounterDetails.chartPanel) then
				encounterDetails.chartPanel:Reset()
			end

			if (encounterDetails.db.show_icon == 5) then
				encounterDetails:AutoShowIcon()
			end

			encounterDetails:CloseWindow()

			--drop last combat table
			encounterDetails.LastSegmentShown = nil

			--wipe emotes
			table.wipe(encounterDetails.boss_emotes_table)

		elseif (event == "GROUP_ONENTER") then
			if (encounterDetails.db.show_icon == 2) then
				encounterDetails:ShowIcon()
			end

		elseif (event == "GROUP_ONLEAVE") then
			if (encounterDetails.db.show_icon == 2) then
				encounterDetails:HideIcon()
			end

		elseif (event == "ZONE_TYPE_CHANGED") then
			if (encounterDetails.db.show_icon == 1) then
				if (select(1, ...) == "raid") then
					encounterDetails:ShowIcon()
				else
					encounterDetails:HideIcon()
				end
			end

		elseif (event == "PLUGIN_DISABLED") then
			encounterDetails:HideIcon()
			encounterDetails:CloseWindow()

		elseif (event == "PLUGIN_ENABLED") then
			if (encounterDetails.db.show_icon == 5) then
				encounterDetails:AutoShowIcon()

			elseif (encounterDetails.db.show_icon == 4) then
				encounterDetails:ShowIcon()
			end
		end
	end

	function encounterDetails:WasEncounter()
		--check if last combat was a boss encounter
		if (not encounterDetails.debugmode) then
			if (not _combat_object.is_boss) then
				return

			elseif (_combat_object.is_boss.encounter == "pvp") then
				return
			end

			if (_combat_object.instance_type ~= "raid") then
				return
			end
		end

		--boss found, show the icon
		encounterDetails:ShowIcon()
	end

	function encounterDetails:ShowIcon()
		encounterDetails.showing = true
		--[1] button to show [2] button animation: "star", "blink" or true(blink)
		encounterDetails:ShowToolbarIcon(encounterDetails.ToolbarButton, "star")
	end

	--hide icon on toolbar
	function encounterDetails:HideIcon()
		encounterDetails.showing = false
		encounterDetails:HideToolbarIcon(encounterDetails.ToolbarButton)
	end

	--user clicked on button, need open or close window
	function encounterDetails:OpenWindow()
		if (encounterDetails.Frame:IsShown()) then
			return encounterDetails:CloseWindow()
		end

		DetailsPluginContainerWindow.OpenPlugin(encounterDetails)

		--build all window data
		encounterDetails.db.opened = encounterDetails.db.opened + 1
		encounterDetails:OpenAndRefresh()

		--show
		edFrame:Show()
		encounterDetails.open = true

		if (edFrame.ShowType == "graph") then
			encounterDetails:ShowChartFrame()
		end

		--select latest emote segment
		encounterDetails.emoteSegmentsDropdown:Select(1)
		encounterDetails.emoteSegmentsDropdown:Refresh()
		encounterDetails:SetEmoteSegment(1)

		if (edFrame.ShowType ~= "emotes") then
			--hide emote frames
			for _, widget in pairs(encounterDetails.Frame.EmoteWidgets) do
				widget:Hide()
			end
		end

		return true
	end

	function encounterDetails:CloseWindow()
		encounterDetails.open = false
		edFrame:Hide()
		Details:CloseBreakdownWindow()
		return true
	end

	local cooltip_menu = function()
		local gameCooltip = GameCooltip

		gameCooltip:Reset()
		gameCooltip:SetType("menu")

		gameCooltip:SetOption("TextSize", Details.font_sizes.menus)
		gameCooltip:SetOption("TextFont", Details.font_faces.menus)

		gameCooltip:SetOption("ButtonHeightModSub", -2)
		gameCooltip:SetOption("ButtonHeightMod", -5)

		gameCooltip:SetOption("ButtonsYModSub", -3)
		gameCooltip:SetOption("ButtonsYMod", -6)

		gameCooltip:SetOption("YSpacingModSub", -3)
		gameCooltip:SetOption("YSpacingMod", 1)

		gameCooltip:SetOption("HeighMod", 3)
		gameCooltip:SetOption("SubFollowButton", true)

		Details:SetTooltipMinWidth()

		--summary
		gameCooltip:AddLine("Encounter Summary")
		gameCooltip:AddMenu(1, encounterDetails.Frame.switch, "main")
		gameCooltip:AddIcon("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons", 1, 1, 20, 20, 0, 0.125, 0, 0.5)

		--chart
		gameCooltip:AddLine("Damage Graphic")
		gameCooltip:AddMenu(1, encounterDetails.Frame.switch, "graph")
		gameCooltip:AddIcon("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons", 1, 1, 20, 20, 0.125*3, 0.125*4, 0, 0.5)

		--emotes
		gameCooltip:AddLine("Boss Emotes")
		gameCooltip:AddMenu(1, encounterDetails.Frame.switch, "emotes")
		gameCooltip:AddIcon("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons", 1, 1, 20, 20, 0.125*4, 0.125*5, 0, 0.5)

		--phases
		gameCooltip:AddLine("Damage by Boss Phase")
		gameCooltip:AddMenu(1, encounterDetails.Frame.switch, "phases")
		gameCooltip:AddIcon("Interface\\AddOns\\Details_EncounterDetails\\images\\boss_frame_buttons", 1, 1, 20, 20,  0.125, 0.125*2, 0, 0.505625)

		--apply the backdrop settings to the menu
		Details:FormatCooltipBackdrop()
		gameCooltip:SetOwner(ENCOUNTERDETAILS_BUTTON, "bottom", "top", 0, 0)
		gameCooltip:ShowCooltip()
	end

	encounterDetails.ToolbarButton = Details.ToolBar:NewPluginToolbarButton(encounterDetails.OpenWindow, "Interface\\AddOns\\Details_EncounterDetails\\images\\icon", Loc ["STRING_PLUGIN_NAME"], Loc ["STRING_TOOLTIP"], 16, 16, "ENCOUNTERDETAILS_BUTTON", cooltip_menu) --"Interface\\COMMON\\help-i"
	encounterDetails.ToolbarButton.shadow = true --loads icon_shadow.tga when the instance is showing icons with shadows

	--setpoint anchors mod if needed
	encounterDetails.ToolbarButton.y = 0.5
	encounterDetails.ToolbarButton.x = 0

	--build all frames ans widgets
	Details.EncounterDetailsTempWindow(encounterDetails)
	Details.EncounterDetailsTempWindow = nil
end

--custom tooltip for dead details ---------------------------------------------------------------------------------------------------------

	--tooltip backdrop, color and border
	local bgColor, borderColor = {0.17, 0.17, 0.17, .9}, {.30, .30, .30, .3}

	local function KillInfo(deathTable, row)
		local iconSize = 19

		local eventos = deathTable [1]
		local hora_da_morte = deathTable [2]
		local hp_max = deathTable [5]

		local battleress = false
		local lastcooldown = false

		GameCooltip:Reset()
		GameCooltip:SetType("tooltipbar")
		GameCooltip:SetOwner(row)

		GameCooltip:AddLine("Click to Report", nil, 1, "orange")
		GameCooltip:AddIcon([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 1, 1, 12, 16, 0.015625, 0.13671875, 0.4375, 0.59765625)
		GameCooltip:AddStatusBar(0, 1, 1, 1, 1, 1, false, {value = 100, color = {.3, .3, .3, .5}, specialSpark = false, texture = [[Interface\AddOns\Details\images\bar_serenity]]})

		local statusBarBackground = {value = 100, color = {.21, .21, .21, 0.8}, texture = [[Interface\AddOns\Details\images\bar_serenity]]}

		--death parser
		for index, event in ipairs(eventos) do

			local hp = math.floor(event[5]/hp_max*100)
			if (hp > 100) then
				hp = 100
			end

			local evtype = event [1]
			local spellname, _, spellicon = _GetSpellInfo(event [2])
			local amount = event [3]
			local time = event [4]
			local source = event [6]

			if (type(evtype) == "boolean") then
				--is damage or heal
				if (evtype) then
					--damage

					local overkill = event [10] or 0
					if (overkill > 0) then
						amount = amount - overkill
						overkill = "(" .. Details:ToK(overkill) .. " |cFFFF8800overkill|r)"
					else
						overkill = ""
					end

					if (source:find("%[")) then
						source = source:gsub("%[%*%] ", "")
					end

					GameCooltip:AddLine("" .. string.format("%.1f", time - hora_da_morte) .. "s " .. spellname .. "(" .. source .. ")", "-" .. Details:ToK(amount) .. overkill .. "(" .. hp .. "%)", 1, "white", "white")
					GameCooltip:AddIcon(spellicon, 1, 1, 16, 16, .1, .9, .1, .9)

					if (event [9]) then
						--friendly fire
						GameCooltip:AddStatusBar(hp, 1, "darkorange", true, statusBarBackground)
					else
						--from a enemy
						GameCooltip:AddStatusBar(hp, 1, "red", true, statusBarBackground)
					end
				else
					--heal
					local class = Details:GetClass(source)
					local spec = Details:GetSpec(source)

					GameCooltip:AddLine("" .. string.format("%.1f", time - hora_da_morte) .. "s " .. spellname .. "(" .. Details:GetOnlyName(Details:AddClassOrSpecIcon(source, class, spec, 16, true)) .. ")", "+" .. Details:ToK(amount) .. "(" .. hp .. "%)", 1, "white", "white")
					GameCooltip:AddIcon(spellicon, 1, 1, 16, 16, .1, .9, .1, .9)
					GameCooltip:AddStatusBar(hp, 1, "green", true, statusBarBackground)
				end

			elseif (type(evtype) == "number") then
				if (evtype == 1) then
					--cooldown
					GameCooltip:AddLine("" .. string.format("%.1f", time - hora_da_morte) .. "s " .. spellname .. "(" .. source .. ")", "cooldown(" .. hp .. "%)", 1, "white", "white")
					GameCooltip:AddIcon(spellicon, 1, 1, 16, 16, .1, .9, .1, .9)
					GameCooltip:AddStatusBar(100, 1, "yellow", true, statusBarBackground)

				elseif (evtype == 2 and not battleress) then
					--battle ress
					battleress = event

				elseif (evtype == 3) then
					--last cooldown used
					lastcooldown = event

				elseif (evtype == 4) then
					--debuff
					if (source:find("%[")) then
						source = source:gsub("%[%*%] ", "")
					end

					GameCooltip:AddLine("" .. string.format("%.1f", time - hora_da_morte) .. "s [x" .. amount .. "] " .. spellname .. "(" .. source .. ")", "debuff(" .. hp .. "%)", 1, "white", "white")
					GameCooltip:AddIcon(spellicon, 1, 1, 16, 16, .1, .9, .1, .9)
					GameCooltip:AddStatusBar(100, 1, "purple", true, statusBarBackground)

				end
			end
		end

		GameCooltip:AddLine(deathTable [6] .. " " .. "died" , "-- -- -- ", 1, "white")
		GameCooltip:AddIcon("Interface\\AddOns\\Details\\images\\small_icons", 1, 1, iconSize, iconSize, .75, 1, 0, 1)
		GameCooltip:AddStatusBar(0, 1, .5, .5, .5, .5, false, {value = 100, color = {.5, .5, .5, 1}, specialSpark = false, texture = [[Interface\AddOns\Details\images\bar4_vidro]]})

		if (battleress) then
			local nome_magia, _, icone_magia = _GetSpellInfo(battleress [2])
			GameCooltip:AddLine("+" .. string.format("%.1f", battleress[4] - hora_da_morte) .. "s " .. nome_magia .. "(" .. battleress[6] .. ")", "", 1, "white")
			GameCooltip:AddIcon("Interface\\Glues\\CharacterSelect\\Glues-AddOn-Icons", 1, 1, nil, nil, .75, 1, 0, 1)
			GameCooltip:AddStatusBar(0, 1, .5, .5, .5, .5, false, {value = 100, color = {.5, .5, .5, 1}, specialSpark = false, texture = [[Interface\AddOns\Details\images\bar4_vidro]]})
		end

		if (lastcooldown) then
			if (lastcooldown[3] == 1) then
				local nome_magia, _, icone_magia = _GetSpellInfo(lastcooldown [2])
				GameCooltip:AddLine(string.format("%.1f", lastcooldown[4] - hora_da_morte) .. "s " .. nome_magia .. "(" .. Loc ["STRING_LAST_COOLDOWN"] .. ")")
				GameCooltip:AddIcon(icone_magia)
			else
				GameCooltip:AddLine(Loc ["STRING_NOLAST_COOLDOWN"])
				GameCooltip:AddIcon([[Interface\CHARACTERFRAME\UI-Player-PlayTimeUnhealthy]], 1, 1, 18, 18)
			end
			GameCooltip:AddStatusBar(0, 1, 1, 1, 1, 1, false, {value = 100, color = {.3, .3, .3, 1}, specialSpark = false, texture = [[Interface\AddOns\Details\images\bar_serenity]]})
		end

		--death log cooltip settings
		GameCooltip:SetOption("StatusBarHeightMod", -6)
		GameCooltip:SetOption("FixedWidth", 400)
		GameCooltip:SetOption("TextSize", 10)
		GameCooltip:SetOption("LeftBorderSize", -4)
		GameCooltip:SetOption("RightBorderSize", 5)
		GameCooltip:SetOption("StatusBarTexture", [[Interface\AddOns\Details\images\bar_serenity]])
		GameCooltip:SetBackdrop(1, Details.cooltip_preset2_backdrop, bgColor, borderColor)

		GameCooltip:SetOwner(row, "bottomright", "bottomleft", -2, -50)
		row.OverlayTexture:Show()
		GameCooltip:ShowCooltip()
	end

--custom tooltip for dispells details ---------------------------------------------------------------------------------------------------------


--custom tooltip for kick details ---------------------------------------------------------------------------------------------------------



--custom tooltip clicks on any bar ---------------------------------------------------------------------------------------------------------
function Details:BossInfoRowClick(barra, param1)

	if (type(self) == "table") then
		barra, param1 = self, barra
	end

	if (type(param1) == "table") then
		barra = param1
	end

	if (barra._no_report) then
		return
	end

	local reportar

	if (barra.TTT == "morte" or true) then --deaths -- todos os boxes est�o usando cooltip, por isso o 'true'.

		reportar = {barra.report_text .. " " ..(barra.lineText1 and barra.lineText1:GetText() or barra:GetParent() and barra:GetParent().lineText1 and barra:GetParent().lineText1:GetText() or "")}
		local beginAt = 1
		if (barra.TTT == "damage_taken" or barra.TTT == "habilidades_inimigas" or barra.TTT == "total_interrupt" or barra.TTT == "add") then
			beginAt = 2
		end
		--"habilidades_inimigas"
		for i = beginAt, GameCooltip:GetNumLines(), 1 do
			local texto_left, texto_right = GameCooltip:GetText(i)

			if (texto_left and texto_right) then
				texto_left = texto_left:gsub(("|T(.*)|t "), "")
				reportar [#reportar+1] = ""..texto_left.." "..texto_right..""
			end
		end
	else

		barra.report_text = barra.report_text or ""
		reportar = {barra.report_text .. " " .. _G.GameTooltipTextLeft1:GetText()}
		local numLines = GameTooltip:NumLines()

		for i = 1, numLines, 1 do
			local nome_left = "GameTooltipTextLeft"..i
			local texto_left = _G[nome_left]
			texto_left = texto_left:GetText()

			local nome_right = "GameTooltipTextRight"..i
			local texto_right = _G[nome_right]
			texto_right = texto_right:GetText()

			if (texto_left and texto_right) then
				texto_left = texto_left:gsub(("|T(.*)|t "), "")
				reportar [#reportar+1] = ""..texto_left.." "..texto_right..""
			end
		end
	end

	return Details:Reportar(reportar, {_no_current = true, _no_inverse = true, _custom = true})
end

--custom tooltip that handle mouse enter and leave on customized rows ---------------------------------------------------------------------------------------------------------

local backdrop_bar_onenter = {bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16, edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 8, insets = {left = 1, right = 1, top = 0, bottom = 1}}
local backdrop_bar_onleave = {bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16, insets = {left = 1, right = 1, top = 0, bottom = 1}}

function encounterDetails:SetRowScripts(barra, index, container)

	barra:SetScript("OnMouseDown", function(self)
		if (self.fading_in) then
			return
		end

		self.mouse_down = GetTime()
		local x, y = GetCursorPosition()
		self.x = math.floor(x)
		self.y = math.floor(y)

		--EncounterDetailsFrame:StartMoving()
		edFrame.isMoving = true

	end)

	barra:SetScript("OnMouseUp", function(self)

		if (self.fading_in) then
			return
		end

		if (edFrame.isMoving) then
			--EncounterDetailsFrame:GetParent():StopMovingOrSizing()
			edFrame.isMoving = false
			--instancia:SaveMainWindowPosition() --precisa fazer algo pra salvar o trem
		end

		local x, y = GetCursorPosition()
		x = math.floor(x)
		y = math.floor(y)

		if ((self.mouse_down+0.4 > GetTime() and(x == self.x and y == self.y)) or(x == self.x and y == self.y)) then
			Details:BossInfoRowClick(self)
		end
	end)

	barra:SetScript("OnEnter", --MOUSE OVER
		function(self)
			--aqui 1
			if (container.fading_in or container.faded) then
				return
			end

			self.mouse_over = true
			self:SetHeight(encounterDetails.Frame.DefaultBarHeight + 1)
			self:SetAlpha(1)
			encounterDetails.SetBarBackdrop_OnEnter(self)

			--GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
			GameCooltip:Preset(2)
			GameCooltip:SetOwner(self)
			encounterDetails:FormatCooltipSettings()

			if (not self.TTT) then --tool tip type
				return
			end

			if (self.TTT == "damage_taken") then --damage taken
				DamageTakenDetails(self.jogador, barra)

			elseif (self.TTT == "habilidades_inimigas") then --enemy abilytes
				self.spellid = self.jogador [4]
				EnemySkills(self.jogador, self)

			elseif (self.TTT == "total_interrupt") then
				self.spellid = self.jogador [3]
				KickBy(self.jogador, self)

			elseif (self.TTT == "dispell") then
				self.spellid = self.jogador [3]
				DispellInfo(self.jogador, self)

			elseif (self.TTT == "morte") then --deaths
				KillInfo(self.jogador, self) --aqui 2
			end

			GameCooltip:Show()
		end)

	barra:SetScript("OnLeave", --MOUSE OUT
		function(self)

			self:SetScript("OnUpdate", nil)

			if (self.fading_in or self.faded or not self:IsShown() or self.hidden) then
				return
			end

			self:SetHeight(encounterDetails.Frame.DefaultBarHeight)
			self:SetAlpha(0.9)

			encounterDetails.SetBarBackdrop_OnLeave(self)

			GameTooltip:Hide()
			GameCooltip:Hide()

			if (self.OverlayTexture) then
				self.OverlayTexture:Hide()
			end
		end)
end

--Here start the data mine ---------------------------------------------------------------------------------------------------------
function encounterDetails:OpenAndRefresh(_, segment)
	local segmentsDropdown = _G[edFrame:GetName() .. "SegmentsDropdown"]
	segmentsDropdown.MyObject:Refresh()
	encounterDetails.LastOpenedTime = GetTime()
	segmentsDropdown.MyObject:Refresh()

	edFrame.ShowType = encounterDetails.db.last_section_selected

	if (segment) then
		_combat_object = encounterDetails:GetCombat(segment)
		encounterDetails._segment = segment
		DebugMessage("there's a segment to use:", segment, _combat_object, _combat_object and _combat_object.is_boss)

	else
		DebugMessage("no segment has been passed, looping segments to find one.")
		local segmentsTable = Details:GetCombatSegments()
		local foundABoss = false

		for index, combatObject in ipairs(segmentsTable) do
			if (combatObject.is_boss and combatObject.is_boss.index) then
				encounterDetails._segment = index
				_combat_object = combatObject

				DebugMessage("segment found: ", index, combatObject:GetCombatName(), combatObject.is_trash)
				--the first segment found here will be the first segment the dropdown found, so it can use the index 1 of the dropdown list
				_G [edFrame:GetName().."SegmentsDropdown"].MyObject:Select(1, true)

				foundABoss = true
				break
			end
		end

		if (not foundABoss) then
			DebugMessage("boss not found during the segment loop")
		end
	end

	if (not _combat_object) then
		--EncounterDetails:Msg("no combat found.")
		DebugMessage("_combat_object is nil, EXIT")
		return
	end

	if (not _combat_object.is_boss) then
		DebugMessage("_combat_object is not a boss, trying another loop in the segments")

		local foundSegment
		for index, combat in ipairs(encounterDetails:GetCombatSegments()) do
			if (combat.is_boss and encounterDetails:GetBossDetails(combat.is_boss.mapid, combat.is_boss.index)) then
				_combat_object = combat

				--the first segment found here will be the first segment the dropdown found, so it can use the index 1 of the dropdown list
				_G [edFrame:GetName() .. "SegmentsDropdown"].MyObject:Select(1, true)

				DebugMessage("found another segment during another loop", index, combat:GetCombatName(), combat.is_trash)
				foundSegment = true
				break
			end
		end

		if (not foundSegment) then
			DebugMessage("boss not found during the second loop segment")
		end

		if (not _combat_object.is_boss) then
			DebugMessage("_combat_object still isn't a boss segment, trying to get the last segment shown.")
			if (encounterDetails.LastSegmentShown) then
				_combat_object = encounterDetails.LastSegmentShown
				DebugMessage("found the last segment shown, using it.")
			else
				DebugMessage("the segment isn't a boss, EXIT.")
				return
			end
		end
	end

	encounterDetails.LastSegmentShown = _combat_object

	encounterDetails.Frame.switch(edFrame.ShowType)

	if (edFrame.ShowType == "phases") then
		EncounterDetailsPhaseFrame.OnSelectPhase(1)

	elseif (edFrame.ShowType == "graph") then
		encounterDetails:ShowChartFrame()
	end

-------------- set boss name and zone name --------------
	edFrame.bossNameLabel:SetText(_combat_object.is_boss.encounter)
	edFrame.raidNameLabel:SetText(_combat_object.is_boss.zone)

-------------- set portrait and background image --------------

	local mapID = _combat_object.is_boss.mapid
	local L, R, T, B, Texture = encounterDetails:GetBossIcon(mapID, _combat_object.is_boss.index)

	if (L) then
		edFrame.bossIcon:SetTexture(Texture)
		edFrame.bossIcon:SetTexCoord(L, R, T, B)
	else
		edFrame.bossIcon:SetTexture([[Interface\CHARACTERFRAME\TempPortrait]])
		edFrame.bossIcon:SetTexCoord(0, 1, 0, 1)
	end

	--[=[
	local file, L, R, T, B = EncounterDetails:GetRaidBackground(_combat_object.is_boss.mapid)
	if (file) then
		edFrame.raidBackgroundTexture:SetTexture(file)
		edFrame.raidBackgroundTexture:SetTexCoord(L, R, T, B)
	else
		edFrame.raidBackgroundTexture:SetTexture([[Interface\Glues\LOADINGSCREENS\LoadScreenDungeon]])
		edFrame.raidBackgroundTexture:SetTexCoord(0, 1, 120/512, 408/512)
	end
	--]=]

	edFrame.raidBackgroundTexture:SetTexture(.3, .3, .3, .5)
end

local events_to_track = {
	["SPELL_CAST_START"] = true, --not instant cast
	["SPELL_CAST_SUCCESS"] = true, --not instant cast
	["SPELL_AURA_APPLIED"] = true, --if is a debuff
	["SPELL_DAMAGE"] = true, --damage
	["SPELL_PERIODIC_DAMAGE"] = true, --dot damage
	["SPELL_HEAL"] = true, --healing
	["SPELL_PERIODIC_HEAL"] = true, --dot healing
}

local enemy_spell_pool
local CLEvents = function(self, event)
	local time, token, hidding, who_serial, who_name, who_flags, who_flags2, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, school, aura_type = CombatLogGetCurrentEventInfo()

	if (events_to_track [token] and bitBand(who_flags or 0x0, 0x00000060) ~= 0) then
		local t = enemy_spell_pool [spellid]
		if (not t) then
			t = {["token"] = {[token] = true}, ["source"] = who_name, ["school"] = school}
			if (token == "SPELL_AURA_APPLIED") then
				t.type = aura_type
			end
			enemy_spell_pool [spellid] = t
			return

		elseif (t.token [token]) then
			return
		end

		t.token [token] = true
		if (token == "SPELL_AURA_APPLIED") then
			t.type = aura_type
		end
	end
end

local installPluginFunc = function()
	if (Details and Details.InstallOkey and Details:InstallOkey()) then
		if (DetailsFramework.IsClassicWow()) then
			return
		end

		--create widgets
		CreatePluginFrames(data)

		local PLUGIN_MINIMAL_DETAILS_VERSION_REQUIRED = 1
		local PLUGIN_TYPE = "TOOLBAR"
		local PLUGIN_LOCALIZED_NAME = Loc ["STRING_PLUGIN_NAME"]
		local PLUGIN_ICON = [[Interface\Scenarios\ScenarioIcon-Boss]]
		local PLUGIN_AUTHOR = "Terciob"
		local PLUGIN_VERSION = "v1.06"

		local defaultSettings = {
			show_icon = 5, --automatic
			hide_on_combat = false, --hide the window when a new combat start
			max_emote_segments = 3,
			opened = 0,
			encounter_timers_dbm = {},
			encounter_timers_bw = {},
			window_scale = 1,
			last_section_selected = "main",
		}

		--install
		local install, saveddata, isEnabled = Details:InstallPlugin(
			PLUGIN_TYPE,
			PLUGIN_LOCALIZED_NAME,
			PLUGIN_ICON,
			encounterDetails,
			PLUGIN_REAL_NAME,
			PLUGIN_MINIMAL_DETAILS_VERSION_REQUIRED,
			PLUGIN_AUTHOR,
			PLUGIN_VERSION,
			defaultSettings
		)

		if (type(install) == "table" and install.error) then
			print(install.error)
		end

		encounterDetails.charsaved = EncounterDetailsDB or {emotes = {}, chartData = {}}
		EncounterDetailsDB = encounterDetails.charsaved

		EncounterDetailsDB.chartData = EncounterDetailsDB.chartData or {}
		EncounterDetailsDB.emotes = EncounterDetailsDB.emotes or {}

		--make a cleanup on saved charts
		local now = time()
		for combatUniqueId, charts in pairs(EncounterDetailsDB.chartData) do
			--check if details! still have a combat with the same id
			local bCombatExists = Details:DoesCombatWithUIDExists(combatUniqueId)
			if (not bCombatExists) then
				EncounterDetailsDB.chartData[combatUniqueId] = nil
			else
				--check if the data is already 48hrs old
				for chartName, chartData in pairs(charts) do
					if (chartData.__time) then
						if (now - chartData.__time > 60*60*24*2) then
							charts[chartName] = nil
						end
					end
				end
			end
		end

		encounterDetails.charsaved.encounter_spells = encounterDetails.charsaved.encounter_spells or {}
		encounterDetails.boss_emotes_table = encounterDetails.charsaved.emotes

		--build a table on global saved variables
		if (not Details.global_plugin_database["DETAILS_PLUGIN_ENCOUNTER_DETAILS"]) then
			Details.global_plugin_database["DETAILS_PLUGIN_ENCOUNTER_DETAILS"] = {encounter_timers_dbm = {}, encounter_timers_bw= {}}
		end

		--Register needed events
		Details:RegisterEvent(encounterDetails, "COMBAT_PLAYER_ENTER")
		Details:RegisterEvent(encounterDetails, "COMBAT_PLAYER_LEAVE")
		Details:RegisterEvent(encounterDetails, "COMBAT_BOSS_FOUND")
		Details:RegisterEvent(encounterDetails, "DETAILS_DATA_RESET")
		Details:RegisterEvent(encounterDetails, "GROUP_ONENTER")
		Details:RegisterEvent(encounterDetails, "GROUP_ONLEAVE")
		Details:RegisterEvent(encounterDetails, "ZONE_TYPE_CHANGED")

		edFrame:RegisterEvent("ENCOUNTER_START")
		edFrame:RegisterEvent("ENCOUNTER_END")
		encounterDetails.EnemySpellPool = encounterDetails.charsaved.encounter_spells
		enemy_spell_pool = encounterDetails.EnemySpellPool
		encounterDetails.CLEvents = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
		encounterDetails.CLEvents:SetScript("OnEvent", CLEvents)
		encounterDetails.CLEvents:Hide()

		encounterDetails.BossWhispColors = {
			[1] = "RAID_BOSS_EMOTE",
			[2] = "RAID_BOSS_WHISPER",
			[3] = "MONSTER_EMOTE",
			[4] = "MONSTER_SAY",
			[5] = "MONSTER_WHISPER",
			[6] = "MONSTER_PARTY",
			[7] = "MONSTER_YELL",
		}
	end
end

function encounterDetails:OnEvent(self, event, ...)
	if (event == "ENCOUNTER_START") then
		--tracks if a enemy spell is instant cast
		encounterDetails.CLEvents:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	elseif (event == "ENCOUNTER_END") then
		encounterDetails.CLEvents:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	elseif (event == "ADDON_LOADED") then
		local addonName = select(1, ...)
		if (addonName == "Details_EncounterDetails") then
			C_Timer.After(1, installPluginFunc)
		end
	end
end
