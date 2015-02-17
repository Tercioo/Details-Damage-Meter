	local _detalhes = _G._detalhes

	--> default weaktable
	_detalhes.weaktable = {__mode = "v"}

	
	--weak auras
	local group_prototype = {
		["xOffset"] = -678.999450683594,
		["yOffset"] = 212.765991210938,
		["id"] = "Details! Aura Group",
		["grow"] = "RIGHT",
		["controlledChildren"] = {},
		["animate"] = true,
		["border"] = "None",
		["anchorPoint"] = "CENTER",
		["regionType"] = "dynamicgroup",
		["sort"] = "none",
		["actions"] = {},
		["space"] = 0,
		["background"] = "None",
		["expanded"] = true,
		["constantFactor"] = "RADIUS",
		["trigger"] = {
			["type"] = "aura",
			["spellIds"] = {},
			["unit"] = "player",
			["debuffType"] = "HELPFUL",
			["names"] = {},
		},
		["borderOffset"] = 16,
		
		["animation"] = {
			["start"] = {
				["type"] = "none",
				["duration_type"] = "seconds",
			},
			["main"] = {
				["type"] = "none",
				["duration_type"] = "seconds",
			},
			["finish"] = {
				["type"] = "none",
				["duration_type"] = "seconds",
			},
		},
		["align"] = "CENTER",
		["rotation"] = 0,
		["frameStrata"] = 1,
		["width"] = 199.999969482422,
		["height"] = 20,
		["stagger"] = 0,
		["radius"] = 200,
		["numTriggers"] = 1,
		["backgroundInset"] = 0,
		["selfPoint"] = "LEFT",
		["load"] = {
			["use_combat"] = true,
			["race"] = {
				["multi"] = {},
			},
			["talent"] = {
				["multi"] = {},
			},
			["role"] = {
				["multi"] = {},
			},
			["spec"] = {
				["multi"] = {},
			},
			["class"] = {
				["multi"] = {},
			},
			["size"] = {
				["multi"] = {},
			},
		},
		["untrigger"] = {},
	}
	
	local icon_prototype = {
		["yOffset"] = -10.08984375,
		["xOffset"] = -3.2294921875,
		["fontSize"] = 14,
		["displayStacks"] = "%s",
		["parent"] = "Details! Aura Group",
		["color"] = {1, 1, 1, 1},
		["stacksPoint"] = "BOTTOMRIGHT",
		["regionType"] = "icon",
		["untrigger"] = {},
		["anchorPoint"] = "CENTER",
		["icon"] = true,
		["numTriggers"] = 1,
		["customTextUpdate"] = "update",
		["id"] = "UNNAMED",
		["actions"] = {},
		["fontFlags"] = "OUTLINE",
		["stacksContainment"] = "INSIDE",
		["zoom"] = 0,
		["auto"] = false,
		["animation"] = {
			["start"] = {
				["duration_type"] = "seconds",
				["type"] = "preset",
				["preset"] = "grow",
			},
			["main"] = {
				["duration_type"] = "seconds",
				["type"] = "preset",
				["preset"] = "pulse",
			},
			["finish"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
		},
		["trigger"] = {
			["type"] = "aura",
			["spellId"] = "0",
			["subeventSuffix"] = "_CAST_START",
			["custom_hide"] = "timed",
			["event"] = "Health",
			["subeventPrefix"] = "SPELL",
			["debuffClass"] = "magic",
			["use_spellId"] = true,
			["spellIds"] = {},
			["name_operator"] = "==",
			["fullscan"] = true,
			["unit"] = "player",
			["names"] = {
				"", -- [1]
			},
			["debuffType"] = "HARMFUL",
		},
		["desaturate"] = false,
		["frameStrata"] = 1,
		["stickyDuration"] = false,
		["width"] = 192,
		["font"] = "Friz Quadrata TT",
		["inverse"] = false,
		["selfPoint"] = "CENTER",
		["height"] = 192,
		["displayIcon"] = "Interface\\Icons\\Spell_Holiday_ToW_SpiceCloud",
		["load"] = {
			["use_combat"] = true,
			["race"] = {
				["multi"] = {
				},
			},
			["talent"] = {
				["multi"] = {
				},
			},
			["role"] = {
				["multi"] = {
				},
			},
			["spec"] = {
				["multi"] = {
				},
			},
			["class"] = {
				["multi"] = {
				},
			},
			["size"] = {
				["multi"] = {
				},
			},
		},
		["textColor"] = {
			1, -- [1]
			1, -- [2]
			1, -- [3]
			1, -- [4]
		},
	}
	
	local actions_prototype = {
		["start"] = {
			["do_glow"] = true,
			["glow_action"] = "show",
			["do_sound"] = true,
			["glow_frame"] = "WeakAuras:Crystalline Barrage Step",
			["sound"] = "Interface\\AddOns\\WeakAuras\\Media\\Sounds\\WaterDrop.ogg",
			["sound_channel"] = "Master",
		},
		["finish"] = {},
	}
	
	function _detalhes:CreateWeakAura (spellid, name, icon_texture, glow, sound)
		if (not WeakAuras or not WeakAurasSaved) then
			return
		end
		
		if (not WeakAurasSaved.displays ["Details! Aura Group"]) then
			local group = _detalhes.table.copy ({}, group_prototype)
			WeakAuras.Add (group)
		end
		
		local icon = _detalhes.table.copy ({}, icon_prototype)
		
		icon.id = name
		icon.displayIcon = icon_texture
		icon.trigger.spellId = spellid
		
		tinsert (icon.trigger.spellIds, spellid)
		
		WeakAuras.Add (icon)
		
		tinsert (WeakAurasSaved.displays ["Details! Aura Group"].controlledChildren, name)
		
		local options_frame = WeakAuras.OptionsFrame and WeakAuras.OptionsFrame()
		if (options_frame and options_frame:IsShown()) then
			WeakAuras.ToggleOptions()
			WeakAuras.ToggleOptions()
		else
			WeakAuras.OpenOptions()
		end
	end
	
	function _detalhes:OpenAuraPanel (spellid, spellname, spellicon)
		
		if (not DetailsAuraPanel) then
			
			local f = CreateFrame ("frame", "DetailsAuraPanel", UIParent, "ButtonFrameTemplate")
			f:SetSize (300, 250)
			f:SetPoint ("center", UIParent, "center")
			f:SetFrameStrata ("HIGH")
			f:SetToplevel (true)
			f:SetMovable (true)
			
			tinsert (UISpecialFrames, "DetailsAuraPanel")
			
			f:SetScript ("OnMouseDown", function(self, button)
				if (self.isMoving) then
					return
				end
				if (button == "RightButton") then
					self:Hide()
				else
					self:StartMoving() 
					self.isMoving = true
				end
			end)
			f:SetScript ("OnMouseUp", function(self, button) 
				if (self.isMoving and button == "LeftButton") then
					self:StopMovingOrSizing()
					self.isMoving = nil
				end
			end)
			
			f.TitleText:SetText ("Create Aura")
			f.portrait:SetTexture ([[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT-FEMALE-BLOODELF]])
			
			local fw = _detalhes:GetFramework()
			
			--aura name
			local name_label = fw:CreateLabel (f, "Name: ", nil, nil, "GameFontNormal")
			local name_textentry = fw:CreateTextEntry (f, _detalhes.empty_function, 150, 20)
			name_textentry:SetPoint ("left", name_label, "right", 2, 0)
			f.name = name_textentry
			
			--aura icon
			local icon_label = fw:CreateLabel (f, "Icon: ", nil, nil, "GameFontNormal")
			local icon_button_func = function (texture)
				f.IconButton.icon.texture = texture
			end
			local icon_pick_button = fw:NewButton (f, nil, "$parentIconButton", "IconButton", 20, 20, function() fw:IconPick (icon_button_func, true) end)
			local icon_button_icon = fw:NewImage (icon_pick_button, [[Interface\ICONS\TEMP]], 19, 19, "background", nil, "icon", "$parentIcon")
			icon_pick_button:InstallCustomTexture()
			
			icon_pick_button:SetPoint ("left", icon_label, "right", 2, 0)
			icon_button_icon:SetPoint ("left", icon_label, "right", 2, 0)
			
			f.icon = icon_button_icon
			
			--create
			local create_func = function()
				
				_detalhes:CreateWeakAura (f.spellid, f.name.text, DetailsAuraPanel.icon.texture, nil, nil)
				
				f:Hide()
			end
			local create_button = fw:CreateButton (f, create_func, 106, 16, "Create Aura")
			create_button:InstallCustomTexture()
			
			local cancel_button = fw:CreateButton (f, function() name_textentry:ClearFocus(); f:Hide() end, 106, 16, "Cancel")
			cancel_button:InstallCustomTexture()
			
			create_button:SetIcon ([[Interface\Buttons\UI-CheckBox-Check]], nil, nil, nil, {0.125, 0.875, 0.125, 0.875}, nil, 4, 2)
			cancel_button:SetIcon ([[Interface\Buttons\UI-GroupLoot-Pass-Down]], nil, nil, nil, {0.125, 0.875, 0.125, 0.875}, nil, 4, 2)
			
			local x_start = 20
			local y_start = 20
			
			name_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*1) + (50)) * -1)
			icon_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*2) + (50)) * -1)

			create_button:SetPoint ("topleft", f, "topleft", x_start, ((y_start*4) + (50)) * -1)
			cancel_button:SetPoint ("left", create_button, "right", 20, 0)
			
		end
		
		DetailsAuraPanel.spellid = spellid
		
		DetailsAuraPanel.name.text = spellname
		DetailsAuraPanel.icon.texture = spellicon
		
		DetailsAuraPanel:Show()
	end
	
	------------------------------------------------------------------------------------------------------------------
	
	--> get the total of damage and healing of this phase
	function _detalhes:OnCombatPhaseChanged()
	
		local current_combat = _detalhes:GetCurrentCombat()
		local current_phase = current_combat.PhaseData [#current_combat.PhaseData][1]
		
		local phase_damage_container = current_combat.PhaseData.damage [current_phase]
		local phase_healing_container = current_combat.PhaseData.heal [current_phase]
		
		local phase_damage_section = current_combat.PhaseData.damage_section
		local phase_healing_section = current_combat.PhaseData.heal_section
		
		if (not phase_damage_container) then
			phase_damage_container = {}
			current_combat.PhaseData.damage [current_phase] = phase_damage_container
		end
		if (not phase_healing_container) then
			phase_healing_container = {}
			current_combat.PhaseData.heal [current_phase] = phase_healing_container
		end
		
		for index, damage_actor in ipairs (_detalhes.cache_damage_group) do
			local phase_damage = damage_actor.total - (phase_damage_section [damage_actor.nome] or 0)
			phase_damage_section [damage_actor.nome] = damage_actor.total
			phase_damage_container [damage_actor.nome] = (phase_damage_container [damage_actor.nome] or 0) + phase_damage
		end
		
		for index, healing_actor in ipairs (_detalhes.cache_healing_group) do
			local phase_heal = healing_actor.total - (phase_healing_section [healing_actor.nome] or 0)
			phase_healing_section [healing_actor.nome] = healing_actor.total
			phase_healing_container [healing_actor.nome] = (phase_healing_container [healing_actor.nome] or 0) + phase_heal
		end
		
	end
	
	function _detalhes:BossModsLink()
		if (_G.DBM) then
			local dbm_callback_phase = function (event, msg)

				local mod = _detalhes.encounter_table.DBM_Mod
				
				if (not mod) then
					local id = _detalhes:GetEncounterIdFromBossIndex (_detalhes.encounter_table.mapid, _detalhes.encounter_table.id)
					if (id) then
						for index, tmod in ipairs (DBM.Mods) do 
							if (tmod.id == id) then
								_detalhes.encounter_table.DBM_Mod = tmod
								mod = tmod
							end
						end
					end
				end
				
				local phase = mod and mod.vb and mod.vb.phase
				if (phase and _detalhes.encounter_table.phase ~= phase) then
					--_detalhes:Msg ("Current phase:", phase)
					
					_detalhes:OnCombatPhaseChanged()
					
					_detalhes.encounter_table.phase = phase
					
					local cur_combat = _detalhes:GetCurrentCombat()
					local time = cur_combat:GetCombatTime()
					if (time > 5) then
						tinsert (cur_combat.PhaseData, {phase, time})
					end
					
					_detalhes:SendEvent ("COMBAT_ENCOUNTER_PHASE_CHANGED", nil, phase)
				end
			end
			
			local dbm_callback_pull = function (event, mod, delay, synced, startHp)
				_detalhes.encounter_table.DBM_Mod = mod
				_detalhes.encounter_table.DBM_ModTime = time()
			end
			
			DBM:RegisterCallback ("DBM_Announce", dbm_callback_phase)
			DBM:RegisterCallback ("pull", dbm_callback_pull)
		end
		
		LoadAddOn ("BigWigs_Core")
		
		if (BigWigs and not _G.DBM) then
			BigWigs:Enable()
		
			function _detalhes:BigWigs_Message (event, module, key, text)
				--print ("new bigwigs message...")
				if (key == "stages") then
					local phase = text:gsub (".*%s", "")
					phase = tonumber (phase)
					--print ("Phase Changed!", phase)
					
					if (phase and type (phase) == "number" and _detalhes.encounter_table.phase ~= phase) then
						--_detalhes:Msg ("Current phase:", phase)
						
						_detalhes:OnCombatPhaseChanged()
						
						_detalhes.encounter_table.phase = phase
						
						local cur_combat = _detalhes:GetCurrentCombat()
						local time = cur_combat:GetCombatTime()
						if (time > 5) then
							tinsert (cur_combat.PhaseData, {phase, time})
						end
						
						_detalhes:SendEvent ("COMBAT_ENCOUNTER_PHASE_CHANGED", nil, phase)
					end
					
				end
			end
			
			BigWigs.RegisterMessage (_detalhes, "BigWigs_Message")
		end
	end	
	