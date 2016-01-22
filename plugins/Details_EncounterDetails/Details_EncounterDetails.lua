local AceLocale = LibStub ("AceLocale-3.0")
local Loc = AceLocale:GetLocale ("Details_EncounterDetails")
local Graphics = LibStub:GetLibrary("LibGraph-2.0")

--> Needed locals
local _GetTime = GetTime --> wow api local
local _UFC = UnitAffectingCombat --> wow api local
local _IsInRaid = IsInRaid --> wow api local
local _IsInGroup = IsInGroup --> wow api local
local _UnitAura = UnitAura --> wow api local
local _GetSpellInfo = _detalhes.getspellinfo --> wow api local
local _CreateFrame = CreateFrame --> wow api local
local _GetTime = GetTime --> wow api local
local _GetCursorPosition = GetCursorPosition --> wow api local
local _GameTooltip = GameTooltip --> wow api local

local _math_floor = math.floor --> lua library local
local _cstr = string.format --> lua library local
local _ipairs = ipairs --> lua library local
local _pairs = pairs --> lua library local
local _table_sort = table.sort --> lua library local
local _table_insert = table.insert --> lua library local
local _unpack = unpack --> lua library local
local _bit_band = bit.band


--> Create the plugin Object
local EncounterDetails = _detalhes:NewPluginObject ("Details_EncounterDetails", DETAILSPLUGIN_ALWAYSENABLED)
tinsert (UISpecialFrames, "Details_EncounterDetails")
--> Main Frame
local EncounterDetailsFrame = EncounterDetails.Frame

EncounterDetails:SetPluginDescription ("Raid encounters summary, show basic stuff like dispels, interrupts and also graphic charts, boss emotes and the Weakaura Creation Tool.")

--> container types
local class_type_damage = _detalhes.atributos.dano --> damage
local class_type_misc = _detalhes.atributos.misc --> misc
--> main combat object
local _combat_object

local sort_by_name = function (t1, t2) return t1.nome < t2.nome end

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS

EncounterDetails.name = "Encounter Details"
EncounterDetails.debugmode = false

local ability_type_table = {
	[0x1] = "|cFF00FF00"..Loc ["STRING_HEAL"].."|r", 
	[0x2] = "|cFF710000"..Loc ["STRING_LOWDPS"].."|r", 
	[0x4] = "|cFF057100"..Loc ["STRING_LOWHEAL"].."|r", 
	[0x8] = "|cFFd3acff"..Loc ["STRING_VOIDZONE"].."|r", 
	[0x10] = "|cFFbce3ff"..Loc ["STRING_DISPELL"].."|r", 
	[0x20] = "|cFFffdc72"..Loc ["STRING_INTERRUPT"].."|r", 
	[0x40] = "|cFFd9b77c"..Loc ["STRING_POSITIONING"].."|r", 
	[0x80] = "|cFFd7ff36"..Loc ["STRING_RUNAWAY"].."|r", 
	[0x100] = "|cFF9a7540"..Loc ["STRING_TANKSWITCH"] .."|r", 
	[0x200] = "|cFFff7800"..Loc ["STRING_MECHANIC"].."|r", 
	[0x400] = "|cFFbebebe"..Loc ["STRING_CROWDCONTROL"].."|r", 
	[0x800] = "|cFF6e4d13"..Loc ["STRING_TANKCOOLDOWN"].."|r", 
	[0x1000] = "|cFFffff00"..Loc ["STRING_KILLADD"].."|r", 
	[0x2000] = "|cFFff9999"..Loc ["STRING_SPREADOUT"].."|r", 
	[0x4000] = "|cFFffff99"..Loc ["STRING_STOPCAST"].."|r",
	[0x8000] = "|cFFffff99"..Loc ["STRING_FACING"].."|r",
	[0x10000] = "|cFFffff99"..Loc ["STRING_STACK"].."|r",
	
}

--> main object frame functions
local function CreatePluginFrames (data)
	
	--> catch Details! main object
	local _detalhes = _G._detalhes
	local DetailsFrameWork = _detalhes.gump

	--> saved data if any
	EncounterDetails.data = data or {}
	--> record if button is shown
	EncounterDetails.showing = false
	--> record if boss window is open or not
	EncounterDetails.window_open = false
	EncounterDetails.combat_boss_found = false
	
	--> OnEvent Table
	function EncounterDetails:OnDetailsEvent (event, ...)
	
		--> when main frame became hide
		if (event == "HIDE") then --> plugin hidded, disabled
			self.open = false
		
		--> when main frame is shown on screen
		elseif (event == "SHOW") then --> plugin hidded, disabled
			self.open = true
			EncounterDetails:RefreshScale()
		
		--> when details finish his startup and are ready to work
		elseif (event == "DETAILS_STARTED") then

			--> check if details are in combat, if not check if the last fight was a boss fight
			if (not EncounterDetails:IsInCombat()) then
				--> get the current combat table
				_combat_object = EncounterDetails:GetCombat()
				--> check if was a boss fight
				EncounterDetails:WasEncounter()
			end
			
			local damage_done_func = function (support_table, time_table, tick_second)
				local current_total_damage = _detalhes.tabela_vigente.totals_grupo[1]
				local current_damage = current_total_damage - support_table.last_damage
				time_table [tick_second] = current_damage
				if (current_damage > support_table.max_damage) then
					support_table.max_damage = current_damage
					time_table.max_damage = current_damage
				end
				support_table.last_damage = current_total_damage
			end
			
			local string_damage_done_func = [[
			
				-- this script takes the current combat and request the total of damage done by the group.
			
				-- first lets take the current combat and name it "current_combat".
				local current_combat = _detalhes:GetCombat ("current") --> getting the current combat
				
				-- now lets ask the combat for the total damage done by the raide group.
				local total_damage = current_combat:GetTotal ( DETAILS_ATTRIBUTE_DAMAGE, nil, DETAILS_TOTALS_ONLYGROUP )
			
				-- checks if the result is valid
				if (not total_damage) then
					return 0
				end
			
				-- with the  number in hands, lets finish the code returning the amount
				return total_damage
			]]
			
			--_detalhes:TimeDataRegister ("Raid Damage Done", damage_done_func, {last_damage = 0, max_damage = 0}, "Encounter Details", "v1.0", [[Interface\ICONS\Ability_DualWield]], true)
			_detalhes:TimeDataRegister ("Raid Damage Done", string_damage_done_func, nil, "Encounter Details", "v1.0", [[Interface\ICONS\Ability_DualWield]], true, true)

			if (EncounterDetails.db.show_icon == 4) then
				EncounterDetails:ShowIcon()
			elseif (EncounterDetails.db.show_icon == 5) then
				EncounterDetails:AutoShowIcon()
			end
			
			EncounterDetails:CreateCallbackListeners()
		
		elseif (event == "COMBAT_PLAYER_ENTER") then --> combat started
			if (EncounterDetails.showing and EncounterDetails.db.hide_on_combat) then
				--EncounterDetails:HideIcon()
				EncounterDetails:CloseWindow()
			end
			
			EncounterDetails.current_whisper_table = {}
		
		elseif (event == "COMBAT_PLAYER_LEAVE") then
			--> combat leave and enter always send current combat table
			_combat_object = select (1, ...)
			--> check if was a boss fight
			EncounterDetails:WasEncounter()
			if (EncounterDetails.combat_boss_found) then
				EncounterDetails.combat_boss_found = false
			end
			if (EncounterDetails.db.show_icon == 5) then
				EncounterDetails:AutoShowIcon()
			end

			local whisper_table = EncounterDetails.current_whisper_table
			if (whisper_table and _combat_object.is_boss and _combat_object.is_boss.name) then
				whisper_table.boss = _combat_object.is_boss.name
				tinsert (EncounterDetails.boss_emotes_table, 1, whisper_table)
				
				if (#EncounterDetails.boss_emotes_table > EncounterDetails.db.max_emote_segments) then
					table.remove (EncounterDetails.boss_emotes_table, EncounterDetails.db.max_emote_segments+1)
				end
			end
			
		elseif (event == "COMBAT_BOSS_FOUND") then
			EncounterDetails.combat_boss_found = true
			if (EncounterDetails.db.show_icon == 5) then
				EncounterDetails:AutoShowIcon()
			end

		elseif (event == "DETAILS_DATA_RESET") then
			if (_G.DetailsRaidDpsGraph) then
				_G.DetailsRaidDpsGraph:ResetData()
			end
			if (EncounterDetails.db.show_icon == 5) then
				EncounterDetails:AutoShowIcon()
			end
			--EncounterDetails:HideIcon()
			EncounterDetails:CloseWindow()
			
			--drop last combat table
			EncounterDetails.LastSegmentShown = nil
			
			if (DetailsRaidDpsGraph) then
				DetailsRaidDpsGraph.combat = nil
			end
			
			--wipe emotes
			table.wipe (EncounterDetails.boss_emotes_table)
	
		elseif (event == "GROUP_ONENTER") then
			if (EncounterDetails.db.show_icon == 2) then
				EncounterDetails:ShowIcon()
			end
			
		elseif (event == "GROUP_ONLEAVE") then
			if (EncounterDetails.db.show_icon == 2) then
				EncounterDetails:HideIcon()
			end
			
		elseif (event == "ZONE_TYPE_CHANGED") then
			if (EncounterDetails.db.show_icon == 1) then
				if (select (1, ...) == "raid") then
					EncounterDetails:ShowIcon()
				else
					EncounterDetails:HideIcon()
				end
			end
		
		elseif (event == "PLUGIN_DISABLED") then
			EncounterDetails:HideIcon()
			EncounterDetails:CloseWindow()
			
		elseif (event == "PLUGIN_ENABLED") then
			if (EncounterDetails.db.show_icon == 5) then
				EncounterDetails:AutoShowIcon()
			elseif (EncounterDetails.db.show_icon == 4) then
				EncounterDetails:ShowIcon()
			end
		end
	end
	
	function EncounterDetails:CreateCallbackListeners()
	
		EncounterDetails.DBM_timers = {}
		
		local current_encounter = false
		
		local current_table_dbm = {}
		local current_table_bigwigs = {}
	
		local event_frame = CreateFrame ("frame", nil, UIParent)
		event_frame:SetScript ("OnEvent", function (self, event, ...)
			if (event == "ENCOUNTER_START") then
				local encounterID, encounterName, difficultyID, raidSize = select (1, ...)
				current_encounter = encounterID
				
			elseif (event == "ENCOUNTER_END" or event == "PLAYER_REGEN_ENABLED") then
				if (current_encounter) then
				
					if (_G.DBM) then
						local db = _detalhes.global_plugin_database ["DETAILS_PLUGIN_ENCOUNTER_DETAILS"]
						for spell, timer_table in pairs (current_table_dbm) do
							if (not db.encounter_timers_dbm [timer_table[1]]) then
								timer_table.id = current_encounter
								db.encounter_timers_dbm [timer_table[1]] = timer_table
							end
						end
					end
					if (BigWigs) then
						local db = _detalhes.global_plugin_database ["DETAILS_PLUGIN_ENCOUNTER_DETAILS"]
						for timer_id, timer_table in pairs (current_table_bigwigs) do
							if (not db.encounter_timers_bw [timer_id]) then
								timer_table.id = current_encounter
								db.encounter_timers_bw [timer_id] = timer_table
							end
						end
					end
					
				end	
				
				current_encounter = false
				wipe (current_table_dbm)
				wipe (current_table_bigwigs)
			end
		end)
		event_frame:RegisterEvent ("ENCOUNTER_START")
		event_frame:RegisterEvent ("ENCOUNTER_END")
		event_frame:RegisterEvent ("PLAYER_REGEN_ENABLED")
		
--DBM_TimerStart Timer183828cdcount	2 Death Brand CD (2) 42.5 Interface\Icons\warlock_summon_doomguard cdcount 183828 1 1438		
--DBM_TimerStart Timer183828cdcount	3 Death Brand CD (3) 42.5 Interface\Icons\warlock_summon_doomguard cdcount 183828 1 1438
		
		--EncounterDetails.DBM_timers
		if (_G.DBM) then
			local dbm_timer_callback = function (bar_type, id, msg, timer, icon, bartype, spellId, colorId, modid)
				--print (bar_type, id, msg, timer, icon, bartype, spellId, colorId, modid)
				local spell = tostring (spellId)
				if (spell and not current_table_dbm [spell]) then
					current_table_dbm [spell] = {spell, id, msg, timer, icon, bartype, spellId, colorId, modid}
				end
			end
			DBM:RegisterCallback ("DBM_TimerStart", dbm_timer_callback)
		end
		function EncounterDetails:RegisterBigWigsCallBack()
			if (BigWigs) then
				BigWigs:Enable()
				function EncounterDetails:BigWigs_StartBar (event, module, spellid, bar_text, time, icon, ...)
					--print (event, module, spellid, bar_text, time, icon, ...)
					spellid = tostring (spellid)
					if (not current_table_bigwigs [spellid]) then
						current_table_bigwigs [spellid] = {(type (module) == "string" and module) or (module and module.moduleName) or "", spellid or "", bar_text or "", time or 0, icon or ""}
					end
				end
				BigWigs.RegisterMessage (EncounterDetails, "BigWigs_StartBar")
			end
		end
		EncounterDetails:ScheduleTimer ("RegisterBigWigsCallBack", 5)
	
--BigWigs_StartBar BigWigs_Bosses_Brackenspore mind_fungus Mind Fungus 51 Interface\Icons\inv_mushroom_10 true
--bigwigs startbar mind_fungus	

--BigWigs_StartBar BigWigs_Bosses_Brackenspore 159996 Infesting Spores (2) 58 Interface\Icons\Ability_Creature_Disease_01
--bigwigs startbar 160013
	
	end
	
	function EncounterDetails:WasEncounter()

		--> check if last combat was a boss encounter fight
		if (not EncounterDetails.debugmode) then
		
			if (not _combat_object.is_boss) then
				return
			elseif (_combat_object.is_boss.encounter == "pvp") then 
				return
			end
			
			if (_combat_object.instance_type ~= "raid") then
				return
			end
			
		end

		--> boss found, we need to show the icon
		EncounterDetails:ShowIcon()
	end
	
	--> show icon on toolbar
	function EncounterDetails:ShowIcon()
		EncounterDetails.showing = true
		--> [1] button to show [2] button animation: "star", "blink" or true (blink)
		EncounterDetails:ShowToolbarIcon (EncounterDetails.ToolbarButton, "star")
		
		--EncounterDetails:SetTutorialCVar ("ENCOUNTER_DETAILS_TUTORIAL1", false)
		
		if (not EncounterDetails:GetTutorialCVar ("ENCOUNTER_DETAILS_TUTORIAL1")) then
			EncounterDetails:SetTutorialCVar ("ENCOUNTER_DETAILS_TUTORIAL1", true)
			local plugin_icon_alert = CreateFrame ("frame", "EncounterDetailsPopUp1", EncounterDetails.ToolbarButton, "DetailsHelpBoxTemplate")
			plugin_icon_alert.ArrowUP:Show()
			plugin_icon_alert.ArrowGlowUP:Show()
			plugin_icon_alert.Text:SetText ("Encounter Details is Ready!\n\nTake a look in the encounter summary, click here!")
			plugin_icon_alert:SetPoint ("bottom", EncounterDetails.ToolbarButton, "top", 0, 30)
			plugin_icon_alert:Show()
		end
		
	end
	
	-->  hide icon on toolbar
	function EncounterDetails:HideIcon()
		EncounterDetails.showing = false
		EncounterDetails:HideToolbarIcon (EncounterDetails.ToolbarButton)
	end
	
	--> user clicked on button, need open or close window
	function EncounterDetails:OpenWindow()
		if (EncounterDetails.open) then
			return EncounterDetails:CloseWindow()
		end
		
		--> build all window data
		EncounterDetails.db.opened = EncounterDetails.db.opened + 1
		EncounterDetails:OpenAndRefresh()
		--> show
		EncounterDetailsFrame:Show()
		EncounterDetails.open = true
		
		if (EncounterDetailsFrame.ShowType == "graph") then
			EncounterDetails:BuildDpsGraphic()
		end
		
		--EncounterDetails:SetTutorialCVar ("ENCOUNTER_DETAILS_TUTORIAL2", false)
		if (not EncounterDetails:GetTutorialCVar ("ENCOUNTER_DETAILS_TUTORIAL2")) then
			EncounterDetails:SetTutorialCVar ("ENCOUNTER_DETAILS_TUTORIAL2", true)
			EncounterDetails:ButtonsTutorial()
		end

		--select latest emote segment
		Details_EncounterDetailsEmotesSegmentDropdown.MyObject:Select (1)
		Details_EncounterDetailsEmotesSegmentDropdown.MyObject:Refresh()
		FauxScrollFrame_SetOffset (EncounterDetails_EmoteScroll, 0)
		EncounterDetails:SetEmoteSegment (1)
		EncounterDetails_EmoteScroll:Update()
		
		if (EncounterDetailsFrame.ShowType ~= "emotes") then
			--hide emote frames
			for _, widget in pairs (EncounterDetails.Frame.EmoteWidgets) do
				widget:Hide()
			end
		end
		
		return true
	end
	
	function EncounterDetails:CloseWindow()
		EncounterDetails.open = false
		EncounterDetailsFrame:Hide()
		return true
	end
	
	EncounterDetails.ToolbarButton = _detalhes.ToolBar:NewPluginToolbarButton (EncounterDetails.OpenWindow, "Interface\\AddOns\\Details_EncounterDetails\\images\\icon", Loc ["STRING_PLUGIN_NAME"], Loc ["STRING_TOOLTIP"], 16, 16, "ENCOUNTERDETAILS_BUTTON") --"Interface\\COMMON\\help-i"
	EncounterDetails.ToolbarButton.shadow = true --> loads icon_shadow.tga when the instance is showing icons with shadows
	
	--> setpoint anchors mod if needed
	EncounterDetails.ToolbarButton.y = 0.5
	EncounterDetails.ToolbarButton.x = 0
	
	--> build all frames ans widgets
	_detalhes.EncounterDetailsTempWindow (EncounterDetails)
	_detalhes.EncounterDetailsTempWindow = nil
	
end

local IsShiftKeyDown = IsShiftKeyDown

local shift_monitor = function (self)
	if (IsShiftKeyDown()) then
		local spellname = GetSpellInfo (self.spellid)
		if (spellname) then
			GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
			GameTooltip:SetSpellByID (self.spellid)
			GameTooltip:Show()
			self.showing_spelldesc = true
		end
	else
		if (self.showing_spelldesc) then
			self:GetScript ("OnEnter") (self)
			self.showing_spelldesc = false
		end
	end
end

local sort_damage_from = function (a, b) 
	if (a[3] ~= "PET" and b[3] ~= "PET") then 
		return a[2] > b[2] 
	elseif (a[3] == "PET" and b[3] ~= "PET") then
		return false
	elseif (a[3] ~= "PET" and b[3] == "PET") then
		return true
	else
		return a[2] > b[2] 
	end
end

--> custom tooltip for dead details ---------------------------------------------------------------------------------------------------------

	local function KillInfo (deathTable, row)
		
		local eventos = deathTable [1]
		local hora_da_morte = deathTable [2]
		local hp_max = deathTable [5]
		
		local battleress = false
		local lastcooldown = false
		
		local GameCooltip = GameCooltip
		
		GameCooltip:Reset()
		GameCooltip:SetType ("tooltipbar")
		GameCooltip:SetOwner (row)
		
		GameCooltip:AddLine ("Click to Report", nil, 1, "orange")
		GameCooltip:AddIcon ([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 1, 1, 12, 16, 0.015625, 0.13671875, 0.4375, 0.59765625)
		GameCooltip:AddStatusBar (0, 1, 1, 1, 1, 1, false, {value = 100, color = {.3, .3, .3, 1}, specialSpark = false, texture = [[Interface\AddOns\Details\images\bar_serenity]]})

		--death parser
		for index, event in _ipairs (eventos) do 
		
			local hp = _math_floor (event[5]/hp_max*100)
			if (hp > 100) then 
				hp = 100
			end
			
			local evtype = event [1]
			local spellname, _, spellicon = _GetSpellInfo (event [2])
			local amount = event [3]
			local time = event [4]
			local source = event [6]

			if (type (evtype) == "boolean") then
				--> is damage or heal
				if (evtype) then
					--> damage
					
					local overkill = event [10] or 0
					if (overkill > 0) then
						amount = amount - overkill
						overkill = " (" .. _detalhes:ToK (overkill) .. " |cFFFF8800overkill|r)"
					else
						overkill = ""
					end
					
					GameCooltip:AddLine ("" .. _cstr ("%.1f", time - hora_da_morte) .. "s " .. spellname .. " (" .. source .. ")", "-" .. _detalhes:ToK (amount) .. overkill .. " (" .. hp .. "%)", 1, "white", "white")
					GameCooltip:AddIcon (spellicon)
					
					if (event [9]) then
						--> friendly fire
						GameCooltip:AddStatusBar (hp, 1, "darkorange", true)
					else
						--> from a enemy
						GameCooltip:AddStatusBar (hp, 1, "red", true)
					end
				else
					--> heal
					GameCooltip:AddLine ("" .. _cstr ("%.1f", time - hora_da_morte) .. "s " .. spellname .. " (" .. source .. ")", "+" .. _detalhes:ToK (amount) .. " (" .. hp .. "%)", 1, "white", "white")
					GameCooltip:AddIcon (spellicon)
					GameCooltip:AddStatusBar (hp, 1, "green", true)
					
				end
				
			elseif (type (evtype) == "number") then
				if (evtype == 1) then
					--> cooldown
					GameCooltip:AddLine ("" .. _cstr ("%.1f", time - hora_da_morte) .. "s " .. spellname .. " (" .. source .. ")", "cooldown (" .. hp .. "%)", 1, "white", "white")
					GameCooltip:AddIcon (spellicon)
					GameCooltip:AddStatusBar (100, 1, "yellow", true)
					
				elseif (evtype == 2 and not battleress) then
					--> battle ress
					battleress = event
					
				elseif (evtype == 3) then
					--> last cooldown used
					lastcooldown = event
					
				end
			end
		end

		GameCooltip:AddLine (deathTable [6] .. " " .. "died" , "-- -- -- ", 1, "white")
		GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\small_icons", 1, 1, nil, nil, .75, 1, 0, 1)
		GameCooltip:AddStatusBar (0, 1, .5, .5, .5, .5, false, {value = 100, color = {.5, .5, .5, 1}, specialSpark = false, texture = [[Interface\AddOns\Details\images\bar4_vidro]]})
		
		if (battleress) then
			local nome_magia, _, icone_magia = _GetSpellInfo (battleress [2])
			GameCooltip:AddLine ("+" .. _cstr ("%.1f", battleress[4] - hora_da_morte) .. "s " .. nome_magia .. " (" .. battleress[6] .. ")", "", 1, "white")
			GameCooltip:AddIcon ("Interface\\Glues\\CharacterSelect\\Glues-AddOn-Icons", 1, 1, nil, nil, .75, 1, 0, 1)
			GameCooltip:AddStatusBar (0, 1, .5, .5, .5, .5, false, {value = 100, color = {.5, .5, .5, 1}, specialSpark = false, texture = [[Interface\AddOns\Details\images\bar4_vidro]]})
		end
		
		if (lastcooldown) then
			if (lastcooldown[3] == 1) then 
				local nome_magia, _, icone_magia = _GetSpellInfo (lastcooldown [2])
				GameCooltip:AddLine (_cstr ("%.1f", lastcooldown[4] - hora_da_morte) .. "s " .. nome_magia .. " (" .. Loc ["STRING_LAST_COOLDOWN"] .. ")")
				GameCooltip:AddIcon (icone_magia)
			else
				GameCooltip:AddLine (Loc ["STRING_NOLAST_COOLDOWN"])
				GameCooltip:AddIcon ([[Interface\CHARACTERFRAME\UI-Player-PlayTimeUnhealthy]], 1, 1, 18, 18)
			end
				GameCooltip:AddStatusBar (0, 1, 1, 1, 1, 1, false, {value = 100, color = {.3, .3, .3, 1}, specialSpark = false, texture = [[Interface\AddOns\Details\images\bar_serenity]]})
		end


		GameCooltip:SetOption ("StatusBarHeightMod", -6)
		GameCooltip:SetOption ("FixedWidth", 300)
		GameCooltip:SetOption ("TextSize", 9)
		GameCooltip:SetOption ("LeftBorderSize", -4)
		GameCooltip:SetOption ("RightBorderSize", 5)
		GameCooltip:SetOption ("StatusBarTexture", [[Interface\AddOns\Details\images\bar4_reverse]])
		GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0.64453125, 0}, {.8, .8, .8, 0.2}, true)
		
		GameCooltip:ShowCooltip()
	end

--> custom tooltip for dispells details ---------------------------------------------------------------------------------------------------------
local function DispellInfo (dispell, barra)
	
	local jogadores = dispell [1] --> [nome od jogador] = total
	local tabela_jogadores = {}
	
	for nome, tabela in _pairs (jogadores) do --> tabela = [1] total tomado [2] classe
		tabela_jogadores [#tabela_jogadores + 1] = {nome, tabela [1], tabela [2]}
	end
	
	_table_sort (tabela_jogadores, _detalhes.Sort2)
	
	_GameTooltip:ClearLines()
	_GameTooltip:AddLine (barra.texto_esquerdo:GetText())
	
	for index, tabela in _ipairs (tabela_jogadores) do
		local coords = EncounterDetails.class_coords [tabela[3]]
		if (not coords) then
			GameTooltip:AddDoubleLine ("|TInterface\\GossipFrame\\DailyActiveQuestIcon:14:14:0:0:16:16:0:1:0:1".."|t "..tabela[1]..": ", tabela[2], 1, 1, 1, 1, 1, 1)
		else
			GameTooltip:AddDoubleLine ("|TInterface\\AddOns\\Details\\images\\classes_small:14:14:0:0:128:128:"..(coords[1]*128)..":"..(coords[2]*128)..":"..(coords[3]*128)..":"..(coords[4]*128).."|t "..tabela[1]..": ", tabela[2], 1, 1, 1, 1, 1, 1)
		end
	end
end

--> custom tooltip for kick details ---------------------------------------------------------------------------------------------------------

local function KickBy (magia, barra)

	local jogadores = magia [1] --> [nome od jogador] = total
	local tabela_jogadores = {}
	
	for nome, tabela in _pairs (jogadores) do --> tabela = [1] total tomado [2] classe
		tabela_jogadores [#tabela_jogadores + 1] = {nome, tabela [1], tabela [2]}
	end
	
	_table_sort (tabela_jogadores, _detalhes.Sort2)
	
	_GameTooltip:ClearLines()
	_GameTooltip:AddLine (barra.texto_esquerdo:GetText())
	
	for index, tabela in _ipairs (tabela_jogadores) do
		local coords = EncounterDetails.class_coords [tabela[3]]
		GameTooltip:AddDoubleLine ("|TInterface\\AddOns\\Details\\images\\classes_small:14:14:0:0:128:128:"..(coords[1]*128)..":"..(coords[2]*128)..":"..(coords[3]*128)..":"..(coords[4]*128).."|t "..tabela[1]..": ", tabela[2], 1, 1, 1, 1, 1, 1)
	end
end

--> custom tooltip for enemy abilities details ---------------------------------------------------------------------------------------------------------

local function EnemySkills (habilidade, barra)
	--> barra.jogador agora tem a tabela com --> [1] total dano causado [2] jogadores que foram alvos [3] jogadores que castaram essa magia [4] ID da magia
	
	local total = habilidade [1]
	local jogadores = habilidade [2] --> [nome od jogador] = total
	
	local tabela_jogadores = {}
	
	for nome, tabela in _pairs (jogadores) do --> tabela = [1] total tomado [2] classe
		tabela_jogadores [#tabela_jogadores + 1] = {nome, tabela[1], tabela[2]}
	end
	
	_table_sort (tabela_jogadores, _detalhes.Sort2)
	
	_GameTooltip:ClearLines()
	_GameTooltip:AddLine (barra.texto_esquerdo:GetText())
	
	for index, tabela in _ipairs (tabela_jogadores) do
		local coords = EncounterDetails.class_coords [tabela[3]]
		if (coords) then
			GameTooltip:AddDoubleLine ("|TInterface\\AddOns\\Details\\images\\classes_small:14:14:0:0:128:128:"..(coords[1]*128)..":"..(coords[2]*128)..":"..(coords[3]*128)..":"..(coords[4]*128).."|t "..tabela[1]..": ", _detalhes:comma_value(tabela[2]).." (".._cstr("%.1f", (tabela[2]/total) * 100).."%)", 1, 1, 1, 1, 1, 1)
		end
		--GameTooltip:AddDoubleLine ("|TInterface\\AddOns\\Details\\images\\classes_small:14:14:0:0:128:128:"..coords[1]..":"..coords[2]..":"..coords[3]..":"..coords[4].."|t "..tabela[1]..": ", _detalhes:comma_value(tabela[2]).." (".._cstr("%.1f", (tabela[2]/total) * 100).."%)", 1, 1, 1, 1, 1, 1)
	end
	
end

--> custom tooltip for damage taken details ---------------------------------------------------------------------------------------------------------

local function DamageTakenDetails (jogador, barra)

	local agressores = jogador.damage_from
	local damage_taken = jogador.damage_taken
	
	local showing = _combat_object [class_type_damage] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable
	
	local meus_agressores = {}
	
	for nome, _ in _pairs (agressores) do --> agressores seria a lista de nomes
		local este_agressor = showing._ActorTable[showing._NameIndexTable[nome]]
		if (este_agressor) then --> checagem por causa do total e do garbage collector que não limpa os nomes que deram dano
			local habilidades = este_agressor.spells._ActorTable
			for id, habilidade in _pairs (habilidades) do 
			--print ("oi - " .. este_agressor.nome)
				local alvos = habilidade.targets
				for target_name, amount in _pairs (alvos) do 
					if (target_name == jogador.nome) then
						meus_agressores [#meus_agressores+1] = {id, amount, este_agressor.nome}
					end
				end
			end
		end
	end

	_table_sort (meus_agressores, _detalhes.Sort2)
	
	_GameTooltip:ClearLines()
	_GameTooltip:AddLine (barra.texto_esquerdo:GetText())

	local max = #meus_agressores
	if (max > 20) then
		max = 20
	end

	local teve_melee = false
	
	for i = 1, max do
	
		local nome_magia, _, icone_magia = _GetSpellInfo (meus_agressores[i][1])
		
		if (meus_agressores[i][1] == 1) then 
			nome_magia = "*"..meus_agressores[i][3]
			teve_melee = true
		end
		
		GameTooltip:AddDoubleLine (nome_magia..": ", _detalhes:comma_value(meus_agressores[i][2]).." (".._cstr("%.1f", (meus_agressores[i][2]/damage_taken) * 100).."%)", 1, 1, 1, 1, 1, 1)
		GameTooltip:AddTexture (icone_magia)
	end
	
	if (teve_melee) then
		GameTooltip:AddLine ("* "..Loc ["STRING_MELEE_DAMAGE"], 0, 1, 0)
	end
end

--> custom tooltip clicks on any bar ---------------------------------------------------------------------------------------------------------
function _detalhes:BossInfoRowClick (barra, param1)
	
	if (type (self) == "table") then
		barra, param1 = self, barra
	end
	
	if (type (param1) == "table") then
		barra = param1
	end
	
	if (barra._no_report) then
		return
	end

	local reportar
	
	if (barra.TTT == "morte") then --> deaths
		reportar = {barra.report_text .. " " .. barra.texto_esquerdo:GetText()}
		for i = 1, GameCooltip:GetNumLines(), 1 do 
		
			local texto_left, texto_right = GameCooltip:GetText (i)

			if (texto_left and texto_right) then 
				texto_left = texto_left:gsub (("|T(.*)|t "), "")
				reportar [#reportar+1] = ""..texto_left.." "..texto_right..""
			end
		end
	else
		
		barra.report_text = barra.report_text or ""
		reportar = {barra.report_text .. " " .. _G.GameTooltipTextLeft1:GetText()}
		local numLines = _GameTooltip:NumLines()
		
		for i = 1, numLines, 1 do 
			local nome_left = "GameTooltipTextLeft"..i
			local texto_left = _G[nome_left]
			texto_left = texto_left:GetText()
			
			local nome_right = "GameTooltipTextRight"..i
			local texto_right = _G[nome_right]
			texto_right = texto_right:GetText()
			
			if (texto_left and texto_right) then 
				texto_left = texto_left:gsub (("|T(.*)|t "), "")
				reportar [#reportar+1] = ""..texto_left.." "..texto_right..""
			end
		end		
	end

	return _detalhes:Reportar (reportar, {_no_current = true, _no_inverse = true, _custom = true})
	
end

--> custom tooltip that handle mouse enter and leave on customized rows ---------------------------------------------------------------------------------------------------------

local backdrop_bar_onenter = {bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16, edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 8, insets = {left = 1, right = 1, top = 0, bottom = 1}}
local backdrop_bar_onleave = {bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16, insets = {left = 1, right = 1, top = 0, bottom = 1}}

function EncounterDetails:SetRowScripts (barra, index, container)

	barra:SetScript ("OnMouseDown", function (self)
		if (self.fading_in) then
			return
		end
	
		self.mouse_down = _GetTime()
		local x, y = _GetCursorPosition()
		self.x = _math_floor (x)
		self.y = _math_floor (y)

		EncounterDetailsFrame:StartMoving()
		EncounterDetailsFrame.isMoving = true
		
	end)
	
	barra:SetScript ("OnMouseUp", function (self)

		if (self.fading_in) then
			return
		end
	
		if (EncounterDetailsFrame.isMoving) then
			EncounterDetailsFrame:StopMovingOrSizing()
			EncounterDetailsFrame.isMoving = false
			--instancia:SaveMainWindowPosition() --> precisa fazer algo pra salvar o trem
		end
	
		local x, y = _GetCursorPosition()
		x = _math_floor (x)
		y = _math_floor (y)
		if ((self.mouse_down+0.4 > _GetTime() and (x == self.x and y == self.y)) or (x == self.x and y == self.y)) then
			_detalhes:BossInfoRowClick (self)
		end
	end)
	
	barra:SetScript ("OnEnter", --> MOUSE OVER
		function (self) 
			--> aqui 1
			if (container.fading_in or container.faded) then
				return
			end
		
			self.mouse_over = true
			
			self:SetHeight (17)
			self:SetAlpha(1)
			
			self:SetBackdrop (backdrop_bar_onenter)	
			self:SetBackdropColor (.0, .0, .0, 0.3)
			self:SetBackdropBorderColor (.0, .0, .0, 0.5)
			
			GameTooltip:SetOwner (self, "ANCHOR_TOPRIGHT")
			
			if (not self.TTT) then --> tool tip type
				return
			end
			
			if (self.TTT == "damage_taken") then --> damage taken
				DamageTakenDetails (self.jogador, barra)
				
			elseif (self.TTT == "habilidades_inimigas") then --> enemy abilytes
				EnemySkills (self.jogador, self)
				self:SetScript ("OnUpdate", shift_monitor)
				self.spellid = self.jogador [4]
				_GameTooltip:AddLine (" ")
				_GameTooltip:AddLine (Loc ["STRING_HOLDSHIFT"])
				
			elseif (self.TTT == "total_interrupt") then
				KickBy (self.jogador, self)
				self:SetScript ("OnUpdate", shift_monitor)
				self.spellid = self.jogador [3]
				_GameTooltip:AddLine (" ")
				_GameTooltip:AddLine (Loc ["STRING_HOLDSHIFT"])
				
			elseif (self.TTT == "dispell") then
				DispellInfo (self.jogador, self)
				self:SetScript ("OnUpdate", shift_monitor)
				self.spellid = self.jogador [3]
				_GameTooltip:AddLine (" ")
				_GameTooltip:AddLine (Loc ["STRING_HOLDSHIFT"])
				
			elseif (self.TTT == "morte") then --> deaths
				KillInfo (self.jogador, self) --> aqui 2
			end

			GameTooltip:Show()
		end)
	
	barra:SetScript ("OnLeave", --> MOUSE OUT
		function (self) 
		
			self:SetScript ("OnUpdate", nil)
		
			if (self.fading_in or self.faded or not self:IsShown() or self.hidden) then
				return
			end
			
			self:SetHeight (16)
			self:SetAlpha (0.9)
			
			self:SetBackdrop (backdrop_bar_onleave)
			self:SetBackdropColor (.0, .0, .0, 0.3)
			
			GameTooltip:Hide()
			_detalhes.popup:ShowMe (false, "tooltip")
		
		end)
end

--> Here start the data mine ---------------------------------------------------------------------------------------------------------
function EncounterDetails:OpenAndRefresh (_, segment)
	
	local frame = EncounterDetailsFrame --alias

	if (segment) then
		_combat_object = EncounterDetails:GetCombat (segment)
		EncounterDetails._segment = segment
	else
		local historico = _detalhes.tabela_historico.tabelas
		for index, combate in ipairs (historico) do 
			if (combate.is_boss and combate.is_boss.index) then
				_G [frame:GetName().."SegmentsDropdown"].MyObject:Select (index)
				EncounterDetails._segment = index
				_combat_object = combate
				break
			end
		end
	end
	
	if (not _combat_object) then
		EncounterDetails:Msg ("no combat found.")
		return
	end
	
	local boss_id
	local map_id
	local boss_info
	
	if (EncounterDetails.debugmode and not _combat_object.is_boss) then
		_combat_object.is_boss = {
			index = 1, 
			name = "Immerseus",
			zone = "Siege of Orggrimar", 
			mapid = 1136, 
			encounter = "Immerseus"
		}
	end
	
	if (not _combat_object.is_boss) then
		for _, combat in _ipairs (EncounterDetails:GetCombatSegments()) do 
			if (combat.is_boss and EncounterDetails:GetBossDetails (combat.is_boss.mapid, combat.is_boss.index)) then
				_combat_object = combat
				break
			end
		end
		if (not _combat_object.is_boss) then
			if (EncounterDetails.LastSegmentShown) then
				_combat_object = EncounterDetails.LastSegmentShown
			else
				return
			end
		end
	end
	
	--> the segment is a boss
	
	boss_id = _combat_object.is_boss.index
	map_id = _combat_object.is_boss.mapid
	boss_info = _detalhes:GetBossDetails (_combat_object.is_boss.mapid, _combat_object.is_boss.index)
	
	if (EncounterDetailsFrame.ShowType == "graph") then
		EncounterDetails:BuildDpsGraphic()
		
	elseif (EncounterDetailsFrame.ShowType == "spellsauras") then
		--refresh spells and auras
		local actor = EncounterDetails.build_actor_menu() [1]
		actor = actor and actor.value
		if (actor) then
			_G [EncounterDetailsFrame:GetName() .. "EnemyActorSpellsDropdown"].MyObject:Select (actor)
			EncounterDetails.update_enemy_spells (actor)
		end
		EncounterDetails.update_enemy_spells()
	end

	EncounterDetails.LastSegmentShown = _combat_object
	
-------------- set boss name and zone name --------------
	EncounterDetailsFrame.boss_name:SetText (_combat_object.is_boss.encounter)
	EncounterDetailsFrame.raid_name:SetText (_combat_object.is_boss.zone)

-------------- set portrait and background image --------------	
	local L, R, T, B, Texture = EncounterDetails:GetBossIcon (_combat_object.is_boss.mapid, _combat_object.is_boss.index)
	if (L) then
		EncounterDetailsFrame.boss_icone:SetTexture (Texture)
		EncounterDetailsFrame.boss_icone:SetTexCoord (L, R, T, B)
	else
		EncounterDetailsFrame.boss_icone:SetTexture ([[Interface\CHARACTERFRAME\TempPortrait]])
		EncounterDetailsFrame.boss_icone:SetTexCoord (0, 1, 0, 1)
	end
	
	local file, L, R, T, B = EncounterDetails:GetRaidBackground (_combat_object.is_boss.mapid)
	if (file) then
		EncounterDetailsFrame.raidbackground:SetTexture (file)
		EncounterDetailsFrame.raidbackground:SetTexCoord (L, R, T, B)
	else
		EncounterDetailsFrame.raidbackground:SetTexture ([[Interface\Glues\LOADINGSCREENS\LoadScreenDungeon]])
		EncounterDetailsFrame.raidbackground:SetTexCoord (0, 1, 120/512, 408/512)
	end
	
-------------- set totals on down frame --------------
--[[ data mine:
	_combat_object ["totals_grupo"] hold the total [1] damage // [2] heal // [3] [energy_name] energies // [4] [misc_name] miscs --]]

	--> Container Overall Damage Taken
		--[[ data mine:
			combat tables have 4 containers [1] damage [2] heal [3] energy [4] misc each container have 2 tables: ._NameIndexTable and ._ActorTable --]]
		local DamageContainer = _combat_object [class_type_damage]
		
		local damage_taken = _detalhes.atributo_damage:RefreshWindow ({}, _combat_object, _, { key = "damage_taken", modo = _detalhes.modos.group })
		
		local container = frame.overall_damagetaken.gump
		
		local quantidade = 0
		local dano_do_primeiro = 0
		
		for index, jogador in _ipairs (DamageContainer._ActorTable) do
			--> ta em ordem de quem tomou mais dano.
			
			if (not jogador.grupo) then --> só aparecer nego da raid
				break
			end
			
			if (jogador.classe and jogador.classe ~= "UNGROUPPLAYER" and jogador.classe ~= "UNKNOW") then
				local barra = container.barras [index]
				if (not barra) then
					barra = EncounterDetails:CreateRow (index, container)
					_detalhes:SetFontSize (barra.texto_esquerdo, 9)
					_detalhes:SetFontSize (barra.texto_direita, 9)
					_detalhes:SetFontFace (barra.texto_esquerdo, "Arial Narrow")
					barra.TTT = "damage_taken" -- tool tip type --> damage taken
					barra.report_text = Loc ["STRING_PLUGIN_NAME"].."! "..Loc ["STRING_DAMAGE_TAKEN_REPORT"] 
				end

				if (jogador.nome:find ("-")) then
					barra.texto_esquerdo:SetText (jogador.nome:gsub (("-.*"), ""))
				else
					barra.texto_esquerdo:SetText (jogador.nome)
				end
				
				barra.texto_direita:SetText (_detalhes:comma_value (jogador.damage_taken))
				
				_detalhes:name_space (barra)
				
				barra.jogador = jogador
				
				barra.textura:SetStatusBarColor (_unpack (_detalhes.class_colors [jogador.classe]))
				
				if (index == 1)  then
					barra.textura:SetValue (100)
					dano_do_primeiro = jogador.damage_taken
				else
					barra.textura:SetValue (jogador.damage_taken/dano_do_primeiro *100)
				end
				
				barra.icone:SetTexture ("Interface\\AddOns\\Details\\images\\classes_small")
				if (EncounterDetails.class_coords [jogador.classe]) then
					barra.icone:SetTexCoord (_unpack (EncounterDetails.class_coords [jogador.classe]))
				end
				
				barra:Show()
				quantidade = quantidade + 1
			end
		end
		
		EncounterDetails:JB_AtualizaContainer (container, quantidade)
		
		if (quantidade < #container.barras) then
			for i = quantidade+1, #container.barras, 1 do 
			
				if (barra) then
					barra:Hide()
				end
			end
		end
		
	--> Fim do container Overall Damage Taken
	
	--> Container Overall Habilidades Inimigas
		local habilidades_poll = {}
		
		--> pega as magias contínuas presentes em todas as fases
		if (boss_info and boss_info.continuo) then
			for index, spellid in _ipairs (boss_info.continuo) do 
				habilidades_poll [spellid] = true
			end
		end

		--> pega as habilidades que pertence especificamente a cada fase
		if (boss_info and boss_info.phases) then
			for fase_id, fase in _ipairs (boss_info.phases) do 
				if (fase.spells) then
					for index, spellid in _ipairs (fase.spells) do 
						habilidades_poll [spellid] = true
					end
				end
			end
		end
		
		local habilidades_usadas = {}
		local have_pool = false
		for spellid, _ in _pairs (habilidades_poll) do 
			have_pool = true
			break
		end
		
		for index, jogador in _ipairs (DamageContainer._ActorTable) do
		
			--> get all spells from neutral and hostile npcs
			if (	
				_bit_band (jogador.flag_original, 0x00000060) ~= 0 and --is neutral or hostile
				(not jogador.owner or (_bit_band (jogador.owner.flag_original, 0x00000060) ~= 0 and not jogador.owner.grupo and _bit_band (jogador.owner.flag_original, 0x00000400) == 0)) and --isn't a pet or the owner isn't a player
				not jogador.grupo and
				_bit_band (jogador.flag_original, 0x00000400) == 0
			) then
		
				local habilidades = jogador.spells._ActorTable
				
				for id, habilidade in _pairs (habilidades) do
					--if (habilidades_poll [id]) then
						--> esse jogador usou uma habilidade do boss
						local esta_habilidade = habilidades_usadas [id] --> tabela não numerica, pq diferentes monstros podem castar a mesma magia
						if (not esta_habilidade) then 
							esta_habilidade = {0, {}, {}, id} --> [1] total dano causado [2] jogadores que foram alvos [3] jogadores que castaram essa magia [4] ID da magia
							habilidades_usadas [id] = esta_habilidade
						end
						
						--> adiciona ao [1] total de dano que esta habilidade causou
						esta_habilidade[1] = esta_habilidade[1] + habilidade.total
						
						 --> adiciona ao [3] total do jogador que castou
						if (not esta_habilidade[3][jogador.nome]) then
							esta_habilidade[3][jogador.nome] = 0
						end
						
						esta_habilidade[3][jogador.nome] = esta_habilidade[3][jogador.nome] + habilidade.total
						
						--> pega os alvos e adiciona ao [2]
						local alvos = habilidade.targets
						for target_name, amount in _pairs (alvos) do 
						
							--> ele tem o nome do jogador, vamos ver se este alvo é realmente um jogador verificando na tabela do combate
							local tabela_dano_do_jogador = DamageContainer._ActorTable [DamageContainer._NameIndexTable [target_name]]
							if (tabela_dano_do_jogador and tabela_dano_do_jogador.grupo) then
								if (not esta_habilidade[2] [target_name]) then 
									esta_habilidade[2] [target_name] = {0, tabela_dano_do_jogador.classe}
								end
								esta_habilidade[2] [target_name] [1] = esta_habilidade[2] [target_name] [1] + amount
							end
						end
					--end
				end
			
			elseif (have_pool) then
				--> check if the spell id is in the spell poll.
				local habilidades = jogador.spells._ActorTable
				
				for id, habilidade in _pairs (habilidades) do
					if (habilidades_poll [id]) then
						--> esse jogador usou uma habilidade do boss
						local esta_habilidade = habilidades_usadas [id] --> tabela não numerica, pq diferentes monstros podem castar a mesma magia
						if (not esta_habilidade) then 
							esta_habilidade = {0, {}, {}, id} --> [1] total dano causado [2] jogadores que foram alvos [3] jogadores que castaram essa magia [4] ID da magia
							habilidades_usadas [id] = esta_habilidade
						end
						
						--> adiciona ao [1] total de dano que esta habilidade causou
						esta_habilidade[1] = esta_habilidade[1] + habilidade.total
						
						 --> adiciona ao [3] total do jogador que castou
						if (not esta_habilidade[3][jogador.nome]) then
							esta_habilidade[3][jogador.nome] = 0
						end
						
						esta_habilidade[3][jogador.nome] = esta_habilidade[3][jogador.nome] + habilidade.total
						
						--> pega os alvos e adiciona ao [2]
						local alvos = habilidade.targets
						for target_name, amount in _pairs (alvos) do 
						
							--> ele tem o nome do jogador, vamos ver se este alvo é realmente um jogador verificando na tabela do combate
							local tabela_dano_do_jogador = DamageContainer._ActorTable [DamageContainer._NameIndexTable [target_name]]
							if (tabela_dano_do_jogador and tabela_dano_do_jogador.grupo) then
								if (not esta_habilidade[2] [target_name]) then 
									esta_habilidade[2] [target_name] = {0, tabela_dano_do_jogador.classe}
								end
								esta_habilidade[2] [target_name] [1] = esta_habilidade[2] [target_name] [1] + amount
							end
						end
					end
				end
			end
		end
		
		--> por em ordem
		local tabela_em_ordem = {}
		for id, tabela in _pairs (habilidades_usadas) do 
			tabela_em_ordem [#tabela_em_ordem+1] = tabela
		end
		
		_table_sort (tabela_em_ordem, _detalhes.Sort1)

		container = frame.overall_habilidades.gump
		quantidade = 0
		dano_do_primeiro = 0
		
		--> mostra o resultado nas barras
		for index, habilidade in _ipairs (tabela_em_ordem) do
			--> ta em ordem das habilidades que deram mais dano
			
			if (habilidade[1] > 0) then
			
				local barra = container.barras [index]
				if (not barra) then
					barra = EncounterDetails:CreateRow (index, container)
					barra.TTT = "habilidades_inimigas" -- tool tip type --enemy abilities
					barra.report_text = Loc ["STRING_PLUGIN_NAME"].."! " .. Loc ["STRING_ABILITY_DAMAGE"]
					_detalhes:SetFontSize (barra.texto_esquerdo, 9)
					_detalhes:SetFontSize (barra.texto_direita, 9)
					_detalhes:SetFontFace (barra.texto_esquerdo, "Arial Narrow")
					barra.t:SetVertexColor (1, .8, .8, .8)
				end
				
				local nome_magia, _, icone_magia = _GetSpellInfo (habilidade[4])

				barra.texto_esquerdo:SetText (nome_magia)
				barra.texto_direita:SetText (_detalhes:comma_value (habilidade[1]))
				
				_detalhes:name_space (barra)
				
				barra.jogador = habilidade --> barra.jogador agora tem a tabela com --> [1] total dano causado [2] jogadores que foram alvos [3] jogadores que castaram essa magia [4] ID da magia
				
				--barra.textura:SetStatusBarColor (_unpack (_detalhes.class_colors [jogador.classe]))
				--barra.textura:SetStatusBarColor (1, 1, 1, 1) --> a cor pode ser a spell school da magia
				
				if (index == 1)  then
					barra.textura:SetValue (100)
					dano_do_primeiro = habilidade[1]
				else
					barra.textura:SetValue (habilidade[1]/dano_do_primeiro *100)
				end
				
				barra.icone:SetTexture (icone_magia)
				--barra.icone:SetTexCoord (_unpack (EncounterDetails.class_coords [jogador.classe]))
				
				barra:Show()
				quantidade = quantidade + 1
			
			end
		end
		
		--print (quantidade)
		EncounterDetails:JB_AtualizaContainer (container, quantidade)
		
		if (quantidade < #container.barras) then
			for i = quantidade+1, #container.barras, 1 do 
				container.barras [i]:Hide()
			end
		end
	
	--> Fim do container Over Habilidades Inimigas
	
	--> Identificar os ADDs da luta:
	
		--> declara a pool onde serão armazenados os adds existentas na luta
		local adds_pool = {}
	
		--> pega as habilidades que pertence especificamente a cada fase
		
		if (boss_info and boss_info.phases) then
			for fase_id, fase in _ipairs (boss_info.phases) do 
				if (fase.adds) then
					for index, addId in _ipairs (fase.adds) do 
						adds_pool [addId] = true
					end
				end
			end
		end
		
		--> agora ja tenho a lista de todos os adds da luta
		-- vasculhar o container de dano e achar os adds:
		-- ~add
		
		local adds = {}
		
		for index, jogador in _ipairs (DamageContainer._ActorTable) do
		
			--> só estou interessado nos adds, conferir pelo nome
			if (adds_pool [_detalhes:GetNpcIdFromGuid (jogador.serial)] or (
				jogador.flag_original and
				bit.band (jogador.flag_original, 0x00000060) ~= 0 and
				(not jogador.owner or (_bit_band (jogador.owner.flag_original, 0x00000060) ~= 0 and not jogador.owner.grupo and _bit_band (jogador.owner.flag_original, 0x00000400) == 0)) and --isn't a pet or the owner isn't a player
				not jogador.grupo and
				_bit_band (jogador.flag_original, 0x00000400) == 0
			)) then --> é um inimigo ou neutro
				
				local nome = jogador.nome
				local tabela = {nome = nome, total = 0, dano_em = {}, dano_em_total = 0, damage_from = {}, damage_from_total = 0}
			
				--> total de dano que ele causou
				tabela.total = jogador.total
				
				--> em quem ele deu dano
				for target_name, amount in _pairs (jogador.targets) do
					local este_jogador = _combat_object (1, target_name)
					if (este_jogador) then
						if (este_jogador.classe ~= "PET" and este_jogador.classe ~= "UNGROUPPLAYER" and este_jogador.classe ~= "UNKNOW") then
							tabela.dano_em [#tabela.dano_em +1] = {target_name, amount, este_jogador.classe}
							tabela.dano_em_total = tabela.dano_em_total + amount
						end
					else
						--print ("actor not found: " ..alvo.nome )
					end
				end
				_table_sort (tabela.dano_em, _detalhes.Sort2)
				
				--> quem deu dano nele
				for agressor, _ in _pairs (jogador.damage_from) do 
					--local este_jogador = DamageContainer._ActorTable [DamageContainer._NameIndexTable [agressor]]
					local este_jogador = _combat_object (1, agressor)
					if (este_jogador and este_jogador:IsPlayer()) then 
						for target_name, amount in _pairs (este_jogador.targets) do
							if (target_name == nome) then 
								tabela.damage_from [#tabela.damage_from+1] = {agressor, amount, este_jogador.classe}
								tabela.damage_from_total = tabela.damage_from_total + amount
							end
						end
					end
				end
				
				_table_sort (tabela.damage_from, sort_damage_from)

				tinsert (adds, tabela)
				
			end
			
		end
		
		--> montou a tabela, agora precisa mostrar no painel

		local function _DanoFeito (self)
		
			self.textura:SetBlendMode ("ADD")
		
			local barra = self:GetParent()
			local tabela = barra.jogador
			local dano_em = tabela.dano_em
			
			GameTooltip:SetOwner (barra, "ANCHOR_TOPRIGHT")
			
			_GameTooltip:ClearLines()
			_GameTooltip:AddLine (barra.texto_esquerdo:GetText().." ".. Loc ["STRING_INFLICTED"]) 
			
			local dano_em_total = tabela.dano_em_total
			for _, esta_tabela in _pairs (dano_em) do 
				local coords = EncounterDetails.class_coords [esta_tabela[3]]
				GameTooltip:AddDoubleLine ("|TInterface\\AddOns\\Details\\images\\classes_small:14:14:0:0:128:128:"..(coords[1]*128)..":"..(coords[2]*128)..":"..(coords[3]*128)..":"..(coords[4]*128).."|t "..esta_tabela[1]..": ", _detalhes:comma_value(esta_tabela[2]).." (".. _cstr ("%.1f", esta_tabela[2]/dano_em_total*100) .."%)", 1, 1, 1, 1, 1, 1)
			end
			
			GameTooltip:AddLine (" ")
			GameTooltip:AddLine ("CLICK to Report")
			
			GameTooltip:Show()	
		end

		local function _DanoRecebido (self)
		
			self.textura:SetBlendMode ("ADD")
		
			local barra = self:GetParent()
			local tabela = barra.jogador
			local damage_from = tabela.damage_from
			
			GameTooltip:SetOwner (barra, "ANCHOR_TOPRIGHT")
			
			GameTooltip:ClearLines()
			GameTooltip:AddLine (barra.texto_esquerdo:GetText().." "..Loc ["STRING_DAMAGE_TAKEN"])
			
			local damage_from_total = tabela.damage_from_total

			for _, esta_tabela in _pairs (damage_from) do 

				local coords = EncounterDetails.class_coords [esta_tabela[3]]
				if (coords) then
					GameTooltip:AddDoubleLine ("|TInterface\\AddOns\\Details\\images\\classes_small:14:14:0:0:128:128:"..(coords[1]*128)..":"..(coords[2]*128)..":"..(coords[3]*128)..":"..(coords[4]*128).."|t "..esta_tabela[1]..": ", _detalhes:comma_value(esta_tabela[2]).." (".. _cstr ("%.1f", esta_tabela[2]/damage_from_total*100) .."%)", 1, 1, 1, 1, 1, 1)
				else
					GameTooltip:AddDoubleLine (esta_tabela[1],  _detalhes:comma_value(esta_tabela[2]).." (".. _cstr ("%.1f", esta_tabela[2]/damage_from_total*100) .."%)", 1, 1, 1, 1, 1, 1)
				end
			end
			
			GameTooltip:AddLine (" ")
			GameTooltip:AddLine ("CLICK to Report")
			
			GameTooltip:Show()	
		end
		
		local function _OnHide (self)
			GameTooltip:Hide()
			self.textura:SetBlendMode ("BLEND")
		end
		
		local y = 10
		local frame_adds = EncounterDetailsFrame.overall_adds
		container = frame_adds.gump
		local index = 1
		quantidade = 0
		
		
		
		table.sort (adds, sort_by_name)
		
		for index, esta_tabela in _ipairs (adds) do 
		
				local addName = esta_tabela.nome
		
				local barra = container.barras [index]
				if (not barra) then
					barra = EncounterDetails:CreateRow (index, container, -0)
					barra:SetBackdrop (backdrop_bar_onleave)
					barra:SetBackdropColor (.0, .0, .0, 0.3)
					
					barra:SetWidth (155)
					
					barra._no_report = true

					--> criar 2 botão: um para o dano que add deu e outro para o dano que o add tomou
					local add_damage_taken = _CreateFrame ("Button", nil, barra)
					add_damage_taken.report_text = "Details! "
					add_damage_taken.barra = barra
					add_damage_taken:SetWidth (16)
					add_damage_taken:SetHeight (16)
					add_damage_taken:EnableMouse (true)
					add_damage_taken:SetResizable (false)
					add_damage_taken:SetPoint ("left", barra, "left", 0, 0)
					
					add_damage_taken:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16})
					add_damage_taken:SetBackdropColor (.0, .5, .0, 0.5)
					
					add_damage_taken:SetScript ("OnEnter", _DanoRecebido)
					add_damage_taken:SetScript ("OnLeave", _OnHide)
					add_damage_taken:SetScript ("OnClick", EncounterDetails.BossInfoRowClick)
					
					add_damage_taken.textura = add_damage_taken:CreateTexture (nil, "overlay")
					add_damage_taken.textura:SetTexture ("Interface\\Buttons\\UI-MicroStream-Green")
					add_damage_taken.textura:SetWidth (16)
					add_damage_taken.textura:SetHeight (16)
					add_damage_taken.textura:SetTexCoord (0, 1, 1, 0)
					add_damage_taken.textura:SetPoint ("center", add_damage_taken, "center")
					
					local add_damage_done = _CreateFrame ("Button", nil, barra)
					add_damage_done.report_text = "Details! "
					add_damage_done.barra = barra
					add_damage_done:SetWidth (16)
					add_damage_done:SetHeight (16)
					add_damage_done:EnableMouse (true)
					add_damage_done:SetResizable (false)
					add_damage_done:SetPoint ("left", add_damage_taken, "right", 0, 0)
					
					add_damage_done:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16})
					add_damage_done:SetBackdropColor (.5, .0, .0, 0.5)
					
					add_damage_done.textura = add_damage_done:CreateTexture (nil, "overlay")
					add_damage_done.textura:SetTexture ("Interface\\Buttons\\UI-MicroStream-Red")
					add_damage_done.textura:SetWidth (16)
					add_damage_done.textura:SetHeight (16)
					add_damage_done.textura:SetPoint ("topleft", add_damage_done, "topleft")
					
					add_damage_done:SetScript ("OnEnter", _DanoFeito)
					add_damage_done:SetScript ("OnLeave", _OnHide)
					add_damage_done:SetScript ("OnClick", EncounterDetails.BossInfoRowClick)
					
					barra.texto_esquerdo:SetPoint ("left", add_damage_done, "right")
					barra.textura:SetStatusBarTexture (nil)
					_detalhes:SetFontSize (barra.texto_esquerdo, 9)
					_detalhes:SetFontSize (barra.texto_direita, 9)
					
					--barra.TTT = "habilidades_inimigas" -- tool tip type
				end

				barra.texto_esquerdo:SetText (addName)
				barra.texto_direita:SetText (_detalhes:ToK (esta_tabela.total))
				barra.texto_esquerdo:SetSize (barra:GetWidth() - barra.texto_direita:GetStringWidth() - 34, 15)
				
				barra.jogador = esta_tabela --> barra.jogador agora tem a tabela com --> [1] total dano causado [2] jogadores que foram alvos [3] jogadores que castaram essa magia [4] ID da magia
				
				--barra.textura:SetStatusBarColor (_unpack (_detalhes.class_colors [jogador.classe]))
				barra.textura:SetStatusBarColor (1, 1, 1, 1) --> a cor pode ser a spell school da magia
				barra.textura:SetValue (100)
				
				barra:Show()
				quantidade = quantidade + 1
				index = index +1
		end
		
		EncounterDetails:JB_AtualizaContainer (container, quantidade, 4)
		
		if (quantidade < #container.barras) then
			for i = quantidade+1, #container.barras, 1 do 
				container.barras [i]:Hide()
			end
		end
		
	--> Fim do container Over ADDS
	
	--> Inicio do Container de Interrupts:
	
		local misc = _combat_object [class_type_misc]
		
		local total_interrompido = _detalhes.atributo_misc:RefreshWindow ({}, _combat_object, _, { key = "interrupt", modo = _detalhes.modos.group })
		
		local frame_interrupts = EncounterDetailsFrame.overall_interrupt
		container = frame_interrupts.gump
		
		quantidade = 0
		local interrupt_do_primeiro = 0
		
		local habilidades_interrompidas = {}
		
		for index, jogador in _ipairs (misc._ActorTable) do
			if (not jogador.grupo) then --> só aparecer nego da raid
				break
			end
			
			if (jogador.classe and jogador.classe ~= "UNGROUPPLAYER") then			
				local interrupts = jogador.interrupt				
				if (interrupts and interrupts > 0) then
					local oque_interrompi = jogador.interrompeu_oque
					--> vai ter [spellid] = quantidade
					
					for spellid, amt in _pairs (oque_interrompi) do 
						if (not habilidades_interrompidas [spellid]) then --> se a spell não tiver na pool, cria a tabela dela
							habilidades_interrompidas [spellid] = {{}, 0, spellid} --> tabela com quem interrompeu e o total de vezes que a habilidade foi interrompida
						end
						
						if (not habilidades_interrompidas [spellid] [1] [jogador.nome]) then --> se o jogador não tiver na pool dessa habilidade interrompida, cria um indice pra ele.
							habilidades_interrompidas [spellid] [1] [jogador.nome] = {0, jogador.classe}
						end
						
						habilidades_interrompidas [spellid] [2] = habilidades_interrompidas [spellid] [2] + amt
						habilidades_interrompidas [spellid] [1] [jogador.nome] [1] = habilidades_interrompidas [spellid] [1] [jogador.nome] [1] + amt
					end
				end
			end
		end
		
		--> por em ordem
		tabela_em_ordem = {}
		for spellid, tabela in _pairs (habilidades_interrompidas) do 
			tabela_em_ordem [#tabela_em_ordem+1] = tabela
		end
		_table_sort (tabela_em_ordem, _detalhes.Sort2)

		index = 1
		
		for _, tabela in _ipairs (tabela_em_ordem) do
		
			local barra = container.barras [index]
			if (not barra) then
				barra = EncounterDetails:CreateRow (index, container, 3, 0, -6)
				barra.TTT = "total_interrupt" -- tool tip type
				barra.report_text = "Details! ".. Loc ["STRING_INTERRUPTS_OF"]
				barra:SetBackdrop (backdrop_bar_onleave)
				barra:SetBackdropColor (.0, .0, .0, 0.3)
				barra:SetWidth (155)
			end
			
			local spellid = tabela [3]
			
			local nome_magia, _, icone_magia = _GetSpellInfo (tabela [3])
			local successful = 0
			--> pegar quantas vezes a magia passou com sucesso.
			for _, enemy_actor in _ipairs (DamageContainer._ActorTable) do
				if (enemy_actor.spells._ActorTable [spellid]) then
					local spell = enemy_actor.spells._ActorTable [spellid]
					successful = spell.successful_casted
				end
			end
			
			barra.texto_esquerdo:SetText (nome_magia)
			local total = successful + tabela [2]
			barra.texto_direita:SetText (tabela [2] .. " / ".. total)
			
			_detalhes:name_space (barra)
			
			barra.jogador = tabela
			
			--barra.textura:SetStatusBarColor (_unpack (_detalhes.class_colors [jogador.classe]))
			
			if (index == 1)  then
				barra.textura:SetValue (100)
				dano_do_primeiro = tabela [2]
			else
				barra.textura:SetValue (tabela [2]/dano_do_primeiro *100)
			end
			
			barra.icone:SetTexture (icone_magia)
			--barra.icone:SetTexCoord (_unpack (EncounterDetails.class_coords [jogador.classe]))
			
			barra:Show()
			
			quantidade = quantidade + 1
			index = index + 1 
		end

		EncounterDetails:JB_AtualizaContainer (container, quantidade, 4)
		
		if (quantidade < #container.barras) then
			for i = quantidade+1, #container.barras, 1 do 
				container.barras[i]:Hide()
			end
		end
	
	--> Fim do container dos Interrupts
	
	--> Inicio do Container dos Dispells:
		
		--> force refresh window behavior
		local total_dispelado = _detalhes.atributo_misc:RefreshWindow ({}, _combat_object, _, { key = "dispell", modo = _detalhes.modos.group })
		
		local frame_dispell = EncounterDetailsFrame.overall_dispell
		container = frame_dispell.gump
		
		quantidade = 0
		local dispell_do_primeiro = 0
		
		local habilidades_dispeladas = {}
		
		for index, jogador in _ipairs (misc._ActorTable) do
			if (not jogador.grupo) then --> só aparecer nego da raid
				break
			end

			if (jogador.classe and jogador.classe ~= "UNGROUPPLAYER") then

				local dispells = jogador.dispell
				if (dispells and dispells > 0) then
					local oque_dispelei = jogador.dispell_oque
					--> vai ter [spellid] = quantidade
					
					--print ("dispell: " .. jogador.classe .. " nome: " .. jogador.nome)
					
					for spellid, amt in _pairs (oque_dispelei) do 
						if (not habilidades_dispeladas [spellid]) then --> se a spell não tiver na pool, cria a tabela dela
							habilidades_dispeladas [spellid] = {{}, 0, spellid} --> tabela com quem dispolou e o total de vezes que a habilidade foi dispelada
						end
						
						if (not habilidades_dispeladas [spellid] [1] [jogador.nome]) then --> se o jogador não tiver na pool dessa habilidade interrompida, cria um indice pra ele.
							habilidades_dispeladas [spellid] [1] [jogador.nome] = {0, jogador.classe}
							--print (jogador.nome)
							--print (jogador.classe)
						end
						
						habilidades_dispeladas [spellid] [2] = habilidades_dispeladas [spellid] [2] + amt
						habilidades_dispeladas [spellid] [1] [jogador.nome] [1] = habilidades_dispeladas [spellid] [1] [jogador.nome] [1] + amt
					end
				end
			end
		end
		
		--> por em ordem
		tabela_em_ordem = {}
		for spellid, tabela in _pairs (habilidades_dispeladas) do 
			tabela_em_ordem [#tabela_em_ordem+1] = tabela
		end
		_table_sort (tabela_em_ordem, _detalhes.Sort2)

		index = 1
		
		for _, tabela in _ipairs (tabela_em_ordem) do
		
			local barra = container.barras [index]
			if (not barra) then
				barra = EncounterDetails:CreateRow (index, container, 3, 3, -6)
				barra.TTT = "dispell" -- tool tip type
				barra.report_text = "Details! ".. Loc ["STRING_DISPELLS_OF"]
				barra:SetBackdrop (backdrop_bar_onleave)
				barra:SetBackdropColor (.0, .0, .0, 0.3)
				barra:SetWidth (160)
			end
			
			local nome_magia, _, icone_magia = _GetSpellInfo (tabela [3])
			
			barra.texto_esquerdo:SetText (nome_magia)
			barra.texto_direita:SetText (tabela [2])
			
			_detalhes:name_space (barra)
			
			barra.jogador = tabela
			
			--barra.textura:SetStatusBarColor (_unpack (_detalhes.class_colors [jogador.classe]))
			
			if (index == 1)  then
				barra.textura:SetValue (100)
				dano_do_primeiro = tabela [2]
			else
				barra.textura:SetValue (tabela [2]/dano_do_primeiro *100)
			end
			
			barra.icone:SetTexture (icone_magia)
			--barra.icone:SetTexCoord (_unpack (EncounterDetails.class_coords [jogador.classe]))
			
			barra:Show()
			
			quantidade = quantidade + 1
			index = index + 1 
		end
		
		EncounterDetails:JB_AtualizaContainer (container, quantidade, 4)
		
		if (quantidade < #container.barras) then
			for i = quantidade+1, #container.barras, 1 do 
				container.barras [i]:Hide()
			end
		end
	
	--> Fim do container dos Dispells
	
	--> Inicio do Container das Mortes:
		local frame_mortes = EncounterDetailsFrame.overall_dead
		container = frame_mortes.gump
		
		quantidade = 0
	
		-- boss_info.spells_info o erro de lua do boss é a habilidade dele que não foi declarada ainda
	
		local mortes = _combat_object.last_events_tables
		local habilidades_info = boss_info and boss_info.spell_mechanics or {} --barra.extra pega esse cara aqui --> então esse erro é das habilidades que não tao
	
		for index, tabela in _ipairs (mortes) do
			--> {esta_morte, time, este_jogador.nome, este_jogador.classe, _UnitHealthMax (alvo_name), minutos.."m "..segundos.."s",  ["dead"] = true}
			local barra = container.barras [index]
			if (not barra) then
				barra = EncounterDetails:CreateRow (index, container, 3, 0, 1)
				barra.TTT = "morte" -- tool tip type
				barra.report_text = "Details! " .. Loc ["STRING_DEAD_LOG"]
				_detalhes:SetFontSize (barra.texto_esquerdo, 9)
				_detalhes:SetFontSize (barra.texto_direita, 9)
				_detalhes:SetFontFace (barra.texto_esquerdo, "Arial Narrow")
				barra:SetWidth (169)
			end
			
			if (tabela [3]:find ("-")) then
				barra.texto_esquerdo:SetText (index..". "..tabela [3]:gsub (("-.*"), ""))
			else
				barra.texto_esquerdo:SetText (index..". "..tabela [3])
			end

			barra.texto_direita:SetText (tabela [6])
			
			_detalhes:name_space (barra)
			
			barra.jogador = tabela
			barra.extra = habilidades_info
			
			barra.textura:SetStatusBarColor (_unpack (_detalhes.class_colors [tabela [4]]))
			barra.textura:SetValue (100)
			
			barra.icone:SetTexture ("Interface\\AddOns\\Details\\images\\classes_small")
			barra.icone:SetTexCoord (_unpack (EncounterDetails.class_coords [tabela [4]]))
			
			barra:Show()
			
			quantidade = quantidade + 1
		
		end
		
		EncounterDetails:JB_AtualizaContainer (container, quantidade, 4)
		
		if (quantidade < #container.barras) then
			for i = quantidade+1, #container.barras, 1 do 
				container.barras [i]:Hide()
			end
		end
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
local CLEvents = function (self, event, time, token, hidding, who_serial, who_name, who_flags, who_flags2, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, school, aura_type)
	if (events_to_track [token] and _bit_band (who_flags or 0x0, 0x00000060) ~= 0) then
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

function EncounterDetails:OnEvent (_, event, ...)

	if (event == "ENCOUNTER_START") then
		--> tracks if a enemy spell is instant cast.
		EncounterDetails.CLEvents:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
		
	elseif (event == "ENCOUNTER_END") then
		EncounterDetails.CLEvents:UnregisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
	
	elseif (event == "ADDON_LOADED") then
		local AddonName = select (1, ...)
		if (AddonName == "Details_EncounterDetails") then
			
			if (_G._detalhes and _G._detalhes:InstallOkey()) then
				
				--> create widgets
				CreatePluginFrames (data)

				local PLUGIN_MINIMAL_DETAILS_VERSION_REQUIRED = 1
				local PLUGIN_TYPE = "TOOLBAR"
				local PLUGIN_LOCALIZED_NAME = Loc ["STRING_PLUGIN_NAME"]
				local PLUGIN_REAL_NAME = "DETAILS_PLUGIN_ENCOUNTER_DETAILS"
				local PLUGIN_ICON = [[Interface\Scenarios\ScenarioIcon-Boss]]
				local PLUGIN_AUTHOR = "Details! Team"
				local PLUGIN_VERSION = "v1.06"
				
				local default_settings = {
					show_icon = 5, --automatic
					hide_on_combat = false, --hide the window when a new combat start
					max_emote_segments = 3,
					opened = 0,
					encounter_timers_dbm = {},
					encounter_timers_bw = {},
					window_scale = 1,
				}

				--> Install
				local install, saveddata, is_enabled = _G._detalhes:InstallPlugin (
					PLUGIN_TYPE,
					PLUGIN_LOCALIZED_NAME,
					PLUGIN_ICON,
					EncounterDetails, 
					PLUGIN_REAL_NAME,
					PLUGIN_MINIMAL_DETAILS_VERSION_REQUIRED, 
					PLUGIN_AUTHOR, 
					PLUGIN_VERSION, 
					default_settings
				)
				
				if (type (install) == "table" and install.error) then
					print (install.error)
				end
--				table.wipe (EncounterDetailsDB.encounter_spells)
				EncounterDetails.charsaved = EncounterDetailsDB or {emotes = {}}
				EncounterDetailsDB = EncounterDetails.charsaved
				
				EncounterDetails.charsaved.encounter_spells = EncounterDetails.charsaved.encounter_spells or {}
				
				EncounterDetails.boss_emotes_table = EncounterDetails.charsaved.emotes
				
				--> build a table on global saved variables
				if (not _detalhes.global_plugin_database ["DETAILS_PLUGIN_ENCOUNTER_DETAILS"]) then
					_detalhes.global_plugin_database ["DETAILS_PLUGIN_ENCOUNTER_DETAILS"] = {encounter_timers_dbm = {}, encounter_timers_bw= {}}
				end
				
				--> Register needed events
				_G._detalhes:RegisterEvent (EncounterDetails, "COMBAT_PLAYER_ENTER")
				_G._detalhes:RegisterEvent (EncounterDetails, "COMBAT_PLAYER_LEAVE")
				_G._detalhes:RegisterEvent (EncounterDetails, "COMBAT_BOSS_FOUND")
				_G._detalhes:RegisterEvent (EncounterDetails, "DETAILS_DATA_RESET")
				
				_G._detalhes:RegisterEvent (EncounterDetails, "GROUP_ONENTER")
				_G._detalhes:RegisterEvent (EncounterDetails, "GROUP_ONLEAVE")
				
				_G._detalhes:RegisterEvent (EncounterDetails, "ZONE_TYPE_CHANGED")
				
				EncounterDetailsFrame:RegisterEvent ("ENCOUNTER_START")
				EncounterDetailsFrame:RegisterEvent ("ENCOUNTER_END")
				EncounterDetails.EnemySpellPool = EncounterDetails.charsaved.encounter_spells
				enemy_spell_pool = EncounterDetails.EnemySpellPool
				EncounterDetails.CLEvents = CreateFrame ("frame", nil, UIParent)
				EncounterDetails.CLEvents:SetScript ("OnEvent", CLEvents)
				EncounterDetails.CLEvents:Hide()
				
				EncounterDetails.BossWhispColors = {
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
		
	end
end
