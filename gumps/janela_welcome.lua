local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

local g =	_detalhes.gump

function _detalhes:OpenWelcomeWindow ()

	GameCooltip:Close()
	local window = _G.DetailsWelcomeWindow

	if (not window) then
	
		local index = 1
		local pages = {}
		
		window = CreateFrame ("frame", "DetailsWelcomeWindow", UIParent)
		window:SetPoint ("center", UIParent, "center", 0, 0)
		window:SetWidth (512)
		window:SetHeight (256)
		window:SetMovable (true)
		window:SetScript ("OnMouseDown", function() window:StartMoving() end)
		window:SetScript ("OnMouseUp", function() window:StopMovingOrSizing() end)
		
		local background = window:CreateTexture (nil, "background")
		background:SetPoint ("topleft", window, "topleft")
		background:SetPoint ("bottomright", window, "bottomright")
		background:SetTexture ([[Interface\AddOns\Details\images\welcome]])
		
		local rodape_bg = window:CreateTexture (nil, "artwork")
		rodape_bg:SetPoint ("bottomleft", window, "bottomleft", 11, 12)
		rodape_bg:SetPoint ("bottomright", window, "bottomright", -11, 12)
		rodape_bg:SetTexture ([[Interface\Tooltips\UI-Tooltip-Background]])
		rodape_bg:SetHeight (25)
		rodape_bg:SetVertexColor (0, 0, 0, 1)
		
		local logotipo = window:CreateTexture (nil, "overlay")
		logotipo:SetPoint ("topleft", window, "topleft", 16, -20)
		logotipo:SetTexture ([[Interface\Addons\Details\images\logotipo]])
		logotipo:SetTexCoord (0.07421875, 0.73828125, 0.51953125, 0.890625)
		logotipo:SetWidth (186)
		logotipo:SetHeight (50)
		
		local cancel = CreateFrame ("Button", nil, window)
		cancel:SetWidth (22)
		cancel:SetHeight (22)
		cancel:SetPoint ("bottomleft", window, "bottomleft", 12, 14)
		cancel:SetFrameLevel (window:GetFrameLevel()+1)
		cancel:SetPushedTexture ([[Interface\Buttons\UI-GroupLoot-Pass-Down]])
		cancel:SetHighlightTexture ([[Interface\Buttons\UI-GROUPLOOT-PASS-HIGHLIGHT]])
		cancel:SetNormalTexture ([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
		cancel:SetScript ("OnClick", function() window:Hide() end)
		local cancelText = cancel:CreateFontString (nil, "overlay", "GameFontNormal")
		cancelText:SetPoint ("left", cancel, "right", 2, 0)
		cancelText:SetText ("Skip")
		
		local forward = CreateFrame ("button", nil, window)
		forward:SetWidth (26)
		forward:SetHeight (26)
		forward:SetPoint ("bottomright", window, "bottomright", -14, 13)
		forward:SetFrameLevel (window:GetFrameLevel()+1)
		forward:SetPushedTexture ([[Interface\Buttons\UI-SpellbookIcon-NextPage-Down]])
		forward:SetHighlightTexture ([[Interface\Buttons\UI-SpellbookIcon-NextPage-Up]])
		forward:SetNormalTexture ([[Interface\Buttons\UI-SpellbookIcon-NextPage-Up]])
		forward:SetDisabledTexture ([[Interface\Buttons\UI-SpellbookIcon-NextPage-Disabled]])
		
		local backward = CreateFrame ("button", nil, window)
		backward:SetWidth (26)
		backward:SetHeight (26)
		backward:SetPoint ("bottomright", window, "bottomright", -38, 13)
		backward:SetPushedTexture ([[Interface\Buttons\UI-SpellbookIcon-PrevPage-Down]])
		backward:SetHighlightTexture ([[Interface\Buttons\UI-SpellbookIcon-PrevPage-Up]])
		backward:SetNormalTexture ([[Interface\Buttons\UI-SpellbookIcon-PrevPage-Up]])
		backward:SetDisabledTexture ([[Interface\Buttons\UI-SpellbookIcon-PrevPage-Disabled]])
		
		forward:SetScript ("OnClick", function()
			if (index < #pages) then
				for _, widget in ipairs (pages [index]) do 
					widget:Hide()
				end
				
				index = index + 1
				
				for _, widget in ipairs (pages [index]) do 
					widget:Show()
				end
				
				if (index == #pages) then
					forward:Disable()
				end
				backward:Enable()
			end
			

			
		end)
		
		backward:SetScript ("OnClick", function()
			if (index > 1) then
				for _, widget in ipairs (pages [index]) do 
					widget:Hide()
				end
				
				index = index - 1
				
				for _, widget in ipairs (pages [index]) do 
					widget:Show()
				end
				
				if (index == 1) then
					backward:Disable()
				end
				forward:Enable()
			end
		end)
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 1
		
		--> introduction
		
		local angel = window:CreateTexture (nil, "border")
		angel:SetPoint ("bottomright", window, "bottomright")
		angel:SetTexture ([[Interface\TUTORIALFRAME\UI-TUTORIALFRAME-SPIRITREZ]])
		angel:SetTexCoord (0.162109375, 0.591796875, 0, 1)
		angel:SetWidth (442)
		angel:SetHeight (256)
		angel:SetAlpha (.2)
		
		local texto1 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto1:SetPoint ("topleft", window, "topleft", 13, -150)
		texto1:SetText ("|cFFFFFFFFWelcome to Details! Quick Setup Wizard\n\n|rThis guide will help you with some important configurations.\nYou can skip this at any time just clicking on 'skip' button.")
		texto1:SetJustifyH ("left")
		
		pages [#pages+1] = {texto1, angel}
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 2
		
		--ampulheta:SetTexture ([[Interface\Timer\Challenges-Logo]])
		--[[
		local ampulheta = window:CreateTexture (nil, "overlay")
		
		ampulheta:SetPoint ("topright", window, "topright", 60, 57)
		ampulheta:SetHeight (125*3)--125
		ampulheta:SetWidth (89*3)--82
		ampulheta:SetAlpha (.1)
		ampulheta:SetDesaturated (true)
		--]]
		
		local ampulheta = window:CreateTexture (nil, "overlay")
		ampulheta:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		ampulheta:SetPoint ("bottomright", window, "bottomright", -10, 10)
		ampulheta:SetHeight (125*3)--125
		ampulheta:SetWidth (89*3)--82
		ampulheta:SetAlpha (.1)
		ampulheta:SetTexCoord (1, 0, 0, 1)		
		
		g:NewLabel (window, _, "$parentChangeMind2Label", "changemind2Label", "if you change your mind, you can always modify again through options panel", "GameFontNormal", 9, "orange")
		window.changemind2Label:SetPoint ("center", window, "center")
		window.changemind2Label:SetPoint ("bottom", window, "bottom", 0, 19)
		window.changemind2Label.align = "|"

		local texto2 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto2:SetPoint ("topleft", window, "topleft", 20, -80)
		texto2:SetText ("Damage & Healing per Second Timing:")
		
		local chronometer = CreateFrame ("CheckButton", "WelcomeWindowChronometer", window, "ChatConfigCheckButtonTemplate")
		chronometer:SetPoint ("topleft", window, "topleft", 40, -110)
		local continuous = CreateFrame ("CheckButton", "WelcomeWindowContinuous", window, "ChatConfigCheckButtonTemplate")
		continuous:SetPoint ("topleft", window, "topleft", 40, -160)
		
		_G ["WelcomeWindowChronometerText"]:SetText ("Chronometer"..": ")
		_G ["WelcomeWindowContinuousText"]:SetText ("Continuous"..": ")
		
		local chronometer_text = window:CreateFontString (nil, "overlay", "GameFontNormal")
		chronometer_text:SetText ("standard way of measuring time, the timer of each raid member is put on hold if his activity is ceased and back again to count when actor activity is resumed.")
		chronometer_text:SetWidth (360)
		chronometer_text:SetHeight (40)
		chronometer_text:SetJustifyH ("left")
		chronometer_text:SetJustifyV ("top")
		chronometer_text:SetTextColor (.8, .8, .8, 1)
		chronometer_text:SetPoint ("topleft", _G ["WelcomeWindowChronometerText"], "topright", 0, 0)
		
		local continuous_text = window:CreateFontString (nil, "overlay", "GameFontNormal")
		continuous_text:SetText ("also know as 'effective time', this method uses the elapsed combat time for mensure the Dps and Hps of all raid members.")
		continuous_text:SetWidth (360)
		continuous_text:SetHeight (40)
		continuous_text:SetJustifyH ("left")
		continuous_text:SetJustifyV ("top")
		continuous_text:SetTextColor (.8, .8, .8, 1)
		continuous_text:SetPoint ("topleft", _G ["WelcomeWindowContinuousText"], "topright", 0, 0)
		
		chronometer:SetHitRectInsets (0, -70, 0, 0)
		continuous:SetHitRectInsets (0, -70, 0, 0)
		
		if (_detalhes.time_type == 1) then --> chronometer
			chronometer:SetChecked (true)
			continuous:SetChecked (false)
		elseif (_detalhes.time_type == 1) then --> continuous
			chronometer:SetChecked (false)
			continuous:SetChecked (true)
		end
		
		chronometer:SetScript ("OnClick", function() continuous:SetChecked (false); _detalhes.time_type = 1 end)
		continuous:SetScript ("OnClick", function() chronometer:SetChecked (false); _detalhes.time_type = 2 end)
		
		pages [#pages+1] = {ampulheta, texto2, chronometer, continuous, chronometer_text, continuous_text, window.changemind2Label}
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 3

		local mecanica = window:CreateTexture (nil, "overlay")
		mecanica:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		mecanica:SetPoint ("bottomright", window, "bottomright", -10, 10)
		mecanica:SetHeight (125*3)--125
		mecanica:SetWidth (89*3)--82
		mecanica:SetAlpha (.1)
		mecanica:SetTexCoord (1, 0, 0, 1)	
		
		g:NewLabel (window, _, "$parentChangeMind3Label", "changemind3Label", "if you change your mind, you can always modify again through options panel", "GameFontNormal", 9, "orange")
		window.changemind3Label:SetPoint ("center", window, "center")
		window.changemind3Label:SetPoint ("bottom", window, "bottom", 0, 19)
		window.changemind3Label.align = "|"
		
		local texto3 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto3:SetPoint ("topleft", window, "topleft", 20, -80)
		texto3:SetText ("Reading combat data:")
		
		local data_text = window:CreateFontString (nil, "overlay", "GameFontNormal")
		data_text:SetText ("Details! reads and calculate combat data in a very fast way, but if you are unconfortable with you compunter performance, you can drop some types of data which isn't important to you:")
		data_text:SetWidth (460)
		data_text:SetHeight (40)
		data_text:SetJustifyH ("left")
		data_text:SetJustifyV ("top")
		data_text:SetTextColor (1, 1, 1, 1)
		data_text:SetPoint ("topleft", window, "topleft", 30, -105)
		
		local data_text2 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		data_text2:SetText ("Tip: for a best experience, it's recommend leave all turned on.")
		data_text2:SetWidth (460)
		data_text2:SetHeight (40)
		data_text2:SetJustifyH ("left")
		data_text2:SetJustifyV ("top")
		data_text2:SetTextColor (1, 1, 1, 1)
		data_text2:SetPoint ("topleft", window, "topleft", 30, -201)
		
	--------------- Captures
		g:NewImage (window, _, "$parentCaptureDamage", "damageCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.damageCaptureImage:SetPoint (35, -155)
		window.damageCaptureImage:SetTexCoord (0, 0.125, 0, 1)
		
		g:NewImage (window, _, "$parentCaptureHeal", "healCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.healCaptureImage:SetPoint (170, -155)
		window.healCaptureImage:SetTexCoord (0.125, 0.25, 0, 1)
		
		g:NewImage (window, _, "$parentCaptureEnergy", "energyCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.energyCaptureImage:SetPoint (305, -155)
		window.energyCaptureImage:SetTexCoord (0.25, 0.375, 0, 1)
		
		g:NewImage (window, _, "$parentCaptureMisc", "miscCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.miscCaptureImage:SetPoint (35, -175)
		window.miscCaptureImage:SetTexCoord (0.375, 0.5, 0, 1)
		
		g:NewImage (window, _, "$parentCaptureAura", "auraCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.auraCaptureImage:SetPoint (170, -175)
		window.auraCaptureImage:SetTexCoord (0.5, 0.625, 0, 1)
		
		g:NewLabel (window, _, "$parentCaptureDamageLabel", "damageCaptureLabel", "Damage")
		window.damageCaptureLabel:SetPoint ("left", window.damageCaptureImage, "right", 2)
		g:NewLabel (window, _, "$parentCaptureDamageLabel", "healCaptureLabel", "Healing")
		window.healCaptureLabel:SetPoint ("left", window.healCaptureImage, "right", 2)
		g:NewLabel (window, _, "$parentCaptureDamageLabel", "energyCaptureLabel", "Energy")
		window.energyCaptureLabel:SetPoint ("left", window.energyCaptureImage, "right", 2)
		g:NewLabel (window, _, "$parentCaptureDamageLabel", "miscCaptureLabel", "Misc")
		window.miscCaptureLabel:SetPoint ("left", window.miscCaptureImage, "right", 2)
		g:NewLabel (window, _, "$parentCaptureDamageLabel", "auraCaptureLabel", "Auras")
		window.auraCaptureLabel:SetPoint ("left", window.auraCaptureImage, "right", 2)
		
		local switch_icon_color = function (icon, on_off)
			icon:SetDesaturated (not on_off)
		end
		
		g:NewSwitch (window, _, "$parentCaptureDamageSlider", "damageCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["damage"])
		window.damageCaptureSlider:SetPoint ("left", window.damageCaptureLabel, "right", 2)
		window.damageCaptureSlider.tooltip = "Pause or enable capture of:\n- damage done\n- damage per second\n- friendly fire\n- damage taken"
		window.damageCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "damage", true)
			switch_icon_color (window.damageCaptureImage, value)
		end
		switch_icon_color (window.damageCaptureImage, _detalhes.capture_real ["damage"])
		
		g:NewSwitch (window, _, "$parentCaptureHealSlider", "healCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["heal"])
		window.healCaptureSlider:SetPoint ("left", window.healCaptureLabel, "right", 2)
		window.healCaptureSlider.tooltip = "Pause or enable capture of:\n- healing done (not absorbs)\n- healing per second\n- overheal\n- healing taken\n- enemy healed"
		window.healCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "heal", true)
			switch_icon_color (window.healCaptureImage, value)
		end
		switch_icon_color (window.healCaptureImage, _detalhes.capture_real ["heal"])
		
		g:NewSwitch (window, _, "$parentCaptureEnergySlider", "energyCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["energy"])
		window.energyCaptureSlider:SetPoint ("left", window.energyCaptureLabel, "right", 2)
		window.energyCaptureSlider.tooltip = "Pause or enable capture of:\n- mana restored\n- rage generated\n- energy generated\n- runic power generated"
		window.energyCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "energy", true)
			switch_icon_color (window.energyCaptureImage, value)
		end
		switch_icon_color (window.energyCaptureImage, _detalhes.capture_real ["energy"])
		
		g:NewSwitch (window, _, "$parentCaptureMiscSlider", "miscCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["miscdata"])
		window.miscCaptureSlider:SetPoint ("left", window.miscCaptureLabel, "right", 2)
		window.miscCaptureSlider.tooltip = "Pause or enable capture of:\n- cc breaks\n- dispell\n- interrupts\n- ress\n- deaths"
		window.miscCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "miscdata", true)
			switch_icon_color (window.miscCaptureImage, value)
		end
		switch_icon_color (window.miscCaptureImage, _detalhes.capture_real ["miscdata"])
		
		g:NewSwitch (window, _, "$parentCaptureAuraSlider", "auraCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["aura"])
		window.auraCaptureSlider:SetPoint ("left", window.auraCaptureLabel, "right", 2)
		window.auraCaptureSlider.tooltip = "Pause or enable capture of:\n- buffs and debufs\n- absorbs (heal)\n- cooldowns\n- damage prevented"
		window.auraCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "aura", true)
			switch_icon_color (window.auraCaptureImage, value)
		end
		switch_icon_color (window.auraCaptureImage, _detalhes.capture_real ["aura"])		
		
		pages [#pages+1] = {mecanica, texto3, data_text, window.damageCaptureImage, window.healCaptureImage, window.energyCaptureImage, window.miscCaptureImage,
		window.auraCaptureImage, window.damageCaptureSlider, window.healCaptureSlider, window.energyCaptureSlider, window.miscCaptureSlider, window.auraCaptureSlider, 
		window.damageCaptureLabel, window.healCaptureLabel, window.energyCaptureLabel, window.miscCaptureLabel, window.auraCaptureLabel, data_text2, window.changemind3Label}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 4
		
		local bg = window:CreateTexture (nil, "overlay")
		bg:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg:SetHeight (125*3)--125
		bg:SetWidth (89*3)--82
		bg:SetAlpha (.1)
		bg:SetTexCoord (1, 0, 0, 1)
		
		g:NewLabel (window, _, "$parentChangeMind4Label", "changemind4Label", "if you change your mind, you can always modify again through options panel", "GameFontNormal", 9, "orange")
		window.changemind4Label:SetPoint ("center", window, "center")
		window.changemind4Label:SetPoint ("bottom", window, "bottom", 0, 19)
		window.changemind4Label.align = "|"
		
		local texto4 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto4:SetPoint ("topleft", window, "topleft", 20, -80)
		texto4:SetText ("Interface Tweaks:")
		
		local interval_text = window:CreateFontString (nil, "overlay", "GameFontNormal")
		interval_text:SetText ("You can also adjust the interval (in seconds) between window updates, high values may save some performance.")
		interval_text:SetWidth (460)
		interval_text:SetHeight (40)
		interval_text:SetJustifyH ("left")
		interval_text:SetJustifyV ("top")
		interval_text:SetTextColor (1, 1, 1, 1)
		interval_text:SetPoint ("topleft", window, "topleft", 30, -110)
		
		local dance_text = window:CreateFontString (nil, "overlay", "GameFontNormal")
		dance_text:SetText ("Keeping 'Dance Bars' disabled may help save performance.")
		dance_text:SetWidth (460)
		dance_text:SetHeight (40)
		dance_text:SetJustifyH ("left")
		dance_text:SetJustifyV ("top")
		dance_text:SetTextColor (1, 1, 1, 1)
		dance_text:SetPoint ("topleft", window, "topleft", 30, -170)
		
	--------------- Update Speed
		g:NewLabel (window, _, "$parentUpdateSpeedLabel", "updatespeedLabel", "Update Speed")
		window.updatespeedLabel:SetPoint (31, -150)
		--
		g:NewSlider (window, _, "$parentSliderUpdateSpeed", "updatespeedSlider", 160, 20, 0.3, 3, 0.1, _detalhes.update_speed, true) --parent, container, name, member, w, h, min, max, step, defaultv
		window.updatespeedSlider:SetPoint ("left", window.updatespeedLabel, "right", 2, 0)
		window.updatespeedSlider:SetThumbSize (50)
		window.updatespeedSlider.useDecimals = true
		local updateColor = function (slider, value)
			if (value < 1) then
				slider.amt:SetTextColor (1, value, 0)
			elseif (value > 1) then
				slider.amt:SetTextColor (-(value-3), 1, 0)
			else
				slider.amt:SetTextColor (1, 1, 0)
			end
		end
		window.updatespeedSlider:SetHook ("OnValueChange", function (self, _, amount) 
			_detalhes:CancelTimer (_detalhes.atualizador)
			_detalhes.update_speed = amount
			_detalhes.atualizador = _detalhes:ScheduleRepeatingTimer ("AtualizaGumpPrincipal", _detalhes.update_speed, -1)
			updateColor (self, amount)
		end)
		updateColor (window.updatespeedSlider, _detalhes.update_speed)
		
		window.updatespeedSlider.tooltip = "delay between each update,\ncpu usage may |cFFFF9900increase|r with low values\nand |cFF00FF00slight reduce|r with high values."
		
	--------------- Animate Rows
		g:NewLabel (window, _, "$parentAnimateLabel", "animateLabel", "Dance Bars")
		window.animateLabel:SetPoint (31, -195)
		--
		g:NewSwitch (window, _, "$parentAnimateSlider", "animateSlider", 60, 20, _, _, _detalhes.use_row_animations) -- ltext, rtext, defaultv
		window.animateSlider:SetPoint ("left",window.animateLabel, "right", 2, 0)
		window.animateSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue (false, true)
			_detalhes.use_row_animations = value
		end	
		window.animateSlider.tooltip = "dancing bars is a feature which create animations\nto the left and right directions for all bars.\ncpu usage may |cFFFF9900slight increase|r with this turned on."
		
		pages [#pages+1] = {bg, texto4, interval_text, dance_text, window.updatespeedLabel, window.updatespeedSlider, window.animateLabel, window.animateSlider, window.changemind4Label}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 5

		local bg6 = window:CreateTexture (nil, "overlay")
		bg6:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg6:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg6:SetHeight (125*3)--125
		bg6:SetWidth (89*3)--82
		bg6:SetAlpha (.1)
		bg6:SetTexCoord (1, 0, 0, 1)

		local texto5 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto5:SetPoint ("topleft", window, "topleft", 20, -80)
		texto5:SetText ("Using the Interface: Stretch")
		
		local texto_stretch = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto_stretch:SetPoint ("topleft", window, "topleft", 181, -105)
		texto_stretch:SetText ("- When you have the mouse over a Details! window, a |cFFFFFF00small hook|r will appear over the instance button. |cFFFFFF00Click, hold and pull|r up to |cFFFFFF00stretch|r the window, releasing the mouse click, the window |cFFFFFF00back to original|r size.\n\n- If you miss a |cFFFFBB00scroll bar|r, you can active it on the options panel.")
		texto_stretch:SetWidth (310)
		texto_stretch:SetHeight (100)
		texto_stretch:SetJustifyH ("left")
		texto_stretch:SetJustifyV ("top")
		texto_stretch:SetTextColor (1, 1, 1, 1)
		
		local stretch_image = window:CreateTexture (nil, "overlay")
		stretch_image:SetTexture ([[Interface\Addons\Details\images\icons]])
		stretch_image:SetPoint ("right", texto_stretch, "left", -12, 0)
		stretch_image:SetWidth (144)
		stretch_image:SetHeight (61)
		stretch_image:SetTexCoord (0.716796875, 1, 0.876953125, 1)
		
		pages [#pages+1] = {bg6, texto5, stretch_image, texto_stretch}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 6

		local bg6 = window:CreateTexture (nil, "overlay")
		bg6:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg6:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg6:SetHeight (125*3)--125
		bg6:SetWidth (89*3)--82
		bg6:SetAlpha (.1)
		bg6:SetTexCoord (1, 0, 0, 1)

		local texto6 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto6:SetPoint ("topleft", window, "topleft", 20, -80)
		texto6:SetText ("Using the Interface: Instance Button")
		
		local texto_instance_button = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto_instance_button:SetPoint ("topleft", window, "topleft", 25, -105)
		texto_instance_button:SetText ("Instance button basically do three things:\n\n- show |cFFFFFF00what instance|r is it through the |cFFFFFF00#number|r,\n- open a |cFFFFFF00new instance|r window when clicked.\n- show a menu with |cFFFFFF00closed instances|r which can be reopen at any one.")
		texto_instance_button:SetWidth (270)
		texto_instance_button:SetHeight (100)
		texto_instance_button:SetJustifyH ("left")
		texto_instance_button:SetJustifyV ("top")
		texto_instance_button:SetTextColor (1, 1, 1, 1)
		
		local instance_button_image = window:CreateTexture (nil, "overlay")
		instance_button_image:SetTexture ([[Interface\Addons\Details\images\icons]])
		instance_button_image:SetPoint ("topright", window, "topright", -12, -70)
		instance_button_image:SetWidth (204)
		instance_button_image:SetHeight (141)
		instance_button_image:SetTexCoord (0.31640625, 0.71484375, 0.724609375, 1)
		
		pages [#pages+1] = {bg6, texto6, instance_button_image, texto_instance_button}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 7

		local bg7 = window:CreateTexture (nil, "overlay")
		bg7:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg7:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg7:SetHeight (125*3)--125
		bg7:SetWidth (89*3)--82
		bg7:SetAlpha (.1)
		bg7:SetTexCoord (1, 0, 0, 1)

		local texto7 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto7:SetPoint ("topleft", window, "topleft", 20, -80)
		texto7:SetText ("Using the Interface: Fast Switch Panel (shortcuts)")
		
		local texto_shortcut = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto_shortcut:SetPoint ("topleft", window, "topleft", 25, -110)
		texto_shortcut:SetText ("- Right clicking |cFFFFFF00over a row|r or in the background opens the |cFFFFFF00shortcut menu|r.\n- You can choose which |cFFFFFF00attribute|r the shortcut will have by |cFFFFFF00right clicking|r his icon.\n- Left click |cFFFFFF00selects|r the shortcut attribute and |cFFFFFF00display|r it on the instance\n- Right click anywhere |cFFFFFF00closes|r the switch panel.")
		texto_shortcut:SetWidth (320)
		texto_shortcut:SetHeight (90)
		texto_shortcut:SetJustifyH ("left")
		texto_shortcut:SetJustifyV ("top")
		texto_shortcut:SetTextColor (1, 1, 1, 1)
		
		local shortcut_image1 = window:CreateTexture (nil, "overlay")
		shortcut_image1:SetTexture ([[Interface\Addons\Details\images\icons]])
		shortcut_image1:SetPoint ("topright", window, "topright", -12, -20)
		shortcut_image1:SetWidth (160)
		shortcut_image1:SetHeight (91)
		shortcut_image1:SetTexCoord (0, 0.31250, 0.82421875, 1)
		
		local shortcut_image2 = window:CreateTexture (nil, "overlay")
		shortcut_image2:SetTexture ([[Interface\Addons\Details\images\icons]])
		shortcut_image2:SetPoint ("topright", window, "topright", -12, -110)
		shortcut_image2:SetWidth (160)
		shortcut_image2:SetHeight (106)
		shortcut_image2:SetTexCoord (0, 0.31250, 0.59375, 0.80078125)
		
		pages [#pages+1] = {bg7, texto7, shortcut_image1, shortcut_image2, texto_shortcut}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 8

		local bg8 = window:CreateTexture (nil, "overlay")
		bg8:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg8:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg8:SetHeight (125*3)--125
		bg8:SetWidth (89*3)--82
		bg8:SetAlpha (.1)
		bg8:SetTexCoord (1, 0, 0, 1)

		local texto8 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto8:SetPoint ("topleft", window, "topleft", 20, -80)
		texto8:SetText ("Ready to Raid!")
		
		local texto = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto:SetPoint ("topleft", window, "topleft", 25, -110)
		texto:SetText ("Thank you for choosing Details!\n\nFeel free to always send feedbacks and bug reports to us (|cFFBBFFFFuse the fifth button a blue one|r), we appreciate.")
		texto:SetWidth (410)
		texto:SetHeight (90)
		texto:SetJustifyH ("left")
		texto:SetJustifyV ("top")
		texto:SetTextColor (1, 1, 1, 1)
		
		local report_image1 = window:CreateTexture (nil, "overlay")
		report_image1:SetTexture ([[Interface\Addons\Details\images\icons]])
		report_image1:SetPoint ("topright", window, "topright", -30, -97)
		report_image1:SetWidth (144)
		report_image1:SetHeight (30)
		report_image1:SetTexCoord (0.71875, 1, 0.81640625, 0.875)
	
		pages [#pages+1] = {bg8, texto8, texto, report_image1}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end
		
------------------------------------------------------------------------------------------------------------------------------		
		
		--[[
		forward:Click()
		forward:Click()
		forward:Click()
		forward:Click()
		forward:Click()
		forward:Click()
		forward:Click()
		--]]
		
	end
	
end