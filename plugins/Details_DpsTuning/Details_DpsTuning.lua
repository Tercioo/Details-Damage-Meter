local Loc = LibStub ("AceLocale-3.0"):GetLocale ("Details")

--> Main Plugin Object
local DpsTuningPlugin = _detalhes:NewPluginObject ("Details_DpsTuning")
--> Main Frame
local SDF = DpsTuningPlugin.Frame

--> global pointers
local ClockTime = time --> lua library local
local ipairs = ipairs --> lua library local
local pairs = pairs --> lua library local
local floor = floor --> lua library local
local _cstr = string.format --> lua library local

local GetSpellBonusDamage = GetSpellBonusDamage
local UnitAura = UnitAura --> wow api local
local GetTime = GetTime --> wow api local
local _

local _GetSpellInfo =_detalhes.getspellinfo --> details api local

DpsTuningPlugin:SetPluginDescription ("Tool for testing your Dps showing detailed information for each spell, buffs and also graphical charts for abilities.")

local function CreatePluginFrames()

	--> get the framework
	local fw = _detalhes:GetFramework()
	
	--> player damage done chart code
	local string_player_damage_done = [[
	
		-- the goal of this script is get the current combat then get your character and extract your damage done.
		-- the first thing to do is get the combat, so, we use here the command "_detalhes:GetCombat ( "overall" "current" or "segment number")"
		
		local current_combat = _detalhes:GetCombat ("current") --> getting the current combat
		
		-- the next step is request your character from the combat
		-- to do this, we take the combat which here we named "current_combat" and tells what we want inside parentheses.
		
		local my_self = current_combat (DETAILS_ATTRIBUTE_DAMAGE, _detalhes.playername)
		
		-- _detalhes.playername holds the name of your character.
		-- DETAILS_ATTRIBUTE_DAMAGE means we want the damage table, _HEAL _ENERGY _MISC is the other 3 tables.
		
		-- before we proceed, the result needs to be checked to make sure its a valid result.
		
		if (not my_self) then
			return 0 -- the combat doesnt have *you*, this happens when you didn't deal any damage in the combat yet.
		end
		
		-- now its time to get the total damage.
		
		local my_damage = my_self.total
		
		-- then finally return the amount to the capture.
		
		return my_damage
		
	]]
	
	--> color for spell dps bars
	DpsTuningPlugin.BarColor = {.4, .4, .4, .7}
	
	function DpsTuningPlugin:OnDetailsEvent (event, ...)

		if (event == "SHOW") then --> plugin shown on screen, actived
		
			SDF:SetResizable (false) --> cant resize, this is a fixed size
			SDF:SetSize (300, 300) --> need to be 300x300 to fit details window

			--> create the frames on the first shown
			if (not DpsTuningPlugin.frames_created) then
				DpsTuningPlugin:BuildHeader()
				DpsTuningPlugin:BuildSpellBars()
				DpsTuningPlugin:BuildSummaryPanel()
				DpsTuningPlugin:BuildBuffBlocks()
				DpsTuningPlugin:BuildChartPanels()
				
				DpsTuningPlugin.frames_created = true
				DpsTuningPlugin.Frame:Show()
				
				--tricky, localize members inside the plugin, so it doesn't need to lookup on _detalhes object every time
				DpsTuningPlugin.playername = DpsTuningPlugin.playername
				DpsTuningPlugin.comma_value = DpsTuningPlugin.comma_value
				DpsTuningPlugin.ToK2 = DpsTuningPlugin.ToK2
				DpsTuningPlugin.Sort2 = DpsTuningPlugin.Sort2
				DpsTuningPlugin.Sort3 = DpsTuningPlugin.Sort3
			end
			
			--> we only want register the player damage done when the plugin is active
			DpsTuningPlugin:TimeDataRegister ("Player Damage Done", string_player_damage_done, nil, "Spell Details", "v1.0", "Interface\\Icons\\INV_Fabric_Spellweave", true, true)
			
		elseif (event == "HIDE") then --> plugin hidded, disabled
		
			--> plugin is gone, unregister the chart
			DpsTuningPlugin:TimeDataUnregister ("Player Damage Done")
		
		elseif (event == "DETAILS_STARTED") then
		
			--> triggered right after details finish run all ADDON_LOADED functions
			local power = {}
			for i = 1, 7 do
				power [i] = {i, GetSpellBonusDamage (i)}
			end
			table.sort (power, DpsTuningPlugin.Sort2)
			DpsTuningPlugin.PowerType = power [1][1]
		
		elseif (event == "REFRESH") then --> requested a refresh window
			--> refresh window happens when there is a invalid combat, like a combat with less then 5 seconds.
			--DpsTuningPlugin:Refresh()
		
		elseif (event == "COMBAT_PLAYER_ENTER") then
			DpsTuningPlugin:OnCombatStart (...)
			
		elseif (event == "COMBAT_INVALID") then
			--DpsTuningPlugin:Reset()
			--print ("eh invalido...")
			
		elseif (event == "COMBAT_PLAYER_LEAVE") then
			DpsTuningPlugin:OnCombatEnd (...)

		elseif (event == "PLUGIN_DISABLED") then
			--> plugin got disabled on details options panel
		
		elseif (event == "PLUGIN_ENABLED") then
			--> plugin got enabled on details options panel
			
		elseif (event == "DETAILS_DATA_RESET") then
			--> data on details! got reseted. need to reset the plugin as well
			
			DpsTuningPlugin:TrackBuffsAtEnd()
			DpsTuningPlugin:CancelTicker()
			SDF:UnregisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
	
			DpsTuningPlugin:OnDataReset (...)
		
		end
	end
	
	local close_button = DpsTuningPlugin:CreateSoloCloseButton()
	close_button:SetPoint ("TOPRIGHT", SDF, "TOPRIGHT", -15, 5)
	close_button:SetSize (24, 24)
	
	function DpsTuningPlugin.GetActivityTime (thisspell, time)
		if (thisspell.tempo_end) then --> o tempo do jogador esta trancado
			local t = thisspell.tempo_end - thisspell.start
			if (t < 6) then
				t = 6
			end
			return t
		elseif (thisspell.onhold) then
			local t = thisspell.delay - thisspell.start
			if (t < 6) then
				t = 6
			end
			return t
		else
			if (thisspell.start == 0) then
				return 6
			end
			local t = time - thisspell.start
			if (t < 6) then
				if (DpsTuningPlugin.in_combat) then
					local combat_time = DpsTuningPlugin.CurCombat:GetCombatTime()
					if (combat_time < 6) then
						return combat_time
					end
				end
				t = 6
			end
			return t
		end
	end
	
	local spells = {cur = 0}
	local spell_activity = {}
	local buff_activity = {}
	local buff_graphic_data = {}
	local spell_graphic_data = {}
	local power_amount_chart_table = {}
	power_amount_chart_table.max_value = 0
	
	DpsTuningPlugin.FinishedAt = 0
	
	function DpsTuningPlugin.RefreshSpells()
	
		if (DpsTuningPlugin.db.SpellBarsShowType == 1) then --> execution activity dps
	
			local now = ClockTime()
			for spellid, spelltable in pairs (DpsTuningPlugin.CurPlayer:GetActorSpells()) do

				local this = spell_activity [spellid]
				if (not this) then
					local t = {}
					t.total = spelltable.total
					t.time = ClockTime()
					t.start = t.time
					t.tempo_end = nil
					t.lastevent = t.time
					spell_activity [spellid] = t
					this = t
				else
					local lastdamage = this.total
					if (lastdamage ~= spelltable.total) then
						this.lastevent = now
					end
					
					if (this.lastevent+6 < now) then
						--hold
						if (not this.onhold) then
							this.delay = this.lastevent
							if (this.delay < this.start) then
								this.delay = this.start
							end
							this.onhold = true
						end
					else
						--exec
						if (this.onhold) then
							local diff = now - this.delay - 2
							if (diff > 0) then
								this.start = this.start + diff
							end
							this.onhold = nil
						end
					end
					
					this.total = spelltable.total
				end
			end

			local i = 0
			for spellid, spelltable in pairs (spell_activity) do
				i = i + 1
				
				if (not spells [i]) then
					spells [i] = {}
				end
				
				spells [i][1] = spellid
				spells [i][2] = spelltable.total
				spells [i][3] = DpsTuningPlugin.GetActivityTime (spelltable, now)
				spells [i][4] = spells [i][2] / spells [i][3] --adps
			end
			
			spells.cur = i
			for o = #spells, i+1, -1 do
				spells [o][1] = 0
				spells [o][2] = 0
				spells [o][3] = 0
				spells [o][4] = 0
			end
			
			table.sort (spells, DpsTuningPlugin.Sort4)
			
			DpsTuningPlugin.SpellList = spells
			DpsTuningPlugin.SpellScroll:Update()
			
		elseif (DpsTuningPlugin.db.SpellBarsShowType == 2) then --> player activity dps
			
			local player_time = DpsTuningPlugin.CurPlayer:Tempo()
			local i = 0
			
			for spellid, spelltable in pairs (DpsTuningPlugin.CurPlayer:GetActorSpells()) do
				i = i + 1
				
				if (not spells [i]) then
					spells [i] = {}
				end
				
				spells [i][1] = spellid
				spells [i][2] = spelltable.total
				spells [i][3] = spelltable.total/player_time
			end
			
			spells.cur = i
			for o = #spells, i+1, -1 do
				spells [o][1] = 0
				spells [o][2] = 0
				spells [o][3] = 0
				spells [o][4] = 0
			end
			
			table.sort (spells, DpsTuningPlugin.Sort3)
			
			DpsTuningPlugin.SpellList = spells
			DpsTuningPlugin.SpellScroll:Update()
			
		elseif (DpsTuningPlugin.db.SpellBarsShowType == 3) then --> spell damage
			
			local i = 0
			for spellid, spelltable in pairs (DpsTuningPlugin.CurPlayer:GetActorSpells()) do
				i = i + 1
			
				if (not spells [i]) then
					spells [i] = {}
				end
				
				spells [i][1] = spellid
				spells [i][2] = spelltable.total
			end
			
			spells.cur = i
			for o = #spells, i+1, -1 do
				spells [o][1] = 0
				spells [o][2] = 0
				spells [o][3] = 0
				spells [o][4] = 0
			end
			
			table.sort (spells, DpsTuningPlugin.Sort2)
			
			DpsTuningPlugin.SpellList = spells
			DpsTuningPlugin.SpellScroll:Update()
			
		end

	end
	
	function update_scroll (self)
	
		local spells = DpsTuningPlugin.SpellList
		if (not spells) then
			for bar_index = 1, 9 do 
				local bar = DpsTuningPlugin.SpellBars [bar_index]
				bar:Hide()
			end
			return
		end
	
		local offset = FauxScrollFrame_GetOffset (self)
		local amt = 0
		for index, spell in ipairs (spells) do
			if (spell[2] > 0) then
				amt = amt + 1
			end
		end
		
		for bar_index = 1, 9 do 
			local data = spells [bar_index + offset]
			local bar = DpsTuningPlugin.SpellBars [bar_index]

			if (DpsTuningPlugin.db.SpellBarsShowType == 1) then --> execution activity dps
			
				if (data and data[3] > 0) then
					local name, _, icon = _GetSpellInfo (data [1])
					bar.icon = icon
					bar.lefttext = name
					bar.righttext = DpsTuningPlugin:comma_value (data [2]) .. " (" .. data [3] .. ", " .. DpsTuningPlugin:ToK2 (floor (data [4])) .. ")"
					bar.spellid = data [1]
					bar:Show()
				else
					bar:Hide()
				end
				
			elseif (DpsTuningPlugin.db.SpellBarsShowType == 2) then --> player activity dps

				if (data and data[2] > 0) then
					local name, _, icon = _GetSpellInfo (data [1])
					bar.icon = icon
					bar.lefttext = name
					bar.righttext = DpsTuningPlugin:comma_value (data [2]) .. " (" .. DpsTuningPlugin:ToK2 (floor (data [3])) .. ")"
					bar.spellid = data [1]
					bar:Show()
				else
					bar:Hide()
				end
			
			elseif (DpsTuningPlugin.db.SpellBarsShowType == 3) then --> spell damage
			
				local total = DpsTuningPlugin.CurPlayer.total
			
				if (data and data[2] > 0) then
					local name, _, icon = _GetSpellInfo (data [1])
					bar.icon = icon
					bar.lefttext = name
					bar.righttext = DpsTuningPlugin:comma_value (data [2]) .. " (" .. floor (data[2] / total * 100) .. "%)"
					bar.spellid = data [1]
					bar:Show()
				else
					bar:Hide()
				end
				
			end
		end
		
		FauxScrollFrame_Update (self, amt, 9, 15)
		
	end
	
	function DpsTuningPlugin:BuildSummaryPanel()
	
		--total damage
		local damage1 = fw:CreateLabel (SDF, "Damage:")
		local damage2 = fw:CreateLabel (SDF, "")
		damage1:SetPoint ("topleft", SDF, "topleft", 2, -165)
		damage2:SetPoint ("left", damage1, "right", 2, 0)
		DpsTuningPlugin.total_damage = damage2
	
		--activity dps
		local a_dps1 = fw:CreateLabel (SDF, "Dps:")
		local a_dps2 = fw:CreateLabel (SDF, "")
		a_dps1:SetPoint ("topleft", SDF, "topleft", 2, -180)
		a_dps2:SetPoint ("left", a_dps1, "right", 2, 0)
		DpsTuningPlugin.activity_dps = a_dps2
		
		--timer
		local timer1 = fw:CreateLabel (SDF, "Time:")
		local timer2 = fw:CreateLabel (SDF, "")
		timer1:SetPoint ("topleft", SDF, "topleft", 2, -195)
		timer2:SetPoint ("left", timer1, "right", 2, 0)
		DpsTuningPlugin.time_elapsed = timer2
		
		--power
		local power1 = fw:CreateLabel (SDF, "Power:")
		local power2 = fw:CreateLabel (SDF, "", 15, "orange")
		power1:SetPoint ("topleft", SDF, "topleft", 2, -215)
		power2:SetPoint ("left", power1, "right", 2, 0)
		DpsTuningPlugin.power_amount = power2
	end
	
	function DpsTuningPlugin:BuildHeader()
		
		local on_select_spell_type = function (_, _, type_number)
			DpsTuningPlugin.db.SpellBarsShowType = type_number
			DpsTuningPlugin:UpdateTick()
		end
		
		local icon = [[Interface\COMMON\friendship-FistOrc]]
		
		local spell_type_options = {
			{value = 1, label = "Execution Activity Dps", desc = "Oder and show the dps following the spell individual activity time.", onclick = on_select_spell_type, icon = icon},
			{value = 2, label = "Player Activity Dps", desc = "Order the spells using your activity time to measure the dps for each spell.", onclick = on_select_spell_type, icon = icon},
			{value = 3, label = "Damage", desc = "Order the spells following the damage done by each one.", onclick = on_select_spell_type, icon = icon},
		}
		
		local select_spell_type = function()
			return spell_type_options
		end
		
		local dropdown = fw:CreateDropDown (SDF, select_spell_type, DpsTuningPlugin.db.SpellBarsShowType, 160, 18)
		local label = fw:CreateLabel (SDF, "Dps Format:")
		label:SetPoint (2, -4)
		dropdown:SetPoint ("left", label, "right", 2, -1)
	end
	
	DpsTuningPlugin.AuraBlocks = {}
	
	local aura_onenter = function (self, capsule)
		self:SetBackdropBorderColor (1, 1, 0, 1)
		capsule.icontexture.alpha = 1
		local buff = capsule.buff
		if (buff) then
			GameCooltip:Reset()
			GameCooltip:SetOwner (self)
			GameCooltip:SetType ("tooltip")
			DpsTuningPlugin:CooltipPreset (2)
			
			local name, _, icon = _GetSpellInfo (buff.spellid)
			
			GameCooltip:AddLine (name, "", 1, "orange", nil, 13, "Arrial Narrow")
			GameCooltip:AddIcon (icon)
			
			GameCooltip:AddLine ("")

			local minutos, segundos = floor (buff.uptime/60), floor (buff.uptime%60)
			GameCooltip:AddLine ("Uptime:", minutos .. "m " .. segundos .. "s", 1, "white", nil, 10, "Arrial Narrow")
			GameCooltip:AddLine ("Percent:", _cstr ("%.1f", buff.uptime/DpsTuningPlugin.CurPlayer:Tempo()*100) .. "%", 1, "white", nil, 10, "Arrial Narrow")
			
			GameCooltip:SetOption ("AlignAsBlizzTooltip", true)
			GameCooltip:Show()
		end
	end
	local aura_onleave = function (self, capsule)
		self:SetBackdropBorderColor (1, 1, 1, 1)
		capsule.icontexture.alpha = 0.9
		GameCooltip:Hide()
	end
	
	local aura_onenter2 = function (self, capsule)
		aura_onenter (capsule.block.widget, capsule.block)
	end
	local aura_onleave2 = function (self, capsule)
		aura_onleave (capsule.block.widget, capsule.block)
	end
	
	local AuraOnClick = function (block)
		if (block.buff) then
			block.buff.disabled = not block.buff.disabled
			if (block.buff.disabled) then
				block.X:Show()
			else
				block.X:Hide()
			end
		end
	end
	
	function DpsTuningPlugin:BuildBuffBlocks()
		
		local auras = fw:CreateLabel (SDF, "Auras (click to disable):")
		auras:SetPoint (170, -165)
		
		local coords = {0.1, 0.9, 0.1, 0.9}
		local size = 26
		local color = {.7, .7, .7}
		
		for i = 1, 3 do
			local block = fw:CreatePanel (SDF, 32, 32)
			block:SetFrameLevel (SDF:GetFrameLevel()+2)
			block:SetPoint (170 + ((i-1) * 36), -180)
			block:SetHook ("OnEnter", aura_onenter)
			block:SetHook ("OnLeave", aura_onleave)
			block.icontexture = fw:CreateImage (block, nil, size, size, "border", coords)
			block.icontexture:SetPoint ("center", block, "center")
			block.icontexture.alpha = 0.9
			block.icontexture:SetVertexColor (unpack (color))
			block.texttime = fw:CreateLabel (block, "", 16, "yellow", "GameFontNormal", nil, nil, "artwork")
			block.texttime:SetPoint ("center", block, "center")
			
			block.X = fw:CreateImage (block, [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], size*1.1, size*1.1, "overlay")
			block.X:SetPoint ("center", block, "center")
			block.X:Hide()
			
			block.button = fw:CreateButton (block, AuraOnClick, 32, 32, "", block)
			block.button:SetPoint ("center", box, "center")
			block.button:SetHook ("OnEnter", aura_onenter2)
			block.button:SetHook ("OnLeave", aura_onleave2)
			block.button.block = block
			
			tinsert (DpsTuningPlugin.AuraBlocks, block)
		end
		
		for i = 1, 3 do
			local block = fw:CreatePanel (SDF, 32, 32)
			block:SetFrameLevel (SDF:GetFrameLevel()+2)
			block:SetPoint (170 + ((i-1) * 36), -220)
			block:SetHook ("OnEnter", aura_onenter)
			block:SetHook ("OnLeave", aura_onleave)
			block.icontexture = fw:CreateImage (block, nil, size, size, "border", coords)
			block.icontexture:SetPoint ("center", block, "center")
			block.icontexture.alpha = 0.9
			block.icontexture:SetVertexColor (unpack (color))
			block.texttime = fw:CreateLabel (block, "", 16, "yellow", "GameFontNormal", nil, nil, "artwork")
			block.texttime:SetPoint ("center", block, "center")
			
			block.X = fw:CreateImage (block, [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], size*1.1, size*1.1, "overlay")
			block.X:SetPoint ("center", block, "center")
			block.X:Hide()
			
			block.button = fw:CreateButton (block, AuraOnClick, 32, 32, "", block)
			block.button:SetPoint ("center", box, "center")
			block.button:SetHook ("OnEnter", aura_onenter2)
			block.button:SetHook ("OnLeave", aura_onleave2)
			block.button.block = block
			
			tinsert (DpsTuningPlugin.AuraBlocks, block)
		end
		
		for i = 1, 3 do
			local block = fw:CreatePanel (SDF, 32, 32)
			block:SetFrameLevel (SDF:GetFrameLevel()+2)
			block:SetPoint (170 + ((i-1) * 36), -260)
			block:SetHook ("OnEnter", aura_onenter)
			block:SetHook ("OnLeave", aura_onleave)
			block.icontexture = fw:CreateImage (block, nil, size, size, "border", coords)
			block.icontexture:SetPoint ("center", block, "center")
			block.icontexture.alpha = 0.9
			block.icontexture:SetVertexColor (unpack (color))
			block.texttime = fw:CreateLabel (block, "", 16, "yellow", "GameFontNormal", nil, nil, "artwork")
			block.texttime:SetPoint ("center", block, "center")
			
			block.X = fw:CreateImage (block, [[Interface\Glues\LOGIN\Glues-CheckBox-Check]], size*1.1, size*1.1, "overlay")
			block.X:SetPoint ("center", block, "center")
			block.X:Hide()
			
			block.button = fw:CreateButton (block, AuraOnClick, 32, 32, "", block)
			block.button:SetPoint ("center", box, "center")
			block.button:SetHook ("OnEnter", aura_onenter2)
			block.button:SetHook ("OnLeave", aura_onleave2)
			block.button.block = block
			
			tinsert (DpsTuningPlugin.AuraBlocks, block)
		end
		
	end
	
	function DpsTuningPlugin:ClearBuffBlocks()
		for index, block in ipairs (DpsTuningPlugin.AuraBlocks) do
			block.buff = nil
			block.icontexture.texture = nil
			block.texttime.text = ""
		end
	end
	
	function DpsTuningPlugin:UpdateBuffBlocks()
		for index, block in ipairs (DpsTuningPlugin.AuraBlocks) do
			if (block.buff) then
				if (block.buff.actived) then
					block.texttime.text = block.buff.uptime + (ClockTime() - block.buff.actived_at)
				else
					block.texttime.text = block.buff.uptime
				end
			end
		end
	end
	
	function DpsTuningPlugin:EnableAuraBlock (block_number, buff_table)
		if (block_number <= 9) then
			local block = DpsTuningPlugin.AuraBlocks [block_number]
			block.icontexture.texture = select (3, _GetSpellInfo (buff_table.spellid))
			block.buff = buff_table
		end
	end
	
	function DpsTuningPlugin:TrackBuffsAtEnd()
		for buffIndex = 1, 41 do
			local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellid  = UnitAura ("player", buffIndex, nil, "HELPFUL")
			local buff_table = buff_activity [spellid]
			if (buff_table) then
				if (buff_table.actived_at and buff_table.actived) then
					buff_table.uptime = buff_table.uptime + ClockTime() - buff_table.actived_at
				end
				buff_table.actived = false
				buff_table.actived_at = nil
				DpsTuningPlugin:BuffChartEnd (spellid)
			end
		end
	end
	
	function DpsTuningPlugin:BuffChartStart (spellid)
		local buff_chart = buff_graphic_data [spellid]
		if (not buff_chart) then
			buff_chart = {}
			buff_graphic_data [spellid] = buff_chart
		end
		local bufftime = {time_start = DpsTuningPlugin.CurTick, time_end = 0}
		tinsert (buff_chart, bufftime)
	end
	
	function DpsTuningPlugin:BuffChartEnd (spellid)
		local buff_chart = buff_graphic_data [spellid]
		if (buff_chart) then
			local bufftime = buff_chart [#buff_chart]
			bufftime.time_end = DpsTuningPlugin.CurTick
		end
	end
	
	function DpsTuningPlugin:TrackBuffsAtStart()
		for buffIndex = 1, 41 do
			local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellid  = UnitAura ("player", buffIndex, nil, "HELPFUL")
			
			if (name and unitCaster == "player" and duration > 0 and expirationTime > 0 and not shouldConsolidate) then
				local buff_table = buff_activity [spellid]
				if (not buff_table) then
					buff_table = {uptime = 0, actived = false, activedamt = 0, block = buff_activity.next, spellid = spellid, procs = {}}
					buff_activity.next = buff_activity.next + 1
					buff_activity [spellid] = buff_table
				end
				
				buff_table.actived = true
				buff_table.activedamt = 1
				buff_table.actived_at = ClockTime()
				tinsert (buff_table.procs, DpsTuningPlugin.CurCombat:GetCombatTime())

				DpsTuningPlugin:BuffChartStart (spellid)
				DpsTuningPlugin:EnableAuraBlock (buff_table.block, buff_table)
			end
		end
	end
	
	
	function DpsTuningPlugin:AuraApplied (time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, tipo, amount)
		if (tipo == "BUFF") then
		
			local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellid  = UnitAura ("player", spellname, nil, "HELPFUL")
			
			if (name and unitCaster == "player" and duration > 0 and expirationTime > 0 and not shouldConsolidate) then

				local buff_table = buff_activity [spellid]
				if (not buff_table) then
					buff_table = {uptime = 0, actived = false, activedamt = 0, block = buff_activity.next, spellid = spellid, procs = {}}
					buff_activity.next = buff_activity.next + 1
					buff_activity [spellid] = buff_table
				end
				
				buff_table.actived = true
				buff_table.activedamt = buff_table.activedamt + 1
				buff_table.actived_at = ClockTime()
				tinsert (buff_table.procs, DpsTuningPlugin.CurCombat:GetCombatTime())
				
				DpsTuningPlugin:BuffChartStart (spellid)
				DpsTuningPlugin:EnableAuraBlock (buff_table.block, buff_table)
			
			end
		end
	end

	function DpsTuningPlugin:AuraRefresh (time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, tipo, amount)
		if (tipo == "BUFF") then
			local buff_table = buff_activity [spellid]
			if (buff_table) then
				if (buff_table.actived_at and buff_table.actived) then
					buff_table.uptime = buff_table.uptime + ClockTime() - buff_table.actived_at
				end
				buff_table.actived_at = ClockTime()
				buff_table.actived = true
			end
		end
	end

	function DpsTuningPlugin:AuraRemoved (time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, tipo, amount)
		if (tipo == "BUFF") then
			local buff_table = buff_activity [spellid]
			if (buff_table) then
				if (buff_table.actived_at and buff_table.actived) then
					buff_table.uptime = buff_table.uptime + ClockTime() - buff_table.actived_at
				end
				buff_table.actived = false
				buff_table.actived_at = nil
				tinsert (buff_table.procs, DpsTuningPlugin.CurCombat:GetCombatTime())
				DpsTuningPlugin:BuffChartEnd (spellid)
			end
		end
	end
	
	local misscolor = {1, 0.3, 0.3}
	
	local bar_onenter_script = function (self, capsule)
	
		if (not DpsTuningPlugin.CurPlayer or not capsule.spellid) then
			return
		end
	
		GameCooltip:Reset()
		GameCooltip:SetOwner (self)
		GameCooltip:SetType ("tooltip")
		DpsTuningPlugin:CooltipPreset (2)
		
		local spell = DpsTuningPlugin.CurPlayer:GetSpell (capsule.spellid)
		local name, _, icon = _GetSpellInfo (capsule.spellid)
		
		GameCooltip:AddLine (name, "", 1, "orange", nil, 13, "Arrial Narrow")
		GameCooltip:AddIcon (icon)
		
		GameCooltip:AddLine ("")
		
		GameCooltip:AddLine ("Damage:", DpsTuningPlugin:comma_value (spell.total), 1, "white", nil, 10, "Arrial Narrow")
		GameCooltip:AddLine ("Hits:", spell.counter, 1, "white", nil, 10, "Arrial Narrow")
		GameCooltip:AddLine ("Dps:", DpsTuningPlugin:ToK2 (floor (spell.total / DpsTuningPlugin.CurPlayer:Tempo())), 1, "white", nil, 10, "Arrial Narrow")
		GameCooltip:AddLine ("Percent:", _cstr ("%.1f", spell.total / DpsTuningPlugin.CurPlayer.total_without_pet * 100) .. "%", 1, "white", nil, 10, "Arrial Narrow")
		
		GameCooltip:AddLine ("")
		
		GameCooltip:AddLine ("Average Damage:", DpsTuningPlugin:comma_value (floor (spell.total / spell.counter)), 1, "white", nil, 10, "Arrial Narrow")
		GameCooltip:AddLine ("Min Hit:", DpsTuningPlugin:comma_value (spell.n_min), 1, "white", nil, 10, "Arrial Narrow")
		GameCooltip:AddLine ("Max Hit:", DpsTuningPlugin:comma_value (math.max (spell.n_max, spell.c_max)), 1, "white", nil, 10, "Arrial Narrow")
		
		GameCooltip:AddLine ("")
		
		GameCooltip:AddLine ("Critical Hits:", _cstr ("%.1f", spell.c_amt / spell.counter * 100) .. "%", 1, "white", nil, 10, "Arrial Narrow")
		if (spell.c_amt > 0) then
			GameCooltip:AddLine ("Critical Average Damage:", DpsTuningPlugin:comma_value (floor (spell.c_dmg / spell.c_amt)), 1, "white", nil, 10, "Arrial Narrow")
		else
			GameCooltip:AddLine ("Critical Average Damage:", "0", 1, "white", nil, 10, "Arrial Narrow")
		end
		
		--uptime
		
		local misc = DpsTuningPlugin.CurCombat (DETAILS_ATTRIBUTE_MISC, DpsTuningPlugin.playername)
		if (misc) then
			local debuff_uptime = misc.debuff_uptime
			if (debuff_uptime) then
				local this_spell = misc.debuff_uptime_spells._ActorTable [capsule.spellid]
				if (this_spell) then
					GameCooltip:AddLine ("")
					local uptime = this_spell.uptime
					local minutos, segundos = floor (uptime/60), floor (uptime%60)
					GameCooltip:AddLine ("Uptime:", minutos .. "m " .. segundos .. "s", 1, "white", nil, 10, "Arrial Narrow")
				end
			end
		end
		
		--miss 
		GameCooltip:AddLine ("")
		
		local miss = spell ["MISS"]
		local parry = spell ["PARRY"]
		local dodge = spell ["DODGE"]
		
		if (miss) then
			GameCooltip:AddLine ("Miss:", miss .. " (" .. _cstr ("%.1f", miss / spell.counter * 100) .. "%)", 1, misscolor, nil, 10, "Arrial Narrow")
		end
		if (parry) then
			GameCooltip:AddLine ("Parry:", parry .. " (" .. _cstr ("%.1f", parry / spell.counter * 100) .. "%)", 1, misscolor, nil, 10, "Arrial Narrow")
		end
		if (dodge) then
			GameCooltip:AddLine ("Dodge:", dodge .. " (" .. _cstr ("%.1f", dodge / spell.counter * 100) .. "%)", 1, misscolor, nil, 10, "Arrial Narrow")
		end
		if (spell.g_amt > 0) then
			GameCooltip:AddLine ("Glancing:", spell.g_amt .. " (" .. _cstr ("%.1f", spell.g_amt / spell.counter * 100) .. "%)", 1, misscolor, nil, 10, "Arrial Narrow")
		end

		GameCooltip:SetOption ("AlignAsBlizzTooltip", true)
		GameCooltip:Show()
	end
	
	local bar_onleanve_script = function (self)
		GameCooltip:Hide()
	end
	
	function DpsTuningPlugin:BuildSpellBars()
		DpsTuningPlugin.SpellBars = {}
		
		local scrollbar = CreateFrame ("scrollframe", "DpsTuningPluginSpellsFauxScroll", DpsTuningPlugin.Frame, "FauxScrollFrameTemplate")
		scrollbar:SetSize (275, 150)
		scrollbar:SetPoint ("topleft", DpsTuningPlugin.Frame, "topleft", 1, 0)
		scrollbar:SetScript ("OnVerticalScroll", function (self, offset) FauxScrollFrame_OnVerticalScroll (self, offset, 15, update_scroll) end)
		scrollbar.Update = update_scroll
		DpsTuningPlugin.SpellScroll = scrollbar
		
		for i = 1, 9 do
			local bar = fw:CreateBar (DpsTuningPlugin.Frame, "Skyline", 275, 14, 100)
			bar.color = DpsTuningPlugin.BarColor
			bar.textfont = "Arial Narrow"
			bar.textsize = 10
			bar:SetPoint ("topleft", DpsTuningPlugin.Frame, "topleft", 1, ((i-1) * -15) - 20)
			
			bar:SetHook ("OnEnter", bar_onenter_script)
			bar:SetHook ("OnLeave", bar_onleanve_script)
			
			tinsert (DpsTuningPlugin.SpellBars, bar)
		end
	end
	
	local colors = {
		{1, 1, 1}, --white
		{1, 0.8, .1}, --orange
		{.3, .3, 1}, --blue
		{1, .3, .3}, --red
		{.3, 1, .3}, --green
		{.3, 1, 1}, --cyan
		{1, 0.75, 0.79}, --pink
		{0.98, 0.50, 0.44}, --salmon
		{0.75, 0.75, 0.75}, --silver
		{0.60, 0.80, 0.19}, --yellow
		{1, .3, 1}, --magenta
	}
	
	local linetypes = {"line", "smallline", "thinline"}
	
	function DpsTuningPlugin:BuildChartPanels()

		local chart_panel = fw:CreateChartPanel (UIParent, GetScreenWidth()-200, 500)
		chart_panel:SetPoint ("topleft", UIParent, "topleft", 100, -100)
		chart_panel:SetTitle ("Dps Tuning")
		chart_panel:SetFrameStrata ("DIALOG")
		chart_panel:CanMove (true)
		tinsert (UISpecialFrames, chart_panel:GetName())

		chart_panel:Hide()
		
		local open_chart_panel = function()
			chart_panel:Reset()
		
			local player_dps = DpsTuningPlugin.CurCombat:GetTimeData ("Player Damage Done")
			
			local combat_time = DpsTuningPlugin.CurCombat:GetCombatTime()
			chart_panel:SetTime (combat_time)
			chart_panel:SetScale (player_dps.max_value)
			
			chart_panel:AddLine (player_dps, {1, 1, 1, 1}, "Your Damage", combat_time, "line")
			chart_panel:AddLine (power_amount_chart_table, {1, .4, .4, 1}, "Spell/Attack Power (x3)", combat_time)

			chart_panel:Show()
		end
		
		local open_chart_panel2 = function()

			chart_panel:Reset()
			
			local GraphicSmoothLevel = 1
			
			--> we need to copy because of the addition of spells with the same icon.
			local spell_graphic_data = table_deepcopy (spell_graphic_data)
			
			local consolidate = {}
			for spellid, data in pairs (spell_graphic_data) do
				local spellname, _, spellicon = _GetSpellInfo (spellid)
				if (consolidate [spellicon]) then
				
					local data2 = consolidate [spellicon][3]
					local new_max_value = consolidate [spellicon][4]
					
					for i = 1, #data do
						data2[i] = data2[i] + data[i] --can be the same table as the default one or it just will add and add over again.
						if (data2[i] > new_max_value) then
							new_max_value = data2[i]
						end
					end
					
					consolidate [spellicon][4] = new_max_value
					
					local spelldamage = DpsTuningPlugin.CurPlayer:GetSpell (spellid).total
					consolidate [spellicon][5] = consolidate [spellicon][5] + spelldamage
					
					if (string.len (spellname) < string.len (consolidate [spellicon][2])) then
						consolidate [spellicon][2] = spellname
					end

				else
					consolidate [spellicon] = {spellid, spellname, data, data.max_value, DpsTuningPlugin.CurPlayer:GetSpell (spellid).total}
				end
			end

			local order = {}
			for spellid, data in pairs (consolidate) do
				tinsert (order, data)
			end
			
			table.sort (order, DpsTuningPlugin.Sort1)

			local player_total_damage = DpsTuningPlugin.CurPlayer.total
			
			local max = 0
			
			for index, data in ipairs (order) do
				local spellid = data[1]
				local spellname = data[2]
				local chart_data = data[3]
				local max_value = data[4]
				if (max_value > max) then
					max = max_value
				end
				local spelldamage = data[5]
				
				if (spelldamage/player_total_damage*100 > 5) then
					if (colors [index]) then
						chart_panel:AddLine (chart_data, colors [index], spellname, DpsTuningPlugin.CurCombat:GetCombatTime(), nil, GraphicSmoothLevel)
					end
				end
			end

			chart_panel:SetTime (DpsTuningPlugin.CurCombat:GetCombatTime())
			chart_panel:SetScale (max)
			
			chart_panel:Show()
		end
		
		local open_chart_panel3 = function()
			
			chart_panel:Reset()
		
			local player_dps = DpsTuningPlugin.CurCombat:GetTimeData ("Player Damage Done")
			chart_panel:AddLine (player_dps, {1, 1, 1, 1}, "Your Damage", DpsTuningPlugin.CurCombat:GetCombatTime(), "line")

			chart_panel:SetTime (DpsTuningPlugin.CurCombat:GetCombatTime())
			chart_panel:SetScale (player_dps.max_value)

			local index = 1
			for spellid, bufftable in pairs (buff_activity) do
				if (type (bufftable) == "table") then
					if (not bufftable.disabled) then
						local proctable = bufftable.procs
						
						local spellname, _, spellicon = _GetSpellInfo (spellid)
						
						chart_panel:AddOverlay (bufftable.procs, colors [index], spellname, spellicon)
						index = index + 1
					end
				end
			end
			
			chart_panel:Show()
			
		end

		local button_open = fw:CreateButton (SDF, open_chart_panel, 120, 18, "Damage x Power", nil, nil, nil, "OpenGraphicButton")
		button_open:InstallCustomTexture (nil, nil, nil, nil, true)
		button_open:SetPoint ("bottomleft", SDF, "bottomleft", 2, 3)
		button_open:Disable()
		
		local button_open2 = fw:CreateButton (SDF, open_chart_panel2, 120, 18, "All Spells", nil, nil, nil, "OpenGraphicButton2")
		button_open2:InstallCustomTexture (nil, nil, nil, nil, true)
		button_open2:SetPoint ("bottom", button_open, "top", 0, 3)
		button_open2:Disable()
		
		local button_open3 = fw:CreateButton (SDF, open_chart_panel3, 120, 18, "Aura Procs", nil, nil, nil, "OpenGraphicButton3")
		button_open3:InstallCustomTexture (nil, nil, nil, nil, true)
		button_open3:SetPoint ("bottom", button_open2, "top", 0, 3)
		button_open3:Disable()

	end

	
	function DpsTuningPlugin:UpdateSummary()
		if (DpsTuningPlugin.CurPlayer) then
			DpsTuningPlugin.total_damage.text = DpsTuningPlugin:comma_value (floor (DpsTuningPlugin.CurPlayer.total))
			DpsTuningPlugin.activity_dps.text = DpsTuningPlugin:ToK2 (floor (DpsTuningPlugin.CurPlayer.total / DpsTuningPlugin.CurPlayer:Tempo()))
			DpsTuningPlugin.time_elapsed.text = _cstr ("%.1f", GetTime() - DpsTuningPlugin.StartTime)
			DpsTuningPlugin.power_amount.text = DpsTuningPlugin:comma_value (GetSpellBonusDamage (DpsTuningPlugin.PowerType))
		end
	end
	
	function DpsTuningPlugin:UpdateMiliTick()
		DpsTuningPlugin:UpdateSummary()
	end
	
	function DpsTuningPlugin:UpdateTick()
	
		--check for current player
		if (not DpsTuningPlugin.CurPlayer) then
			if (not DpsTuningPlugin.CurCombat) then
				return
			end
			DpsTuningPlugin.CurPlayer = DpsTuningPlugin.CurCombat (DETAILS_ATTRIBUTE_DAMAGE, DpsTuningPlugin.playername)
			if (not DpsTuningPlugin.CurPlayer) then
				return
			end
			
			if (DpsTuningPlugin.CurPlayer and not DpsTuningPlugin.MiliSecTick) then
				DpsTuningPlugin.MiliSecTick = DpsTuningPlugin:ScheduleRepeatingTimer ("UpdateMiliTick", 0.1)
			end
		end
		
		DpsTuningPlugin.CurTick = DpsTuningPlugin.CurTick + 1
		
		--refresh bars
		DpsTuningPlugin.RefreshSpells()
		
		--refresh buff blocks
		DpsTuningPlugin:UpdateBuffBlocks()
		
		--get spells damages
		DpsTuningPlugin:ChartDataTick()

	end
	
	function DpsTuningPlugin:ChartDataTick()
	
		local power = math.max (GetSpellBonusDamage (1), GetSpellBonusDamage (2)) * 3
		tinsert (power_amount_chart_table, power)
		if (power_amount_chart_table.max_value < power) then
			power_amount_chart_table.max_value = power
		end
	
		for spellid, spelltable in pairs (DpsTuningPlugin.CurPlayer:GetActorSpells()) do 
			if (spelltable.total > 0) then
				
				local chart_table = spell_graphic_data [spelltable.id]
				
				if (not chart_table) then
					local new_chart_data = {}
					new_chart_data.last_value = 0
					new_chart_data.max_value = 0
					
					for i = 1, DpsTuningPlugin.CurTick-1 do
						tinsert (new_chart_data, 0)
					end
					spell_graphic_data [spelltable.id] = new_chart_data
					chart_table = new_chart_data
				end
				
				local cvalue = spelltable.total - chart_table.last_value
				if (chart_table.max_value < cvalue) then
					chart_table.max_value = cvalue
				end
				tinsert (chart_table, cvalue)
				chart_table.last_value = spelltable.total
				
			end
		end
	end
	
	function DpsTuningPlugin:OnDataReset (...)
		DpsTuningPlugin.CurCombat = nil
		DpsTuningPlugin.CurPlayer = nil
		
		table.wipe (spell_activity)
		table.wipe (buff_activity)
		table.wipe (spell_graphic_data)
		table.wipe (buff_graphic_data)
		table.wipe (power_amount_chart_table)
		
		DpsTuningPlugin:ClearBuffBlocks()
		
		SDF.OpenGraphicButton:Disable()
		SDF.OpenGraphicButton2:Disable()
		SDF.OpenGraphicButton3:Disable()
		
		if (DpsTuningPlugin.SpellBars) then
			for bar_index = 1, 9 do 
				local bar = DpsTuningPlugin.SpellBars [bar_index]
				if (bar) then
					bar:Hide()
				end
			end
		end
		
		DpsTuningPlugin.FinishedAt = 0
	end
	
	function DpsTuningPlugin:OnCombatStart (...)
	
		if (DpsTuningPlugin.FinishedAt+10 > ClockTime()) then
			DpsTuningPlugin:Msg ("Ignoring combat start: a combat just finished.")
			DpsTuningPlugin.FinishedAt = ClockTime()
			return
		end
		
		DpsTuningPlugin.CurCombat = ...
		DpsTuningPlugin.CurPlayer = DpsTuningPlugin.CurCombat (DETAILS_ATTRIBUTE_DAMAGE, DpsTuningPlugin.playername)
	
		table.wipe (spell_activity)
		table.wipe (buff_activity)
		table.wipe (spell_graphic_data)
		table.wipe (buff_graphic_data)
		table.wipe (power_amount_chart_table)
	
		buff_activity.next = 1
		power_amount_chart_table.max_value = 0
		
		DpsTuningPlugin:ClearBuffBlocks()
		DpsTuningPlugin:TrackBuffsAtStart()
		
		--> enable buff parser
		SDF:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
		
		DpsTuningPlugin.LastDps = 0
		DpsTuningPlugin.CurTick = 0
		DpsTuningPlugin.StartTime = GetTime()
		
		DpsTuningPlugin.TimerTick = DpsTuningPlugin:ScheduleRepeatingTimer ("UpdateTick", 1)
		
		if (DpsTuningPlugin.CurPlayer and not DpsTuningPlugin.MiliSecTick) then
			DpsTuningPlugin.MiliSecTick = DpsTuningPlugin:ScheduleRepeatingTimer ("UpdateMiliTick", 0.1)
		end
		
		SDF.OpenGraphicButton:Disable()
		SDF.OpenGraphicButton2:Disable()
		SDF.OpenGraphicButton3:Disable()
	
	end
	
	function DpsTuningPlugin:OnCombatEnd (...)
		local combat = ...
		
		if (DpsTuningPlugin.CurCombat and DpsTuningPlugin.CurCombat == combat) then
			local now = ClockTime()
			
			DpsTuningPlugin.FinishedAt = now
			
			--> close spells 
			for spellid, spelltable in pairs (spell_activity) do
				if (spelltable.onhold) then
					local diff = now - spelltable.delay - 2
					if (diff > 0) then
						spelltable.start = spelltable.start + diff
					end
					spelltable.onhold = nil
				end
				
				spelltable.tempo_end = now
			end
			
			--> close buffs
			DpsTuningPlugin:TrackBuffsAtEnd()
			
			--> turn off buff parser
			SDF:UnregisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
			
			--> cancel tick
			DpsTuningPlugin:CancelTicker()
			
			SDF.OpenGraphicButton:Enable()
			SDF.OpenGraphicButton2:Enable()
			SDF.OpenGraphicButton3:Enable()
		end
	end
	

	
	function DpsTuningPlugin:CancelTicker()
		if (DpsTuningPlugin.TimerTick) then
			DpsTuningPlugin:CancelTimer (DpsTuningPlugin.TimerTick)
			DpsTuningPlugin.TimerTick = nil
		end
		if (DpsTuningPlugin.MiliSecTick) then
			DpsTuningPlugin:CancelTimer (DpsTuningPlugin.MiliSecTick)
			DpsTuningPlugin.MiliSecTick = nil
		end
	end

end

function DpsTuningPlugin:OnEvent (_, event, ...)

	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
	
		local time1, token, hidding, who_serial, who_name, who_flags, who_flags2, alvo_serial, alvo_name, alvo_flags, alvo_flags2, spellid, spellname, spellschool, tipo, amount = select (1, ...)
		
		if (who_name == DpsTuningPlugin.playername and alvo_name == DpsTuningPlugin.playername) then
			if (token == "SPELL_AURA_APPLIED") then
				DpsTuningPlugin:AuraApplied (time1, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, tipo, amount)
			elseif (token == "SPELL_AURA_REMOVED") then
				DpsTuningPlugin:AuraRemoved (time1, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, tipo, amount)
			elseif (token == "SPELL_AURA_REFRESH") then
				DpsTuningPlugin:AuraRefresh (time1, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, spellid, spellname, spellschool, tipo, amount)
			end
		end

	elseif (event == "ADDON_LOADED") then
		local AddonName = select (1, ...)
		if (AddonName == "Details_DpsTuning") then
			
			if (_G._detalhes) then
				
				--> create main plugin object
				CreatePluginFrames()
				
				local MINIMAL_DETAILS_VERSION_REQUIRED = 28
				
				local default_settings = {
					SpellBarsShowType = 1,
				}
				
				--> Install plugin inside details
				local install = _G._detalhes:InstallPlugin ("SOLO", "Dps Tuning", "Interface\\Icons\\Ability_Racial_RocketBarrage", DpsTuningPlugin, "DETAILS_PLUGIN_DPS_TUNING", MINIMAL_DETAILS_VERSION_REQUIRED, "Details! Team", "v1.1", default_settings)
				if (type (install) == "table" and install.error) then
					print (install.error)
				end
				
				--> Register needed events
				_G._detalhes:RegisterEvent (DpsTuningPlugin, "COMBAT_PLAYER_ENTER")
				_G._detalhes:RegisterEvent (DpsTuningPlugin, "COMBAT_PLAYER_LEAVE")
				_G._detalhes:RegisterEvent (DpsTuningPlugin, "DETAILS_DATA_RESET")
				_G._detalhes:RegisterEvent (DpsTuningPlugin, "COMBAT_INVALID")
				
			end
		end

	end
end
