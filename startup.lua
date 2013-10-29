--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.

function _G._detalhes:Start()
 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details defaults

	_detalhes.debug = false
	local _
	--> who is
		self.playername = UnitName ("player")
		self.playerserial = UnitGUID ("player")
		
		--> player faction and enemy faction
		self.faction = UnitFactionGroup ("player")
		if (self.faction == PLAYER_FACTION_GROUP[0]) then --> player is horde
			self.faction_against = PLAYER_FACTION_GROUP[1] --> ally
		elseif (self.faction == PLAYER_FACTION_GROUP[1]) then --> player is alliance
			self.faction_against = PLAYER_FACTION_GROUP[0] --> horde
		end
		
		self.zone_type = nil
		_detalhes.temp_table1 = {}
		
	--> combat
		self.encounter = {}
		self.in_combat = false
		self.combat_id = self.combat_id or 0
		self.instances_amount = self.instances_amount or 12
		self.segments_amount = self.segments_amount or 12
		self.segments_amount_to_save = self.segments_amount_to_save or 5
		self.memory_threshold = self.memory_threshold or 3
		self.memory_ram = self.memory_ram or 64
		self.deadlog_limit = self.deadlog_limit or 12
		self.minimum_combat_time = self.minimum_combat_time or 5

		if (type (self.only_pvp_frags) ~= "boolean") then
			self.only_pvp_frags = false
		end
		
		if (type (self.remove_realm_from_name) ~= "boolean") then
			self.remove_realm_from_name = true
		end
		
		if (type (self.cloud_capture) ~= "boolean") then
			self.cloud_capture = true
		end
		
		if (type (self.segments_panic_mode) ~= "boolean") then
			self.segments_panic_mode = true
		end
		
		if (type (self.clear_graphic) ~= "boolean") then
			self.clear_graphic = self.clear_graphic or true
		end
		
		if (type (self.clear_ungrouped) ~= "boolean") then
			self.clear_ungrouped = self.clear_ungrouped or true
		end
		
		if (type (self.use_row_animations) ~= "boolean") then
			self.use_row_animations = self.use_row_animations or false
		end

	--> instances (windows)
		self.solo = self.solo or nil 
		self.raid = self.raid or nil 
		self.opened_windows = 0
		
		self.update_speed = self.update_speed or 1
		self.time_type = self.time_type or 1
		
		self.row_fade_in = self.row_fade_in or {"in", 0.2}
		self.row_fade_out = self.row_fade_out or {"out", 0.2}
		self.windows_fade_in = self.windows_fade_in or {"in", 0.2}
		self.windows_fade_out = self.windows_fade_out or {"out", 0.2}

		self.default_texture = [[Interface\AddOns\Details\images\bar4]]
		self.default_texture_name = "Details D'ictum"

		self.default_bg_color = self.default_bg_color or 0.0941
		self.default_bg_alpha = self.default_bg_alpha or 0.7
		
		self.new_window_size = self.new_window_size or {width = 300, height = 95}
		self.max_window_size = self.max_window_size or {width = 480, height = 450}
		self.window_clamp = self.window_clamp or {-8, 0, 30, -14}
		
		self.report_lines = self.report_lines or 5
		self.report_to_who = self.report_to_who or ""
		
		self.animate_scroll = self.animate_scroll or false
		self.use_scroll = self.use_scroll or false
		
		self.tooltip_max_targets = 3
		self.tooltip_max_abilities = 3
		self.tooltip_max_pets = 1

		self.font_sizes = self.font_sizes or {
			menus = 10
		}
		
		self.tutorial = self.tutorial or {}
		self.tutorial.unlock_button = self.tutorial.unlock_button or 0
		self.tutorial.version_announce = self.tutorial.version_announce or 0
		self.tutorial.main_help_button = self.tutorial.main_help_button or 0
		
	--> class colors and tcoords
		if (not self.class_colors) then
			self.class_colors = {}
			for classe, tabela_cor in pairs ( RAID_CLASS_COLORS ) do 
				self.class_colors [classe] = {tabela_cor.r, tabela_cor.g, tabela_cor.b}
			end
			--self.class_colors ["UNKNOW"] = {0.3921, 0.0980, 0.0980}
			self.class_colors ["UNKNOW"] = {0.2, 0.2, 0.2}
			self.class_colors ["UNGROUPPLAYER"] = {0.4, 0.4, 0.4}
			self.class_colors ["PET"] = {0.3, 0.4, 0.5}
		end
		
		self.class_coords = {}
		for class, tcoord in pairs (_G.CLASS_ICON_TCOORDS) do
			self.class_coords [class] = tcoord
		end
		
		self.class_icons_small = [[Interface\AddOns\Details\images\classes_small]]
		self.class_coords ["Alliance"] = {0.49609375, 0.7421875, 0.75, 1}
		self.class_coords ["Horde"] = {0.7421875, 0.98828125, 0.75, 1}
		self.class_coords ["PET"] = {0.25, 0.49609375, 0.75, 1}
		self.class_coords ["MONSTER"] = {0, 0.25, 0.75, 1}
		
		self.class_coords ["UNKNOW"] = {0.5, 0.75, 0.75, 1}
		self.class_coords ["UNGROUPPLAYER"] = {0.5, 0.75, 0.75, 1}
		
		
		

	--> single click row function replace
		--damage, dps, damage taken, friendly fire
			self.row_singleclick_overwrite [1] = {true, true, true, true, self.atributo_damage.ReportSingleFragsLine} 
		--healing, hps, overheal, healing taken
			self.row_singleclick_overwrite [2] = {true, true, true, true, false, self.atributo_heal.ReportSingleDamagePreventedLine} 
		--mana, rage, energy, runepower
			self.row_singleclick_overwrite [3] = {true, true, true, true} 
		--cc breaks, ress, interrupts, dispells, deaths
			self.row_singleclick_overwrite [4] = {true, true, true, true, self.atributo_misc.ReportSingleDeadLine, self.atributo_misc.ReportSingleCooldownLine, self.atributo_misc.ReportSingleBuffUptimeLine} 
		
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> initialize

	--> build frames
		--> cooltip
			self.popup = DetailsCreateCoolTip()
		--> fast switch
			if (self.switch.InitSwitch) then
				self.switch:InitSwitch()
			end
		--> custom window
			self.custom = self.custom or {}
			self:InitCustom()
		--> actor info
			self.janela_info = self.gump:CriaJanelaInfo()
			self.gump:Fade (self.janela_info, 1)
		--> copy and paste window
			self:CreateCopyPasteWindow()
			self.CreateCopyPasteWindow = nil
		--> yesno frame
			self.yesNo = self.gump:NewPanel (UIParent, _, "DetailsYesNoWindow", _, 500, 80)
			self.yesNo:SetPoint ("center", UIParent, "center")
			self.gump:NewLabel (self.yesNo, _, "$parentAsk", "ask", "")
			self.yesNo ["ask"]:SetPoint ("center", self.yesNo, "center", 0, 25)
			self.yesNo ["ask"]:SetWidth (480)
			self.yesNo ["ask"]:SetJustifyH ("center")
			self.yesNo ["ask"]:SetHeight (22)
			local Loc = LibStub ("AceLocale-3.0"):GetLocale ("Details")
			self.gump:NewButton (self.yesNo, _, "$parentNo", "no", 100, 30, function() self.yesNo:Hide() end, nil, nil, nil, Loc ["STRING_NO"])
			self.gump:NewButton (self.yesNo, _, "$parentYes", "yes", 100, 30, nil, nil, nil, nil, Loc ["STRING_YES"])
			self.yesNo ["no"]:SetPoint (10, -45)
			self.yesNo ["yes"]:SetPoint (390, -45)
			self.yesNo ["no"]:InstallCustomTexture()
			self.yesNo ["yes"]:InstallCustomTexture()
			self.yesNo ["yes"]:SetHook ("OnMouseUp", function() self.yesNo:Hide() end)
			function _detalhes:Ask (msg, func, ...)
				self.yesNo ["ask"].text = msg
				local p1, p2 = ...
				self.yesNo ["yes"]:SetClickFunction (func, p1, p2)
				self.yesNo:Show()
			end
			self.yesNo:Hide()

	--> start instances
	
		--_detalhes.custom = {}
		--_detalhes.tabela_instancias = {}
	
		if (self:QuantasInstancias() == 0) then
			self:CriarInstancia()
		else
			self:ReativarInstancias()
		end
		self:GetLowerInstanceNumber()
		self:CheckConsolidates()
	
	--> start time machine
		self.timeMachine:Ligar()
		
	--> start instances updater
		self:AtualizaGumpPrincipal (-1, true)
		self.atualizador = self:ScheduleRepeatingTimer ("AtualizaGumpPrincipal", _detalhes.update_speed, -1)
		
		for index = 1, #self.tabela_instancias do
			local instance = self.tabela_instancias [index]
			if (instance:IsAtiva()) then
				self:ScheduleTimer ("RefreshBars", 1, instance)
				self:ScheduleTimer ("InstanceReset", 1, instance)
				self:ScheduleTimer ("InstanceRefreshRows", 1, instance)
			end
		end

		function self:AtualizaGumps()
			self:AtualizaGumpPrincipal (-1, true)
			self.AtualizaGumps = nil
			for index = 1, #self.tabela_instancias do
				local instance = self.tabela_instancias [index]
				if (instance:IsAtiva()) then
					if (instance.wallpaper.enabled) then
						instance:InstanceWallpaper (true)
					end
				end
			end
		end
		self:ScheduleTimer ("AtualizaGumps", 4)
		
	--> start garbage collector
		self.ultima_coleta = 0
		self.intervalo_coleta = 720
		self.intervalo_memoria = 180
		self.garbagecollect = self:ScheduleRepeatingTimer ("IniciarColetaDeLixo", self.intervalo_coleta)
		self.memorycleanup = self:ScheduleRepeatingTimer ("CheckMemoryPeriodically", self.intervalo_memoria)
		self.next_memory_check = time()+self.intervalo_memoria
		
	--> start parser
		
		--> load parser capture options
			self:CaptureRefresh()
		--> register parser events
			self.listener:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
			self.listener:RegisterEvent ("PLAYER_REGEN_DISABLED")
			self.listener:RegisterEvent ("PLAYER_REGEN_ENABLED")
			self.listener:RegisterEvent ("SPELL_SUMMON")
			self.listener:RegisterEvent ("UNIT_PET")

			self.listener:RegisterEvent ("PARTY_MEMBERS_CHANGED")
			self.listener:RegisterEvent ("GROUP_ROSTER_UPDATE")
			self.listener:RegisterEvent ("PARTY_CONVERTED_TO_RAID")
			
			self.listener:RegisterEvent ("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			
			self.listener:RegisterEvent ("ZONE_CHANGED_NEW_AREA")
			self.listener:RegisterEvent ("PLAYER_ENTERING_WORLD")
		
			--self.listener:RegisterAllEvents()
		
	--		self.listener:RegisterEvent ("SPELL_CAST_START")
	--		self.listener:RegisterEvent ("UNIT_SPELLCAST_STOP")
	--		self.listener:RegisterEvent ("UNIT_SPELLCAST_SUCCEEDED")
	--		self.listener:RegisterEvent ("UNIT_SPELLCAST_FAILED")
	--		self.listener:RegisterEvent ("UNIT_SPELLCAST_FAILED_QUIET")
	--		self.listener:RegisterEvent ("UNIT_SPELLCAST_INTERRUPTED")
	----------------------------------------------------------------------------------------------------------------------------------------

	
	--> done
	self.initializing = nil
	
	--> group
	self.details_users = {}
	self.in_group = IsInGroup() or IsInRaid()

	--> send messages gathered on initialization
	self:ScheduleTimer ("ShowDelayMsg", 7) 
	
	--> send instance open signal
	for index, instancia in ipairs (self.tabela_instancias) do
		if (instancia.ativa) then
			self:SendEvent ("DETAILS_INSTANCE_OPEN", nil, instancia)
		end
	end
	
	--> all done, send started signal and we are ready
	function self:AnnounceStartup()
		self:SendEvent ("DETAILS_STARTED", "SEND_TO_ALL")
	end
	self:ScheduleTimer ("AnnounceStartup", 5)
	
	--> announce alpha version
	function self:AnnounceVersion()
		for index, instancia in ipairs (self.tabela_instancias) do
			if (instancia.ativa) then
				self.gump:Fade (instancia._version, "in", 5)
			end
		end
	end
	
	if (self.tutorial.version_announce < 4) then
		self:ScheduleTimer ("AnnounceVersion", 20)
		self.tutorial.version_announce = self.tutorial.version_announce + 1
	else
		for index, instancia in ipairs (self.tabela_instancias) do
			if (instancia.ativa) then
				self.gump:Fade (instancia._version, 0)
				instancia._version:SetText ("Details Alpha " .. _detalhes.userversion .. " (core: " .. self.realversion .. ")")
				instancia._version:SetPoint ("bottomleft", instancia.baseframe, "bottomleft", 0, 1)
				self.gump:Fade (instancia._version, "in", 10)
			end
		end
	end
	
	if (self.is_first_run) then
		_detalhes:OpenWelcomeWindow()
	end
	
	if (self.is_version_first_run) then
		local lower_instance = _detalhes:GetLowerInstanceNumber()
		if (lower_instance) then
			lower_instance = _detalhes:GetInstance (lower_instance)
			if (lower_instance) then
				lower_instance:InstanceAlert (Loc ["STRING_VERSION_UPDATE"], {[[Interface\GossipFrame\AvailableQuestIcon]], 16, 16, false}, 20, {_detalhes.OpenNewsWindow})
			end
		end
	end
	
end
