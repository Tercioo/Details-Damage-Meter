


--> check unloaded files:
if (
	-- version 1.21.0
	not _G._detalhes.atributo_custom.damagedoneTooltip or
	not _G._detalhes.atributo_custom.healdoneTooltip
	) then
	
	local f = CreateFrame ("frame", "DetaisCorruptInstall", UIParent)
	f:SetSize (370, 70)
	f:SetPoint ("center", UIParent, "center", 0, 0)
	f:SetPoint ("top", UIParent, "top", 0, -20)
	local bg = f:CreateTexture (nil, "background")
	bg:SetAllPoints (f)
	bg:SetTexture ([[Interface\AddOns\Details\images\welcome]])
	
	local image = f:CreateTexture (nil, "overlay")
	image:SetTexture ([[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]])
	image:SetSize (32, 32)
	
	local label = f:CreateFontString (nil, "overlay", "GameFontNormal")
	label:SetText ("Restart game client in order to finish addons updates.")
	label:SetWidth (300)
	label:SetJustifyH ("left")
	
	local close = CreateFrame ("button", "DetaisCorruptInstall", f, "UIPanelCloseButton")
	close:SetSize (32, 32)
	close:SetPoint ("topright", f, "topright", 0, 0)
	
	image:SetPoint ("topleft", f, "topleft", 10, -20)	
	label:SetPoint ("left", image, "right", 4, 0)

	_G._detalhes.FILEBROKEN = true
end

function _G._detalhes:InstallOkey()
	if (_G._detalhes.FILEBROKEN) then
		return false
	end
	return true
end

--> start funtion
function _G._detalhes:Start()

	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> row single click

	--> single click row function replace
		--damage, dps, damage taken, friendly fire
			self.row_singleclick_overwrite [1] = {true, true, true, true, self.atributo_damage.ReportSingleFragsLine, self.atributo_damage.ReportEnemyDamageTaken, self.atributo_damage.ReportSingleVoidZoneLine, self.atributo_damage.ReportSingleDTBSLine}
		--healing, hps, overheal, healing taken
			self.row_singleclick_overwrite [2] = {true, true, true, true, false, self.atributo_heal.ReportSingleDamagePreventedLine} 
		--mana, rage, energy, runepower
			self.row_singleclick_overwrite [3] = {true, true, true, true} 
		--cc breaks, ress, interrupts, dispells, deaths
			self.row_singleclick_overwrite [4] = {true, true, true, true, self.atributo_misc.ReportSingleDeadLine, self.atributo_misc.ReportSingleCooldownLine, self.atributo_misc.ReportSingleBuffUptimeLine, self.atributo_misc.ReportSingleDebuffUptimeLine} 
		
		function self:ReplaceRowSingleClickFunction (attribute, sub_attribute, func)
			assert (type (attribute) == "number" and attribute >= 1 and attribute <= 4, "ReplaceRowSingleClickFunction expects a attribute index on #1 argument.")
			assert (type (sub_attribute) == "number" and sub_attribute >= 1 and sub_attribute <= 10, "ReplaceRowSingleClickFunction expects a sub attribute index on #2 argument.")
			assert (type (func) == "function", "ReplaceRowSingleClickFunction expects a function on #3 argument.")
			
			self.row_singleclick_overwrite [attribute] [sub_attribute] = func
			return true
		end
		
		self.click_to_report_color = {1, 0.8, 0, 1}
		
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> initialize

	--> build frames

		--> bookmarks
			if (self.switch.InitSwitch) then
				--self.switch:InitSwitch()
			end
			
		--> custom window
			self.custom = self.custom or {}
			
		--> micro button alert
			self.MicroButtonAlert = CreateFrame ("frame", "DetailsMicroButtonAlert", UIParent, "MicroButtonAlertTemplate")
			self.MicroButtonAlert:Hide()
			
		--> actor details window
			self.janela_info = self.gump:CriaJanelaInfo()
			self.gump:Fade (self.janela_info, 1)
			
		--> copy and paste window
			self:CreateCopyPasteWindow()
			self.CreateCopyPasteWindow = nil
			
	--> start instances
		if (self:GetNumInstancesAmount() == 0) then
			self:CriarInstancia()
		end
		self:GetLowerInstanceNumber()
		
	--> start time machine
		self.timeMachine:Ligar()
	
	--> update abbreviation shortcut
	
		self.atributo_damage:UpdateSelectedToKFunction()
		self.atributo_heal:UpdateSelectedToKFunction()
		self.atributo_energy:UpdateSelectedToKFunction()
		self.atributo_misc:UpdateSelectedToKFunction()
		self.atributo_custom:UpdateSelectedToKFunction()
		
	--> start instances updater
	
		self:CheckSwitchOnLogon()
	
		function _detalhes:ScheduledWindowUpdate (forced)
			if (not forced and _detalhes.in_combat) then
				return
			end
			_detalhes.scheduled_window_update = nil
			_detalhes:AtualizaGumpPrincipal (-1, true)
		end
		function _detalhes:ScheduleWindowUpdate (time, forced)
			if (_detalhes.scheduled_window_update) then
				_detalhes:CancelTimer (_detalhes.scheduled_window_update)
				_detalhes.scheduled_window_update = nil
			end
			_detalhes.scheduled_window_update = _detalhes:ScheduleTimer ("ScheduledWindowUpdate", time or 1, forced)
		end
	
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

		function self:RefreshAfterStartup()
		
			self:AtualizaGumpPrincipal (-1, true)
			
			local lower_instance = _detalhes:GetLowerInstanceNumber()

			for index = 1, #self.tabela_instancias do
				local instance = self.tabela_instancias [index]
				if (instance:IsAtiva()) then
					--> refresh wallpaper
					if (instance.wallpaper.enabled) then
						instance:InstanceWallpaper (true)
					else
						instance:InstanceWallpaper (false)
					end
					
					--> refresh desaturated icons if is lower instance
					if (index == lower_instance) then
						instance:DesaturateMenu()

						instance:SetAutoHideMenu (nil, nil, true)
					end
					
				end
			end
			
			--> refresh lower instance plugin icons and skin
			_detalhes.ToolBar:ReorganizeIcons() 
			--> refresh skin for other windows
			if (lower_instance) then
				for i = lower_instance+1, #self.tabela_instancias do
					local instance = self:GetInstance (i)
					if (instance and instance.baseframe and instance.ativa) then
						instance:ChangeSkin()
					end
				end
			end
		
			self.RefreshAfterStartup = nil
			
			function _detalhes:CheckWallpaperAfterStartup()
			
				if (not _detalhes.profile_loaded) then
					return _detalhes:ScheduleTimer ("CheckWallpaperAfterStartup", 2)
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
				_detalhes.profile_loaded = nil

			end
			
			_detalhes:ScheduleTimer ("CheckWallpaperAfterStartup", 5)
			
		end
		self:ScheduleTimer ("RefreshAfterStartup", 5)

		
	--> start garbage collector
	
		self.ultima_coleta = 0
		self.intervalo_coleta = 720
		--self.intervalo_coleta = 10
		self.intervalo_memoria = 180
		--self.intervalo_memoria = 20
		self.garbagecollect = self:ScheduleRepeatingTimer ("IniciarColetaDeLixo", self.intervalo_coleta)
		self.memorycleanup = self:ScheduleRepeatingTimer ("CheckMemoryPeriodically", self.intervalo_memoria)
		self.next_memory_check = time()+self.intervalo_memoria

	--> role
		self.last_assigned_role = UnitGroupRolesAssigned ("player")
		
	--> start parser
		
		--> load parser capture options
			self:CaptureRefresh()
		--> register parser events
			
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
		
			self.listener:RegisterEvent ("ENCOUNTER_START")
			self.listener:RegisterEvent ("ENCOUNTER_END")
			
			self.listener:RegisterEvent ("START_TIMER")
			self.listener:RegisterEvent ("UNIT_NAME_UPDATE")

			self.listener:RegisterEvent ("PET_BATTLE_OPENING_START")
			self.listener:RegisterEvent ("PET_BATTLE_CLOSE")
			
			self.listener:RegisterEvent ("PLAYER_ROLES_ASSIGNED")
			self.listener:RegisterEvent ("ROLE_CHANGED_INFORM")
			
			self.listener:RegisterEvent ("PLAYER_SPECIALIZATION_CHANGED")
			
			self.parser_frame:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")

	--> group
		self.details_users = {}
		self.in_group = IsInGroup() or IsInRaid()
		
	--> done
		self.initializing = nil
	
	--> scan pets
		_detalhes:SchedulePetUpdate (1)
	
	--> send messages gathered on initialization
		self:ScheduleTimer ("ShowDelayMsg", 10) 
	
	--> send instance open signal
		for index, instancia in _detalhes:ListInstances() do
			if (instancia.ativa) then
				self:SendEvent ("DETAILS_INSTANCE_OPEN", nil, instancia)
			end
		end

	--> send details startup done signal
		function self:AnnounceStartup()
			
			self:SendEvent ("DETAILS_STARTED", "SEND_TO_ALL")
			
			if (_detalhes.in_group) then
				_detalhes:SendEvent ("GROUP_ONENTER")
			else
				_detalhes:SendEvent ("GROUP_ONLEAVE")
			end
			
			_detalhes.last_zone_type = "INIT"
			_detalhes.parser_functions:ZONE_CHANGED_NEW_AREA()
			
			_detalhes.AnnounceStartup = nil

		end
		self:ScheduleTimer ("AnnounceStartup", 5)
		
		if (_detalhes.failed_to_load) then
			_detalhes:CancelTimer (_detalhes.failed_to_load)
			_detalhes.failed_to_load = nil
		end
		
		--function self:RunAutoHideMenu()
		--	local lower_instance = _detalhes:GetLowerInstanceNumber()
		--	local instance = self:GetInstance (lower_instance)
		--	instance:SetAutoHideMenu (nil, nil, true)
		--end
		--self:ScheduleTimer ("RunAutoHideMenu", 15)
		
	--> announce alpha version
		function self:AnnounceVersion()
			for index, instancia in _detalhes:ListInstances() do
				if (instancia.ativa) then
					self.gump:Fade (instancia._version, "in", 0.1)
				end
			end
		end
		
	--> check version
		_detalhes:CheckVersion (true)
		
	--> restore cooltip anchor position
		DetailsTooltipAnchor:Restore()
	
	--> check is this is the first run
		if (self.is_first_run) then
			if (#self.custom == 0) then
				_detalhes:AddDefaultCustomDisplays()
			end
			
			_detalhes:FillUserCustomSpells()
		end
		
	--> send feedback panel if the user got 100 or more logons with details
		if (self.tutorial.logons > 100) then --  and self.tutorial.logons < 104
			if (not self.tutorial.feedback_window1) then
				--> check if isn't inside an instance
				if (_detalhes:IsInCity()) then
					self.tutorial.feedback_window1 = true
					_detalhes:ShowFeedbackRequestWindow()
				end
			end
		end
	
	--> check is this is the first run of this version
		if (self.is_version_first_run) then

			local enable_reset_warning = true
		
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			if (lower_instance) then
				lower_instance = _detalhes:GetInstance (lower_instance)
				if (lower_instance and _detalhes.latest_news_saw ~= _detalhes.userversion) then
					lower_instance:InstanceAlert (Loc ["STRING_VERSION_UPDATE"], {[[Interface\GossipFrame\AvailableQuestIcon]], 16, 16, false}, 60, {_detalhes.OpenNewsWindow})
				end
			end
			
			_detalhes:FillUserCustomSpells()
			_detalhes:AddDefaultCustomDisplays()
			
			--> erase the custom for damage taken by spell
			if (_detalhes_database.last_realversion and _detalhes_database.last_realversion < 75 and enable_reset_warning) then
				if (_detalhes.global_plugin_database and _detalhes.global_plugin_database ["DETAILS_PLUGIN_ENCOUNTER_DETAILS"]) then
					wipe (_detalhes.global_plugin_database ["DETAILS_PLUGIN_ENCOUNTER_DETAILS"].encounter_timers_dbm)
					wipe (_detalhes.global_plugin_database ["DETAILS_PLUGIN_ENCOUNTER_DETAILS"].encounter_timers_bw)
				end
			end
			
			if (_detalhes_database.last_realversion and _detalhes_database.last_realversion < 74 and enable_reset_warning) then
				function _detalhes:FixMonkSpecIcons()
					local m269 = _detalhes.class_specs_coords [269]
					local m270 = _detalhes.class_specs_coords [270]
					
					m269[1], m269[2], m269[3], m269[4] = 448/512, 512/512, 64/512, 128/512
					m270[1], m270[2], m270[3], m270[4] = 384/512, 448/512, 64/512, 128/512
				end
				_detalhes:ScheduleTimer ("FixMonkSpecIcons", 1)
			end
			
			if (_detalhes_database.last_realversion and _detalhes_database.last_realversion < 73 and enable_reset_warning) then
			
				local secure_func = function()
					for i = #_detalhes.custom, 1, -1 do
						local index = i
						local CustomObject = _detalhes.custom [index]
						
						if (CustomObject:GetName() == Loc ["STRING_CUSTOM_DTBS"]) then
							for o = 1, _detalhes.switch.slots do
								local options = _detalhes.switch.table [o]
								if (options and options.atributo == 5 and options.sub_atributo == index) then 
									options.atributo = 1
									options.sub_atributo = 8
									_detalhes.switch:Update()
								end
							end
						
							_detalhes.atributo_custom:RemoveCustom (index)
						end
					end
				end
				pcall (secure_func)
				
			end
			
			if (_detalhes_database.last_realversion and _detalhes_database.last_realversion < 70 and enable_reset_warning) then
				local bg = _detalhes.tooltip.background
				bg [1] = 0.1960
				bg [2] = 0.1960
				bg [3] = 0.1960
				bg [4] = 0.8697
				
				local border = _detalhes.tooltip.border_color
				border [1] = 1
				border [2] = 1
				border [3] = 1
				border [4] = 0
				
				--> refresh
				_detalhes:SetTooltipBackdrop()
			end
			
			--> check elvui for the new player detail skin
			if (_detalhes_database.last_realversion and _detalhes_database.last_realversion < 71 and enable_reset_warning) then
				function _detalhes:PDWElvuiCheck()
					_detalhes:ApplyPDWSkin ("ElvUI")
					
					_detalhes.class_specs_coords[62][1] = (128/512) + 0.001953125
					_detalhes.class_specs_coords[70][1] = (128/512) + 0.001953125
					_detalhes.class_specs_coords[258][1] = (320/512) + 0.001953125
				end
				_detalhes:ScheduleTimer ("PDWElvuiCheck", 2)
			end
			
			if (_detalhes_database.last_realversion and _detalhes_database.last_realversion < 69 and enable_reset_warning) then
				function _detalhes:PDWElvuiCheck()
					local ElvUI = _G.ElvUI
					if (ElvUI) then
						_detalhes:ApplyPDWSkin ("ElvUI")
					end
				end
				_detalhes:ScheduleTimer ("PDWElvuiCheck", 1)
			end
			
			--> Reset for the new structure
			if (_detalhes_database.last_realversion and _detalhes_database.last_realversion < 66 and enable_reset_warning) then
				function _detalhes:ResetDataStorage()
					if (not IsAddOnLoaded ("Details_DataStorage")) then
						local loaded, reason = LoadAddOn ("Details_DataStorage")
						if (not loaded) then
							return
						end
					end
					
					local db = DetailsDataStorage
					if (db) then
						table.wipe (db)
					end
					
					DetailsDataStorage = _detalhes:CreateStorageDB()
				end
				_detalhes:ScheduleTimer ("ResetDataStorage", 1)
				
				_detalhes.segments_panic_mode = false
				
			end

			if (_detalhes_database.last_realversion and _detalhes_database.last_realversion < 47 and enable_reset_warning) then
				for i = #_detalhes.custom, 1, -1  do
					_detalhes.atributo_custom:RemoveCustom (i)
				end
				_detalhes:AddDefaultCustomDisplays()
			end

		end
	
	local lower = _detalhes:GetLowerInstanceNumber()
	if (lower) then
		local instance = _detalhes:GetInstance (lower)
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
			
			if (self.tutorial.logons < 50) then
				--dev_text:SetText ("Details is Under\nDevelopment")
				--dev_icon:SetTexture ([[Interface\DialogFrame\UI-Dialog-Icon-AlertOther]])
			end
		
			--version
			self.gump:Fade (instance._version, 0)
			instance._version:SetText ("Details! " .. _detalhes.userversion .. " (core " .. self.realversion .. ")")
			instance._version:SetTextColor (1, 1, 1, .35)
			instance._version:SetPoint ("bottomleft", instance.baseframe, "bottomleft", 5, 1)

			if (instance.auto_switch_to_old) then
				instance:SwitchBack()
			end

			function _detalhes:FadeStartVersion()
				_detalhes.gump:Fade (dev_icon, "in", 2)
				_detalhes.gump:Fade (dev_text, "in", 2)
				self.gump:Fade (instance._version, "in", 2)
				
				if (_detalhes.switch.table) then
				
					local have_bookmark
					
					for index, t in ipairs (_detalhes.switch.table) do
						if (t.atributo) then
							have_bookmark = true
							break
						end
					end
					
					if (not have_bookmark) then
						function _detalhes:WarningAddBookmark()
							instance._version:SetText ("right click to set bookmarks.")
							self.gump:Fade (instance._version, "out", 1)
							function _detalhes:FadeBookmarkWarning()
								self.gump:Fade (instance._version, "in", 2)
							end
							_detalhes:ScheduleTimer ("FadeBookmarkWarning", 5)
						end
						_detalhes:ScheduleTimer ("WarningAddBookmark", 2)
					end
				end
				
			end
			
			_detalhes:ScheduleTimer ("FadeStartVersion", 12)
			
		end
	end
	
	function _detalhes:OpenOptionsWindowAtStart()
		--_detalhes:OpenOptionsWindow (_detalhes.tabela_instancias[1])
		--print (_G ["DetailsClearSegmentsButton1"]:GetSize())
		--_detalhes:OpenCustomDisplayWindow()
		--_detalhes:OpenWelcomeWindow()
	end
	_detalhes:ScheduleTimer ("OpenOptionsWindowAtStart", 2)
	--_detalhes:OpenCustomDisplayWindow()
	
	--> minimap
	pcall (_detalhes.RegisterMinimap, _detalhes)
	
	--> hot corner
	function _detalhes:RegisterHotCorner()
		_detalhes:DoRegisterHotCorner()
	end
	_detalhes:ScheduleTimer ("RegisterHotCorner", 5)
	
	--> get in the realm chat channel
	if (not _detalhes.schedule_chat_enter and not _detalhes.schedule_chat_leave) then
		_detalhes:ScheduleTimer ("CheckChatOnZoneChange", 60)
	end

	--> open profiler 
	_detalhes:OpenProfiler()
	
	--> start announcers
	_detalhes:StartAnnouncers()
	
	--> start aura
	_detalhes:CreateAuraListener()
	
	--> open welcome
	if (self.is_first_run) then
		_detalhes:OpenWelcomeWindow()
	end
	
	--_detalhes:OpenWelcomeWindow() --debug
	-- /run _detalhes:OpenWelcomeWindow()
	
	_detalhes:BrokerTick()
	
	--boss mobs callbacks
	_detalhes:ScheduleTimer ("BossModsLink", 5)
	
	--> limit item level life for 24Hs
	local now = time()
	for guid, t in pairs (_detalhes.item_level_pool) do
		if (t.time+86400 < now) then
			_detalhes.item_level_pool [guid] = nil
		end
	end
	
	--> dailly reset of the cache for talents and specs.
	local today = date ("%d")
	if (_detalhes.last_day ~= today) then
		wipe (_detalhes.cached_specs)
		wipe (_detalhes.cached_talents)
	end

	--> get the player spec
	C_Timer.After (2, _detalhes.parser_functions.PLAYER_SPECIALIZATION_CHANGED)

	_detalhes.chat_embed:CheckChatEmbed (true)
	
	--_detalhes:SetTutorialCVar ("MEMORY_USAGE_ALERT1", false)
	if (not _detalhes:GetTutorialCVar ("MEMORY_USAGE_ALERT1")) then
		function _detalhes:AlertAboutMemoryUsage()
			if (DetailsWelcomeWindow and DetailsWelcomeWindow:IsShown()) then
				return _detalhes:ScheduleTimer ("AlertAboutMemoryUsage", 30)
			end
			
			local f = _detalhes.gump:CreateSimplePanel (UIParent, 500, 290, Loc ["STRING_MEMORY_ALERT_TITLE"], "AlertAboutMemoryUsagePanel", {NoTUISpecialFrame = true, DontRightClickClose = true})
			f:SetPoint ("center", UIParent, "center", -200, 100)
			f.Close:Hide()
			_detalhes:SetFontColor (f.Title, "yellow")
			
			local gnoma = _detalhes.gump:CreateImage (f.TitleBar, [[Interface\AddOns\Details\images\icons2]], 104, 107, "overlay", {104/512, 0, 405/512, 1})
			gnoma:SetPoint ("topright", 0, 14)
			
			local logo = _detalhes.gump:CreateImage (f, [[Interface\AddOns\Details\images\logotipo]])
			logo:SetPoint ("topleft", -5, 15)
			logo:SetSize (512*0.4, 256*0.4)
			
			local text1 = Loc ["STRING_MEMORY_ALERT_TEXT1"]
			local text2 = Loc ["STRING_MEMORY_ALERT_TEXT2"]
			local text3 = Loc ["STRING_MEMORY_ALERT_TEXT3"]
			
			local str1 = _detalhes.gump:CreateLabel (f, text1)
			str1.width = 480
			str1.fontsize = 12
			str1:SetPoint ("topleft", 10, -100)
			
			local str2 = _detalhes.gump:CreateLabel (f, text2)
			str2.width = 480
			str2.fontsize = 12
			str2:SetPoint ("topleft", 10, -150)
			
			local str3 = _detalhes.gump:CreateLabel (f, text3)
			str3.width = 480
			str3.fontsize = 12
			str3:SetPoint ("topleft", 10, -200)
			
			local textbox = _detalhes.gump:CreateTextEntry (f, function()end, 350, 20, nil, nil, nil, _detalhes.gump:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			textbox:SetPoint ("topleft", 10, -250)
			textbox:SetText ([[www.curse.com/addons/wow/addons-cpu-usage]])
			textbox:SetHook ("OnEditFocusGained", function() textbox:HighlightText() end)
			
			local close_func = function()
				_detalhes:SetTutorialCVar ("MEMORY_USAGE_ALERT1", true)
				f:Hide()
			end
			local close = _detalhes.gump:CreateButton (f, close_func, 127, 20, Loc ["STRING_MEMORY_ALERT_BUTTON"], nil, nil, nil, nil, nil, nil, _detalhes.gump:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
			close:SetPoint ("left", textbox, "right", 2, 0)
			
		end
		_detalhes:ScheduleTimer ("AlertAboutMemoryUsage", 30) --30
	end
	
	_detalhes.AddOnStartTime = GetTime()
	
	--_detalhes.player_details_window.skin = "ElvUI"
	if (_detalhes.player_details_window.skin ~= "ElvUI") then
		local reset_player_detail_window = function()
			_detalhes:ApplyPDWSkin ("ElvUI")
		end
		C_Timer.After (2, reset_player_detail_window)
	end
	
	_detalhes.tooltip.tooltip_max_abilities = 5
end

_detalhes.AddOnLoadFilesTime = GetTime()
