
--> check unloaded files:
if (
	-- version 1.21.0
	not _G._detalhes.atributo_custom.damagedoneTooltip or
	not _G._detalhes.atributo_custom.damagetakenTooltip or
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
			self.row_singleclick_overwrite [1] = {true, true, true, true, self.atributo_damage.ReportSingleFragsLine, true, self.atributo_damage.ReportSingleVoidZoneLine} 
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
				self.switch:InitSwitch()
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
		self:CheckConsolidates()
		
	--> start time machine
		self.timeMachine:Ligar()
	
	--> update abbreviation shortcut
	
		self.atributo_damage:UpdateSelectedToKFunction()
		self.atributo_heal:UpdateSelectedToKFunction()
		self.atributo_energy:UpdateSelectedToKFunction()
		self.atributo_misc:UpdateSelectedToKFunction()
		self.atributo_custom:UpdateSelectedToKFunction()
		
	--> start instances updater
	
		_detalhes:CheckSwitchOnLogon()
	
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
					end
				end
			end
			
			_detalhes.ToolBar:ReorganizeIcons() --> refresh all skin
		
			self.RefreshAfterStartup = nil
			
			function _detalhes:CheckWallpaperAfterStartup()
				for _, instance in ipairs (self.tabela_instancias) do
					if (not instance.wallpaper.enabled) then
						if (instance:IsAtiva()) then
							instance:InstanceWallpaper (false)
						end
					end
					if (instance:IsEnabled()) then
						_detalhes.move_janela_func (instance.baseframe, true, instance)
						_detalhes.move_janela_func (instance.baseframe, false, instance)
					end
				end
				self.CheckWallpaperAfterStartup = nil
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
		
	--> start tutorial if this is first run
		if (self.tutorial.logons < 2 and self.is_first_run) then
			self:StartTutorial()
		end
	
	--> send feedback panel if the user got 100 or more logons with details
		if (self.tutorial.logons > 100) then --  and self.tutorial.logons < 104
			if (not self.tutorial.feedback_window1) then
				self.tutorial.feedback_window1 = true
				_detalhes:ShowFeedbackRequestWindow()
			end
		end
	
	--> check is this is the first run of this version
		if (self.is_version_first_run) then
		
			local enable_reset_warning = true
		
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			if (lower_instance) then
				lower_instance = _detalhes:GetInstance (lower_instance)
				if (lower_instance) then
					lower_instance:InstanceAlert (Loc ["STRING_VERSION_UPDATE"], {[[Interface\GossipFrame\AvailableQuestIcon]], 16, 16, false}, 60, {_detalhes.OpenNewsWindow})
				end
			end
			
			_detalhes:FillUserCustomSpells()
			
			if (_detalhes_database.last_realversion and _detalhes_database.last_realversion < 20 and enable_reset_warning) then
				table.wipe (self.custom)
				_detalhes:AddDefaultCustomDisplays()
			end
			
			if (_detalhes_database.last_realversion and _detalhes_database.last_realversion < 18 and enable_reset_warning) then
				
				for index, instance in ipairs (_detalhes.tabela_instancias) do 
					if (not instance.iniciada) then
						instance:RestauraJanela()
						local skin = instance.skin
						instance:ChangeSkin ("Default Skin")
						instance:ChangeSkin ("Minimalistic")
						instance:ChangeSkin (skin)
						instance:DesativarInstancia()
					else
						local skin = instance.skin
						instance:ChangeSkin ("Default Skin")
						instance:ChangeSkin ("Minimalistic")
						instance:ChangeSkin (skin)
					end
				end
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
			dev_icon:SetTexture ([[Interface\DialogFrame\UI-Dialog-Icon-AlertOther]])
			dev_icon:SetAlpha (.3)
			
			local dev_text = instance.bgdisplay:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
			dev_text:SetHeight (64)
			dev_text:SetPoint ("left", dev_icon, "right", 5, 0)
			dev_text:SetTextColor (1, 1, 1)
			dev_text:SetText ("Details is Under\nDevelopment")
			dev_text:SetAlpha (.3)
		
			--version
			self.gump:Fade (instance._version, 0)
			instance._version:SetText ("Details! Alpha " .. _detalhes.userversion .. " (core: " .. self.realversion .. ")")
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
	
	--> minimap
		_detalhes:RegisterMinimapAndHotCorner()

		
	function _detalhes:OpenOptionsWindowAtStart()
		--_detalhes:OpenOptionsWindow (_detalhes.tabela_instancias[1])
		--print (_G ["DetailsClearSegmentsButton1"]:GetSize())
		--_detalhes:OpenCustomDisplayWindow()
		--_detalhes:OpenWelcomeWindow()
	end
	_detalhes:ScheduleTimer ("OpenOptionsWindowAtStart", 2)
	--_detalhes:OpenCustomDisplayWindow()
	
	--BNSendFriendInvite ("tercio#1488")

	if (not _detalhes.schedule_chat_enter and not _detalhes.schedule_chat_leave) then
		_detalhes.schedule_chat_enter = _detalhes:ScheduleTimer ("EnterChatChannel", 30)
	end

	_detalhes:OpenProfiler()
	
	if (self.is_first_run) then
		_detalhes:OpenWelcomeWindow()
	end
	
end

