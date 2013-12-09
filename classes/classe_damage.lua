--why do a cleanup on classes today if i can do tomorrow?

--lua locals
local _cstr = string.format
local _math_floor = math.floor
local _table_sort = table.sort
local _table_insert = table.insert
local _table_size = table.getn
local _setmetatable = setmetatable
local _getmetatable = getmetatable
local _ipairs = ipairs
local _pairs = pairs
local _rawget= rawget
local _math_min = math.min
local _math_max = math.max
local _bit_band = bit.band
local _unpack = unpack
local _type = type
--api locals
local _GetSpellInfo = _detalhes.getspellinfo
local GameTooltip = GameTooltip

local _detalhes = 		_G._detalhes
local AceLocale = LibStub ("AceLocale-3.0")
local Loc = AceLocale:GetLocale ( "Details" )

local gump = 			_detalhes.gump
local _

local alvo_da_habilidade = 	_detalhes.alvo_da_habilidade
local container_habilidades = 	_detalhes.container_habilidades
local container_combatentes = _detalhes.container_combatentes
local container_pets =		_detalhes.container_pets
local atributo_damage =	_detalhes.atributo_damage
local atributo_misc =		_detalhes.atributo_misc
local habilidade_dano = 	_detalhes.habilidade_dano
local container_damage_target = _detalhes.container_type.CONTAINER_DAMAGETARGET_CLASS

local container_playernpc = _detalhes.container_type.CONTAINER_PLAYERNPC
local container_damage = _detalhes.container_type.CONTAINER_DAMAGE_CLASS
local container_friendlyfire = _detalhes.container_type.CONTAINER_FRIENDLYFIRE

local modo_ALONE = _detalhes.modos.alone
local modo_GROUP = _detalhes.modos.group
local modo_ALL = _detalhes.modos.all

local class_type = _detalhes.atributos.dano

local DATA_TYPE_START = _detalhes._detalhes_props.DATA_TYPE_START
local DATA_TYPE_END = _detalhes._detalhes_props.DATA_TYPE_END

local DFLAG_player = _detalhes.flags.player
local DFLAG_group = _detalhes.flags.in_group
local DFLAG_player_group = _detalhes.flags.player_in_group

local div_abre = _detalhes.divisores.abre
local div_fecha = _detalhes.divisores.fecha
local div_lugar = _detalhes.divisores.colocacao

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS

local info = _detalhes.janela_info
local keyName

function atributo_damage:NovaTabela (serial, nome, link)

	--> constructor
	local _new_damageActor = {
		
		--> dps do objeto inicia sempre desligado
		tipo = class_type, --> atributo 1 = dano
		
		total = 0,
		total_without_pet = 0,
		custom = 0,
		
		damage_taken = 0, --> total de dano que este jogador levou
		damage_from = {}, --> armazena os nomes que deram dano neste jogador
		
		dps_started = false,
		last_event = 0,
		on_hold = false,
		delay = 0,
		last_value = nil, --> ultimo valor que este jogador teve, salvo quando a barra dele é atualizada
		last_dps = 0,

		end_time = nil,
		start_time = 0,
		
		pets = {}, --> armazena os nomes dos pets já com a tag do dono: pet name <owner nome>
		
		friendlyfire_total = 0,
		friendlyfire = container_combatentes:NovoContainer (container_friendlyfire),

		--container armazenará os seriais dos alvos que o player aplicou dano
		targets = container_combatentes:NovoContainer (container_damage_target),

		--container armazenará os IDs das habilidades usadas por este jogador
		spell_tables = container_habilidades:NovoContainer (container_damage)
	}
	
	_setmetatable (_new_damageActor, atributo_damage)
	
	if (link) then --> se não for a shadow
		_new_damageActor.last_events_table = _detalhes:CreateActorLastEventTable()
		_new_damageActor.last_events_table.original = true
		
		_new_damageActor.targets.shadow = link.targets
		_new_damageActor.spell_tables.shadow = link.spell_tables
		_new_damageActor.friendlyfire.shadow = link.friendlyfire
	end
	
	return _new_damageActor
end

--[[exported]]	function _detalhes:CreateActorLastEventTable()
				local t = { {}, {}, {}, {}, {}, {}, {}, {} }
				t.n = 1
				return t
			end

--[[exported]]	function _detalhes.SortGroup (container, keyName2)
				keyName = keyName2
				return _table_sort (container, _detalhes.SortKeyGroup)
			end

--[[exported]]	function _detalhes.SortKeyGroup (table1, table2)
				if (table1.grupo and table2.grupo) then
					return table1 [keyName] > table2 [keyName]
				elseif (table1.grupo and not table2.grupo) then
					return true
				elseif (not table1.grupo and table2.grupo) then
					return false
				else
					return table1 [keyName] > table2 [keyName]
				end
			end

--[[exported]] 	function _detalhes.SortKeySimple (table1, table2)
				return table1 [keyName] > table2 [keyName]
			end
			
--[[exported]] 	function _detalhes:ContainerSort (container, amount, keyName2)
				keyName = keyName2
				_table_sort (container,  _detalhes.SortKeySimple)
				
				if (amount) then 
					for i = amount, 1, -1 do --> de trás pra frente
						if (container[i][keyName] < 1) then
							amount = amount-1
						else
							break
						end
					end
					
					return amount
				end
			end
			
--[[ exported]] 	function _detalhes:IsPlayer()
				if (self.flags) then
					if (_bit_band (self.flag, 0x00000001) ~= 0) then
						return true
					end
				end
				return false
			end

local sortEnemies = function (t1, t2)
	local a = _bit_band (t1.flag_original, 0x00000040)
	local b = _bit_band (t2.flag_original, 0x00000040)
	
	if (a ~= 0 and b ~= 0) then
		return t1.total > t2.total
	elseif (a ~= 0 and b == 0) then
		return true
	elseif (a == 0 and b ~= 0) then
		return false
	end
	
	return false
end

--[[exported]] 	function _detalhes:ContainerSortEnemies (container, amount, keyName2)

				keyName = keyName2
				
				_table_sort (container, sortEnemies)
				
				local total = 0
				
				for index, player in _ipairs (container) do
				
					if (_bit_band (player.flag_original, 0x00000040) ~= 0) then --> é um inimigo
						total = total + player [keyName]
					else
						amount = index-1
						break
					end
				end
				
				return amount, total
			end

function atributo_damage:ContainerRefreshDps (container, combat_time)

	if (_detalhes.time_type == 2 or not _detalhes:CaptureGet ("damage")) then
		for _, actor in _ipairs (container) do
			if (actor.grupo) then
				actor.last_dps = actor.total / combat_time
			else
				actor.last_dps = actor.total / actor:Tempo()
			end
		end
	else
		for _, actor in _ipairs (container) do
			actor.last_dps = actor.total / actor:Tempo()
		end
	end
	
end

function _detalhes:ToolTipFrags (instancia, frag, esta_barra)
	
	--vardump (frag)
	
	local name = frag [1]
	local GameCooltip = GameCooltip
	
	GameCooltip:Reset()
	GameCooltip:SetType ("tooltip")
	GameCooltip:SetOwner (esta_barra)
	GameCooltip:SetOption ("LeftBorderSize", -5)
	GameCooltip:SetOption ("RightBorderSize", 5)
	GameCooltip:SetOption ("StatusBarTexture", [[Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT]])
	
	--> mantendo a função o mais low level possível
	local damage_container = instancia.showing [1]
	
	local frag_actor = damage_container._ActorTable [damage_container._NameIndexTable [ name ]]

	if (frag_actor) then
		
		local damage_taken_table = {}

		local took_damage_from = frag_actor.damage_from
		local total_damage_taken = frag_actor.damage_taken

		for aggressor, _ in _pairs (took_damage_from) do
		
			local damager_actor = damage_container._ActorTable[damage_container._NameIndexTable [ aggressor ]]
			
			if (damager_actor) then --> checagem por causa do total e do garbage collector que não limpa os names que deram dano
			
				local targets = damager_actor.targets
				
				local specific_target = targets._ActorTable [targets._NameIndexTable [ name ]] --> é ele mesmo
				if (specific_target) then
					damage_taken_table [#damage_taken_table+1] = {aggressor, specific_target.total, damager_actor.classe}
				end
			end
		end

		if (#damage_taken_table > 0) then
			
			_table_sort (damage_taken_table, _detalhes.Sort2)
			
			GameCooltip:AddLine (Loc ["STRING_FROM"], nil, nil, headerColor, nil, 12)
			GameCooltip:AddIcon ([[Interface\Addons\Details\images\icons]], 1, 1, 14, 14, 0.126953125, 0.1796875, 0, 0.0546875)
			GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
		
			for i = 1, math.min (6, #damage_taken_table) do 
			
				local t = damage_taken_table [i]
			
				GameCooltip:AddLine (t [1], _detalhes:comma_value (t [2]))
				local classe = t [3]
				if (not classe) then
					classe = "UNKNOW"
				end
				if (classe == "UNKNOW") then
					GameCooltip:AddIcon ("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, 14, 14, .25, .5, 0, 1)
				else
					GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, 14, 14, _unpack (_detalhes.class_coords [classe]))
				end
				GameCooltip:AddStatusBar (100, 1, .1, .1, .1, .3)
			end
			
			GameCooltip:AddLine (Loc ["STRING_REPORT_LEFTCLICK"], nil, 1, "white")
			GameCooltip:AddIcon ([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 1, 1, 12, 16, 0.015625, 0.13671875, 0.4375, 0.59765625)
			GameCooltip:ShowCooltip()
		
		else
			GameCooltip:AddLine (Loc ["STRING_NO_DATA"], nil, 1, "white")
			GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, 14, 14, _unpack (_detalhes.class_coords ["UNKNOW"]))
			GameCooltip:ShowCooltip()
		end
		
	else
		GameCooltip:AddLine (Loc ["STRING_NO_DATA"], nil, 1, "white")
		GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, 14, 14, _unpack (_detalhes.class_coords ["UNKNOW"]))
		GameCooltip:ShowCooltip()
	end
	
end

local function RefreshBarraFrags (tabela, barra, instancia)
	atributo_damage:AtualizarFrags (tabela, tabela.minha_barra, barra.colocacao, instancia)
end

function atributo_damage:ReportSingleFragsLine (frag, instancia)
	local barra = instancia.barras [frag.minha_barra]

	local reportar = {"Details! " .. Loc ["STRING_ATTRIBUTE_DAMAGE_TAKEN"].. ": " .. frag [1]} --> localize-me
	for i = 1, GameCooltip:GetNumLines() do 
		local texto_left, texto_right = GameCooltip:GetText (i)
		if (texto_left and texto_right) then 
			texto_left = texto_left:gsub (("|T(.*)|t "), "")
			reportar [#reportar+1] = ""..texto_left.." "..texto_right..""
		end
	end

	return _detalhes:Reportar (reportar, {_no_current = true, _no_inverse = true, _custom = true})
end

function atributo_damage:AtualizarFrags (tabela, qual_barra, colocacao, instancia)

	tabela ["frags"] = true --> marca que esta tabela é uma tabela de frags, usado no controla na hora de montar o tooltip
	local esta_barra = instancia.barras [qual_barra] --> pega a referência da barra na janela
	
	if (not esta_barra) then
		print ("DEBUG: problema com <instancia.esta_barra> "..qual_barra.." "..lugar)
		return
	end
	
	local tabela_anterior = esta_barra.minha_tabela
	
	esta_barra.minha_tabela = tabela
	
	tabela.nome = tabela [1] --> evita dar erro ao redimencionar a janela
	tabela.minha_barra = qual_barra
	esta_barra.colocacao = colocacao
	
	if (not _getmetatable (tabela)) then 
		_setmetatable (tabela, {__call = RefreshBarraFrags}) 
		tabela._custom = true
	end

	esta_barra.texto_esquerdo:SetText (colocacao .. ". " .. tabela [1])
	esta_barra.texto_direita:SetText (tabela [2])
	
	if (colocacao == 1) then
		esta_barra.statusbar:SetValue (100)
	else
		esta_barra.statusbar:SetValue (tabela [2] / instancia.top * 100)
	end
	
	if (esta_barra.hidden or esta_barra.fading_in or esta_barra.faded) then
		gump:Fade (esta_barra, "out")
	end

	--> ele nao come o texto quando a instância esta muito pequena
	esta_barra.textura:SetVertexColor (_unpack (_detalhes.class_colors [tabela [3]]))
	
	if (tabela [3] == "UNKNOW" or tabela [3] == "UNGROUPPLAYER" or tabela [3] == "ENEMY") then
		esta_barra.icone_classe:SetTexture ("Interface\\LFGFRAME\\LFGROLE_BW")
		esta_barra.icone_classe:SetTexCoord (.25, .5, 0, 1)
		esta_barra.icone_classe:SetVertexColor (1, 1, 1)
	else
		esta_barra.icone_classe:SetTexture ("Interface\\AddOns\\Details\\images\\classes_small")
		esta_barra.icone_classe:SetTexCoord (_unpack (_detalhes.class_coords [tabela [3]]))
		esta_barra.icone_classe:SetVertexColor (1, 1, 1)
	end

	if (esta_barra.mouse_over and not instancia.baseframe.isMoving) then --> precisa atualizar o tooltip
		--gump:UpdateTooltip (qual_barra, esta_barra, instancia)
	end

end

function atributo_damage:ReportSingleVoidZoneLine (actor, instancia)
	local barra = instancia.barras [actor.minha_barra]

	local reportar = {"Details! " .. Loc ["STRING_ATTRIBUTE_DAMAGE_DEBUFFS_REPORT"] .. ": " .. actor.nome} --> localize-me
	for i = 1, GameCooltip:GetNumLines() do 
		local texto_left, texto_right = GameCooltip:GetText (i)
		if (texto_left and texto_right) then 
			texto_left = texto_left:gsub (("|T(.*)|t "), "")
			reportar [#reportar+1] = ""..texto_left.." "..texto_right..""
		end
	end

	return _detalhes:Reportar (reportar, {_no_current = true, _no_inverse = true, _custom = true})
end

function _detalhes:ToolTipVoidZones (instancia, actor, barra)
	
	local damage_actor = instancia.showing[1]:PegarCombatente (_, actor.damage_twin)
	local habilidade
	local alvos
	
	if (damage_actor) then
		habilidade = damage_actor.spell_tables._ActorTable [actor.damage_spellid]
	end
	
	if (habilidade) then
		alvos = habilidade.targets
	end
	
	local container = actor.debuff_uptime_targets._ActorTable
	
	for _, alvo in _ipairs (container) do
		if (alvos) then
			local damage_alvo = alvos._NameIndexTable [alvo.nome]
			if (damage_alvo) then
				damage_alvo = alvos._ActorTable [damage_alvo]
				alvo.damage = damage_alvo.total
			else
				alvo.damage = 0
			end
		else
			alvo.damage = 0
		end
	end

	--> sort no container:
	_table_sort (container, function (tabela1, tabela2)
		if (tabela1.damage > tabela2.damage) then
			return true;
		elseif (tabela1.damage == tabela2.damage) then
			return tabela1.uptime > tabela2.uptime;
		end
		return false;
	end)
	
	actor.debuff_uptime_targets:remapear()
	
	--> monta o cooltip
	
	local GameCooltip = GameCooltip
	
	GameCooltip:Reset()
	GameCooltip:SetType ("tooltip")
	GameCooltip:SetOwner (barra)
	GameCooltip:SetOption ("LeftBorderSize", -5)
	GameCooltip:SetOption ("RightBorderSize", 5)
	GameCooltip:SetOption ("StatusBarTexture", [[Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT]])
	
	for _, alvo in _ipairs (container) do 

		local minutos, segundos = _math_floor (alvo.uptime / 60), _math_floor (alvo.uptime % 60)
		if (minutos > 0) then
			GameCooltip:AddLine (alvo.nome, _detalhes:comma_value (alvo.damage) .. " (" .. minutos .. "m " .. segundos .. "s" .. ")")
		else
			GameCooltip:AddLine (alvo.nome, _detalhes:comma_value (alvo.damage) .. " (" .. segundos .. "s" .. ")")
		end
		
		local classe = _detalhes:GetClass (alvo.nome)
		if (classe) then	
			GameCooltip:AddIcon ([[Interface\AddOns\Details\images\classes_small]], nil, nil, 14, 14, unpack (_detalhes.class_coords [classe]))
		else
			GameCooltip:AddIcon ("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, 14, 14, .25, .5, 0, 1)
		end
		
		GameCooltip:AddStatusBar (100, 1, .1, .1, .1, .3)
	
	end
	
	GameCooltip:AddLine (Loc ["STRING_REPORT_LEFTCLICK"], nil, 1, "white")
	GameCooltip:AddIcon ([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 1, 1, 12, 16, 0.015625, 0.13671875, 0.4375, 0.59765625)
	GameCooltip:ShowCooltip()
	
end

local function RefreshBarraVoidZone (tabela, barra, instancia)
	tabela:AtualizarVoidZone (tabela.minha_barra, barra.colocacao, instancia)
end

function atributo_misc:AtualizarVoidZone (qual_barra, colocacao, instancia)

	local esta_barra = instancia.barras [qual_barra] --> pega a referência da barra na janela
	
	if (not esta_barra) then
		print ("DEBUG: problema com <instancia.esta_barra> "..qual_barra.." "..lugar)
		return
	end
	
	self._refresh_window = RefreshBarraVoidZone
	
	local tabela_anterior = esta_barra.minha_tabela
	
	esta_barra.minha_tabela = self
	
	self.minha_barra = qual_barra
	esta_barra.colocacao = colocacao
	
	esta_barra.texto_esquerdo:SetText (colocacao .. ". " .. self.nome)
	esta_barra.texto_direita:SetText (self.debuff_uptime)
	
	--if (colocacao == 1) then
		esta_barra.statusbar:SetValue (100)
	--else
	--	esta_barra.statusbar:SetValue (self.debuff_uptime / instancia.top * 100)
	--end
	
	if (esta_barra.hidden or esta_barra.fading_in or esta_barra.faded) then
		gump:Fade (esta_barra, "out")
	end
	
	local _, _, icon = GetSpellInfo (self.damage_spellid)
	local school_color = _detalhes.school_colors [self.spellschool]
	if (not school_color) then
		school_color = _detalhes.school_colors ["unknown"]
	end
	
	esta_barra.textura:SetVertexColor (_unpack (school_color))
	esta_barra.icone_classe:SetTexture (icon)
	esta_barra.icone_classe:SetTexCoord (0, 1, 0, 1)
	esta_barra.icone_classe:SetVertexColor (1, 1, 1)

	if (esta_barra.mouse_over and not instancia.baseframe.isMoving) then --> precisa atualizar o tooltip
		--gump:UpdateTooltip (qual_barra, esta_barra, instancia)
	end

end

local ntable = {}
local vtable = {}

function atributo_damage:RefreshWindow (instancia, tabela_do_combate, forcar, exportar)
	
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable

	--> não há barras para mostrar -- not have something to show
	if (#showing._ActorTable < 1) then 
		--> colocado isso recentemente para fazer as barras de dano sumirem na troca de atributo
		return _detalhes:EsconderBarrasNaoUsadas (instancia, showing) 
	end
	
	--> total
	local total = 0
	--> top actor #1
	instancia.top = 0
	
	local using_cache = false
	
	local sub_atributo = instancia.sub_atributo --> o que esta sendo mostrado nesta instância
	local conteudo = showing._ActorTable --> pega a lista de jogadores -- get actors table from container
	local amount = #conteudo
	local modo = instancia.modo
	
	--> pega qual a sub key que será usada --sub keys
	if (exportar) then
	
		if (_type (exportar) == "boolean") then 		
			if (sub_atributo == 1) then --> DAMAGE DONE
				keyName = "total"
			elseif (sub_atributo == 2) then --> DPS
				keyName = "last_dps"
			elseif (sub_atributo == 3) then --> TAMAGE TAKEN
				keyName = "damage_taken"
			elseif (sub_atributo == 4) then --> FRIENDLY FIRE
				keyName = "friendlyfire_total"
			elseif (sub_atributo == 5) then --> FRAGS
				keyName = "frags"
			elseif (sub_atributo == 6) then --> ENEMIES
				keyName = "enemies"
			elseif (sub_atributo == 7) then --> AURAS VOIDZONES
				keyName = "voidzones"
			end
		else
			keyName = exportar.key
			modo = exportar.modo		
		end
	elseif (instancia.atributo == 5) then --> custom
		keyName = "custom"
		total = tabela_do_combate.totals [instancia.customName]
	else
		if (sub_atributo == 1) then --> DAMAGE DONE
			keyName = "total"
		elseif (sub_atributo == 2) then --> DPS
			keyName = "last_dps"
		elseif (sub_atributo == 3) then --> TAMAGE TAKEN
			keyName = "damage_taken"
		elseif (sub_atributo == 4) then --> FRIENDLY FIRE
			keyName = "friendlyfire_total"
		elseif (sub_atributo == 5) then --> FRAGS
			keyName = "frags"
		elseif (sub_atributo == 6) then --> ENEMIES
			keyName = "enemies"
		elseif (sub_atributo == 7) then --> AURAS VOIDZONES
			keyName = "voidzones"
		end
	end
	
	if (keyName == "frags") then 
	
		local frags = instancia.showing.frags
		local index = 0
		
		for fragName, fragAmount in _pairs (frags) do 
		
			index = index + 1
		
			local fragged_actor = showing._NameIndexTable [fragName] --> get index
			local actor_classe
			if (fragged_actor) then
				fragged_actor = showing._ActorTable [fragged_actor] --> get object
				actor_classe = fragged_actor.classe
			end
			
			if (fragged_actor and fragged_actor.monster) then
				actor_classe = "ENEMY"
			elseif (not actor_classe) then
				actor_classe = "UNGROUPPLAYER"
			end
			
			if (ntable [index]) then
				ntable [index] [1] = fragName
				ntable [index] [2] = fragAmount
				ntable [index] [3] = actor_classe
			else
				ntable [index] = {fragName, fragAmount, actor_classe}
			end
			
		end
		
		local tsize = #ntable
		if (index < tsize) then
			for i = index+1, tsize do
				ntable [i][2] = 0
			end
		end
		
		if (tsize > 0) then
			--_table_sort (ntable, function (t1, t2) 
			--	return (t1 [2] > t2 [2])
			--end)
			_table_sort (ntable, _detalhes.Sort2)
			instancia.top = ntable [1][2]
		end
	
		total = index
		
		if (exportar) then 
			local export = {}
			for i = 1, index do 
				export [i] = {ntable[i][1], ntable[i][2], ntable[i][3]}
			end
			return export
		end
		
		if (total < 1) then
			instancia:EsconderScrollBar()
			return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
		end
		
		--estra mostrando ALL então posso seguir o padrão correto? primeiro, atualiza a scroll bar...
		instancia:AtualizarScrollBar (total)
		
		--depois faz a atualização normal dele através dos iterators
		local qual_barra = 1
		local barras_container = instancia.barras

		for i = instancia.barraS[1], instancia.barraS[2], 1 do --> vai atualizar só o range que esta sendo mostrado
			atributo_damage:AtualizarFrags (ntable[i], qual_barra, i, instancia)
			qual_barra = qual_barra+1
		end
		
		return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
	
	elseif (keyName == "voidzones") then 
		
		local index = 0
		local misc_container = tabela_do_combate [4]
		
		for _, actor in _ipairs (misc_container._ActorTable) do
			if (actor.boss_debuff) then
			
				index = index + 1
			
				local twin_damage_actor = showing._NameIndexTable [actor.damage_twin]
				if (twin_damage_actor) then
					twin_damage_actor = showing._ActorTable [twin_damage_actor]
					actor.damage = twin_damage_actor.total
				else
					actor.damage = 0
				end
				
				vtable [index] = actor
				
			end
		end
		
		local tsize = #vtable
		if (index < tsize) then
			for i = index+1, tsize do
				vtable [i] = nil
			end
		end
		
		--print ("size: ", tsize)
		
		if (tsize > 0 and vtable[1]) then
			_table_sort (vtable, function (t1, t2) 
				return t1.damage > t2.damage
			end)
			instancia.top = vtable [1].damage
		end
		total = index 
		
		if (exportar) then 
			return vtable
		end
		
		if (total < 1) then
			instancia:EsconderScrollBar()
			return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
		end
		
		--esta mostrando ALL então posso seguir o padrão correto? primeiro, atualiza a scroll bar...
		instancia:AtualizarScrollBar (total)
		
		--depois faz a atualização normal dele através dos iterators
		local qual_barra = 1
		local barras_container = instancia.barras

		for i = instancia.barraS[1], instancia.barraS[2], 1 do --> vai atualizar só o range que esta sendo mostrado
			vtable[i]:AtualizarVoidZone (qual_barra, i, instancia)
			qual_barra = qual_barra+1
		end
		
		return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
		
	else
	
		if (instancia.atributo == 5) then --> custom
			--> faz o sort da categoria e retorna o amount corrigido
			amount = _detalhes:ContainerSort (conteudo, amount, keyName)
			
			--> grava o total
			instancia.top = conteudo[1][keyName]
			
		elseif (keyName == "enemies") then 
		
			amount, total = _detalhes:ContainerSortEnemies (conteudo, amount, "total")
			--keyName = "enemies"
			--> grava o total
			instancia.top = conteudo[1][keyName]
			
			--print ("aqui", amount, total, instancia.top)

		elseif (modo == modo_ALL) then --> mostrando ALL
		
			--> faz o sort da categoria e retorna o amount corrigido
			--print (keyName)
			if (sub_atributo == 2) then
				local combat_time = instancia.showing:GetCombatTime()
				atributo_damage:ContainerRefreshDps (conteudo, combat_time)
			end
			
			amount = _detalhes:ContainerSort (conteudo, amount, keyName)
			
			--> pega o total ja aplicado na tabela do combate
			total = tabela_do_combate.totals [class_type]
			
			--> grava o total
			instancia.top = conteudo[1][keyName]
		
		elseif (modo == modo_GROUP) then --> mostrando GROUP
		
			--> organiza as tabelas
			
			if (_detalhes.in_combat and instancia.segmento == 0 and not exportar) then
				using_cache = true
			end
			
			if (using_cache) then
			
				conteudo = _detalhes.cache_damage_group
				
				if (sub_atributo == 2) then
					local combat_time = instancia.showing:GetCombatTime()
					atributo_damage:ContainerRefreshDps (conteudo, combat_time)
				end
			
				if (#conteudo < 1) then
					return _detalhes:EsconderBarrasNaoUsadas (instancia, showing)
				end
			
				_table_sort (conteudo, _detalhes.SortKeySimple)
			
				if (conteudo[1][keyName] < 1) then
					amount = 0
				else
					instancia.top = conteudo[1][keyName]
					amount = #conteudo
				end
			
				for i = 1, amount do 
					total = total + conteudo[i][keyName]
				end
			else
				if (sub_atributo == 2) then
					local combat_time = instancia.showing:GetCombatTime()
					atributo_damage:ContainerRefreshDps (conteudo, combat_time)
				end

				_table_sort (conteudo, _detalhes.SortKeyGroup)
			end
			--
			
			if (not using_cache) then
				for index, player in _ipairs (conteudo) do
					--if (_bit_band (player.flag, DFLAG_player_group) >= 0x101) then --> é um player e esta em grupo
					if (player.grupo) then --> é um player e esta em grupo
						if (player[keyName] < 1) then --> dano menor que 1, interromper o loop
							amount = index - 1
							break
						elseif (index == 1) then --> esse IF aqui, precisa mesmo ser aqui? não daria pra pega-lo com uma chave [1] nad grupo == true?
							instancia.top = conteudo[1][keyName]
						end
						
						total = total + player[keyName]
					else
						amount = index-1
						break
					end
				end
			end
		end
	end
	
	--> refaz o mapa do container
	if (not using_cache) then
		showing:remapear()
	end
	
	if (exportar) then 
		return total, keyName, instancia.top
	end

	if (amount < 1) then --> não há barras para mostrar
		if (forcar) then
			if (instancia.modo == 2) then --> group
				for i = 1, instancia.barrasInfo.cabem  do
					gump:Fade (instancia.barras [i], "in", 0.3)
				end
			end
		end
		instancia:EsconderScrollBar() --> precisaria esconder a scroll bar
		return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
	end

	--estra mostrando ALL então posso seguir o padrão correto? primeiro, atualiza a scroll bar...
	--print ("AMOUT: " .. amount)
	instancia:AtualizarScrollBar (amount)

	--depois faz a atualização normal dele através dos iterators
	local qual_barra = 1
	local barras_container = instancia.barras --> evita buscar N vezes a key .barras dentro da instância

	if (not true) then --> follow tests, not working atm.
		local myPos = showing._NameIndexTable [_detalhes.playername]
		if (myPos) then
			--testando

			local cima = math.floor (instancia.barrasInfo.cabem/2)
			local baixo = math.ceil (instancia.barrasInfo.cabem/2)
			
			if (instancia.barrasInfo.cabem%2 == 0) then
				cima = cima - 1
			end
			
			cima = math.max (myPos - cima, 1)
			baixo = math.min (myPos + baixo, amount)
			
			print (myPos, cima, baixo)
			
			for i = cima, baixo, 1 do --> vai atualizar só o range que esta sendo mostrado
				conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName) --> instância, index, total, valor da 1º barra
				qual_barra = qual_barra+1
			end	

		end
	else
	
		if (total == 0) then
			total = 0.00000001
		end
	
		local combat_time = instancia.showing:GetCombatTime()
		for i = instancia.barraS[1], instancia.barraS[2], 1 do --> vai atualizar só o range que esta sendo mostrado
			conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName, combat_time) --> instância, index, total, valor da 1º barra
			qual_barra = qual_barra+1
		end	
	end
	

	
	if (instancia.atributo == 5) then --> custom
		--> zerar o .custom dos Actors
		for index, player in _ipairs (conteudo) do
			if (player.custom > 0) then 
				player.custom = 0
			else
				break
			end
		end
	end
	
	--> beta, hidar barras não usadas durante um refresh forçado
	if (forcar) then
		if (instancia.modo == 2) then --> group
			for i = qual_barra, instancia.barrasInfo.cabem  do
				gump:Fade (instancia.barras [i], "in", 0.3)
			end
		end
	end
	
	return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh

end

function atributo_damage:Custom (_customName, _combat, sub_atributo, spell, alvo)
	--> vai ter só o que a spell causou em alguém
	--print (spell)
	--print (self.nome)
	--print (self.spell_tables._ActorTable)
	
	--if (self.nome == "Ditador") then 
		--for spellid, tabela in pairs (self.spell_tables._ActorTable) do 
			--print (spellid)
		--end
		local _Skill = self.spell_tables._ActorTable [tonumber (spell)]
		--print (_Skill)
		if (_Skill) then
			local spellName = _GetSpellInfo (tonumber (spell))
			--print (spell)
			--print (spellName)
			
			local SkillTargets = _Skill.targets._ActorTable
			
			for _, TargetActor in _ipairs (SkillTargets) do 
				--print (TargetActor.nome)
				local TargetActorSelf = _combat (class_type, TargetActor.nome)
				if (TargetActorSelf) then
					--print (TargetActor.total)
					TargetActorSelf.custom = TargetActor.total + TargetActorSelf.custom
					--print (TargetActorSelf.custom)
					_combat.totals [_customName] = _combat.totals [_customName] + TargetActor.total
					--print (self.nome .. " " ..TargetActor.total)
				end
			end
		end
	--end
end

function _detalhes:FastRefreshWindow (instancia)
	if (instancia.atributo == 1) then --> damage
		
	end
end

local actor_class_color_r, actor_class_color_g, actor_class_color_b

--self = esta classe de dano
function atributo_damage:AtualizaBarra (instancia, barras_container, qual_barra, lugar, total, sub_atributo, forcar, keyName, combat_time)
							-- instância, container das barras, qual barra, colocação, total?, sub atributo, forçar refresh, key
	
	local esta_barra = barras_container [qual_barra] --> pega a referência da barra na janela
	
	if (not esta_barra) then
		print ("DEBUG: problema com <instancia.esta_barra> "..qual_barra.." "..lugar)
		return
	end
	
	local tabela_anterior = esta_barra.minha_tabela
	
	esta_barra.minha_tabela = self --> grava uma referência desse objeto na barra
	self.minha_barra = esta_barra --> grava uma referência da barra no objeto
	
	esta_barra.colocacao = lugar --> salva na barra qual a colocação mostrada.
	self.colocacao = lugar --> salva no objeto qual a colocação mostrada
	
	local damage_total = self.total --> total de dano que este jogador deu
	local dps
	local porcentagem = self [keyName] / total * 100
	local esta_porcentagem

	if ((_detalhes.time_type == 2 and self.grupo) or not _detalhes:CaptureGet ("damage") or not self.shadow) then
		dps = damage_total / combat_time
		self.last_dps = dps
	else
		if (not self.on_hold) then
			dps = damage_total/self:Tempo() --calcula o dps deste objeto
			self.last_dps = dps --salva o dps dele
		else
			if (self.last_dps == 0) then --> não calculou o dps dele ainda mas entrou em standby
				dps = damage_total/self:Tempo()
				self.last_dps = dps
			else
				dps = self.last_dps
			end
		end
	end
	
	-- >>>>>>>>>>>>>>> texto da direita
	if (instancia.atributo == 5) then --> custom
		esta_barra.texto_direita:SetText (_detalhes:ToK (self.custom) .." ".. div_abre .. _cstr ("%.1f", porcentagem).."%" .. div_fecha) --seta o texto da direita
		esta_porcentagem = _math_floor ((self.custom/instancia.top) * 100) --> determina qual o tamanho da barra
	else
		if (sub_atributo == 1) then --> mostrando damage done
			esta_barra.texto_direita:SetText (_detalhes:ToK (damage_total) .." ".. div_abre .. _math_floor (dps) .. ", ".. _cstr ("%.1f", porcentagem).."%" .. div_fecha) --seta o texto da direita
			esta_porcentagem = _math_floor ((damage_total/instancia.top) * 100) --> determina qual o tamanho da barra
			
		elseif (sub_atributo == 2) then --> mostrando dps
			esta_barra.texto_direita:SetText (_cstr("%.1f", dps) .." ".. div_abre .. _detalhes:ToK (damage_total) .. ", ".._cstr("%.1f", porcentagem).."%" .. div_fecha) --seta o texto da direita
			esta_porcentagem = _math_floor ((dps/instancia.top) * 100) --> determina qual o tamanho da barra
			
		elseif (sub_atributo == 3) then --> mostrando damage taken
			esta_barra.texto_direita:SetText (_detalhes:ToK (self.damage_taken) .." ".. div_abre .._cstr("%.1f", porcentagem).."%" .. div_fecha) --seta o texto da direita --_cstr("%.1f", dps) .. " - ".. DPS do damage taken não será possivel correto?
			esta_porcentagem = _math_floor ((self.damage_taken/instancia.top) * 100) --> determina qual o tamanho da barra
			
		elseif (sub_atributo == 4) then --> mostrando friendly fire
			esta_barra.texto_direita:SetText (_detalhes:ToK (self.friendlyfire_total) .." ".. div_abre .._cstr("%.1f", porcentagem).."%" .. div_fecha) --seta o texto da direita --_cstr("%.1f", dps) .. " - ".. DPS do damage taken não será possivel correto?
			esta_porcentagem = _math_floor ((self.friendlyfire_total/instancia.top) * 100) --> determina qual o tamanho da barra
		
		elseif (sub_atributo == 6) then --> mostrando friendly fire
			esta_barra.texto_direita:SetText (_detalhes:ToK (damage_total) .." ".. div_abre .. _math_floor (dps) .. ", ".. _cstr ("%.1f", porcentagem).."%" .. div_fecha) --seta o texto da direita
			esta_porcentagem = _math_floor ((damage_total/instancia.top) * 100) --> determina qual o tamanho da barra
		end
	end

	if (esta_barra.mouse_over and not instancia.baseframe.isMoving) then --> precisa atualizar o tooltip
		gump:UpdateTooltip (qual_barra, esta_barra, instancia)
	end

	if (self.need_refresh) then
		self.need_refresh = false
		forcar = true
	end
	

	if (self.owner) then
		actor_class_color_r, actor_class_color_g, actor_class_color_b = _unpack (_detalhes.class_colors [self.owner.classe])
	elseif (self.monster) then
		actor_class_color_r, actor_class_color_g, actor_class_color_b = _unpack (_detalhes.class_colors.ENEMY)
	else
		actor_class_color_r, actor_class_color_g, actor_class_color_b = _unpack (_detalhes.class_colors [self.classe])
	end
	
	return self:RefreshBarra2 (esta_barra, instancia, tabela_anterior, forcar, esta_porcentagem, qual_barra, barras_container)

end

--[[ exported]] function _detalhes:RefreshBarra2 (esta_barra, instancia, tabela_anterior, forcar, esta_porcentagem, qual_barra, barras_container)
	
	--> primeiro colocado
	if (esta_barra.colocacao == 1) then
		if (not tabela_anterior or tabela_anterior ~= esta_barra.minha_tabela or forcar) then
			esta_barra.statusbar:SetValue (100)
			
			if (esta_barra.hidden or esta_barra.fading_in or esta_barra.faded) then
				gump:Fade (esta_barra, "out")
			end
			
			return self:RefreshBarra (esta_barra, instancia)
		else
			return
		end
	else

		if (esta_barra.hidden or esta_barra.fading_in or esta_barra.faded) then
		
			esta_barra.statusbar:SetValue (esta_porcentagem)
			gump:Fade (esta_barra, "out")
			
			if (instancia.row_texture_class_colors) then
				esta_barra.textura:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
			end
			if (instancia.barrasInfo.texturaBackgroundByClass) then
				esta_barra.background:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
			end
			
			return self:RefreshBarra (esta_barra, instancia)
			
		else
			--> agora esta comparando se a tabela da barra é diferente da tabela na atualização anterior
			if (not tabela_anterior or tabela_anterior ~= esta_barra.minha_tabela or forcar) then --> aqui diz se a barra do jogador mudou de posição ou se ela apenas será atualizada
			
				esta_barra.statusbar:SetValue (esta_porcentagem)
			
				esta_barra.last_value = esta_porcentagem --> reseta o ultimo valor da barra
				
				if (instancia.use_row_animations and forcar) then
					esta_barra.tem_animacao = 0
					esta_barra:SetScript ("OnUpdate", nil)
				end
				
				return self:RefreshBarra (esta_barra, instancia)
				
			elseif (esta_porcentagem ~= esta_barra.last_value) then --> continua mostrando a mesma tabela então compara a porcentagem
				--> apenas atualizar
				if (instancia.use_row_animations) then
					
					local upRow = barras_container [qual_barra-1]
					if (upRow) then
						if (upRow.statusbar:GetValue() < esta_barra.statusbar:GetValue()) then
							esta_barra.statusbar:SetValue (esta_porcentagem)
						else
							instancia:AnimarBarra (esta_barra, esta_porcentagem)
						end
					else
						instancia:AnimarBarra (esta_barra, esta_porcentagem)
					end
				else
					esta_barra.statusbar:SetValue (esta_porcentagem)
				end
				esta_barra.last_value = esta_porcentagem
			end
		end

	end
	
end

--[[ exported]] function _detalhes:RefreshBarra (esta_barra, instancia, from_resize)
	
	if (from_resize) then
		if (self.owner) then
			actor_class_color_r, actor_class_color_g, actor_class_color_b = _unpack (_detalhes.class_colors [self.owner.classe])
		else
			actor_class_color_r, actor_class_color_g, actor_class_color_b = _unpack (_detalhes.class_colors [self.classe])
		end
	end
	
	if (instancia.row_texture_class_colors) then
		esta_barra.textura:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
	end
	if (instancia.barrasInfo.texturaBackgroundByClass) then
		esta_barra.background:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
	end	
	
	if (self.classe == "UNKNOW") then
		esta_barra.icone_classe:SetTexture ("Interface\\LFGFRAME\\LFGROLE_BW")
		esta_barra.icone_classe:SetTexCoord (.25, .5, 0, 1)
		esta_barra.icone_classe:SetVertexColor (1, 1, 1)
	
	elseif (self.classe == "UNGROUPPLAYER") then
		if (self.enemy) then
			if (_detalhes.faction_against == "Horde") then
				esta_barra.icone_classe:SetTexture ("Interface\\ICONS\\Achievement_Character_Orc_Male")
				esta_barra.icone_classe:SetTexCoord (0, 1, 0, 1)
			else
				esta_barra.icone_classe:SetTexture ("Interface\\ICONS\\Achievement_Character_Human_Male")
				esta_barra.icone_classe:SetTexCoord (0, 1, 0, 1)
			end
		else
			if (_detalhes.faction_against == "Horde") then
				esta_barra.icone_classe:SetTexture ("Interface\\ICONS\\Achievement_Character_Human_Male")
				esta_barra.icone_classe:SetTexCoord (0, 1, 0, 1)
			else
				esta_barra.icone_classe:SetTexture ("Interface\\ICONS\\Achievement_Character_Orc_Male")
				esta_barra.icone_classe:SetTexCoord (0, 1, 0, 1)
			end
		end
		esta_barra.icone_classe:SetVertexColor (1, 1, 1)
	
	elseif (self.classe == "PET") then
		esta_barra.icone_classe:SetTexture ("Interface\\AddOns\\Details\\images\\classes_small")
		esta_barra.icone_classe:SetTexCoord (0.25, 0.49609375, 0.75, 1)
		esta_barra.icone_classe:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)

	else
		esta_barra.icone_classe:SetTexture ("Interface\\AddOns\\Details\\images\\classes_small")
		esta_barra.icone_classe:SetTexCoord (_unpack (CLASS_ICON_TCOORDS [self.classe])) --very slow method
		esta_barra.icone_classe:SetVertexColor (1, 1, 1)
	end
	
	if (self.enemy) then
		if (_detalhes.faction_against == "Horde") then
			esta_barra.texto_esquerdo:SetText (esta_barra.colocacao..". |TInterface\\AddOns\\Details\\images\\icones_barra:"..instancia.barrasInfo.altura..":"..instancia.barrasInfo.altura..":0:0:256:32:0:32:0:32|t"..self.displayName) --seta o texto da esqueda -- HORDA
		else
			esta_barra.texto_esquerdo:SetText (esta_barra.colocacao..". |TInterface\\AddOns\\Details\\images\\icones_barra:"..instancia.barrasInfo.altura..":"..instancia.barrasInfo.altura..":0:0:256:32:32:64:0:32|t"..self.displayName) --seta o texto da esqueda -- ALLY
		end
		
		if (instancia.row_texture_class_colors) then
			esta_barra.textura:SetVertexColor (0.94117, 0, 0.01960, 1)
		end
	else
		esta_barra.texto_esquerdo:SetText (esta_barra.colocacao..". "..self.displayName) --seta o texto da esqueda
	end
	
	if (instancia.row_textL_class_colors) then
		esta_barra.texto_esquerdo:SetTextColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
	end
	if (instancia.row_textR_class_colors) then
		esta_barra.texto_direita:SetTextColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
	end
	
	esta_barra.texto_esquerdo:SetSize (esta_barra:GetWidth() - esta_barra.texto_direita:GetStringWidth() - 20, 15)
	
end


--------------------------------------------- // TOOLTIPS // ---------------------------------------------

--[[Exported]] function _detalhes:TooltipForCustom (barra)
		--GameCooltip:AddLine (barra.colocacao..". "..self.nome)
		GameCooltip:AddLine (Loc ["STRING_LEFT_CLICK_SHARE"])
		return true
end

---------> TOOLTIPS BIFURCAÇÃO

function atributo_damage:ToolTip (instancia, numero, barra)
	--> seria possivel aqui colocar o icone da classe dele?

	if (instancia.atributo == 5) then --> custom
		return self:TooltipForCustom (barra)
	else
		if (instancia.sub_atributo == 1 or instancia.sub_atributo == 2 or instancia.sub_atributo == 6) then --> damage done or Dps or enemy
			return self:ToolTip_DamageDone (instancia, numero, barra)
		elseif (instancia.sub_atributo == 3) then --> damage taken
			return self:ToolTip_DamageTaken (instancia, numero, barra)
		elseif (instancia.sub_atributo == 4) then --> friendly fire
			return self:ToolTip_FriendlyFire (instancia, numero, barra)
		end
	end
end
--> tooltip locals
local r, g, b
local headerColor = "yellow"
local barAlha = .6

--[[exported]]	function _detalhes.Sort1 (table1, table2)
				return table1 [1] > table2 [1]
			end
--[[exported]]	function _detalhes.Sort2 (table1, table2)
				return table1 [2] > table2 [2]
			end
--[[exported]]	function _detalhes.Sort3 (table1, table2)
				return table1 [3] > table2 [3]
			end
--[[exported]]	function _detalhes.Sort4 (table1, table2)
				return table1 [4] > table2 [4]
			end

---------> DAMAGE DONE & DPS
function atributo_damage:ToolTip_DamageDone (instancia, numero, barra)
	
	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack (_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack (_detalhes.class_colors [self.classe])
	end
	
	do
		--> TOP HABILIDADES
			local ActorDamage = self.total_without_pet
			if (ActorDamage == 0) then
				ActorDamage = 0.00000001
			end
			local ActorSkillsContainer = self.spell_tables._ActorTable
			local ActorSkillsSortTable = {}
			
			local meu_tempo
			if (_detalhes.time_type == 1 or not self.grupo) then
				meu_tempo = self:Tempo()
			elseif (_detalhes.time_type == 2) then
				meu_tempo = self:GetCombatTime()
			end
			
			for _spellid, _skill in _pairs (ActorSkillsContainer) do
				ActorSkillsSortTable [#ActorSkillsSortTable+1] = {_spellid, _skill.total, _skill.total/meu_tempo}
				--local nome_magia, _, icone_magia = _GetSpellInfo (_spellid)
				--print ("==============")
				--print (nome_magia, _skill.total)
			end
			_table_sort (ActorSkillsSortTable, _detalhes.Sort2)
		
		--> TOP INIMIGOS
			local ActorTargetsContainer = self.targets._ActorTable
			local ActorTargetsSortTable = {}
			for _, _target in _ipairs (ActorTargetsContainer) do
				ActorTargetsSortTable [#ActorTargetsSortTable+1] = {_target.nome, _target.total}
			end
			_table_sort (ActorTargetsSortTable, _detalhes.Sort2)
		
		--> MOSTRA HABILIDADES
			GameCooltip:AddLine (Loc ["STRING_SPELLS"].."", nil, nil, headerColor, nil, 12)
			--GameCooltip:AddIcon ([[Interface\HELPFRAME\HotIssueIcon]], 1, 1, 14, 14, 0.0625, 0.90625, 0, 1)
			GameCooltip:AddIcon ([[Interface\ICONS\Spell_Shaman_BlessingOfTheEternals]], 1, 1, 14, 14, 0.90625, 0.109375, 0.15625, 0.875)
			GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)

			local tooltip_max_abilities = _detalhes.tooltip_max_abilities

			if (instancia.sub_atributo == 2) then
				tooltip_max_abilities = 6
			end
			
			if (#ActorSkillsSortTable > 0) then
				for i = 1, _math_min (tooltip_max_abilities, #ActorSkillsSortTable) do
					local SkillTable = ActorSkillsSortTable [i]
					local nome_magia, _, icone_magia = _GetSpellInfo (SkillTable [1])
					if (instancia.sub_atributo == 1 or instancia.sub_atributo == 6) then
						GameCooltip:AddLine (nome_magia..": ", _detalhes:comma_value (SkillTable [2]) .." (".._cstr("%.1f", SkillTable [2]/ActorDamage*100).."%)")
					else
						GameCooltip:AddLine (nome_magia..": ", _detalhes:comma_value (_math_floor (SkillTable [3])) .." (".._cstr("%.1f", SkillTable [2]/ActorDamage*100).."%)")
					end
					GameCooltip:AddIcon (icone_magia, nil, nil, 14, 14)
					GameCooltip:AddStatusBar (100, 1, .1, .1, .1, .3)
				end
			else
				GameCooltip:AddLine (Loc ["STRING_NO_SPELL"])
			end
			
		--> MOSTRA INIMIGOS
			if (instancia.sub_atributo == 1 or instancia.sub_atributo == 6) then
				GameCooltip:AddLine (Loc ["STRING_TARGETS"].."", nil, nil, headerColor, nil, 12)
				GameCooltip:AddIcon ([[Interface\Addons\Details\images\icons]], 1, 1, 14, 14, 0, 0.03125, 0.126953125, 0.15625)
				GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
				
				for i = 1, _math_min (_detalhes.tooltip_max_targets, #ActorTargetsSortTable) do
					local este_inimigo = ActorTargetsSortTable [i]
					GameCooltip:AddLine (este_inimigo[1]..": ", _detalhes:comma_value (este_inimigo[2]) .." (".._cstr("%.1f", este_inimigo[2]/ActorDamage*100).."%)")
					GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\espadas", nil, nil, 14, 14)
					GameCooltip:AddStatusBar (100, 1, .1, .1, .1, .2)
				end
			end
	end
	
	--> PETS
	local meus_pets = self.pets
	if (#meus_pets > 0) then --> teve ajudantes
		
		local quantidade = {} --> armazena a quantidade de pets iguais
		local danos = {} --> armazena as habilidades
		local alvos = {} --> armazena os alvos
		local totais = {} --> armazena o dano total de cada objeto
		
		for index, nome in _ipairs (meus_pets) do
			if (not quantidade [nome]) then
				quantidade [nome] = 1
				
				local my_self = instancia.showing[class_type]:PegarCombatente (nil, nome)
				if (my_self) then
					local meu_total = my_self.total_without_pet
					local tabela = my_self.spell_tables._ActorTable
					local meus_danos = {}
					
					--totais [nome] = my_self.total_without_pet
					local meu_tempo
					if (_detalhes.time_type == 1 or not self.grupo) then
						meu_tempo = my_self:Tempo()
					elseif (_detalhes.time_type == 2) then
						meu_tempo = my_self:GetCombatTime()
					end
					totais [#totais+1] = {nome, my_self.total_without_pet, my_self.total_without_pet/meu_tempo}
					
					for spellid, tabela in _pairs (tabela) do
						local nome, rank, icone = _GetSpellInfo (spellid)
						_table_insert (meus_danos, {spellid, tabela.total, tabela.total/meu_total*100, {nome, rank, icone}})
					end
					_table_sort (meus_danos, _detalhes.Sort2)
					danos [nome] = meus_danos
					
					local meus_inimigos = {}
					tabela = my_self.targets._ActorTable
					for _, tabela in _ipairs (tabela) do
						_table_insert (meus_inimigos, {tabela.nome, tabela.total, tabela.total/meu_total*100})
					end
					_table_sort (meus_inimigos,_detalhes.Sort2)
					alvos [nome] = meus_inimigos
				end
				
			else
				quantidade [nome] = quantidade [nome]+1
			end
		end
		
		--GameTooltip:AddLine (" ")
		--GameCooltip:AddLine (" ")
		
		local _quantidade = 0
		local added_logo = false
		_table_sort (totais, _detalhes.Sort2)
		
		if (true) then
			
			for _, _table in _ipairs (totais) do
				
				if (_table [2] > 0) then
				
					if (not added_logo) then
						added_logo = true
						GameCooltip:AddLine (Loc ["STRING_PETS"].."", nil, nil, headerColor, nil, 12)
						
						--GameCooltip:AddIcon ([[Interface\Addons\Details\images\icons]], 1, 1, 14, 14, 0.03515625, 0.087890625, 0.0234375, 0.09765625, _detalhes.class_colors [self.classe])
						GameCooltip:AddIcon ([[Interface\COMMON\friendship-heart]], 1, 1, 14, 14, 0.21875, 0.78125, 0.09375, 0.6875)
						
						GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
					end
				
					local n = _table [1]:gsub (("%s%<.*"), "")
					if (instancia.sub_atributo == 1) then
						GameCooltip:AddLine (n, _detalhes:comma_value (_table [2]) .. " (" .. _math_floor (_table [2]/self.total*100) .. "%)")
					else
						GameCooltip:AddLine (n, _detalhes:comma_value ( _math_floor (_table [3])) .. " (" .. _math_floor (_table [2]/self.total*100) .. "%)")
					end
					GameCooltip:AddStatusBar (100, 1, .1, .1, .1, .3)
					GameCooltip:AddIcon ([[Interface\AddOns\Details\images\classes_small]], 1, 1, 14, 14, 0.25, 0.49609375, 0.75, 1)
				end
			end
			
		else
			--> old pet display mode
			for nome, meus_danos in _pairs (danos) do --> um pet de cada vez
				local n = nome:gsub (("%s%<.*"), "")
				--GameTooltip:AddDoubleLine ("Ajudante: ", "x"..quantidade[nome].." "..n.." (".._math_floor (totais [nome]/self.total*100).."%)", nil, nil, nil, 1, 1, 1) 
				--> pintar o nome do pet com a cor da classe do jogador
				
				local cor = self.cor
				GameCooltip:AddLine (Loc ["STRING_PET"]..":", n.." (".._math_floor (totais [nome]/self.total*100).."%)", 1, 1, 1, 1, _unpack (_detalhes.class_colors [self.classe])) --> removido a quantidade
				--GameCooltip:AddLine (Loc ["STRING_SPELLS"]) 
				--GameTooltip:AddDoubleLine (Loc ["STRING_PET"]..":", n.." (".._math_floor (totais [nome]/self.total*100).."%)", nil, nil, nil, _unpack (_detalhes.class_colors [self.classe])) --> removido a quantidade
				--GameTooltip:AddLine (Loc ["STRING_SPELLS"]) 
				for i = 1, 3 do
					if (meus_danos[i]) then
						--> meus_danos =  { [1] = spellid [2] = total [3] = % [4] = { [1] = nome [2] = rank [3] = icone } }
						GameCooltip:AddLine (meus_danos[i][4][1]..": ", _detalhes:comma_value (meus_danos[i][2]).." (".._cstr("%.1f", meus_danos[i][3]).."%)")
						GameCooltip:AddIcon (meus_danos[i][4][3], nil, nil, 14, 14)
						GameCooltip:AddStatusBar (100, 1, .1, .1, .1, .2)
						--GameTooltip:AddDoubleLine (meus_danos[i][4][1]..": ", _detalhes:comma_value (meus_danos[i][2]).." (".._cstr("%.1f", meus_danos[i][3]).."%)", 1, 1, 1, 1, 1, 1)
						--GameTooltip:AddTexture (meus_danos[i][4][3])
					end
				end
				
				GameTooltip:AddLine (Loc ["STRING_TARGETS"]) 
				for i = 1, 3 do
					local meus_inimigos = alvos [nome]
					if (meus_inimigos[i]) then
						GameTooltip:AddLine (meus_inimigos[i][1]..": ", _detalhes:comma_value (meus_inimigos[i][2]).." (".._cstr("%.1f", meus_inimigos[i][3]).."%)")
						--GameTooltip:AddDoubleLine (meus_inimigos[i][1]..": ", _detalhes:comma_value (meus_inimigos[i][2]).." (".._cstr("%.1f", meus_inimigos[i][3]).."%)", 1, 1, 1, 1, 1, 1)
						--GameTooltip:AddTexture ("Interface\\GossipFrame\\BattleMasterGossipIcon.blp")

						GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\espadas", nil, nil, 14, 14)
						GameCooltip:AddStatusBar (100, 1, .1, .1, .1, .2)
						--GameTooltip:AddTexture ("Interface\\AddOns\\Details\\images\\espadas")
					end
				end
				
				--GameTooltip:AddLine (" ")
				
				_quantidade = _quantidade + 1
				if (_quantidade >= _detalhes.tooltip_max_pets) then
					return true
				end
			end
		end
	end
	
	return true
end

---------> DAMAGE TAKEN
function atributo_damage:ToolTip_DamageTaken (instancia, numero, barra)

	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack (_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack (_detalhes.class_colors [self.classe])
	end

	local agressores = self.damage_from
	local damage_taken = self.damage_taken
	
	local tabela_do_combate = instancia.showing
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable
	
	local meus_agressores = {}

	for nome, _ in _pairs (agressores) do --> agressores seria a lista de nomes
		local este_agressor = showing._ActorTable[showing._NameIndexTable[nome]]
		if (este_agressor) then --> checagem por causa do total e do garbage collector que não limpa os nomes que deram dano
			local alvos = este_agressor.targets
			local este_alvo = alvos._ActorTable[alvos._NameIndexTable[self.nome]]
			if (este_alvo) then
				meus_agressores [#meus_agressores+1] = {nome, este_alvo.total, este_agressor.classe}
			end
		end
	end

	_table_sort (meus_agressores, function (a, b) return a[2] > b[2] end)

	GameCooltip:AddLine (Loc ["STRING_FROM"], nil, nil, headerColor, nil, 12)
	--GameCooltip:AddIcon ([[Interface\Addons\Details\images\icons]], 1, 1, 14, 14, 0.03515625, 0.087890625, 0.0234375, 0.09765625, _detalhes.class_colors [self.classe])
	GameCooltip:AddIcon ([[Interface\Addons\Details\images\icons]], 1, 1, 14, 14, 0.126953125, 0.1796875, 0, 0.0546875)
	GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
			
	local max = #meus_agressores
	if (max > 6) then
		max = 6
	end

	for i = 1, max do
		GameCooltip:AddLine (meus_agressores[i][1]..": ", _detalhes:comma_value (meus_agressores[i][2]).." (".._cstr("%.1f", (meus_agressores[i][2]/damage_taken) * 100).."%)")
		local classe = meus_agressores[i][3]
		
		if (not classe) then
			classe = "UNKNOW"
		end
		
		if (classe == "UNKNOW") then
			GameCooltip:AddIcon ("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, 14, 14, .25, .5, 0, 1)
		else
			GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, 14, 14, _unpack (_detalhes.class_coords [classe]))
		end
		GameCooltip:AddStatusBar (100, 1, .1, .1, .1, .3)
	end
	
	return true
end

---------> FRIENDLY FIRE
function atributo_damage:ToolTip_FriendlyFire (instancia, numero, barra)

	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack (_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack (_detalhes.class_colors [self.classe])
	end

	local FriendlyFire = self.friendlyfire --> container de jogadores
	local FriendlyFireTotal = self.friendlyfire_total

	local tabela_do_combate = instancia.showing
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable
	
	local DamagedPlayers = {}
	local Skills = {}

	for nome, index in _pairs (FriendlyFire._NameIndexTable) do
		local TargetActor = FriendlyFire._ActorTable [index]
		DamagedPlayers [#DamagedPlayers+1] = {nome, TargetActor.total, TargetActor.classe}
		
		local SkillTable = TargetActor.spell_tables --> container das habilidades
		for spellid, tabela in _pairs (SkillTable._ActorTable) do
			Skills [#Skills+1] = {spellid, tabela.total, tabela.counter}
		end
	end
	
	_table_sort (DamagedPlayers, _detalhes.Sort2)
	_table_sort (Skills, _detalhes.Sort2)

	GameCooltip:AddLine (Loc ["STRING_TARGETS"].."", nil, nil, headerColor, nil, 12)
	--GameCooltip:AddIcon ([[Interface\Addons\Details\images\icons]], 1, 1, 14, 14, 0.03515625, 0.087890625, 0.0234375, 0.09765625, _detalhes.class_colors [self.classe])
	GameCooltip:AddIcon ([[Interface\Addons\Details\images\icons]], 1, 1, 14, 14, 0.126953125, 0.224609375, 0.056640625, 0.140625)
	GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
		
	for i = 1, _math_min (_detalhes.tooltip_max_abilities, #DamagedPlayers) do
		local classe = DamagedPlayers[i][3]
		if (not classe) then
			classe = "UNKNOW"
		end

		GameCooltip:AddLine (DamagedPlayers[i][1]..": ", _detalhes:comma_value (DamagedPlayers[i][2]).." (".._cstr("%.1f", DamagedPlayers[i][2]/FriendlyFireTotal*100).."%)")
		GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\espadas", nil, nil, 14, 14)
		GameCooltip:AddStatusBar (100, 1, .1, .1, .1, .3)
		
		if (classe == "UNKNOW") then
			GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, 14, 14, _unpack (_detalhes.class_coords ["UNKNOW"]))
		else
			GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, 14, 14, _unpack (_detalhes.class_coords [classe]))
		end
		
	end
	
	GameCooltip:AddLine (Loc ["STRING_SPELLS"].."", nil, nil, headerColor, nil, 12)
	--GameCooltip:AddIcon ([[Interface\Addons\Details\images\icons]], 1, 1, 14, 14, 0.03515625, 0.087890625, 0.0234375, 0.09765625, _detalhes.class_colors [self.classe])
	GameCooltip:AddIcon ([[Interface\PVPFrame\bg-down-on]], 1, 1, 14, 14, 0, 1, 0, 1)
	GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
	
	for i = 1, _math_min (_detalhes.tooltip_max_abilities, #Skills) do
		local nome, _, icone = _GetSpellInfo (Skills[i][1])
		GameCooltip:AddLine (nome.." (x".. Skills[i][3].."): ", _detalhes:comma_value (Skills[i][2]).." (".._cstr("%.1f", Skills[i][2]/FriendlyFireTotal*100).."%)")
		GameCooltip:AddIcon (icone, nil, nil, 14, 14)
		GameCooltip:AddStatusBar (100, 1, .1, .1, .1, .3)
	end	
	
	return true
end


--------------------------------------------- // JANELA DETALHES // ---------------------------------------------


---------> DETALHES BIFURCAÇÃO
function atributo_damage:MontaInfo()
	if (info.sub_atributo == 1 or info.sub_atributo == 2 or info.sub_atributo == 6) then --> damage done & dps
		return self:MontaInfoDamageDone()
	elseif (info.sub_atributo == 3) then --> damage taken
		return self:MontaInfoDamageTaken()
	elseif (info.sub_atributo == 4) then --> friendly fire
		return self:MontaInfoFriendlyFire()
	end
end

---------> DETALHES bloco da direita BIFURCAÇÃO
function atributo_damage:MontaDetalhes (spellid, barra)
	if (info.sub_atributo == 1 or info.sub_atributo == 2) then
		return self:MontaDetalhesDamageDone (spellid, barra)
	elseif (info.sub_atributo == 3) then
		return self:MontaDetalhesDamageTaken (spellid, barra)
	elseif (info.sub_atributo == 4) then
		return self:MontaDetalhesFriendlyFire (spellid, barra)
	elseif (info.sub_atributo == 6) then
		return self:MontaDetalhesEnemy (spellid, barra)
	end
end


------ Friendly Fire
function atributo_damage:MontaInfoFriendlyFire()

	-- ESQUERDA -> JOGADORES ATINGIDOS - jogadores que o player atingiu com o fogo amigo
	-- DIREITA -> MAGIAS USADAS - magias que o jogador usou para causar dano no amigo
	-- ALVOS -> overall de todas as magias, total de dano que elas causaram

	local FriendlyFireTotal = self.friendlyfire_total --> total de fogo amigo dado por este jogador
	local conteudo = self.friendlyfire._ActorTable --> _ipairs[] com os nomes dos jogadores em que este jogador deu dano
	
	local barras = info.barras1
	local barras2 = info.barras2
	local barras3 = info.barras3
	
	local instancia = info.instancia
	
	local DamagedPlayers = {}
	local Skills = {}
	
	for nome, index in _pairs (self.friendlyfire._NameIndexTable) do --> da foreach em cada spellid do container
		local TargetActor = conteudo [index]
		local TargetActorDamage = TargetActor.total
		_table_insert (DamagedPlayers, {nome, TargetActorDamage, TargetActorDamage/FriendlyFireTotal*100, TargetActor.classe})
		
		for spellid, habilidade in _pairs (TargetActor.spell_tables._ActorTable) do
			if (not Skills [spellid]) then 
				Skills [spellid] = habilidade.total
			else
				Skills [spellid] = Skills [spellid] + habilidade.total
			end
		end
	end
	
	_table_sort (DamagedPlayers, _detalhes.Sort2)
	
	local amt = #DamagedPlayers
	gump:JI_AtualizaContainerBarras (amt)
	
	local FirstPlaceDamage = DamagedPlayers [1] and DamagedPlayers [1][2] or 0
	
	for index, tabela in _ipairs (DamagedPlayers) do
		local barra = barras [index]

		if (not barra) then
			barra = gump:CriaNovaBarraInfo1 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1)
			barra.on_focus = false
		end
		
		if (not info.mostrando_mouse_over) then
			if (tabela[1] == self.detalhes) then --> tabela [1] = NOME = NOME que esta na caixa da direita
				if (not barra.on_focus) then --> se a barra não tiver no foco
					barra.textura:SetStatusBarColor (129/255, 125/255, 69/255, 1)
					barra.on_focus = true
					if (not info.mostrando) then
						info.mostrando = barra
					end
				end
			else
				if (barra.on_focus) then
					barra.textura:SetStatusBarColor (1, 1, 1, 1) --> volta a cor antiga
					barra:SetAlpha (.9) --> volta a alfa antiga
					barra.on_focus = false
				end
			end
		end
		
		if (index == 1) then
			barra.textura:SetValue (100)
		else
			barra.textura:SetValue (tabela[2]/FirstPlaceDamage*100)
		end
		
		barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[1]) --seta o texto da esqueda
		barra.texto_direita:SetText (tabela[2] .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[3]) .."%".. instancia.divisores.fecha) --seta o texto da direita
		
		local classe = tabela[4]
		if (not classe) then
			classe = "monster"
		end

		barra.icone:SetTexture ("Interface\\AddOns\\Details\\images\\"..classe:lower().."_small")

		barra.minha_tabela = self
		barra.show = tabela[1]
		barra:Show()

		if (self.detalhes and self.detalhes == barra.show) then
			self:MontaDetalhes (self.detalhes, barra)
		end
	end

	local SkillTable = {}
	for spellid, amt in _pairs (Skills) do
		local nome, _, icone = _GetSpellInfo (spellid)
		SkillTable [#SkillTable+1] = {nome, amt, amt/FriendlyFireTotal*100, icone}
	end

	_table_sort (SkillTable, _detalhes.Sort2)	
	
	amt = #SkillTable
	if (amt < 1) then
		return
	end

	gump:JI_AtualizaContainerAlvos (amt)
	
	FirstPlaceDamage = SkillTable [1] and SkillTable [1][2] or 0
	
	for index, tabela in _ipairs (SkillTable) do
		local barra = barras2 [index]
		
		if (not barra) then
			barra = gump:CriaNovaBarraInfo2 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1)
		end
		
		if (index == 1) then
			barra.textura:SetValue (100)
		else
			barra.textura:SetValue (tabela[2]/FirstPlaceDamage*100)
		end
		
		barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[1]) --seta o texto da esqueda
		barra.texto_direita:SetText (tabela[2] .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[3]) .. instancia.divisores.fecha) --seta o texto da direita
		barra.icone:SetTexture (tabela[4])
		
		barra.minha_tabela = nil --> desativa o tooltip
	
		barra:Show()
	end
	
end

------ Damage Taken
function atributo_damage:MontaInfoDamageTaken()

	local damage_taken = self.damage_taken
	local agressores = self.damage_from
	local instancia = info.instancia
	local tabela_do_combate = instancia.showing
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable
	local barras = info.barras1	
	local meus_agressores = {}
	
	local este_agressor	
	for nome, _ in _pairs (agressores) do
		este_agressor = showing._ActorTable[showing._NameIndexTable[nome]]
		if (este_agressor) then
			local alvos = este_agressor.targets
			local este_alvo = alvos._ActorTable[alvos._NameIndexTable[self.nome]]
			if (este_alvo) then
				meus_agressores [#meus_agressores+1] = {nome, este_alvo.total, este_alvo.total/damage_taken*100, este_agressor.classe}
			end
		end
	end

	local amt = #meus_agressores
	
	if (amt < 1) then --> caso houve apenas friendly fire
		return true
	end
	
	--_table_sort (meus_agressores, function (a, b) return a[2] > b[2] end)
	_table_sort (meus_agressores, _detalhes.Sort2)
	
	gump:JI_AtualizaContainerBarras (amt)

	local max_ = meus_agressores [1] and meus_agressores [1][2] or 0

	local barra
	for index, tabela in _ipairs (meus_agressores) do
		barra = barras [index]
		if (not barra) then
			barra = gump:CriaNovaBarraInfo1 (instancia, index)
		end

		self:FocusLock (barra, tabela[1])
		
		local texCoords = CLASS_ICON_TCOORDS [tabela[4]]
		if (not texCoords) then
			texCoords = _detalhes.class_coords ["UNKNOW"]
		end
		
		self:UpdadeInfoBar (barra, index, tabela[1], tabela[1], tabela[2], max_, tabela[3], "Interface\\AddOns\\Details\\images\\classes_small", true, texCoords)
	end
	
end

--[[
		--> TOP HABILIDADES
		local ActorDamage = self.total_without_pet
		local ActorSkillsContainer = self.spell_tables._ActorTable
		local ActorSkillsSortTable = {}
		for _spellid, _skill in _pairs (ActorSkillsContainer) do
			ActorSkillsSortTable [#ActorSkillsSortTable+1] = {_spellid, _skill.total}
		end
		_table_sort (ActorSkillsSortTable, _detalhes.Sort2)
		
		--> TOP INIMIGOS
		local ActorTargetsContainer = self.targets._ActorTable
		local ActorTargetsSortTable = {}
		for _, _target in _ipairs (ActorTargetsContainer) do
			ActorTargetsSortTable [#ActorTargetsSortTable+1] = {_target.nome, _target.total}
		end
		_table_sort (ActorTargetsSortTable, _detalhes.Sort2)
--]]

--[[exported]] function _detalhes:UpdadeInfoBar (row, index, spellid, name, value, max, percent, icon, detalhes, texCoords)
	--> seta o tamanho da barra
	if (index == 1) then
		row.textura:SetValue (100)
	else
		row.textura:SetValue (value/max*100)
	end

	--> seta o texto da esqueda
	--row.texto_esquerdo:SetText (index.."."..name)
	--if (not) then
	
	--end
	row.texto_esquerdo:SetText (index.."."..name)
	--> seta o texto da direita
	row.texto_direita:SetText (_detalhes:comma_value (value).." (".._cstr("%.1f", percent) .."%)")
	
	--> seta o icone
	if (icon) then 
		row.icone:SetTexture (icon)
		if (icon == "Interface\\AddOns\\Details\\images\\classes_small") then
			row.icone:SetTexCoord (0.25, 0.49609375, 0.75, 1)
		else
			row.icone:SetTexCoord (0, 1, 0, 1)
		end
	else
		row.icone:SetTexture ("")
	end
	
	if (texCoords) then
		row.icone:SetTexCoord (unpack (texCoords))
	end
	
	row.minha_tabela = self
	row.show = spellid
	row:Show() --> mostra a barra
	
	if (detalhes and self.detalhes and self.detalhes == spellid) then
		self:MontaDetalhes (spellid, row) --> poderia deixar isso pro final e montar uma tail call??
	end
end

--[[exported]] function _detalhes:FocusLock (row, spellid)
	if (not info.mostrando_mouse_over) then
		if (spellid == self.detalhes) then --> tabela [1] = spellid = spellid que esta na caixa da direita
			if (not row.on_focus) then --> se a barra não tiver no foco
				row.textura:SetStatusBarColor (129/255, 125/255, 69/255, 1)
				row.on_focus = true
				if (not info.mostrando) then
					info.mostrando = row
				end
			end
		else
			if (row.on_focus) then
				row.textura:SetStatusBarColor (1, 1, 1, 1) --> volta a cor antiga
				row:SetAlpha (.9) --> volta a alfa antiga
				row.on_focus = false
			end
		end
	end
end

------ Damage Done & Dps
function atributo_damage:MontaInfoDamageDone()

	local barras = info.barras1
	local instancia = info.instancia
	local total = self.total_without_pet --> total de dano aplicado por este jogador 
	
	local ActorTotalDamage = self.total
	local ActorSkillsSortTable = {}
	local ActorSkillsContainer = self.spell_tables._ActorTable

	for _spellid, _skill in _pairs (ActorSkillsContainer) do --> da foreach em cada spellid do container
		local nome, _, icone = _GetSpellInfo (_spellid)
		_table_insert (ActorSkillsSortTable, {_spellid, _skill.total, _skill.total/ActorTotalDamage*100, nome, icone})
	end

	--> add pets
	local ActorPets = self.pets
	for _, PetName in _ipairs (ActorPets) do
		local PetActor = instancia.showing (class_type, PetName)
		if (PetActor) then 
			_table_insert (ActorSkillsSortTable, {PetName, PetActor.total, PetActor.total/ActorTotalDamage*100, PetName:gsub ((" <.*"), ""), "Interface\\AddOns\\Details\\images\\classes_small"})
		end
	end
	
	_table_sort (ActorSkillsSortTable, _detalhes.Sort2)

	gump:JI_AtualizaContainerBarras (#ActorSkillsSortTable)

	local max_ = ActorSkillsSortTable[1] and ActorSkillsSortTable[1][2] or 0 --> dano que a primeiro magia vez

	local barra
	for index, tabela in _ipairs (ActorSkillsSortTable) do
		barra = barras [index]
		if (not barra) then
			barra = gump:CriaNovaBarraInfo1 (instancia, index)
		end

		self:FocusLock (barra, tabela[1])
		
		self:UpdadeInfoBar (barra, index, tabela[1], tabela[4], tabela[2], max_, tabela[3], tabela[5], true)
	end
	
	--> TOP INIMIGOS
	if (instancia.sub_atributo == 6) then
	
		local damage_taken = self.damage_taken
		local agressores = self.damage_from
		local tabela_do_combate = instancia.showing
		local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable
		local barras = info.barras2
		local meus_agressores = {}
		
		local este_agressor	
		for nome, _ in _pairs (agressores) do
			este_agressor = showing._ActorTable[showing._NameIndexTable[nome]]
			if (este_agressor) then
				local alvos = este_agressor.targets
				local este_alvo = alvos._ActorTable[alvos._NameIndexTable[self.nome]]
				if (este_alvo) then
					meus_agressores [#meus_agressores+1] = {nome, este_alvo.total, este_alvo.total/damage_taken*100, este_agressor.classe}
				end
			end
		end

		local amt = #meus_agressores
		
		if (amt < 1) then --> caso houve apenas friendly fire
			return true
		end
		
		--_table_sort (meus_agressores, function (a, b) return a[2] > b[2] end)
		_table_sort (meus_agressores, _detalhes.Sort2)
		
		local max_ = meus_agressores[1] and meus_agressores[1][2] or 0 --> dano que a primeiro magia vez
		
		local barra
		for index, tabela in _ipairs (meus_agressores) do
			barra = barras [index]

			if (not barra) then --> se a barra não existir, criar ela então
				barra = gump:CriaNovaBarraInfo2 (instancia, index)
				barra.textura:SetStatusBarColor (1, 1, 1, 1) --> isso aqui é a parte da seleção e desceleção
			end
			
			if (index == 1) then
				barra.textura:SetValue (100)
			else
				barra.textura:SetValue (tabela[2]/max_*100)
			end

			barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[1]) --seta o texto da esqueda
			barra.texto_direita:SetText (tabela[2] .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[3]) .."%".. instancia.divisores.fecha) --seta o texto da direita
			
			--barra.icone:SetTexture (tabela[4]) --CLASSE
			
			if (barra.mouse_over) then --> atualizar o tooltip
				if (barra.isAlvo) then
					GameTooltip:Hide() 
					GameTooltip:SetOwner (barra, "ANCHOR_TOPRIGHT")
					if (not barra.minha_tabela:MontaTooltipDamageTaken (barra, index)) then
						return
					end
					GameTooltip:Show()
				end
			end
			
			barra.minha_tabela = self --> grava o jogador na tabela
			barra.nome_inimigo = tabela [1] --> salva o nome do inimigo na barra --> isso é necessário?
			
			-- no lugar do spell id colocar o que?
			barra.spellid = "enemies"

			barra:Show() --> mostra a barra
		end
	else
		local meus_inimigos = {}
		conteudo = self.targets._ActorTable
		
		for _, tabela in _ipairs (conteudo) do
			_table_insert (meus_inimigos, {tabela.nome, tabela.total, tabela.total/total*100})
		end
		
		_table_sort (meus_inimigos, function(a, b) return a[2] > b[2] end )	
		
		local amt_alvos = #meus_inimigos
		if (amt_alvos < 1) then
			return
		end
		
		gump:JI_AtualizaContainerAlvos (amt_alvos)
		
		local max_inimigos = meus_inimigos[1] and meus_inimigos[1][2] or 0
		
		local barra
		for index, tabela in _ipairs (meus_inimigos) do
		
			barra = info.barras2 [index]
			
			if (not barra) then
				barra = gump:CriaNovaBarraInfo2 (instancia, index)
				barra.textura:SetStatusBarColor (1, 1, 1, 1)
			end
			
			if (index == 1) then
				barra.textura:SetValue (100)
			else
				barra.textura:SetValue (tabela[2]/max_inimigos*100)
			end
			
			barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[1]) --seta o texto da esqueda
			barra.texto_direita:SetText (_detalhes:comma_value (tabela[2]) .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[3]) .. instancia.divisores.fecha) --seta o texto da direita
			
			if (barra.mouse_over) then --> atualizar o tooltip
				if (barra.isAlvo) then
					GameTooltip:Hide() 
					GameTooltip:SetOwner (barra, "ANCHOR_TOPRIGHT")
					if (not barra.minha_tabela:MontaTooltipAlvos (barra, index)) then
						return
					end
					GameTooltip:Show()
				end
			end
			
			barra.minha_tabela = self --> grava o jogador na tabela
			barra.nome_inimigo = tabela [1] --> salva o nome do inimigo na barra --> isso é necessário?
			
			-- no lugar do spell id colocar o que?
			barra.spellid = tabela[5]
			barra:Show()
		end
	end
end


------ Detalhe Info Friendly Fire
function atributo_damage:MontaDetalhesFriendlyFire (nome, barra)

	for _, barra in _ipairs (info.barras3) do 
		barra:Hide()
	end

	local barras = info.barras3
	local instancia = info.instancia
	
	local tabela_do_combate = info.instancia.showing
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable

	--> será apresentada as magias que deram dano no jogador alvo
	
	local friendlyfire = self.friendlyfire

	local total = friendlyfire._ActorTable [friendlyfire._NameIndexTable[nome]].total
	local conteudo = friendlyfire._ActorTable [friendlyfire._NameIndexTable[nome]].spell_tables._ActorTable --> assumindo que nome é o nome do Alvo que tomou dano // bastaria pegar a tabela de habilidades dele

	local minhas_magias = {}

	for spellid, tabela in _pairs (conteudo) do --> da foreach em cada spellid do container
		local nome, _, icone = _GetSpellInfo (spellid)
		_table_insert (minhas_magias, {spellid, tabela.total, tabela.total/total*100, nome, icone})
	end

	_table_sort (minhas_magias, function(a, b) return a[2] > b[2] end)

	--local amt = #minhas_magias
	--gump:JI_AtualizaContainerBarras (amt)

	local max_ = minhas_magias[1] and minhas_magias[1][2] or 0 --> dano que a primeiro magia vez
	
	local barra
	for index, tabela in _ipairs (minhas_magias) do
		barra = barras [index]

		if (not barra) then --> se a barra não existir, criar ela então
			barra = gump:CriaNovaBarraInfo3 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1) --> isso aqui é a parte da seleção e desceleção
		end
		
		if (index == 1) then
			barra.textura:SetValue (100)
		else
			barra.textura:SetValue (tabela[2]/max_*100) --> muito mais rapido...
		end

		barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[4]) --seta o texto da esqueda
		barra.texto_direita:SetText (tabela[2] .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[3]) .."%".. instancia.divisores.fecha) --seta o texto da direita
		
		barra.icone:SetTexture (tabela[5])

		barra:Show() --> mostra a barra
		
		if (index == 15) then 
			break
		end
	end
	
end

-- detalhes info enemies
function atributo_damage:MontaDetalhesEnemy (spellid, barra)
	
	for _, barra in _ipairs (info.barras3) do 
		barra:Hide()
	end
	
	local container = info.instancia.showing[1]
	local barras = info.barras3
	local instancia = info.instancia
	local spell = self.spell_tables:PegaHabilidade (spellid)
	
	local targets = spell.targets._ActorTable
	local target_pool = {}
	
	for _, target in _ipairs (targets) do	
		local classe
		local this_actor = info.instancia.showing (1, target.nome)
		if (this_actor) then
			classe = this_actor.classe or "UNKNOW"
		else
			classe = "UNKNOW"
		end
		target_pool [#target_pool+1] = {target.nome, target.total, classe}
	end
	
	_table_sort (target_pool, _detalhes.Sort2)
	
	local max_ = target_pool [1] and target_pool [1][2] or 0
	
	local barra
	for index, tabela in _ipairs (target_pool) do
		barra = barras [index]

		if (not barra) then --> se a barra não existir, criar ela então
			barra = gump:CriaNovaBarraInfo3 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1) --> isso aqui é a parte da seleção e desceleção
		end
		
		if (index == 1) then
			barra.textura:SetValue (100)
		else
			barra.textura:SetValue (tabela[2]/max_*100) --> muito mais rapido...
		end

		barra.texto_esquerdo:SetText (index .. ". " .. tabela [1]) --seta o texto da esqueda
		_detalhes:name_space_info (barra)
		
		if (spell.total > 0) then
			barra.texto_direita:SetText (tabela[2] .." (".. _cstr("%.1f", tabela[2] / spell.total * 100) .."%)") --seta o texto da direita
		else
			barra.texto_direita:SetText (tabela[2] .." (0%)") --seta o texto da direita
		end
		
		local texCoords = _detalhes.class_coords [tabela[3]]
		if (not texCoords) then
			texCoords = _detalhes.class_coords ["UNKNOW"]
		end
		
		barra.icone:SetTexture ("Interface\\AddOns\\Details\\images\\classes_small")
		barra.icone:SetTexCoord (unpack (texCoords))

		barra:Show() --> mostra a barra
		
		if (index == 15) then 
			break
		end
	end
	
end

------ Detalhe Info Damage Taken
function atributo_damage:MontaDetalhesDamageTaken (nome, barra)

	for _, barra in _ipairs (info.barras3) do 
		barra:Hide()
	end

	local barras = info.barras3
	local instancia = info.instancia
	
	local tabela_do_combate = info.instancia.showing
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable

	local este_agressor = showing._ActorTable[showing._NameIndexTable[nome]]
	
	if (not este_agressor ) then 
		print ("EROO este agressor eh NIL")
		return
	end
	
	local conteudo = este_agressor.spell_tables._ActorTable --> _pairs[] com os IDs das magias
	
	local actor = info.jogador.nome
	
	local total = este_agressor.targets._ActorTable [este_agressor.targets._NameIndexTable [actor]].total

	local minhas_magias = {}

	for spellid, tabela in _pairs (conteudo) do --> da foreach em cada spellid do container
	
		--> preciso pegar os alvos que esta magia atingiu
		local alvos = tabela.targets
		local index = alvos._NameIndexTable[actor]
		
		if (index) then --> esta magia deu dano no actor
			local este_alvo = alvos._ActorTable[index] --> pega a classe_target
			local spell_nome, rank, icone = _GetSpellInfo (spellid)
			_table_insert (minhas_magias, {spellid, este_alvo.total, este_alvo.total/total*100, spell_nome, icone})
		end

	end

	_table_sort (minhas_magias, function(a, b) return a[2] > b[2] end)

	--local amt = #minhas_magias
	--gump:JI_AtualizaContainerBarras (amt)

	local max_ = minhas_magias[1] and minhas_magias[1][2] or 0 --> dano que a primeiro magia vez
	
	local barra
	for index, tabela in _ipairs (minhas_magias) do
		barra = barras [index]

		if (not barra) then --> se a barra não existir, criar ela então
			barra = gump:CriaNovaBarraInfo3 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1) --> isso aqui é a parte da seleção e desceleção
		end
		
		if (index == 1) then
			barra.textura:SetValue (100)
		else
			barra.textura:SetValue (tabela[2]/max_*100) --> muito mais rapido...
		end

		barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[4]) --seta o texto da esqueda
		_detalhes:name_space_info (barra)
		
		barra.texto_direita:SetText (tabela[2] .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[3]) .."%".. instancia.divisores.fecha) --seta o texto da direita
		
		barra.icone:SetTexture (tabela[5])

		barra:Show() --> mostra a barra
		
		if (index == 15) then 
			break
		end
	end
	
end

------ Detalhe Info Damage Done e Dps
function atributo_damage:MontaDetalhesDamageDone (spellid, barra)

	if (_type (spellid) == "string") then 
	
		local _barra = info.grupos_detalhes [1]
		
		if (not _barra.pet) then 
			_barra.bg.PetIcon = _barra.bg:CreateTexture (nil, "overlay")
			
			--_barra.bg.PetIcon:SetTexture ("Interface\\ICONS\\Ability_Druid_SkinTeeth")
			_barra.bg.PetIcon:SetTexture ("Interface\\AddOns\\Details\\images\\classes")
			_barra.bg.PetIcon:SetTexCoord (0.25, 0.49609375, 0.75, 1)

			_barra.bg.PetIcon:SetPoint ("left", _barra.bg, "left", 2, 2)
			_barra.bg.PetIcon:SetWidth (40)
			_barra.bg.PetIcon:SetHeight (40)
			gump:NewLabel (_barra.bg, _barra.bg, nil, "PetText", Loc ["STRING_ISA_PET"], "GameFontHighlightLeft")
			_barra.bg.PetText:SetPoint ("topleft", _barra.bg.PetIcon, "topright", 10, -2)
			gump:NewLabel (_barra.bg, _barra.bg, nil, "PetDps", "", "GameFontHighlightSmall")
			_barra.bg.PetDps:SetPoint ("left", _barra.bg.PetIcon, "right", 10, 2)
			_barra.bg.PetDps:SetPoint ("top", _barra.bg.PetText, "bottom", 0, -5)
			_barra.pet = true
		end
		
		_barra.IsPet = true
		_barra.bg:SetValue (100)
		gump:Fade (_barra.bg.overlay, "OUT")
		_barra.bg:SetStatusBarColor (1, 1, 1)
		_barra.bg_end:SetPoint ("LEFT", _barra.bg, "LEFT", (_barra.bg:GetValue()*2.19)-6, 0)
		_barra.bg.PetIcon:SetVertexColor (_unpack (_detalhes.class_colors [self.classe]))
		_barra.bg:Show()
		_barra.bg.PetIcon:Show()
		_barra.bg.PetText:Show()
		_barra.bg.PetDps:Show()
		
		local PetActor = info.instancia.showing (info.instancia.atributo, spellid)
		
		if (PetActor) then 
			local OwnerActor = PetActor.ownerName
			if (OwnerActor) then --> nor necessary
				OwnerActor = info.instancia.showing (info.instancia.atributo, OwnerActor)
				if (OwnerActor) then 
					local meu_tempo = OwnerActor:Tempo()
					local normal_dmg = PetActor.total
					local T = (meu_tempo*normal_dmg)/PetActor.total
					_barra.bg.PetDps:SetText ("Dps: " .. _cstr("%.1f", normal_dmg/T))
				end
			end
		
		end
		
		for i = 2, 5 do
			gump:HidaDetalheInfo (i)
		end
		
		local ThisBox = _detalhes.janela_info.grupos_detalhes [1]
		ThisBox.nome:Hide()
		ThisBox.dano:Hide()
		ThisBox.dano_porcento:Hide()
		ThisBox.dano_media:Hide()
		ThisBox.dano_dps:Hide()
		ThisBox.nome2:Hide()

		return
	end

	local esta_magia = self.spell_tables._ActorTable [spellid]
	if (not esta_magia) then
		return
	end

	--> icone direito superior
	local nome, rank, icone = _GetSpellInfo (spellid)
	local infospell = {nome, rank, icone}

	_detalhes.janela_info.spell_icone:SetTexture (infospell[3])

	local total = self.total
	local meu_tempo
	if (_detalhes.time_type == 1 or not self.grupo) then
		meu_tempo = self:Tempo()
	elseif (_detalhes.time_type == 2) then
		meu_tempo = self:GetCombatTime()
	end
	
	local total_hits = esta_magia.counter
	
	local index = 1
	
	local data = {}
	
	--> GERAL
		local media = esta_magia.total/total_hits
		
		local this_dps = nil
		if (esta_magia.counter > esta_magia.c_amt) then
			this_dps = Loc ["STRING_DPS"]..": ".._cstr("%.1f", esta_magia.total/meu_tempo)
		else
			this_dps = Loc ["STRING_DPS"]..": "..Loc ["STRING_SEE_BELOW"]
		end
		
		gump:SetaDetalheInfoTexto ( index, 100,
			Loc ["STRING_GERAL"],
			Loc ["STRING_DAMAGE"]..": ".._detalhes:ToK (esta_magia.total), 
			Loc ["STRING_PERCENTAGE"]..": ".._cstr("%.1f", esta_magia.total/total*100) .. "%", 
			Loc ["STRING_MEDIA"]..": " .. _cstr("%.1f", media), 
			this_dps,
			Loc ["STRING_HITS"]..": " .. total_hits)
	
	--> NORMAL
		local normal_hits = esta_magia.n_amt
		if (normal_hits > 0) then
			local normal_dmg = esta_magia.n_dmg
			local media_normal = normal_dmg/normal_hits
			local T = (meu_tempo*normal_dmg)/esta_magia.total
			local P = media/media_normal*100
			T = P*T/100

			data[#data+1] = {
				esta_magia.n_amt, 
				normal_hits/total_hits*100, 
				Loc ["STRING_NORMAL_HITS"],
				Loc ["STRING_MINIMUM"]..": ".._detalhes:comma_value (esta_magia.n_min),
				Loc ["STRING_MAXIMUM"]..": ".._detalhes:comma_value (esta_magia.n_max), 
				Loc ["STRING_MEDIA"]..": ".._cstr("%.1f", media_normal), 
				Loc ["STRING_DPS"]..": ".._cstr("%.1f", normal_dmg/T), 
				normal_hits.. " / ".._cstr("%.1f", normal_hits/total_hits*100).."%"
				}
		end

	--> CRITICO
		if (esta_magia.c_amt > 0) then	
			local media_critico = esta_magia.c_dmg/esta_magia.c_amt
			local T = (meu_tempo*esta_magia.c_dmg)/esta_magia.total
			local P = media/media_critico*100
			T = P*T/100
			local crit_dps = esta_magia.c_dmg/T
			if (not crit_dps) then
				crit_dps = 0
			end
			
			data[#data+1] = {
				esta_magia.c_amt,
				esta_magia.c_amt/total_hits*100, 
				Loc ["STRING_CRITICAL_HITS"], 
				Loc ["STRING_MINIMUM"]..": ".._detalhes:comma_value (esta_magia.c_min),
				Loc ["STRING_MAXIMUM"]..": ".._detalhes:comma_value (esta_magia.c_max),
				Loc ["STRING_MEDIA"]..": ".._cstr("%.1f", media_critico), 
				Loc ["STRING_DPS"]..": ".._cstr("%.1f", crit_dps),
				esta_magia.c_amt.. " / ".._cstr("%.1f", esta_magia.c_amt/total_hits*100).."%"
				}
		end
		
	--> Outros erros: GLACING, resisted, blocked, absorbed
		local outros_desvios = esta_magia.g_amt + esta_magia.r_amt + esta_magia.b_amt + esta_magia.a_amt
		
		if (outros_desvios > 0) then
			local porcentagem_defesas = outros_desvios/total_hits*100
			data[#data+1] = {
				outros_desvios,
				{["p"] = porcentagem_defesas, ["c"] = {117/255, 58/255, 0/255}},
				Loc ["STRING_DEFENSES"], 
				Loc ["STRING_GLANCING"]..": "..esta_magia.g_amt.." / ".._math_floor (esta_magia.g_amt/esta_magia.counter*100).."%", --esta_magia.g_dmg
				Loc ["STRING_RESISTED"]..": "..esta_magia.r_dmg, --esta_magia.resisted.amt.." / "..
				Loc ["STRING_ABSORBED"]..": "..esta_magia.a_dmg, --esta_magia.absorbed.amt.." / "..
				Loc ["STRING_BLOCKED"]..": "..esta_magia.b_amt.." / "..esta_magia.b_dmg,
				outros_desvios.." / ".._cstr("%.1f", porcentagem_defesas).."%"
				}
		end
		
	--> Erros de Ataque	--habilidade.missType  -- {"ABSORB", "BLOCK", "DEFLECT", "DODGE", "EVADE", "IMMUNE", "MISS", "PARRY", "REFLECT", "RESIST"}
		local miss = esta_magia ["MISS"] or 0
		local parry = esta_magia ["PARRY"] or 0
		local dodge = esta_magia ["DODGE"] or 0
		local erros = miss + parry + dodge
		
		if (erros > 0) then
			local porcentagem_erros = erros/total_hits*100
			data[#data+1] = { 
				erros,
				{["p"] = porcentagem_erros, ["c"] = {0.5, 0.1, 0.1}},
				Loc ["STRING_FAIL_ATTACKS"], 
				Loc ["STRING_MISS"]..": "..miss,
				Loc ["STRING_PARRY"]..": "..parry,
				Loc ["STRING_DODGE"]..": "..dodge,
				"",
				erros.." / ".._cstr("%.1f", porcentagem_erros).."%"
				}
		end

	table.sort (data, function (a, b) return a[1] > b[1] end)
	
	for index, tabela in _ipairs (data) do
		gump:SetaDetalheInfoTexto (index+1, tabela[2], tabela[3], tabela[4], tabela[5], tabela[6], tabela[7], tabela[8])
	end
	
	for i = #data+2, 5 do
		gump:HidaDetalheInfo (i)
	end
	
end

function atributo_damage:MontaTooltipDamageTaken (esta_barra, index)
	
	local aggressor = info.instancia.showing [1]:PegarCombatente (_, esta_barra.nome_inimigo)
	local container = aggressor.spell_tables._ActorTable
	local habilidades = {}

	local total = 0
	
	for spellid, spell in _pairs (container) do 
		for _, actor in _ipairs (spell.targets._ActorTable) do 
			if (actor.nome == self.nome) then
				total = total + actor.total
				habilidades [#habilidades+1] = {spellid, actor.total, actor.nome}
			end
		end
	end

	table.sort (habilidades, function (a, b) return a[2] > b[2] end)
	
	GameTooltip:AddLine (index..". "..esta_barra.nome_inimigo)
	GameTooltip:AddLine (Loc ["STRING_DAMAGE_TAKEN_FROM2"]..":")
	GameTooltip:AddLine (" ")
	
	for index, tabela in _ipairs (habilidades) do
		local nome, rank, icone = _GetSpellInfo (tabela[1])
		if (index < 8) then
			GameTooltip:AddDoubleLine (index..". |T"..icone..":0|t "..nome, _detalhes:comma_value (tabela[2]).." (".._cstr("%.1f", tabela[2]/total*100).."%)", 1, 1, 1, 1, 1, 1)
			--GameTooltip:AddTexture (icone)
		else
			GameTooltip:AddDoubleLine (index..". "..nome, _detalhes:comma_value (tabela[2]).." (".._cstr("%.1f", tabela[2]/total*100).."%)", .65, .65, .65, .65, .65, .65)
		end
	end
	
	return true
	--GameTooltip:AddDoubleLine (meus_danos[i][4][1]..": ", meus_danos[i][2].." (".._cstr("%.1f", meus_danos[i][3]).."%)", 1, 1, 1, 1, 1, 1)
	
end

function atributo_damage:MontaTooltipAlvos (esta_barra, index)
	-- eu ja sei quem é o alvo a mostrar os detalhes
	-- dar foreach no container de habilidades -- pegar os alvos da habilidade -- e ver se dentro do container tem o meu alvo.
	
	local inimigo = esta_barra.nome_inimigo
	local container = self.spell_tables._ActorTable
	local habilidades = {}
	local total = self.total_without_pet
	
	for spellid, tabela in _pairs (container) do
		--> tabela = classe_damage_habilidade
		local alvos = tabela.targets._ActorTable
		for _, tabela in _ipairs (alvos) do
			--> tabela = classe_target
			if (tabela.nome == inimigo) then
				habilidades [#habilidades+1] = {spellid, tabela.total}
			end
		end
	end
	
	table.sort (habilidades, function (a, b) return a[2] > b[2] end)
	
	GameTooltip:AddLine (index..". "..inimigo)
	GameTooltip:AddLine (Loc ["STRING_DAMAGE_FROM"]..":")
	GameTooltip:AddLine (" ")
	
	for index, tabela in _ipairs (habilidades) do
		local nome, rank, icone = _GetSpellInfo (tabela[1])
		if (index < 8) then
			GameTooltip:AddDoubleLine (index..". |T"..icone..":0|t "..nome, _detalhes:comma_value (tabela[2]).." (".._cstr("%.1f", tabela[2]/total*100).."%)", 1, 1, 1, 1, 1, 1)
			--GameTooltip:AddTexture (icone)
		else
			GameTooltip:AddDoubleLine (index..". "..nome, _detalhes:comma_value (tabela[2]).." (".._cstr("%.1f", tabela[2]/total*100).."%)", .65, .65, .65, .65, .65, .65)
		end
	end
	
	return true
	--GameTooltip:AddDoubleLine (meus_danos[i][4][1]..": ", meus_danos[i][2].." (".._cstr("%.1f", meus_danos[i][3]).."%)", 1, 1, 1, 1, 1, 1)
	
end

--controla se o dps do jogador esta travado ou destravado
function atributo_damage:Iniciar (iniciar)
	if (iniciar == nil) then 
		return self.dps_started --retorna se o dps esta aberto ou fechado para este jogador
	elseif (iniciar) then
		self.dps_started = true
		self:RegistrarNaTimeMachine() --coloca ele da timeMachine
		if (self.shadow) then
			self.shadow.dps_started = true --> isso foi posto recentemente
			--self.shadow:RegistrarNaTimeMachine()
		end
	else
		self.dps_started = false
		self:DesregistrarNaTimeMachine() --retira ele da timeMachine
		if (self.shadow) then
			--self.shadow:DesregistrarNaTimeMachine()
			self.shadow.dps_started = false --> isso foi posto recentemente
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core functions

	--> diminui o total das tabelas do combate
		function atributo_damage:subtract_total (combat_table)
			combat_table.totals [class_type] = combat_table.totals [class_type] - self.total
			if (self.grupo) then
				combat_table.totals_grupo [class_type] = combat_table.totals_grupo [class_type] - self.total
			end
		end
		function atributo_damage:add_total (combat_table)
			combat_table.totals [class_type] = combat_table.totals [class_type] + self.total
			if (self.grupo) then
				combat_table.totals_grupo [class_type] = combat_table.totals_grupo [class_type] + self.total
			end
		end
		
	--> restaura a tabela de last event
		function atributo_damage:r_last_events_table (actor)
			if (not actor) then
				actor = self
			end
			actor.last_events_table = _detalhes:CreateActorLastEventTable()
		end
		
	--> restaura e liga o ator com a sua shadow durante a inicialização (startup function)
		function atributo_damage:r_connect_shadow (actor)
		
			if (not actor) then
				actor = self
			end
	
			--> criar uma shadow desse ator se ainda não tiver uma
				local overall_dano = _detalhes.tabela_overall [1]
				local shadow = overall_dano._ActorTable [overall_dano._NameIndexTable [actor.nome]]
				
				if (not shadow) then 
					shadow = overall_dano:PegarCombatente (actor.serial, actor.nome, actor.flag_original, true)
					shadow.classe = actor.classe
					shadow.grupo = actor.grupo
					shadow.start_time = time() - 3
					shadow.end_time = time()
				end

			--> restaura a meta e indexes ao ator
				_detalhes.refresh:r_atributo_damage (actor, shadow)
			
			--> tempo decorrido (captura de dados)
				if (actor.end_time) then
					local tempo = (actor.end_time or time()) - actor.start_time
					shadow.start_time = shadow.start_time - tempo
				end
				
			--> total de dano (captura de dados)
				shadow.total = shadow.total + actor.total				
			--> total de dano sem o pet (captura de dados)
				shadow.total_without_pet = shadow.total_without_pet + actor.total_without_pet
			--> total de dano que o ator sofreu (captura de dados)
				shadow.damage_taken = shadow.damage_taken + actor.damage_taken
			--> total do friendly fire causado
				shadow.friendlyfire_total = shadow.friendlyfire_total + actor.friendlyfire_total

			--> total no combate overall (captura de dados)
				_detalhes.tabela_overall.totals[1] = _detalhes.tabela_overall.totals[1] + actor.total
				if (actor.grupo) then
					_detalhes.tabela_overall.totals_grupo[1] = _detalhes.tabela_overall.totals_grupo[1] + actor.total
				end
				
			--> copia o damage_from (captura de dados)
				for nome, _ in _pairs (actor.damage_from) do 
					shadow.damage_from [nome] = true
				end
			
			--> copia o container de alvos (captura de dados)
				for index, alvo in _ipairs (actor.targets._ActorTable) do 
					--> cria e soma o valor do total
					local alvo_shadow = shadow.targets:PegarCombatente (nil, alvo.nome, nil, true)
					alvo_shadow.total = alvo_shadow.total + alvo.total
					--> refresh no alvo
					_detalhes.refresh:r_alvo_da_habilidade (alvo, shadow.targets)
				end
				
			--> copia o container de habilidades (captura de dados)
				for spellid, habilidade in _pairs (actor.spell_tables._ActorTable) do 
					--> cria e soma o valor
					local habilidade_shadow = shadow.spell_tables:PegaHabilidade (spellid, true, nil, true)
					--> refresh e soma os valores dos alvos
					for index, alvo in _ipairs (habilidade.targets._ActorTable) do 
						--> cria e soma o valor do total
						local alvo_shadow = habilidade_shadow.targets:PegarCombatente (nil, alvo.nome, nil, true)
						alvo_shadow.total = alvo_shadow.total + alvo.total
						--> refresh no alvo da habilidade
						_detalhes.refresh:r_alvo_da_habilidade (alvo, habilidade_shadow.targets)
					end
					--> soma todos os demais valores
					for key, value in _pairs (habilidade) do 
						if (_type (value) == "number") then
							if (key ~= "id") then
								if (not habilidade_shadow [key]) then 
									habilidade_shadow [key] = 0
								end
								habilidade_shadow [key] = habilidade_shadow [key] + value
							end
						end
					end
					
					--> refresh na habilidade
					_detalhes.refresh:r_habilidade_dano (habilidade, shadow.spell_tables)
				end
				
			--> copia o container de friendly fire (captura de dados)
				for index, friendlyFire in _ipairs (actor.friendlyfire._ActorTable) do 
					--> cria ou pega a shadow
					local friendlyFire_shadow = shadow.friendlyfire:PegarCombatente (nil, friendlyFire.nome, nil, true)
					--> refresh na tabela e no container de habilidades
					_setmetatable (friendlyFire, _detalhes)
					friendlyFire.shadow = friendlyFire_shadow
					--> soma o total
					friendlyFire_shadow.total = friendlyFire_shadow.total + friendlyFire.total

					for spellid, habilidade in _pairs (friendlyFire.spell_tables._ActorTable) do
						--> cria ou pega a habilidade no container de habilidade
						local habilidade_shadow = friendlyFire_shadow.spell_tables:PegaHabilidade (spellid, true, nil, true)
						--> soma os valores
						habilidade_shadow.counter = habilidade_shadow.counter + habilidade.counter
						habilidade_shadow.total = habilidade_shadow.total + habilidade.total
						--> refresh na habilidade
						_detalhes.refresh:r_habilidade_dano (habilidade, friendlyFire_shadow.spell_tables)
					end
					--> refresh na meta e indexes
					_detalhes.refresh:r_container_habilidades (friendlyFire.spell_tables, friendlyFire_shadow.spell_tables)
				end
			
			return shadow
		end

function atributo_damage:FF_funcao_de_criacao (_, _, link)
	local tabela = _setmetatable ({}, _detalhes) --> mudei de _detalhes para atributo_damage
	tabela.total = 0
	tabela.spell_tables = container_habilidades:NovoContainer (container_damage)
	if (link) then
		tabela.spell_tables.shadow = link.spell_tables
	end
	return tabela
end

function atributo_damage:ColetarLixo (lastevent)
	return _detalhes:ColetarLixo (class_type, lastevent)
end

function _detalhes.refresh:r_atributo_damage (este_jogador, shadow)

	--> restaura metas do ator
		_setmetatable (este_jogador, _detalhes.atributo_damage)
		este_jogador.__index = _detalhes.atributo_damage
	--> atribui a shadow a ele
		este_jogador.shadow = shadow
	--> restaura as metas dos container de alvos, habilidades e ff
		_detalhes.refresh:r_container_combatentes (este_jogador.targets, shadow.targets)
		_detalhes.refresh:r_container_combatentes (este_jogador.friendlyfire, shadow.friendlyfire)
		_detalhes.refresh:r_container_habilidades (este_jogador.spell_tables, shadow.spell_tables)
end

function _detalhes.clear:c_atributo_damage (este_jogador)
	--este_jogador.__index = {}
	este_jogador.__index = nil
	este_jogador.shadow = nil
	este_jogador.links = nil
	este_jogador.minha_barra = nil
	
	_detalhes.clear:c_container_combatentes (este_jogador.targets)
	_detalhes.clear:c_container_habilidades (este_jogador.spell_tables)
	_detalhes.clear:c_atributo_damage_FF (este_jogador.friendlyfire)
end

function _detalhes.clear:c_atributo_damage_FF (container)
	_detalhes.clear:c_container_combatentes (container)
	
	for _, _tabela in _ipairs (container._ActorTable) do 
		_tabela.__index = {}
		_tabela.shadow = nil
		
		local habilidades = _tabela.spell_tables
		_detalhes.clear:c_container_habilidades (habilidades)
		
		for _, habilidade in _pairs (habilidades._ActorTable) do
			_detalhes.clear:c_habilidade_dano (habilidade)
			--pode parar aqui, o container de alvos não é usado no friendly fire
		end
	end	
end

atributo_damage.__add = function (tabela1, tabela2)

	--> tempo decorrido
		local tempo = (tabela2.end_time or time()) - tabela2.start_time
		tabela1.start_time = tabela1.start_time - tempo
	
	--> total de dano
		tabela1.total = tabela1.total + tabela2.total
	--> total de dano sem o pet
		tabela1.total_without_pet = tabela1.total_without_pet + tabela2.total_without_pet
	--> total de dano que o cara levou
		tabela1.damage_taken = tabela1.damage_taken + tabela2.damage_taken
	--> total do friendly fire causado
		tabela1.friendlyfire_total = tabela1.friendlyfire_total + tabela2.friendlyfire_total

	--> soma o damage_from
		for nome, _ in _pairs (tabela2.damage_from) do 
			tabela1.damage_from [nome] = true
		end
	
	--> soma os containers de alvos
		for index, alvo in _ipairs (tabela2.targets._ActorTable) do 
			--> pega o alvo no ator
			local alvo_tabela1 = tabela1.targets:PegarCombatente (nil, alvo.nome, nil, true)
			--> soma o valor
			alvo_tabela1.total = alvo_tabela1.total + alvo.total
		end
		
	--> soma o container de habilidades
		for spellid, habilidade in _pairs (tabela2.spell_tables._ActorTable) do 
			--> pega a habilidade no primeiro ator
			local habilidade_tabela1 = tabela1.spell_tables:PegaHabilidade (spellid, true, "SPELL_DAMAGE", false)
			--> soma os alvos
			for index, alvo in _ipairs (habilidade.targets._ActorTable) do 
				local alvo_tabela1 = habilidade_tabela1.targets:PegarCombatente (nil, alvo.nome, nil, true)
				alvo_tabela1.total = alvo_tabela1.total + alvo.total
			end
			--> soma os valores da habilidade
			for key, value in _pairs (habilidade) do 
				if (_type (value) == "number") then
					if (key ~= "id") then
						if (not habilidade_tabela1 [key]) then 
							habilidade_tabela1 [key] = 0
						end
						habilidade_tabela1 [key] = habilidade_tabela1 [key] + value
					end
				end
			end
		end
	
	--> soma o container de friendly fire
		for index, friendlyFire in _ipairs (tabela2.friendlyfire._ActorTable) do 
			--> pega o ator ff no ator principal
			local friendlyFire_tabela1 = tabela1.friendlyfire:PegarCombatente (nil, friendlyFire.nome, nil, true)
			--> soma o total
			friendlyFire_tabela1.total = friendlyFire_tabela1.total + friendlyFire.total
			--> soma as habilidades
			for spellid, habilidade in _pairs (friendlyFire.spell_tables._ActorTable) do
				local habilidade_tabela1 = friendlyFire_tabela1.spell_tables:PegaHabilidade (spellid, true, nil, false)
				habilidade_tabela1.counter = habilidade_tabela1.counter + habilidade.counter
				habilidade_tabela1.total = habilidade_tabela1.total + habilidade.total
			end
		end

	return tabela1
end

atributo_damage.__sub = function (tabela1, tabela2)

	--> tempo decorrido
		local tempo = (tabela2.end_time or time()) - tabela2.start_time
		tabela1.start_time = tabela1.start_time + tempo
	
	--> total de dano
		tabela1.total = tabela1.total - tabela2.total
	--> total de dano sem o pet
		tabela1.total_without_pet = tabela1.total_without_pet - tabela2.total_without_pet
	--> total de dano que o cara levou
		tabela1.damage_taken = tabela1.damage_taken - tabela2.damage_taken
	--> total do friendly fire causado
		tabela1.friendlyfire_total = tabela1.friendlyfire_total - tabela2.friendlyfire_total
		
	--> reduz os containers de alvos
		for index, alvo in _ipairs (tabela2.targets._ActorTable) do 
			--> pega o alvo no ator
			local alvo_tabela1 = tabela1.targets:PegarCombatente (nil, alvo.nome, nil, true)
			--> subtrai o valor
			alvo_tabela1.total = alvo_tabela1.total - alvo.total
		end
		
	--> reduz o container de habilidades
		for spellid, habilidade in _pairs (tabela2.spell_tables._ActorTable) do 
			--> pega a habilidade no primeiro ator
			local habilidade_tabela1 = tabela1.spell_tables:PegaHabilidade (spellid, true, "SPELL_DAMAGE", false)
			--> soma os alvos
			for index, alvo in _ipairs (habilidade.targets._ActorTable) do 
				local alvo_tabela1 = habilidade_tabela1.targets:PegarCombatente (nil, alvo.nome, nil, true)
				alvo_tabela1.total = alvo_tabela1.total - alvo.total
			end
			--> subtrai os valores da habilidade
			for key, value in _pairs (habilidade) do 
				if (_type (value) == "number") then
					if (key ~= "id") then
						if (not habilidade_tabela1 [key]) then 
							habilidade_tabela1 [key] = 0
						end
						habilidade_tabela1 [key] = habilidade_tabela1 [key] - value
					end
				end
			end
		end
		
	--> reduz o container de friendly fire
		for index, friendlyFire in _ipairs (tabela2.friendlyfire._ActorTable) do 
			--> pega o ator ff no ator principal
			local friendlyFire_tabela1 = tabela1.friendlyfire:PegarCombatente (nil, friendlyFire.nome, nil, true)
			--> soma o total
			friendlyFire_tabela1.total = friendlyFire_tabela1.total - friendlyFire.total
			--> soma as habilidades
			for spellid, habilidade in _pairs (friendlyFire.spell_tables._ActorTable) do
				local habilidade_tabela1 = friendlyFire_tabela1.spell_tables:PegaHabilidade (spellid, true, nil, false)
				habilidade_tabela1.counter = habilidade_tabela1.counter - habilidade.counter
				habilidade_tabela1.total = habilidade_tabela1.total - habilidade.total
			end
		end
	
	return tabela1
end

		--local cor = self.cor
		
		--esta_barra.statusbar:SetStatusBarColor (cor[1], cor[2], cor[3], cor[4])
		
		--print (cor[1], cor[2], cor[3])
		--esta_barra.textura:SetVertexColor (cor[1], cor[2], cor[3], cor[4])
		
		--local grayscale = (cor[1] + cor[2] + cor[3]) / 3.0 -- lightness
		
		-- local grayscale = (_math_max (cor[1], cor[2], cor[3]) + _math_min (cor[1], cor[2], cor[3])) / 2 -- average
		-- local grayscale = cor[1]*0.21 + cor[2]*0.71  + cor[3]*0.07
		--(max(R, G, B) + min(R, G, B)) / 2
