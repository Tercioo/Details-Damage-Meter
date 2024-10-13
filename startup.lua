
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")
local _
local tocName, Details222 = ...
local detailsFramework = DetailsFramework

--start funtion
function Details222.StartUp.StartMeUp()
	if (Details.AndIWillNeverStop) then
		return
	end
	Details.AndIWillNeverStop = true

	--note: this runs after profile loaded

	--set default time for arena and bg to be the Details! load time in case the client loads mid event
	Details.lastArenaStartTime = GetTime()
	Details.lastBattlegroundStartTime = GetTime()

	--save the time when the addon finished loading
	Details.AddOnStartTime = GetTime()
	function Details.GetStartupTime()
		return Details.AddOnStartTime or GetTime()
	end

	--load custom spells on login
	C_Timer.After(3, function()
		Details:FillUserCustomSpells()
	end)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--row single click, this determines what happen when the user click on a bar

	--single click row function replace
		--damage, dps, damage taken, friendly fire
			Details.row_singleclick_overwrite[1] = {true, true, true, true, Details.atributo_damage.ReportSingleFragsLine, Details.atributo_damage.ReportEnemyDamageTaken, Details.atributo_damage.ReportSingleVoidZoneLine, Details.atributo_damage.ReportSingleDTBSLine}
		--healing, hps, overheal, healing taken
			Details.row_singleclick_overwrite[2] = {true, true, true, true, false, Details.atributo_heal.ReportSingleDamagePreventedLine}
		--mana, rage, energy, runepower
			Details.row_singleclick_overwrite[3] = {true, true, true, true} --missing other resources and alternate power
		--cc breaks, ress, interrupts, dispells, deaths
			Details.row_singleclick_overwrite[4] = {true, true, true, true, Details.atributo_misc.ReportSingleDeadLine, Details.atributo_misc.ReportSingleCooldownLine, Details.atributo_misc.ReportSingleBuffUptimeLine, Details.atributo_misc.ReportSingleDebuffUptimeLine}

		function Details:ReplaceRowSingleClickFunction(attribute, subAttribute, func)
			assert(type(attribute) == "number" and attribute >= 1 and attribute <= 4, "ReplaceRowSingleClickFunction expects a attribute index on #1 argument.")
			assert(type(subAttribute) == "number" and subAttribute >= 1 and subAttribute <= 10, "ReplaceRowSingleClickFunction expects a sub attribute index on #2 argument.")
			assert(type(func) == "function", "ReplaceRowSingleClickFunction expects a function on #3 argument.")

				Details.row_singleclick_overwrite[attribute][subAttribute] = func
			return true
		end

		Details.click_to_report_color = {1, 0.8, 0, 1}

		--death tooltip function, exposed for 3rd party customization
		--called when the mouse hover over a player line when displaying deaths
		--the function called receives 4 parameters: instanceObject, lineFrame, combatObject, deathTable
		--@instance: the details! object of the window showing the deaths
		--@lineFrame: the frame to setpoint your frame
		--@combatObject: the combat itself
		--@deathTable: a table containing all the information about the player's death
		Details.ShowDeathTooltipFunction = Details.ShowDeathTooltip

		if (C_CVar) then
			if (not InCombatLockdown() and DetailsFramework.IsDragonflightAndBeyond()) then --disable for releases
			--C_CVar.SetCVar("cameraDistanceMaxZoomFactor", 2.6)
			end
		end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--initialize

	--make an encounter journal cache. the cache will load before this if any function tries to get information from the cache
	C_Timer.After(3, Details222.EJCache.CreateEncounterJournalDump)

	--plugin container
	Details:CreatePluginWindowContainer()
	Details:InitializeForge() --to install into the container plugin
	Details:InitializeRaidHistoryWindow()
	--Details:InitializeOptionsWindow() --debug, uncoment to open options window on startup

	C_Timer.After(2, function()
		Details:InitializeAuraCreationWindow()
	end)

	Details:InitializeCustomDisplayWindow()
	Details:InitializeAPIWindow()
	Details:InitializeRunCodeWindow()
	Details:InitializePlaterIntegrationWindow()
	Details:InitializeMacrosWindow()

	Details222.CreateAllDisplaysFrame()

	Details222.LoadCommentatorFunctions()

	Details222.AuraScan.FindAndIgnoreWorldAuras()

	Details222.Notes.RegisterForOpenRaidNotes()

	if (Details.ocd_tracker.show_options) then
		Details:InitializeCDTrackerWindow()
	else
		--Details:InitializeCDTrackerWindow() --enabled for v11 beta, debug openraid
	end
	--/run Details.ocd_tracker.show_options = true; ReloadUI()
	--custom window
	Details.custom = Details.custom or {}

	--micro button alert
	--"MainMenuBarMicroButton" has been removed on 9.0
	Details.MicroButtonAlert = CreateFrame("frame", "DetailsMicroButtonAlert", UIParent)
	Details.MicroButtonAlert.Text = Details.MicroButtonAlert:CreateFontString(nil, "overlay", "GameFontNormal")
	Details.MicroButtonAlert.Text:SetPoint("center")
	Details.MicroButtonAlert:Hide()

	--actor details window
	Details.BreakdownWindowFrame = Details:CreateBreakdownWindow()
	Details.FadeHandler.Fader(Details.BreakdownWindowFrame, 1)

	--copy and paste window
	Details:CreateCopyPasteWindow()
	Details.CreateCopyPasteWindow = nil

	--start instances
	if (Details:GetNumInstancesAmount() == 0) then
		Details:CreateInstance()
	end
	Details:GetLowerInstanceNumber()

	--start time machine, the time machine controls the activity time of players
	Details222.TimeMachine.Start()

	--update abbreviation shortcut
	Details.atributo_damage:UpdateSelectedToKFunction()
	Details.atributo_heal:UpdateSelectedToKFunction()
	Details.atributo_energy:UpdateSelectedToKFunction()
	Details.atributo_misc:UpdateSelectedToKFunction()
	Details.atributo_custom:UpdateSelectedToKFunction()

	Details:CheckSwitchOnLogon()

	function Details:ScheduledWindowUpdate(bIsForced)
		if (not bIsForced and Details.in_combat) then
			return
		end
		Details.scheduled_window_update = nil
		local bForceRefresh = true
		Details:RefreshMainWindow(-1, bForceRefresh)
	end

	function Details:ScheduleWindowUpdate(time, bIsForced)
		if (Details.scheduled_window_update) then
			Details.Schedules.Cancel(Details.scheduled_window_update)
			Details.scheduled_window_update = nil
		end
		Details.scheduled_window_update = Details.Schedules.NewTimer(time or 1, Details.ScheduledWindowUpdate, Details, bIsForced)
	end

	--do the first refresh here, not waiting for the regular refresh schedule to kick in
	local bForceRefresh = true
	Details:RefreshMainWindow(-1, bForceRefresh)
	Details:RefreshUpdater()

	for instanceId = 1, Details:GetNumInstances() do
		local instance = Details:GetInstance(instanceId)
		if (instance:IsEnabled()) then
			Details.Schedules.NewTimer(1, Details.RefreshBars, Details, instance)
			Details.Schedules.NewTimer(1, Details.InstanceReset, Details, instance)
			Details.Schedules.NewTimer(1, Details.InstanceRefreshRows, Details, instance)
		end
	end

	function Details:RefreshAfterStartup()
		--repair nicknames as nicknames aren't saved within the actor when leaving the game
		if (not Details.ignore_nicktag) then
			local currentCombat = Details:GetCurrentCombat()
			local containerDamage = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
			for _, actorObject in containerDamage:ListActors() do
				--get the actor nickname
				local nickname = Details:GetNickname(actorObject:Name(), false, true)
				if (nickname and type(nickname) == "string" and nickname:len() >= 2) then
					actorObject:SetDisplayName(nickname)
				end
			end
		end

		local refreshAllInstances = -1
		local forceRefresh = true
		Details:RefreshMainWindow(refreshAllInstances, forceRefresh)
		local lowerInstanceId = Details:GetLowerInstanceNumber()

		for id = 1, Details:GetNumInstances() do
			local instance = Details:GetInstance(id)
			if (instance:IsEnabled()) then
				if (instance.modo == 3 and Details.auto_change_to_standard) then --everything
					instance.LastModo = 2 --standard
					instance.modo = 2 --standard
				end

				--refresh wallpaper
				if (instance.wallpaper.enabled) then
					instance:InstanceWallpaper(true)
				else
					instance:InstanceWallpaper(false)
				end

				--refresh desaturated icons if is lower instance because plugins shall have installed their icons at this point
				if (id == lowerInstanceId) then
					instance:DesaturateMenu()
					instance:SetAutoHideMenu(nil, nil, true)
				end
			end
		end

		--after plugins are loaded and they have registered their icons, reorganize them after the start
		Details.ToolBar:ReorganizeIcons()

		--refresh skin for other windows
		if (lowerInstanceId) then
			for instanceId = lowerInstanceId+1, Details:GetNumInstances() do
				local instance = Details:GetInstance(instanceId)
				if (instance and instance.baseframe and instance.ativa) then
					instance:ChangeSkin()
				end
			end
		end

		Details.RefreshAfterStartup = nil

		--the wallpaper could have been loaded by another addon
		--need to refresh wallpaper a few frames or seconds after the game starts
		function Details:CheckWallpaperAfterStartup()
			if (not Details.profile_loaded) then
				Details.Schedules.NewTimer(5, Details.CheckWallpaperAfterStartup, Details)
			end

			for instanceId = 1, Details.instances_amount do
				local instance = Details:GetInstance(instanceId)
				if (instance and instance:IsEnabled()) then
					if (not instance.wallpaper.enabled) then
						instance:InstanceWallpaper(false)
					end

					instance.do_not_snap = true
					Details.move_janela_func(instance.baseframe, true, instance, true)
					Details.move_janela_func(instance.baseframe, false, instance, true)
					instance.do_not_snap = false
				end
			end

			Details.CheckWallpaperAfterStartup = nil
			Details.profile_loaded = nil
		end
		Details.Schedules.NewTimer(5, Details.CheckWallpaperAfterStartup, Details)
	end

	Details.Schedules.NewTimer(5, Details.RefreshAfterStartup, Details)

	--start garbage collector
	Details222.GarbageCollector.lastCollectTime = 0
	Details222.GarbageCollector.intervalTime = 300
	Details222.GarbageCollector.collectorTimer = Details.Schedules.NewTicker(Details222.GarbageCollector.intervalTime, Details222.GarbageCollector.RestartInternalGarbageCollector)

	--player role
	local UnitGroupRolesAssigned = _G.DetailsFramework.UnitGroupRolesAssigned
	Details.last_assigned_role = UnitGroupRolesAssigned and UnitGroupRolesAssigned("player")

	--load parser capture options
		Details:CaptureRefresh()

	--register parser events
		Details.listener:RegisterEvent("PLAYER_REGEN_DISABLED")
		Details.listener:RegisterEvent("PLAYER_REGEN_ENABLED")
		Details.listener:RegisterEvent("UNIT_PET")

		Details.listener:RegisterEvent("GROUP_ROSTER_UPDATE")
		Details.listener:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")

		Details.listener:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		Details.listener:RegisterEvent("PLAYER_ENTERING_WORLD")

		if (C_EventUtils.IsEventValid("SCENARIO_COMPLETED")) then
			Details.listener:RegisterEvent("SCENARIO_COMPLETED")
		end

		Details.listener:RegisterEvent("ENCOUNTER_START")
		Details.listener:RegisterEvent("ENCOUNTER_END")

		Details.listener:RegisterEvent("START_TIMER")
		Details.listener:RegisterEvent("UNIT_NAME_UPDATE")

		Details.listener:RegisterEvent("PLAYER_ROLES_ASSIGNED")
		Details.listener:RegisterEvent("ROLE_CHANGED_INFORM")

		Details.listener:RegisterEvent("UNIT_FACTION")

		Details.listener:RegisterEvent("PLAYER_TARGET_CHANGED")

		if (not DetailsFramework.IsTimewalkWoW()) then
			Details.listener:RegisterEvent("PET_BATTLE_OPENING_START")
			Details.listener:RegisterEvent("PET_BATTLE_CLOSE")
			Details.listener:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
			Details.listener:RegisterEvent("PLAYER_TALENT_UPDATE")
			Details.listener:RegisterEvent("CHALLENGE_MODE_START")
			--Details.listener:RegisterEvent("CHALLENGE_MODE_END") --doesn't exists ingame (only at cleu)
			Details.listener:RegisterEvent("CHALLENGE_MODE_COMPLETED")
			Details.listener:RegisterEvent("WORLD_STATE_TIMER_START")

		end

		Details222.parser_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	--update is in group
	Details.details_users = {}
	Details.in_group = IsInGroup() or IsInRaid()

	--done
	Details.initializing = nil

	--scan pets
	Details:SchedulePetUpdate(1)

	--send messages gathered on initialization, these messages contain warnings and errors
	Details.Schedules.NewTimer(10, Details.ShowDelayMsg, Details)

	--send instance open event for each instance opened
	for id, instancia in Details:ListInstances() do
		if (instancia.ativa) then
			Details:SendEvent("DETAILS_INSTANCE_OPEN", nil, instancia)
		end
	end

	--send details startup done event, this signal that details is ready to work
	function Details:AnnounceStartup()
		Details:SendEvent("DETAILS_STARTED", "SEND_TO_ALL")

		if (Details.in_group) then
			Details:SendEvent("GROUP_ONENTER")
		else
			Details:SendEvent("GROUP_ONLEAVE")
		end

		Details.parser_functions:ZONE_CHANGED_NEW_AREA()
		Details.AnnounceStartup = nil
	end

	Details.Schedules.NewTimer(4, Details.AnnounceStartup, Details)

	if (Details.failed_to_load) then
		Details.failed_to_load:Cancel()
		Details.failed_to_load = nil
	end

	--display the version right after the startup, this will fade out after a few seconds
	function Details:AnnounceVersion()
		for index, instancia in Details:ListInstances() do
			if (instancia.ativa) then
				Details.FadeHandler.Fader(instancia._version, "in", 0.1)
			end
		end
	end

	--check version
	Details:CheckVersion(true)

	--restore cooltip anchor position, this is for the custom anchor in the screen set in the tooltip options
	DetailsTooltipAnchor:Restore()

	--check is this is the first run ever
	if (Details.is_first_run) then
		if (#Details.custom == 0) then
			Details:AddDefaultCustomDisplays()
		end
		Details:FillUserCustomSpells()

		if (C_CVar) then
			if (not InCombatLockdown() and DetailsFramework.IsDragonflightAndBeyond()) then
				C_CVar.SetCVar("cameraDistanceMaxZoomFactor", 2.6)
			end
		end
	end

	--check is this is the first run of this version
	if (Details.is_version_first_run) then
		if (Details.build_counter == 13096) then
			Details.mythic_plus.autoclose_time = 90
		end

		local lowerInstanceId = Details:GetLowerInstanceNumber()
		if (lowerInstanceId) then
			lowerInstanceId = Details:GetInstance(lowerInstanceId)
			if (lowerInstanceId) then
				--check if there's changes in the size of the news string
				if (Details.last_changelog_size ~= #Loc["STRING_VERSION_LOG"]) then
					Details.last_changelog_size = #Loc["STRING_VERSION_LOG"]
					if (Details.auto_open_news_window) then
						C_Timer.After(5, function()
							Details.OpenNewsWindow()
						end)
					end

					if (lowerInstanceId) then
						C_Timer.After(10, function()
							if (lowerInstanceId:IsEnabled()) then
								lowerInstanceId:InstanceAlert(Loc ["STRING_VERSION_UPDATE"], {[[Interface\GossipFrame\AvailableQuestIcon]], 16, 16, false}, 60, {Details.OpenNewsWindow}, true)
								Details:Msg("A new version has been installed: /details news") --localize-me
							end
						end)
					end
				end
			end
		end

		Details:FillUserCustomSpells()
		Details:AddDefaultCustomDisplays()
	end

	if (C_AddOns) then
		hooksecurefunc(C_AddOns, "LoadAddOn", function(addOnName)
			if (addOnName == "Blizzard_GarrisonUI") then
				GarrisonMissionTutorialFrame:HookScript("OnShow", function(self)
					GarrisonMissionTutorialFrame:Hide()
				end)
				GarrisonMissionTutorialFrame:Hide()
			end
			if (addOnName == "Blizzard_VoidStorageUI") then
				VoidStorageBorderFrameMouseBlockFrame:HookScript("OnShow", function(self)
					VoidStorageBorderFrameMouseBlockFrame:Hide();
					VoidStoragePurchaseFrame:Hide();
					VoidStorageBorderFrame.Bg:Hide();

					if (not CanUseVoidStorage()) then
						VoidStoragePurchaseFrame:Show();
					end
				end)
				VoidStorageBorderFrameMouseBlockFrame:Hide();
				VoidStoragePurchaseFrame:Hide();
				VoidStorageBorderFrame.Bg:Hide();
			end
		end)
	end

	local lowerInstanceId = Details:GetLowerInstanceNumber()
	if (lowerInstanceId) then
		local instance = Details:GetInstance(lowerInstanceId)
		if (instance) then
			--in development
			local devIcon = instance.bgdisplay:CreateTexture(nil, "overlay")
			devIcon:SetWidth(40)
			devIcon:SetHeight(40)
			devIcon:SetPoint("bottomleft", instance.baseframe, "bottomleft", 4, 8)
			devIcon:SetAlpha(.3)

			local devText = instance.bgdisplay:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
			devText:SetHeight(64)
			devText:SetPoint("left", devIcon, "right", 5, 0)
			devText:SetTextColor(1, 1, 1)
			devText:SetAlpha(.3)

			--version
			Details.FadeHandler.Fader(instance._version, 0)
			instance._version:SetText("Details! " .. Details.userversion .. " (core " .. Details.realversion .. ")")
			instance._version:SetTextColor(1, 1, 1, .95)
			instance._version:SetPoint("bottomleft", instance.baseframe, "bottomleft", 5, 1)

			if (instance.auto_switch_to_old) then
				instance:SwitchBack()
			end

			function Details:FadeStartVersion()
				Details.FadeHandler.Fader(devIcon, "in", 2)
				Details.FadeHandler.Fader(devText, "in", 2)
				Details.FadeHandler.Fader(instance._version, "in", 2)
			end
			Details.Schedules.NewTimer(12, Details.FadeStartVersion, Details)
		end
	end

	function Details:OpenOptionsWindowAtStart()
		--Details:OpenOptionsWindow (Details.tabela_instancias[1])
		--print(_G ["DetailsClearSegmentsButton1"]:GetSize())
		--Details:OpenCustomDisplayWindow()
		--Details:OpenWelcomeWindow()
	end
	Details.Schedules.NewTimer(2, Details.OpenOptionsWindowAtStart, Details)
	--Details:OpenCustomDisplayWindow()

	--minimap registration
	Details.SafeRun(Details.RegisterMinimap, "Register Minimap Icon", Details)

	--hot corner addon
	Details.Schedules.NewTimer(5, function() Details.SafeRun(Details.DoRegisterHotCorner, "Register on Hot Corner Addon", Details) end, Details)

	--restore mythic dungeon state
	Details:RestoreState_CurrentMythicDungeonRun()

	--open profiler (will only open in the first time the character is logged in)
	Details:OpenProfiler()

	--start announcers
	Details:StartAnnouncers()

	--open welcome
	if (Details.is_first_run) then
		C_Timer.After(1, function() --wait details full load the rest of the systems before executing the welcome window
			Details:OpenWelcomeWindow()
		end)
	end

	--load broadcaster tools
	Details:LoadFramesForBroadcastTools()
	Details:BrokerTick()

	---return the table where the trinket data is stored
	---@return table<spellid, trinketdata>
	function Details:GetTrinketData()
		return Details.trinket_data
	end

	local customSpellList = Details:GetDefaultCustomItemList()
	local trinketData = Details:GetTrinketData()
	for spellId, trinketTable in pairs(customSpellList) do
		if (trinketTable.isPassive) then
			if (not trinketData[spellId]) then
				---@type trinketdata
				local thisTrinketData = {
					itemName = C_Item.GetItemNameByID(trinketTable.itemId),
					spellName = Details222.GetSpellInfo(spellId) or "spell not found",
					lastActivation = 0,
					lastPlayerName = "",
					totalCooldownTime = 0,
					activations = 0,
					lastCombatId = 0,
					minTime = 9999999,
					maxTime = 0,
					averageTime = 0,
				}
				trinketData[spellId] = thisTrinketData
			end

		elseif (trinketTable.onUse and trinketTable.castId) then
			Details222.OnUseItem.Trinkets[trinketTable.castId] = spellId
		end
	end

	--register boss mobs callbacks (DBM and BigWigs) -> functions/bossmods.lua
	Details.Schedules.NewTimer(5, Details.BossModsLink, Details)

	--limit item level life for 24Hs
	local now = time()
	for guid, ilevelTable in pairs(Details.ilevel:GetPool()) do
		if (ilevelTable.time + 86400 < now) then
			Details.ilevel:ClearIlvl(guid)
		end
	end

	--dailly reset of the cache for talents and specs
	local today = date("%d")
	if (Details.last_day ~= today) then
		Details:Destroy(Details.cached_specs)
		Details:Destroy(Details.cached_talents)
	end

	--get the player spec
	C_Timer.After(2, Details.parser_functions.PLAYER_SPECIALIZATION_CHANGED)

	--embed windows on the chat window
	Details.chat_embed:CheckChatEmbed(true)

	--coach feature startup
	Details.Coach.StartUp()

	--force the group edit be always enabled when Details! starts
	Details.options_group_edit = true

	--shutdown pre-pot announcer
	Details.announce_prepots.enabled = false
	--remove standard skin on 9.0.1
	Details.standard_skin = false
	--enforce to show 6 abilities on the tooltip
	--_detalhes.tooltip.tooltip_max_abilities = 6 freeeeeedooommmmm
	--no no, enforece 8, 8 is much better, 8 is more lines, we like 8
	Details.tooltip.tooltip_max_abilities = 8

	Details.InstallRaidInfo()

	--Plater integration
	C_Timer.After(2, function()
		Details:RefreshPlaterIntegration()
	end)

	--show warning message about classic beta
	if (not DetailsFramework.IsClassicWow()) then
		--i'm not in classc wow
	else
		--print("|CFFFFFF00[Details!]: you're using Details! for RETAIL on Classic WOW, please get the classic version (Details! Damage Meter Classic WoW), if you need help see our Discord (/details discord).")
	end

	Details:InstallHook("HOOK_DEATH", Details.Coach.Client.SendMyDeath)

	if (not Details.slash_me_used) then
		if (math.random(25) == 1) then
			--Details:Msg("use '/details me' macro to open the player breakdown for you!")
		end
	end

	if (not DetailsFramework.IsTimewalkWoW()) then
		Details.cached_specs[UnitGUID("player")] = GetSpecializationInfo(GetSpecialization() or 0)
	end

	if (GetExpansionLevel() == 9) then
		if (not Details.data_wipes_exp["10"]) then
			Details:Destroy(Details.encounter_spell_pool or {})
			Details:Destroy(Details.boss_mods_timers or {})
			Details:Destroy(Details.spell_school_cache or {})
			Details:Destroy(Details.spell_pool or {})
			Details:Destroy(Details.npcid_pool or {})
			Details:Destroy(Details.current_exp_raid_encounters or {})
			Details.data_wipes_exp["10"] = true
		end
	end

	if (GetExpansionLevel() == 10) then
		if (not Details.data_wipes_exp["11"]) then
			Details:Msg("New expansion detected, clearing data...")
			Details:Destroy(Details.encounter_spell_pool or {})
			Details:Destroy(Details.boss_mods_timers or {})
			Details:Destroy(Details.spell_school_cache or {})
			Details:Destroy(Details.spell_pool or {})
			Details:Destroy(Details.npcid_pool or {})
			Details:Destroy(Details.current_exp_raid_encounters or {})
			Details.data_wipes_exp["11"] = true

			Details.frame_background_color[1] = 0.0549
			Details.frame_background_color[2] = 0.0549
			Details.frame_background_color[3] = 0.0549
			Details.frame_background_color[4] = 0.934

			if (Details.breakdown_spell_tab.spellcontainer_headers.critpercent) then
				Details.breakdown_spell_tab.spellcontainer_headers.critpercent.enabled = true
			end

			if (Details.breakdown_spell_tab.spellcontainer_headers.uptime) then
				Details.breakdown_spell_tab.spellcontainer_headers.uptime.enabled = true
			end

			if (Details.breakdown_spell_tab.spellcontainer_headers.hits) then
				Details.breakdown_spell_tab.spellcontainer_headers.hits.enabled = true
			end

			Details.breakdown_general.bar_texture = "You Are the Best!"

			Details.tooltip.rounded_corner = false

			local tooltipBarColor = Details.tooltip.bar_color
			tooltipBarColor[1] = 0.129
			tooltipBarColor[2] = 0.129
			tooltipBarColor[3] = 0.129
			tooltipBarColor[4] = 1

			local tooltipBackgroundColor = Details.tooltip.background
			tooltipBackgroundColor[1] = 0.054
			tooltipBackgroundColor[2] = 0.054
			tooltipBackgroundColor[3] = 0.054
			tooltipBackgroundColor[4] = 0.8

			Details.tooltip.fontshadow = true
			Details.tooltip.fontsize = 11
		end
	end

	Details.boss_mods_timers.encounter_timers_dbm = Details.boss_mods_timers.encounter_timers_dbm or {}
	Details.boss_mods_timers.encounter_timers_bw = Details.boss_mods_timers.encounter_timers_bw or {}

	if (Details.time_type == 3 or not Details.time_type) then
		Details.time_type = 2
	end

	--hide the panel shown by pressing the right mouse button on the title bar when a cooltip is opened
	hooksecurefunc(GameCooltip, "SetMyPoint", function()
		if (DetailsAllAttributesFrame) then
			DetailsAllAttributesFrame:Hide()
		end
	end)

	--to ignore this, use /run _G["UpdateAddOnMemoryUsage"] = Details.UpdateAddOnMemoryUsage_Original or add to any script that run on login
	--also the slash command "/details stopperfcheck" stop it as well
	Details.check_stuttering = false
	if (Details.check_stuttering) then
		_G["UpdateAddOnMemoryUsage"] = Details.UpdateAddOnMemoryUsage_Custom
	end

	Details.InitializeSpellBreakdownTab()

	pcall(Details222.ClassCache.MakeCache)

	Details:BuildSpecsNameCache()

	Details222.Cache.DoMaintenance()

	function Details:InstallOkey()
		return true
	end

	if (DetailsFramework:IsNearlyEqual(Details.class_coords.ROGUE[4], 0.25)) then
		DetailsFramework.table.copy(Details.class_coords, Details.default_profile.class_coords)
	end

--[=
	--remove on v11 launch
	if (DetailsFramework.IsWarWow()) then
	C_Timer.After(1, function() if (SplashFrame) then SplashFrame:Hide() end end)
	function HelpTip:SetHelpTipsEnabled(flag, enabled)
		if (Details.streamer_config.no_helptips) then
			HelpTip.supressHelpTips[flag] = false
		end
	end
	hooksecurefunc(HelpTipTemplateMixin, "OnShow", function(self)
		if (Details.streamer_config.no_helptips) then
			self:Hide()
		end
	end)
	hooksecurefunc(HelpTipTemplateMixin, "OnUpdate", function(self)
		if (Details.streamer_config.no_helptips) then
			self:Hide()
		end
	end)

	C_Timer.After(5, function()
	if (TutorialPointerFrame_1) then
		--TutorialPointerFrame_1:Hide()
		hooksecurefunc(TutorialPointerFrame_1, "Show", function(self)
			--self:Hide()
		end)
	end
end)
end
--]=]

end

Details.AddOnLoadFilesTime = _G.GetTime()
