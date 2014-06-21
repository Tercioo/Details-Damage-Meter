--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.

function _G._detalhes:Start()

	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details defaults

	--> single click row function replace
		--damage, dps, damage taken, friendly fire
			self.row_singleclick_overwrite [1] = {true, true, true, true, self.atributo_damage.ReportSingleFragsLine, true, self.atributo_damage.ReportSingleVoidZoneLine} 
		--healing, hps, overheal, healing taken
			self.row_singleclick_overwrite [2] = {true, true, true, true, false, self.atributo_heal.ReportSingleDamagePreventedLine} 
		--mana, rage, energy, runepower
			self.row_singleclick_overwrite [3] = {true, true, true, true} 
		--cc breaks, ress, interrupts, dispells, deaths
			self.row_singleclick_overwrite [4] = {true, true, true, true, self.atributo_misc.ReportSingleDeadLine, self.atributo_misc.ReportSingleCooldownLine, self.atributo_misc.ReportSingleBuffUptimeLine, self.atributo_misc.ReportSingleDebuffUptimeLine} 
		
		self.click_to_report_color = {1, 0.8, 0, 1}
		
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> initialize

	--> build frames

		--> fast switch
			if (self.switch.InitSwitch) then
				self.switch:InitSwitch()
			end
			
		--> custom window
			self.custom = self.custom or {}
			--self:InitCustom()
			
		--> actor info
			self.janela_info = self.gump:CriaJanelaInfo()
			self.gump:Fade (self.janela_info, 1)
			
		--> copy and paste window
			self:CreateCopyPasteWindow()
			self.CreateCopyPasteWindow = nil
			
	--> start instances
	
		if (self:QuantasInstancias() == 0) then
			self:CriarInstancia()
		end
		self:GetLowerInstanceNumber()
		self:CheckConsolidates()
		
	--> start time machine
	
		self.timeMachine:Ligar()
	
	--> update abbreviation shorcut
	
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
		for index, instancia in ipairs (self.tabela_instancias) do
			if (instancia.ativa) then
				self:SendEvent ("DETAILS_INSTANCE_OPEN", nil, instancia)
			end
		end

	--> send details startup done signal
		function self:AnnounceStartup()
			self:SendEvent ("DETAILS_STARTED", "SEND_TO_ALL")
		end
		self:ScheduleTimer ("AnnounceStartup", 5)
		
	--> announce alpha version
		function self:AnnounceVersion()
			for index, instancia in ipairs (self.tabela_instancias) do
				if (instancia.ativa) then
					self.gump:Fade (instancia._version, "in", 0.1)
				end
			end
		end
		
	--> restore cooltip anchor position
		DetailsTooltipAnchor:Restore()
	
	--> check is this is the first run
		if (self.is_first_run) then
			_detalhes:OpenWelcomeWindow()
			
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
			
				local feedback_frame = CreateFrame ("FRAME", "DetailsFeedbackWindow", UIParent, "ButtonFrameTemplate")
				tinsert (UISpecialFrames, "DetailsFeedbackWindow")
				feedback_frame:SetPoint ("center", UIParent, "center")
				feedback_frame:SetSize (512, 200)
				feedback_frame.portrait:SetTexture ([[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT-FEMALE-GNOME]])
				
				feedback_frame.TitleText:SetText ("Details! Need Your Help!")
				
				feedback_frame.uppertext = feedback_frame:CreateFontString (nil, "artwork", "GameFontNormal")
				feedback_frame.uppertext:SetText ("Tell us about your experience using Details!, what you liked most, where we could improve, what things you want to see in the future?")
				feedback_frame.uppertext:SetPoint ("topleft", feedback_frame, "topleft", 60, -32)
				local font, _, flags = feedback_frame.uppertext:GetFont()
				feedback_frame.uppertext:SetFont (font, 10, flags)
				feedback_frame.uppertext:SetTextColor (1, 1, 1, .8)
				feedback_frame.uppertext:SetWidth (440)
				
			
				local editbox = _detalhes.gump:NewTextEntry (feedback_frame, nil, "$parentTextEntry", "text", 387, 14)
				editbox:SetPoint (20, -106)
				editbox:SetAutoFocus (false)
				editbox:SetHook ("OnEditFocusGained", function() 
					editbox.text = "http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks" 
					editbox:HighlightText()
				end)
				editbox:SetHook ("OnEditFocusLost", function() 
					editbox.text = "http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks" 
					editbox:HighlightText()
				end)
				editbox:SetHook ("OnChar", function() 
					editbox.text = "http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks"
					editbox:HighlightText()
				end)
				editbox.text = "http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks"
				
				
				feedback_frame.midtext = feedback_frame:CreateFontString (nil, "artwork", "GameFontNormal")
				feedback_frame.midtext:SetText ("visit the link above and let's make Details! stronger!")
				feedback_frame.midtext:SetPoint ("center", editbox.widget, "center")
				feedback_frame.midtext:SetPoint ("top", editbox.widget, "bottom", 0, -2)
				feedback_frame.midtext:SetJustifyH ("center")
				local font, _, flags = feedback_frame.midtext:GetFont()
				feedback_frame.midtext:SetFont (font, 10, flags)
				--feedback_frame.midtext:SetTextColor (1, 1, 1, 1)
				feedback_frame.midtext:SetWidth (440)
				
				
				feedback_frame.gnoma = feedback_frame:CreateTexture (nil, "artwork")
				feedback_frame.gnoma:SetPoint ("topright", feedback_frame, "topright", -1, -59)
				feedback_frame.gnoma:SetTexture ("Interface\\AddOns\\Details\\images\\icons2")
				feedback_frame.gnoma:SetSize (105*1.05, 107*1.05)
				feedback_frame.gnoma:SetTexCoord (0.2021484375, 0, 0.7919921875, 1)

				feedback_frame.close = CreateFrame ("Button", "DetailsFeedbackWindowCloseButton", feedback_frame, "OptionsButtonTemplate")
				feedback_frame.close:SetPoint ("bottomleft", feedback_frame, "bottomleft", 8, 4)
				feedback_frame.close:SetText ("Close")
				feedback_frame.close:SetScript ("OnClick", function (self)
					editbox:ClearFocus()
					feedback_frame:Hide()
				end)
				
				feedback_frame.postpone = CreateFrame ("Button", "DetailsFeedbackWindowPostPoneButton", feedback_frame, "OptionsButtonTemplate")
				feedback_frame.postpone:SetPoint ("bottomright", feedback_frame, "bottomright", -10, 4)
				feedback_frame.postpone:SetText ("Remind-me Later")
				feedback_frame.postpone:SetScript ("OnClick", function (self)
					editbox:ClearFocus()
					feedback_frame:Hide()
					_detalhes.tutorial.feedback_window1 = false
				end)
				feedback_frame.postpone:SetWidth (130)
				
				feedback_frame:SetScript ("OnHide", function() 
					editbox:ClearFocus()
				end)
				
				--0.0009765625 512
				function _detalhes:FeedbackSetFocus()
					DetailsFeedbackWindow:Show()
					DetailsFeedbackWindowTextEntry.MyObject:SetFocus()
					DetailsFeedbackWindowTextEntry.MyObject:HighlightText()
				end
				_detalhes:ScheduleTimer ("FeedbackSetFocus", 5)
			
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
				
				--print ("Last Version:", _detalhes_database.last_version, "Last Interval Version:", _detalhes_database.last_realversion)

				local resetwarning_frame = CreateFrame ("FRAME", "DetailsResetConfigWarningDialog", UIParent, "ButtonFrameTemplate")
				resetwarning_frame:SetFrameStrata ("LOW")
				tinsert (UISpecialFrames, "DetailsResetConfigWarningDialog")
				resetwarning_frame:SetPoint ("center", UIParent, "center")
				resetwarning_frame:SetSize (512, 200)
				resetwarning_frame.portrait:SetTexture ([[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT-FEMALE-GNOME]])
				resetwarning_frame:SetScript ("OnHide", function()
					DetailsBubble:HideBubble()
				end)
				
				resetwarning_frame.TitleText:SetText ("Noooooooooooo!!!")

				resetwarning_frame.midtext = resetwarning_frame:CreateFontString (nil, "artwork", "GameFontNormal")
				resetwarning_frame.midtext:SetText ("A pack of murlocs has attacked Details! tech center, our gnomes engineers are working on fixing the damage.\n\n If something is messed in your Details!, especially the close, instance and reset buttons, you can either 'Reset Skin' or access the options panel.")
				resetwarning_frame.midtext:SetPoint ("topleft", resetwarning_frame, "topleft", 10, -90)
				resetwarning_frame.midtext:SetJustifyH ("center")
				resetwarning_frame.midtext:SetWidth (370)
				
				resetwarning_frame.gnoma = resetwarning_frame:CreateTexture (nil, "artwork")
				resetwarning_frame.gnoma:SetPoint ("topright", resetwarning_frame, "topright", -3, -80)
				resetwarning_frame.gnoma:SetTexture ("Interface\\AddOns\\Details\\images\\icons2")
				resetwarning_frame.gnoma:SetSize (89*1.00, 97*1.00)
				--resetwarning_frame.gnoma:SetTexCoord (0.212890625, 0.494140625, 0.798828125, 0.99609375) -- 109 409 253 510
				resetwarning_frame.gnoma:SetTexCoord (0.17578125, 0.001953125, 0.59765625, 0.787109375) -- 1 306 90 403
				
				resetwarning_frame.close = CreateFrame ("Button", "DetailsFeedbackWindowCloseButton", resetwarning_frame, "OptionsButtonTemplate")
				resetwarning_frame.close:SetPoint ("bottomleft", resetwarning_frame, "bottomleft", 8, 4)
				resetwarning_frame.close:SetText ("Close")
				resetwarning_frame.close:SetScript ("OnClick", function (self)
					resetwarning_frame:Hide()
				end)
			
				resetwarning_frame.see_updates = CreateFrame ("Button", "DetailsResetWindowSeeUpdatesButton", resetwarning_frame, "OptionsButtonTemplate")
				resetwarning_frame.see_updates:SetPoint ("bottomright", resetwarning_frame, "bottomright", -10, 4)
				resetwarning_frame.see_updates:SetText ("Update Info")
				resetwarning_frame.see_updates:SetScript ("OnClick", function (self)
					_detalhes.OpenNewsWindow()
					DetailsBubble:HideBubble()
					--resetwarning_frame:Hide()
				end)
				resetwarning_frame.see_updates:SetWidth (130)
				
				resetwarning_frame.reset_skin = CreateFrame ("Button", "DetailsResetWindowResetSkinButton", resetwarning_frame, "OptionsButtonTemplate")
				resetwarning_frame.reset_skin:SetPoint ("right", resetwarning_frame.see_updates, "left", -5, 0)
				resetwarning_frame.reset_skin:SetText ("Reset Skin")
				resetwarning_frame.reset_skin:SetScript ("OnClick", function (self)
					--do the reset
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
				end)
				resetwarning_frame.reset_skin:SetWidth (130)
				
				resetwarning_frame.open_options = CreateFrame ("Button", "DetailsResetWindowOpenOptionsButton", resetwarning_frame, "OptionsButtonTemplate")
				resetwarning_frame.open_options:SetPoint ("right", resetwarning_frame.reset_skin, "left", -5, 0)
				resetwarning_frame.open_options:SetText ("Options Panel")
				resetwarning_frame.open_options:SetScript ("OnClick", function (self)
					local lower_instance = _detalhes:GetLowerInstanceNumber()
					if (not lower_instance) then
						local instance = _detalhes:GetInstance (1)
						_detalhes.CriarInstancia (_, _, 1)
						_detalhes:OpenOptionsWindow (instance)
					else
						_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
					end
				end)
				resetwarning_frame.open_options:SetWidth (130)
			
				function _detalhes:ResetWarningDialog()
					DetailsResetConfigWarningDialog:Show()
					DetailsBubble:SetOwner (resetwarning_frame.gnoma, "bottomright", "topleft", 30, -37, 1)
					DetailsBubble:FlipHorizontal()
					DetailsBubble:SetBubbleText ("", "", "WWHYYYYYYYYY!!!!", "", "")
					DetailsBubble:TextConfig (14, nil, "deeppink")
					DetailsBubble:ShowBubble()


				end
				_detalhes:ScheduleTimer ("ResetWarningDialog", 7)
				
			end
		end
	
	--> interface menu
	local f = CreateFrame ("frame", "DetailsInterfaceOptionsPanel", UIParent)
	f.name = "Details"
	f.logo = f:CreateTexture (nil, "overlay")
	f.logo:SetPoint ("center", f, "center", 0, 0)
	f.logo:SetPoint ("top", f, "top", 25, 56)
	f.logo:SetTexture ([[Interface\AddOns\Details\images\logotipo]])
	f.logo:SetSize (256, 128)
	InterfaceOptions_AddCategory (f)
	
		--> open options panel
		f.options_button = CreateFrame ("button", nil, f, "OptionsButtonTemplate")
		f.options_button:SetText (Loc ["STRING_INTERFACE_OPENOPTIONS"])
		f.options_button:SetPoint ("topleft", f, "topleft", 10, -100)
		f.options_button:SetWidth (170)
		f.options_button:SetScript ("OnClick", function (self)
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
		end)
		
		--> create new window
		f.new_window_button = CreateFrame ("button", nil, f, "OptionsButtonTemplate")
		f.new_window_button:SetText (Loc ["STRING_MINIMAPMENU_NEWWINDOW"])
		f.new_window_button:SetPoint ("topleft", f, "topleft", 10, -125)
		f.new_window_button:SetWidth (170)
		f.new_window_button:SetScript ("OnClick", function (self)
			_detalhes:CriarInstancia (_, true)
		end)
	
	--> MicroButtonAlertTemplate
	self.MicroButtonAlert = CreateFrame ("frame", "DetailsMicroButtonAlert", UIParent, "MicroButtonAlertTemplate")
	self.MicroButtonAlert:Hide()

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
			end
			
			_detalhes:ScheduleTimer ("FadeStartVersion", 12)
			
		end
	end	
	
	--> minimap
	local LDB = LibStub ("LibDataBroker-1.1", true)
	local LDBIcon = LDB and LibStub ("LibDBIcon-1.0", true)
	
	if LDB then

		local databroker = LDB:NewDataObject ("Details!", {
			type = "launcher",
			icon = [[Interface\AddOns\Details\images\minimap]],
			text = "0",
			
			HotCornerIgnore = true,
			
			OnClick = function (self, button)
			
				if (button == "LeftButton") then
				
					--> 1 = open options panel
					if (_detalhes.minimap.onclick_what_todo == 1) then
						local lower_instance = _detalhes:GetLowerInstanceNumber()
						if (not lower_instance) then
							local instance = _detalhes:GetInstance (1)
							_detalhes.CriarInstancia (_, _, 1)
							_detalhes:OpenOptionsWindow (instance)
						else
							_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
						end
					
					--> 2 = reset data
					elseif (_detalhes.minimap.onclick_what_todo == 2) then
						_detalhes.tabela_historico:resetar()
					
					--> 3 = unknown
					elseif (_detalhes.minimap.onclick_what_todo == 3) then
					
					end
					
				elseif (button == "RightButton") then
				
					GameTooltip:Hide()
					local GameCooltip = GameCooltip
					
					GameCooltip:Reset()
					GameCooltip:SetType ("menu")
					GameCooltip:SetOption ("ButtonsYMod", -5)
					GameCooltip:SetOption ("HeighMod", 5)
					GameCooltip:SetOption ("TextSize", 10)

					--344 427 200 268 0.0009765625
					--0.672851, 0.833007, 0.391601, 0.522460
					
					GameCooltip:SetBannerImage (1, [[Interface\AddOns\Details\images\icons]], 83*.5, 68*.5, {"bottomleft", "topleft", 1, -4}, {0.672851, 0.833007, 0.391601, 0.522460}, nil)
					GameCooltip:SetBannerImage (2, "Interface\\PetBattles\\Weather-Windy", 512*.35, 128*.3, {"bottomleft", "topleft", -25, -4}, {0, 1, 1, 0})
					GameCooltip:SetBannerText (1, "Mini Map Menu", {"left", "right", 2, -5}, "white", 10)
					
					--> reset
					GameCooltip:AddMenu (1, _detalhes.tabela_historico.resetar, true, nil, nil, Loc ["STRING_MINIMAPMENU_RESET"], nil, true)
					GameCooltip:AddIcon ([[Interface\COMMON\VOICECHAT-MUTED]], 1, 1, 14, 14)
					
					GameCooltip:AddLine ("$div")
					
					--> nova instancai
					GameCooltip:AddMenu (1, _detalhes.CriarInstancia, true, nil, nil, Loc ["STRING_MINIMAPMENU_NEWWINDOW"], nil, true)
					GameCooltip:AddIcon ([[Interface\ICONS\Spell_ChargePositive]], 1, 1, 14, 14, 0.0703125, 0.9453125, 0.0546875, 0.9453125)
					
					--> reopen window 64: 0.0078125
					local reopen = function()
						for _, instance in ipairs (_detalhes.tabela_instancias) do 
							if (not instance:IsAtiva()) then
								_detalhes:CriarInstancia (instance.meu_id)
								return
							end
						end
					end
					GameCooltip:AddMenu (1, reopen, nil, nil, nil, Loc ["STRING_MINIMAPMENU_REOPEN"], nil, true)
					GameCooltip:AddIcon ([[Interface\ICONS\Ability_Priest_VoidShift]], 1, 1, 14, 14, 0.0703125, 0.9453125, 0.0546875, 0.9453125)
					
					GameCooltip:AddMenu (1, _detalhes.ReabrirTodasInstancias, true, nil, nil, Loc ["STRING_MINIMAPMENU_REOPENALL"], nil, true)
					GameCooltip:AddIcon ([[Interface\ICONS\Ability_Priest_VoidShift]], 1, 1, 14, 14, 0.0703125, 0.9453125, 0.0546875, 0.9453125, "#ffb400")

					GameCooltip:AddLine ("$div")
					
					--> lock
					GameCooltip:AddMenu (1, _detalhes.TravasInstancias, true, nil, nil, Loc ["STRING_MINIMAPMENU_LOCK"], nil, true)
					GameCooltip:AddIcon ([[Interface\PetBattles\PetBattle-LockIcon]], 1, 1, 14, 14, 0.0703125, 0.9453125, 0.0546875, 0.9453125)
					
					GameCooltip:AddMenu (1, _detalhes.DestravarInstancias, true, nil, nil, Loc ["STRING_MINIMAPMENU_UNLOCK"], nil, true)
					GameCooltip:AddIcon ([[Interface\PetBattles\PetBattle-LockIcon]], 1, 1, 14, 14, 0.0703125, 0.9453125, 0.0546875, 0.9453125, "gray")
					
					GameCooltip:SetOwner (self, "topright", "bottomleft")
					GameCooltip:ShowCooltip()
					

				end
			end,
			OnTooltipShow = function (tooltip)
				tooltip:AddLine ("Details!", 1, 1, 1)
				if (_detalhes.minimap.onclick_what_todo == 1) then
					tooltip:AddLine (Loc ["STRING_MINIMAP_TOOLTIP1"])
				elseif (_detalhes.minimap.onclick_what_todo == 2) then
					tooltip:AddLine (Loc ["STRING_MINIMAP_TOOLTIP11"])
				end
				tooltip:AddLine (Loc ["STRING_MINIMAP_TOOLTIP2"])
			end,
		})
		
		if (databroker and not LDBIcon:IsRegistered ("Details!")) then
			LDBIcon:Register ("Details!", databroker, self.minimap)
		end
		
		_detalhes.databroker = databroker
		
	end

	--register lib-hotcorners
	local on_click_on_hotcorner_button = function (frame, button) 
		if (_detalhes.hotcorner_topleft.onclick_what_todo == 1) then
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			if (not lower_instance) then
				local instance = _detalhes:GetInstance (1)
				_detalhes.CriarInstancia (_, _, 1)
				_detalhes:OpenOptionsWindow (instance)
			else
				_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
			end
			
		elseif (_detalhes.hotcorner_topleft.onclick_what_todo == 2) then
			_detalhes.tabela_historico:resetar()
		end
	end
	
	local on_click_on_quickclick_button = function (frame, button) 
		if (_detalhes.hotcorner_topleft.quickclick_what_todo == 1) then
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			if (not lower_instance) then
				local instance = _detalhes:GetInstance (1)
				_detalhes.CriarInstancia (_, _, 1)
				_detalhes:OpenOptionsWindow (instance)
			else
				_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
			end
			
		elseif (_detalhes.hotcorner_topleft.quickclick_what_todo == 2) then
			_detalhes.tabela_historico:resetar()
		end
	end
	
	local tooltip_hotcorner = function()
		GameTooltip:AddLine ("Details!", 1, 1, 1, 1)
		if (_detalhes.hotcorner_topleft.onclick_what_todo == 1) then
			GameTooltip:AddLine ("|cFF00FF00Left Click:|r open options panel.", 1, 1, 1, 1)
			
		elseif (_detalhes.hotcorner_topleft.onclick_what_todo == 2) then
			GameTooltip:AddLine ("|cFF00FF00Left Click:|r clear all segments.", 1, 1, 1, 1)
			
		end
	end
	
	_detalhes:RegisterHotCornerButton (
		--> absolute name
		"Details!",
		--> corner
		"TOPLEFT", 
		--> config table
		self.hotcorner_topleft,
		--> frame _G name
		"DetailsLeftCornerButton", 
		--> icon
		[[Interface\AddOns\Details\images\minimap]], 
		--> tooltip
		tooltip_hotcorner,
		--> click function
		on_click_on_hotcorner_button, 
		--> menus
		nil, 
		--> quick click
		on_click_on_quickclick_button)
	
	--> register time captures
	--_detalhes:LoadUserTimeCaptures()
	
	--[[
	local f = CreateFrame ("frame", nil, UIParent)
	f:SetSize (200, 200)
	f:SetPoint ("center", UIParent, "center")
	local t = f:CreateTexture (nil, "overlay")
	t:SetPoint ("center", f, "center")
	t:SetTexture (1, 1, 1, 1)
	t:SetSize (100, 100)
	
	f:SetAlpha (.1)
	t:SetAlpha (1)
	t:SetVertexColor (1, 1, 1, 1)
	
	local b = CreateFrame ("button", "teste", f, "OptionsButtonTemplate")
	b:SetSize (75, 30)
	b:SetPoint ("left", f, "left")
	b:SetAlpha (1)
	--]]

	local panel = self.gump:NewPanel (UIParent, nil, "DetailsWindowOptionsBarTextEditor", nil, 650, 200)
	panel:SetPoint ("center", UIParent, "center")
	panel:Hide()
	panel:SetFrameStrata ("FULLSCREEN")
	panel:SetBackdrop ({	bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 64, edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=16, insets = {left=3, right=3, top=3, bottom=3}})
	panel:DisableGradient()
	panel:SetBackdropColor (0, 0, 0, 1)
	
	function panel.widget:Open (text, callback, host)
		if (host) then
			panel:SetPoint ("center", host, "center")
		end
		
		text = text:gsub ("||", "|")
		panel.default_text = text
		panel.widget.editbox:SetText (text)
		panel.callback = callback
		panel:Show()
	end
	
	local textentry = self.gump:NewSpecialLuaEditorEntry (panel.widget, 450, 180, "editbox", "$parentEntry", true)
	textentry:SetPoint ("topleft", panel.widget, "topleft", 10, -10)
	
	local arg1_button = self.gump:NewButton (panel, nil, "$parentButton1", nil, 80, 20, function() textentry.editbox:Insert ("{data1}") end, nil, nil, nil, "{data1}")
	local arg2_button = self.gump:NewButton (panel, nil, "$parentButton2", nil, 80, 20, function() textentry.editbox:Insert ("{data2}") end, nil, nil, nil, "{data2}")
	local arg3_button = self.gump:NewButton (panel, nil, "$parentButton3", nil, 80, 20, function() textentry.editbox:Insert ("{data3}") end, nil, nil, nil, "{data3}")
	arg1_button:SetPoint ("topright", panel, "topright", -10, -14)
	arg2_button:SetPoint ("topright", panel, "topright", -10, -36)
	arg3_button:SetPoint ("topright", panel, "topright", -10, -58)
	arg1_button:InstallCustomTexture()
	arg2_button:InstallCustomTexture()
	arg3_button:InstallCustomTexture()
	
	-- code author Saiket from  http://www.wowinterface.com/forums/showpost.php?p=245759&postcount=6
	--- @return StartPos, EndPos of highlight in this editbox.
	local function GetTextHighlight ( self )
		local Text, Cursor = self:GetText(), self:GetCursorPosition();
		self:Insert( "" ); -- Delete selected text
		local TextNew, CursorNew = self:GetText(), self:GetCursorPosition();
		-- Restore previous text
		self:SetText( Text );
		self:SetCursorPosition( Cursor );
		local Start, End = CursorNew, #Text - ( #TextNew - CursorNew );
		self:HighlightText( Start, End );
		return Start, End;
	end
      
	local StripColors;
	do
		local CursorPosition, CursorDelta;
		--- Callback for gsub to remove unescaped codes.
		local function StripCodeGsub ( Escapes, Code, End )
			if ( #Escapes % 2 == 0 ) then -- Doesn't escape Code
				if ( CursorPosition and CursorPosition >= End - 1 ) then
					CursorDelta = CursorDelta - #Code;
				end
				return Escapes;
			end
		end
		--- Removes a single escape sequence.
		local function StripCode ( Pattern, Text, OldCursor )
			CursorPosition, CursorDelta = OldCursor, 0;
			return Text:gsub( Pattern, StripCodeGsub ), OldCursor and CursorPosition + CursorDelta;
		end
		--- Strips Text of all color escape sequences.
		-- @param Cursor  Optional cursor position to keep track of.
		-- @return Stripped text, and the updated cursor position if Cursor was given.
		function StripColors ( Text, Cursor )
			Text, Cursor = StripCode( "(|*)(|c%x%x%x%x%x%x%x%x)()", Text, Cursor );
			return StripCode( "(|*)(|r)()", Text, Cursor );
		end
	end
	
	local COLOR_END = "|r";
	--- Wraps this editbox's selected text with the given color.
	local function ColorSelection ( self, ColorCode )
		local Start, End = GetTextHighlight( self );
		local Text, Cursor = self:GetText(), self:GetCursorPosition();
		if ( Start == End ) then -- Nothing selected
			--Start, End = Cursor, Cursor; -- Wrap around cursor
			return; -- Wrapping the cursor in a color code and hitting backspace crashes the client!
		end
		-- Find active color code at the end of the selection
		local ActiveColor;
		if ( End < #Text ) then -- There is text to color after the selection
			local ActiveEnd;
			local CodeEnd, _, Escapes, Color = 0;
			while ( true ) do
				_, CodeEnd, Escapes, Color = Text:find( "(|*)(|c%x%x%x%x%x%x%x%x)", CodeEnd + 1 );
				if ( not CodeEnd or CodeEnd > End ) then
					break;
				end
				if ( #Escapes % 2 == 0 ) then -- Doesn't escape Code
					ActiveColor, ActiveEnd = Color, CodeEnd;
				end
			end
       
			if ( ActiveColor ) then
				-- Check if color gets terminated before selection ends
				CodeEnd = 0;
				while ( true ) do
					_, CodeEnd, Escapes = Text:find( "(|*)|r", CodeEnd + 1 );
					if ( not CodeEnd or CodeEnd > End ) then
						break;
					end
					if ( CodeEnd > ActiveEnd and #Escapes % 2 == 0 ) then -- Terminates ActiveColor
						ActiveColor = nil;
						break;
					end
				end
			end
		end
     
		local Selection = Text:sub( Start + 1, End );
		-- Remove color codes from the selection
		local Replacement, CursorReplacement = StripColors( Selection, Cursor - Start );
     
		self:SetText( ( "" ):join(
			Text:sub( 1, Start ),
			ColorCode, Replacement, COLOR_END,
			ActiveColor or "", Text:sub( End + 1 )
		) );
     
		-- Restore cursor and highlight, adjusting for wrapper text
		Cursor = Start + CursorReplacement;
		if ( CursorReplacement > 0 ) then -- Cursor beyond start of color code
			Cursor = Cursor + #ColorCode;
		end
		if ( CursorReplacement >= #Replacement ) then -- Cursor beyond end of color
			Cursor = Cursor + #COLOR_END;
		end
		
		self:SetCursorPosition( Cursor );
		-- Highlight selection and wrapper
		self:HighlightText( Start, #ColorCode + ( #Replacement - #Selection ) + #COLOR_END + End );
	end
	
	local color_func = function (_, r, g, b, a)
		local hex = _detalhes:hex (a*255).._detalhes:hex (r*255).._detalhes:hex (g*255).._detalhes:hex (b*255)
		ColorSelection ( textentry.editbox, "|c" .. hex)
	end
	
	local func_button = self.gump:NewButton (panel, nil, "$parentButton4", nil, 80, 20, function() textentry.editbox:Insert ("{func local player = ...; return 0;}") end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_FUNC"])
	local color_button = self.gump:NewColorPickButton (panel, "$parentButton5", nil, color_func)
	color_button:SetSize (80, 20)
	func_button:SetPoint ("topright", panel, "topright", -10, -80)
	color_button:SetPoint ("topright", panel, "topright", -10, -102)
	func_button:InstallCustomTexture()
	
	color_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_COLOR_TOOLTIP"]
	func_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_FUNC_TOOLTIP"]
	
	--color_button:InstallCustomTexture()
	
	local comma_button = self.gump:NewButton (panel, nil, "$parentButtonComma", nil, 80, 20, function() textentry.editbox:Insert ("_detalhes:comma_value ( )") end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_COMMA"])
	local tok_button = self.gump:NewButton (panel, nil, "$parentButtonTok", nil, 80, 20, function() textentry.editbox:Insert ("_detalhes:ToK2 ( )") end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_TOK"])
	comma_button:InstallCustomTexture()
	tok_button:InstallCustomTexture()
	comma_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_COMMA_TOOLTIP"]
	tok_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_TOK_TOOLTIP"]
	
	comma_button:SetPoint ("topright", panel, "topright", -100, -14)
	tok_button:SetPoint ("topright", panel, "topright", -100, -36)
	
	local done = function()
		local text = panel.widget.editbox:GetText()
		text = text:gsub ("\n", "")
		
		local test = text
	
		local function errorhandler(err)
			return geterrorhandler()(err)
		end
	
		local code = [[local str = "STR"; str = str:ReplaceData (100, 50, 75, {nome = "you", total = 10, total_without_pet = 5, damage_taken = 7, last_dps = 1, friendlyfire_total = 6, totalover = 2, totalabsorb = 4, totalover_without_pet = 6, healing_taken = 1, heal_enemy_amt = 2});]]
		code = code:gsub ("STR", test)

		local f = loadstring (code)
		local err, two = xpcall (f, errorhandler)
		
		if (not err) then
			return
		end
		
		panel.callback (text)
		panel:Hide()
	end
	
	local ok_button = self.gump:NewButton (panel, nil, "$parentButtonOk", nil, 80, 20, done, nil, nil, nil, "DONE")
	ok_button:InstallCustomTexture()
	ok_button:SetPoint ("topright", panel, "topright", -10, -174)
	
	local reset_button = self.gump:NewButton (panel, nil, "$parentDefaultOk", nil, 80, 20, function() textentry.editbox:SetText (_detalhes.instance_defaults.row_info.textR_custom_text) end, nil, nil, nil, "Default")
	reset_button:InstallCustomTexture()
	reset_button:SetPoint ("topright", panel, "topright", -100, -152)
	
	local cancel_button = self.gump:NewButton (panel, nil, "$parentDefaultCancel", nil, 80, 20, function() textentry.editbox:SetText (panel.default_text); done(); end, nil, nil, nil, "Cancel")
	cancel_button:InstallCustomTexture()
	cancel_button:SetPoint ("topright", panel, "topright", -100, -174)
	
	function _detalhes:OpenOptionsWindowAtStart()
		--_detalhes:OpenOptionsWindow (_detalhes.tabela_instancias[1])
		--print (_G ["DetailsClearSegmentsButton1"]:GetSize())
		--_detalhes:OpenCustomWindow()
		--_detalhes:OpenWelcomeWindow() --for debug
	end
	_detalhes:ScheduleTimer ("OpenOptionsWindowAtStart", 2)
	--_detalhes:OpenCustomDisplayWindow()
	
	--BNSendFriendInvite ("tercio#1488")
	
end

