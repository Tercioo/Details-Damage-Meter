--[[ Esta classe irá abrigar todo a cura de uma habilidade
Parents:
	addon -> combate atual -> cura -> container de jogadores -> esta classe

]]

--lua locals
local _cstr = string.format
local _math_floor = math.floor
local _setmetatable = setmetatable
local _pairs = pairs
local _ipairs = ipairs
local _unpack = unpack
local _type = type
local _table_sort = table.sort
local _cstr = string.format
local _table_insert = table.insert
local _bit_band = bit.band
local _math_min = math.min
--api locals
local _GetSpellInfo = _detalhes.getspellinfo
local _IsInRaid = IsInRaid
local _IsInGroup = IsInGroup

local _detalhes = 		_G._detalhes
local _

local AceLocale = LibStub ("AceLocale-3.0")
local Loc = AceLocale:GetLocale ( "Details" )

local gump = 			_detalhes.gump

local alvo_da_habilidade = 	_detalhes.alvo_da_habilidade
local container_habilidades = 	_detalhes.container_habilidades
local container_combatentes =	_detalhes.container_combatentes
local atributo_heal =		_detalhes.atributo_heal
local habilidade_cura = 		_detalhes.habilidade_cura

local container_playernpc = _detalhes.container_type.CONTAINER_PLAYERNPC
local container_heal = _detalhes.container_type.CONTAINER_HEAL_CLASS
local container_heal_target = _detalhes.container_type.CONTAINER_HEALTARGET_CLASS

local modo_ALONE = _detalhes.modos.alone
local modo_GROUP = _detalhes.modos.group
local modo_ALL = _detalhes.modos.all

local class_type = _detalhes.atributos.cura

local DATA_TYPE_START = _detalhes._detalhes_props.DATA_TYPE_START
local DATA_TYPE_END = _detalhes._detalhes_props.DATA_TYPE_END

local DFLAG_player = _detalhes.flags.player
local DFLAG_group = _detalhes.flags.in_group
local DFLAG_player_group = _detalhes.flags.player_in_group

local div_abre = _detalhes.divisores.abre
local div_fecha = _detalhes.divisores.fecha
local div_lugar = _detalhes.divisores.colocacao

local ToKFunctions = _detalhes.ToKFunctions
local SelectedToKFunction = ToKFunctions [1]
local UsingCustomRightText = false

local FormatTooltipNumber = ToKFunctions [8]
local TooltipMaximizedMethod = 1

local info = _detalhes.janela_info
local keyName

function atributo_heal:NovaTabela (serial, nome, link)

	--> constructor
	local _new_healActor = {

		tipo = class_type, --> atributo 2 = cura
		
		total = 0,
		totalover = 0,
		totalabsorb = 0,
		custom = 0,
		
		total_without_pet = 0,
		totalover_without_pet = 0,
		
		healing_taken = 0, --> total de cura que este jogador recebeu
		healing_from = {}, --> armazena os nomes que deram cura neste jogador

		iniciar_hps = false,  --> dps_started
		last_event = 0,
		on_hold = false,
		delay = 0,
		last_value = nil, --> ultimo valor que este jogador teve, salvo quando a barra dele é atualizada
		last_hps = 0, --> cura por segundo

		end_time = nil,
		start_time = 0,

		pets = {}, --> nome já formatado: pet nome <owner nome>
		
		heal_enemy = {}, --> quando o jogador cura um inimigo
		heal_enemy_amt = 0,

		--container armazenará os IDs das habilidades usadas por este jogador
		spell_tables = container_habilidades:NovoContainer (container_heal),
		
		--container armazenará os seriais dos alvos que o player aplicou dano
		targets = container_combatentes:NovoContainer (container_heal_target)
	}
	
	_setmetatable (_new_healActor, atributo_heal)
	
	if (link) then --> se não for a shadow
		_new_healActor.last_events_table = _detalhes:CreateActorLastEventTable()
		_new_healActor.last_events_table.original = true
	
		_new_healActor.targets.shadow = link.targets
		_new_healActor.spell_tables.shadow = link.spell_tables
	end
	
	return _new_healActor
end


function _detalhes.SortGroupHeal (container, keyName2)
	keyName = keyName2
	return _table_sort (container, _detalhes.SortKeyGroupHeal)
end

function _detalhes.SortKeyGroupHeal (table1, table2)
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

function _detalhes.SortKeySimpleHeal (table1, table2)
	return table1 [keyName] > table2 [keyName]
end

function _detalhes:ContainerSortHeal (container, amount, keyName2)
	keyName = keyName2
	_table_sort (container,  _detalhes.SortKeySimpleHeal)
	
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

function atributo_heal:ContainerRefreshHps (container, combat_time)

	if (_detalhes.time_type == 2 or not _detalhes:CaptureGet ("heal")) then
		for _, actor in _ipairs (container) do
			if (actor.grupo) then
				actor.last_hps = actor.total / combat_time
			else
				actor.last_hps = actor.total / actor:Tempo()
			end
		end
	else
		for _, actor in _ipairs (container) do
			actor.last_hps = actor.total / actor:Tempo()
		end
	end
	
end

function atributo_heal:ReportSingleDamagePreventedLine (actor, instancia)
	local barra = instancia.barras [actor.minha_barra]

	local reportar = {"Details! " .. Loc ["STRING_ATTRIBUTE_HEAL_PREVENT"].. ": " .. actor.nome} --> localize-me
	for i = 1, GameCooltip:GetNumLines() do 
		local texto_left, texto_right = GameCooltip:GetText (i)
		if (texto_left and texto_right) then 
			texto_left = texto_left:gsub (("|T(.*)|t "), "")
			reportar [#reportar+1] = ""..texto_left.." "..texto_right..""
		end
	end

	return _detalhes:Reportar (reportar, {_no_current = true, _no_inverse = true, _custom = true})
end

function atributo_heal:RefreshWindow (instancia, tabela_do_combate, forcar, exportar)
	
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura

	--> não há barras para mostrar -- not have something to show
	if (#showing._ActorTable < 1) then --> não há barras para mostrar
		--> colocado isso recentemente para fazer as barras de dano sumirem na troca de atributo
		return _detalhes:EsconderBarrasNaoUsadas (instancia, showing)
	end

	--> total
	local total = 0 
	--> top actor #1
	instancia.top = 0
	
	local using_cache = false
	
	local sub_atributo = instancia.sub_atributo --> o que esta sendo mostrado nesta instância
	local conteudo = showing._ActorTable
	local amount = #conteudo
	local modo = instancia.modo
	
	--> pega qual a sub key que será usada
	if (exportar) then
	
		if (_type (exportar) == "boolean") then 
			if (sub_atributo == 1) then --> healing DONE
				keyName = "total"
			elseif (sub_atributo == 2) then --> HPS
				keyName = "last_hps"
			elseif (sub_atributo == 3) then --> overheal
				keyName = "totalover"
			elseif (sub_atributo == 4) then --> healing take
				keyName = "healing_taken"
			elseif (sub_atributo == 5) then --> enemy heal
				keyName = "heal_enemy_amt"
			elseif (sub_atributo == 6) then --> absorbs
				keyName = "totalabsorb"
			end
		else
			keyName = exportar.key
			modo = exportar.modo
		end
	elseif (instancia.atributo == 5) then --> custom
		keyName = "custom"
		total = tabela_do_combate.totals [instancia.customName]
	else	
		if (sub_atributo == 1) then --> healing DONE
			keyName = "total"
		elseif (sub_atributo == 2) then --> HPS
			keyName = "last_hps"
		elseif (sub_atributo == 3) then --> overheal
			keyName = "totalover"
		elseif (sub_atributo == 4) then --> healing take
			keyName = "healing_taken"
		elseif (sub_atributo == 5) then --> enemy heal
			keyName = "heal_enemy_amt"
		elseif (sub_atributo == 6) then --> absorbs
			keyName = "totalabsorb"
		end
	end

	if (instancia.atributo == 5) then --> custom
		--> faz o sort da categoria e retorna o amount corrigido
		amount = _detalhes:ContainerSortHeal (conteudo, amount, keyName)
		
		--> grava o total
		instancia.top = conteudo[1][keyName]
	
	elseif (instancia.modo == modo_ALL or sub_atributo == 5) then --> mostrando ALL
	
		amount = _detalhes:ContainerSortHeal (conteudo, amount, keyName)

		--> pega o total ja aplicado na tabela do combate
		total = tabela_do_combate.totals [class_type]
		
		--> grava o total
		instancia.top = conteudo[1][keyName]
		
	elseif (instancia.modo == modo_GROUP) then --> mostrando GROUP
	
		if (_detalhes.in_combat and instancia.segmento == 0 and not exportar) then
			using_cache = true
		end
		
		if (using_cache) then
		
			conteudo = _detalhes.cache_healing_group

			if (sub_atributo == 2) then --> hps
				local combat_time = instancia.showing:GetCombatTime()
				atributo_heal:ContainerRefreshHps (conteudo, combat_time)
			end
			
			if (#conteudo < 1) then
				return _detalhes:EsconderBarrasNaoUsadas (instancia, showing)
			end
		
			_detalhes:ContainerSortHeal (conteudo, nil, keyName)
		
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
			if (sub_atributo == 2) then --> hps
				local combat_time = instancia.showing:GetCombatTime()
				atributo_heal:ContainerRefreshHps (conteudo, combat_time)
			end
			--_table_sort (conteudo, _detalhes.SortKeyGroup)
			_detalhes.SortGroupHeal (conteudo, keyName)
		end
		
		--_table_sort (conteudo, _detalhes.SortKeyGroup)
		
		
		--[[_table_sort (conteudo, function (a, b)
				if (a.grupo and b.grupo) then
					return a[keyName] > b[keyName]
				elseif (a.grupo and not b.grupo) then
					return true
				elseif (not a.grupo and b.grupo) then
					return false
				else
					return a[keyName] > b[keyName]
				end
			end)--]]

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
	
	--> refaz o mapa do container
	--> se for cache não precisa remapear
	showing:remapear()

	if (exportar) then 
		return total, keyName, instancia.top
	end
	
	if (amount < 1) then --> não há barras para mostrar
		instancia:EsconderScrollBar()
		return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
	end

	--estra mostrando ALL então posso seguir o padrão correto? primeiro, atualiza a scroll bar...
	instancia:AtualizarScrollBar (amount)
	
	--depois faz a atualização normal dele através dos iterators
	local qual_barra = 1
	local barras_container = instancia.barras --> evita buscar N vezes a key .barras dentro da instância
	local percentage_type = instancia.row_info.percent_type
	
	--print (sub_atributo, total, keyName)
	
	local combat_time = instancia.showing:GetCombatTime()
	UsingCustomRightText = instancia.row_info.textR_enable_custom_text
	
	local use_total_bar = false
	if (instancia.total_bar.enabled) then
	
		use_total_bar = true
		
		if (instancia.total_bar.only_in_group and (not _IsInGroup() and not _IsInRaid())) then
			use_total_bar = false
		end
		
		if (sub_atributo > 6) then --enemies, frags, void zones
			use_total_bar = false
		end
		
	end
	
	if (instancia.bars_sort_direction == 1) then --top to bottom

		if (use_total_bar and instancia.barraS[1] == 1) then
			qual_barra = 2
			local iter_last = instancia.barraS[2]
			if (iter_last == instancia.rows_fit_in_window) then
				iter_last = iter_last - 1
			end
			
			local row1 = barras_container [1]
			row1.minha_tabela = nil
			row1.texto_esquerdo:SetText (Loc ["STRING_TOTAL"])
			row1.texto_direita:SetText (_detalhes:ToK2 (total) .. " (" .. _detalhes:ToK (total / combat_time) .. ")")
			
			row1.statusbar:SetValue (100)
			local r, b, g = unpack (instancia.total_bar.color)
			row1.textura:SetVertexColor (r, b, g)
			
			row1.icone_classe:SetTexture (instancia.total_bar.icon)
			row1.icone_classe:SetTexCoord (0.0625, 0.9375, 0.0625, 0.9375)
			
			gump:Fade (row1, "out")
			
			for i = instancia.barraS[1], iter_last, 1 do --> vai atualizar só o range que esta sendo mostrado
				conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type) --> instância, index, total, valor da 1º barra
				qual_barra = qual_barra+1
			end	
		else
		
			if (use_total_bar and instancia.barraS[1] == 1) then
			
				qual_barra = 2
				local iter_last = instancia.barraS[2]
				if (iter_last == instancia.rows_fit_in_window) then
					iter_last = iter_last - 1
				end
				
				local row1 = barras_container [1]
				row1.minha_tabela = nil
				row1.texto_esquerdo:SetText (Loc ["STRING_TOTAL"])
				row1.texto_direita:SetText (_detalhes:ToK2 (total) .. " (" .. _detalhes:ToK (total / combat_time) .. ")")
				
				row1.statusbar:SetValue (100)
				local r, b, g = unpack (instancia.total_bar.color)
				row1.textura:SetVertexColor (r, b, g)
				
				row1.icone_classe:SetTexture (instancia.total_bar.icon)
				row1.icone_classe:SetTexCoord (0.0625, 0.9375, 0.0625, 0.9375)
				
				gump:Fade (row1, "out")
				
				for i = iter_last, instancia.barraS[1], -1 do --> vai atualizar só o range que esta sendo mostrado
					conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type) --> instância, index, total, valor da 1º barra
					qual_barra = qual_barra+1
				end
			else
				for i = instancia.barraS[1], instancia.barraS[2], 1 do --> vai atualizar só o range que esta sendo mostrado
					conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type) --> instância, index, total, valor da 1º barra
					qual_barra = qual_barra+1
				end
			end
		end
		
	elseif (instancia.bars_sort_direction == 2) then --bottom to top
		for i = instancia.barraS[2], instancia.barraS[1], 1 do --> vai atualizar só o range que esta sendo mostrado
			conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type) --> instância, index, total, valor da 1º barra
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
			for i = qual_barra, instancia.rows_fit_in_window  do
				gump:Fade (instancia.barras [i], "in", 0.3)
			end
		end
	end

	-- showing.need_refresh = false
	return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
	
end

function atributo_heal:Custom (_customName, _combat, sub_atributo, spell, alvo)
	local _Skill = self.spell_tables._ActorTable [tonumber (spell)]
	if (_Skill) then
		local spellName = _GetSpellInfo (tonumber (spell))
		local SkillTargets = _Skill.targets._ActorTable
		
		for _, TargetActor in _ipairs (SkillTargets) do 
			local TargetActorSelf = _combat (class_type, TargetActor.nome)
			if (TargetActorSelf) then
				TargetActorSelf.custom = TargetActor.total + TargetActorSelf.custom
				_combat.totals [_customName] = _combat.totals [_customName] + TargetActor.total
			end
		end
	end
end

local actor_class_color_r, actor_class_color_g, actor_class_color_b

--function atributo_heal:AtualizaBarra (instancia, qual_barra, lugar, total, sub_atributo, forcar)
function atributo_heal:AtualizaBarra (instancia, barras_container, qual_barra, lugar, total, sub_atributo, forcar, keyName, combat_time, percentage_type)

	local esta_barra = instancia.barras[qual_barra] --> pega a referência da barra na janela
	
	if (not esta_barra) then
		print ("DEBUG: problema com <instancia.esta_barra> "..qual_barra.." "..lugar)
		return
	end
	
	local tabela_anterior = esta_barra.minha_tabela
	
	esta_barra.minha_tabela = self --grava uma referência dessa classe de dano na barra
	self.minha_barra = esta_barra --> salva uma referência da barra no objeto do jogador
	
	esta_barra.colocacao = lugar --> salva na barra qual a colocação dela.
	self.colocacao = lugar --> salva qual a colocação do jogador no objeto dele
	
	local healing_total = self.total --> total de dano que este jogador deu
	local hps
	
	--local porcentagem = self [keyName] / total * 100
	local porcentagem
	local esta_porcentagem
	
	if (percentage_type == 1) then
		porcentagem = _cstr ("%.1f", self [keyName] / total * 100)
	elseif (percentage_type == 2) then
		porcentagem = _cstr ("%.1f", self [keyName] / instancia.top * 100)
	end

	if ((_detalhes.time_type == 2 and self.grupo) or (not _detalhes:CaptureGet ("heal") and not _detalhes:CaptureGet ("aura")) or not self.shadow) then
		if (not self.shadow and combat_time == 0) then
			local p = _detalhes.tabela_vigente (2, self.nome)
			if (p) then
				local t = p:Tempo()
				hps = healing_total / t
				self.last_hps = hps
			else
				hps = healing_total / combat_time
				self.last_hps = hps
			end
		else
			hps = healing_total / combat_time
			self.last_hps = hps
		end
	else
		if (not self.on_hold) then
			hps = healing_total/self:Tempo() --calcula o dps deste objeto
			self.last_hps = hps --salva o dps dele
		else
			hps = self.last_hps
			
			if (hps == 0) then --> não calculou o dps dele ainda mas entrou em standby
				hps = healing_total/self:Tempo()
				self.last_hps = hps
			end
		end
	end
	
	-- >>>>>>>>>>>>>>> texto da direita
	if (instancia.atributo == 5) then --> custom
		esta_barra.texto_direita:SetText (_detalhes:ToK (self.custom) .. " (" .. porcentagem .. "%)") --seta o texto da direita
		esta_porcentagem = _math_floor ((self.custom/instancia.top) * 100) --> determina qual o tamanho da barra
	else	
		if (sub_atributo == 1) then --> mostrando healing done
		
			hps = _math_floor (hps)
			local formated_heal = SelectedToKFunction (_, healing_total)
			local formated_hps = SelectedToKFunction (_, hps)
		
			if (UsingCustomRightText) then
				esta_barra.texto_direita:SetText (instancia.row_info.textR_custom_text:ReplaceData (formated_heal, formated_hps, porcentagem, self))
			else
				esta_barra.texto_direita:SetText (formated_heal .." (" .. formated_hps .. ", " .. porcentagem .. "%)") --seta o texto da direita
			end
			esta_porcentagem = _math_floor ((healing_total/instancia.top) * 100) --> determina qual o tamanho da barra
			
		elseif (sub_atributo == 2) then --> mostrando hps
		
			hps = _math_floor (hps)
			local formated_heal = SelectedToKFunction (_, healing_total)
			local formated_hps = SelectedToKFunction (_, hps)
			
			if (UsingCustomRightText) then
				esta_barra.texto_direita:SetText (instancia.row_info.textR_custom_text:ReplaceData (formated_hps, formated_heal, porcentagem, self))
			else			
				esta_barra.texto_direita:SetText (formated_hps .. " (" .. formated_heal .. ", " .. porcentagem .. "%)") --seta o texto da direita
			end
			esta_porcentagem = _math_floor ((hps/instancia.top) * 100) --> determina qual o tamanho da barra
			
		elseif (sub_atributo == 3) then --> mostrando overall
		
			local formated_overheal = SelectedToKFunction (_, self.totalover)
			
			if (UsingCustomRightText) then
				esta_barra.texto_direita:SetText (instancia.row_info.textR_custom_text:ReplaceData (formated_overheal, "", porcentagem, self))
			else
				esta_barra.texto_direita:SetText (formated_overheal .." (" .. porcentagem .. "%)") --seta o texto da direita --_cstr("%.1f", dps) .. " - ".. DPS do damage taken não será possivel correto?
			end
			esta_porcentagem = _math_floor ((self.totalover/instancia.top) * 100) --> determina qual o tamanho da barra
			
		elseif (sub_atributo == 4) then --> mostrando healing take
		
			local formated_healtaken = SelectedToKFunction (_, self.healing_taken)
			
			if (UsingCustomRightText) then
				esta_barra.texto_direita:SetText (instancia.row_info.textR_custom_text:ReplaceData (formated_healtaken, "", porcentagem, self))
			else		
				esta_barra.texto_direita:SetText (formated_healtaken .. " (" .. porcentagem .. "%)") --seta o texto da direita --_cstr("%.1f", dps) .. " - ".. DPS do damage taken não será possivel correto?
			end
			esta_porcentagem = _math_floor ((self.healing_taken/instancia.top) * 100) --> determina qual o tamanho da barra
		
		elseif (sub_atributo == 5) then --> mostrando enemy heal
		
			local formated_enemyheal = SelectedToKFunction (_, self.heal_enemy_amt)
		
			if (UsingCustomRightText) then
				esta_barra.texto_direita:SetText (instancia.row_info.textR_custom_text:ReplaceData (formated_enemyheal, "", porcentagem, self))
			else
				esta_barra.texto_direita:SetText (formated_enemyheal .. " (" .. porcentagem .. "%)") --seta o texto da direita --_cstr("%.1f", dps) .. " - ".. DPS do damage taken não será possivel correto?
			end
			esta_porcentagem = _math_floor ((self.heal_enemy_amt/instancia.top) * 100) --> determina qual o tamanho da barra
			
		elseif (sub_atributo == 6) then --> mostrando damage prevented
		
			local formated_absorbs = SelectedToKFunction (_, self.totalabsorb)
		
			if (UsingCustomRightText) then
				esta_barra.texto_direita:SetText (instancia.row_info.textR_custom_text:ReplaceData (formated_absorbs, "", porcentagem, self))
			else
				esta_barra.texto_direita:SetText (formated_absorbs .. " (" .. porcentagem .. "%)") --seta o texto da direita --_cstr("%.1f", dps) .. " - ".. DPS do damage taken não será possivel correto?
			end
			esta_porcentagem = _math_floor ((self.totalabsorb/instancia.top) * 100) --> determina qual o tamanho da barra
		end
	end
	
	if (esta_barra.mouse_over and not instancia.baseframe.isMoving) then --> precisa atualizar o tooltip
		gump:UpdateTooltip (qual_barra, esta_barra, instancia)
	end

	if (self.owner) then
		actor_class_color_r, actor_class_color_g, actor_class_color_b = _unpack (_detalhes.class_colors [self.owner.classe])
	else
		actor_class_color_r, actor_class_color_g, actor_class_color_b = _unpack (_detalhes.class_colors [self.classe])
	end	
	
	return self:RefreshBarra2 (esta_barra, instancia, tabela_anterior, forcar, esta_porcentagem, qual_barra, barras_container)	
end

function atributo_heal:RefreshBarra2 (esta_barra, instancia, tabela_anterior, forcar, esta_porcentagem, qual_barra, barras_container)
	
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
			
			if (instancia.row_info.texture_class_colors) then
				esta_barra.textura:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
			end
			if (instancia.row_info.texture_background_class_color) then
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

function atributo_heal:RefreshBarra (esta_barra, instancia, from_resize)
	
	if (from_resize) then
		if (self.owner) then
			actor_class_color_r, actor_class_color_g, actor_class_color_b = _unpack (_detalhes.class_colors [self.owner.classe])
		else
			actor_class_color_r, actor_class_color_g, actor_class_color_b = _unpack (_detalhes.class_colors [self.classe])
		end
	end
	
	if (instancia.row_info.texture_class_colors) then
		esta_barra.textura:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
	end
	if (instancia.row_info.texture_background_class_color) then
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
		esta_barra.icone_classe:SetTexture (instancia.row_info.icon_file)
		esta_barra.icone_classe:SetTexCoord (0.25, 0.49609375, 0.75, 1)
		esta_barra.icone_classe:SetVertexColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)

	else
		esta_barra.icone_classe:SetTexture (instancia.row_info.icon_file)
		esta_barra.icone_classe:SetTexCoord (_unpack (CLASS_ICON_TCOORDS [self.classe])) --very slow method
		esta_barra.icone_classe:SetVertexColor (1, 1, 1)
	end
	
	if (self.enemy) then
		if (_detalhes.faction_against == "Horde") then
			esta_barra.texto_esquerdo:SetText (esta_barra.colocacao..". |TInterface\\AddOns\\Details\\images\\icones_barra:" .. instancia.row_info.height .. ":" .. instancia.row_info.height .. ":0:0:256:32:0:32:0:32|t"..self.displayName) --seta o texto da esqueda -- HORDA
		else
			esta_barra.texto_esquerdo:SetText (esta_barra.colocacao..". |TInterface\\AddOns\\Details\\images\\icones_barra:" .. instancia.row_info.height .. ":" .. instancia.row_info.height .. ":0:0:256:32:32:64:0:32|t"..self.displayName) --seta o texto da esqueda -- ALLY
		end
		
		if (instancia.row_info.texture_class_colors) then
			esta_barra.textura:SetVertexColor (240/255, 0, 5/255, 1)
		end
	else
		esta_barra.texto_esquerdo:SetText (esta_barra.colocacao..". "..self.displayName) --seta o texto da esqueda
	end
	
	if (instancia.row_info.textL_class_colors) then
		esta_barra.texto_esquerdo:SetTextColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
	end
	if (instancia.row_info.textR_class_colors) then
		esta_barra.texto_direita:SetTextColor (actor_class_color_r, actor_class_color_g, actor_class_color_b)
	end
	
	esta_barra.texto_esquerdo:SetSize (esta_barra:GetWidth() - esta_barra.texto_direita:GetStringWidth() - 20, 15)
	
end

--------------------------------------------- // TOOLTIPS // ---------------------------------------------


---------> TOOLTIPS BIFURCAÇÃO
function atributo_heal:ToolTip (instancia, numero, barra, keydown)
	--> seria possivel aqui colocar o icone da classe dele?

	if (instancia.atributo == 5) then --> custom
		return self:TooltipForCustom (barra)
	else
		--GameTooltip:ClearLines()
		--GameTooltip:AddLine (barra.colocacao..". "..self.nome)
		if (instancia.sub_atributo <= 3) then --> healing done, HPS or Overheal
			return self:ToolTip_HealingDone (instancia, numero, barra, keydown)
		elseif (instancia.sub_atributo == 6) then --> healing done, HPS or Overheal	
			return self:ToolTip_HealingDone (instancia, numero, barra, keydown)
		elseif (instancia.sub_atributo == 4) then --> healing taken
			return self:ToolTip_HealingTaken (instancia, numero, barra, keydown)
		end
	end
end
--> tooltip locals
local r, g, b
local headerColor = "yellow"
local barAlha = .6
local key_overlay = {1, 1, 1, .1}
local key_overlay_press = {1, 1, 1, .2}

---------> HEALING TAKEN
function atributo_heal:ToolTip_HealingTaken (instancia, numero, barra, keydown)

	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack (_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack (_detalhes.class_colors [self.classe])
	end

	local curadores = self.healing_from
	local total_curado = self.healing_taken
	
	local tabela_do_combate = instancia.showing
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable
	
	local meus_curadores = {}
	
	for nome, _ in _pairs (curadores) do --> agressores seria a lista de nomes
		local este_curador = showing._ActorTable[showing._NameIndexTable[nome]]
		if (este_curador) then --> checagem por causa do total e do garbage collector que não limpa os nomes que deram dano
			local alvos = este_curador.targets
			local este_alvo = alvos._ActorTable[alvos._NameIndexTable[self.nome]]
			if (este_alvo and este_alvo.total > 0) then
				meus_curadores [#meus_curadores+1] = {nome, este_alvo.total, este_curador.classe}
			end
		end
	end
	
	_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_FROM"], headerColor, r, g, b, #meus_curadores)

	GameCooltip:AddIcon ([[Interface\TUTORIALFRAME\UI-TutorialFrame-LevelUp]], 1, 1, 14, 14, 0.10546875, 0.89453125, 0.05859375, 0.6796875)
	GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)

	local ismaximized = false
	
	if (keydown == "shift" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 3) then
		GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, 24, 12, 0, 1, 0, 0.640625, key_overlay_press)
		GameCooltip:AddStatusBar (100, 1, r, g, b, 1)
		ismaximized = true
	else
		GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, 24, 12, 0, 1, 0, 0.640625, key_overlay)
		GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
	end

	_table_sort (meus_curadores, function (a, b) return a[2] > b[2] end)
	local max = #meus_curadores
	if (max > 6) then
		max = 6
	end
	
	if (ismaximized) then
		max = 99
	end

	for i = 1, _math_min (max, #meus_curadores) do
		GameCooltip:AddLine (meus_curadores[i][1]..": ", FormatTooltipNumber (_, meus_curadores[i][2]).." (".._cstr ("%.1f", (meus_curadores[i][2]/total_curado) * 100).."%)")
		local classe = meus_curadores[i][3]
		if (not classe) then
			classe = "UNKNOW"
		end
		if (classe == "UNKNOW") then
			GameCooltip:AddIcon ("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, 14, 14, .25, .5, 0, 1)
		else
			GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, 14, 14, _unpack (_detalhes.class_coords [classe]))
		end
		_detalhes:AddTooltipBackgroundStatusbar()
	end
	
	return true
end

---------> HEALING DONE / HPS / OVERHEAL
local background_heal_vs_absorbs = {value = 100, color = {1, 1, 0, .25}, specialSpark = false, texture = [[Interface\AddOns\Details\images\bar4_glass]]}

function atributo_heal:ToolTip_HealingDone (instancia, numero, barra, keydown)

	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack (_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack (_detalhes.class_colors [self.classe])
	end
	
	local ActorHealingTable = {}
	local ActorHealingTargets = {}
	local ActorSkillsContainer = self.spell_tables._ActorTable

	local actor_key, skill_key = "total", "total"
	if (instancia.sub_atributo == 3) then
		actor_key, skill_key = "totalover", "overheal"
	elseif (instancia.sub_atributo == 6) then
		actor_key, skill_key = "totalabsorb", "totalabsorb"
	end
	
	local meu_tempo
	if (_detalhes.time_type == 1 or not self.grupo) then
		meu_tempo = self:Tempo()
	elseif (_detalhes.time_type == 2) then
		meu_tempo = self:GetCombatTime()
	end
	
	local ActorTotal = self [actor_key]
	
	for _spellid, _skill in _pairs (ActorSkillsContainer) do 
		local SkillName, _, SkillIcon = _GetSpellInfo (_spellid)
		if (_skill [skill_key] > 0) then
			_table_insert (ActorHealingTable, {_spellid, _skill [skill_key], _skill [skill_key]/ActorTotal*100, {SkillName, nil, SkillIcon}, _skill [skill_key]/meu_tempo, _skill.total})
		end
	end
	_table_sort (ActorHealingTable, _detalhes.Sort2)
	
	--> TOP Curados
	ActorSkillsContainer = self.targets._ActorTable
	for _, TargetTable in _ipairs (ActorSkillsContainer) do
		if (TargetTable.total > 0) then
			_table_insert (ActorHealingTargets, {TargetTable.nome, TargetTable.total, TargetTable.total/ActorTotal*100})
		end
	end
	_table_sort (ActorHealingTargets, _detalhes.Sort2)

	--> Mostra as habilidades no tooltip
	_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_SPELLS"], headerColor, r, g, b, #ActorHealingTable)
	GameCooltip:AddIcon ([[Interface\RAIDFRAME\Raid-Icon-Rez]], 1, 1, 14, 14, 0.109375, 0.890625, 0.0625, 0.90625)

	local ismaximized = false
	if (keydown == "shift" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 3) then
		GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, 24, 12, 0, 1, 0, 0.640625, key_overlay_press)
		GameCooltip:AddStatusBar (100, 1, r, g, b, 1)
		ismaximized = true
	else
		GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, 24, 12, 0, 1, 0, 0.640625, key_overlay)
		GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
	end

	local tooltip_max_abilities = _detalhes.tooltip_max_abilities
	if (instancia.sub_atributo == 3 or instancia.sub_atributo == 2) then
		tooltip_max_abilities = 6
	end

	if (ismaximized) then
		tooltip_max_abilities = 99
	end
	
	for i = 1, _math_min (tooltip_max_abilities, #ActorHealingTable) do
		if (ActorHealingTable[i][2] < 1) then
			break
		end
		if (instancia.sub_atributo == 2) then --> hps
			GameCooltip:AddLine (ActorHealingTable[i][4][1]..": ", FormatTooltipNumber (_,  _math_floor (ActorHealingTable[i][5])).." (".._cstr ("%.1f", ActorHealingTable[i][3]).."%)")
		elseif (instancia.sub_atributo == 3) then --> overheal
			local overheal = ActorHealingTable[i][2]
			local total = ActorHealingTable[i][6]
			GameCooltip:AddLine (ActorHealingTable[i][4][1] .." (|cFFFF3333" .. _math_floor ( (overheal / (overheal+total)) *100)  .. "%|r):", FormatTooltipNumber (_,  _math_floor (ActorHealingTable[i][2])).." (".._cstr ("%.1f", ActorHealingTable[i][3]).."%)")
		else
			GameCooltip:AddLine (ActorHealingTable[i][4][1]..": ", FormatTooltipNumber (_, ActorHealingTable[i][2]).." (".._cstr ("%.1f", ActorHealingTable[i][3]).."%)")
		end
		GameCooltip:AddIcon (ActorHealingTable[i][4][3], nil, nil, 14, 14)
		_detalhes:AddTooltipBackgroundStatusbar()
	end
	
	if (instancia.sub_atributo == 6) then
		GameCooltip:AddLine (Loc ["STRING_REPORT_LEFTCLICK"], nil, 1, "white")
		GameCooltip:AddIcon ([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 1, 1, 12, 16, 0.015625, 0.13671875, 0.4375, 0.59765625)
		GameCooltip:ShowCooltip()
	end
	
	local container = instancia.showing [2]
	
	if (instancia.sub_atributo == 1) then -- 1 or 2 -> healing done or hps
	
		_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_TARGETS"], headerColor, r, g, b, #ActorHealingTargets)
		GameCooltip:AddIcon ([[Interface\TUTORIALFRAME\UI-TutorialFrame-LevelUp]], 1, 1, 14, 14, 0.10546875, 0.89453125, 0.05859375, 0.6796875)

		local ismaximized = false
		if (keydown == "ctrl" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 4) then
			GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_ctrl]], 1, 2, 24, 12, 0, 1, 0, 0.640625, key_overlay_press)
			GameCooltip:AddStatusBar (100, 1, r, g, b, 1)
			ismaximized = true
		else
			GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_ctrl]], 1, 2, 24, 12, 0, 1, 0, 0.640625, key_overlay)
			GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
		end
		
		local tooltip_max_abilities2 = _detalhes.tooltip_max_abilities
		if (ismaximized) then
			tooltip_max_abilities2 = 99
		end
		
		for i = 1, _math_min (tooltip_max_abilities2, #ActorHealingTargets) do
			if (ActorHealingTargets[i][2] < 1) then
				break
			end
			
			if (ismaximized and ActorHealingTargets[i][1]:find (_detalhes.playername)) then
				GameCooltip:AddLine (ActorHealingTargets[i][1]..": ", FormatTooltipNumber (_, ActorHealingTargets[i][2]) .." (".._cstr ("%.1f", ActorHealingTargets[i][3]).."%)", nil, "yellow")
				GameCooltip:AddStatusBar (100, 1, .5, .5, .5, .7)
			else
				GameCooltip:AddLine (ActorHealingTargets[i][1]..": ", FormatTooltipNumber (_, ActorHealingTargets[i][2]) .." (".._cstr ("%.1f", ActorHealingTargets[i][3]).."%)")
				_detalhes:AddTooltipBackgroundStatusbar()
			end
			
			local targetActor = container:PegarCombatente (nil, ActorHealingTargets[i][1])
			
			if (targetActor) then
				local classe = targetActor.classe
				if (not classe) then
					classe = "UNKNOW"
				end
				if (classe == "UNKNOW") then
					GameCooltip:AddIcon ("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, 14, 14, .25, .5, 0, 1)
				else
					GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, 14, 14, _unpack (_detalhes.class_coords [classe]))
				end
			end
		end
	end
	
	--> PETS
	local meus_pets = self.pets
	
	if (#meus_pets > 0 and (instancia.sub_atributo == 1 or instancia.sub_atributo == 2)) then --> teve ajudantes
		
		local quantidade = {} --> armazena a quantidade de pets iguais
		local danos = {} --> armazena as habilidades
		local alvos = {} --> armazena os alvos
		local totais = {} --> armazena o dano total de cada objeto
		
		for index, nome in _ipairs (meus_pets) do
			if (not quantidade [nome]) then
				quantidade [nome] = 1
				
				local my_self = instancia.showing [class_type]:PegarCombatente (nil, nome)
				if (my_self) then
				
					local meu_total = my_self.total_without_pet
					local tabela = my_self.spell_tables._ActorTable
					local meus_danos = {}
					
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
		
		local _quantidade = 0
		local added_logo = false

		_table_sort (totais, _detalhes.Sort2)
		
		local ismaximized = false
		if (keydown == "alt" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 5) then
			ismaximized = true
		end
		
		for index, _table in _ipairs (totais) do
			
			if (_table [2] > 0 and (index < 3 or ismaximized)) then
			
				if (not added_logo) then
					added_logo = true
					_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_PETS"], headerColor, r, g, b, #totais)

					GameCooltip:AddIcon ([[Interface\COMMON\friendship-heart]], 1, 1, 14, 14, 0.21875, 0.78125, 0.09375, 0.6875)

					if (ismaximized) then
						GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_alt]], 1, 2, 24, 12, 0, 1, 0, 0.640625, key_overlay_press)
						GameCooltip:AddStatusBar (100, 1, r, g, b, 1)
					else
						GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_alt]], 1, 2, 24, 12, 0, 1, 0, 0.640625, key_overlay)
						GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)
					end
					
				end
			
				local n = _table [1]:gsub (("%s%<.*"), "")
				if (instancia.sub_atributo == 2) then
					GameCooltip:AddLine (n, FormatTooltipNumber (_,  _math_floor (_table [3])) .. " (" .. _math_floor (_table [2]/self.total*100) .. "%)")
				else
					GameCooltip:AddLine (n, FormatTooltipNumber (_, _table [2]) .. " (" .. _math_floor (_table [2]/self.total*100) .. "%)")
				end
				_detalhes:AddTooltipBackgroundStatusbar()
				GameCooltip:AddIcon ([[Interface\AddOns\Details\images\classes_small]], 1, 1, 14, 14, 0.25, 0.49609375, 0.75, 1)
			end
		end
		
	end
	
	--> absorbs vs heal
	if (instancia.sub_atributo == 1 or instancia.sub_atributo == 2) then
		local total_healed = self.total - self.totalabsorb
		local total_previned = self.totalabsorb
		
		local healed_percentage = total_healed / self.total * 100
		local previned_percentage = total_previned / self.total * 100
		
		if (healed_percentage > 1 and previned_percentage > 1) then
			GameCooltip:AddLine (_math_floor (healed_percentage).."%", _math_floor (previned_percentage).."%")
			local r, g, b = _unpack (_detalhes.class_colors [self.classe])
			background_heal_vs_absorbs.color[1] = r
			background_heal_vs_absorbs.color[2] = g
			background_heal_vs_absorbs.color[3] = b
			background_heal_vs_absorbs.specialSpark = false
			GameCooltip:AddStatusBar (healed_percentage, 1, r, g, b, .9, false, background_heal_vs_absorbs)
			GameCooltip:AddIcon ([[Interface\ICONS\Ability_Priest_ReflectiveShield]], 1, 2, 14, 14, 0.0625, 0.9375, 0.0625, 0.9375)
			GameCooltip:AddIcon ([[Interface\ICONS\Ability_Monk_ChiWave]], 1, 1, 14, 14, 0.9375, 0.0625, 0.0625, 0.9375)
		end
		
	elseif (instancia.sub_atributo == 3) then
		local total_healed = self.total
		local total_overheal = self.totalover
		local both = total_healed + total_overheal
		
		local healed_okey = total_healed / both * 100
		local healed_disposed = total_overheal / both * 100
		
		if (healed_okey > 1 and healed_disposed > 1) then
			GameCooltip:AddLine (_math_floor (healed_okey).."%", _math_floor (healed_disposed).."%")
			background_heal_vs_absorbs.color[1] = 1
			background_heal_vs_absorbs.color[2] = 0
			background_heal_vs_absorbs.color[3] = 0
			background_heal_vs_absorbs.specialSpark = false
			GameCooltip:AddStatusBar (healed_okey, 1, 0, 1, 0, .9, false, background_heal_vs_absorbs)
			GameCooltip:AddIcon ([[Interface\Scenarios\ScenarioIcon-Check]], 1, 1, 14, 14, 0, 1, 0, 1)
			GameCooltip:AddIcon ([[Interface\Glues\LOGIN\Glues-CheckBox-Check]], 1, 2, 14, 14, 1, 0, 0, 1)
		end
	end
	
	return true
end


--------------------------------------------- // JANELA DETALHES // ---------------------------------------------
---------- bifurcação
function atributo_heal:MontaInfo()
	if (info.sub_atributo == 1 or info.sub_atributo == 2) then
		return self:MontaInfoHealingDone()
	elseif (info.sub_atributo == 3) then
		return self:MontaInfoOverHealing()
	elseif (info.sub_atributo == 4) then
		return self:MontaInfoHealTaken()
	end
end

function atributo_heal:MontaInfoHealTaken()

	local healing_taken = self.healing_taken
	local curandeiros = self.healing_from
	local instancia = info.instancia
	local tabela_do_combate = instancia.showing
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable
	local barras = info.barras1
	local meus_curandeiros = {}
	
	local este_curandeiro	
	for nome, _ in _pairs (curandeiros) do
		este_curandeiro = showing._ActorTable[showing._NameIndexTable[nome]]
		if (este_curandeiro) then
			local alvos = este_curandeiro.targets
			local este_alvo = alvos._ActorTable[alvos._NameIndexTable[self.nome]]
			if (este_alvo) then
				meus_curandeiros [#meus_curandeiros+1] = {nome, este_alvo.total, este_alvo.total/healing_taken*100, este_curandeiro.classe}
			end
		end
	end
	
	local amt = #meus_curandeiros
	
	if (amt < 1) then
		return true
	end
	
	_table_sort (meus_curandeiros, function (a, b) return a[2] > b[2] end)
	
	gump:JI_AtualizaContainerBarras (amt)

	local max_ = meus_curandeiros [1] and meus_curandeiros [1][2] or 0
	
	local barra
	for index, tabela in _ipairs (meus_curandeiros) do
		barra = barras [index]
		if (not barra) then
			barra = gump:CriaNovaBarraInfo1 (instancia, index)
		end

		self:FocusLock (barra, tabela[1])
		
		--hes:UpdadeInfoBar (row, index, spellid, name, value, max, percent, icon, detalhes)
		
		local texCoords = CLASS_ICON_TCOORDS [tabela[4]]
		if (not texCoords) then
			texCoords = _detalhes.class_coords ["UNKNOW"]
		end
		
		self:UpdadeInfoBar (barra, index, tabela[1], tabela[1], tabela[2], max_, tabela[3], "Interface\\AddOns\\Details\\images\\classes_small", true, texCoords)
	end	
	
	--[[
	for index, tabela in _ipairs (meus_curandeiros) do
		
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
			barra.textura:SetValue (tabela[2]/max_*100) --> muito mais rapido...
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
	--]]
end

function atributo_heal:MontaInfoOverHealing()
--> pegar as habilidade de dar sort no heal
	
	local instancia = info.instancia
	local total = self.totalover
	local tabela = self.spell_tables._ActorTable
	local minhas_curas = {}
	local barras = info.barras1

	for spellid, tabela in _pairs (tabela) do
		local nome, _, icone = _GetSpellInfo (spellid)
		_table_insert (minhas_curas, {spellid, tabela.overheal, tabela.overheal/total*100, nome, icone})
	end

	_table_sort (minhas_curas, function(a, b) return a[2] > b[2] end)

	local amt = #minhas_curas
	gump:JI_AtualizaContainerBarras (amt)

	local max_ = minhas_curas[1] and minhas_curas[1][2] or 0

	for index, tabela in _ipairs (minhas_curas) do

		local barra = barras [index]

		if (not barra) then
			barra = gump:CriaNovaBarraInfo1 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1)
			barra.on_focus = false
		end

		if (not info.mostrando_mouse_over) then
			if (tabela[1] == self.detalhes) then --> tabela [1] = spellid = spellid que esta na caixa da direita
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
			barra.textura:SetValue (tabela[2]/max_*100) --> muito mais rapido...
		end

		barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[4]) --seta o texto da esqueda
		barra.texto_direita:SetText (_detalhes:comma_value (tabela[2]) .." ".. instancia.divisores.abre .. _cstr ("%.1f", tabela[3]) .."%".. instancia.divisores.fecha) --seta o texto da direita

		barra.icone:SetTexture (tabela[5])

		barra.minha_tabela = self
		barra.show = tabela[1]
		barra:Show()

		if (self.detalhes and self.detalhes == barra.show) then
			self:MontaDetalhes (self.detalhes, barra)
		end
	end
	
	--> TOP OVERHEALED
	local meus_inimigos = {}
	tabela = self.targets._ActorTable
	for _, tabela in _ipairs (tabela) do
		_table_insert (meus_inimigos, {tabela.nome, tabela.overheal, tabela.overheal/total*100})
	end
	_table_sort (meus_inimigos, function(a, b) return a[2] > b[2] end )	
	
	local amt_alvos = #meus_inimigos
	gump:JI_AtualizaContainerAlvos (amt_alvos)
	
	local max_inimigos = meus_inimigos[1] and meus_inimigos[1][2] or 0
	
	for index, tabela in _ipairs (meus_inimigos) do
	
		local barra = info.barras2 [index]
		
		if (not barra) then
			barra = gump:CriaNovaBarraInfo2 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1)
		end
		
		if (index == 1) then
			barra.textura:SetValue (100)
		else
			barra.textura:SetValue (tabela[2]/max_*100) --> muito mais rapido...
		end
		
		barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[1]) --seta o texto da esqueda
		barra.texto_direita:SetText (_detalhes:comma_value (tabela[2]) .." ".. instancia.divisores.abre .. _cstr ("%.1f", tabela[3]) .. instancia.divisores.fecha) --seta o texto da direita
		barra.texto_esquerdo:SetWidth (barra:GetWidth() - barra.texto_direita:GetStringWidth() - 30)
		
		-- o que mostrar no local do ícone?
		--barra.icone:SetTexture (tabela[4][3])
		
		barra.minha_tabela = self
		barra.nome_inimigo = tabela [1]
		
		-- no lugar do spell id colocar o que?
		--barra.spellid = tabela[5]
		barra:Show()
		
		--if (self.detalhes and self.detalhes == barra.spellid) then
		--	self:MontaDetalhes (self.detalhes, barra)
		--end
	end
end

function atributo_heal:MontaInfoHealingDone()

	--> pegar as habilidade de dar sort no heal
	
	local instancia = info.instancia
	local total = self.total
	local tabela = self.spell_tables._ActorTable
	local minhas_curas = {}
	local barras = info.barras1

	for spellid, tabela in _pairs (tabela) do
		local nome, rank, icone = _GetSpellInfo (spellid)
		_table_insert (minhas_curas, {spellid, tabela.total, tabela.total/total*100, nome, icone})
	end

	_table_sort (minhas_curas, function(a, b) return a[2] > b[2] end)

	local amt = #minhas_curas
	gump:JI_AtualizaContainerBarras (amt)

	local max_ = minhas_curas[1] and minhas_curas[1][2] or 0

	for index, tabela in _ipairs (minhas_curas) do

		local barra = barras [index]

		if (not barra) then
			barra = gump:CriaNovaBarraInfo1 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1)
			barra.on_focus = false
		end

		self:FocusLock (barra, tabela[1])
		
		self:UpdadeInfoBar (barra, index, tabela[1], tabela[4], tabela[2], max_, tabela[3], tabela[5], true)

		barra.minha_tabela = self
		barra.show = tabela[1]
		barra.spellid = self.nome
		barra:Show()

		if (self.detalhes and self.detalhes == barra.show) then
			self:MontaDetalhes (self.detalhes, barra)
		end
	end
	
	--> SERIA TOP CURADOS
	local meus_inimigos = {}
	tabela = self.targets._ActorTable
	for _, tabela in _ipairs (tabela) do
		_table_insert (meus_inimigos, {tabela.nome, tabela.total, tabela.total/total*100})
	end
	_table_sort (meus_inimigos, function(a, b) return a[2] > b[2] end )	
	
	local amt_alvos = #meus_inimigos
	gump:JI_AtualizaContainerAlvos (amt_alvos)
	
	local max_inimigos = meus_inimigos[1] and meus_inimigos[1][2] or 0
	
	for index, tabela in _ipairs (meus_inimigos) do
	
		local barra = info.barras2 [index]
		
		if (not barra) then
			barra = gump:CriaNovaBarraInfo2 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1)
		end
		
		if (index == 1) then
			barra.textura:SetValue (100)
		else
			barra.textura:SetValue (tabela[2]/max_*100) --> muito mais rapido...
		end
		
		barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[1]) --seta o texto da esqueda
		barra.texto_direita:SetText (_detalhes:comma_value (tabela[2]) .." ".. instancia.divisores.abre .. _cstr ("%.1f", tabela[3]) .. instancia.divisores.fecha) --seta o texto da direita
		
		-- o que mostrar no local do ícone?
		--barra.icone:SetTexture (tabela[4][3])
		
		barra.minha_tabela = self
		barra.nome_inimigo = tabela [1]
		
		-- no lugar do spell id colocar o que?
		barra.spellid = tabela[5]
		barra:Show()
		
		--if (self.detalhes and self.detalhes == barra.spellid) then
		--	self:MontaDetalhes (self.detalhes, barra)
		--end
	end
	
end

function atributo_heal:MontaTooltipAlvos (esta_barra, index)
	-- eu ja sei quem é o alvo a mostrar os detalhes
	-- dar foreach no container de habilidades -- pegar os alvos da habilidade -- e ver se dentro do container tem o meu alvo.
	
	local inimigo = esta_barra.nome_inimigo
	local container = self.spell_tables._ActorTable
	local habilidades = {}
	local total = self.total
	
	if (info.instancia.sub_atributo == 3) then --> overheal
		total = self.totalover
		for spellid, tabela in _pairs (container) do
			--> tabela = classe_damage_habilidade
			local alvos = tabela.targets._ActorTable
			for _, tabela in _ipairs (alvos) do
				--> tabela = classe_target
				if (tabela.nome == inimigo) then
					habilidades [#habilidades+1] = {spellid, tabela.overheal}
				end
			end
		end
	else
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
	
	end
	
	_table_sort (habilidades, function (a, b) return a[2] > b[2] end)
	
	GameTooltip:AddLine (index..". "..inimigo)
	GameTooltip:AddLine (Loc ["STRING_HEALING_FROM"]..":") --> localize-me
	GameTooltip:AddLine (" ")
	
	for index, tabela in _ipairs (habilidades) do
		local nome, rank, icone = _GetSpellInfo (tabela[1])
		if (index < 8) then
			GameTooltip:AddDoubleLine (index..". |T"..icone..":0|t "..nome, _detalhes:comma_value (tabela[2]).." (".. _cstr ("%.1f", tabela[2]/total*100).."%)", 1, 1, 1, 1, 1, 1)
			--GameTooltip:AddTexture (icone)
		else
			GameTooltip:AddDoubleLine (index..". "..nome, _detalhes:comma_value (tabela[2]).." (".. _cstr ("%.1f", tabela[2]/total*100).."%)", .65, .65, .65, .65, .65, .65)
		end
	end
	
	return true
	--GameTooltip:AddDoubleLine (minhas_curas[i][4][1]..": ", minhas_curas[i][2].." (".._cstr ("%.1f", minhas_curas[i][3]).."%)", 1, 1, 1, 1, 1, 1)
	
end

function atributo_heal:MontaDetalhes (spellid, barra)
	--> bifurgações
	if (info.sub_atributo == 1 or info.sub_atributo == 2 or info.sub_atributo == 3) then
		return self:MontaDetalhesHealingDone (spellid, barra)
	elseif (info.sub_atributo == 4) then
		atributo_heal:MontaDetalhesHealingTaken (spellid, barra)
	end
end

function atributo_heal:MontaDetalhesHealingTaken (nome, barra)

	for _, barra in _ipairs (info.barras3) do 
		barra:Hide()
	end

	local barras = info.barras3
	local instancia = info.instancia
	
	local tabela_do_combate = info.instancia.showing
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable

	local este_curandeiro = showing._ActorTable[showing._NameIndexTable[nome]]
	local conteudo = este_curandeiro.spell_tables._ActorTable --> _pairs[] com os IDs das magias
	
	local actor = info.jogador.nome
	
	local total = este_curandeiro.targets._ActorTable [este_curandeiro.targets._NameIndexTable [actor]].total

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
		barra.texto_direita:SetText (_detalhes:comma_value (tabela[2]) .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[3]) .."%".. instancia.divisores.fecha) --seta o texto da direita
		
		barra.icone:SetTexture (tabela[5])

		barra:Show() --> mostra a barra
		
		if (index == 15) then 
			break
		end
	end
end

function atributo_heal:MontaDetalhesHealingDone (spellid, barra)
	--> localize-me

	local esta_magia = self.spell_tables._ActorTable [spellid]
	if (not esta_magia) then
		return
	end
	
	--> icone direito superior
	local nome, rank, icone = _GetSpellInfo (spellid)
	local infospell = {nome, rank, icone}

	info.spell_icone:SetTexture (infospell[3])

	local total = self.total
	
	local overheal = esta_magia.overheal
	local meu_total = esta_magia.total + overheal
	
	local meu_tempo
	if (_detalhes.time_type == 1 or not self.grupo) then
		meu_tempo = self:Tempo()
	elseif (_detalhes.time_type == 2) then
		meu_tempo = self:GetCombatTime()
	end
	
	--local total_hits = esta_magia.counter
	local total_hits = esta_magia.n_amt+esta_magia.c_amt
	
	local index = 1
	
	local data = {}
	
	if (esta_magia.total > 0) then
	
	--> GERAL
		local media = esta_magia.total/total_hits
		
		local this_hps = nil
		if (esta_magia.counter > esta_magia.c_amt) then
			this_hps = Loc ["STRING_HPS"]..": ".._cstr ("%.1f", esta_magia.total/meu_tempo) --> localiza-me
		else
			this_hps = Loc ["STRING_HPS"]..": "..Loc ["STRING_SEE_BELOW"]
		end
		
		gump:SetaDetalheInfoTexto ( index, 100, --> Localize-me
			Loc ["STRING_GERAL"], --> localiza-me
			Loc ["STRING_HEAL"]..": ".._detalhes:ToK (esta_magia.total), --> localiza-me
			Loc ["STRING_PERCENTAGE"]..": ".._cstr ("%.1f", esta_magia.total/total*100) .. "%", --> localiza-me
			Loc ["STRING_MEDIA"]..": ".._cstr ("%.1f", media), --> localiza-me
			this_hps,
			Loc ["STRING_HITS"]..": " .. total_hits) --> localiza-me
	
	--> NORMAL
		local normal_hits = esta_magia.n_amt
		if (normal_hits > 0) then
			local normal_curado = esta_magia.n_curado
			local media_normal = normal_curado/normal_hits
			local T = (meu_tempo*normal_curado)/esta_magia.total
			local P = media/media_normal*100
			T = P*T/100

			data[#data+1] = {
				esta_magia.n_amt, 
				normal_hits/total_hits*100, 
				--esta_magia.n_curado/esta_magia.total*100, 
				Loc ["STRING_HEAL"], --> localiza-me
				Loc ["STRING_MINIMUM"] .. ": " .. _detalhes:comma_value (esta_magia.n_min), --> localiza-me
				Loc ["STRING_MAXIMUM"] .. ": " .. _detalhes:comma_value (esta_magia.n_max), --> localiza-me
				Loc ["STRING_MEDIA"] .. ": " .. _cstr ("%.1f", media_normal), --> localiza-me
				Loc ["STRING_HPS"] .. ": " .. _cstr ("%.1f", normal_curado/T), --> localiza-me
				normal_hits .. " / ".. _cstr ("%.1f", normal_hits/total_hits*100).."%"
				}
		end

	--> CRITICO
		if (esta_magia.c_amt > 0) then	
			local media_critico = esta_magia.c_curado/esta_magia.c_amt
			local T = (meu_tempo*esta_magia.c_curado)/esta_magia.total
			local P = media/media_critico*100
			T = P*T/100
			local crit_hps = esta_magia.c_curado/T
			if (not crit_hps) then
				crit_hps = 0
			end
			
			data[#data+1] = {
				esta_magia.c_amt,
				esta_magia.c_amt/total_hits*100, 
				--esta_magia.c_curado/esta_magia.total*100,
				Loc ["STRING_HEAL_CRIT"], --> localiza-me
				Loc ["STRING_MINIMUM"] .. ": " .. _detalhes:comma_value (esta_magia.c_min), --> localiza-me
				Loc ["STRING_MAXIMUM"] .. ": " .. _detalhes:comma_value (esta_magia.c_max), --> localiza-me
				Loc ["STRING_MEDIA"] .. ": " .. _cstr ("%.1f", media_critico), --> localiza-me
				Loc ["STRING_HPS"] .. ": " .. _cstr ("%.1f", crit_hps), --> localiza-me
				esta_magia.c_amt .. " / ".._cstr ("%.1f", esta_magia.c_amt/total_hits*100).."%"
				}
		end
		
	end
	
	_table_sort (data, function (a, b) return a[1] > b[1] end)

	--> Aqui pode vir a cura absorvida

		local absorbed = esta_magia.absorbed

		if (absorbed > 0) then
			local porcentagem_absorbed = absorbed/esta_magia.total*100
			data[#data+1] = {
				absorbed,
				{["p"] = porcentagem_absorbed, ["c"] = {117/255, 58/255, 0/255}},
				Loc ["STRING_HEAL_ABSORBED"], --> localiza-me
				"", --esta_magia.glacing.curado
				"",
				"",
				"",
				absorbed.." / ".._cstr ("%.1f", porcentagem_absorbed).."%"
				}
		end

	for i = #data+1, 3 do --> para o overheal aparecer na ultima barra
		data[i] = nil
	end
		
	--> overhealing

		if (overheal > 0) then
			local porcentagem_overheal = overheal/meu_total*100
			data[4] = { 
				overheal,
				{["p"] = porcentagem_overheal, ["c"] = {0.5, 0.1, 0.1}},
				Loc ["STRING_OVERHEAL"], --> localiza-me
				"",
				"",
				"",
				"",
				_detalhes:comma_value (overheal).." / ".._cstr ("%.1f", porcentagem_overheal).."%"
				}
		end
	
	for index = 1, 4 do
		local tabela = data[index]
		if (not tabela) then
			gump:HidaDetalheInfo (index+1)
		else
			gump:SetaDetalheInfoTexto (index+1, tabela[2], tabela[3], tabela[4], tabela[5], tabela[6], tabela[7], tabela[8])
		end
	end

	--for i = #data+2, 5 do
	--	gump:HidaDetalheInfo (i)
	--end

end

--controla se o dps do jogador esta travado ou destravado
function atributo_heal:Iniciar (iniciar)
	if (iniciar == nil) then 
		return self.iniciar_hps --retorna se o dps esta aberto ou fechado para este jogador
	elseif (iniciar) then
		self.iniciar_hps = true
		self:RegistrarNaTimeMachine() --coloca ele da timeMachine
		if (self.shadow) then
			self.shadow.iniciar_hps = true --> isso foi posto recentemente
			--self.shadow:RegistrarNaTimeMachine()
		end
	else
		self.iniciar_hps = false
		self:DesregistrarNaTimeMachine() --retira ele da timeMachine
		if (self.shadow) then
			self.shadow.iniciar_hps = false --> isso foi posto recentemente
			--self.shadow:DesregistrarNaTimeMachine()
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core functions

	--> atualize a funcao de abreviacao
		function atributo_heal:UpdateSelectedToKFunction()
			SelectedToKFunction = ToKFunctions [_detalhes.ps_abbreviation]
			FormatTooltipNumber = ToKFunctions [_detalhes.tooltip.abbreviation]
			TooltipMaximizedMethod = _detalhes.tooltip.maximize_method
		end

	--> subtract total from a combat table
		function atributo_heal:subtract_total (combat_table)
			combat_table.totals [class_type] = combat_table.totals [class_type] - self.total
			if (self.grupo) then
				combat_table.totals_grupo [class_type] = combat_table.totals_grupo [class_type] - self.total
			end
		end
		function atributo_heal:add_total (combat_table)
			combat_table.totals [class_type] = combat_table.totals [class_type] + self.total
			if (self.grupo) then
				combat_table.totals_grupo [class_type] = combat_table.totals_grupo [class_type] + self.total
			end
		end		
		
	--> restaura a tabela de last event
		function atributo_heal:r_last_events_table (actor)
			if (not actor) then
				actor = self
			end
			actor.last_events_table = _detalhes:CreateActorLastEventTable()
		end
		
	--> restaura e liga o ator com a sua shadow durante a inicialização
		function atributo_heal:r_connect_shadow (actor)
		
			if (not actor) then
				actor = self
			end
		
			--> criar uma shadow desse ator se ainda não tiver uma
				local overall_cura = _detalhes.tabela_overall [2]
				local shadow = overall_cura._ActorTable [overall_cura._NameIndexTable [actor.nome]]

				if (not shadow) then 
					shadow = overall_cura:PegarCombatente (actor.serial, actor.nome, actor.flag_original, true)
					shadow.classe = actor.classe
					shadow.grupo = actor.grupo
					shadow.start_time = time() - 3
					shadow.end_time = time()
				end
			
			--> restaura a meta e indexes ao ator
				_detalhes.refresh:r_atributo_heal (actor, shadow)
			
			--> tempo decorrido (captura de dados)
				if (actor.end_time) then
					local tempo = (actor.end_time or time()) - actor.start_time
					shadow.start_time = shadow.start_time - tempo
				end

			--> total de cura (captura de dados)
				shadow.total = shadow.total + actor.total
			--> total de overheal (captura de dados)
				shadow.totalover = shadow.totalover + actor.totalover
			--> total de absorbs (captura de dados)
				shadow.totalabsorb = shadow.totalabsorb + actor.totalabsorb
			--> total de cura feita em inimigos (captura de dados)
				shadow.heal_enemy_amt = shadow.heal_enemy_amt + actor.heal_enemy_amt
			--> total sem pets (captura de dados)
				shadow.total_without_pet = shadow.total_without_pet + actor.total_without_pet
				shadow.totalover_without_pet = shadow.totalover_without_pet + actor.totalover_without_pet
			--> total de cura recebida (captura de dados)
				shadow.healing_taken = shadow.healing_taken + actor.healing_taken

			--> total no combate overall (captura de dados)
				_detalhes.tabela_overall.totals[2] = _detalhes.tabela_overall.totals[2] + actor.total
				if (actor.grupo) then
					_detalhes.tabela_overall.totals_grupo[2] = _detalhes.tabela_overall.totals_grupo[2] + actor.total
				end
				
			--> copia o healing_from  (captura de dados)
				for nome, _ in _pairs (actor.healing_from) do 
					shadow.healing_from [nome] = true
				end
				
			--> copia o heal_enemy (captura de dados)
				for spellid, amount in _pairs (actor.heal_enemy) do 
					if (shadow.heal_enemy [spellid]) then 
						shadow.heal_enemy [spellid] = shadow.heal_enemy [spellid] + amount
					else
						shadow.heal_enemy [spellid] = amount
					end
				end
			
			--> copia o container de alvos (captura de dados)
				for index, alvo in _ipairs (actor.targets._ActorTable) do 
					--> cria e soma o valor do total
					local alvo_shadow = shadow.targets:PegarCombatente (nil, alvo.nome, nil, true)
					alvo_shadow.total = alvo_shadow.total + alvo.total
					alvo_shadow.overheal = alvo_shadow.overheal + alvo.overheal
					alvo_shadow.absorbed = alvo_shadow.absorbed + alvo.absorbed 
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
						alvo_shadow.overheal = alvo_shadow.overheal + alvo.overheal
						alvo_shadow.absorbed = alvo_shadow.absorbed + alvo.absorbed 
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
					_detalhes.refresh:r_habilidade_cura (habilidade, shadow.spell_tables)
				end
			
			return shadow
		end

function atributo_heal:ColetarLixo (lastevent)
	return _detalhes:ColetarLixo (class_type, lastevent)
end

function _detalhes.refresh:r_atributo_heal (este_jogador, shadow)
	_setmetatable (este_jogador, atributo_heal)
	este_jogador.__index = atributo_heal
	
	if (shadow ~= -1) then
		este_jogador.shadow = shadow
		_detalhes.refresh:r_container_combatentes (este_jogador.targets, shadow.targets)
		_detalhes.refresh:r_container_habilidades (este_jogador.spell_tables, shadow.spell_tables)
	else
		_detalhes.refresh:r_container_combatentes (este_jogador.targets, -1)
		_detalhes.refresh:r_container_habilidades (este_jogador.spell_tables, -1)
	end
end

function _detalhes.clear:c_atributo_heal (este_jogador)
	--este_jogador.__index = {}
	este_jogador.__index = nil
	este_jogador.shadow = nil
	este_jogador.links = nil
	este_jogador.minha_barra = nil
	
	_detalhes.clear:c_container_combatentes (este_jogador.targets)
	_detalhes.clear:c_container_habilidades (este_jogador.spell_tables)
end

atributo_heal.__add = function (tabela1, tabela2)

	--> tempo decorrido
		local tempo = (tabela2.end_time or time()) - tabela2.start_time
		tabela1.start_time = tabela1.start_time - tempo

	--> total de cura
		tabela1.total = tabela1.total + tabela2.total
	--> total de overheal
		tabela1.totalover = tabela1.totalover + tabela2.totalover
	--> total de absorbs
		tabela1.totalabsorb = tabela1.totalabsorb + tabela2.totalabsorb
	--> total de cura feita em inimigos
		tabela1.heal_enemy_amt = tabela1.heal_enemy_amt + tabela2.heal_enemy_amt
	--> total sem pets
		tabela1.total_without_pet = tabela1.total_without_pet + tabela2.total_without_pet
		tabela1.totalover_without_pet = tabela1.totalover_without_pet + tabela2.totalover_without_pet
	--> total de cura recebida
		tabela1.healing_taken = tabela1.healing_taken + tabela2.healing_taken
		
	--> soma o healing_from
		for nome, _ in _pairs (tabela2.healing_from) do 
			tabela1.healing_from [nome] = true
		end
	
	--> somar o heal_enemy
		for spellid, amount in _pairs (tabela2.heal_enemy) do 
			if (tabela1.heal_enemy [spellid]) then 
				tabela1.heal_enemy [spellid] = tabela1.heal_enemy [spellid] + amount
			else
				tabela1.heal_enemy [spellid] = amount
			end
		end
	
	--> somar o container de alvos
		for index, alvo in _ipairs (tabela2.targets._ActorTable) do 
			--> pega o alvo no ator
			local alvo_tabela1 = tabela1.targets:PegarCombatente (nil, alvo.nome, nil, true)
			--> soma os valores
			alvo_tabela1.total = alvo_tabela1.total + alvo.total
			alvo_tabela1.overheal = alvo_tabela1.overheal + alvo.overheal
			alvo_tabela1.absorbed = alvo_tabela1.absorbed + alvo.absorbed 
		end
	
	--> soma o container de habilidades
		for spellid, habilidade in _pairs (tabela2.spell_tables._ActorTable) do 
			--> pega a habilidade no primeiro ator
			local habilidade_tabela1 = tabela1.spell_tables:PegaHabilidade (spellid, true, "SPELL_HEAL", false)
			--> soma os alvos
			for index, alvo in _ipairs (habilidade.targets._ActorTable) do 
				local alvo_tabela1 = habilidade_tabela1.targets:PegarCombatente (nil, alvo.nome, nil, true)
				alvo_tabela1.total = alvo_tabela1.total + alvo.total
				alvo_tabela1.overheal = alvo_tabela1.overheal + alvo.overheal
				alvo_tabela1.absorbed = alvo_tabela1.absorbed + alvo.absorbed 
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
	
	return tabela1
end

atributo_heal.__sub = function (tabela1, tabela2)

	--> tempo decorrido
		local tempo = (tabela2.end_time or time()) - tabela2.start_time
		tabela1.start_time = tabela1.start_time + tempo

	--> total de cura
		tabela1.total = tabela1.total - tabela2.total
	--> total de overheal
		tabela1.totalover = tabela1.totalover - tabela2.totalover
	--> total de absorbs
		tabela1.totalabsorb = tabela1.totalabsorb - tabela2.totalabsorb
	--> total de cura feita em inimigos
		tabela1.heal_enemy_amt = tabela1.heal_enemy_amt - tabela2.heal_enemy_amt
	--> total sem pets
		tabela1.total_without_pet = tabela1.total_without_pet - tabela2.total_without_pet
		tabela1.totalover_without_pet = tabela1.totalover_without_pet - tabela2.totalover_without_pet
	--> total de cura recebida
		tabela1.healing_taken = tabela1.healing_taken - tabela2.healing_taken

	--> reduz o heal_enemy
		for spellid, amount in _pairs (tabela2.heal_enemy) do 
			if (tabela1.heal_enemy [spellid]) then 
				tabela1.heal_enemy [spellid] = tabela1.heal_enemy [spellid] - amount
			else
				tabela1.heal_enemy [spellid] = amount
			end
		end
		
	--> reduz o container de alvos
		for index, alvo in _ipairs (tabela2.targets._ActorTable) do 
			--> pega o alvo no ator
			local alvo_tabela1 = tabela1.targets:PegarCombatente (nil, alvo.nome, nil, true)
			--> soma os valores
			alvo_tabela1.total = alvo_tabela1.total - alvo.total
			alvo_tabela1.overheal = alvo_tabela1.overheal - alvo.overheal
			alvo_tabela1.absorbed = alvo_tabela1.absorbed - alvo.absorbed 
		end

	--> reduz o container de habilidades
		for spellid, habilidade in _pairs (tabela2.spell_tables._ActorTable) do 
			--> pega a habilidade no primeiro ator
			local habilidade_tabela1 = tabela1.spell_tables:PegaHabilidade (spellid, true, "SPELL_HEAL", false)
			--> soma os alvos
			for index, alvo in _ipairs (habilidade.targets._ActorTable) do 
				local alvo_tabela1 = habilidade_tabela1.targets:PegarCombatente (nil, alvo.nome, nil, true)
				alvo_tabela1.total = alvo_tabela1.total - alvo.total
				alvo_tabela1.overheal = alvo_tabela1.overheal - alvo.overheal
				alvo_tabela1.absorbed = alvo_tabela1.absorbed - alvo.absorbed 
			end
			--> soma os valores da habilidade
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
	
	return tabela1
end
