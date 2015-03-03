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
	
	local debuff_prototype = {
		["cooldown"] = true,
		["trigger"] = {
			["spellId"] = "0",
			["unit"] = "",
			["spellIds"] = {},
			["debuffType"] = "HARMFUL",
		},
	}
	local buff_prototype = {
		["cooldown"] = true,
		["trigger"] = {
			["spellId"] = "0",
			["unit"] = "",
			["spellIds"] = {},
			["debuffType"] = "HELPFUL",
		},
	}
	local cast_prototype = {
		["trigger"] = {
			["type"] = "event",
			["spellId"] = "0",
			["subeventSuffix"] = "_CAST_SUCCESS",
			["unevent"] = "timed",
			["duration"] = "4",
			["event"] = "Combat Log",
			["subeventPrefix"] = "SPELL",
			["use_spellId"] = true,
		}
	}
	
	local stack_prototype = {
		["trigger"] = {
			["countOperator"] = ">=",
			["count"] = "0",
			["useCount"] = true,
		},
	}
	
	local sound_prototype = {
		["actions"] = {
			["start"] = {
				["do_sound"] = true,
				["sound"] = "Interface\\Quiet.ogg",
				["sound_channel"] = "Master",
			},
		},
	}
	
	local chat_prototype = {
		["actions"] = {
			["start"] = {
				["message"] = "",
				["message_type"] = "SAY",
				["do_message"] = true,
			},
		},
	}
	
	function _detalhes:CreateWeakAura (spellid, name, icon_texture, target, stacksize, sound, chat)
	
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

		if (target) then
			if (target == 1) then --Debuff on Player
				local add = _detalhes.table.copy ({}, debuff_prototype)
				add.trigger.spellId = tostring (spellid)
				add.trigger.spellIds[1] = spellid
				add.trigger.unit = "player"
				_detalhes.table.deploy (icon, add)
				
			elseif (target == 2) then --Debuff on Target
				local add = _detalhes.table.copy ({}, debuff_prototype)
				add.trigger.spellId = tostring (spellid)
				add.trigger.spellIds[1] = spellid
				add.trigger.unit = "target"
				_detalhes.table.deploy (icon, add)

			elseif (target == 3) then --Debuff on Focus
				local add = _detalhes.table.copy ({}, debuff_prototype)
				add.trigger.spellId = tostring (spellid)
				add.trigger.spellIds[1] = spellid
				add.trigger.unit = "focus"
				_detalhes.table.deploy (icon, add)
				
			elseif (target == 11) then --Buff on Player
				local add = _detalhes.table.copy ({}, buff_prototype)
				add.trigger.spellId = tostring (spellid)
				add.trigger.spellIds[1] = spellid
				add.trigger.unit = "player"
				_detalhes.table.deploy (icon, add)
				
			elseif (target == 12) then --Buff on Target
				local add = _detalhes.table.copy ({}, buff_prototype)
				add.trigger.spellId = tostring (spellid)
				add.trigger.spellIds[1] = spellid
				add.trigger.unit = "target"
				_detalhes.table.deploy (icon, add)
				
			elseif (target == 13) then --Buff on Focus
				local add = _detalhes.table.copy ({}, buff_prototype)
				add.trigger.spellId = tostring (spellid)
				add.trigger.spellIds[1] = spellid
				add.trigger.unit = "focus"
				_detalhes.table.deploy (icon, add)
				
			elseif (target == 21) then --Spell Cast Started
				local add = _detalhes.table.copy ({}, cast_prototype)
				add.trigger.spellId = tostring (spellid)
				add.trigger.subeventSuffix = "_CAST_START"
				_detalhes.table.deploy (icon, add)
				
			elseif (target == 22) then --Spell Cast Successful
				local add = _detalhes.table.copy ({}, cast_prototype)
				add.trigger.spellId = tostring (spellid)
				_detalhes.table.deploy (icon, add)
			end
		else
			icon.trigger.spellId = tostring (spellid)
			tinsert (icon.trigger.spellIds, spellid)
		end

		if (stacksize and stacksize >= 1) then
			stacksize = floor (stacksize)
			local add = _detalhes.table.copy ({}, stack_prototype)
			add.trigger.count = tostring (stacksize)
			_detalhes.table.deploy (icon, add)
		end
		
		if (sound and sound ~= "" and sound ~= [[Interface\Quiet.ogg]]) then
			local add = _detalhes.table.copy ({}, sound_prototype)
			add.actions.start.sound = sound
			_detalhes.table.deploy (icon, add)
		end
		
		if (chat and chat ~= "") then
			local add = _detalhes.table.copy ({}, sound_prototype)
			add.actions.start.message = chat
			_detalhes.table.deploy (icon, add)
		end
		
		if (WeakAurasSaved.displays [icon.id]) then
			-- already exists
			for i = 2, 100 do
				if (not WeakAurasSaved.displays [icon.id .. " (" .. i .. ")"]) then
					icon.id = icon.id .. " (" .. i .. ")"
					break
				end
			end
		end
		
		tinsert (WeakAurasSaved.displays ["Details! Aura Group"].controlledChildren, icon.id)
		
		WeakAuras.Add (icon)
		
		local options_frame = WeakAuras.OptionsFrame and WeakAuras.OptionsFrame()
		if (options_frame and options_frame:IsShown()) then
			--WeakAuras.ToggleOptions()
			--WeakAuras.ToggleOptions()
		else
			--WeakAuras.OpenOptions()
		end
	end
	
	function _detalhes:OpenAuraPanel (spellid, spellname, spellicon)
		
		if (not DetailsAuraPanel) then
			
			local f = CreateFrame ("frame", "DetailsAuraPanel", UIParent, "ButtonFrameTemplate")
			f:SetSize (300, 350)
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
			local name_textentry = fw:CreateTextEntry (f, _detalhes.empty_function, 150, 20, "AuraName", "$parentAuraName")
			name_textentry:SetPoint ("left", name_label, "right", 2, 0)
			f.name = name_textentry
			
			--spellid
			local auraid_label = fw:CreateLabel (f, "Spell Id: ", nil, nil, "GameFontNormal")
			local auraid_textentry = fw:CreateTextEntry (f, _detalhes.empty_function, 150, 20, "AuraSpellId", "$parentAuraSpellId")
			auraid_textentry:SetPoint ("left", auraid_label, "right", 2, 0)
			
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
			
			--target
			local aura_on_icon = [[Interface\Buttons\UI-GroupLoot-DE-Down]]
			local aura_on_table = {
				{label = "Debuff on You", value = 1, icon = aura_on_icon},
				{label = "Debuff on Target", value = 2, icon = aura_on_icon},
				{label = "Debuff on Focus", value = 3, icon = aura_on_icon},
				
				{label = "Buff on You", value = 11, icon = aura_on_icon},
				{label = "Buff on Target", value = 12, icon = aura_on_icon},
				{label = "Buff on Focus", value = 13, icon = aura_on_icon},
				
				{label = "Spell Cast Started", value = 21, icon = aura_on_icon},
				{label = "Spell Cast successful", value = 22, icon = aura_on_icon},
			}
			local aura_on_options = function()
				return aura_on_table
			end
			local aura_on = fw:CreateDropDown (f, aura_on_options, 1, 150, 20, "AuraOnDropdown", "$parentAuraOnDropdown")
			local aura_on_label = fw:CreateLabel (f, "Trigger: ", nil, nil, "GameFontNormal")
			aura_on:SetPoint ("left", aura_on_label, "right", 2, 0)
			
			--stack
			local stack_slider = fw:NewSlider (f, f, "$parentStackSlider", "StackSlider", 150, 20, 0, 30, 1, 0)
			local stack_label = fw:CreateLabel (f, "Stack Size: ", nil, nil, "GameFontNormal")
			stack_slider:SetPoint ("left", stack_label, "right", 2, 0)
			
			--sound effect
			local play_sound = function (self, fixedParam, file)
				print (file)
				PlaySoundFile (file, "Master")
			end
			local sound_options = function()
				local t = {{label = "No Sound", value = "", icon = [[Interface\Buttons\UI-GuildButton-MOTD-Disabled]]}}
				for name, soundFile in pairs (LibStub:GetLibrary("LibSharedMedia-3.0"):HashTable ("sound")) do
					tinsert (t, {label = name, value = soundFile, icon = [[Interface\Buttons\UI-GuildButton-MOTD-Up]], onclick = play_sound})
				end
				return t
			end
			local sound_effect = fw:CreateDropDown (f, sound_options, 1, 150, 20, "SoundEffectDropdown", "$parentSoundEffectDropdown")
			local sound_effect_label = fw:CreateLabel (f, "Play Sound: ", nil, nil, "GameFontNormal")
			sound_effect:SetPoint ("left", sound_effect_label, "right", 2, 0)
			
			--say something
			local say_something_label = fw:CreateLabel (f, "Chat Message: ", nil, nil, "GameFontNormal")
			local say_something = fw:CreateTextEntry (f, _detalhes.empty_function, 150, 20, "SaySomething", "$parentSaySomething")
			say_something:SetPoint ("left", say_something_label, "right", 2, 0)
			
			--aura addon
			local addon_options = function()
				local t = {}
				if (WeakAuras) then
					tinsert (t, {label = "Weak Auras 2", value = "WA", icon = [[Interface\AddOns\WeakAuras\icon]]})
				end
				return t
			end
			local aura_addon = fw:CreateDropDown (f, addon_options, 1, 150, 20, "AuraAddonDropdown", "$parentAuraAddonDropdown")
			local aura_addon_label = fw:CreateLabel (f, "Addon: ", nil, nil, "GameFontNormal")
			aura_addon:SetPoint ("left", aura_addon_label, "right", 2, 0)
			
			--create
			local create_func = function()
				
				local name = f.AuraName.text
				local spellid = f.AuraSpellId.text
				local icon = f.IconButton.icon.texture
				local target = f.AuraOnDropdown.value
				local stacksize = f.StackSlider.value
				local sound = f.SoundEffectDropdown.value
				local chat = f.SaySomething.text
				local addon = f.AuraAddonDropdown.value

				if (addon == "WA") then
					_detalhes:CreateWeakAura (spellid, name, icon, target, stacksize, sound, chat)
				else
					_detalhes:Msg ("No Aura Addon selected. Addons currently supported: WeakAuras 2.")
				end
				
				f:Hide()
			end
			
			local create_button = fw:CreateButton (f, create_func, 106, 16, "Create Aura")
			create_button:InstallCustomTexture()
			
			local cancel_button = fw:CreateButton (f, function() name_textentry:ClearFocus(); f:Hide() end, 106, 16, "Cancel")
			cancel_button:InstallCustomTexture()
			
			create_button:SetIcon ([[Interface\Buttons\UI-CheckBox-Check]], nil, nil, nil, {0.125, 0.875, 0.125, 0.875}, nil, 4, 2)
			cancel_button:SetIcon ([[Interface\Buttons\UI-GroupLoot-Pass-Down]], nil, nil, nil, {0.125, 0.875, 0.125, 0.875}, nil, 4, 2)
			
			local x_start = 20
			local y_start = 21
			
			name_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*1) + (50)) * -1)
			auraid_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*2) + (50)) * -1)
			icon_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*3) + (50)) * -1)
			aura_on_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*4) + (50)) * -1)
			stack_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*5) + (50)) * -1)
			sound_effect_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*6) + (50)) * -1)
			say_something_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*7) + (50)) * -1)
			aura_addon_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*10) + (50)) * -1)

			create_button:SetPoint ("topleft", f, "topleft", x_start, ((y_start*12) + (50)) * -1)
			cancel_button:SetPoint ("topright", f, "topright", x_start*-1, ((y_start*12) + (50)) * -1)
			
		end
		
		DetailsAuraPanel.spellid = spellid
		
		DetailsAuraPanel.name.text = spellname
		DetailsAuraPanel.AuraSpellId.text = tostring (spellid)
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
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details auras

	local aura_prototype = {
		name = "",
		type = "DEBUFF",
		target = "player",
		boss = "0",
		icon = "",
		stack = 0,
		sound = "",
		sound_channel = "",
		chat = "",
		chat_where = "SAY",
		chat_extra = "",
	}
	
	function _detalhes:CreateDetailsAura (name, auratype, target, boss, icon, stack, sound, chat)
	
		local aura_container = _detalhes.details_auras
		
		--already exists
		if (aura_container [name]) then
			_detalhes:Msg ("Aura name already exists.")
			return
		end
		
		--create the new aura
		local new_aura = _detalhes.table.copy ({}, aura_prototype)
		new_aura.type = auratype or new_aura.type
		new_aura.target = auratype or new_aura.target
		new_aura.boss = boss or new_aura.boss
		new_aura.icon = icon or new_aura.icon
		new_aura.stack = math.max (stack or 0, new_aura.stack)
		new_aura.sound = sound or new_aura.sound
		new_aura.chat = chat or new_aura.chat
		
		_detalhes.details_auras [name] = new_aura
		
		return new_aura
	end
	
	function _detalhes:CreateAuraListener()
	
		local listener = _detalhes:CreateEventListener()
		
		function listener:on_enter_combat (event, combat, encounterId)
			
		end
		
		function listener:on_leave_combat (event, combat)
			
		end
		
		listener:RegisterEvent ("COMBAT_PLAYER_ENTER", "on_enter_combat")
		listener:RegisterEvent ("COMBAT_PLAYER_LEAVE", "on_leave_combat")
	
	end
	
	
	
	
	
	
	

	