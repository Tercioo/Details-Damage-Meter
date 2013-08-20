local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

local g =	_detalhes.gump

function _detalhes:OpenOptionsWindow (instance)

	GameCooltip:Close()
	local window = _G.DetailsOptionsWindow

	if (not window) then
	
-- Details Overall -------------------------------------------------------------------------------------------------------------------------------------------------
	
		-- Most of details widgets have the same 6 first parameters: parent, container, global name, parent key, width, height
	
		window = g:NewPanel (UIParent, _, "DetailsOptionsWindow", _, 500, 320)
		window.instance = instance
		tinsert (UISpecialFrames, "DetailsOptionsWindow")
		window:SetPoint ("center", UIParent, "Center")
		window.locked = false
		window.close_with_right = true
	
		g:NewLabel (window, _, "$parentTitle", "title", "Options for Details!")
		window.title:SetPoint (10, -10)
		
		local c = window:CreateRightClickLabel ("medium")
		c:SetPoint ("bottomleft", window, "bottomleft", 5, 5)
		
	--------------- Max Segments
		g:NewLabel (window, _, "$parentSliderLabel", "segmentsLabel", "max segments")
		window.segmentsLabel:SetPoint (10, -35)
		--
		g:NewSlider (window, _, "$parentSlider", "segmentsSlider", 120, 20, 1, 25, 1, _detalhes.segments_amount) -- min, max, step, defaultv
		window.segmentsSlider:SetPoint ("left", window.segmentsLabel, "right")
		window.segmentsSlider:SetHook ("OnValueChange", function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.segments_amount = amount
		end)
		window.segmentsSlider.tooltip = "This option control how many fights you want to maintain.\nAs overall data work dynamic with segments stored,\nfeel free to adjust this number to be comfortable for you.\nHigh value may increase the memory use,\nbut doesn't affect your game framerate."

	--------------- Max Segments Saved
		g:NewLabel (window, _, "$parentLabelSegmentsSave", "segmentsSaveLabel", "segments saved on logout")
		window.segmentsSaveLabel:SetPoint (10, -50)
		--
		g:NewSlider (window, _, "$parentSliderSegmentsSave", "segmentsSliderToSave", 80, 20, 1, 5, 1, _detalhes.segments_amount_to_save) -- min, max, step, defaultv
		window.segmentsSliderToSave:SetPoint ("left", window.segmentsSaveLabel, "right")
		window.segmentsSliderToSave:SetHook ("OnValueChange", function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.segments_amount_to_save = amount
		end)
		window.segmentsSliderToSave.tooltip = "How many segments will be saved on logout.\nHigher values may increase the time between a\nlogout button click and your character selection screen.\nIf you rarely check last day data, it`s high recommeded save only 1."
	
	--------------- Panic Mode
		g:NewLabel (window, _, "$parentPanicModeLabel", "panicModeLabel", "panic mode")
		window.panicModeLabel:SetPoint (10, -65)
		--
		g:NewSwitch (window, _, "$parentPanicModeSlider", "panicModeSlider", 60, 20, _, _, _detalhes.segments_panic_mode)
		window.panicModeSlider:SetPoint ("left", window.panicModeLabel, "right")
		window.panicModeSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue
			_detalhes.segments_panic_mode = value
		end
		window.panicModeSlider.tooltip = "If enabled, when you are in a raid encounter\nand get dropped from the game, a disconnect for intance,\nDetails! immediately erase all segments\nmaking the disconnect process faster."
		
	--------------- Animate Rows
		g:NewLabel (window, _, "$parentAnimateLabel", "animateLabel", "animate rows")
		window.animateLabel:SetPoint (10, -80)
		--
		g:NewSwitch (window, _, "$parentAnimateSlider", "animateSlider", 60, 20, _, _, _detalhes.use_row_animations) -- ltext, rtext, defaultv
		window.animateSlider:SetPoint ("left",window.animateLabel, "right")
		window.animateSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue (false, true)
			_detalhes.use_row_animations = value
		end
		
	--------------- Clear Ungrouped
	--[[
		g:NewLabel (window, _, "$parentClearUngroupedLabel", "clearungroupedLabel", "delete ungrouped on logout")
		window.clearungroupedLabel:SetPoint (10, -65)
		--
		g:NewSwitch (window, _, "$parentClearUngroupedSlider", "clearungroupedSlider", 60, 20, _, _, _detalhes.clear_ungrouped) -- ltext, rtext, defaultv
		window.clearungroupedSlider:SetPoint ("left", window.clearungroupedLabel, "right")
		window.clearungroupedSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue
			_detalhes.clear_ungrouped = value
		end
		window.clearungroupedSlider.tooltip = "erase actors without a group when you logout."
	--]]
	
	--------------- Use Scroll Bar
		g:NewLabel (window, _, "$parentUseScrollLabel", "scrollLabel", "show scroll bar")
		window.scrollLabel:SetPoint (10, -95)
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
		window.animatescrollLabel:SetPoint (10, -110)
		--
		g:NewSwitch (window, _, "$parentClearAnimateScrollSlider", "animatescrollSlider", 60, 20, _, _, _detalhes.animate_scroll) -- ltext, rtext, defaultv
		window.animatescrollSlider:SetPoint ("left", window.animatescrollLabel, "right")
		window.animatescrollSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue
			_detalhes.animate_scroll = value
		end
		
	--------------- Update Speed
		g:NewLabel (window, _, "$parentUpdateSpeedLabel", "updatespeedLabel", "update speed")
		window.updatespeedLabel:SetPoint (10, -125)
		--
		g:NewSlider (window, _, "$parentSliderUpdateSpeed", "updatespeedSlider", 160, 20, 0.3, 2, 0.1, _detalhes.update_speed, true) --parent, container, name, member, w, h, min, max, step, defaultv
		window.updatespeedSlider:SetPoint ("left", window.updatespeedLabel, "right")
		window.updatespeedSlider:SetThumbSize (50)
		window.updatespeedSlider.useDecimals = true
		local updateColor = function (slider, value)
			if (value < 1) then
				slider.amt:SetTextColor (1, value, 0)
			elseif (value > 1) then
				slider.amt:SetTextColor (-(value-2), 1, 0)
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
		window.timetypeLabel:SetPoint (10, -143)
		--
		local onSelectTimeType = function (_, _, timetype)
			_detalhes.time_type = timetype
			_detalhes:AtualizaGumpPrincipal (-1, true)
		end
		local timetypeOptions = {
			{value = 1, label = "Chronometer", onclick = onSelectTimeType, icon = "Interface\\Icons\\INV_Misc_PocketWatch_01", desc = "The effective time are based on the actions of the actor\nand his activity time are paused when he is idle during combat."},
			{value = 2, label = "Continuous", onclick = onSelectTimeType, icon = "Interface\\Icons\\INV_Misc_Gear_03", desc = "Activity time is the same for all the actors where the\ncombat time is used to measure the effectiveness of all actors."}
		}
		local buildTimeTypeMenu = function()
			return timetypeOptions
		end
		g:NewDropDown (window, _, "$parentTTDropdown", "timetypeDropdown", 160, 20, buildTimeTypeMenu, nil) -- func, default
		window.timetypeDropdown:SetPoint ("left", window.timetypeLabel, "right")
	
	--------------- Captures
		g:NewImage (window, _, "$parentCaptureDamage", "damageCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.damageCaptureImage:SetPoint (10, -163)
		window.damageCaptureImage:SetTexCoord (0, 0.125, 0, 1)
		
		g:NewImage (window, _, "$parentCaptureHeal", "healCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.healCaptureImage:SetPoint (10, -183)
		window.healCaptureImage:SetTexCoord (0.125, 0.25, 0, 1)
		
		g:NewImage (window, _, "$parentCaptureEnergy", "energyCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.energyCaptureImage:SetPoint (10, -203)
		window.energyCaptureImage:SetTexCoord (0.25, 0.375, 0, 1)
		
		g:NewImage (window, _, "$parentCaptureMisc", "miscCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.miscCaptureImage:SetPoint (10, -223)
		window.miscCaptureImage:SetTexCoord (0.375, 0.5, 0, 1)
		
		g:NewImage (window, _, "$parentCaptureAura", "auraCaptureImage", 20, 20, [[Interface\AddOns\Details\images\atributos_captures]])
		window.auraCaptureImage:SetPoint (10, -243)
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
		window.healCaptureSlider.tooltip = "Pause or enable capture of:\n- healing done (not absorbs)\n- healing per second\n- overheal\n- healing taken"
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
		window.auraCaptureSlider.tooltip = "Pause or enable capture of:\n- buffs and debufs\n- absorbs (heal)"
		window.auraCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "aura", true)
			switch_icon_color (window.auraCaptureImage, value)
		end
		switch_icon_color (window.auraCaptureImage, _detalhes.capture_real ["aura"])
		
	--------------- Cloud Capture
	
		g:NewLabel (window, _, "$parentCloudCaptureLabel", "cloudCaptureLabel", "Cloud Capture")
		window.cloudCaptureLabel:SetPoint (10, -268)
	
		g:NewSwitch (window, _, "$parentCloudAuraSlider", "cloudCaptureSlider", 60, 20, _, _, _detalhes.cloud_capture)
		window.cloudCaptureSlider:SetPoint ("left", window.cloudCaptureLabel, "right", 2)
		window.cloudCaptureSlider.tooltip = "Download capture data from another\nraid member when a capture are disabled."
		window.cloudCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes.cloud_capture = value
		end
		
		
-- Current Instalnce --------------------------------------------------------------------------------------------------------------------------------------------
		
	--------------- Row textures
		g:NewLabel (window, _, "$parentTextureLabel", "textureLabel", "row style")
		window.textureLabel:SetPoint (250, -30)
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
		g:NewLabel (window, _, "$parentFontSizeLabel", "fonsizeLabel", "font size")
		window.fonsizeLabel:SetPoint (250, -65)
		--
		g:NewSlider (window, _, "$parentSliderFontSize", "fonsizeSlider", 90, 20, 8, 15, 1, tonumber (instance.barrasInfo.fontSize)) --parent, container, name, member, w, h, min, max, step, defaultv
		window.fonsizeSlider:SetPoint ("left", window.fonsizeLabel, "right")
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
		
		g:NewLabel (window, _, "$parentFontLabel", "fontLabel", "select font style")
		window.fontLabel:SetPoint (250, -82)
		--
		g:NewDropDown (window, _, "$parentFontDropdown", "fontDropdown", 160, 20, buildFontMenu, nil)
		window.fontDropdown:SetPoint ("left", window.fontLabel, "right", 2)
	
	--------------- Instance Color
	
		g:NewLabel (window, _, "$parentInstanceColorLabel", "instancecolor", "instance color")
		window.instancecolor:SetPoint (250, -115)
		
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
			
			window.instancecolortexture:SetTexture (r, g, b)
			window.instancecolortexture:SetAlpha (a)
			
			window.instance.color[1], window.instance.color[2], window.instance.color[3], window.instance.color[4] = r, g, b, a
			window.instance:InstanceColor (r, g, b, a)

		end
		
		local colorpick = function()
			ColorPickerFrame.func = selectedColor
			ColorPickerFrame.cancelFunc = canceledColor
			ColorPickerFrame.hasOpacity = false
			ColorPickerFrame.opacity = window.instance.color[4] or 1
			ColorPickerFrame.previousValues = window.instance.color
			ColorPickerFrame:SetParent (window.widget)
			ColorPickerFrame:SetColorRGB (unpack (window.instance.color))
			ColorPickerFrame:Show()
		end

		g:NewImage (window, _, "$parentInstanceColorTexture", "instancecolortexture", 100, 12)
		window.instancecolortexture:SetPoint ("left", window.instancecolor, "right", 2)
		window.instancecolortexture:SetTexture (1, 1, 1)
		
		g:NewButton (window, _, "$parentInstanceColorButton", "instancecolorbutton", 200, 20, colorpick)
		window.instancecolorbutton:SetPoint ("left", window.instancecolor, "right", 2)
	
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
		
		g:NewLabel (window, _, "$parentBackgroundLabel", "backgroundLabel", "instance wallpaper")
		window.backgroundLabel:SetPoint (250, -145)
		--
		g:NewSwitch (window, _, "$parentUseBackgroundSlider", "useBackgroundSlider", 60, 20, _, _, window.instance.wallpaper.enabled)
		window.useBackgroundSlider:SetPoint ("left", window.backgroundLabel, "right")
		window.useBackgroundSlider.OnSwitch = function (self, instance, value) --> slider, fixedValue, sliderValue
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
		window.backgroundLabel:SetPoint (250, -160)
		g:NewLabel (window, _, "$parentBackgroundLabel", "backgroundLabel", "select wallpaper")
		window.backgroundLabel:SetPoint (370, -160)
		--
		g:NewDropDown (window, _, "$parentBackgroundDropdown", "backgroundDropdown", 120, 20, buildBackgroundMenu, nil)
		window.backgroundDropdown:SetPoint (250, -175)
		--
		g:NewDropDown (window, _, "$parentBackgroundDropdown2", "backgroundDropdown2", 120, 20, buildBackgroundMenu2, nil)
		window.backgroundDropdown2:SetPoint (370, -175)

		
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
				g:ImageEditor (callmeback, tinstance.wallpaper.texture, tinstance.wallpaper.texcoord, tinstance.wallpaper.overlay, window.instance.baseframe.wallpaper:GetWidth(), window.instance.baseframe.wallpaper:GetHeight())
			end
		end
		
		g:NewLabel (window, _, "$parentAnchorLabel", "anchorLabel", "align")
		window.anchorLabel:SetPoint (250, -200)
		--
		g:NewDropDown (window, _, "$parentAnchorDropdown", "anchorDropdown", 100, 20, buildAnchorMenu, nil)
		window.anchorDropdown:SetPoint ("left", window.anchorLabel, "right", 2)
		--
		g:NewButton (window, _, "$parentEditImage", "editImage", 100, 18, startImageEdit, nil, nil, nil, "edit image")
		window.editImage:InstallCustomTexture()
		window.editImage:SetPoint ("left", window.anchorDropdown, "right", 2)
		
----------------------- Save Style Text Entry and Button -----------------------------------------
	
		----- style name
		g:NewTextEntry (window, _, "$parentSaveStyleName", "saveStyleName", nil, 20, _, _, _, 178) --width will be auto adjusted if space parameter is passed
		window.saveStyleName:SetLabelText ("style name:")
		window.saveStyleName:SetPoint (250, -300)
	
		local saveStyleFunc = function()
			if (not window.saveStyleName.text or window.saveStyleName.text == "") then
				_detalhes:Msg ("Give a name for your style.")
				return
			end
			local savedObject = {
				name = window.saveStyleName.text,
				texture = window.textureDropdown.value,
				fontSize = tonumber (window.fonsizeSlider.value),
				fontFace = window.fontDropdown.value, 
				color = window.instance.color,
				wallpaper = instance.wallpaper
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
			--refresh
			instance:RefreshBars()
			--update options
			
			_G.DetailsOptionsWindowInstanceColorTexture.MyObject:SetTexture (unpack (style.color))
			_G.DetailsOptionsWindowTextureDropdown.MyObject:Select (style.texture)
			_G.DetailsOptionsWindowFontDropdown.MyObject:Select (style.fontFace)
			_G.DetailsOptionsWindowSliderFontSize.MyObject:SetValue (style.fontSize)
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
				if (this_instance:IsAtiva() and this_instance.meu_id ~= instance.meu_id) then
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
					--refresh
					this_instance:RefreshBars()
				end
			end
		end
		
		g:NewButton (window, _, "$parentToAllStyleButton", "applyToAll", 130, 14, applyToAll, nil, nil, nil, "apply to all instances")
		window.applyToAll:InstallCustomTexture()
		window.applyToAll:SetPoint ("bottomright", window.removeStyle, "topright", 1, 3)
		
	end
	
	
----------------------------------------------------------------------------------------
--> Show

	_G.DetailsOptionsWindowTextureDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowTextureDropdown.MyObject:Select (instance.barrasInfo.textureName)
	--
	_G.DetailsOptionsWindowFontDropdown.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowFontDropdown.MyObject:Select (instance.barrasInfo.fontName)
	--
	_G.DetailsOptionsWindowSliderFontSize.MyObject:SetFixedParameter (instance)
	_G.DetailsOptionsWindowSliderFontSize.MyObject:SetValue (instance.barrasInfo.fontSize)
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
	--
	GameCooltip:SetFixedParameter (_G.DetailsOptionsWindowLoadStyleButton, instance)
	
	_G.DetailsOptionsWindow.MyObject.instance = instance
	window:Show()
	
end
