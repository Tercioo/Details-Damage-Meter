local AceLocale = LibStub ("AceLocale-3.0")
local Loc = AceLocale:GetLocale ("Details_EncounterDetails")
local Graphics = LibStub:GetLibrary("LibGraph-2.0")

--> Needed locals
local _GetTime = GetTime --> wow api local
local _UFC = UnitAffectingCombat --> wow api local
local _IsInRaid = IsInRaid --> wow api local
local _IsInGroup = IsInGroup --> wow api local
local _UnitAura = UnitAura --> wow api local
local _GetSpellInfo = _detalhes.getspellinfo --> wow api local
local _CreateFrame = CreateFrame --> wow api local
local _GetTime = GetTime --> wow api local
local _GetCursorPosition = GetCursorPosition --> wow api local
local _GameTooltip = GameTooltip --> wow api local

local _math_floor = math.floor --> lua library local
local _cstr = string.format --> lua library local
local _ipairs = ipairs --> lua library local
local _pairs = pairs --> lua library local
local _table_sort = table.sort --> lua library local
local _table_insert = table.insert --> lua library local
local _unpack = unpack --> lua library local


--> Create the plugin Object
local EncounterDetails = _detalhes:NewPluginObject ("Details_EncounterDetails", DETAILSPLUGIN_ALWAYSENABLED)
tinsert (UISpecialFrames, "Details_EncounterDetails")
--> Main Frame
local EncounterDetailsFrame = EncounterDetails.Frame

--> container types
local class_type_damage = _detalhes.atributos.dano --> damage
local class_type_misc = _detalhes.atributos.misc --> misc
--> main combat object
local _combat_object

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS

EncounterDetails.name = "Encounter Details"

local ability_type_table = {
	[0x1] = "|cFF00FF00"..Loc ["STRING_HEAL"].."|r", 
	[0x2] = "|cFF710000"..Loc ["STRING_LOWDPS"].."|r", 
	[0x4] = "|cFF057100"..Loc ["STRING_LOWHEAL"].."|r", 
	[0x8] = "|cFFd3acff"..Loc ["STRING_VOIDZONE"].."|r", 
	[0x10] = "|cFFbce3ff"..Loc ["STRING_DISPELL"].."|r", 
	[0x20] = "|cFFffdc72"..Loc ["STRING_INTERRUPT"].."|r", 
	[0x40] = "|cFFd9b77c"..Loc ["STRING_POSITIONING"].."|r", 
	[0x80] = "|cFFd7ff36"..Loc ["STRING_RUNAWAY"].."|r", 
	[0x100] = "|cFF9a7540"..Loc ["STRING_TANKSWITCH"] .."|r", 
	[0x200] = "|cFFff7800"..Loc ["STRING_MECHANIC"].."|r", 
	[0x400] = "|cFFbebebe"..Loc ["STRING_CROWDCONTROL"].."|r", 
	[0x800] = "|cFF6e4d13"..Loc ["STRING_TANKCOOLDOWN"].."|r", 
	[0x1000] = "|cFFffff00"..Loc ["STRING_KILLADD"].."|r", 
	[0x2000] = "|cFFff9999"..Loc ["STRING_SPREADOUT"].."|r", 
	[0x4000] = "|cFFffff99"..Loc ["STRING_STOPCAST"].."|r",
	[0x8000] = "|cFFffff99"..Loc ["STRING_FACING"].."|r",
	[0x10000] = "|cFFffff99"..Loc ["STRING_STACK"].."|r",
	
}

local debugmode = false

--> main object frame functions
local function CreatePluginFrames (data)
	
	--> catch Details! main object
	local _detalhes = _G._detalhes
	local DetailsFrameWork = _detalhes.gump

	--> saved data if any
	EncounterDetails.data = data or {}
	--> record if button is shown
	EncounterDetails.showing = false
	--> record if boss window is open or not
	EncounterDetails.window_open = false
	EncounterDetails.combat_boss_found = false
	
	--> OnEvent Table
	function EncounterDetails:OnDetailsEvent (event, ...)
	
		--> when main frame became hide
		if (event == "HIDE") then --> plugin hidded, disabled
			self.open = false
		
		--> when main frame is shown on screen
		elseif (event == "SHOW") then --> plugin hidded, disabled
			self.open = true
		
		--> when details finish his startup and are ready to work
		elseif (event == "DETAILS_STARTED") then
			--> check if details are in combat, if not check if the last fight was a boss fight
			if (not EncounterDetails:IsInCombat()) then
				--> get the current combat table
				_combat_object = EncounterDetails:GetCombat()
				--> check if was a boss fight
				EncounterDetails:WasEncounter()
			end
			
			local damage_done_func = function (support_table, time_table, tick_second)

				local current_total_damage = _detalhes.tabela_vigente.totals_grupo[1]
				
				local current_damage = current_total_damage - support_table.last_damage
				
				time_table [tick_second] = current_damage
				
				if (current_damage > support_table.max_damage) then
					support_table.max_damage = current_damage
					time_table.max_damage = current_damage
				end
				
				support_table.last_damage = current_total_damage
			
			end
			
			local string_damage_done_func = [[
			
				-- this script takes the current combat and request the total of damage done by the group.
			
				-- first lets take the current combat and name it "current_combat".
				local current_combat = _detalhes:GetCombat ("current") --> getting the current combat
				
				-- now lets ask the combat for the total damage done by the raide group.
				local total_damage = current_combat:GetTotal ( DETAILS_ATTRIBUTE_DAMAGE, nil, DETAILS_TOTALS_ONLYGROUP )
			
				-- checks if the result is valid
				if (not total_damage) then
					return 0
				end
			
				-- with the  number in hands, lets finish the code returning the amount
				return total_damage
			]]
			
			--_detalhes:TimeDataRegister ("Raid Damage Done", damage_done_func, {last_damage = 0, max_damage = 0}, "Encounter Details", "v1.0", [[Interface\ICONS\Ability_DualWield]], true)
			_detalhes:TimeDataRegister ("Raid Damage Done", string_damage_done_func, nil, "Encounter Details", "v1.0", [[Interface\ICONS\Ability_DualWield]], true, true)
		
		elseif (event == "COMBAT_PLAYER_ENTER") then --> combat started
			if (EncounterDetails.showing) then
				EncounterDetails:HideIcon()
				EncounterDetails:CloseWindow()
			end
		
		elseif (event == "COMBAT_PLAYER_LEAVE") then
			--> combat leave and enter always send current combat table
			_combat_object = select (1, ...)
			--> check if was a boss fight
			EncounterDetails:WasEncounter()
			if (EncounterDetails.combat_boss_found) then
				EncounterDetails.combat_boss_found = false
			end
			
		elseif (event == "COMBAT_BOSS_FOUND") then
			EncounterDetails.combat_boss_found = true

		elseif (event == "DETAILS_DATA_RESET") then
			if (_G.DetailsRaidDpsGraph) then
				_G.DetailsRaidDpsGraph:ResetData()
			end
			EncounterDetails:HideIcon()
			EncounterDetails:CloseWindow()
			
		elseif (event == "PLUGIN_DISABLED") then
			EncounterDetails:HideIcon()
			EncounterDetails:CloseWindow()
			
		elseif (event == "PLUGIN_ENABLED") then
			--EncounterDetails:ShowIcon()
			
		end
	end
	
	function EncounterDetails:WasEncounter()

		--> check if last combat was a boss encounter fight
		if (not debugmode) then
			if (not _combat_object.is_boss) then
				_combat_object.is_boss = EncounterDetails:FindBoss()
				if (not _combat_object.is_boss) then
					return
				end
			elseif (_combat_object.is_boss.encounter == "pvp") then 
				return
			end
		end

		--> boss found, we need to show the icon
		EncounterDetails:ShowIcon()
	end
	
	--> show icon on toolbar
	function EncounterDetails:ShowIcon()
		EncounterDetails.showing = true
		--> [1] button to show [2] button animation: "star", "blink" or true (blink)
		EncounterDetails:ShowToolbarIcon (EncounterDetails.ToolbarButton, "star")
	end
	
	-->  hide icon on toolbar
	function EncounterDetails:HideIcon()
		EncounterDetails.showing = false
		EncounterDetails:HideToolbarIcon (EncounterDetails.ToolbarButton)
	end
	
	--> user clicked on button, need open or close window
	function EncounterDetails:OpenWindow()
		if (EncounterDetails.open) then
			return EncounterDetails:CloseWindow()
		end
		
		--> build all window data
		EncounterDetails:OpenAndRefresh()
		--> show
		EncounterDetailsFrame:Show()
		if (EncounterDetailsFrame.ShowType == "graph") then
			EncounterDetails:BuildDpsGraphic()
		end
		return true
	end
	
	function EncounterDetails:CloseWindow()
		EncounterDetailsFrame:Hide()
		return true
	end
	
	--> create the button to show on toolbar [1] function OnClick [2] texture [3] tooltip [4] width or 14 [5] height or 14 [6] frame name or nil
	--EncounterDetails.ToolbarButton = _detalhes.ToolBar:NewPluginToolbarButton (EncounterDetails.OpenWindow, "Interface\\Scenarios\\ScenarioIcon-Boss", Loc ["STRING_PLUGIN_NAME"], Loc ["STRING_TOOLTIP"], 12, 12, "ENCOUNTERDETAILS_BUTTON") --"Interface\\COMMON\\help-i"
	EncounterDetails.ToolbarButton = _detalhes.ToolBar:NewPluginToolbarButton (EncounterDetails.OpenWindow, "Interface\\AddOns\\Details_EncounterDetails\\images\\icon", Loc ["STRING_PLUGIN_NAME"], Loc ["STRING_TOOLTIP"], 16, 16, "ENCOUNTERDETAILS_BUTTON") --"Interface\\COMMON\\help-i"
	--> setpoint anchors mod if needed
	EncounterDetails.ToolbarButton.y = 0.5
	EncounterDetails.ToolbarButton.x = 0
	
	--> build all frames ans widgets
	_detalhes.EncounterDetailsTempWindow (EncounterDetails)
	_detalhes.EncounterDetailsTempWindow = nil
	
end

local IsShiftKeyDown = IsShiftKeyDown

local shift_monitor = function (self)
	if (IsShiftKeyDown()) then
		local spellname = GetSpellInfo (self.spellid)
		if (spellname) then
			GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
			GameTooltip:SetSpellByID (self.spellid)
			GameTooltip:Show()
			self.showing_spelldesc = true
		end
	else
		if (self.showing_spelldesc) then
			self:GetScript ("OnEnter") (self)
			self.showing_spelldesc = false
		end
	end
end

--> custom tooltip for dead details ---------------------------------------------------------------------------------------------------------

	local function KillInfo (deathTable, row)
		
		local lastEvents = deathTable [1]
		local timeOfDeath = deathTable [2]
		local hp_max = deathTable [5]
		
		local lines = {}
		
		local battleress = false
		local skillTable = row.extra
		
		local GameCooltip = GameCooltip
		
		GameCooltip:Reset()
		GameCooltip:SetType ("tooltipbar")
		GameCooltip:SetOwner (row)
		
		
		for index, event in _ipairs (lastEvents) do 
		
			--max hp percent (in case of hp cooldowns)
			local hp = _math_floor (event[5]/hp_max*100)
			if (hp > 100) then 
				hp = 100
			end
			
			if (event [1]) then --> DAMAGE
				local nome_magia, _, icone_magia = _GetSpellInfo (event [2])
				
				if (not event[3] and not battleress) then --> battle ress
					GameCooltip:AddLine ("+".._cstr ("%.1f", event[4] - timeOfDeath) .."s "..nome_magia.." ("..event[6]..")", "-- -- -- ", 1, "white")
					GameCooltip:AddIcon ("Interface\\Glues\\CharacterSelect\\Glues-AddOn-Icons", 1, 1, nil, nil, .75, 1, 0, 1)
					GameCooltip:AddStatusBar (100, 1, "silver", false)
					battleress = true
					
				elseif (event[3]) then
					
					local habilidade_school = skillTable [event [2]] --> pegou a tabela com os hex
					local _school = ""
					
					if (habilidade_school) then
						for _, hex in _ipairs (habilidade_school) do 
							_school = _school .. " " .. ability_type_table [hex]
						end
					end
					
					_school = _detalhes:trim (_school)
					local texto_esquerdo
					if (nome_magia) then
						texto_esquerdo = "".._cstr ("%.1f", event[4] - timeOfDeath) .."s " .. nome_magia .. " (".. event [6] ..")" --" (".. _school ..")"
						texto_esquerdo = texto_esquerdo:gsub ("(%()%)", "")
					else
						texto_esquerdo = ""
					end
					
					if (type (event [1]) ~= "boolean" and event [1] == 2) then --> last cooldown
						if (event[3] == 1) then 
							GameCooltip:AddLine ("".._cstr ("%.1f", event[4] - timeOfDeath) .. "s " .. nome_magia .. " (" .. Loc ["STRING_LAST_COOLDOWN"] .. ")")
							GameCooltip:AddIcon (icone_magia)
							GameCooltip:AddStatusBar (100, 1, "gray", true)
						else
							GameCooltip:AddLine (Loc ["STRING_NOLAST_COOLDOWN"])
							GameCooltip:AddStatusBar (100, 1, "gray", true)
						end
					else
						GameCooltip:AddLine (texto_esquerdo, "-".._detalhes:ToK (event[3]).." (".. hp .."%)", 1, "white", "white")
						GameCooltip:AddIcon (icone_magia)
						
						if (type (event [1]) ~= "boolean" and event [1] == 1) then --> cooldown
							GameCooltip:AddStatusBar (100, 1, "yellow", true)
						else
							GameCooltip:AddStatusBar (hp, 1, "red", true)
						end
					end
						
				end
			else
				local nome_magia, _, icone_magia = _GetSpellInfo (event [2])
				GameCooltip:AddLine ("".._cstr ("%.1f", event[4] - timeOfDeath) .."s "..nome_magia.." ("..event[6]..")", "+".._detalhes:ToK (event[3]).." (".. hp .."%)", 1, "white", "white")
				GameCooltip:AddIcon (icone_magia, 1, 1)
				GameCooltip:AddStatusBar (hp, 1, "green", true)
			end
		end
		
		if (battleress) then
			GameCooltip:AddSpecial ("line", 2, nil, deathTable [6] .. " "..Loc ["STRING_DIED"], "-- -- -- ", 1, "white")
			GameCooltip:AddSpecial ("icon", 2, nil, "Interface\\AddOns\\Details\\images\\small_icons", 1, 1, nil, nil, .75, 1, 0, 1)
			GameCooltip:AddSpecial ("statusbar", 2, nil, 100, 1, "darkgray", false)
		else
			GameCooltip:AddSpecial ("line", 1, nil, deathTable [6] .. " "..Loc ["STRING_DIED"], "-- -- -- ", 1, "white")
			GameCooltip:AddSpecial ("icon", 1, nil, "Interface\\AddOns\\Details\\images\\small_icons", 1, 1, nil, nil, .75, 1, 0, 1)
			GameCooltip:AddSpecial ("statusbar", 1, nil, 100, 1, "darkgray", false)

		end
		
		GameCooltip:SetOption ("StatusBarHeightMod", -6)
		GameCooltip:SetOption ("FixedWidth", 400)
		GameCooltip:SetOption ("TextSize", 9)
		GameCooltip:SetOption ("StatusBarTexture", "Interface\\AddOns\\Details\\images\\bar_serenity")
		GameCooltip:ShowCooltip()
		
	end

--> custom tooltip for dispells details ---------------------------------------------------------------------------------------------------------
local function DispellInfo (dispell, barra)
	
	local jogadores = dispell [1] --> [nome od jogador] = total
	local tabela_jogadores = {}
	
	for nome, tabela in _pairs (jogadores) do --> tabela = [1] total tomado [2] classe
		tabela_jogadores [#tabela_jogadores + 1] = {nome, tabela [1], tabela [2]}
	end
	
	_table_sort (tabela_jogadores, function (a, b) return a[2] > b[2] end)
	
	_GameTooltip:ClearLines()
	_GameTooltip:AddLine (barra.texto_esquerdo:GetText())
	
	for index, tabela in _ipairs (tabela_jogadores) do
		local coords = CLASS_ICON_TCOORDS [tabela[3]]
		if (not coords) then
			GameTooltip:AddDoubleLine ("|TInterface\\GossipFrame\\DailyActiveQuestIcon:14:14:0:0:16:16:0:1:0:1".."|t "..tabela[1]..": ", tabela[2], 1, 1, 1, 1, 1, 1)
		else
			GameTooltip:AddDoubleLine ("|TInterface\\AddOns\\Details\\images\\classes_small:14:14:0:0:128:128:"..(coords[1]*128)..":"..(coords[2]*128)..":"..(coords[3]*128)..":"..(coords[4]*128).."|t "..tabela[1]..": ", tabela[2], 1, 1, 1, 1, 1, 1)
		end
	end
end

--> custom tooltip for kick details ---------------------------------------------------------------------------------------------------------

local function KickBy (magia, barra)

	local jogadores = magia [1] --> [nome od jogador] = total
	local tabela_jogadores = {}
	
	for nome, tabela in _pairs (jogadores) do --> tabela = [1] total tomado [2] classe
		tabela_jogadores [#tabela_jogadores + 1] = {nome, tabela [1], tabela [2]}
	end
	
	_table_sort (tabela_jogadores, function (a, b) return a[2] > b[2] end)
	
	_GameTooltip:ClearLines()
	_GameTooltip:AddLine (barra.texto_esquerdo:GetText())
	
	for index, tabela in _ipairs (tabela_jogadores) do
		local coords = CLASS_ICON_TCOORDS [tabela[3]]
		GameTooltip:AddDoubleLine ("|TInterface\\AddOns\\Details\\images\\classes_small:14:14:0:0:128:128:"..(coords[1]*128)..":"..(coords[2]*128)..":"..(coords[3]*128)..":"..(coords[4]*128).."|t "..tabela[1]..": ", tabela[2], 1, 1, 1, 1, 1, 1)
	end
end

--> custom tooltip for enemy abilities details ---------------------------------------------------------------------------------------------------------

local function EnemySkills (habilidade, barra)
	--> barra.jogador agora tem a tabela com --> [1] total dano causado [2] jogadores que foram alvos [3] jogadores que castaram essa magia [4] ID da magia
	
	local total = habilidade [1]
	local jogadores = habilidade [2] --> [nome od jogador] = total
	
	local tabela_jogadores = {}
	
	for nome, tabela in _pairs (jogadores) do --> tabela = [1] total tomado [2] classe
		tabela_jogadores [#tabela_jogadores + 1] = {nome, tabela[1], tabela[2]}
	end
	
	_table_sort (tabela_jogadores, function (a, b) return a[2] > b[2] end)
	
	_GameTooltip:ClearLines()
	_GameTooltip:AddLine (barra.texto_esquerdo:GetText())
	
	for index, tabela in _ipairs (tabela_jogadores) do
		local coords = CLASS_ICON_TCOORDS [tabela[3]]
		if (coords) then
			GameTooltip:AddDoubleLine ("|TInterface\\AddOns\\Details\\images\\classes_small:14:14:0:0:128:128:"..(coords[1]*128)..":"..(coords[2]*128)..":"..(coords[3]*128)..":"..(coords[4]*128).."|t "..tabela[1]..": ", _detalhes:comma_value(tabela[2]).." (".._cstr("%.1f", (tabela[2]/total) * 100).."%)", 1, 1, 1, 1, 1, 1)
		end
		--GameTooltip:AddDoubleLine ("|TInterface\\AddOns\\Details\\images\\classes_small:14:14:0:0:128:128:"..coords[1]..":"..coords[2]..":"..coords[3]..":"..coords[4].."|t "..tabela[1]..": ", _detalhes:comma_value(tabela[2]).." (".._cstr("%.1f", (tabela[2]/total) * 100).."%)", 1, 1, 1, 1, 1, 1)
	end
	
end

--> custom tooltip for damage taken details ---------------------------------------------------------------------------------------------------------

local function DamageTakenDetails (jogador, barra)

	local agressores = jogador.damage_from
	local damage_taken = jogador.damage_taken
	
	local showing = _combat_object [class_type_damage] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable
	
	local meus_agressores = {}
	
	for nome, _ in _pairs (agressores) do --> agressores seria a lista de nomes
		local este_agressor = showing._ActorTable[showing._NameIndexTable[nome]]
		if (este_agressor) then --> checagem por causa do total e do garbage collector que não limpa os nomes que deram dano
		
			local habilidades = este_agressor.spell_tables._ActorTable
			for id, habilidade in _pairs (habilidades) do 
			--print ("oi - " .. este_agressor.nome)
				local alvos = habilidade.targets
				for index, alvo in _ipairs (alvos._ActorTable) do 
					--print ("hello -> "..alvo.nome)
					if (alvo.nome == jogador.nome) then
						meus_agressores [#meus_agressores+1] = {id, alvo.total, este_agressor.nome}
					end
				end
			end
		end
	end

	_table_sort (meus_agressores, function (a, b) return a[2] > b[2] end)
	
	_GameTooltip:ClearLines()
	_GameTooltip:AddLine (barra.texto_esquerdo:GetText())

	local max = #meus_agressores
	if (max > 20) then
		max = 20
	end

	local teve_melee = false
	
	for i = 1, max do
	
		local nome_magia, _, icone_magia = _GetSpellInfo (meus_agressores[i][1])
		
		if (meus_agressores[i][1] == 1) then 
			nome_magia = "*"..meus_agressores[i][3]
			teve_melee = true
		end
		
		GameTooltip:AddDoubleLine (nome_magia..": ", _detalhes:comma_value(meus_agressores[i][2]).." (".._cstr("%.1f", (meus_agressores[i][2]/damage_taken) * 100).."%)", 1, 1, 1, 1, 1, 1)
		GameTooltip:AddTexture (icone_magia)
	end
	
	if (teve_melee) then
		GameTooltip:AddLine ("* "..Loc ["STRING_MELEE_DAMAGE"], 0, 1, 0)
	end
end

--> custom tooltip clicks on any bar ---------------------------------------------------------------------------------------------------------
function _detalhes:BossInfoRowClick (barra, param1)
	
	if (type (self) == "table") then
		barra, param1 = self, barra
	end
	
	if (type (param1) == "table") then
		barra = param1
	end
	
	if (barra._no_report) then
		return
	end

	local reportar
	
	if (barra.TTT == "morte") then --> deaths
		reportar = {barra.report_text .. " " .. barra.texto_esquerdo:GetText()}
		for i = 1, GameCooltip:GetNumLines(), 1 do 
		
			local texto_left, texto_right = GameCooltip:GetText (i)

			if (texto_left and texto_right) then 
				texto_left = texto_left:gsub (("|T(.*)|t "), "")
				reportar [#reportar+1] = ""..texto_left.." "..texto_right..""
			end
		end
	else
		
		barra.report_text = barra.report_text or ""
		reportar = {barra.report_text .. " " .. _G.GameTooltipTextLeft1:GetText()}
		local numLines = _GameTooltip:NumLines()
		
		for i = 1, numLines, 1 do 
			local nome_left = "GameTooltipTextLeft"..i
			local texto_left = _G[nome_left]
			texto_left = texto_left:GetText()
			
			local nome_right = "GameTooltipTextRight"..i
			local texto_right = _G[nome_right]
			texto_right = texto_right:GetText()
			
			if (texto_left and texto_right) then 
				texto_left = texto_left:gsub (("|T(.*)|t "), "")
				reportar [#reportar+1] = ""..texto_left.." "..texto_right..""
			end
		end		
	end

	return _detalhes:Reportar (reportar, {_no_current = true, _no_inverse = true, _custom = true})
	
end

--> custom tooltip that handle mouse enter and leave on customized rows ---------------------------------------------------------------------------------------------------------

function EncounterDetails:SetRowScripts (barra, index, container)

	barra:SetScript ("OnMouseDown", function (self)
		if (self.fading_in) then
			return
		end
	
		self.mouse_down = _GetTime()
		local x, y = _GetCursorPosition()
		self.x = _math_floor (x)
		self.y = _math_floor (y)

		EncounterDetailsFrame:StartMoving()
		EncounterDetailsFrame.isMoving = true
		
	end)
	
	barra:SetScript ("OnMouseUp", function (self)

		if (self.fading_in) then
			return
		end
	
		if (EncounterDetailsFrame.isMoving) then
			EncounterDetailsFrame:StopMovingOrSizing()
			EncounterDetailsFrame.isMoving = false
			--instancia:SaveMainWindowPosition() --> precisa fazer algo pra salvar o trem
		end
	
		local x, y = _GetCursorPosition()
		x = _math_floor (x)
		y = _math_floor (y)
		if ((self.mouse_down+0.4 > _GetTime() and (x == self.x and y == self.y)) or (x == self.x and y == self.y)) then
			_detalhes:BossInfoRowClick (self)
		end
	end)
	
	barra:SetScript ("OnEnter", --> MOUSE OVER
		function (self) 
			--> aqui 1
			if (container.fading_in or container.faded) then
				return
			end
		
			self.mouse_over = true
			
			self:SetHeight (17)
			self:SetAlpha(1)
			
			self:SetBackdrop({edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 16, edgeSize = 10,insets = {left = 1, right = 1, top = 0, bottom = 1},})	
			self:SetBackdropBorderColor (170/255, 170/255, 170/255)
			self:SetBackdropColor (24/255, 24/255, 24/255)
			
			GameTooltip:SetOwner (self, "ANCHOR_TOPRIGHT")
			
			if (not self.TTT) then --> tool tip type
				return
			end
			
			if (self.TTT == "damage_taken") then --> damage taken
				DamageTakenDetails (self.jogador, barra)
				
			elseif (self.TTT == "habilidades_inimigas") then --> enemy abilytes
				EnemySkills (self.jogador, self)
				self:SetScript ("OnUpdate", shift_monitor)
				self.spellid = self.jogador [4]
				_GameTooltip:AddLine (" ")
				_GameTooltip:AddLine (Loc ["STRING_HOLDSHIFT"])
				
			elseif (self.TTT == "total_interrupt") then
				KickBy (self.jogador, self)
				self:SetScript ("OnUpdate", shift_monitor)
				self.spellid = self.jogador [3]
				_GameTooltip:AddLine (" ")
				_GameTooltip:AddLine (Loc ["STRING_HOLDSHIFT"])
				
			elseif (self.TTT == "dispell") then
				DispellInfo (self.jogador, self)
				self:SetScript ("OnUpdate", shift_monitor)
				self.spellid = self.jogador [3]
				_GameTooltip:AddLine (" ")
				_GameTooltip:AddLine (Loc ["STRING_HOLDSHIFT"])
				
			elseif (self.TTT == "morte") then --> deaths
				KillInfo (self.jogador, self) --> aqui 2
			end

			GameTooltip:Show()
		end)
	
	barra:SetScript ("OnLeave", --> MOUSE OUT
		function (self) 
		
			self:SetScript ("OnUpdate", nil)
		
			if (self.fading_in or self.faded or not self:IsShown() or self.hidden) then
				return
			end
			
			self:SetHeight (16)
			self:SetAlpha(0.9)
			
			self:SetBackdrop({bgFile = "", edgeFile = "", tile = true, tileSize = 16, edgeSize = 32, insets = {left = 1, right = 1, top = 0, bottom = 1},})	
			self:SetBackdropBorderColor (0, 0, 0, 0)
			self:SetBackdropColor (0, 0, 0, 0)
			
			GameTooltip:Hide()
			_detalhes.popup:ShowMe (false, "tooltip")
		
		end)
end

--> Here start the data mine ---------------------------------------------------------------------------------------------------------
function EncounterDetails:OpenAndRefresh (_, segment)
	
	local frame = EncounterDetailsFrame --alias
	local _combat_object = _combat_object
	
	if (segment) then
		_combat_object = _detalhes.tabela_historico.tabelas [segment]
	else
		_G [frame:GetName().."SegmentsDropdown"].MyObject:Select (1, true)
	end
	
	--[
	if (frame.ShowType == "main") then
		--frame.buttonSwitchNormal:Disable()

		--if (_combat_object.DpsGraphic[1]) then
			--frame.buttonSwitchGraphic:Enable()
		--else
		--	frame.buttonSwitchGraphic:Disable()
		--end
	elseif (frame.ShowType == "graph") then
		--frame.buttonSwitchNormal:Enable()
		--frame.buttonSwitchGraphic:Disable()
	end
	--]]

	local boss_id
	local map_id
	local boss_info
	
	if (debugmode and not _combat_object.is_boss) then
		_combat_object.is_boss = {
			index = 1, 
			name = _detalhes:GetBossName (1098, 1),
			zone = "Throne of Thunder", 
			mapid = 1098, 
			encounter = "Jin'Rohk the Breaker"
		}
	end
	
	boss_id = _combat_object.is_boss.index
	map_id = _combat_object.is_boss.mapid
	boss_info = _detalhes:GetBossDetails (_combat_object.is_boss.mapid, _combat_object.is_boss.index)

	if (not boss_info) then
		return EncounterDetails:Msg (Loc ["STRING_BOSS_NOT_REGISTRED"])
	end
	
-------------- set boss name and zone name --------------
	EncounterDetailsFrame.boss_name:SetText (_combat_object.is_boss.encounter)
	EncounterDetailsFrame.raid_name:SetText (_combat_object.is_boss.zone)

-------------- set portrait and background image --------------	
	local L, R, T, B, Texture = EncounterDetails:GetBossIcon (_combat_object.is_boss.mapid, _combat_object.is_boss.index)
	EncounterDetailsFrame.boss_icone:SetTexture (Texture)
	EncounterDetailsFrame.boss_icone:SetTexCoord (L, R, T, B)
	EncounterDetailsFrame.raidbackground:SetTexture (EncounterDetails:GetRaidBackground (_combat_object.is_boss.mapid))
	
-------------- set totals on down frame --------------
--[[ data mine:
	_combat_object ["totals_grupo"] hold the total [1] damage // [2] heal // [3] [energy_name] energies // [4] [misc_name] miscs --]]

	EncounterDetailsFrame.StatusBar_totaldamage:SetText (Loc ["STRING_TOTAL_DAMAGE"]..": ".. _detalhes:comma_value (_combat_object.totals_grupo[1])) --> [1] total damage
	EncounterDetailsFrame.StatusBar_totalheal:SetText (Loc ["STRING_TOTAL_HEAL"]..": ".. _detalhes:comma_value (_combat_object.totals_grupo[2])) --> [2] total heal

	--> Container Overall Damage Taken
		--[[ data mine:
			combat tables have 4 containers [1] damage [2] heal [3] energy [4] misc each container have 2 tables: ._NameIndexTable and ._ActorTable --]]
		local DamageContainer = _combat_object [class_type_damage]
		
		local damage_taken = _detalhes.atributo_damage:RefreshWindow ({}, _combat_object, _, { key = "damage_taken", modo = _detalhes.modos.group })
		
		local container = frame.overall_damagetaken.gump
		
		local quantidade = 0
		local dano_do_primeiro = 0
		
		for index, jogador in _ipairs (DamageContainer._ActorTable) do
			--> ta em ordem de quem tomou mais dano.
			
			if (not jogador.grupo) then --> só aparecer nego da raid
				break
			end
			
			if (jogador.classe and jogador.classe ~= "UNGROUPPLAYER" and jogador.classe ~= "UNKNOW") then
				local barra = container.barras [index]
				if (not barra) then
					barra = EncounterDetails:CreateRow (index, container)
					_detalhes:SetFontSize (barra.texto_esquerdo, 9)
					_detalhes:SetFontSize (barra.texto_direita, 9)
					_detalhes:SetFontFace (barra.texto_esquerdo, "Arial Narrow")
					barra.TTT = "damage_taken" -- tool tip type --> damage taken
					barra.report_text = Loc ["STRING_PLUGIN_NAME"].."! "..Loc ["STRING_DAMAGE_TAKEN_REPORT"] 
				end

				if (jogador.nome:find ("-")) then
					barra.texto_esquerdo:SetText (jogador.nome:gsub (("-.*"), ""))
				else
					barra.texto_esquerdo:SetText (jogador.nome)
				end
				
				barra.texto_direita:SetText (_detalhes:comma_value (jogador.damage_taken))
				
				_detalhes:name_space (barra)
				
				barra.jogador = jogador
				
				barra.textura:SetStatusBarColor (_unpack (_detalhes.class_colors [jogador.classe]))
				
				if (index == 1)  then
					barra.textura:SetValue (100)
					dano_do_primeiro = jogador.damage_taken
				else
					barra.textura:SetValue (jogador.damage_taken/dano_do_primeiro *100)
				end
				
				barra.icone:SetTexture ("Interface\\AddOns\\Details\\images\\classes_small")
				if (CLASS_ICON_TCOORDS [jogador.classe]) then
					barra.icone:SetTexCoord (_unpack (CLASS_ICON_TCOORDS [jogador.classe]))
				end
				
				barra:Show()
				quantidade = quantidade + 1
			end
		end
		
		EncounterDetails:JB_AtualizaContainer (container, quantidade)
		
		if (quantidade < #container.barras) then
			for i = quantidade+1, #container.barras, 1 do 
			
				if (barra) then
					barra:Hide()
				end
			end
		end
		
	--> Fim do container Overall Damage Taken
	
	--> Container Overall Habilidades Inimigas
		local habilidades_poll = {}
		
		--> pega as magias contínuas presentes em todas as fases
		if (boss_info.continuo) then
			for index, spellid in _ipairs (boss_info.continuo) do 
				habilidades_poll [spellid] = true
			end
		end

		--> pega as habilidades que pertence especificamente a cada fase
		local fases = boss_info.phases
		for fase_id, fase in _ipairs (fases) do 
			if (fase.spells) then
				for index, spellid in _ipairs (fase.spells) do 
					habilidades_poll [spellid] = true
				end
			end
		end
		
		local habilidades_usadas = {}
		
		for index, jogador in _ipairs (DamageContainer._ActorTable) do
			local habilidades = jogador.spell_tables._ActorTable
			for id, habilidade in _pairs (habilidades) do
				if (habilidades_poll [id]) then
					--> esse jogador usou uma habilidade do boss
					local esta_habilidade = habilidades_usadas [id] --> tabela não numerica, pq diferentes monstros podem castar a mesma magia
					if (not esta_habilidade) then 
						esta_habilidade = {0, {}, {}, id} --> [1] total dano causado [2] jogadores que foram alvos [3] jogadores que castaram essa magia [4] ID da magia
						habilidades_usadas [id] = esta_habilidade
					end
					
					--> adiciona ao [1] total de dano que esta habilidade causou
					esta_habilidade[1] = esta_habilidade[1] + habilidade.total
					
					 --> adiciona ao [3] total do jogador que castou
					if (not esta_habilidade[3][jogador.nome]) then
						esta_habilidade[3][jogador.nome] = 0
					end
					
					esta_habilidade[3][jogador.nome] = esta_habilidade[3][jogador.nome] + habilidade.total
					
					--> pega os alvos e adiciona ao [2]
					local alvos = habilidade.targets
					for index, jogador in _ipairs (alvos._ActorTable) do 
					
						--> ele tem o nome do jogador, vamos ver se este alvo é realmente um jogador verificando na tabela do combate
						local tabela_dano_do_jogador = DamageContainer._ActorTable [DamageContainer._NameIndexTable [jogador.nome]]
						if (tabela_dano_do_jogador and tabela_dano_do_jogador.grupo) then
							if (not esta_habilidade[2] [jogador.nome]) then 
								esta_habilidade[2] [jogador.nome] = {0, tabela_dano_do_jogador.classe}
							end
							esta_habilidade[2] [jogador.nome] [1] = esta_habilidade[2] [jogador.nome] [1] + jogador.total
						end
					end
				end
			end
		end
		
		--> por em ordem
		local tabela_em_ordem = {}
		for id, tabela in _pairs (habilidades_usadas) do 
			tabela_em_ordem [#tabela_em_ordem+1] = tabela
		end
		
		_table_sort (tabela_em_ordem, function (a, b) return a[1] > b[1] end)

		container = frame.overall_habilidades.gump
		quantidade = 0
		dano_do_primeiro = 0
		
		--> mostra o resultado nas barras
		for index, habilidade in _ipairs (tabela_em_ordem) do
			--> ta em ordem das habilidades que deram mais dano
			
			if (habilidade[1] > 0) then
			
				local barra = container.barras [index]
				if (not barra) then
					barra = EncounterDetails:CreateRow (index, container)
					barra.TTT = "habilidades_inimigas" -- tool tip type --enemy abilities
					barra.report_text = Loc ["STRING_PLUGIN_NAME"].."! " .. Loc ["STRING_ABILITY_DAMAGE"]
					_detalhes:SetFontSize (barra.texto_esquerdo, 9)
					_detalhes:SetFontSize (barra.texto_direita, 9)
					_detalhes:SetFontFace (barra.texto_esquerdo, "Arial Narrow")
					barra.t:SetVertexColor (1, .8, .8, .8)
				end
				
				local nome_magia, _, icone_magia = _GetSpellInfo (habilidade[4])

				barra.texto_esquerdo:SetText (nome_magia)
				barra.texto_direita:SetText (_detalhes:comma_value (habilidade[1]))
				
				_detalhes:name_space (barra)
				
				barra.jogador = habilidade --> barra.jogador agora tem a tabela com --> [1] total dano causado [2] jogadores que foram alvos [3] jogadores que castaram essa magia [4] ID da magia
				
				--barra.textura:SetStatusBarColor (_unpack (_detalhes.class_colors [jogador.classe]))
				--barra.textura:SetStatusBarColor (1, 1, 1, 1) --> a cor pode ser a spell school da magia
				
				if (index == 1)  then
					barra.textura:SetValue (100)
					dano_do_primeiro = habilidade[1]
				else
					barra.textura:SetValue (habilidade[1]/dano_do_primeiro *100)
				end
				
				barra.icone:SetTexture (icone_magia)
				--barra.icone:SetTexCoord (_unpack (CLASS_ICON_TCOORDS [jogador.classe]))
				
				barra:Show()
				quantidade = quantidade + 1
			
			end
		end
		
		--print (quantidade)
		EncounterDetails:JB_AtualizaContainer (container, quantidade)
		
		if (quantidade < #container.barras) then
			for i = quantidade+1, #container.barras, 1 do 
				container.barras [i]:Hide()
			end
		end
	
	--> Fim do container Over Habilidades Inimigas
	
	--> Identificar os ADDs da luta:
	
		--> declara a pool onde serão armazenados os adds existentas na luta
		local adds_pool = {}
	
		--> pega as habilidades que pertence especificamente a cada fase
		for fase_id, fase in _ipairs (boss_info.phases) do 
			if (fase.adds) then
				for index, addId in _ipairs (fase.adds) do 
					adds_pool [addId] = true
				end
			end
		end
		
		--> agora ja tenho a lista de todos os adds da luta
		-- vasculhar o container de dano e achar os adds:
		
		local adds = {}
		
		for index, jogador in _ipairs (DamageContainer._ActorTable) do
		
			--> só estou interessado nos adds, conferir pelo nome
			if (adds_pool [tonumber (jogador.serial:sub(6, 10), 16)] or (jogador.flag_original and bit.band (jogador.flag_original, 0x00000040) ~= 0)) then --> é um inimigo) then
				
				local nome = jogador.nome
				local tabela = {total = 0, dano_em = {}, dano_em_total = 0, damage_from = {}, damage_from_total = 0}
			
				--> total de dano que ele causou
				tabela.total = jogador.total
				
				--> em quem ele deu dano
				for _, alvo in _ipairs (jogador.targets._ActorTable) do 
					--local este_jogador = DamageContainer._ActorTable [DamageContainer._NameIndexTable [alvo.nome]]
					local este_jogador = _combat_object (1, alvo.nome)
					if (este_jogador) then
						if (este_jogador.classe ~= "PET" and este_jogador.classe ~= "UNGROUPPLAYER" and este_jogador.classe ~= "UNKNOW") then
							tabela.dano_em [#tabela.dano_em +1] = {alvo.nome, alvo.total, este_jogador.classe}
							tabela.dano_em_total = tabela.dano_em_total + alvo.total
						end
					else
						--print ("actor not found: " ..alvo.nome )
					end
				end
				_table_sort (tabela.dano_em, function(a, b) return a[2] > b[2] end)
				
				--> quem deu dano nele
				for agressor, _ in _pairs (jogador.damage_from) do 
					--local este_jogador = DamageContainer._ActorTable [DamageContainer._NameIndexTable [agressor]]
					local este_jogador = _combat_object (1, agressor)
					if (este_jogador and este_jogador:IsPlayer()) then 
						for _, alvo in _ipairs (este_jogador.targets._ActorTable) do 
							if (alvo.nome == nome) then 
								tabela.damage_from [#tabela.damage_from+1] = {agressor, alvo.total, este_jogador.classe}
								tabela.damage_from_total = tabela.damage_from_total + alvo.total
							end
						end
					end
				end
				_table_sort (tabela.damage_from, 
								function (a, b) 
									if (a[3] ~= "PET" and b[3] ~= "PET") then 
										return a[2] > b[2] 
									elseif (a[3] == "PET" and b[3] ~= "PET") then
										return false
									elseif (a[3] ~= "PET" and b[3] == "PET") then
										return true
									else
										return a[2] > b[2] 
									end
								end)
				
				adds [nome] = tabela
				
			end
			
		end
		
		--> montou a tabela, agora precisa mostrar no painel

		local function _DanoFeito (barra)
			barra = barra:GetParent()
			local tabela = barra.jogador
			local dano_em = tabela.dano_em
			
			GameTooltip:SetOwner (barra, "ANCHOR_TOPRIGHT")
			
			_GameTooltip:ClearLines()
			_GameTooltip:AddLine (barra.texto_esquerdo:GetText().." ".. Loc ["STRING_INFLICTED"]) 
			
			local dano_em_total = tabela.dano_em_total
			for _, esta_tabela in _pairs (dano_em) do 
				local coords = CLASS_ICON_TCOORDS [esta_tabela[3]]
				GameTooltip:AddDoubleLine ("|TInterface\\AddOns\\Details\\images\\classes_small:14:14:0:0:128:128:"..(coords[1]*128)..":"..(coords[2]*128)..":"..(coords[3]*128)..":"..(coords[4]*128).."|t "..esta_tabela[1]..": ", _detalhes:comma_value(esta_tabela[2]).." (".. _cstr ("%.1f", esta_tabela[2]/dano_em_total*100) .."%)", 1, 1, 1, 1, 1, 1)
			end
			
			GameTooltip:Show()	
		end

		local function _DanoRecebido (barra)
			barra = barra:GetParent()
			local tabela = barra.jogador
			local damage_from = tabela.damage_from
			
			GameTooltip:SetOwner (barra, "ANCHOR_TOPRIGHT")
			
			GameTooltip:ClearLines()
			GameTooltip:AddLine (barra.texto_esquerdo:GetText().." "..Loc ["STRING_DAMAGE_TAKEN"])
			
			local damage_from_total = tabela.damage_from_total

			for _, esta_tabela in _pairs (damage_from) do 

				local coords = CLASS_ICON_TCOORDS [esta_tabela[3]]
				if (coords) then
					GameTooltip:AddDoubleLine ("|TInterface\\AddOns\\Details\\images\\classes_small:14:14:0:0:128:128:"..(coords[1]*128)..":"..(coords[2]*128)..":"..(coords[3]*128)..":"..(coords[4]*128).."|t "..esta_tabela[1]..": ", _detalhes:comma_value(esta_tabela[2]).." (".. _cstr ("%.1f", esta_tabela[2]/damage_from_total*100) .."%)", 1, 1, 1, 1, 1, 1)
				else
					GameTooltip:AddDoubleLine (esta_tabela[1],  _detalhes:comma_value(esta_tabela[2]).." (".. _cstr ("%.1f", esta_tabela[2]/damage_from_total*100) .."%)", 1, 1, 1, 1, 1, 1)
				end
			end
			
			GameTooltip:Show()	
		end
		
		local y = 10
		local frame_adds = EncounterDetailsFrame.overall_adds
		container = frame_adds.gump
		local index = 1
		quantidade = 0
		
		for addName, esta_tabela in _pairs (adds) do 
		
				local barra = container.barras [index]
				if (not barra) then
					barra = EncounterDetails:CreateRow (index, container)
					barra:SetWidth (160)
					
					barra._no_report = true

					--> criar 2 botão: um para o dano que add deu e outro para o dano que o add tomou
					local add_damage_taken = _CreateFrame ("Button", nil, barra)
					add_damage_taken.report_text = "Details! "
					add_damage_taken.barra = barra
					add_damage_taken:SetWidth (16)
					add_damage_taken:SetHeight (16)
					add_damage_taken:EnableMouse (true)
					add_damage_taken:SetResizable (false)
					add_damage_taken:SetPoint ("left", barra, "left", 0, 0)
					
					add_damage_taken:SetBackdrop (gump_fundo_backdrop)
					add_damage_taken:SetBackdropColor (.3, .7, .7, 0.8)
					
					add_damage_taken:SetScript ("OnEnter", _DanoRecebido)
					add_damage_taken:SetScript ("OnLeave", function() GameTooltip:Hide() end)
					add_damage_taken:SetScript ("OnClick", EncounterDetails.BossInfoRowClick)
					
					add_damage_taken.textura = add_damage_taken:CreateTexture (nil, "overlay")
					add_damage_taken.textura:SetTexture ("Interface\\Buttons\\UI-MicroStream-Green")
					add_damage_taken.textura:SetWidth (16)
					add_damage_taken.textura:SetHeight (16)
					add_damage_taken.textura:SetTexCoord (0, 1, 1, 0)
					add_damage_taken.textura:SetPoint ("center", add_damage_taken, "center")
					
					local add_damage_done = _CreateFrame ("Button", nil, barra)
					add_damage_done.report_text = "Details! "
					add_damage_done.barra = barra
					add_damage_done:SetWidth (16)
					add_damage_done:SetHeight (16)
					add_damage_done:EnableMouse (true)
					add_damage_done:SetResizable (false)
					add_damage_done:SetPoint ("left", add_damage_taken, "right", 0, 0)
					
					add_damage_done:SetBackdrop (gump_fundo_backdrop)
					add_damage_done:SetBackdropColor (.9, .9, .3, 0.8)
					
					add_damage_done.textura = add_damage_done:CreateTexture (nil, "overlay")
					add_damage_done.textura:SetTexture ("Interface\\Buttons\\UI-MicroStream-Red")
					add_damage_done.textura:SetWidth (16)
					add_damage_done.textura:SetHeight (16)
					add_damage_done.textura:SetPoint ("topleft", add_damage_done, "topleft")
					
					add_damage_done:SetScript ("OnEnter", _DanoFeito)
					add_damage_done:SetScript ("OnLeave", function() GameTooltip:Hide() end)
					add_damage_done:SetScript ("OnClick", EncounterDetails.BossInfoRowClick)
					
					barra.texto_esquerdo:SetPoint ("left", add_damage_done, "right")
					barra.textura:SetStatusBarTexture (nil)
					_detalhes:SetFontSize (barra.texto_esquerdo, 9)
					_detalhes:SetFontSize (barra.texto_direita, 9)
					
					--barra.TTT = "habilidades_inimigas" -- tool tip type
				end

				barra.texto_esquerdo:SetText (addName)
				
				--barra.texto_direita:SetText (_detalhes:comma_value (esta_tabela.total))
				barra.texto_direita:SetText (_detalhes:ToK (esta_tabela.total))
				
				barra.texto_esquerdo:SetSize (barra:GetWidth() - barra.texto_direita:GetStringWidth() - 34, 15)
				
				barra.jogador = esta_tabela --> barra.jogador agora tem a tabela com --> [1] total dano causado [2] jogadores que foram alvos [3] jogadores que castaram essa magia [4] ID da magia
				
				--barra.textura:SetStatusBarColor (_unpack (_detalhes.class_colors [jogador.classe]))
				barra.textura:SetStatusBarColor (1, 1, 1, 1) --> a cor pode ser a spell school da magia
				barra.textura:SetValue (100)
				
				--barra.icone:SetTexture (icone_magia)
				--barra.icone:SetTexCoord (_unpack (CLASS_ICON_TCOORDS [jogador.classe]))
				
				barra:Show()
				quantidade = quantidade + 1
				index = index +1
		end
		
		EncounterDetails:JB_AtualizaContainer (container, quantidade, 4)
		
		if (quantidade < #container.barras) then
			for i = quantidade+1, #container.barras, 1 do 
				container.barras [i]:Hide()
			end
		end
		
	--> Fim do container Over ADDS
	
	--> Inicio do Container de Interrupts:
	
		local misc = _combat_object [class_type_misc]
		
		local total_interrompido = _detalhes.atributo_misc:RefreshWindow ({}, _combat_object, _, { key = "interrupt", modo = _detalhes.modos.group })
		
		local frame_interrupts = EncounterDetailsFrame.overall_interrupt
		container = frame_interrupts.gump
		
		quantidade = 0
		local interrupt_do_primeiro = 0
		
		local habilidades_interrompidas = {}
		
		for index, jogador in _ipairs (misc._ActorTable) do
			if (not jogador.grupo) then --> só aparecer nego da raid
				break
			end
			
			if (jogador.classe and jogador.classe ~= "UNGROUPPLAYER") then			
				local interrupts = jogador.interrupt				
				if (interrupts and interrupts > 0) then
					local oque_interrompi = jogador.interrompeu_oque
					--> vai ter [spellid] = quantidade
					
					for spellid, amt in _pairs (oque_interrompi) do 
						if (not habilidades_interrompidas [spellid]) then --> se a spell não tiver na pool, cria a tabela dela
							habilidades_interrompidas [spellid] = {{}, 0, spellid} --> tabela com quem interrompeu e o total de vezes que a habilidade foi interrompida
						end
						
						if (not habilidades_interrompidas [spellid] [1] [jogador.nome]) then --> se o jogador não tiver na pool dessa habilidade interrompida, cria um indice pra ele.
							habilidades_interrompidas [spellid] [1] [jogador.nome] = {0, jogador.classe}
						end
						
						habilidades_interrompidas [spellid] [2] = habilidades_interrompidas [spellid] [2] + amt
						habilidades_interrompidas [spellid] [1] [jogador.nome] [1] = habilidades_interrompidas [spellid] [1] [jogador.nome] [1] + amt
					end
				end
			end
		end
		
		--> por em ordem
		tabela_em_ordem = {}
		for spellid, tabela in _pairs (habilidades_interrompidas) do 
			tabela_em_ordem [#tabela_em_ordem+1] = tabela
		end
		_table_sort (tabela_em_ordem, function (a, b) return a[2] > b[2] end)

		index = 1
		
		for _, tabela in _ipairs (tabela_em_ordem) do
		
			local barra = container.barras [index]
			if (not barra) then
				barra = EncounterDetails:CreateRow (index, container, 3, 3, -6)
				barra.TTT = "total_interrupt" -- tool tip type
				barra.report_text = "Details! ".. Loc ["STRING_INTERRUPT_BY"]
			end
			
			local spellid = tabela [3]
			
			local nome_magia, _, icone_magia = _GetSpellInfo (tabela [3])
			local successful = 0
			--> pegar quantas vezes a magia passou com sucesso.
			for _, enemy_actor in _ipairs (DamageContainer._ActorTable) do
				if (enemy_actor.spell_tables._ActorTable [spellid]) then
					local spell = enemy_actor.spell_tables._ActorTable [spellid]
					successful = spell.successful_casted
				end
			end
			
			barra.texto_esquerdo:SetText (nome_magia)
			local total = successful + tabela [2]
			barra.texto_direita:SetText (tabela [2] .. " / ".. total)
			
			_detalhes:name_space (barra)
			
			barra.jogador = tabela
			
			--barra.textura:SetStatusBarColor (_unpack (_detalhes.class_colors [jogador.classe]))
			
			if (index == 1)  then
				barra.textura:SetValue (100)
				dano_do_primeiro = tabela [2]
			else
				barra.textura:SetValue (tabela [2]/dano_do_primeiro *100)
			end
			
			barra.icone:SetTexture (icone_magia)
			--barra.icone:SetTexCoord (_unpack (CLASS_ICON_TCOORDS [jogador.classe]))
			
			barra:Show()
			
			quantidade = quantidade + 1
			index = index + 1 
		end

		EncounterDetails:JB_AtualizaContainer (container, quantidade, 4)
		
		if (quantidade < #container.barras) then
			for i = quantidade+1, #container.barras, 1 do 
				container.barras[i]:Hide()
			end
		end
	
	--> Fim do container dos Interrupts
	
	--> Inicio do Container dos Dispells:
		
		--> force refresh window behavior
		local total_dispelado = _detalhes.atributo_misc:RefreshWindow ({}, _combat_object, _, { key = "dispell", modo = _detalhes.modos.group })
		
		local frame_dispell = EncounterDetailsFrame.overall_dispell
		container = frame_dispell.gump
		
		quantidade = 0
		local dispell_do_primeiro = 0
		
		local habilidades_dispeladas = {}
		
		for index, jogador in _ipairs (misc._ActorTable) do
			if (not jogador.grupo) then --> só aparecer nego da raid
				break
			end

			if (jogador.classe and jogador.classe ~= "UNGROUPPLAYER") then

				local dispells = jogador.dispell
				if (dispells and dispells > 0) then
					local oque_dispelei = jogador.dispell_oque
					--> vai ter [spellid] = quantidade
					
					--print ("dispell: " .. jogador.classe .. " nome: " .. jogador.nome)
					
					for spellid, amt in _pairs (oque_dispelei) do 
						if (not habilidades_dispeladas [spellid]) then --> se a spell não tiver na pool, cria a tabela dela
							habilidades_dispeladas [spellid] = {{}, 0, spellid} --> tabela com quem dispolou e o total de vezes que a habilidade foi dispelada
						end
						
						if (not habilidades_dispeladas [spellid] [1] [jogador.nome]) then --> se o jogador não tiver na pool dessa habilidade interrompida, cria um indice pra ele.
							habilidades_dispeladas [spellid] [1] [jogador.nome] = {0, jogador.classe}
							--print (jogador.nome)
							--print (jogador.classe)
						end
						
						habilidades_dispeladas [spellid] [2] = habilidades_dispeladas [spellid] [2] + amt
						habilidades_dispeladas [spellid] [1] [jogador.nome] [1] = habilidades_dispeladas [spellid] [1] [jogador.nome] [1] + amt
					end
				end
			end
		end
		
		--> por em ordem
		tabela_em_ordem = {}
		for spellid, tabela in _pairs (habilidades_dispeladas) do 
			tabela_em_ordem [#tabela_em_ordem+1] = tabela
		end
		_table_sort (tabela_em_ordem, function (a, b) return a[2] > b[2] end)

		index = 1
		
		for _, tabela in _ipairs (tabela_em_ordem) do
		
			local barra = container.barras [index]
			if (not barra) then
				barra = EncounterDetails:CreateRow (index, container, 3, 3, -6)
				barra.TTT = "dispell" -- tool tip type
				barra.report_text = "Details! ".. Loc ["STRING_DISPELLED_BY"]
			end
			
			local nome_magia, _, icone_magia = _GetSpellInfo (tabela [3])
			
			barra.texto_esquerdo:SetText (nome_magia)
			barra.texto_direita:SetText (tabela [2])
			
			_detalhes:name_space (barra)
			
			barra.jogador = tabela
			
			--barra.textura:SetStatusBarColor (_unpack (_detalhes.class_colors [jogador.classe]))
			
			if (index == 1)  then
				barra.textura:SetValue (100)
				dano_do_primeiro = tabela [2]
			else
				barra.textura:SetValue (tabela [2]/dano_do_primeiro *100)
			end
			
			barra.icone:SetTexture (icone_magia)
			--barra.icone:SetTexCoord (_unpack (CLASS_ICON_TCOORDS [jogador.classe]))
			
			barra:Show()
			
			quantidade = quantidade + 1
			index = index + 1 
		end
		
		EncounterDetails:JB_AtualizaContainer (container, quantidade, 4)
		
		if (quantidade < #container.barras) then
			for i = quantidade+1, #container.barras, 1 do 
				container.barras [i]:Hide()
			end
		end
	
	--> Fim do container dos Dispells
	
	--> Inicio do Container das Mortes:
		local frame_mortes = EncounterDetailsFrame.overall_dead
		container = frame_mortes.gump
		
		quantidade = 0
	
		-- boss_info.spell_tables_info o erro de lua do boss é a habilidade dele que não foi declarada ainda
	
		local mortes = _combat_object.last_events_tables
		local habilidades_info = boss_info.spell_mechanics --barra.extra pega esse cara aqui --> então esse erro é das habilidades que não tao
	
		for index, tabela in _ipairs (mortes) do
			--> {esta_morte, time, este_jogador.nome, este_jogador.classe, _UnitHealthMax (alvo_name), minutos.."m "..segundos.."s",  ["dead"] = true}
			local barra = container.barras [index]
			if (not barra) then
				barra = EncounterDetails:CreateRow (index, container, 3, 0, -4)
				barra.TTT = "morte" -- tool tip type
				barra.report_text = "Details! " .. Loc ["STRING_DEAD_LOG"]
				_detalhes:SetFontSize (barra.texto_esquerdo, 9)
				_detalhes:SetFontSize (barra.texto_direita, 9)
				_detalhes:SetFontFace (barra.texto_esquerdo, "Arial Narrow")
			end
			
			if (tabela [3]:find ("-")) then
				barra.texto_esquerdo:SetText (index..". "..tabela [3]:gsub (("-.*"), ""))
			else
				barra.texto_esquerdo:SetText (index..". "..tabela [3])
			end

			barra.texto_direita:SetText (tabela [6])
			
			_detalhes:name_space (barra)
			
			barra.jogador = tabela
			barra.extra = habilidades_info
			
			barra.textura:SetStatusBarColor (_unpack (_detalhes.class_colors [tabela [4]]))
			barra.textura:SetValue (100)
			
			barra.icone:SetTexture ("Interface\\AddOns\\Details\\images\\classes_small")
			barra.icone:SetTexCoord (_unpack (CLASS_ICON_TCOORDS [tabela [4]]))
			
			barra:Show()
			
			quantidade = quantidade + 1
		
		end
		
		EncounterDetails:JB_AtualizaContainer (container, quantidade, 4)
		
		if (quantidade < #container.barras) then
			for i = quantidade+1, #container.barras, 1 do 
				container.barras [i]:Hide()
			end
		end
end

function EncounterDetails:OnEvent (_, event, ...)

	if (event == "ADDON_LOADED") then
		local AddonName = select (1, ...)
		if (AddonName == "Details_EncounterDetails") then
			
			if (_G._detalhes) then
				
				--> create widgets
				CreatePluginFrames (data)

				local MINIMAL_DETAILS_VERSION_REQUIRED = 1
				
				--> Install
				local install, saveddata = _G._detalhes:InstallPlugin ("TOOLBAR", Loc ["STRING_PLUGIN_NAME"], "Interface\\Scenarios\\ScenarioIcon-Boss", EncounterDetails, "DETAILS_PLUGIN_ENCOUNTER_DETAILS", MINIMAL_DETAILS_VERSION_REQUIRED, "Details! Team", "v1.05")
				if (type (install) == "table" and install.error) then
					print (install.error)
				end
				
				--> Register needed events
				_G._detalhes:RegisterEvent (EncounterDetails, "COMBAT_PLAYER_ENTER")
				_G._detalhes:RegisterEvent (EncounterDetails, "COMBAT_PLAYER_LEAVE")
				_G._detalhes:RegisterEvent (EncounterDetails, "COMBAT_BOSS_FOUND")
				_G._detalhes:RegisterEvent (EncounterDetails, "DETAILS_DATA_RESET")
				
			end
		end
		
	elseif (event == "PLAYER_LOGOUT") then
		_detalhes_databaseEncounterDetails = EncounterDetails.data
	end
end
