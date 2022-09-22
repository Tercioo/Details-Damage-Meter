

local UnitGroupRolesAssigned = _G.DetailsFramework.UnitGroupRolesAssigned
local wipe = _G.wipe
local C_Timer = _G.C_Timer
local CreateFrame = _G.CreateFrame
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")

--start funtion
function Details:StartMeUp() --I'll never stop!
	--set default time for arena and bg to be the Details! load time in case the client loads mid event
	Details.lastArenaStartTime = GetTime()
	Details.lastBattlegroundStartTime = GetTime()

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> row single click, this determines what happen when the user click on a bar

	--> single click row function replace
		--damage, dps, damage taken, friendly fire
			self.row_singleclick_overwrite[1] = {true, true, true, true, self.atributo_damage.ReportSingleFragsLine, self.atributo_damage.ReportEnemyDamageTaken, self.atributo_damage.ReportSingleVoidZoneLine, self.atributo_damage.ReportSingleDTBSLine}
		--healing, hps, overheal, healing taken
			self.row_singleclick_overwrite[2] = {true, true, true, true, false, self.atributo_heal.ReportSingleDamagePreventedLine}
		--mana, rage, energy, runepower
			self.row_singleclick_overwrite[3] = {true, true, true, true}
		--cc breaks, ress, interrupts, dispells, deaths
			self.row_singleclick_overwrite[4] = {true, true, true, true, self.atributo_misc.ReportSingleDeadLine, self.atributo_misc.ReportSingleCooldownLine, self.atributo_misc.ReportSingleBuffUptimeLine, self.atributo_misc.ReportSingleDebuffUptimeLine}

		function self:ReplaceRowSingleClickFunction(attribute, subAttribute, func)
			assert(type(attribute) == "number" and attribute >= 1 and attribute <= 4, "ReplaceRowSingleClickFunction expects a attribute index on #1 argument.")
			assert(type(subAttribute) == "number" and subAttribute >= 1 and subAttribute <= 10, "ReplaceRowSingleClickFunction expects a sub attribute index on #2 argument.")
			assert(type(func) == "function", "ReplaceRowSingleClickFunction expects a function on #3 argument.")

			self.row_singleclick_overwrite[attribute][subAttribute] = func
			return true
		end

		self.click_to_report_color = {1, 0.8, 0, 1}

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> initialize
	C_Timer.After(2, function()
		--test libOpenRaid deprecated code
		--[=[
		local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")
		openRaidLib.playerInfoManager.GetPlayerInfo()
		openRaidLib.RequestAllPlayersInfo()
		openRaidLib.playerInfoManager.GetAllPlayersInfo()
		openRaidLib.gearManager.GetAllPlayersGear()
		openRaidLib.gearManager.GetPlayerGear()
		openRaidLib.cooldownManager.GetAllPlayersCooldown()
		openRaidLib.cooldownManager.GetPlayerCooldowns()
		--]=]
	end)

	--plugin container
	self:CreatePluginWindowContainer()
	self:InitializeForge() --to install into the container plugin
	self:InitializeRaidHistoryWindow()
	--self:InitializeOptionsWindow()

	C_Timer.After(2, function()
		self:InitializeAuraCreationWindow()
	end)

	self:InitializeCustomDisplayWindow()
	self:InitializeAPIWindow()
	self:InitializeRunCodeWindow()
	self:InitializePlaterIntegrationWindow()
	self:InitializeMacrosWindow()

	if (self.ocd_tracker.show_options) then
		self:InitializeCDTrackerWindow()
	end

	--custom window
	self.custom = self.custom or {}

	--micro button alert
	--"MainMenuBarMicroButton" has been removed on 9.0
	self.MicroButtonAlert = CreateFrame("frame", "DetailsMicroButtonAlert", UIParent)
	self.MicroButtonAlert.Text = self.MicroButtonAlert:CreateFontString(nil, "overlay", "GameFontNormal")
	self.MicroButtonAlert.Text:SetPoint("center")
	self.MicroButtonAlert:Hide()

	--actor details window
	self.playerDetailWindow = self.gump:CriaJanelaInfo()
	Details.FadeHandler.Fader(self.playerDetailWindow, 1)

	--copy and paste window
	self:CreateCopyPasteWindow()
	self.CreateCopyPasteWindow = nil

	--start instances
	if (self:GetNumInstancesAmount() == 0) then
		self:CriarInstancia()
	end
	self:GetLowerInstanceNumber()

	--start time machine
	self.timeMachine:Ligar()

	--update abbreviation shortcut
	self.atributo_damage:UpdateSelectedToKFunction()
	self.atributo_heal:UpdateSelectedToKFunction()
	self.atributo_energy:UpdateSelectedToKFunction()
	self.atributo_misc:UpdateSelectedToKFunction()
	self.atributo_custom:UpdateSelectedToKFunction()

	--> start instances updater
		self:CheckSwitchOnLogon()

		function Details:ScheduledWindowUpdate(forced)
			if (not forced and Details.in_combat) then
				return
			end
			Details.scheduled_window_update = nil
			Details:RefreshMainWindow(-1, true)
		end
		function Details:ScheduleWindowUpdate(time, forced)
			if (Details.scheduled_window_update) then
				Details.Schedules.Cancel(Details.scheduled_window_update)
				Details.scheduled_window_update = nil
			end
			Details.scheduled_window_update = Details.Schedules.NewTimer(time or 1, Details.ScheduledWindowUpdate, Details, forced)
		end

		self:RefreshMainWindow(-1, true)
		Details:RefreshUpdater()

		for index = 1, #self.tabela_instancias do
			local instance = self.tabela_instancias[index]
			if (instance:IsAtiva()) then
				Details.Schedules.NewTimer(1, Details.RefreshBars, Details, instance)
				Details.Schedules.NewTimer(1, Details.InstanceReset, Details, instance)
				Details.Schedules.NewTimer(1, Details.InstanceRefreshRows, Details, instance)

				--self:ScheduleTimer("RefreshBars", 1, instance)
				--self:ScheduleTimer("InstanceReset", 1, instance)
				--self: ("InstanceRefreshRows", 1, instance)
			end
		end

		function self:RefreshAfterStartup()
			--repair nicknames
			if (not Details.ignore_nicktag) then
				local currentCombat = Details:GetCurrentCombat()
				local containerDamage = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
				for _, actorObject in containerDamage:ListActors() do
					--get the actor nickname
					local nickname = Details:GetNickname(actorObject:Name(), false, true)
					if (nickname) then
						actorObject.displayName = nickname
					end
				end
			end

			self:RefreshMainWindow(-1, true)

			local lower_instance = Details:GetLowerInstanceNumber()

			for index = 1, #self.tabela_instancias do
				local instance = self.tabela_instancias [index]
				if(instance:IsAtiva()) then
					--refresh wallpaper
					if(instance.wallpaper.enabled) then
						instance:InstanceWallpaper(true)
					else
						instance:InstanceWallpaper(false)
					end

					--refresh desaturated icons if is lower instance
					if(index == lower_instance) then
						instance:DesaturateMenu()

						instance:SetAutoHideMenu(nil, nil, true)
					end
				end
			end

			--refresh lower instance plugin icons and skin
			Details.ToolBar:ReorganizeIcons()

			--refresh skin for other windows
			if (lower_instance) then
				for i = lower_instance+1, #self.tabela_instancias do
					local instance = self:GetInstance(i)
					if (instance and instance.baseframe and instance.ativa) then
						instance:ChangeSkin()
					end
				end
			end

			self.RefreshAfterStartup = nil

			function Details:CheckWallpaperAfterStartup()
				if (not Details.profile_loaded) then
					Details.Schedules.NewTimer(5, Details.CheckWallpaperAfterStartup, Details)
					--return Details:ScheduleTimer ("CheckWallpaperAfterStartup", 2)
				end

				for i = 1, self.instances_amount do
					local instance = self:GetInstance (i)
					if (instance and instance:IsEnabled()) then
						if (not instance.wallpaper.enabled) then
							instance:InstanceWallpaper (false)
						end

						instance.do_not_snap = true
						self.move_janela_func (instance.baseframe, true, instance, true)
						self.move_janela_func (instance.baseframe, false, instance, true)
						instance.do_not_snap = false
					end
				end
				self.CheckWallpaperAfterStartup = nil
				Details.profile_loaded = nil
			end
			--Details:ScheduleTimer ("CheckWallpaperAfterStartup", 5)
			Details.Schedules.NewTimer(5, Details.CheckWallpaperAfterStartup, Details)
		end

		--self:ScheduleTimer ("RefreshAfterStartup", 5)
		Details.Schedules.NewTimer(5, Details.RefreshAfterStartup, Details)

	--start garbage collector
	self.ultima_coleta = 0
	self.intervalo_coleta = 720
	self.intervalo_memoria = 180
	--self.garbagecollect = self:ScheduleRepeatingTimer ("IniciarColetaDeLixo", self.intervalo_coleta) --deprecated
	self.garbagecollect = Details.Schedules.NewTicker(self.intervalo_coleta, Details.IniciarColetaDeLixo, Details)
	self.next_memory_check = _G.time()+self.intervalo_memoria

	--player role
	self.last_assigned_role = UnitGroupRolesAssigned ("player")
		
	--> start parser
		
		--> load parser capture options
			self:CaptureRefresh()

		--> register parser events
			self.listener:RegisterEvent ("PLAYER_REGEN_DISABLED")
			self.listener:RegisterEvent ("PLAYER_REGEN_ENABLED")
			self.listener:RegisterEvent ("UNIT_PET")

			self.listener:RegisterEvent ("GROUP_ROSTER_UPDATE")
			self.listener:RegisterEvent ("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			
			self.listener:RegisterEvent ("ZONE_CHANGED_NEW_AREA")
			self.listener:RegisterEvent ("PLAYER_ENTERING_WORLD")
		
			self.listener:RegisterEvent ("ENCOUNTER_START")
			self.listener:RegisterEvent ("ENCOUNTER_END")
			
			self.listener:RegisterEvent ("START_TIMER")
			self.listener:RegisterEvent ("UNIT_NAME_UPDATE")

			self.listener:RegisterEvent ("PLAYER_ROLES_ASSIGNED")
			self.listener:RegisterEvent ("ROLE_CHANGED_INFORM")
			
			self.listener:RegisterEvent ("UNIT_FACTION")

			if (not _G.DetailsFramework.IsTimewalkWoW()) then
				self.listener:RegisterEvent ("PET_BATTLE_OPENING_START")
				self.listener:RegisterEvent ("PET_BATTLE_CLOSE")
				self.listener:RegisterEvent ("PLAYER_SPECIALIZATION_CHANGED")
				self.listener:RegisterEvent ("PLAYER_TALENT_UPDATE")
				self.listener:RegisterEvent ("CHALLENGE_MODE_START")
				self.listener:RegisterEvent ("CHALLENGE_MODE_COMPLETED")
			end

			self.parser_frame:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")

	--update is in group
	self.details_users = {}
	self.in_group = IsInGroup() or IsInRaid()

	--done
	self.initializing = nil

	--scan pets
	Details:SchedulePetUpdate(1)

	--send messages gathered on initialization
	--self:ScheduleTimer ("ShowDelayMsg", 10)
	Details.Schedules.NewTimer(10, Details.ShowDelayMsg, Details)

	--send instance open signal
	for index, instancia in Details:ListInstances() do
		if (instancia.ativa) then
			self:SendEvent ("DETAILS_INSTANCE_OPEN", nil, instancia)
		end
	end

	--send details startup done signal
	function self:AnnounceStartup()
		self:SendEvent ("DETAILS_STARTED", "SEND_TO_ALL")

		if (Details.in_group) then
			Details:SendEvent ("GROUP_ONENTER")
		else
			Details:SendEvent ("GROUP_ONLEAVE")
		end

		Details.last_zone_type = "INIT"
		Details.parser_functions:ZONE_CHANGED_NEW_AREA()

		Details.AnnounceStartup = nil
	end

	--self:ScheduleTimer ("AnnounceStartup", 5)
	Details.Schedules.NewTimer(5, Details.AnnounceStartup, Details)

	if (Details.failed_to_load) then
		Details:CancelTimer (Details.failed_to_load)
		Details.failed_to_load = nil
	end

	--announce alpha version
	function self:AnnounceVersion()
		for index, instancia in Details:ListInstances() do
			if (instancia.ativa) then
				Details.FadeHandler.Fader(instancia._version, "in", 0.1)
			end
		end
	end

	--check version
	Details:CheckVersion(true)

	--restore cooltip anchor position, this is for the custom anchor in the screen
	_G.DetailsTooltipAnchor:Restore()

	--check is this is the first run
	if (self.is_first_run) then
		if (#self.custom == 0) then
			Details:AddDefaultCustomDisplays()
		end
		Details:FillUserCustomSpells()
	end

	--check is this is the first run of this version
	if (self.is_version_first_run) then
		local lower_instance = Details:GetLowerInstanceNumber()
		if (lower_instance) then
			lower_instance = Details:GetInstance (lower_instance)

			if (lower_instance) then
				--check if there's changes in the size of the news string
				if (Details.last_changelog_size < #Loc["STRING_VERSION_LOG"]) then
					Details.last_changelog_size = #Loc["STRING_VERSION_LOG"]

					if (Details.auto_open_news_window) then
						C_Timer.After(5, function()
							Details.OpenNewsWindow()
						end)
					end

					if (lower_instance) then
						_G.C_Timer.After(10, function()
							if (lower_instance:IsEnabled()) then
								lower_instance:InstanceAlert(Loc ["STRING_VERSION_UPDATE"], {[[Interface\GossipFrame\AvailableQuestIcon]], 16, 16, false}, 60, {Details.OpenNewsWindow}, true)
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

	local lower = Details:GetLowerInstanceNumber()
	if (lower) then
		local instance = Details:GetInstance (lower)
		if (instance) then
			--in development
			local dev_icon = instance.bgdisplay:CreateTexture (nil, "overlay")
			dev_icon:SetWidth (40)
			dev_icon:SetHeight (40)
			dev_icon:SetPoint ("bottomleft", instance.baseframe, "bottomleft", 4, 8)
			dev_icon:SetAlpha (.3)

			local dev_text = instance.bgdisplay:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
			dev_text:SetHeight (64)
			dev_text:SetPoint ("left", dev_icon, "right", 5, 0)
			dev_text:SetTextColor (1, 1, 1)
			dev_text:SetAlpha (.3)

			--version
			Details.FadeHandler.Fader (instance._version, 0)
			instance._version:SetText ("Details! " .. Details.userversion .. " (core " .. self.realversion .. ")")
			instance._version:SetTextColor (1, 1, 1, .35)
			instance._version:SetPoint ("bottomleft", instance.baseframe, "bottomleft", 5, 1)

			if (instance.auto_switch_to_old) then
				instance:SwitchBack()
			end

			function Details:FadeStartVersion()
				Details.FadeHandler.Fader (dev_icon, "in", 2)
				Details.FadeHandler.Fader (dev_text, "in", 2)
				Details.FadeHandler.Fader (instance._version, "in", 2)
			end
			Details.Schedules.NewTimer(12, Details.FadeStartVersion, Details)
		end
	end

	function Details:OpenOptionsWindowAtStart()
		--Details:OpenOptionsWindow (Details.tabela_instancias[1])
		--print (_G ["DetailsClearSegmentsButton1"]:GetSize())
		--Details:OpenCustomDisplayWindow()
		--Details:OpenWelcomeWindow()
	end
	--Details:ScheduleTimer ("OpenOptionsWindowAtStart", 2)
	Details.Schedules.NewTimer(2, Details.OpenOptionsWindowAtStart, Details)
	--Details:OpenCustomDisplayWindow()

	--> minimap
	pcall (Details.RegisterMinimap, Details)

	--hot corner addon
	function Details:RegisterHotCorner()
		Details:DoRegisterHotCorner()
	end
	--Details:ScheduleTimer ("RegisterHotCorner", 5)
	Details.Schedules.NewTimer(5, Details.RegisterHotCorner, Details)


	--restore mythic dungeon state
	Details:RestoreState_CurrentMythicDungeonRun()

	--open profiler
	Details:OpenProfiler()

	--start announcers
	Details:StartAnnouncers()

	--open welcome
	if (self.is_first_run) then
		C_Timer.After(1, function() --wait details full load the rest of the systems before executing the welcome window
			Details:OpenWelcomeWindow()
		end)
	end

	--load broadcaster tools
	Details:LoadFramesForBroadcastTools()
	Details:BrokerTick()

	--register boss mobs callbacks (DBM and BigWigs) -> functions/bossmods.lua
	Details.Schedules.NewTimer(5, Details.BossModsLink, Details)

	--limit item level life for 24Hs
	local now = _G.time()
	for guid, t in pairs(Details.item_level_pool) do
		if (t.time + 86400 < now) then
			Details.item_level_pool[guid] = nil
		end
	end

	--dailly reset of the cache for talents and specs
	local today = _G.date("%d")
	if (Details.last_day ~= today) then
		wipe(Details.cached_specs)
		wipe(Details.cached_talents)
	end

	--get the player spec
	C_Timer.After(2, Details.parser_functions.PLAYER_SPECIALIZATION_CHANGED)

	--embed windows on the chat window
	Details.chat_embed:CheckChatEmbed(true)

	--save the time when the addon finished loading
	Details.AddOnStartTime = GetTime()
	function Details.GetStartupTime()
		return Details.AddOnStartTime or GetTime()
	end

	if (Details.player_details_window.skin ~= "ElvUI") then
		local reset_player_detail_window = function()
			Details:ApplyPDWSkin("ElvUI")
		end
		C_Timer.After(2, reset_player_detail_window)
	end

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

	Details.InstallRaidInfo()

	--Plater integration
	C_Timer.After(2, function()
		Details:RefreshPlaterIntegration()
	end)

	--show warning message about classic beta
	if (not DetailsFramework.IsClassicWow()) then
		--i'm not in classc wow
	else
		print ("|CFFFFFF00[Details!]: you're using Details! for RETAIL on Classic WOW, please get the classic version (Details! Damage Meter Classic WoW), if you need help see our Discord (/details discord).")
	end

	Details:InstallHook("HOOK_DEATH", Details.Coach.Client.SendMyDeath)

	if (math.random(10) == 1) then
		Details:Msg("use '/details me' macro to open the player breakdown for you!")
	end

	if (not DetailsFramework.IsTimewalkWoW()) then
		Details.cached_specs[UnitGUID("player")] = GetSpecializationInfo(GetSpecialization() or 0)
	end

	if (not Details.data_wipes_exp["9"]) then
		wipe(Details.encounter_spell_pool or {})
		wipe(Details.boss_mods_timers or {})
		wipe(Details.spell_school_cache or {})
		wipe(Details.spell_pool or {})
		wipe(Details.npcid_pool or {})
		wipe(Details.current_exp_raid_encounters or {})
		Details.data_wipes_exp["9"] = true
	end

	Details.boss_mods_timers.encounter_timers_dbm = Details.boss_mods_timers.encounter_timers_dbm or {}
	Details.boss_mods_timers.encounter_timers_bw = Details.boss_mods_timers.encounter_timers_bw or {}

	--clear overall data on new session
	if (Details.overall_clear_logout) then
		Details.tabela_overall = Details.combate:NovaTabela()
	end

	if (not DetailsFramework.IsTimewalkWoW()) then
		--wipe overall on torghast - REMOVE ON 10.0
		local torghastTracker = CreateFrame("frame")
		torghastTracker:RegisterEvent("JAILERS_TOWER_LEVEL_UPDATE")
		torghastTracker:SetScript("OnEvent", function(self, event, level, towerType)
			if (level == 1) then
				if (Details.overall_clear_newtorghast) then
					Details.historico:resetar_overall()
					Details:Msg ("overall data are now reset.") --localize-me
				end
			end
		end)
	end

	--hide the panel shown by pressing the right mouse button on the title bar when a cooltip is opened
	hooksecurefunc(GameCooltip, "SetMyPoint", function()
		if (DetailsAllAttributesFrame) then
			DetailsAllAttributesFrame:Hide()
		end
	end)

	if (DetailsFramework.IsDragonflight()) then
		DetailsFramework.Schedules.NewTimer(5, Details.RegisterDragonFlightEditMode)
	end

	function Details:InstallOkey()
		return true
	end

	--shutdown the old OnDeathMenu
	--cleanup: this line can be removed after the first month of dragonflight
	Details.on_death_menu = false
end

Details.AddOnLoadFilesTime = _G.GetTime()









