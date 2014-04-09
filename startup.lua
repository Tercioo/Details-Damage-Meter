--no inicio da luta gravar tabela com os coolsdowns de cada jogador e ir anotando quando eles sao usados.

--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.

function _G._detalhes:Start()

-- slider de scale nas opções

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details defaults
	
	--> parse all config
		--_detalhes:CountDataOnLoad()

	--> single click row function replace
		--damage, dps, damage taken, friendly fire
			self.row_singleclick_overwrite [1] = {true, true, true, true, self.atributo_damage.ReportSingleFragsLine, true, self.atributo_damage.ReportSingleVoidZoneLine} 
		--healing, hps, overheal, healing taken
			self.row_singleclick_overwrite [2] = {true, true, true, true, false, self.atributo_heal.ReportSingleDamagePreventedLine} 
		--mana, rage, energy, runepower
			self.row_singleclick_overwrite [3] = {true, true, true, true} 
		--cc breaks, ress, interrupts, dispells, deaths
			self.row_singleclick_overwrite [4] = {true, true, true, true, self.atributo_misc.ReportSingleDeadLine, self.atributo_misc.ReportSingleCooldownLine, self.atributo_misc.ReportSingleBuffUptimeLine, self.atributo_misc.ReportSingleDebuffUptimeLine} 
		
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> initialize

	--> build frames

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
			--self:ReativarInstancias()
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

		function self:RefreshAfterStartup()
		
			self:AtualizaGumpPrincipal (-1, true)
			
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			
			for index = 1, #self.tabela_instancias do
				local instance = self.tabela_instancias [index]
				if (instance:IsAtiva()) then
					--> refresh wallpaper
					if (instance.wallpaper.enabled) then
						instance:InstanceWallpaper (true)
					end
					
					--> refresh desaturated icons if is lower instance
					if (index == lower_instance) then
						instance:DesaturateMenu()
					end
				end
			end
			
			_detalhes.ToolBar:ReorganizeIcons()
			
			self.RefreshAfterStartup = nil
		end
		self:ScheduleTimer ("RefreshAfterStartup", 4)
		
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
			--self.listener:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
			self.parser_frame:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
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
	self:ScheduleTimer ("ShowDelayMsg", 10) 
	
	--> send instance open signal
	for index, instancia in ipairs (self.tabela_instancias) do
		if (instancia.ativa) then
			self:SendEvent ("DETAILS_INSTANCE_OPEN", nil, instancia)
			--instancia:SetBarGrowDirection()
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
				self.gump:Fade (instancia._version, "in", 0.1)
			end
		end
	end

	--[[
	if (self.tutorial.version_announce < 4) then
		self:ScheduleTimer ("AnnounceVersion", 20)
		self.tutorial.version_announce = self.tutorial.version_announce + 1
	else

		for index, instancia in ipairs (self.tabela_instancias) do
			if (instancia.ativa) then
				self.gump:Fade (instancia._version, 0)
				instancia._version:SetText ("Details! Alpha " .. _detalhes.userversion .. " (core: " .. self.realversion .. ")")
				instancia._version:SetPoint ("bottomleft", instancia.baseframe, "bottomleft", 0, 1)
				self.gump:Fade (instancia._version, "in", 10)
				
				if (instancia.auto_switch_to_old) then
					instancia:SwitchBack()
				end
			end
		end
	end
	--]]
	
	if (self.is_first_run) then
	
		_detalhes:OpenWelcomeWindow()
		
		if (#self.custom == 0) then
			local Healthstone = {
				["attribute"] = 2,
				["spell"] = "6262",
				["name"] = "Healthstone",
				["sattribute"] = 1,
				["target"] = "",
				["source"] = "[raid]",
				["icon"] = "Interface\\Icons\\warlock_ healthstone",
			}
			self.custom [#self.custom+1] = Healthstone
			
			local HealingPotion = {
				["attribute"] = 2,
				["spell"] = "105708",
				["name"] = "Healing Potion",
				["sattribute"] = 1,
				["target"] = "",
				["source"] = "[raid]",
				["icon"] = "Interface\\Icons\\trade_alchemy_potiond3",
			}
			self.custom [#self.custom+1] = HealingPotion
		end
	end
	
	--_detalhes:OpenWelcomeWindow()
	
	--desligado por preocaução
	if (self.tutorial.logons < 2) then
		--self:StartTutorial()
	end
	
	--> feedback trhead
	if (self.tutorial.logons > 100 and false) then --  and self.tutorial.logons < 104
	
		--desligado por preocaução

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
	
	if (self.is_version_first_run) then
		local lower_instance = _detalhes:GetLowerInstanceNumber()
		if (lower_instance) then
			lower_instance = _detalhes:GetInstance (lower_instance)
			if (lower_instance) then
				lower_instance:InstanceAlert (Loc ["STRING_VERSION_UPDATE"], {[[Interface\GossipFrame\AvailableQuestIcon]], 16, 16, false}, 20, {_detalhes.OpenNewsWindow})
			end
		end
	end
	
	--> minimap
	local LDB = LibStub ("LibDataBroker-1.1", true)
	local LDBIcon = LDB and LibStub ("LibDBIcon-1.0", true)
	
	if LDB then

		local minimapIcon = LDB:NewDataObject ("Details!", {
			type = "data source",
			icon = [[Interface\AddOns\Details\images\minimap]],
			
			OnClick = function (self, button)
			
				if (button == "LeftButton") then
				
					local lower_instance = _detalhes:GetLowerInstanceNumber()
					if (not lower_instance) then
						local instance = _detalhes:GetInstance (1)
						_detalhes.CriarInstancia (_, _, 1)
						_detalhes:OpenOptionsWindow (instance)
					else
						_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
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
				tooltip:AddLine (Loc ["STRING_MINIMAP_TOOLTIP1"])
				tooltip:AddLine (Loc ["STRING_MINIMAP_TOOLTIP2"])
			end,
		})
		
		if (minimapIcon and not LDBIcon:IsRegistered ("Details!")) then
			LDBIcon:Register ("Details!", minimapIcon, self.minimap)

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

	--[[
	print ("primeiro:")
	local instancia = _detalhes.tabela_instancias [1]
	for i = 1, instancia.barras [1]:GetNumPoints() do 
		local point, relativeTo, relativePoint, xOfs, yOfs = instancia.barras [1]:GetPoint (i)
		print (point, relativeTo, relativePoint, xOfs, yOfs)
	end
	print ("---------------")
	--]]
	
	
	-- bubble test 
	local f = CreateFrame ("frame", "DetailsBubble", UIParent)
	f:SetPoint ("center", UIParent, "center")
	f:SetSize (100, 100)
	f:SetFrameStrata ("TOOLTIP")
	f.isHorizontalFlipped = false
	f.isVerticalFlipped = false
	
	local t = f:CreateTexture (nil, "artwork")
	t:SetTexture ([[Interface\AddOns\Details\images\icons]])
	t:SetSize (131 * 1.2, 81 * 1.2)
	--377 328 508 409  0.0009765625
	t:SetTexCoord (0.7373046875, 0.9912109375, 0.6416015625, 0.7978515625)
	t:SetPoint ("center", f, "center")
	
	local line1 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
	line1:SetPoint ("topleft", t, "topleft", 24, -10)
	_detalhes:SetFontSize (line1, 9)
	line1:SetTextColor (.9, .9, .9, 1)
	line1:SetSize (110, 12)
	line1:SetJustifyV ("center")
	line1:SetJustifyH ("center")

	local line2 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
	line2:SetPoint ("topleft", t, "topleft", 11, -20)
	_detalhes:SetFontSize (line2, 9)
	line2:SetTextColor (.9, .9, .9, 1)
	line2:SetSize (140, 12)
	line2:SetJustifyV ("center")
	line2:SetJustifyH ("center")
	
	local line3 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
	line3:SetPoint ("topleft", t, "topleft", 7, -30)
	_detalhes:SetFontSize (line3, 9)
	line3:SetTextColor (.9, .9, .9, 1)
	line3:SetSize (144, 12)
	line3:SetJustifyV ("center")
	line3:SetJustifyH ("center")
	
	local line4 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
	line4:SetPoint ("topleft", t, "topleft", 11, -40)
	_detalhes:SetFontSize (line4, 9)
	line4:SetTextColor (.9, .9, .9, 1)
	line4:SetSize (140, 12)
	line4:SetJustifyV ("center")
	line4:SetJustifyH ("center")

	local line5 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
	line5:SetPoint ("topleft", t, "topleft", 24, -50)
	_detalhes:SetFontSize (line5, 9)
	line5:SetTextColor (.9, .9, .9, 1)
	line5:SetSize (110, 12)
	line5:SetJustifyV ("center")
	line5:SetJustifyH ("center")
	
	f.lines = {line1, line2, line3, line4, line5}
	
	--t:SetPoint ("center", UIParent, "center")
	
	function f:FlipHorizontal()
		if (not f.isHorizontalFlipped) then
			if (f.isVerticalFlipped) then
				t:SetTexCoord (0.9912109375, 0.7373046875, 0.7978515625, 0.6416015625)
			else
				t:SetTexCoord (0.9912109375, 0.7373046875, 0.6416015625, 0.7978515625)
			end
			f.isHorizontalFlipped = true
		else
			if (f.isVerticalFlipped) then
				t:SetTexCoord (0.7373046875, 0.9912109375, 0.7978515625, 0.6416015625)
			else
				t:SetTexCoord (0.7373046875, 0.9912109375, 0.6416015625, 0.7978515625)
			end
			f.isHorizontalFlipped = false
		end
	end
	
	function f:FlipVertical()
	
		if (not f.isVerticalFlipped) then
			if (f.isHorizontalFlipped) then
				t:SetTexCoord (0.7373046875, 0.9912109375, 0.7978515625, 0.6416015625)
			else
				t:SetTexCoord (0.9912109375, 0.7373046875, 0.7978515625, 0.6416015625)
			end
			f.isVerticalFlipped = true
		else
			if (f.isHorizontalFlipped) then
				t:SetTexCoord (0.7373046875, 0.9912109375, 0.6416015625, 0.7978515625)
			else
				t:SetTexCoord (0.9912109375, 0.7373046875, 0.6416015625, 0.7978515625)
			end
			f.isVerticalFlipped = false
		end
	end
	
	function f:SetBubbleText (line1, line2, line3, line4, line5)
		if (not line1) then
			for _, line in ipairs (f.lines) do
				line:SetText ("")
			end
			return
		end
		
		if (line1:find ("\n")) then
			line1, line2, line3, line4, line5 = strsplit ("\n", line1)
		end
		
		f.lines[1]:SetText (line1)
		f.lines[2]:SetText (line2)
		f.lines[3]:SetText (line3)
		f.lines[4]:SetText (line4)
		f.lines[5]:SetText (line5)
	end
	
	function f:SetOwner (frame, myPoint, hisPoint, x, y, alpha)
		f:ClearAllPoints()
		f:SetBubbleText (nil)
		t:SetTexCoord (0.7373046875, 0.9912109375, 0.6416015625, 0.7978515625)
		f.isHorizontalFlipped = false
		f.isVerticalFlipped = false
		f:SetPoint (myPoint or "bottom", frame, hisPoint or "top", x or 0, y or 0)
		t:SetAlpha (alpha or 1)
	end
	
	function f:ShowBubble()
		f:Show()
	end
	
	function f:HideBubble()
		f:Hide()
	end
	
	f:SetBubbleText (nil)
	
	f:Hide()
	

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
			
			_detalhes:ScheduleTimer ("FadeStartVersion", 7)
			
		end
	end
	
	
end

