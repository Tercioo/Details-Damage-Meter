local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

local g =	_detalhes.gump
local _
function _detalhes:OpenOptionsWindow (instance)

	GameCooltip:Close()
	local window = _G.DetailsOptionsWindow

	if (not window) then
	
-- Details Overall -------------------------------------------------------------------------------------------------------------------------------------------------
	
		-- Most of details widgets have the same 6 first parameters: parent, container, global name, parent key, width, height
	
		window = g:NewPanel (UIParent, _, "DetailsOptionsWindow", _, 700, 470)
		window.instance = instance
		tinsert (UISpecialFrames, "DetailsOptionsWindow")
		window:SetPoint ("center", UIParent, "Center")
		window.locked = false
		window.close_with_right = true
	
		g:NewLabel (window, _, "$parentTitle", "title", "This is a tiny options panel for Alpha Development Stage of Details!, yeah, it's a mess i agree, but in a near future will be changed.")
		window.title:SetPoint (10, -10)
		
		local c = window:CreateRightClickLabel ("medium")
		c:SetPoint ("bottomleft", window, "bottomleft", 5, 5)
		
	--------------- Memory
	
		g:NewSlider (window, _, "$parentSlider", "segmentsSlider", 120, 20, 1, 25, 1, _detalhes.segments_amount) -- min, max, step, defaultv
		g:NewSlider (window, _, "$parentSliderSegmentsSave", "segmentsSliderToSave", 80, 20, 1, 5, 1, _detalhes.segments_amount_to_save) -- min, max, step, defaultv
		g:NewSlider (window, _, "$parentSliderUpdateSpeed", "updatespeedSlider", 160, 20, 0.3, 3, 0.1, _detalhes.update_speed, true) --parent, container, name, member, w, h, min, max, step, defaultv
	
		g:NewLabel (window, _, "$parentLabelMemory", "memoryLabel", "memory threshold")
		window.memoryLabel:SetPoint (10, -35)
		--
		g:NewSlider (window, _, "$parentSliderMemory", "memorySlider", 130, 20, 1, 4, 1, _detalhes.memory_threshold) -- min, max, step, defaultv
		window.memorySlider:SetPoint ("left", window.memoryLabel, "right", 2, 0)
		window.memorySlider:SetHook ("OnValueChange", function (slider, _, amount) --> slider, fixedValue, sliderValue
			
			amount = math.floor (amount)
			
			if (amount == 1) then
				slider.amt:SetText ("<= 1gb")
				_detalhes.memory_ram = 16
				--_detalhes.segments_amount = 5
				--_detalhes.segments_amount_to_save = 2
				--_detalhes.update_speed = 1.5
				
				--_G.DetailsOptionsWindowSlider.MyObject:SetValue (_detalhes.segments_amount)
				--_G.DetailsOptionsWindowSliderSegmentsSave.MyObject:SetValue (_detalhes.segments_amount_to_save)
				--_G.DetailsOptionsWindowSliderUpdateSpeed.MyObject:SetValue (_detalhes.update_speed)
				
			elseif (amount == 2) then
				slider.amt:SetText ("2gb")
				_detalhes.memory_ram = 32
				--_detalhes.segments_amount = 10
				--_detalhes.segments_amount_to_save = 3
				--_detalhes.update_speed = 1.2
				
				--_G.DetailsOptionsWindowSlider.MyObject:SetValue (_detalhes.segments_amount)
				--_G.DetailsOptionsWindowSliderSegmentsSave.MyObject:SetValue (_detalhes.segments_amount_to_save)
				--_G.DetailsOptionsWindowSliderUpdateSpeed.MyObject:SetValue (_detalhes.update_speed)
				
			elseif (amount == 3) then
				slider.amt:SetText ("4gb")
				_detalhes.memory_ram = 64
				--_detalhes.segments_amount = 20
				--_detalhes.segments_amount_to_save = 5
				--_detalhes.update_speed = 1.0
				
				--_G.DetailsOptionsWindowSlider.MyObject:SetValue (_detalhes.segments_amount)
				--_G.DetailsOptionsWindowSliderSegmentsSave.MyObject:SetValue (_detalhes.segments_amount_to_save)
				--_G.DetailsOptionsWindowSliderUpdateSpeed.MyObject:SetValue (_detalhes.update_speed)
				
			elseif (amount == 4) then
				slider.amt:SetText (">= 6gb")
				_detalhes.memory_ram = 128
				--_detalhes.segments_amount = 25
				--_detalhes.segments_amount_to_save = 5
				--_detalhes.update_speed = 0.5
				
				--_G.DetailsOptionsWindowSlider.MyObject:SetValue (_detalhes.segments_amount)
				--_G.DetailsOptionsWindowSliderSegmentsSave.MyObject:SetValue (_detalhes.segments_amount_to_save)
				--_G.DetailsOptionsWindowSliderUpdateSpeed.MyObject:SetValue (_detalhes.update_speed)
				
			end
			
			_detalhes.memory_threshold = amount
			
			return true
		end)
		window.memorySlider.tooltip = "Details! try adjust it self with the amount of memory\navaliable on your system.\n\nAlso is recommeded keep the amount of\nsegments low if your system have 2gb ram or less."
		window.memorySlider.thumb:SetSize (40, 12)
		window.memorySlider.thumb:SetTexture ([[Interface\Buttons\UI-Listbox-Highlight2]])
		window.memorySlider.thumb:SetVertexColor (.2, .2, .2, .9)
		local t = _detalhes.memory_threshold
		window.memorySlider:SetValue (1)
		window.memorySlider:SetValue (2)
		window.memorySlider:SetValue (t)
		
	--------------- Max Segments
		g:NewLabel (window, _, "$parentSliderLabel", "segmentsLabel", "max segments")
		window.segmentsLabel:SetPoint (10, -50)
		--
		
		window.segmentsSlider:SetPoint ("left", window.segmentsLabel, "right")
		window.segmentsSlider:SetHook ("OnValueChange", function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.segments_amount = math.floor (amount)
		end)
		window.segmentsSlider.tooltip = "This option control how many fights you want to maintain.\nAs overall data work dynamic with segments stored,\nfeel free to adjust this number to be comfortable for you.\nHigh value may increase the memory use,\nbut doesn't affect your game framerate."

	--------------- Max Segments Saved
		g:NewLabel (window, _, "$parentLabelSegmentsSave", "segmentsSaveLabel", "segments saved on logout")
		window.segmentsSaveLabel:SetPoint (10, -65)
		--
		
		window.segmentsSliderToSave:SetPoint ("left", window.segmentsSaveLabel, "right")
		window.segmentsSliderToSave:SetHook ("OnValueChange", function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.segments_amount_to_save = math.floor (amount)
		end)
		window.segmentsSliderToSave.tooltip = "How many segments will be saved on logout.\nHigher values may increase the time between a\nlogout button click and your character selection screen.\nIf you rarely check last day data, it`s high recommeded save only 1."
	
	--------------- Panic Mode
		g:NewLabel (window, _, "$parentPanicModeLabel", "panicModeLabel", "panic mode")
		window.panicModeLabel:SetPoint (10, -80)
		--
		g:NewSwitch (window, _, "$parentPanicModeSlider", "panicModeSlider", 60, 20, _, _, _detalhes.segments_panic_mode)
		window.panicModeSlider:SetPoint ("left", window.panicModeLabel, "right")
		window.panicModeSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue
			_detalhes.segments_panic_mode = value
		end
		window.panicModeSlider.tooltip = "If enabled, when you are in a raid encounter\nand get dropped from the game, a disconnect for intance,\nDetails! immediately erase all segments\nmaking the disconnect process faster."
		
	--------------- Animate Rows
		g:NewLabel (window, _, "$parentAnimateLabel", "animateLabel", "dance bars")
		window.animateLabel:SetPoint (10, -95)
		--
		g:NewSwitch (window, _, "$parentAnimateSlider", "animateSlider", 60, 20, _, _, _detalhes.use_row_animations) -- ltext, rtext, defaultv
		window.animateSlider:SetPoint ("left",window.animateLabel, "right")
		window.animateSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue (false, true)
			_detalhes.use_row_animations = value
		end
		
	--------------- Use Scroll Bar
		g:NewLabel (window, _, "$parentUseScrollLabel", "scrollLabel", "show scroll bar")
		window.scrollLabel:SetPoint (10, -110)
		--
		g:NewSwitch (window, _, "$parentUseScrollSlider", "scrollSlider", 60, 20, _, _, _detalhes.use_scroll) -- ltext, rtext, defaultv
		window.scrollSlider:SetPoint ("left", window.scrollLabel, "right")
		window.scrollSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue
			_detalhes.use_scroll = value
			if (not value) then
				for index = 1, #_detalhes.tabela_instancias do
					local instance = _detalhes.tabela_instancias [index]
					if (instance.baseframe) then --fast check if instance already been initialized
						instance:EsconderScrollBar (true, true)
					end
				end
			end
			--hard instances reset
			_detalhes:InstanciaCallFunction (_detalhes.gump.Fade, "in", nil, "barras")
			_detalhes:InstanciaCallFunction (_detalhes.AtualizaSegmentos) -- atualiza o instancia.showing para as novas tabelas criadas
			_detalhes:InstanciaCallFunction (_detalhes.AtualizaSoloMode_AfertReset) -- verifica se precisa zerar as tabela da janela solo mode
			_detalhes:InstanciaCallFunction (_detalhes.ResetaGump) --_detalhes:ResetaGump ("de todas as instancias")
			_detalhes:AtualizaGumpPrincipal (-1, true) --atualiza todas as instancias
		end
		
	--------------- Animate scroll bar
		g:NewLabel (window, _, "$parentAnimateScrollLabel", "animatescrollLabel", "animate scroll")
		window.animatescrollLabel:SetPoint (10, -125)
		--
		g:NewSwitch (window, _, "$parentClearAnimateScrollSlider", "animatescrollSlider", 60, 20, _, _, _detalhes.animate_scroll) -- ltext, rtext, defaultv
		window.animatescrollSlider:SetPoint ("left", window.animatescrollLabel, "right")
		window.animatescrollSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue
			_detalhes.animate_scroll = value
		end
		
	--------------- Update Speed
		g:NewLabel (window, _, "$parentUpdateSpeedLabel", "updatespeedLabel", "update speed")
		window.updatespeedLabel:SetPoint (10, -143)
		--
		--g:NewSlider (window, _, "$parentSliderUpdateSpeed", "updatespeedSlider", 160, 20, 0.3, 3, 0.1, _detalhes.update_speed, true) --parent, container, name, member, w, h, min, max, step, defaultv
		window.updatespeedSlider:SetPoint ("left", window.updatespeedLabel, "right")
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
		
		window.updatespeedSlider.tooltip = "delay between each update,\nCPU usage may increase with low values."
		
	--------------- Time Type
		g:NewLabel (window, _, "$parentTimeTypeLabel", "timetypeLabel", "time measure")
		window.timetypeLabel:SetPoint (10, -163)
		--
		local onSelectTimeType = function (_, _, timetype)
			_detalhes.time_type = timetype
			_detalhes:AtualizaGumpPrincipal (-1, true)
		end
		local timetypeOptions = {
			{value = 1, label = "Activity Time", onclick = onSelectTimeType, icon = "Interface\\Icons\\INV_Misc_PocketWatch_01", desc = "Activity time are based on the actions of the actor\nand his activity time are paused when he is idle during combat."},
			{value = 2, label = "Effective Time", onclick = onSelectTimeType, icon = "Interface\\Icons\\INV_Misc_Gear_03", desc = "The effective time is the same for all the actors where the\ncombat time is used to measure the effectiveness of all actors."}
		}
		local buildTimeTypeMenu = function()
			return timetypeOptions
		end
		g:NewDropDown (window, _, "$parentTTDropdown", "timetypeDropdown", 160, 20, buildTimeTypeMenu, nil) -- func, default
		window.timetypeDropdown:SetPoint ("left", window.timetypeLabel, "right")
	
	--------------- Captures
		g:NewImage (window, _, "$parentCaptureDamage", "damageCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.damageCaptureImage:SetPoint (10, -183)
		window.damageCaptureImage:SetTexCoord (0, 0.125, 0, 1)
		
		g:NewImage (window, _, "$parentCaptureHeal", "healCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.healCaptureImage:SetPoint (10, -203)
		window.healCaptureImage:SetTexCoord (0.125, 0.25, 0, 1)
		
		g:NewImage (window, _, "$parentCaptureEnergy", "energyCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.energyCaptureImage:SetPoint (10, -223)
		window.energyCaptureImage:SetTexCoord (0.25, 0.375, 0, 1)
		
		g:NewImage (window, _, "$parentCaptureMisc", "miscCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.miscCaptureImage:SetPoint (10, -243)
		window.miscCaptureImage:SetTexCoord (0.375, 0.5, 0, 1)
		
		g:NewImage (window, _, "$parentCaptureAura", "auraCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.auraCaptureImage:SetPoint (10, -263)
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
		window.healCaptureSlider.tooltip = "Pause or enable capture of:\n- healing done\n- absorbs\n- healing per second\n- overheal\n- healing taken\n- enemy healed"
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
		window.auraCaptureSlider.tooltip = "Pause or enable capture of:\n- buffs uptime\n- debuffs uptime\n- void zones\n- cooldowns"
		window.auraCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "aura", true)
			switch_icon_color (window.auraCaptureImage, value)
		end
		switch_icon_color (window.auraCaptureImage, _detalhes.capture_real ["aura"])
		
	--------------- Cloud Capture
	
		g:NewLabel (window, _, "$parentCloudCaptureLabel", "cloudCaptureLabel", "Cloud Capture")
		window.cloudCaptureLabel:SetPoint (10, -288)
	
		g:NewSwitch (window, _, "$parentCloudAuraSlider", "cloudCaptureSlider", 60, 20, _, _, _detalhes.cloud_capture)
		window.cloudCaptureSlider:SetPoint ("left", window.cloudCaptureLabel, "right", 2)
		window.cloudCaptureSlider.tooltip = "Download capture data from another\nraid member when a capture are disabled."
		window.cloudCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes.cloud_capture = value
		end
		
	--------------- Max Instances
		g:NewLabel (window, _, "$parentLabelMaxInstances", "maxInstancesLabel", "max instances")
		window.maxInstancesLabel:SetPoint (10, -314)
		--
		g:NewSlider (window, _, "$parentSliderMaxInstances", "maxInstancesSlider", 150, 20, 12, 30, 1, _detalhes.instances_amount) -- min, max, step, defaultv
		window.maxInstancesSlider:SetPoint ("left", window.maxInstancesLabel, "right")
		window.maxInstancesSlider:SetHook ("OnValueChange", function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.instances_amount = amount
		end)
		window.maxInstancesSlider.tooltip = "Amount of windows which can be created."
		
	--------------- Frags PVP Mode
		g:NewLabel (window, _, "$parentLabelFragsPvP", "fragsPvpLabel", "only pvp frags")
		window.fragsPvpLabel:SetPoint (10, -329)
		--
		g:NewSwitch (window, _, "$parentFragsPvpSlider", "fragsPvpSlider", 60, 20, _, _, _detalhes.only_pvp_frags)
		window.fragsPvpSlider:SetPoint ("left", window.fragsPvpLabel, "right")
		window.fragsPvpSlider.OnSwitch = function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.only_pvp_frags = amount
		end
		window.fragsPvpSlider.tooltip = "Only record frags from player characters."
		
	--------------- Concatenate Trash
	--[[
		g:NewLabel (window, _, "$parentConcatenateTrash", "concatenateTrashLabel", "concatenate clean up segments")
		window.concatenateTrashLabel:SetPoint (10, -344)
		--
		g:NewSwitch (window, _, "$parentConcatenateTrashSlider", "concatenateTrashSlider", 60, 20, _, _, _detalhes.trash_concatenate)
		window.concatenateTrashSlider:SetPoint ("left", window.concatenateTrashLabel, "right")
		window.concatenateTrashSlider.OnSwitch = function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.trash_concatenate = amount
		end
		window.concatenateTrashSlider.tooltip = "Concatenate the next boss segments into only one."
		--]]
	--------------- Erase Trash
		g:NewLabel (window, _, "$parentEraseTrash", "eraseTrashLabel", "remove clean up segments")
		window.eraseTrashLabel:SetPoint (10, -359)
		--
		g:NewSwitch (window, _, "$parentRemoveTrashSlider", "removeTrashSlider", 60, 20, _, _, _detalhes.trash_auto_remove)
		window.removeTrashSlider:SetPoint ("left", window.eraseTrashLabel, "right")
		window.removeTrashSlider.OnSwitch = function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.trash_auto_remove = amount
		end
		window.removeTrashSlider.tooltip = "Auto erase the next boss segments."
		
-- Current Instalnce --------------------------------------------------------------------------------------------------------------------------------------------
	

	--------------- Row textures
		g:NewLabel (window, _, "$parentTextureLabel", "textureLabel", "bar texture")
		window.textureLabel:SetPoint (250, -35)
		--
		local onSelectTexture = function (_, instance, textureName) 	
			instance.barrasInfo.textura = SharedMedia:Fetch ("statusbar", textureName)
			instance.barrasInfo.textureName = textureName
			instance:RefreshBars()
		end	
		local textures = SharedMedia:HashTable ("statusbar")
		local texTable = {}
		for name, texturePath in pairs (textures) do 
			texTable[#texTable+1] = {value = name, label = name, statusbar = texturePath,  onclick = onSelectTexture}
		end
		local buildTextureMenu = function() return texTable end
		g:NewDropDown (window, _, "$parentTextureDropdown", "textureDropdown", 160, 20, buildTextureMenu, nil) -- func, default
		window.textureDropdown:SetPoint ("left", window.textureLabel, "right", 2)
		
	--------------- Text Sizes
		g:NewLabel (window, _, "$parentFontSizeLabel", "fonsizeLabel", "text size")
		window.fonsizeLabel:SetPoint (250, -53)
		--
		g:NewSlider (window, _, "$parentSliderFontSize", "fonsizeSlider", 150, 20, 8, 15, 1, tonumber (instance.barrasInfo.fontSize)) --parent, container, name, member, w, h, min, max, step, defaultv
		window.fonsizeSlider:SetPoint ("left", window.fonsizeLabel, "right", 2)
		window.fonsizeSlider:SetThumbSize (50)
		window.fonsizeSlider:SetHook ("OnValueChange", function (self, instance, amount) 
			instance.barrasInfo.fontSize = amount
			instance:RefreshBars()
		end)
		
	--------------- Text Fonts
		local onSelectFont = function (_, instance, fontName)
			instance.barrasInfo.font = SharedMedia:Fetch ("font", fontName)
			instance.barrasInfo.fontName = fontName
			instance:RefreshBars()
		end
	
		local fontObjects = SharedMedia:HashTable ("font")
		local fontTable = {}
		for name, fontPath in pairs (fontObjects) do 
			fontTable[#fontTable+1] = {value = name, label = name, onclick = onSelectFont, font = fontPath}
		end
		local buildFontMenu = function() return fontTable end
		
		g:NewLabel (window, _, "$parentFontLabel", "fontLabel", "text font")
		window.fontLabel:SetPoint (250, -71)
		--
		g:NewDropDown (window, _, "$parentFontDropdown", "fontDropdown", 160, 20, buildFontMenu, nil)
		window.fontDropdown:SetPoint ("left", window.fontLabel, "right", 2)
	
	--------------- Instance Color
	
		g:NewLabel (window, _, "$parentInstanceColorLabel", "instancecolor", "instance color")
		window.instancecolor:SetPoint (250, -89)
		
		local selectedColor = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = OpacitySliderFrame:GetValue()
			
			window.instancecolortexture:SetTexture (r, g, b)
			window.instancecolortexture:SetAlpha (a)
			
			window.instance.color[1], window.instance.color[2], window.instance.color[3], window.instance.color[4] = r, g, b, a
			window.instance:InstanceColor (r, g, b, a)
		end
		
		local canceledColor = function()
			local c = ColorPickerFrame.previousValues
			window.instancecolortexture:SetTexture (c [1], c [2], c [3])
			window.instancecolortexture:SetAlpha (c [4])
			
			window.instance.color[1], window.instance.color[2], window.instance.color[3], window.instance.color[4] = c [1], c [2], c [3], c [4]
			window.instance:InstanceColor (c [1], c [2], c [3], c [4])
			
			ColorPickerFrame.func = nil
			ColorPickerFrame.opacityFunc = nil
			ColorPickerFrame.cancelFunc = nil
		end
		
		local selectedAlpha = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = OpacitySliderFrame:GetValue()

			a = _detalhes:Scale (0, 1, 0.5, 1, a) - 0.5
			
			window.instancecolortexture:SetTexture (r, g, b)
			window.instancecolortexture:SetAlpha (a)
			
			window.instance.color[1], window.instance.color[2], window.instance.color[3], window.instance.color[4] = r, g, b, a
			window.instance:InstanceColor (r, g, b, a)

		end
		
		local colorpick = function()
			ColorPickerFrame.func = selectedColor
			ColorPickerFrame.opacityFunc = selectedAlpha
			ColorPickerFrame.cancelFunc = canceledColor
			ColorPickerFrame.hasOpacity = true --false
			ColorPickerFrame.opacity = window.instance.color[4] or 1
			ColorPickerFrame.previousValues = window.instance.color
			ColorPickerFrame:SetParent (window.widget)
			ColorPickerFrame:SetColorRGB (unpack (window.instance.color))
			ColorPickerFrame:Show()
		end

		g:NewImage (window, _, "$parentInstanceColorTexture", "instancecolortexture", 150, 12)
		window.instancecolortexture:SetPoint ("left", window.instancecolor, "right", 2)
		window.instancecolortexture:SetTexture (1, 1, 1)
		
		g:NewButton (window, _, "$parentInstanceColorButton", "instancecolorbutton", 150, 14, colorpick)
		window.instancecolorbutton:SetPoint ("left", window.instancecolor, "right", 2)
		window.instancecolorbutton:InstallCustomTexture()
	
	-------- bar background

		g:NewLabel (window, _, "$parentRowBackgroundTextureLabel", "rowBackgroundLabel", "bar background texture")
		window.rowBackgroundLabel:SetPoint (250, -107)
		--
		local onSelectTextureBackground = function (_, instance, textureName) 	
			instance.barrasInfo.texturaBackground = SharedMedia:Fetch ("statusbar", textureName)
			instance.barrasInfo.textureNameBackground = textureName
			instance:RefreshBars()
			instance:InstanceReset()
			instance:InstanceRefreshRows()
		end	
		local textures2 = SharedMedia:HashTable ("statusbar")
		local texTable2 = {}
		for name, texturePath in pairs (textures2) do 
			texTable2[#texTable2+1] = {value = name, label = name, statusbar = texturePath,  onclick = onSelectTextureBackground}
		end
		local buildTextureMenu2 = function() return texTable2 end
		g:NewDropDown (window, _, "$parentRowBackgroundTextureDropdown", "rowBackgroundDropdown", 120, 20, buildTextureMenu2, nil) -- func, default
		window.rowBackgroundDropdown:SetPoint ("left", window.rowBackgroundLabel, "right", 2)
	
		g:NewLabel (window, _, "$parentRowBackgroundColorLabel", "rowBackgroundColorLabel", "bar background color")
		window.rowBackgroundColorLabel:SetPoint (250, -125)
		
		local selectedRowBackgroundColor = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = OpacitySliderFrame:GetValue()
			
			local c =  window.instance.barrasInfo.texturaBackgroundColor
			c [1], c [2], c [3], c [4] = r, g, b, a
			
			window.instance:RefreshBars()
			window.instance:InstanceReset()
			window.instance:InstanceRefreshRows()
			
			window.rowBackgroundColorTexture:SetTexture (r, g, b, a)
		end
		
		local canceledRowBackgroundColor = function()
			local c =  window.instance.barrasInfo.texturaBackgroundColor
			c [1], c [2], c [3], c [4] = unpack (ColorPickerFrame.previousValues)
			
			window.instance:RefreshBars()
			window.instance:InstanceReset()
			window.instance:InstanceRefreshRows()
			
			ColorPickerFrame.func = nil
			ColorPickerFrame.opacityFunc = nil
			ColorPickerFrame.cancelFunc = nil
		end
		
		local selectedRowBackgroundAlpha = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = OpacitySliderFrame:GetValue()
			
			local c =  window.instance.barrasInfo.texturaBackgroundColor
			c [1], c [2], c [3], c [4] = r, g, b, a
			
			window.instance:RefreshBars()
			window.instance:InstanceReset()
			window.instance:InstanceRefreshRows()
			
			window.rowBackgroundColorTexture:SetTexture (r, g, b, a)
		end
		
		local colorpickRowBackground = function()
			ColorPickerFrame.func = selectedRowBackgroundColor
			ColorPickerFrame.opacityFunc = selectedRowBackgroundAlpha
			ColorPickerFrame.cancelFunc = canceledRowBackgroundColor
			ColorPickerFrame.hasOpacity = true --false
			ColorPickerFrame.opacity = window.instance.barrasInfo.texturaBackgroundColor[4]
			ColorPickerFrame.previousValues = window.instance.barrasInfo.texturaBackgroundColor
			ColorPickerFrame:SetParent (window.widget)
			ColorPickerFrame:SetColorRGB (unpack (window.instance.barrasInfo.texturaBackgroundColor))
			ColorPickerFrame:Show()
		end

		g:NewImage (window, _, "$parentRowBackgroundColor", "rowBackgroundColorTexture", 120, 12)
		window.rowBackgroundColorTexture:SetPoint ("left", window.rowBackgroundColorLabel, "right", 2)
		window.rowBackgroundColorTexture:SetTexture (1, 1, 1)
		
		g:NewButton (window, _, "$parentRowBackgroundColorButton", "rowBackgroundColorButton", 120, 14, colorpickRowBackground)
		window.rowBackgroundColorButton:SetPoint ("left", window.rowBackgroundColorLabel, "right", 2)
		window.rowBackgroundColorButton:InstallCustomTexture()
	
	--------------- back background with class color
	
		g:NewLabel (window, _, "$parentRowBackgroundClassColorLabel", "rowBackgroundColorByClassLabel", "background by class")
		window.rowBackgroundColorByClassLabel:SetPoint (250, -143)
	
		g:NewSwitch (window, _, "$parentBackgroundClassColorSlider", "rowBackgroundColorByClassSlider", 60, 20, _, _, instance.barrasInfo.texturaBackgroundByClass)
		window.rowBackgroundColorByClassSlider:SetPoint ("left", window.rowBackgroundColorByClassLabel, "right", 2)
		window.rowBackgroundColorByClassSlider.tooltip = ""
		window.rowBackgroundColorByClassSlider.OnSwitch = function (self, instance, value)
			instance.barrasInfo.texturaBackgroundByClass = value
			instance:RefreshBars()
			instance:InstanceReset()
			instance:InstanceRefreshRows()
		end
		
	--------------- Bar Height
		g:NewLabel (window, _, "$parentRowHeightLabel", "rowHeightLabel", "bar height")
		window.rowHeightLabel:SetPoint (250, -163)
		--
		g:NewSlider (window, _, "$parentSliderRowHeight", "rowHeightSlider", 170, 20, 10, 30, 1, tonumber (instance.barrasInfo.altura)) --parent, container, name, member, w, h, min, max, step, defaultv
		window.rowHeightSlider:SetPoint ("left", window.rowHeightLabel, "right", 2)
		window.rowHeightSlider:SetThumbSize (50)
		window.rowHeightSlider:SetHook ("OnValueChange", function (self, instance, amount) 
			instance.barrasInfo.altura = amount
			instance.barrasInfo.alturaReal = instance.barrasInfo.altura+instance.barrasInfo.espaco.entre
			instance:RefreshBars()
			instance:InstanceReset()
			instance:ReajustaGump()
		end)
		
	--------------- Background
	
		local onSelectSecTexture = function (self, instance, texturePath) 
			
			if (texturePath:find ("TALENTFRAME")) then
				instance:InstanceWallpaper (texturePath, nil, nil, {0, 1, 0, 0.703125})
			else
				instance:InstanceWallpaper (texturePath, nil, nil, {0, 1, 0, 1})
			end
		end
	
		local subMenu = {
			
			["ARCHEOLOGY"] = {
				{value = [[Interface\ARCHEOLOGY\Arch-BookCompletedLeft]], label = "Book Wallpaper", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-BookCompletedLeft]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\Arch-BookItemLeft]], label = "Book Wallpaper 2", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-BookItemLeft]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\Arch-Race-DraeneiBIG]], label = "Draenei", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-DraeneiBIG]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\Arch-Race-DwarfBIG]], label = "Dwarf", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-DwarfBIG]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\Arch-Race-NightElfBIG]], label = "Night Elf", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-NightElfBIG]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\Arch-Race-OrcBIG]], label = "Orc", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-OrcBIG]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\Arch-Race-PandarenBIG]], label = "Pandaren", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-PandarenBIG]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\Arch-Race-TrollBIG]], label = "Troll", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-TrollBIG]], texcoord = nil},

				{value = [[Interface\ARCHEOLOGY\ArchRare-AncientShamanHeaddress]], label = "Ancient Shaman", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-AncientShamanHeaddress]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\ArchRare-BabyPterrodax]], label = "Baby Pterrodax", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-BabyPterrodax]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\ArchRare-ChaliceMountainKings]], label = "Chalice Mountain Kings", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ChaliceMountainKings]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\ArchRare-ClockworkGnome]], label = "Clockwork Gnomes", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ClockworkGnome]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\ArchRare-QueenAzsharaGown]], label = "Queen Azshara Gown", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-QueenAzsharaGown]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\ArchRare-QuilinStatue]], label = "Quilin Statue", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-QuilinStatue]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\Arch-TempRareSketch]], label = "Rare Sketch", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-TempRareSketch]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\ArchRare-ScepterofAzAqir]], label = "Scepter of Az Aqir", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ScepterofAzAqir]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\ArchRare-ShriveledMonkeyPaw]], label = "Shriveled Monkey Paw", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ShriveledMonkeyPaw]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\ArchRare-StaffofAmmunrae]], label = "Staff of Ammunrae", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-StaffofAmmunrae]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\ArchRare-TinyDinosaurSkeleton]], label = "Tiny Dinosaur", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-TinyDinosaurSkeleton]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\ArchRare-TyrandesFavoriteDoll]], label = "Tyrandes Favorite Doll", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-TyrandesFavoriteDoll]], texcoord = nil},
				{value = [[Interface\ARCHEOLOGY\ArchRare-ZinRokhDestroyer]], label = "ZinRokh Destroyer", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ZinRokhDestroyer]], texcoord = nil},
			},
		
			["CREDITS"] = {
				{value = [[Interface\Glues\CREDITS\Arakkoa2]], label = "Arakkoa", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Arakkoa2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Arcane_Golem2]], label = "Arcane Golem", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Arcane_Golem2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Badlands3]], label = "Badlands", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Badlands3]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\BD6]], label = "Draenei", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\BD6]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Draenei_Character1]], label = "Draenei 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_Character1]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Draenei_Character2]], label = "Draenei 3", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_Character2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Draenei_Crest2]], label = "Draenei Crest", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_Crest2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Draenei_Female2]], label = "Draenei 4", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_Female2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Draenei2]], label = "Draenei 5", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Blood_Elf_One1]], label = "Kael'thas", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Blood_Elf_One1]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\BD2]], label = "Blood Elf", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\BD2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\BloodElf_Priestess_Master2]], label = "Blood elf 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\BloodElf_Priestess_Master2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Female_BloodElf2]], label = "Blood Elf 3", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Female_BloodElf2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\CinSnow01TGA3]], label = "Cin Snow", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\CinSnow01TGA3]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\DalaranDomeTGA3]], label = "Dalaran", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\DalaranDomeTGA3]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Darnasis5]], label = "Darnasus", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Darnasis5]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Draenei_CityInt5]], label = "Exodar", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_CityInt5]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Shattrath6]], label = "Shattrath", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Shattrath6]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Demon_Chamber2]], label = "Demon Chamber", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Demon_Chamber2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Demon_Chamber6]], label = "Demon Chamber 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Demon_Chamber6]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Dwarfhunter1]], label = "Dwarf Hunter", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Dwarfhunter1]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Fellwood5]], label = "Fellwood", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Fellwood5]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\HordeBanner1]], label = "Horde Banner", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\HordeBanner1]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Illidan_Concept1]], label = "Illidan", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Illidan_Concept1]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Illidan1]], label = "Illidan 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Illidan1]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Naaru_CrashSite2]], label = "Naaru Crash", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Naaru_CrashSite2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\NightElves1]], label = "Night Elves", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\NightElves1]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Ocean2]], label = "Mountain", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Ocean2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Tempest_Keep2]], label = "Tempest Keep", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Tempest_Keep2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Tempest_Keep6]], label = "Tempest Keep 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Tempest_Keep6]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Terrokkar6]], label = "Terrokkar", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Terrokkar6]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\ThousandNeedles2]], label = "Thousand Needles", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\ThousandNeedles2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\Troll2]], label = "Troll", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Troll2]], texcoord = nil},
				{value = [[Interface\Glues\CREDITS\LESSERELEMENTAL_FIRE_03B1]], label = "Fire Elemental", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\LESSERELEMENTAL_FIRE_03B1]], texcoord = nil},
			},
		
			["DEATHKNIGHT"] = {
				{value = [[Interface\TALENTFRAME\bg-deathknight-blood]], label = "Blood", onclick = onSelectSecTexture, icon = [[Interface\ICONS\Spell_Deathknight_BloodPresence]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-deathknight-frost]], label = "Frost", onclick = onSelectSecTexture, icon = [[Interface\ICONS\Spell_Deathknight_FrostPresence]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-deathknight-unholy]], label = "Unholy", onclick = onSelectSecTexture, icon = [[Interface\ICONS\Spell_Deathknight_UnholyPresence]], texcoord = nil}
			},
			
			["DRESSUP"] = {
				{value = [[Interface\DRESSUPFRAME\DressUpBackground-BloodElf1]], label = "Blood Elf", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.5, 0.625, 0.75, 1}},
				{value = [[Interface\DRESSUPFRAME\DressUpBackground-DeathKnight1]], label = "Death Knight", onclick = onSelectSecTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["DEATHKNIGHT"]},
				{value = [[Interface\DRESSUPFRAME\DressUpBackground-Draenei1]], label = "Draenei", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.5, 0.625, 0.5, 0.75}},
				{value = [[Interface\DRESSUPFRAME\DressUpBackground-Dwarf1]], label = "Dwarf", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.125, 0.25, 0, 0.25}},
				{value = [[Interface\DRESSUPFRAME\DRESSUPBACKGROUND-GNOME1]], label = "Gnome", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.25, 0.375, 0, 0.25}},
				{value = [[Interface\DRESSUPFRAME\DressUpBackground-Goblin1]], label = "Goblin", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.625, 0.75, 0.75, 1}},
				{value = [[Interface\DRESSUPFRAME\DressUpBackground-Human1]], label = "Human", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0, 0.125, 0.5, 0.75}},
				{value = [[Interface\DRESSUPFRAME\DressUpBackground-NightElf1]], label = "Night Elf", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.375, 0.5, 0, 0.25}},
				{value = [[Interface\DRESSUPFRAME\DressUpBackground-Orc1]], label = "Orc", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.375, 0.5, 0.25, 0.5}},
				{value = [[Interface\DRESSUPFRAME\DressUpBackground-Pandaren1]], label = "Pandaren", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.75, 0.875, 0.5, 0.75}},
				{value = [[Interface\DRESSUPFRAME\DressUpBackground-Tauren1]], label = "Tauren", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0, 0.125, 0.25, 0.5}},
				{value = [[Interface\DRESSUPFRAME\DRESSUPBACKGROUND-TROLL1]], label = "Troll", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.25, 0.375, 0.75, 1}},
				{value = [[Interface\DRESSUPFRAME\DressUpBackground-Scourge1]], label = "Undead", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.125, 0.25, 0.75, 1}},
				{value = [[Interface\DRESSUPFRAME\DressUpBackground-Worgen1]], label = "Worgen", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.625, 0.75, 0, 0.25}},
			},
			
			["DRUID"] = {
				{value = [[Interface\TALENTFRAME\bg-druid-bear]], label = "Guardian", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_racial_bearform]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-druid-restoration]], label = "Restoration", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_healingtouch]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-druid-cat]], label = "Feral", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_vampiricaura]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-druid-balance]], label = "Balance", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_starfall]], texcoord = nil}
			},
			
			["HUNTER"] = {
				{value = [[Interface\TALENTFRAME\bg-hunter-beastmaster]], label = "Beast Mastery", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_hunter_bestialdiscipline]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-hunter-marksman]], label = "Marksmanship", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_hunter_focusedaim]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-hunter-survival]], label = "Survival", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_hunter_camouflage]], texcoord = nil}
			},
			
			["MAGE"] = {
				{value = [[Interface\TALENTFRAME\bg-mage-arcane]], label = "Arcane", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_magicalsentry]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-mage-fire]], label = "Fire", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_fire_firebolt02]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-mage-frost]], label = "Frost", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_frost_frostbolt02]], texcoord = nil}
			},

			["MONK"] = {
				{value = [[Interface\TALENTFRAME\bg-monk-brewmaster]], label = "Brewmaster", onclick = onSelectSecTexture, icon = [[Interface\ICONS\monk_stance_drunkenox]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-monk-mistweaver]], label = "Mistweaver", onclick = onSelectSecTexture, icon = [[Interface\ICONS\monk_stance_wiseserpent]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-monk-battledancer]], label = "Windwalker", onclick = onSelectSecTexture, icon = [[Interface\ICONS\monk_stance_whitetiger]], texcoord = nil}
			},

			["PALADIN"] = {
				{value = [[Interface\TALENTFRAME\bg-paladin-holy]], label = "Holy", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_holybolt]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-paladin-protection]], label = "Protection", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_paladin_shieldofthetemplar]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-paladin-retribution]], label = "Retribution", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_auraoflight]], texcoord = nil}
			},
			
			["PRIEST"] = {
				{value = [[Interface\TALENTFRAME\bg-priest-discipline]], label = "Discipline", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_powerwordshield]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-priest-holy]], label = "Holy", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_guardianspirit]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-priest-shadow]], label = "Shadow", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_shadowwordpain]], texcoord = nil}
			},

			["ROGUE"] = {
				{value = [[Interface\TALENTFRAME\bg-rogue-assassination]], label = "Assassination", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_rogue_eviscerate]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-rogue-combat]], label = "Combat", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_backstab]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-rogue-subtlety]], label = "Subtlety", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_stealth]], texcoord = nil}
			},

			["SHAMAN"] = {
				{value = [[Interface\TALENTFRAME\bg-shaman-elemental]], label = "Elemental", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_lightning]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-shaman-enhancement]], label = "Enhancement", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_lightningshield]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-shaman-restoration]], label = "Restoration", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_magicimmunity]], texcoord = nil}	
			},
			
			["WARLOCK"] = {
				{value = [[Interface\TALENTFRAME\bg-warlock-affliction]], label = "Affliction", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_deathcoil]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-warlock-demonology]], label = "Demonology", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_metamorphosis]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-warlock-destruction]], label = "Destruction", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_rainoffire]], texcoord = nil}
			},
			["WARRIOR"] = {
				{value = [[Interface\TALENTFRAME\bg-warrior-arms]], label = "Arms", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_warrior_savageblow]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-warrior-fury]], label = "Fury", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_warrior_innerrage]], texcoord = nil},
				{value = [[Interface\TALENTFRAME\bg-warrior-protection]], label = "Protection", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_warrior_defensivestance]], texcoord = nil}
			},
		}
	
		local buildBackgroundMenu2 = function() 
			return  subMenu [window.backgroundDropdown.value] or {label = "-- -- --", value = 0}
		end
	
		local onSelectMainTexture = function (_, instance, choose)
			window.backgroundDropdown2:Select (choose)
		end
	
		local backgroundTable = {
			{value = "ARCHEOLOGY", label = "Archeology", onclick = onSelectMainTexture, icon = [[Interface\ARCHEOLOGY\Arch-Icon-Marker]]},
			{value = "CREDITS", label = "Burning Crusade", onclick = onSelectMainTexture, icon = [[Interface\ICONS\TEMP]]},
			{value = "DEATHKNIGHT", label = "Death Knight", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["DEATHKNIGHT"]},
			{value = "DRESSUP", label = "Class Background", onclick = onSelectMainTexture, icon = [[Interface\ICONS\INV_Chest_Cloth_17]]},
			{value = "DRUID", label = "Druid", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["DRUID"]},
			{value = "HUNTER", label = "Hunter", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["HUNTER"]},
			{value = "MAGE", label = "Mage", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["MAGE"]},
			{value = "MONK", label = "Monk", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["MONK"]},
			{value = "PALADIN", label = "Paladin", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["PALADIN"]},
			{value = "PRIEST", label = "Priest", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["PRIEST"]},
			{value = "ROGUE", label = "Rogue", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["ROGUE"]},
			{value = "SHAMAN", label = "Shaman", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["SHAMAN"]},
			{value = "WARLOCK", label = "Warlock", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["WARLOCK"]},
			{value = "WARRIOR", label = "Warrior", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["WARRIOR"]},
		}
		local buildBackgroundMenu = function() return backgroundTable end
		
		g:NewLabel (window, _, "$parentBackgroundLabel", "backgroundLabel", "enable wallpaper")
		window.backgroundLabel:SetPoint (250, -185)
		--
		g:NewSwitch (window, _, "$parentUseBackgroundSlider", "useBackgroundSlider", 60, 20, _, _, window.instance.wallpaper.enabled)
		window.useBackgroundSlider:SetPoint ("left", window.backgroundLabel, "right", 2, 0)
		window.useBackgroundSlider.OnSwitch = function (self, instance, value) --> slider, fixedValue, sliderValue
		window.useBackgroundSlider.tooltip = "enable or disable wallpaper in this instante\nselect the group on the left box and the image on the right.\nalso, you can edit the image through edit image button."
			instance.wallpaper.enabled = value
			if (value) then
				--> primeira vez que roda:
				if (not instance.wallpaper.texture) then
					local spec = GetSpecialization()
					if (spec) then
						local id, name, description, icon, _background, role = GetSpecializationInfo (spec)
						if (_background) then
							instance.wallpaper.texture = "Interface\\TALENTFRAME\\".._background
						end
					end
					instance.wallpaper.texcoord = {0, 1, 0, 0.703125}
				end
				
				instance:InstanceWallpaper (true)
				_G.DetailsOptionsWindowBackgroundDropdown.MyObject:Enable()
				_G.DetailsOptionsWindowBackgroundDropdown2.MyObject:Enable()
				
			else
				instance:InstanceWallpaper (false)
				_G.DetailsOptionsWindowBackgroundDropdown.MyObject:Disable()
				_G.DetailsOptionsWindowBackgroundDropdown2.MyObject:Disable()
			end
		end
		
		g:NewLabel (window, _, "$parentBackgroundLabel", "backgroundLabel", "wallpaper group")
		window.backgroundLabel:SetPoint (250, -200)
		g:NewLabel (window, _, "$parentBackgroundLabel", "backgroundLabel", "select wallpaper")
		window.backgroundLabel:SetPoint (370, -200)
		--
		g:NewDropDown (window, _, "$parentBackgroundDropdown", "backgroundDropdown", 120, 20, buildBackgroundMenu, nil)
		window.backgroundDropdown:SetPoint (250, -215)
		--
		g:NewDropDown (window, _, "$parentBackgroundDropdown2", "backgroundDropdown2", 120, 20, buildBackgroundMenu2, nil)
		window.backgroundDropdown2:SetPoint (370, -215)

		
		local onSelectAnchor = function (_, instance, anchor)
			instance:InstanceWallpaper (nil, anchor)
		end
		local anchorMenu = {
			{value = "all", label = "Fill", onclick = onSelectAnchor},
			{value = "center", label = "Center", onclick = onSelectAnchor},
			{value = "stretchLR", label = "Stretch Left-Right", onclick = onSelectAnchor},
			{value = "stretchTB", label = "Stretch Top-Bottom", onclick = onSelectAnchor},
			{value = "topleft", label = "Top Left", onclick = onSelectAnchor},
			{value = "bottomleft", label = "Bottom Left", onclick = onSelectAnchor},
			{value = "topright", label = "Top Right", onclick = onSelectAnchor},
			{value = "bottomright", label = "Bottom Right", onclick = onSelectAnchor},
		}
		local buildAnchorMenu = function()
			return anchorMenu
		end

		local callmeback = function (width, height, overlayColor, alpha, texCoords)
			local tinstance = _G ["DetailsOptionsWindow"].MyObject.instance
			tinstance:InstanceWallpaper (nil, nil, alpha, texCoords, width, height, overlayColor)
		end
		
		local startImageEdit = function()
			local tinstance = _G ["DetailsOptionsWindow"].MyObject.instance
			
			if (tinstance.wallpaper.texture:find ("TALENTFRAME")) then
				g:ImageEditor (callmeback, tinstance.wallpaper.texture, tinstance.wallpaper.texcoord, tinstance.wallpaper.overlay, window.instance.baseframe.wallpaper:GetWidth(), window.instance.baseframe.wallpaper:GetHeight())
			else
				tinstance.wallpaper.overlay [4] = 0.5
				g:ImageEditor (callmeback, tinstance.wallpaper.texture, tinstance.wallpaper.texcoord, tinstance.wallpaper.overlay, window.instance.baseframe.wallpaper:GetWidth(), window.instance.baseframe.wallpaper:GetHeight())
			end
		end
		
		g:NewLabel (window, _, "$parentAnchorLabel", "anchorLabel", "align")
		window.anchorLabel:SetPoint (250, -240)
		--
		g:NewDropDown (window, _, "$parentAnchorDropdown", "anchorDropdown", 100, 20, buildAnchorMenu, nil)
		window.anchorDropdown:SetPoint ("left", window.anchorLabel, "right", 2)
		--
		g:NewButton (window, _, "$parentEditImage", "editImage", 100, 18, startImageEdit, nil, nil, nil, "edit image")
		window.editImage:InstallCustomTexture()
		window.editImage:SetPoint ("left", window.anchorDropdown, "right", 2)
		
		--
		
	--------------- Alpha
		g:NewLabel (window, _, "$parentAlphaLabel", "alphaLabel", "transparency")
		window.alphaLabel:SetPoint (250, -270)
		--
		g:NewSlider (window, _, "$parentAlphaSlider", "alphaSlider", 130, 20, 0.02, 1, 0.02, instance.bg_alpha, true) -- min, max, step, defaultv
		window.alphaSlider:SetPoint ("left", window.alphaLabel, "right", 2, 0)
		window.alphaSlider.useDecimals = true
		window.alphaSlider:SetHook ("OnValueChange", function (self, instance, amount) --> slider, fixedValue, sliderValue
			self.amt:SetText (string.format ("%.2f", amount))
			instance:SetBackgroundAlpha (amount)
			return true
		end)
		window.alphaSlider.thumb:SetSize (30+(120*0.2)+2, 20*1.2)
		window.alphaSlider.tooltip = "Change the background alpha for this instance"
		
		local selectedBackgroundColor = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			window.instance:SetBackgroundColor (r, g, b)
			window.backgroundColorTexture:SetTexture (r, g, b)
		end
		
		local canceledBackgroundColor = function()
			local c = ColorPickerFrame.previousValues
			window.instance:SetBackgroundColor (unpack (c))
			window.backgroundColorTexture:SetTexture (unpack (c))
			ColorPickerFrame.func = nil
			ColorPickerFrame.cancelFunc = nil
		end
		
		local colorpickBackgroundColor = function()
			ColorPickerFrame.func = selectedBackgroundColor
			ColorPickerFrame.cancelFunc = canceledBackgroundColor
			ColorPickerFrame.opacityFunc = nil
			ColorPickerFrame.hasOpacity = false
			ColorPickerFrame.previousValues = {window.instance.bg_r, window.instance.bg_g, window.instance.bg_b}
			ColorPickerFrame:SetParent (window.widget)
			ColorPickerFrame:SetColorRGB (window.instance.bg_r, window.instance.bg_g, window.instance.bg_b)
			ColorPickerFrame:Show()
		end

		g:NewImage (window, _, "$parentBackgroundColorTexture", "backgroundColorTexture", 40, 14)
		window.backgroundColorTexture:SetPoint ("left", window.alphaSlider, "right", 5)
		window.backgroundColorTexture:SetTexture (1, 1, 1)
		
		g:NewButton (window, _, "$parentBackgroundColorButton", "backgroundColorButton", 40, 20, colorpickBackgroundColor)
		window.backgroundColorButton:SetPoint ("left", window.alphaSlider, "right", 5)
		window.backgroundColorButton:InstallCustomTexture()
	--------------- Auto Current Segment
	
		g:NewLabel (window, _, "$parentAutoCurrentLabel", "autoCurrentLabel", "auto switch to current")
		window.autoCurrentLabel:SetPoint (250, -293)
	
		g:NewSwitch (window, _, "$parentAutoCurrentSlider", "autoCurrentSlider", 60, 20, _, _, instance.auto_current)
		window.autoCurrentSlider:SetPoint ("left", window.autoCurrentLabel, "right", 2)
		window.autoCurrentSlider.tooltip = "Whenever a combat start and there is no other instance on\ncurrent segment, this instance auto switch to current segment."
		window.autoCurrentSlider.OnSwitch = function (self, instance, value)
			instance.auto_current = value
		end
		
	--------------- Bar and Text Color 
	
		-- BAR TEXTURE
		g:NewLabel (window, _, "$parentUseClassColorsLabel", "classColorsLabel", "bar texture: class color")
		window.classColorsLabel:SetPoint (250, -313)
	
		g:NewSwitch (window, _, "$parentClassColorSlider", "classColorSlider", 60, 20, _, _, instance.row_texture_class_colors)
		window.classColorSlider:SetPoint ("left", window.classColorsLabel, "right", 2)
		window.classColorSlider.tooltip = "if enabled, bar color matches the class, \nelse, a fixed color is used for all bars."
		window.classColorSlider.OnSwitch = function (self, instance, value)
			instance.row_texture_class_colors = value
			instance:InstanceReset()
			instance:InstanceRefreshRows()
		end
		-- LEFT TEXT
		g:NewLabel (window, _, "$parentUseClassColorsLeftText", "classColorsLeftTextLabel", "left text: class color")
		window.classColorsLeftTextLabel:SetPoint (250, -333)
	
		g:NewSwitch (window, _, "$parentUseClassColorsLeftTextSlider", "classColorsLeftTextSlider", 60, 20, _, _, instance.row_textL_class_colors)
		window.classColorsLeftTextSlider:SetPoint ("left", window.classColorsLeftTextLabel, "right", 2)
		window.classColorsLeftTextSlider.tooltip = "if enabled, left bar text color matches the class, \nelse, a fixed color is used."
		window.classColorsLeftTextSlider.OnSwitch = function (self, instance, value)
			instance.row_textL_class_colors = value
			instance:InstanceReset()
			instance:InstanceRefreshRows()
		end
		-- RIGHT TEXT
		g:NewLabel (window, _, "$parentUseClassColorsRightText", "classColorsRightTextLabel", "right text: class color")
		window.classColorsRightTextLabel:SetPoint (250, -347)
	
		g:NewSwitch (window, _, "$parentUseClassColorsRightTextSlider", "classColorsRightTextSlider", 60, 20, _, _, instance.row_textR_class_colors)
		window.classColorsRightTextSlider:SetPoint ("left", window.classColorsRightTextLabel, "right", 2)
		window.classColorsRightTextSlider.tooltip = "if enabled, right bar text color matches the class, \nelse, a fixed color is used."
		window.classColorsRightTextSlider.OnSwitch = function (self, instance, value)
			instance.row_textR_class_colors = value
			instance:InstanceReset()
			instance:InstanceRefreshRows()
		end
		-- ROW TEXTURE COLOR
		local selectedColorClass = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			window.fixedRowColorTexture:SetTexture (r, g, b)
			window.instance.fixed_row_texture_color[1], window.instance.fixed_row_texture_color[2], window.instance.fixed_row_texture_color[3] = r, g, b
			instance:InstanceReset()
			instance:InstanceRefreshRows()
		end
		
		local canceledColorClass = function()
			local c = ColorPickerFrame.previousValues
			window.fixedRowColorTexture:SetTexture (c [1], c [2], c [3])
			
			window.instance.fixed_row_texture_color[1], window.instance.fixed_row_texture_color[2], window.instance.fixed_row_texture_color[3] = c [1], c [2], c [3]

			ColorPickerFrame.func = nil
			ColorPickerFrame.cancelFunc = nil
			instance:InstanceReset()
			instance:InstanceRefreshRows()
		end
		
		local colorpickClass = function()
			ColorPickerFrame.func = selectedColorClass
			ColorPickerFrame.cancelFunc = canceledColorClass
			ColorPickerFrame.opacityFunc = nil
			ColorPickerFrame.hasOpacity = false
			ColorPickerFrame.previousValues = window.instance.fixed_row_texture_color
			ColorPickerFrame:SetParent (window.widget)
			ColorPickerFrame:SetColorRGB (unpack (window.instance.fixed_row_texture_color))
			ColorPickerFrame:Show()
		end

		g:NewImage (window, _, "$parentFixedRowColorTexture", "fixedRowColorTexture", 55, 14)
		window.fixedRowColorTexture:SetPoint ("left", window.classColorSlider, "right", 5)
		window.fixedRowColorTexture:SetTexture (1, 1, 1)
		
		g:NewButton (window, _, "$parentFixedRowColorButton", "fixedRowColorButton", 55, 20, colorpickClass)
		window.fixedRowColorButton:SetPoint ("left", window.fixedRowColorTexture, "left")
		window.fixedRowColorButton:InstallCustomTexture()
		
		-- TEXT COLOR
		local selectedTextColor = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			window.fixedRowColorText:SetTexture (r, g, b)
			window.instance.fixed_row_text_color[1], window.instance.fixed_row_text_color[2], window.instance.fixed_row_text_color[3] = r, g, b
			instance:InstanceReset()
			instance:InstanceRefreshRows()
		end
		
		local canceledTextColor = function()
			local c = ColorPickerFrame.previousValues
			window.fixedRowColorText:SetTexture (c [1], c [2], c [3])
			
			window.instance.fixed_row_text_color[1], window.instance.fixed_row_text_color[2], window.instance.fixed_row_text_color[3] = c [1], c [2], c [3]

			ColorPickerFrame.func = nil
			ColorPickerFrame.cancelFunc = nil
			instance:InstanceReset()
			instance:InstanceRefreshRows()
		end
		
		local colorpickTextColor = function()
			ColorPickerFrame.func = selectedTextColor
			ColorPickerFrame.cancelFunc = canceledTextColor
			ColorPickerFrame.opacityFunc = nil
			ColorPickerFrame.hasOpacity = false
			ColorPickerFrame.previousValues = window.instance.fixed_row_text_color
			ColorPickerFrame:SetParent (window.widget)
			ColorPickerFrame:SetColorRGB (unpack (window.instance.fixed_row_text_color))
			ColorPickerFrame:Show()
		end

		g:NewImage (window, _, "$parentFixedRowColorTTexture", "fixedRowColorText", 55, 25)
		window.fixedRowColorText:SetPoint ("topleft", window.classColorsLeftTextSlider, "topright", 10, -5)
		window.fixedRowColorText:SetPoint ("bottomleft", window.classColorsRightTextSlider, "bottomright", 10, 5)
		window.fixedRowColorText:SetTexture (1, 1, 1)
		
		g:NewButton (window, _, "$parentFixedRowColorTButton", "fixedRowColorTButton", 55, 25, colorpickTextColor)
		window.fixedRowColorTButton:SetPoint ("topleft", window.classColorsLeftTextSlider, "topright", 10, -5)
		window.fixedRowColorTButton:SetPoint ("bottomleft", window.classColorsRightTextSlider, "bottomright", 10, 5)
		window.fixedRowColorTButton:InstallCustomTexture()
		
		-- LEFT TEXT OUTLINE
		g:NewLabel (window, _, "$parentTextLeftOutlineLabel", "textLeftOutlineLabel", "left text: outline")
		window.textLeftOutlineLabel:SetPoint (250, -373)
	
		g:NewSwitch (window, _, "$parentTextLeftOutlineSlider", "textLeftOutlineSlider", 60, 20, _, _, instance.row_textL_outline)
		window.textLeftOutlineSlider:SetPoint ("left", window.textLeftOutlineLabel, "right", 2)
		window.textLeftOutlineSlider.tooltip = "if enabled, left text is outlined"
		window.textLeftOutlineSlider.OnSwitch = function (self, instance, value)
			instance.row_textL_outline = value
			instance:InstanceReset()
			instance:InstanceRefreshRows()
		end
		-- RIGHT TEXT OUTLINE
		g:NewLabel (window, _, "$parentTextRightOutlineLabel", "textRightOutlineLabel", "right text: outline")
		window.textRightOutlineLabel:SetPoint (250, -388)
	
		g:NewSwitch (window, _, "$parentTextRightOutlineSlider", "textRightOutlineSlider", 60, 20, _, _, instance.row_textR_outline)
		window.textRightOutlineSlider:SetPoint ("left", window.textRightOutlineLabel, "right", 2)
		window.textRightOutlineSlider.tooltip = "if enabled, right text is outlined"
		window.textRightOutlineSlider.OnSwitch = function (self, instance, value)
			instance.row_textR_outline = value
			instance:InstanceReset()
			instance:InstanceRefreshRows()
		end
		
----------------------- Save Style Text Entry and Button -----------------------------------------
	
		----- style name
		g:NewTextEntry (window, _, "$parentSaveStyleName", "saveStyleName", nil, 20, _, _, _, 178) --width will be auto adjusted if space parameter is passed
		window.saveStyleName:SetLabelText ("style name:")
		window.saveStyleName:SetPoint (250, -450)
	
		local saveStyleFunc = function()
			if (not window.saveStyleName.text or window.saveStyleName.text == "") then
				_detalhes:Msg ("Give a name for your style.")
				return
			end
			local w = window.instance.wallpaper
			local savedObject = {
				name = window.saveStyleName.text,
				texture = window.textureDropdown.value,
				fontSize = tonumber (window.fonsizeSlider.value),
				fontFace = window.fontDropdown.value, 
				color = {unpack (window.instance.color)},
				wallpaper = {texture = w.texture, enabled = w.enabled, texcoord = {unpack (w.texcoord)}, overlay = {unpack(w.overlay)}, anchor = w.anchor, height = w.height, alpha = w.alpha, width = w.width},
				bg_colors = {window.instance.bg_r, window.instance.bg_g, window.instance.bg_b},
				alpha = tonumber (window.alphaSlider.value),
				texture_class = window.instance.row_texture_class_colors,
				row_textL_class = window.instance.row_textL_class_colors,
				row_textR_class = window.instance.row_textR_class_colors,
				row_textL_outline = window.instance.row_textL_outline,
				row_textR_outline = window.instance.row_textR_outline,
				fixed_row_texture_color = {unpack (window.instance.fixed_row_texture_color)},
				fixed_row_text_color = {unpack (window.instance.fixed_row_text_color)},
				texture_background = window.instance.barrasInfo.texturaBackground,
				texture_background_color = {unpack (window.instance.barrasInfo.texturaBackgroundColor)},
				texture_background_by_class = window.instance.barrasInfo.texturaBackgroundByClass,
				texture_name_background = window.instance.barrasInfo.textureNameBackground
			}
			
			_detalhes.savedStyles [#_detalhes.savedStyles+1] = savedObject
			window.saveStyleName.text = ""
		end
		----- add style button
		g:NewButton (window, _, "$parentSaveStyleButton", "saveStyle", 32, 19, saveStyleFunc, nil, nil, nil, "save")
		window.saveStyle:InstallCustomTexture()
		window.saveStyle:SetPoint ("left", window.saveStyleName, "right", 2)
		
		----- load style button
		g:NewButton (window, _, "$parentLoadStyleButton", "loadStyle", 32, 19, nil, nil, nil, nil, "load")
		window.loadStyle:InstallCustomTexture()
		window.loadStyle:SetPoint ("left", window.saveStyle, "right", 2)
	
		local loadStyle = function (_, instance, index)
			local style = _detalhes.savedStyles [index]
			--texture
			instance.barrasInfo.textura = SharedMedia:Fetch ("statusbar", style.texture)
			instance.barrasInfo.textureName = style.texture
			--fontface
			instance.barrasInfo.font = SharedMedia:Fetch ("font", style.fontFace)
			instance.barrasInfo.fontName = style.fontFace
			--fontsize
			instance.barrasInfo.fontSize = tonumber (style.fontSize)
			--color
			instance:InstanceColor (style.color)
			--wallpaper
			instance:InstanceWallpaper (style.wallpaper)
			--alpha
			instance:SetBackgroundAlpha (style.alpha or _detalhes.default_bg_alpha)
			instance:SetBackgroundColor (style.bg_colors)
			--texture e texts
			instance.row_texture_class_colors = style.texture_class
			instance.row_textL_class_colors = style.row_textL_class
			instance.row_textR_class_colors = style.row_textR_class
			instance.row_textL_outline = style.row_textL_outline
			instance.row_textR_outline = style.row_textR_outline
			instance.fixed_row_texture_color = {unpack (style.fixed_row_texture_color)}
			instance.fixed_row_text_color = {unpack (style.fixed_row_text_color)}
			--row background
			instance.barrasInfo.texturaBackground = style.texture_background
			instance.barrasInfo.texturaBackgroundColor = {unpack (style.texture_background_color)}
			instance.barrasInfo.texturaBackgroundByClass = style.texture_background_by_class
			instance.barrasInfo.textureNameBackground = style.texture_name_background
			--refresh
			instance:RefreshBars()
			instance:InstanceReset()
			instance:InstanceRefreshRows()
			--update options
			
			_G.DetailsOptionsWindowBackgroundClassColorSlider.MyObject:SetValue (style.texture_background_by_class)
			_G.DetailsOptionsWindowRowBackgroundTextureDropdown.MyObject:Select (style.texture_name_background)
			_G.DetailsOptionsWindowRowBackgroundColor.MyObject:SetTexture (unpack (style.texture_background_color))
			
			_G.DetailsOptionsWindowInstanceColorTexture.MyObject:SetTexture (unpack (style.color))
			_G.DetailsOptionsWindowTextureDropdown.MyObject:Select (style.texture)
			_G.DetailsOptionsWindowFontDropdown.MyObject:Select (style.fontFace)
			_G.DetailsOptionsWindowSliderFontSize.MyObject:SetValue (style.fontSize)
			_G.DetailsOptionsWindowAlphaSlider.MyObject:SetValue (style.alpha or _detalhes.default_bg_alpha)
			
			_G.DetailsOptionsWindowClassColorSlider.MyObject:SetValue (style.texture_class)
			_G.DetailsOptionsWindowUseClassColorsLeftTextSlider.MyObject:SetValue (style.row_textL_class)
			_G.DetailsOptionsWindowUseClassColorsRightTextSlider.MyObject:SetValue (style.row_textR_class)
			_G.DetailsOptionsWindowTextLeftOutlineSlider.MyObject:SetValue (style.row_textL_outline)
			_G.DetailsOptionsWindowTextRightOutlineSlider.MyObject:SetValue (style.row_textR_outline)
			_G.DetailsOptionsWindowUseBackgroundSlider.MyObject:SetValue (style.wallpaper.enabled)
			
		end
	
		local createLoadMenu = function()
			for index, _table in ipairs (_detalhes.savedStyles) do 
				GameCooltip:AddLine (_table.name)
				GameCooltip:AddMenu (1, loadStyle, index)
			end
		end
		window.loadStyle.CoolTip = {Type = "menu", BuildFunc = createLoadMenu, FixedValue = instance}
		GameCooltip:CoolTipInject (window.loadStyle)
		
		------ remove style button
		g:NewButton (window, _, "$parentRemoveStyleButton", "removeStyle", 12, 19, nil, nil, nil, nil, "x")
		window.removeStyle:InstallCustomTexture()
		window.removeStyle:SetPoint ("left", window.loadStyle, "right", 2)
		
		local removeStyle = function (_, _, index)
			table.remove (_detalhes.savedStyles, index)
			if (#_detalhes.savedStyles > 0) then 
				GameCooltip:ExecFunc (window.removeStyle)
			else
				GameCooltip:Close()
			end
		end
		
		local createRemoveMenu = function()
			for index, _table in ipairs (_detalhes.savedStyles) do 
				GameCooltip:AddLine (_table.name)
				GameCooltip:AddMenu (1, removeStyle, index)
			end
		end
		window.removeStyle.CoolTip = {Type = "menu", BuildFunc = createRemoveMenu}
		GameCooltip:CoolTipInject (window.removeStyle)
		
		------ apply to all button
		local applyToAll = function()
			for _, this_instance in ipairs (_detalhes.tabela_instancias) do 
				if (this_instance:IsAtiva() and this_instance.meu_id ~= window.instance.meu_id) then
					--texture
					this_instance.barrasInfo.textura = SharedMedia:Fetch ("statusbar", window.textureDropdown.value)
					this_instance.barrasInfo.textureName = window.textureDropdown.value
					--fontface
					this_instance.barrasInfo.font = SharedMedia:Fetch ("font", window.fontDropdown.value)
					this_instance.barrasInfo.fontName = window.fontDropdown.value
					--fontsize
					this_instance.barrasInfo.fontSize = window.fonsizeSlider.value
					--color
					this_instance:InstanceColor (window.instance.color)
					--wallpaper
					this_instance:InstanceWallpaper (window.instance.wallpaper)
					--alpha
					this_instance:SetBackgroundAlpha (window.instance.bg_alpha)
					this_instance:SetBackgroundColor (window.instance.bg_r, window.instance.bg_g, window.instance.bg_b)
					--texture e texts
					this_instance.row_texture_class_colors = window.instance.row_texture_class_colors
					this_instance.row_textL_class_colors = window.instance.row_textL_class_colors
					this_instance.row_textR_class_colors = window.instance.row_textR_class_colors
					this_instance.row_textL_outline = window.instance.row_textL_outline
					this_instance.row_textR_outline = window.instance.row_textR_outline
					--refresh
					this_instance:RefreshBars()
					this_instance:InstanceReset()
					this_instance:InstanceRefreshRows()
				end
			end
		end
		
		g:NewButton (window, _, "$parentToAllStyleButton", "applyToAll", 140, 14, applyToAll, nil, nil, nil, "apply to all instances")
		window.applyToAll:InstallCustomTexture()
		window.applyToAll:SetPoint ("bottomright", window.removeStyle, "topright", 1, 3)
		
		_detalhes.defaultStyle = {
			texture = "Details D'ictum",
			fontSize = 11,
			fontFace = "Arial Narrow",
			color = {1, 1, 1, 1},
			wallpaper = {enabled = false, texcoord = {0, 1, 0, 1},	overlay = {1, 1, 1, 1},  anchor = "all", height = 0, alpha = 0.5, width = 0},
			alpha = 0.7,
			bg_colors = {0.0941, 0.0941, 0.0941},
			texture_class = true,
			row_textL_class = false,
			row_textR_class = false,
			row_textL_outline = false,
			row_textR_outline = false
		}
		
		local resetToDefaults = function()
			local style = _detalhes.defaultStyle
			local instance = window.instance
			--texture
			instance.barrasInfo.textura = SharedMedia:Fetch ("statusbar", style.texture)
			instance.barrasInfo.textureName = style.texture
			--fontface
			instance.barrasInfo.font = SharedMedia:Fetch ("font", style.fontFace)
			instance.barrasInfo.fontName = style.fontFace
			--fontsize
			instance.barrasInfo.fontSize = tonumber (style.fontSize)
			--color
			instance:InstanceColor (style.color)
			instance:SetBackgroundColor (style.bg_colors)
			--wallpaper
			instance:InstanceWallpaper (style.wallpaper)
			--alpha
			instance:SetBackgroundAlpha (style.alpha or _detalhes.default_bg_alpha)
			--texture e texts
			instance.row_texture_class_colors = style.texture_class
			instance.fixed_row_texture_color = {0, 0, 0}
			instance.row_textL_class_colors = style.row_textL_class
			instance.row_textR_class_colors = style.row_textR_class
			instance.fixed_row_text_color = {1, 1, 1}
			instance.row_textL_outline = style.row_textL_outline
			instance.row_textR_outline = style.row_textR_outline
			--refresh
			instance:RefreshBars()
			instance:InstanceReset()
			instance:InstanceRefreshRows()
			--update options
			
			_G.DetailsOptionsWindowInstanceColorTexture.MyObject:SetTexture (unpack (style.color))
			_G.DetailsOptionsWindowBackgroundColorTexture.MyObject:SetTexture (unpack (style.bg_colors))
			_G.DetailsOptionsWindowFixedRowColorTexture.MyObject:SetTexture (0, 0, 0)
			_G.DetailsOptionsWindowFixedRowColorTTexture.MyObject:SetTexture (unpack (instance.fixed_row_text_color))
			_G.DetailsOptionsWindowTextureDropdown.MyObject:Select (style.texture)
			_G.DetailsOptionsWindowFontDropdown.MyObject:Select (style.fontFace)
			_G.DetailsOptionsWindowSliderFontSize.MyObject:SetValue (style.fontSize)
			_G.DetailsOptionsWindowAlphaSlider.MyObject:SetValue (style.alpha or _detalhes.default_bg_alpha)
			
			_G.DetailsOptionsWindowClassColorSlider.MyObject:SetValue (style.texture_class)
			_G.DetailsOptionsWindowUseClassColorsLeftTextSlider.MyObject:SetValue (style.row_textL_class)
			_G.DetailsOptionsWindowUseClassColorsRightTextSlider.MyObject:SetValue (style.row_textR_class)
			_G.DetailsOptionsWindowTextLeftOutlineSlider.MyObject:SetValue (style.row_textL_outline)
			_G.DetailsOptionsWindowTextRightOutlineSlider.MyObject:SetValue (style.row_textR_outline)
		end
		g:NewButton (window, _, "$parentResetToDefaultButton", "resetToDefaults", 100, 14, resetToDefaults, nil, nil, nil, "reset to default")
		window.resetToDefaults:InstallCustomTexture()
		window.resetToDefaults:SetPoint ("right", window.applyToAll, "left", -5, 0)
		
		
-- Persona --------------------------------------------------------------------------------------------------------------------------------------------

		local onPressEnter = function (_, _, text)
			local accepted, errortext = _detalhes:SetNickname (text)
			if (not accepted) then
				_detalhes:Msg (errortext)
			end
			--> we call again here, because if not accepted the box return the previous value and if successful accepted, update the value for formated string.
			window.nicknameEntry.text = _detalhes:GetNickname (UnitGUID ("player"), UnitName ("player"), true)
		end

		g:NewTextEntry (window, _, "$parentNicknameEntry", "nicknameEntry", nil, 20, onPressEnter, _, _, 198) --width will be auto adjusted if space parameter is passed
		window.nicknameEntry:SetLabelText ("nickname")
		window.nicknameEntry:SetPoint (510, -35)
		
		local avatarcallback = function (textureAvatar, textureAvatarTexCoord, textureBackground, textureBackgroundTexCoord, textureBackgroundColor)
			_detalhes:SetNicknameBackground (textureBackground, textureBackgroundTexCoord, textureBackgroundColor, true)
			_detalhes:SetNicknameAvatar (textureAvatar, textureAvatarTexCoord)
			_G.AvatarPickFrame.callback = nil
		end
		
		local openAtavarPickFrame = function()
			_G.AvatarPickFrame.callback = avatarcallback
			_G.AvatarPickFrame:Show()
		end
		
		g:NewButton (window, _, "$parentAvatarFrame", "chooseAvatarButton", 120, 14, openAtavarPickFrame, nil, nil, nil, "Choose Avatar")
		window.chooseAvatarButton:InstallCustomTexture()
		window.chooseAvatarButton:SetPoint (510, -55)
		
--  realm name --------------------------------------------------------------------------------------------------------------------------------------------

		g:NewLabel (window, _, "$parentRealmNameLabel", "realmNameLabel", "remove realm name")
		window.realmNameLabel:SetPoint (510, -80)
	
		g:NewSwitch (window, _, "$parentRealmNameSlider", "realmNameSlider", 60, 20, _, _, _detalhes.remove_realm_from_name)
		window.realmNameSlider:SetPoint ("left", window.realmNameLabel, "right", 2)
		window.realmNameSlider.tooltip = "When enabled and inside a instance, the realm name\nwill not be shown after the player name."
		window.realmNameSlider.OnSwitch = function (self, _, value)
			_detalhes.remove_realm_from_name = value
		end
		
--------SKINS
		g:NewLabel (window, _, "$parentSkinLabel", "skinLabel", "select skin")
		window.skinLabel:SetPoint (510, -100)
		--
		local onSelectSkin = function (_, instance, skin_name)
			instance:ChangeSkin (skin_name)
		end

		local buildSkinMenu = function()
			local skinOptions = {}
			for skin_name, skin_table in pairs (_detalhes.skins) do
				skinOptions [#skinOptions+1] = {value = skin_name, label = skin_name, onclick = onSelectSkin, icon = "Interface\\GossipFrame\\TabardGossipIcon", desc = skin_table.desc}
			end
			return skinOptions
		end
		
		g:NewDropDown (window, _, "$parentSkinDropdown", "skinDropdown", 120, 20, buildSkinMenu, 1) -- func, default
		window.skinDropdown:SetPoint ("left", window.skinLabel, "right", 2)
		
	end
	
	
----------------------------------------------------------------------------------------
--> Show

	_G.DetailsOptionsWindowSkinDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowSkinDropdown.MyObject:Select (instance.skin)
	
	_G.DetailsOptionsWindowTextureDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowRowBackgroundTextureDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowTextureDropdown.MyObject:Select (instance.barrasInfo.textureName)
	_G.DetailsOptionsWindowRowBackgroundTextureDropdown.MyObject:Select (instance.barrasInfo.textureNameBackground)
	_G.DetailsOptionsWindowRowBackgroundColor.MyObject:SetTexture (unpack (instance.barrasInfo.texturaBackgroundColor))
	
	_G.DetailsOptionsWindowBackgroundClassColorSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowBackgroundClassColorSlider.MyObject:SetValue (instance.barrasInfo.texturaBackgroundByClass)

	--
	_G.DetailsOptionsWindowFontDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowFontDropdown.MyObject:Select (instance.barrasInfo.fontName)
	--
	_G.DetailsOptionsWindowSliderRowHeight.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowSliderRowHeight.MyObject:SetValue (instance.barrasInfo.altura)
	--
	_G.DetailsOptionsWindowSliderFontSize.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowSliderFontSize.MyObject:SetValue (instance.barrasInfo.fontSize)
	--
	_G.DetailsOptionsWindowAutoCurrentSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowAutoCurrentSlider.MyObject:SetValue (instance.auto_current)
	--
	_G.DetailsOptionsWindowClassColorSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowClassColorSlider.MyObject:SetValue (instance.row_texture_class_colors)
	
	_G.DetailsOptionsWindowUseClassColorsLeftTextSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowUseClassColorsLeftTextSlider.MyObject:SetValue (instance.row_textL_class_colors)
	_G.DetailsOptionsWindowUseClassColorsRightTextSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowUseClassColorsRightTextSlider.MyObject:SetValue (instance.row_textR_class_colors)
	
	_G.DetailsOptionsWindowTextLeftOutlineSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowTextLeftOutlineSlider.MyObject:SetValue (instance.row_textL_outline)
	_G.DetailsOptionsWindowTextRightOutlineSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowTextRightOutlineSlider.MyObject:SetValue (instance.row_textR_outline)
	--
	_G.DetailsOptionsWindowAlphaSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowAlphaSlider.MyObject:SetValue (instance.bg_alpha)
	--
	_G.DetailsOptionsWindowUseBackgroundSlider.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowBackgroundDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowBackgroundDropdown2.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowAnchorDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowBackgroundDropdown.MyObject:Select (instance.wallpaper.texture)
	
	if (instance.wallpaper.enabled) then
		_G.DetailsOptionsWindowBackgroundDropdown.MyObject:Enable()
		_G.DetailsOptionsWindowBackgroundDropdown2.MyObject:Enable()
		_G.DetailsOptionsWindowUseBackgroundSlider.MyObject:SetValue (2)
	else
		_G.DetailsOptionsWindowBackgroundDropdown.MyObject:Disable()
		_G.DetailsOptionsWindowBackgroundDropdown2.MyObject:Disable()
		_G.DetailsOptionsWindowUseBackgroundSlider.MyObject:SetValue (1)
	end
	--
	_G.DetailsOptionsWindowTTDropdown.MyObject:Select (_detalhes.time_type, true)
	--
	_G.DetailsOptionsWindowInstanceColorTexture.MyObject:SetTexture (unpack (instance.color))
	_G.DetailsOptionsWindowBackgroundColorTexture.MyObject:SetTexture (instance.bg_r, instance.bg_g, instance.bg_b)
	_G.DetailsOptionsWindowFixedRowColorTexture.MyObject:SetTexture (unpack (instance.fixed_row_texture_color))
	_G.DetailsOptionsWindowFixedRowColorTTexture.MyObject:SetTexture (unpack (instance.fixed_row_text_color))
	--
	GameCooltip:SetFixedParameter (_G.DetailsOptionsWindowLoadStyleButton, instance)
	
	_G.DetailsOptionsWindowNicknameEntry.MyObject.text = _detalhes:GetNickname (UnitGUID ("player"), UnitName ("player"), true) --> serial, default, silent
	
	_G.DetailsOptionsWindow.MyObject.instance = instance
	window:Show()
	
end
