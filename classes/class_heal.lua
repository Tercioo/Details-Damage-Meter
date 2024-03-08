
local _detalhes = 		_G.Details
local _
local addonName, Details222 = ...

local AceLocale = LibStub("AceLocale-3.0")
local Loc = AceLocale:GetLocale ( "Details" )
local Translit = LibStub("LibTranslit-1.0")

--lua locals
local _math_floor = math.floor
local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
local _unpack = unpack
local type = type
local _table_sort = table.sort
local _cstr = string.format
local tinsert = table.insert
local _math_min = math.min
local _math_ceil = math.ceil
--api locals
local GetSpellInfo = GetSpellInfo
local _GetSpellInfo = _detalhes.getspellinfo
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup

local _string_replace = _detalhes.string.replace --details api
local gump = 			_detalhes.gump

local detailsFramework = DetailsFramework

local alvo_da_habilidade = 	_detalhes.alvo_da_habilidade
local container_habilidades = 	_detalhes.container_habilidades
local container_combatentes =	_detalhes.container_combatentes
local healingClass =		_detalhes.atributo_heal
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

local div_abre = _detalhes.divisores.abre
local div_fecha = _detalhes.divisores.fecha
local div_lugar = _detalhes.divisores.colocacao

local ToKFunctions = _detalhes.ToKFunctions
local SelectedToKFunction = ToKFunctions [1]
local UsingCustomRightText = false
local UsingCustomLeftText = false

local FormatTooltipNumber = ToKFunctions [8]
local TooltipMaximizedMethod = 1

local headerColor = "yellow"

local breakdownWindowFrame = Details.BreakdownWindowFrame
local keyName

function healingClass:NovaTabela (serial, nome, link)
	local alphabetical = _detalhes:GetOrderNumber(nome)

	--constructor
	local thisActor = {
		tipo = class_type, --atributo 2 = cura

		total = alphabetical,
		totalover = alphabetical,
		totalabsorb = alphabetical,
		totaldenied = alphabetical,
		custom = 0,

		total_without_pet = alphabetical,
		totalover_without_pet = alphabetical,

		healing_taken = alphabetical, --total de cura que este jogador recebeu
		healing_from = {}, --armazena os nomes que deram cura neste jogador

		iniciar_hps = false,  --dps_started
		last_event = 0,
		on_hold = false,
		delay = 0,
		last_value = nil, --ultimo valor que este jogador teve, salvo quando a barra dele � atualizada
		last_hps = 0, --cura por segundo

		end_time = nil,
		start_time = 0,

		pets = {}, --nome j� formatado: pet nome <owner nome>

		heal_enemy = {}, --quando o jogador cura um inimigo
		heal_enemy_amt = 0,

		--container armazenar� os IDs das habilidades usadas por este jogador
		spells = container_habilidades:NovoContainer (container_heal),
		--container armazenar� os seriais dos alvos que o player aplicou dano
		targets = {},
		targets_overheal = {},
		targets_absorbs = {}
	}

	detailsFramework:Mixin(thisActor, Details222.Mixins.ActorMixin)
	setmetatable(thisActor, healingClass)

	return thisActor
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--npc healing taken

--local npchealingtaken_tooltip_background = {value = 100, color = {0.1960, 0.1960, 0.1960, 0.9097}, texture = [[Interface\AddOns\Details\images\bar_background2]]}

--tooltip function

local on_switch_NHT_show = function(instance) --npc healing taken
	instance:TrocaTabela(instance, true, 1, 8)
	return true
end

--local NHT_search_code = [[]]


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
	_table_sort (container, _detalhes.SortKeySimpleHeal)

	if (amount) then
		for i = amount, 1, -1 do --de tr�s pra frente
			if (container[i][keyName] < 1) then
				amount = amount-1
			else
				break
			end
		end

		return amount
	end
end

function healingClass:ContainerRefreshHps (container, combat_time)

	local total = 0

	if (_detalhes.time_type == 2 or _detalhes.time_type == 3 or not _detalhes:CaptureGet("heal")) then
		for _, actor in ipairs(container) do
			if (actor.grupo) then
				actor.last_hps = actor.total / combat_time
			else
				actor.last_hps = actor.total / actor:Tempo()
			end
			total = total + actor.last_hps
		end
	else
		for _, actor in ipairs(container) do
			actor.last_hps = actor.total / actor:Tempo()
			total = total + actor.last_hps
		end
	end

	return total
end

function healingClass:ReportSingleDamagePreventedLine (actor, instancia)
	local barra = instancia.barras [actor.minha_barra]

	local reportar = {"Details!: " .. actor.nome .. " - " .. Loc ["STRING_ATTRIBUTE_HEAL_PREVENT"]}
	for i = 2, GameCooltip:GetNumLines()-2 do
		local texto_left, texto_right = GameCooltip:GetText (i)
		if (texto_left and texto_right) then
			texto_left = texto_left:gsub(("|T(.*)|t "), "")
			reportar [#reportar+1] = ""..texto_left.." "..texto_right..""
		end
	end

	return _detalhes:Reportar (reportar, {_no_current = true, _no_inverse = true, _custom = true})
end

function healingClass:RefreshWindow (instancia, tabela_do_combate, forcar, exportar)

	local showing = tabela_do_combate [class_type] --o que esta sendo mostrado -> [1] - dano [2] - cura

	--n�o h� barras para mostrar -- not have something to show
	if (#showing._ActorTable < 1) then --n�o h� barras para mostrar
		--colocado isso recentemente para fazer as barras de dano sumirem na troca de atributo
		return _detalhes:HideBarsNotInUse(instancia, showing), "", 0, 0
	end

	--total
	local total = 0
	--top actor #1
	instancia.top = 0

	local using_cache = false

	local sub_atributo = instancia.sub_atributo --o que esta sendo mostrado nesta inst�ncia
	local conteudo = showing._ActorTable
	local amount = #conteudo
	local modo = instancia.modo

	--pega qual a sub key que ser� usada
	if (exportar) then

		if (type(exportar) == "boolean") then
			if (sub_atributo == 1) then --healing DONE
				keyName = "total"
			elseif (sub_atributo == 2) then --HPS
				keyName = "last_hps"
			elseif (sub_atributo == 3) then --overheal
				keyName = "totalover"
			elseif (sub_atributo == 4) then --healing take
				keyName = "healing_taken"
			elseif (sub_atributo == 5) then --enemy heal
				keyName = "heal_enemy_amt"
			elseif (sub_atributo == 6) then --absorbs
				keyName = "totalabsorb"
			elseif (sub_atributo == 7) then --heal absorb
				keyName = "totaldenied"
			end
		else
			keyName = exportar.key
			modo = exportar.modo
		end
	elseif (instancia.atributo == 5) then --custom
		keyName = "custom"
		total = tabela_do_combate.totals [instancia.customName]
	else
		if (sub_atributo == 1) then --healing DONE
			keyName = "total"
		elseif (sub_atributo == 2) then --HPS
			keyName = "last_hps"
		elseif (sub_atributo == 3) then --overheal
			keyName = "totalover"
		elseif (sub_atributo == 4) then --healing take
			keyName = "healing_taken"
		elseif (sub_atributo == 5) then --enemy heal
			keyName = "heal_enemy_amt"
		elseif (sub_atributo == 6) then --absorbs
			keyName = "totalabsorb"
		elseif (sub_atributo == 7) then --heal absorb
			keyName = "totaldenied"
		end
	end

	if (instancia.atributo == 5) then --custom
		--faz o sort da categoria e retorna o amount corrigido
		amount = _detalhes:ContainerSortHeal (conteudo, amount, keyName)

		--grava o total
		instancia.top = conteudo[1][keyName]

	elseif (instancia.modo == modo_ALL or sub_atributo == 5 or sub_atributo == 7) then --mostrando ALL

		amount = _detalhes:ContainerSortHeal (conteudo, amount, keyName)

		if (sub_atributo == 2) then --hps
			local combat_time = instancia.showing:GetCombatTime()
			total = healingClass:ContainerRefreshHps (conteudo, combat_time)
		else
			--pega o total ja aplicado na tabela do combate
			total = tabela_do_combate.totals [class_type]
		end

		--grava o total
		instancia.top = conteudo[1][keyName]

	elseif (instancia.modo == modo_GROUP) then --mostrando GROUP

		if (_detalhes.in_combat and instancia.segmento == 0 and not exportar) then
			using_cache = true
		end

		if (using_cache) then
			conteudo = _detalhes.cache_healing_group

			if (sub_atributo == 2) then --hps
				local combat_time = instancia.showing:GetCombatTime()
				healingClass:ContainerRefreshHps (conteudo, combat_time)
			end

			if (#conteudo < 1) then
				return _detalhes:HideBarsNotInUse(instancia, showing), "", 0, 0
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
			if (sub_atributo == 2) then --hps
				local combat_time = instancia.showing:GetCombatTime()
				healingClass:ContainerRefreshHps (conteudo, combat_time)
			end

			_detalhes.SortGroupHeal (conteudo, keyName)
		end
		--
		if (not using_cache) then
			for index, player in ipairs(conteudo) do
				if (player.grupo) then --� um player e esta em grupo
					if (player[keyName] < 1) then --dano menor que 1, interromper o loop
						amount = index - 1
						break
					elseif (index == 1) then --esse IF aqui, precisa mesmo ser aqui? n�o daria pra pega-lo com uma chave [1] nad grupo == true?
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

	--refaz o mapa do container
	--se for cache n�o precisa remapear
	showing:remapear()

	if (exportar) then
		return total, keyName, instancia.top, amount
	end

	if (amount < 1) then --n�o h� barras para mostrar
		instancia:EsconderScrollBar()
		return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --retorna a tabela que precisa ganhar o refresh
	end

	--estra mostrando ALL ent�o posso seguir o padr�o correto? primeiro, atualiza a scroll bar...
	instancia:RefreshScrollBar (amount)

	--depois faz a atualiza��o normal dele atrav�s dos iterators
	local whichRowLine = 1
	local barras_container = instancia.barras --evita buscar N vezes a key .barras dentro da inst�ncia
	local percentage_type = instancia.row_info.percent_type
	local bars_show_data = instancia.row_info.textR_show_data
	local bars_brackets = instancia:GetBarBracket()
	local bars_separator = instancia:GetBarSeparator()
	local baseframe = instancia.baseframe

	local use_animations = _detalhes.is_using_row_animations and (not baseframe.isStretching and not forcar and not baseframe.isResizing)

	if (total == 0) then
		total = 0.00000001
	end

	local myPos
	local following = instancia.following.enabled

	if (following) then
		if (using_cache) then
			local pname = _detalhes.playername
			for i, actor in ipairs(conteudo) do
				if (actor.nome == pname) then
					myPos = i
					break
				end
			end
		else
			myPos = showing._NameIndexTable [_detalhes.playername]
		end
	end

	local combat_time = instancia.showing:GetCombatTime()
	UsingCustomLeftText = instancia.row_info.textL_enable_custom_text
	UsingCustomRightText = instancia.row_info.textR_enable_custom_text

	local use_total_bar = false
	if (instancia.total_bar.enabled) then
		use_total_bar = true

		if (instancia.total_bar.only_in_group and (not IsInGroup() and not IsInRaid())) then
			use_total_bar = false
		end
	end

	if (instancia.bars_sort_direction == 1) then --top to bottom

		if (use_total_bar and instancia.barraS[1] == 1) then

			whichRowLine = 2
			local iter_last = instancia.barraS[2]
			if (iter_last == instancia.rows_fit_in_window) then
				iter_last = iter_last - 1
			end

			local row1 = barras_container [1]
			row1.minha_tabela = nil
			row1.lineText1:SetText(Loc ["STRING_TOTAL"])
			if (instancia.use_multi_fontstrings) then
				instancia:SetInLineTexts(row1, "", _detalhes:ToK2 (total), _detalhes:ToK (total / combat_time))
			else
				row1.lineText4:SetText(_detalhes:ToK2 (total) .. " (" .. _detalhes:ToK (total / combat_time) .. ")")
			end

			row1:SetValue(100)
			local r, g, b = unpack(instancia.total_bar.color)
			row1.textura:SetVertexColor(r, g, b)

			row1.icone_classe:SetTexture(instancia.total_bar.icon)
			row1.icone_classe:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)

			Details.FadeHandler.Fader(row1, "out")

			if (following and myPos and myPos+1 > instancia.rows_fit_in_window and instancia.barraS[2] < myPos+1) then
				for i = instancia.barraS[1], iter_last-1, 1 do --vai atualizar s� o range que esta sendo mostrado
					if (conteudo[i]) then
						conteudo[i]:RefreshLine(instancia, barras_container, whichRowLine, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator)
						whichRowLine = whichRowLine+1
					end
				end

				conteudo[myPos]:RefreshLine(instancia, barras_container, whichRowLine, myPos, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator)
				whichRowLine = whichRowLine+1
			else

				for i = instancia.barraS[1], iter_last, 1 do --vai atualizar s� o range que esta sendo mostrado
					if (conteudo[i]) then
						conteudo[i]:RefreshLine(instancia, barras_container, whichRowLine, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator)
						whichRowLine = whichRowLine+1
					end
				end
			end

		else
			if (following and myPos and myPos > instancia.rows_fit_in_window and instancia.barraS[2] < myPos) then
				for i = instancia.barraS[1], instancia.barraS[2]-1, 1 do --vai atualizar s� o range que esta sendo mostrado
					if (conteudo[i]) then
						conteudo[i]:RefreshLine(instancia, barras_container, whichRowLine, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator)
						whichRowLine = whichRowLine+1
					end
				end

				conteudo[myPos]:RefreshLine(instancia, barras_container, whichRowLine, myPos, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator)
				whichRowLine = whichRowLine+1
			else
				for i = instancia.barraS[1], instancia.barraS[2], 1 do --vai atualizar s� o range que esta sendo mostrado
					if (conteudo[i]) then
						conteudo[i]:RefreshLine(instancia, barras_container, whichRowLine, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator)
						whichRowLine = whichRowLine+1
					end
				end
			end
		end

	elseif (instancia.bars_sort_direction == 2) then --bottom to top

		if (use_total_bar and instancia.barraS[1] == 1) then

			whichRowLine = 2
			local iter_last = instancia.barraS[2]
			if (iter_last == instancia.rows_fit_in_window) then
				iter_last = iter_last - 1
			end

			local row1 = barras_container [1]
			row1.minha_tabela = nil
			row1.lineText1:SetText(Loc ["STRING_TOTAL"])
			--
			if (instancia.use_multi_fontstrings) then
				instancia:SetInLineTexts(row1, "", _detalhes:ToK2(total), _detalhes:ToK(total / combat_time))
			else
				row1.lineText4:SetText(_detalhes:ToK2 (total) .. " (" .. _detalhes:ToK (total / combat_time) .. ")")
			end

			row1:SetValue(100)
			local r, g, b = unpack(instancia.total_bar.color)
			row1.textura:SetVertexColor(r, g, b)

			row1.icone_classe:SetTexture(instancia.total_bar.icon)
			row1.icone_classe:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)

			Details.FadeHandler.Fader(row1, "out")

			if (following and myPos and myPos+1 > instancia.rows_fit_in_window and instancia.barraS[2] < myPos+1) then
				conteudo[myPos]:RefreshLine(instancia, barras_container, whichRowLine, myPos, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator)
				whichRowLine = whichRowLine+1
				for i = iter_last-1, instancia.barraS[1], -1 do --vai atualizar s� o range que esta sendo mostrado
					if (conteudo[i]) then
						conteudo[i]:RefreshLine(instancia, barras_container, whichRowLine, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator)
						whichRowLine = whichRowLine+1
					end
				end
			else
				for i = iter_last, instancia.barraS[1], -1 do --vai atualizar s� o range que esta sendo mostrado
					if (conteudo[i]) then
						conteudo[i]:RefreshLine(instancia, barras_container, whichRowLine, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator)
						whichRowLine = whichRowLine+1
					end
				end
			end
		else
			if (following and myPos and myPos > instancia.rows_fit_in_window and instancia.barraS[2] < myPos) then
				conteudo[myPos]:RefreshLine(instancia, barras_container, whichRowLine, myPos, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator)
				whichRowLine = whichRowLine+1
				for i = instancia.barraS[2]-1, instancia.barraS[1], -1 do --vai atualizar s� o range que esta sendo mostrado
					if (conteudo[i]) then
						conteudo[i]:RefreshLine(instancia, barras_container, whichRowLine, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator)
						whichRowLine = whichRowLine+1
					end
				end
			else
				for i = instancia.barraS[2], instancia.barraS[1], -1 do --vai atualizar s� o range que esta sendo mostrado
					if (conteudo[i]) then
						conteudo[i]:RefreshLine(instancia, barras_container, whichRowLine, i, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator)
						whichRowLine = whichRowLine+1
					end
				end
			end
		end

	end

	if (use_animations) then
		instancia:PerformAnimations (whichRowLine - 1)
	end

	if (instancia.atributo == 5) then --custom
		--zerar o .custom dos Actors
		for index, player in ipairs(conteudo) do
			if (player.custom > 0) then
				player.custom = 0
			else
				break
			end
		end
	end

	--beta, hidar barras n�o usadas durante um refresh for�ado
	if (forcar) then
		if (instancia.modo == 2) then --group
			for i = whichRowLine, instancia.rows_fit_in_window  do
				Details.FadeHandler.Fader(instancia.barras [i], "in", Details.fade_speed)
			end
		end
	end

	instancia:AutoAlignInLineFontStrings()

	-- showing.need_refresh = false
	return Details:EndRefresh (instancia, total, tabela_do_combate, showing) --retorna a tabela que precisa ganhar o refresh

end

local actor_class_color_r, actor_class_color_g, actor_class_color_b

--function atributo_heal:RefreshLine(instancia, whichRowLine, lugar, total, sub_atributo, forcar)
function healingClass:RefreshLine(instancia, barras_container, whichRowLine, lugar, total, sub_atributo, forcar, keyName, combat_time, percentage_type, use_animations, bars_show_data, bars_brackets, bars_separator)

	local thisLine = instancia.barras[whichRowLine] --pega a refer�ncia da barra na janela

	if (not thisLine) then
		print("DEBUG: problema com <instancia.thisLine> "..whichRowLine.." "..lugar)
		return
	end

	local tabela_anterior = thisLine.minha_tabela

	thisLine.minha_tabela = self --grava uma refer�ncia dessa classe de dano na barra
	self.minha_barra = thisLine --salva uma refer�ncia da barra no objeto do jogador

	thisLine.colocacao = lugar --salva na barra qual a coloca��o dela.
	self.colocacao = lugar --salva qual a coloca��o do jogador no objeto dele

	local healing_total = self.total --total de dano que este jogador deu
	local hps

	--local porcentagem = self [keyName] / total * 100
	local porcentagem
	local esta_porcentagem

	if (percentage_type == 1) then
		porcentagem = _cstr ("%.1f", self [keyName] / total * 100)

	elseif (percentage_type == 2) then
		porcentagem = _cstr ("%.1f", self [keyName] / instancia.top * 100)
	end

	if ((_detalhes.time_type == 2 and self.grupo) or _detalhes.time_type == 3 or (not _detalhes:CaptureGet("heal") and not _detalhes:CaptureGet("aura")) or instancia.segmento == -1) then
		if (instancia.segmento == -1 and combat_time == 0) then
			local p = _detalhes.tabela_vigente(2, self.nome)
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
	else -- /dump _detalhes:GetCombat(2)(1, "Ditador").on_hold
		if (not self.on_hold) then
			hps = healing_total/self:Tempo() --calcula o dps deste objeto
			self.last_hps = hps --salva o dps dele
		else
			hps = self.last_hps

			if (hps == 0) then --n�o calculou o dps dele ainda mas entrou em standby
				hps = healing_total/self:Tempo()
				self.last_hps = hps
			end
		end
	end

	-- >>>>>>>>>>>>>>> texto da direita
	if (instancia.atributo == 5) then --custom
		--
		if (instancia.use_multi_fontstrings) then
			instancia:SetInLineTexts(thisLine, "", _detalhes:ToK (self.custom), porcentagem .. "%")
		else
			thisLine.lineText4:SetText(_detalhes:ToK (self.custom) .. " (" .. porcentagem .. "%)")
		end
		esta_porcentagem = _math_floor((self.custom/instancia.top) * 100)

	else
		if (sub_atributo == 1) then --mostrando healing done

			hps = _math_floor(hps)
			local formated_heal = SelectedToKFunction (_, healing_total)
			local formated_hps = SelectedToKFunction (_, hps)
			thisLine.ps_text = formated_hps

			if (not bars_show_data [1]) then
				formated_heal = ""
			end
			if (not bars_show_data [2]) then
				formated_hps = ""
			end
			if (not bars_show_data [3]) then
				porcentagem = ""
			else
				porcentagem = porcentagem .. "%"
			end

			local rightText = formated_heal .. bars_brackets[1] .. formated_hps .. bars_separator .. porcentagem .. bars_brackets[2]
			if (UsingCustomRightText) then
				thisLine.lineText4:SetText(_string_replace (instancia.row_info.textR_custom_text, formated_heal, formated_hps, porcentagem, self, instancia.showing, instancia, rightText))
			else
				if (instancia.use_multi_fontstrings) then
					instancia:SetInLineTexts(thisLine, formated_heal, formated_hps, porcentagem)
				else
					thisLine.lineText4:SetText(rightText)
				end
			end
			esta_porcentagem = _math_floor((healing_total/instancia.top) * 100)

		elseif (sub_atributo == 2) then --mostrando hps

			hps = _math_floor(hps)
			local formated_heal = SelectedToKFunction (_, healing_total)
			local formated_hps = SelectedToKFunction (_, hps)
			thisLine.ps_text = formated_hps

			if (not bars_show_data [1]) then
				formated_hps = ""
			end
			if (not bars_show_data [2]) then
				formated_heal = ""
			end
			if (not bars_show_data [3]) then
				porcentagem = ""
			else
				porcentagem = porcentagem .. "%"
			end

			local rightText = formated_hps .. bars_brackets[1] .. formated_heal .. bars_separator .. porcentagem .. bars_brackets[2]
			if (UsingCustomRightText) then
				thisLine.lineText4:SetText(_string_replace (instancia.row_info.textR_custom_text, formated_hps, formated_heal, porcentagem, self, instancia.showing, instancia, rightText))
			else
				if (instancia.use_multi_fontstrings) then
					instancia:SetInLineTexts(thisLine, formated_hps, formated_heal, porcentagem)
				else
					thisLine.lineText4:SetText(rightText)
				end
			end

			esta_porcentagem = _math_floor((hps/instancia.top) * 100)

		elseif (sub_atributo == 3) then --mostrando overall

			local formated_overheal = SelectedToKFunction (_, self.totalover)

			local percent = self.totalover / (self.totalover + self.total) * 100
			local overheal_percent = _cstr ("%.1f", percent)

			local rr, gg, bb = _detalhes:percent_color (percent, true)
			rr, gg, bb = _detalhes:hex (_math_floor(rr*255)), _detalhes:hex (_math_floor(gg*255)), _detalhes:hex (_math_floor(bb*255))
			overheal_percent = "|cFF" .. rr .. gg .. bb .. overheal_percent .. "|r"

			if (not bars_show_data [1]) then
				formated_overheal = ""
			end
			if (not bars_show_data [3]) then
				overheal_percent = ""
			else
				overheal_percent = overheal_percent .. "%"
			end

			local rightText = formated_overheal .. bars_brackets[1] .. overheal_percent .. bars_brackets[2]
			if (UsingCustomRightText) then
				thisLine.lineText4:SetText(_string_replace (instancia.row_info.textR_custom_text, formated_overheal, "", overheal_percent, self, instancia.showing, instancia, rightText))
			else
				if (instancia.use_multi_fontstrings) then
					instancia:SetInLineTexts(thisLine, "", formated_overheal, overheal_percent)
				else
					thisLine.lineText4:SetText(rightText)
				end
			end

			esta_porcentagem = _math_floor((self.totalover/instancia.top) * 100)

		elseif (sub_atributo == 4) then --mostrando healing taken

			local formated_healtaken = SelectedToKFunction (_, self.healing_taken)

			if (not bars_show_data [1]) then
				formated_healtaken = ""
			end
			if (not bars_show_data [3]) then
				porcentagem = ""
			else
				porcentagem = porcentagem .. "%"
			end

			local rightText = formated_healtaken .. bars_brackets[1] .. porcentagem .. bars_brackets[2]
			if (UsingCustomRightText) then
				thisLine.lineText4:SetText(_string_replace (instancia.row_info.textR_custom_text, formated_healtaken, "", porcentagem, self, instancia.showing, instancia, rightText))
			else
				if (instancia.use_multi_fontstrings) then
					instancia:SetInLineTexts(thisLine, "", formated_healtaken, porcentagem)
				else
					thisLine.lineText4:SetText(rightText)
				end
			end

			esta_porcentagem = _math_floor((self.healing_taken/instancia.top) * 100)

		elseif (sub_atributo == 5) then --mostrando enemy heal

			local formated_enemyheal = SelectedToKFunction (_, self.heal_enemy_amt)

			if (not bars_show_data [1]) then
				formated_enemyheal = ""
			end
			if (not bars_show_data [3]) then
				porcentagem = ""
			else
				porcentagem = porcentagem .. "%"
			end

			local rightText = formated_enemyheal .. bars_brackets[1] .. porcentagem .. bars_brackets[2]
			if (UsingCustomRightText) then
				thisLine.lineText4:SetText(_string_replace (instancia.row_info.textR_custom_text, formated_enemyheal, "", porcentagem, self, instancia.showing, instancia, rightText))
			else
				if (instancia.use_multi_fontstrings) then
					instancia:SetInLineTexts(thisLine, "", formated_enemyheal, porcentagem)
				else
					thisLine.lineText4:SetText(rightText)
				end
			end
			esta_porcentagem = _math_floor((self.heal_enemy_amt/instancia.top) * 100)

		elseif (sub_atributo == 6) then --mostrando damage prevented

			local formated_absorbs = SelectedToKFunction (_, self.totalabsorb)

			if (not bars_show_data [1]) then
				formated_absorbs = ""
			end
			if (not bars_show_data [3]) then
				porcentagem = ""
			else
				porcentagem = porcentagem .. "%"
			end

			local rightText = formated_absorbs .. bars_brackets[1] .. porcentagem .. bars_brackets[2]
			if (UsingCustomRightText) then
				thisLine.lineText4:SetText(_string_replace (instancia.row_info.textR_custom_text, formated_absorbs, "", porcentagem, self, instancia.showing, instancia, rightText))
			else
				if (instancia.use_multi_fontstrings) then
					instancia:SetInLineTexts(thisLine, "", formated_absorbs, porcentagem)
				else
					thisLine.lineText4:SetText(rightText)
				end
			end
			esta_porcentagem = _math_floor((self.totalabsorb/instancia.top) * 100)

		elseif (sub_atributo == 7) then --mostrando cura negada

			local formated_absorbs = SelectedToKFunction (_, self.totaldenied)

			if (not bars_show_data [1]) then
				formated_absorbs = ""
			end
			if (not bars_show_data [3]) then
				porcentagem = ""
			else
				porcentagem = porcentagem .. "%"
			end

			local rightText = formated_absorbs .. bars_brackets[1] .. porcentagem .. bars_brackets[2]
			if (UsingCustomRightText) then
				thisLine.lineText4:SetText(_string_replace (instancia.row_info.textR_custom_text, formated_absorbs, "", porcentagem, self, instancia.showing, instancia, rightText))
			else
				if (instancia.use_multi_fontstrings) then
					instancia:SetInLineTexts(thisLine, "", formated_absorbs, porcentagem)
				else
					thisLine.lineText4:SetText(rightText)
				end
			end
			esta_porcentagem = _math_floor((self.totaldenied/instancia.top) * 100)

		end
	end

	if (thisLine.mouse_over and not instancia.baseframe.isMoving) then --precisa atualizar o tooltip
		gump:UpdateTooltip (whichRowLine, thisLine, instancia)
	end

	actor_class_color_r, actor_class_color_g, actor_class_color_b = self:GetBarColor()

	return self:RefreshBarra2 (thisLine, instancia, tabela_anterior, forcar, esta_porcentagem, whichRowLine, barras_container, use_animations)
end

function healingClass:RefreshBarra2 (thisLine, instancia, tabela_anterior, forcar, esta_porcentagem, whichRowLine, barras_container, use_animations)

	--primeiro colocado
	if (thisLine.colocacao == 1) then
		if (not tabela_anterior or tabela_anterior ~= thisLine.minha_tabela or forcar) then
			thisLine:SetValue(100)

			if (thisLine.hidden or thisLine.fading_in or thisLine.faded) then
				Details.FadeHandler.Fader(thisLine, "out")
			end

			return self:RefreshBarra(thisLine, instancia)
		else
			return
		end
	else

		if (thisLine.hidden or thisLine.fading_in or thisLine.faded) then

			thisLine:SetValue(esta_porcentagem)
			if (use_animations) then
				thisLine.animacao_fim = esta_porcentagem
			else
				thisLine.animacao_ignorar = true
			end

			Details.FadeHandler.Fader(thisLine, "out")

			if (instancia.row_info.texture_class_colors) then
				thisLine.textura:SetVertexColor(actor_class_color_r, actor_class_color_g, actor_class_color_b)
			end
			if (instancia.row_info.texture_background_class_color) then
				thisLine.background:SetVertexColor(actor_class_color_r, actor_class_color_g, actor_class_color_b)
			end

			return self:RefreshBarra(thisLine, instancia)

		else
			--agora esta comparando se a tabela da barra � diferente da tabela na atualiza��o anterior
			if (not tabela_anterior or tabela_anterior ~= thisLine.minha_tabela or forcar) then --aqui diz se a barra do jogador mudou de posi��o ou se ela apenas ser� atualizada

				if (use_animations) then
					thisLine.animacao_fim = esta_porcentagem
				else
					thisLine:SetValue(esta_porcentagem)
					thisLine.animacao_ignorar = true
				end

				thisLine.last_value = esta_porcentagem --reseta o ultimo valor da barra

				return self:RefreshBarra(thisLine, instancia)

			elseif (esta_porcentagem ~= thisLine.last_value) then --continua mostrando a mesma tabela ent�o compara a porcentagem
				--apenas atualizar
				if (use_animations) then
					thisLine.animacao_fim = esta_porcentagem
				else
					thisLine:SetValue(esta_porcentagem)
				end
				thisLine.last_value = esta_porcentagem

				return self:RefreshBarra(thisLine, instancia)
			end
		end

	end

end

function healingClass:RefreshBarra(thisLine, instancia, from_resize)

	local class, enemy, arena_enemy, arena_ally = self.classe, self.enemy, self.arena_enemy, self.arena_ally

	if (from_resize) then
		actor_class_color_r, actor_class_color_g, actor_class_color_b = self:GetBarColor()
	end

	--icon
	self:SetClassIcon (thisLine.icone_classe, instancia, class)
	
	if(thisLine.mouse_over) then
		local classIcon = thisLine:GetClassIcon()
		thisLine.iconHighlight:SetTexture(classIcon:GetTexture())
		thisLine.iconHighlight:SetTexCoord(classIcon:GetTexCoord())
		thisLine.iconHighlight:SetVertexColor(classIcon:GetVertexColor())
	end
	--texture color
	self:SetBarColors(thisLine, instancia, actor_class_color_r, actor_class_color_g, actor_class_color_b)
	--left text
	self:SetBarLeftText (thisLine, instancia, enemy, arena_enemy, arena_ally, UsingCustomLeftText)

	thisLine.lineText1:SetSize(thisLine:GetWidth() - thisLine.lineText4:GetStringWidth() - 20, 15)

end

function _detalhes:CloseShields(combat)
	if (not _detalhes.parser_options.shield_overheal) then
		return
	end

	local shieldCache = _detalhes.ShieldCache
	local container = combat[2]
	local timeNow = time()
	local parser = _detalhes.parser
	local getSpellInfo = GetSpellInfo --does not add the spell into the spell info cache

	for targetName, spellid_table in pairs(shieldCache) do
		local tgt = container:PegarCombatente (_, targetName)
		if (tgt) then
			for spellid, owner_table in pairs(spellid_table) do
				local spellname = getSpellInfo(spellid)
				for owner, amount in pairs(owner_table) do
					if (amount > 0) then
						local obj = container:PegarCombatente (_, owner)
						if (obj) then
							parser:heal("SPELL_AURA_REMOVED", timeNow, obj.serial, owner, obj.flag_original, tgt.serial, targetName, tgt.flag_original, nil, spellid, spellname, nil, 0, _math_ceil (amount), 0, 0, nil, true)
						end
					end
				end
			end
		end
	end
end

--------------------------------------------- // TOOLTIPS // ---------------------------------------------


---------TOOLTIPS BIFURCA��O ~tooltip
function healingClass:ToolTip (instancia, numero, barra, keydown)
	--seria possivel aqui colocar o icone da classe dele?

	if (instancia.atributo == 5) then --custom
		return self:TooltipForCustom (barra)
	else
		--GameTooltip:ClearLines()
		--GameTooltip:AddLine(barra.colocacao..". "..self.nome)
		if (instancia.sub_atributo <= 3) then --healing done, HPS or Overheal
			return self:ToolTip_HealingDone (instancia, numero, barra, keydown)
		elseif (instancia.sub_atributo == 6) then --healing done, HPS or Overheal
			return self:ToolTip_HealingDone (instancia, numero, barra, keydown)
		elseif (instancia.sub_atributo == 4) then --healing taken
			return self:ToolTip_HealingTaken (instancia, numero, barra, keydown)
		elseif (instancia.sub_atributo == 7) then --heal denied
			return self:ToolTip_HealingDenied (instancia, numero, barra, keydown)
		end
	end
end
--tooltip locals
local r, g, b
local barAlha = .6

---------HEAL DENIED
function healingClass:ToolTip_HealingDenied (instancia, numero, barra, keydown)

	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack(_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack(_detalhes.class_colors [self.classe])
	end

	local container = instancia.showing [2]
	local totalDenied = self.totaldenied

	local spellList = {} --spells the player used to deny heal
	local targetList = {} --all players affected
	local spellsDenied = {} --all spells which had heal denied
	local healersDenied = {} --heal denied on healers

	local icon_size = _detalhes.tooltip.icon_size
	local icon_border = _detalhes.tooltip.icon_border_texcoord

	for spellID, spell in pairs(self.spells._ActorTable) do
		if (spell.totaldenied > 0 and spell.heal_denied) then
			--my spells which denied heal
			tinsert(spellList, {spell, spell.totaldenied})

			--players affected
			for playerName, amount in pairs(spell.targets) do
				targetList [playerName] = (targetList [playerName] or 0) + amount
			end

			--spells with heal denied
			for spellID, amount in pairs(spell.heal_denied) do
				spellsDenied [spellID] = (spellsDenied [spellID] or 0) + amount
			end

			--healers denied
			for healerName, amount in pairs(spell.heal_denied_healers) do
				healersDenied [healerName] = (healersDenied [healerName] or 0) + amount
			end
		end
	end

	--Spells
		table.sort (spellList, _detalhes.Sort2)
		--_detalhes:AddTooltipSpellHeaderText ("Spells", headerColor, #spellList, [[Interface\TUTORIALFRAME\UI-TutorialFrame-LevelUp]], 0.10546875, 0.89453125, 0.05859375, 0.6796875)
		--_detalhes:AddTooltipHeaderStatusbar (r, g, b, barAlha)

		local ismaximized = false
		if (keydown == "shift" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 3) then
			--GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay2)
			--_detalhes:AddTooltipHeaderStatusbar (r, g, b, 1)
			ismaximized = true
		else
			--GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay1)
			--_detalhes:AddTooltipHeaderStatusbar (r, g, b, barAlha)
		end

		local tooltip_max_abilities = _detalhes.tooltip.tooltip_max_abilities
		if (ismaximized) then
			tooltip_max_abilities = 99
		end

		for i = 1, _math_min(tooltip_max_abilities, #spellList) do
			local spellObject, spellTotal = unpack(spellList [i])

			if (spellTotal < 1) then
				break
			end

			local spellName, _, spellIcon = _GetSpellInfo(spellObject.id)

			GameCooltip:AddLine(spellName .. ": ", FormatTooltipNumber (_, spellTotal) .. " (" .. _cstr ("%.1f", spellTotal / totalDenied) .."%)")

			GameCooltip:AddIcon (spellIcon, nil, nil, icon_size.W, icon_size.H, icon_border.L, icon_border.R, icon_border.T, icon_border.B)
			_detalhes:AddTooltipBackgroundStatusbar()
		end

	-- follow esta bugado com este display

	--Target Players
		local playerSorted = {}
		for playerName, amount in pairs(targetList) do
			tinsert(playerSorted, {playerName, amount})
		end
		table.sort (playerSorted, _detalhes.Sort2)
		_detalhes:AddTooltipSpellHeaderText ("Targets", headerColor, #playerSorted, [[Interface\TUTORIALFRAME\UI-TutorialFrame-LevelUp]], 0.10546875, 0.89453125, 0.05859375, 0.6796875)
		_detalhes:AddTooltipHeaderStatusbar (r, g, b, barAlha)

		local ismaximized = false
		if (keydown == "ctrl" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 4) then
			GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_ctrl]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay2)
			_detalhes:AddTooltipHeaderStatusbar (r, g, b, 1)
			ismaximized = true
		else
			GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_ctrl]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay1)
			_detalhes:AddTooltipHeaderStatusbar (r, g, b, barAlha)
		end

		local tooltip_max_abilities2 = _detalhes.tooltip.tooltip_max_targets
		if (ismaximized) then
			tooltip_max_abilities2 = 99
		end

		for i = 1, _math_min(tooltip_max_abilities2, #playerSorted) do

			local playerName, amountDenied = unpack(playerSorted [i])

			GameCooltip:AddLine(playerName .. ": ", FormatTooltipNumber (_, amountDenied) .." (" .. _cstr ("%.1f", amountDenied / totalDenied * 100) .. "%)")
			_detalhes:AddTooltipBackgroundStatusbar()

			local targetActor = container:PegarCombatente (nil, playerName) or instancia.showing [1]:PegarCombatente (nil, playerName)
			if (targetActor) then
				local classe = targetActor.classe
				if (not classe) then
					classe = "UNKNOW"
				end
				if (classe == "UNKNOW") then
					GameCooltip:AddIcon ("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, 14, 14, .25, .5, 0, 1)
				else
					GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, 14, 14, _unpack(_detalhes.class_coords [classe]))
				end
			end

		end

	-- Spells Affected
		local spellsSorted = {}
		for spellID, amount in pairs(spellsDenied) do
			tinsert(spellsSorted, {spellID, amount})
		end
		table.sort (spellsSorted, _detalhes.Sort2)
		_detalhes:AddTooltipSpellHeaderText ("Spells Affected", headerColor, #spellsSorted, [[Interface\TUTORIALFRAME\UI-TutorialFrame-LevelUp]], 0.10546875, 0.89453125, 0.05859375, 0.6796875)
		_detalhes:AddTooltipHeaderStatusbar (r, g, b, barAlha)

		local ismaximized = false
		local tooltip_max_abilities3 = _detalhes.tooltip.tooltip_max_targets
		if (keydown == "alt" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 5) then
			tooltip_max_abilities3 = 99
			ismaximized = true
		end

		for i = 1, _math_min(tooltip_max_abilities3, #spellsSorted) do

			local spellID, spellTotal = unpack(spellsSorted [i])

			if (spellTotal < 1) then
				break
			end

			local spellName, _, spellIcon = _GetSpellInfo(spellID)

			GameCooltip:AddLine(spellName .. ": ", FormatTooltipNumber (_, spellTotal) .. " (" .. _cstr ("%.1f", spellTotal / totalDenied) .."%)")

			GameCooltip:AddIcon (spellIcon, nil, nil, icon_size.W, icon_size.H, icon_border.L, icon_border.R, icon_border.T, icon_border.B)
			_detalhes:AddTooltipBackgroundStatusbar()

		end

	--healers denied

		_detalhes:AddTooltipSpellHeaderText ("Healers", headerColor, #spellsSorted, [[Interface\TUTORIALFRAME\UI-TutorialFrame-LevelUp]], 0.10546875, 0.89453125, 0.05859375, 0.6796875)
		_detalhes:AddTooltipHeaderStatusbar (r, g, b, barAlha)

		local healersSorted = {}
		for healerName, amount in pairs(healersDenied) do
			tinsert(healersSorted, {healerName, amount})
		end
		table.sort (healersSorted, _detalhes.Sort2)

		for i = 1, #healersSorted do
			local playerName, amountDenied = unpack(healersSorted [i])

			GameCooltip:AddLine(playerName .. ": ", FormatTooltipNumber (_, amountDenied) .." (" .. _cstr ("%.1f", amountDenied / totalDenied * 100) .. "%)")
			_detalhes:AddTooltipBackgroundStatusbar()

			local targetActor = container:PegarCombatente (nil, playerName) or instancia.showing [1]:PegarCombatente (nil, playerName)
			if (targetActor) then
				local classe = targetActor.classe
				if (not classe) then
					classe = "UNKNOW"
				end
				if (classe == "UNKNOW") then
					GameCooltip:AddIcon ("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, 14, 14, .25, .5, 0, 1)
				else
					GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, 14, 14, _unpack(_detalhes.class_coords [classe]))
				end
			end
	end

	return true
end

---------HEALING TAKEN
function healingClass:ToolTip_HealingTaken (instancia, numero, barra, keydown)

	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack(_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack(_detalhes.class_colors [self.classe])
	end

	local curadores = self.healing_from
	local total_curado = self.healing_taken

	local tabela_do_combate = instancia.showing
	local showing = tabela_do_combate [class_type] --o que esta sendo mostrado -> [1] - dano [2] - cura --pega o container com ._NameIndexTable ._ActorTable

	local meus_curadores = {}

	for nome, _ in pairs(curadores) do --agressores seria a lista de nomes
		local este_curador = showing._ActorTable[showing._NameIndexTable[nome]]
		if (este_curador) then --checagem por causa do total e do garbage collector que n�o limpa os nomes que deram dano
			local alvos = este_curador.targets
			local este_alvo = alvos [self.nome]
			if (este_alvo and este_alvo > 0) then
				meus_curadores [#meus_curadores+1] = {nome, este_alvo, este_curador.classe}
			end
		end
	end

	--_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_FROM"], headerColor, #meus_curadores, [[Interface\TUTORIALFRAME\UI-TutorialFrame-LevelUp]], 0.10546875, 0.89453125, 0.05859375, 0.6796875)
	--_detalhes:AddTooltipHeaderStatusbar (r, g, b, barAlha)

	local ismaximized = false

	if (keydown == "shift" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 3) then
		--GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay2)
		--_detalhes:AddTooltipHeaderStatusbar (r, g, b, 1)
		ismaximized = true
	else
		--GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay1)
		--_detalhes:AddTooltipHeaderStatusbar (r, g, b, barAlha)
	end

	_table_sort (meus_curadores, function(a, b) return a[2] > b[2] end)
	local max = #meus_curadores
	if (max > 9) then
		max = 9
	end

	if (ismaximized) then
		max = 99
	end

	local lineHeight = _detalhes.tooltip.line_height

	for i = 1, _math_min(max, #meus_curadores) do

		local onyName = _detalhes:GetOnlyName(meus_curadores[i][1])
		--translate cyrillic alphabet to western alphabet by Vardex (https://github.com/Vardex May 22, 2019)
		if (instancia.row_info.textL_translit_text) then
			onyName = Translit:Transliterate(onyName, "!")
		end

		GameCooltip:AddLine(onyName, FormatTooltipNumber (_, meus_curadores[i][2]).." (".._cstr ("%.1f", (meus_curadores[i][2]/total_curado) * 100).."%)")
		local classe = meus_curadores[i][3]
		if (not classe) then
			classe = "UNKNOW"
		end
		if (classe == "UNKNOW") then
			GameCooltip:AddIcon ("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, lineHeight, lineHeight, .25, .5, 0, 1)
		else
			local specID = _detalhes:GetSpec(meus_curadores[i][1])
			if (specID) then
				local texture, l, r, t, b = _detalhes:GetSpecIcon (specID, false)
				GameCooltip:AddIcon (texture, 1, 1, lineHeight, lineHeight, l, r, t, b)
			else
				GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, lineHeight, lineHeight, _unpack(_detalhes.class_coords [classe]))
			end
		end

		_detalhes:AddTooltipBackgroundStatusbar (false, meus_curadores[i][2] / meus_curadores[1][2] * 100)

	end

	return true
end

---------HEALING DONE / HPS / OVERHEAL
local background_heal_vs_absorbs = {value = 100, color = {1, 1, 0, .25}, specialSpark = false, texture = [[Interface\AddOns\Details\images\bar4_glass]]}

function healingClass:ToolTip_HealingDone (instancia, numero, barra, keydown)

	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack(_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack(_detalhes.class_colors [self.classe])
	end

	local ActorHealingTable = {}
	local ActorHealingTargets = {}
	local ActorSkillsContainer = self.spells._ActorTable

	local actor_key, skill_key = "total", "total"
	if (instancia.sub_atributo == 3) then
		actor_key, skill_key = "totalover", "overheal"
	elseif (instancia.sub_atributo == 6) then
		actor_key, skill_key = "totalabsorb", "totalabsorb"
	end

	local meu_tempo
	if (_detalhes.time_type == 1 or not self.grupo) then
		meu_tempo = self:Tempo()
	elseif (_detalhes.time_type == 2 or _detalhes.time_type == 3) then
		meu_tempo = instancia.showing:GetCombatTime()
	end

	local ActorTotal = self [actor_key]

	--add actor spells
	for _spellid, _skill in pairs(ActorSkillsContainer) do
		local SkillName, _, SkillIcon = _GetSpellInfo(_spellid)
		if (_skill [skill_key] > 0 or _skill.anti_heal) then
			tinsert(ActorHealingTable, {
				_spellid,
				_skill [skill_key],
				_skill [skill_key]/ActorTotal*100,
				{SkillName, nil, SkillIcon},
				_skill [skill_key]/meu_tempo,
				_skill.total,
				false,
				_skill.anti_heal,
			})
		end
	end

	--add actor pets
	for petIndex, petName in ipairs(self:Pets()) do
		local petActor = instancia.showing[class_type]:PegarCombatente (nil, petName)
		if (petActor) then
			for _spellid, _skill in pairs(petActor:GetActorSpells()) do
				if (_skill [skill_key] > 0) then
					local SkillName, _, SkillIcon = _GetSpellInfo(_spellid)
					local petName = petName:gsub((" <.*"), "")
					ActorHealingTable [#ActorHealingTable+1] = {
						_spellid,
						_skill [skill_key],
						_skill [skill_key]/ActorTotal*100,
						{SkillName, nil, SkillIcon},
						_skill [skill_key]/meu_tempo,
						_skill.total,
						petName
					}
				end
			end
		end
	end

	_table_sort (ActorHealingTable, _detalhes.Sort2)

	--TOP Curados
	ActorSkillsContainer = self.targets
	for targetName, amount in pairs(ActorSkillsContainer) do
		if (amount > 0) then
			--translate cyrillic alphabet to western alphabet by Vardex (https://github.com/Vardex May 22, 2019)
			if (instancia.row_info.textL_translit_text) then
				targetName = Translit:Transliterate(targetName, "!")
			end

			tinsert(ActorHealingTargets, {targetName, amount, amount / ActorTotal * 100})
		end
	end
	_table_sort (ActorHealingTargets, _detalhes.Sort2)

	--Mostra as habilidades no tooltip
	--_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_SPELLS"], headerColor, #ActorHealingTable, [[Interface\RAIDFRAME\Raid-Icon-Rez]], 0.109375, 0.890625, 0.0625, 0.90625)

	local ismaximized = false
	if (keydown == "shift" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 3) then
		--GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay2)
		--_detalhes:AddTooltipHeaderStatusbar (r, g, b, 1)
		ismaximized = true
	else
		--GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_shift]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay1)
		--_detalhes:AddTooltipHeaderStatusbar (r, g, b, barAlha)
	end

	local tooltip_max_abilities = _detalhes.tooltip.tooltip_max_abilities
	if (instancia.sub_atributo == 3 or instancia.sub_atributo == 2) then
		tooltip_max_abilities = 9
	end

	if (ismaximized) then
		tooltip_max_abilities = 99
	end

	local icon_size = _detalhes.tooltip.icon_size
	local icon_border = _detalhes.tooltip.icon_border_texcoord

	local topAbility = ActorHealingTable [1] and ActorHealingTable [1][2] or 0

	for i = 1, _math_min(tooltip_max_abilities, #ActorHealingTable) do
		if (ActorHealingTable[i][2] < 1) then
			local antiHeal = ActorHealingTable[i][8]
			if (not antiHeal) then
				break
			end
		end

		local spellName = ActorHealingTable[i][4][1]

		local petName = ActorHealingTable[i][7]
		if (petName) then
			spellName = spellName .. " (|cFFCCBBBB" .. petName .. "|r)"
		end

		if (instancia.sub_atributo == 2) then --hps

			local formatedTotal = FormatTooltipNumber (_,  _math_floor(ActorHealingTable[i][5]))
			local antiHeal = ActorHealingTable[i][8]
			if (antiHeal) then
				formatedTotal = formatedTotal .. " [|cFFFF5500" .. FormatTooltipNumber (_, _math_floor(antiHeal)) .." " .. Loc ["STRING_DAMAGE"] .."|r] "
			end

			GameCooltip:AddLine(spellName , formatedTotal .. " (".._cstr ("%.1f", ActorHealingTable[i][3]).."%)")

		elseif (instancia.sub_atributo == 3) then --overheal
			local overheal = ActorHealingTable[i][2]
			local total = ActorHealingTable[i][6]
			local formatedTotal = FormatTooltipNumber (_,  _math_floor(ActorHealingTable[i][2]))

			local antiHeal = ActorHealingTable[i][8]
			if (antiHeal) then
				formatedTotal = formatedTotal .. " [|cFFFF5500" .. FormatTooltipNumber (_, _math_floor(antiHeal)) .." " .. Loc ["STRING_DAMAGE"] .."|r] "
			end

			GameCooltip:AddLine(spellName .." (|cFFFF3333" .. _math_floor( (overheal / (overheal+total)) *100)  .. "%|r)", formatedTotal .. " (".._cstr ("%.1f", ActorHealingTable[i][3]).."%)")

		else
			local formatedTotal = FormatTooltipNumber (_, ActorHealingTable[i][2])
			local antiHeal = ActorHealingTable[i][8]
			if (antiHeal) then
				formatedTotal = formatedTotal .. " [|cFFFF5500" .. FormatTooltipNumber (_, _math_floor(antiHeal)) .." " .. Loc ["STRING_DAMAGE"] .."|r] "
			end
			GameCooltip:AddLine(spellName , formatedTotal .. " (" .. _cstr ("%.1f", ActorHealingTable[i][3]) .. "%)")

		end

		GameCooltip:AddIcon (ActorHealingTable[i][4][3], nil, nil, icon_size.W+4, icon_size.H+4, icon_border.L, icon_border.R, icon_border.T, icon_border.B)

		_detalhes:AddTooltipBackgroundStatusbar (false, ActorHealingTable[i][2] / topAbility * 100)
	end

	if (instancia.sub_atributo == 6) then
		GameCooltip:AddLine("")
		GameCooltip:AddLine(Loc ["STRING_REPORT_LEFTCLICK"], nil, 1, _unpack(self.click_to_report_color))
		GameCooltip:AddIcon ([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 1, 1, 12, 16, 0.015625, 0.13671875, 0.4375, 0.59765625)

		GameCooltip:ShowCooltip()
	end

	local container = instancia.showing [2]
	local topTarget = ActorHealingTargets [1] and ActorHealingTargets [1][2] or 0

	if (instancia.sub_atributo == 1) then -- 1 or 2 -> healing done or hps
		_detalhes:AddTooltipSpellHeaderText ("", headerColor, 1, false, 0.1, 0.9, 0.1, 0.9, true) --add a space
		_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_TARGETS"], headerColor, #ActorHealingTargets, [[Interface\TUTORIALFRAME\UI-TutorialFrame-LevelUp]], 0.10546875, 0.89453125, 0.05859375, 0.6796875)

		local ismaximized = false
		if (keydown == "ctrl" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 4) then
			GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_ctrl]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay2)
			_detalhes:AddTooltipHeaderStatusbar (r, g, b, 1)
			ismaximized = true
		else
			GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_ctrl]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay1)
			_detalhes:AddTooltipHeaderStatusbar (r, g, b, barAlha)
		end

		local tooltip_max_abilities2 = _detalhes.tooltip.tooltip_max_targets
		if (ismaximized) then
			tooltip_max_abilities2 = 99
		end

		for i = 1, _math_min(tooltip_max_abilities2, #ActorHealingTargets) do
			if (ActorHealingTargets[i][2] < 1) then
				break
			end

			if (ismaximized and ActorHealingTargets[i][1]:find(_detalhes.playername)) then
				GameCooltip:AddLine(ActorHealingTargets[i][1], FormatTooltipNumber (_, ActorHealingTargets[i][2]) .." (".._cstr ("%.1f", ActorHealingTargets[i][3]).."%)", nil, "yellow")
				GameCooltip:AddStatusBar (100, 1, .5, .5, .5, .7)
			else
				GameCooltip:AddLine(ActorHealingTargets[i][1], FormatTooltipNumber (_, ActorHealingTargets[i][2]) .." (".._cstr ("%.1f", ActorHealingTargets[i][3]).."%)")
				_detalhes:AddTooltipBackgroundStatusbar (false, ActorHealingTargets[i][2] / topTarget * 100)
			end

			local targetActor = container:PegarCombatente (nil, ActorHealingTargets[i][1])

			if (targetActor) then
				local classe = targetActor.classe
				if (not classe) then
					classe = "UNKNOW"
				end
				if (classe == "UNKNOW") then
					GameCooltip:AddIcon ("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, icon_size.W, icon_size.H, .25, .5, 0, 1)
				else
					GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, icon_size.W, icon_size.H, _unpack(_detalhes.class_coords [classe]))
				end
			end
		end
	end

	--PETS
	local meus_pets = self.pets

	if (#meus_pets > 0 and (instancia.sub_atributo == 1 or instancia.sub_atributo == 2 or instancia.sub_atributo == 3)) then --teve ajudantes

		local quantidade = {} --armazena a quantidade de pets iguais
		local totais = {} --armazena o dano total de cada objeto

		for index, nome in ipairs(meus_pets) do
			if (not quantidade [nome]) then
				quantidade [nome] = 1

				local my_self = instancia.showing [class_type]:PegarCombatente (nil, nome)

				if (my_self) then
					local meu_tempo
					if (_detalhes.time_type == 1 or not self.grupo) then
						meu_tempo = my_self:Tempo()
					elseif (_detalhes.time_type == 2 or _detalhes.time_type == 3) then
						meu_tempo = instancia.showing:GetCombatTime()
					end

					if (instancia.sub_atributo == 3) then
						totais [#totais+1] = {nome, my_self.totalover, my_self.total_without_pet}
					else
						totais [#totais+1] = {nome, my_self.total_without_pet, my_self.total_without_pet / meu_tempo}
					end

				end

			else
				quantidade [nome] = quantidade [nome]+1
			end
		end

		local added_logo = false

		_table_sort (totais, _detalhes.Sort2)

		local ismaximized = false
		if (keydown == "alt" or TooltipMaximizedMethod == 2 or TooltipMaximizedMethod == 5) then
			ismaximized = true
		end

		for index, _table in ipairs(totais) do

			if (_table [2] >= 1 and (index < 3 or ismaximized)) then

				if (not added_logo) then
					added_logo = true
					_detalhes:AddTooltipSpellHeaderText ("", headerColor, 1, false, 0.1, 0.9, 0.1, 0.9, true) --add a space
					_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_PETS"], headerColor, #totais, [[Interface\COMMON\friendship-heart]], 0.21875, 0.78125, 0.09375, 0.6875)

					if (ismaximized) then
						GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_alt]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay2)
						_detalhes:AddTooltipHeaderStatusbar (r, g, b, 1)
					else
						GameCooltip:AddIcon ([[Interface\AddOns\Details\images\key_alt]], 1, 2, _detalhes.tooltip_key_size_width, _detalhes.tooltip_key_size_height, 0, 1, 0, 0.640625, _detalhes.tooltip_key_overlay1)
						_detalhes:AddTooltipHeaderStatusbar (r, g, b, barAlha)
					end

				end

				local n = _table [1]:gsub(("%s%<.*"), "")
				if (instancia.sub_atributo == 3) then --overheal
					GameCooltip:AddLine(n .. " (|cFFFF3333" .. _math_floor( (_table [2] / (_table [2] + _table [3])) * 100)  .. "%|r):", FormatTooltipNumber (_,  _math_floor(_table [2])) .. " (" .. _math_floor( (_table [2] / (_table [2] + _table [3])) * 100) .. "%)")

				elseif (instancia.sub_atributo == 2) then --hps
					GameCooltip:AddLine(n, FormatTooltipNumber (_,  _math_floor(_table [3])) .. " (" .. _math_floor(_table [2]/self.total*100) .. "%)")
				else
					GameCooltip:AddLine(n, FormatTooltipNumber (_, _table [2]) .. " (" .. _math_floor(_table [2]/self.total*100) .. "%)")
				end
				_detalhes:AddTooltipBackgroundStatusbar()
				GameCooltip:AddIcon ([[Interface\AddOns\Details\images\classes_small]], 1, 1, icon_size.W, icon_size.H, 0.25, 0.49609375, 0.75, 1)
			end
		end
	end

	--~Phases
	if (instancia.sub_atributo == 1 or instancia.sub_atributo == 2) then
		local segment = instancia:GetShowingCombat()
		if (segment and self.grupo) then
			local bossInfo = segment:GetBossInfo()
			local phasesInfo = segment:GetPhases()
			if (bossInfo and phasesInfo) then
				if (#phasesInfo > 1) then
					_detalhes:AddTooltipSpellHeaderText ("", headerColor, 1, false, 0.1, 0.9, 0.1, 0.9, true) --add a space
					_detalhes:AddTooltipSpellHeaderText ("Healing by Encounter Phase", headerColor, 1, [[Interface\Garrison\orderhall-missions-mechanic8]], 11/64, 53/64, 11/64, 53/64)
					_detalhes:AddTooltipHeaderStatusbar (r, g, b, barAlha)

					local playerPhases = {}
					local totalDamage = 0

					for phase, playersTable in pairs(phasesInfo.heal) do --each phase

						local allPlayers = {} --all players for this phase
						for playerName, amount in pairs(playersTable) do
							tinsert(allPlayers, {playerName, amount})
							totalDamage = totalDamage + amount
						end
						table.sort (allPlayers, function(a, b) return a[2] > b[2] end)

						local myRank = 0
						for i = 1, #allPlayers do
							if (allPlayers [i] [1] == self.nome) then
								myRank = i
								break
							end
						end

						tinsert(playerPhases, {phase, playersTable [self.nome] or 0, myRank, (playersTable [self.nome] or 0) / totalDamage * 100})
					end

					table.sort (playerPhases, function(a, b) return a[1] < b[1] end)

					for i = 1, #playerPhases do
						--[1] Phase Number [2] Amount Done [3] Rank [4] Percent
						GameCooltip:AddLine("|cFFF0F0F0Phase|r " .. playerPhases [i][1], FormatTooltipNumber (_, playerPhases [i][2]) .. " (|cFFFFFF00#" .. playerPhases [i][3] ..  "|r, " .. _cstr ("%.1f", playerPhases [i][4]) .. "%)")
						GameCooltip:AddIcon ([[Interface\Garrison\orderhall-missions-mechanic9]], 1, 1, 14, 14, 11/64, 53/64, 11/64, 53/64)
						_detalhes:AddTooltipBackgroundStatusbar()
					end
				end
			end
		end
	end

	return true
end


--------------------------------------------- // JANELA DETALHES // ---------------------------------------------
---------- bifurca��o
function healingClass:MontaInfo()
	if (breakdownWindowFrame.sub_atributo == 1 or breakdownWindowFrame.sub_atributo == 2) then
		self:MontaInfoHealingDone()

		--[=[
		local bNeedUpdateAgain = false

		--sort by healing done
		---@type df_headerframe
		local spellsHeader = DetailsSpellBreakdownTab.GetSpellScrollFrame().Header
		local totalHeader = spellsHeader:GetHeaderColumnByName("amount")
		if (totalHeader and totalHeader:IsShown()) then
			local columnSelected, order, key, name = spellsHeader:GetSelectedColumn()
			if (name == "overheal") then
				totalHeader:Click()
				bNeedUpdateAgain = true
			end
		end

		---@type df_headerframe
		local targetsHeader = DetailsSpellBreakdownTab.GetTargetScrollFrame().Header
		local totalHeader = targetsHeader:GetHeaderColumnByName("amount")
		if (totalHeader and totalHeader:IsShown()) then
			local columnSelected, order, key, name = targetsHeader:GetSelectedColumn()
			if (name == "overheal") then
				totalHeader:Click()
				bNeedUpdateAgain = true
			end
		end

		if (bNeedUpdateAgain) then
			self:MontaInfoHealingDone()
		end
		--]=]

	elseif (breakdownWindowFrame.sub_atributo == 3) then
		self:MontaInfoHealingDone()

		--[=[
		local bNeedUpdateAgain = false

		--sort by overhealing
		---@type df_headerframe
		local spellsHeader = DetailsSpellBreakdownTab.GetSpellScrollFrame().Header
		local overhealHeader = spellsHeader:GetHeaderColumnByName("overheal")
		if (overhealHeader and overhealHeader:IsShown()) then
			local columnSelected, order, key, name = spellsHeader:GetSelectedColumn()
			if (name ~= "overheal") then
				overhealHeader:Click()
				bNeedUpdateAgain = true
			end
		end

		---@type df_headerframe
		local targetsHeader = DetailsSpellBreakdownTab.GetTargetScrollFrame().Header
		local overhealHeader = targetsHeader:GetHeaderColumnByName("overheal")
		if (overhealHeader and overhealHeader:IsShown()) then
			local columnSelected, order, key, name = targetsHeader:GetSelectedColumn()
			if (name ~= "overheal") then
				overhealHeader:Click()
				bNeedUpdateAgain = true
			end
		end

		if (bNeedUpdateAgain) then
			self:MontaInfoHealingDone()
		end
		--]=]

	elseif (breakdownWindowFrame.sub_atributo == 4) then
		self:MontaInfoHealTaken()
	end
end

local healingTakenHeadersAllowed = {icon = true, name = true, rank = true, amount = true, persecond = true, percent = true}
function healingClass:MontaInfoHealTaken()
	---@type actor
	local actorObject = self
	---@type instance
	local instance = breakdownWindowFrame.instancia
	---@type combat
	local combatObject = instance:GetCombat()
	---@type string
	local actorName = actorObject:Name()

	---@type number
	local healTakenTotal = actorObject.healing_taken
	---@type table<string, boolean>
	local healTakenFrom = actorObject.healing_from
	---@type actorcontainer
	local healContainer = combatObject:GetContainer(class_type)

	local resultTable = {}

	---@type string
	for healerName in pairs(healTakenFrom) do
		local sourceActorObject = healContainer:GetActor(healerName)
		if (sourceActorObject) then
			---@type table<string, number>
			local targets = sourceActorObject:GetTargets()
			---@type number|nil
			local amountOfHeal = targets[actorName]
			if (amountOfHeal) then
				---@type texturetable
				local iconTable = Details:GetActorIcon(sourceActorObject)

				---@type {name: string, amount: number, icon: texturetable}
				local healTakenTable = {name = healerName, total = amountOfHeal, icon = iconTable}

				resultTable[#resultTable+1] = healTakenTable
			end
		end
	end

	resultTable.totalValue = healTakenTotal
	resultTable.combatTime = combatObject:GetCombatTime()
	resultTable.headersAllowed = healingTakenHeadersAllowed

	Details222.BreakdownWindow.SendGenericData(resultTable, actorObject, combatObject, instance)

	if true then return end

	local healing_taken = self.healing_taken
	local curandeiros = self.healing_from
	local instancia = breakdownWindowFrame.instancia
	local tabela_do_combate = instancia.showing
	local showing = tabela_do_combate [class_type] --o que esta sendo mostrado -> [1] - dano [2] - cura --pega o container com ._NameIndexTable ._ActorTable
	local barras = breakdownWindowFrame.barras1
	local meus_curandeiros = {}

	local este_curandeiro
	for nome, _ in pairs(curandeiros) do
		este_curandeiro = showing._ActorTable[showing._NameIndexTable[nome]]
		if (este_curandeiro) then
			local alvos = este_curandeiro.targets
			local este_alvo = alvos [self.nome]
			if (este_alvo) then
				meus_curandeiros [#meus_curandeiros+1] = {nome, este_alvo, este_alvo/healing_taken*100, este_curandeiro.classe}
			end
		end
	end

	local amt = #meus_curandeiros

	if (amt < 1) then
		return true
	end

	_table_sort (meus_curandeiros, _detalhes.Sort2)

	gump:JI_AtualizaContainerBarras (amt)

	local max_ = meus_curandeiros [1] and meus_curandeiros [1][2] or 0

	local barra
	for index, tabela in ipairs(meus_curandeiros) do
		barra = barras [index]
		if (not barra) then
			barra = gump:CriaNovaBarraInfo1 (instancia, index)
		end

		self:FocusLock(barra, tabela[1])

		--hes:UpdadeInfoBar(row, index, spellid, name, value, max, percent, icon, detalhes)

		local texCoords = CLASS_ICON_TCOORDS [tabela[4]]
		if (not texCoords) then
			texCoords = _detalhes.class_coords ["UNKNOW"]
		end

		local formated_value = SelectedToKFunction (_, _math_floor(tabela[2]))
		self:UpdadeInfoBar(barra, index, tabela[1], tabela[1], tabela[2], formated_value, max_, tabela[3], "Interface\\AddOns\\Details\\images\\classes_small", true, texCoords)
	end

end

function healingClass:MontaInfoOverHealing() --this should be deprecated now
--pegar as habilidade de dar sort no heal

	local instancia = breakdownWindowFrame.instancia
	local total = self.totalover
	local tabela = self.spells._ActorTable
	local minhas_curas = {}
	local barras = breakdownWindowFrame.barras1

	for spellid, tabela in pairs(tabela) do
		local nome, _, icone = _GetSpellInfo(spellid)
		tinsert(minhas_curas, {spellid, tabela.overheal, tabela.overheal/total*100, nome, icone})
	end

	--add pets
	local ActorPets = self.pets
	local class_color = "FFDDDDDD"
	for _, PetName in ipairs(ActorPets) do
		local PetActor = instancia.showing (class_type, PetName)
		if (PetActor) then
			local PetSkillsContainer = PetActor.spells._ActorTable
			for _spellid, _skill in pairs(PetSkillsContainer) do --da foreach em cada spellid do container
				local nome, _, icone = _GetSpellInfo(_spellid)
				tinsert(minhas_curas, {_spellid, _skill.overheal, _skill.overheal/total*100, nome .. " (|c" .. class_color .. PetName:gsub((" <.*"), "") .. "|r)", icone, PetActor})
			end
		end
	end

	_table_sort (minhas_curas, _detalhes.Sort2)

	local amt = #minhas_curas
	gump:JI_AtualizaContainerBarras (amt)

	local max_ = minhas_curas[1] and minhas_curas[1][2] or 0

	for index, tabela in ipairs(minhas_curas) do

		local barra = barras [index]

		if (not barra) then
			barra = gump:CriaNovaBarraInfo1 (instancia, index)
			barra.textura:SetStatusBarColor(1, 1, 1, 1)
			barra.on_focus = false
		end

		if (not breakdownWindowFrame.mostrando_mouse_over) then
			if (tabela[1] == self.detalhes) then --tabela [1] = spellid = spellid que esta na caixa da direita
				if (not barra.on_focus) then --se a barra n�o tiver no foco
					barra.textura:SetStatusBarColor(129/255, 125/255, 69/255, 1)
					barra.on_focus = true
					if (not breakdownWindowFrame.mostrando) then
						breakdownWindowFrame.mostrando = barra
					end
				end
			else
				if (barra.on_focus) then
					barra.textura:SetStatusBarColor(1, 1, 1, 1) --volta a cor antiga
					barra:SetAlpha(.9) --volta a alfa antiga
					barra.on_focus = false
				end
			end
		end

		if (index == 1) then
			barra.textura:SetValue(100)
		else
			barra.textura:SetValue(tabela[2]/max_*100) --muito mais rapido...
		end

		barra.lineText1:SetText(index..instancia.divisores.colocacao..tabela[4]) --seta o texto da esqueda

		local formated_value = SelectedToKFunction (_, _math_floor(tabela[2]))
		barra.lineText4:SetText(formated_value .." (".. _cstr ("%.1f", tabela[3]) .."%)")

		barra.icone:SetTexture(tabela[5])

		barra.other_actor = tabela [6]
		barra.minha_tabela = self
		barra.show = tabela[1]
		barra:Show()

		if (self.detalhes and self.detalhes == barra.show) then
			self:MontaDetalhes (self.detalhes, barra)
		end
	end

	--TOP OVERHEALED
	local jogadores_overhealed = {}
	tabela = self.targets_overheal
	local heal_container = instancia.showing[2]
	for target_name, amount in pairs(tabela) do
		local classe = "UNKNOW"
		local actor_object = heal_container._ActorTable [heal_container._NameIndexTable [tabela.nome]]
		if (actor_object) then
			classe = actor_object.classe
		end
		tinsert(jogadores_overhealed, {target_name, amount, amount/total*100, classe})
	end
	_table_sort (jogadores_overhealed, _detalhes.Sort2)

	local amt_alvos = #jogadores_overhealed
	gump:JI_AtualizaContainerAlvos (amt_alvos)

	local max_inimigos = jogadores_overhealed[1] and jogadores_overhealed[1][2] or 0

	for index, tabela in ipairs(jogadores_overhealed) do

		local barra = breakdownWindowFrame.barras2 [index]

		if (not barra) then
			barra = gump:CriaNovaBarraInfo2 (instancia, index)
			barra.textura:SetStatusBarColor(1, 1, 1, 1)
		end

		if (index == 1) then
			barra.textura:SetValue(100)
		else
			barra.textura:SetValue(tabela[2]/max_*100)
		end

		barra.lineText1:SetText(index..instancia.divisores.colocacao..tabela[1]) --seta o texto da esqueda
		barra.lineText4:SetText(_detalhes:comma_value (tabela[2]) .." ".. instancia.divisores.abre .. _cstr ("%.1f", tabela[3]) .. instancia.divisores.fecha)
		barra.lineText1:SetWidth(barra:GetWidth() - barra.lineText4:GetStringWidth() - 30)

		-- icon
		barra.icone:SetTexture([[Interface\AddOns\Details\images\classes_small]])

		local texCoords = _detalhes.class_coords [tabela[4]]
		if (not texCoords) then
			texCoords = _detalhes.class_coords ["UNKNOW"]
		end
		barra.icone:SetTexCoord(_unpack(texCoords))

		barra.minha_tabela = self
		barra.nome_inimigo = tabela [1]

		barra:Show()
	end
end

function healingClass:MontaInfoHealingDone()
	---@type actor
	local actorObject = self
	---@type instance
	local instance = breakdownWindowFrame.instancia
	---@type combat
	local combatObject = instance:GetCombat()
	---@type string
	local playerName = actorObject:Name()

	---@type number
	local actorTotal = actorObject.total
	---@type table
	local actorSpellsSorted = {}
	---@type table<number, spelltable>
	local actorSpells = actorObject:GetSpellList()

	--get time
	local actorCombatTime
	if (Details.time_type == 1 or not actorObject.grupo) then
		actorCombatTime = actorObject:Tempo()
	elseif (Details.time_type == 2 or Details.use_realtimedps) then
		actorCombatTime = breakdownWindowFrame.instancia.showing:GetCombatTime()
	end

	--actor spells
	---@type table<string, number>
	local alreadyAdded = {}
	for spellId, spellTable in pairs(actorSpells) do
		---@cast spellId number
		---@cast spellTable spelltable

		spellTable.ChartData = nil

		---@type string
		local spellName = _GetSpellInfo(spellId)
		if (spellName) then
			---@type number in which index the spell with the same name was stored
			local index = alreadyAdded[spellName]
			if (index) then
				---@type spelltableadv
				local bkSpellData = actorSpellsSorted[index]

				bkSpellData.spellTables[#bkSpellData.spellTables+1] = spellTable

				---@type bknesteddata
				local nestedData = {spellId = spellId, spellTable = spellTable, actorName = "", value = 0}
				bkSpellData.nestedData[#bkSpellData.nestedData+1] = nestedData
				bkSpellData.bCanExpand = true
			else
				---@type spelltableadv
				local bkSpellData = {
					id = spellId,
					spellschool = spellTable.spellschool,
					bIsExpanded = Details222.BreakdownWindow.IsSpellExpanded(spellId),
					bCanExpand = false,

					spellTables = {spellTable},
					nestedData = {{spellId = spellId, spellTable = spellTable, actorName = "", value = 0}},
				}
				detailsFramework:Mixin(bkSpellData, Details.SpellTableMixin)

				actorSpellsSorted[#actorSpellsSorted+1] = bkSpellData
				alreadyAdded[spellName] = #actorSpellsSorted
			end
		end
	end

	--pets spells
	local actorPets = actorObject:GetPets()
	for _, petName in ipairs(actorPets) do
		---@type actor
		local petActor = combatObject(DETAILS_ATTRIBUTE_HEAL, petName)
		if (petActor) then --PET
			local spells = petActor:GetSpellList()
			for spellId, spellTable in pairs(spells) do
				---@cast spellId number
				---@cast spellTable spelltable

				spellTable.ChartData = nil
				--PET
				---@type string
				local spellName = _GetSpellInfo(spellId)
				if (spellName) then
					---@type number in which index the spell with the same name was stored
					local index = alreadyAdded[spellName]
					if (index) then --PET
						---@type spelltableadv
						local bkSpellData = actorSpellsSorted[index]

						bkSpellData.spellTables[#bkSpellData.spellTables+1] = spellTable

						---@type bknesteddata
						local nestedData = {spellId = spellId, spellTable = spellTable, actorName = petName, value = 0}
						bkSpellData.nestedData[#bkSpellData.nestedData+1] = nestedData
						bkSpellData.bCanExpand = true
					else --PET
						---@type spelltableadv
						local bkSpellData = {
							id = spellId,
							actorName = petName,
							spellschool = spellTable.spellschool,
							expanded = Details222.BreakdownWindow.IsSpellExpanded(spellId),
							bCanExpand = false,

							spellTables = {spellTable},
							nestedData = {{spellId = spellId, spellTable = spellTable, actorName = petName, value = 0}},
						}
						detailsFramework:Mixin(bkSpellData, Details.SpellTableMixin)

						actorSpellsSorted[#actorSpellsSorted+1] = bkSpellData
						alreadyAdded[spellName] = #actorSpellsSorted
					end
				end
			end
		end
	end

	for i = 1, #actorSpellsSorted do
		---@type spelltableadv
		local bkSpellData = actorSpellsSorted[i]
		Details.SpellTableMixin.SumSpellTables(bkSpellData.spellTables, bkSpellData)
		--Details:Destroy(bkSpellData, "spellTables")
	end

	--table.sort(actorSpellsSorted, Details.Sort2)
	table.sort(actorSpellsSorted, function(t1, t2)
		return t1.total > t2.total
	end)

	actorSpellsSorted.totalValue = actorTotal
	actorSpellsSorted.combatTime = actorCombatTime

	--cleanup
	Details:Destroy(alreadyAdded)

	--actorSpellsSorted has the spell infomation, need to pass to the summary tab
	--send to the breakdown window
	Details222.BreakdownWindow.SendSpellData(actorSpellsSorted, actorObject, combatObject, instance)

	--targets

	---an array of breakdowntargettable
	---@type breakdowntargettable[]
	local targetList = {}

	--get the targets table: in the class heal, an actor has two targets table, one for normal healing and one for overheal
	---@type targettable
	local normalTargetsTable = self:GetTargets("targets")
	---@type targettable
	local overhealTargetsTable = self:GetTargets("targets_overheal")

	local targetTotalValue = 0
	local targetOverhealTotalValue = 0

	--build the data required by the breakdown window
	for targetName, amount in pairs(normalTargetsTable) do
		if (amount > 0) then
			local overhealAmount = overhealTargetsTable[targetName] or 0
			---@type breakdowntargettable
			local bkTargetData = {
				name = targetName,
				total = amount,
				overheal = overhealAmount,
			}
			targetTotalValue = targetTotalValue + amount
			targetOverhealTotalValue = targetOverhealTotalValue + (overhealAmount)
			tinsert(targetList, bkTargetData)
		end
	end

	for targetName, amount in pairs(overhealTargetsTable) do
		if (amount > 0) then
			if (not normalTargetsTable[targetName]) then
				---@type breakdowntargettable
				local bkTargetData = {
					name = targetName,
					total = 0,
					overheal = amount,
				}
				targetOverhealTotalValue = targetOverhealTotalValue + (amount)
				tinsert(targetList, bkTargetData)
			end
		end
	end

	targetList.totalValue = targetTotalValue
	targetList.totalValueOverheal = targetOverhealTotalValue
	targetList.combatTime = actorCombatTime

	Details222.BreakdownWindow.SendTargetData(targetList, actorObject, combatObject, instance)

	if 1 then return end

	local instancia = breakdownWindowFrame.instancia
	local total = self.total
	local tabela = self.spells._ActorTable
	local minhas_curas = {}
	local barras = breakdownWindowFrame.barras1

	--get time type
	local meu_tempo
	if (_detalhes.time_type == 1 or not self.grupo) then
		meu_tempo = self:Tempo()
	elseif (_detalhes.time_type == 2 or _detalhes.time_type == 3) then
		meu_tempo = breakdownWindowFrame.instancia.showing:GetCombatTime()
	end

	for spellid, tabela in pairs(tabela) do
		local nome, rank, icone = _GetSpellInfo(spellid)
		tinsert(minhas_curas, {
			spellid,
			tabela.total,
			tabela.total/total*100,
			nome,
			icone,
			false, --not a pet
			tabela.anti_heal,
		})
	end

	breakdownWindowFrame:SetStatusbarText()

	--add pets
	local ActorPets = self.pets
	--local class_color = RAID_CLASS_COLORS [self.classe] and RAID_CLASS_COLORS [self.classe].colorStr
	local class_color = "FFDDDDDD"
	for _, PetName in ipairs(ActorPets) do
		local PetActor = instancia.showing (class_type, PetName)
		if (PetActor) then
			local PetSkillsContainer = PetActor.spells._ActorTable
			for _spellid, _skill in pairs(PetSkillsContainer) do --da foreach em cada spellid do container
				local nome, _, icone = _GetSpellInfo(_spellid)
				tinsert(minhas_curas, {
					_spellid,
					_skill.total,
					_skill.total/total*100,
					nome .. " (|c" .. class_color .. PetName:gsub((" <.*"), "") .. "|r)",
					icone,
					PetActor
				})
			end
		end
	end

	_table_sort (minhas_curas, _detalhes.Sort2)

	local amt = #minhas_curas
	gump:JI_AtualizaContainerBarras (amt)

	local max_ = minhas_curas[1] and minhas_curas[1][2] or 0
	local foundSpellDetail = false

	for index, tabela in ipairs(minhas_curas) do

		local barra = barras [index]

		if (not barra) then
			barra = gump:CriaNovaBarraInfo1 (instancia, index)
			barra.textura:SetStatusBarColor(1, 1, 1, 1)
			barra.on_focus = false
		end

		self:FocusLock(barra, tabela[1])

		barra.other_actor = tabela [6]

		if (breakdownWindowFrame.sub_atributo == 2) then
			local formated_value = SelectedToKFunction (_, _math_floor(tabela[2]/meu_tempo))
			self:UpdadeInfoBar(barra, index, tabela[1], tabela[4], tabela[2], formated_value, max_, tabela[3], tabela[5], true)
		else
			local formated_value = SelectedToKFunction (_, _math_floor(tabela[2]))
			if (tabela [7]) then
				formated_value = formated_value .. " [|cFFFF5500" .. SelectedToKFunction (_, _math_floor(tabela [7])) .." " .. Loc ["STRING_DAMAGE"] .."|r] "
			end
			self:UpdadeInfoBar(barra, index, tabela[1], tabela[4], tabela[2], formated_value, max_, tabela[3], tabela[5], true)
		end

		barra.minha_tabela = self
		barra.show = tabela[1]
		barra.spellid = self.nome
		barra:Show()

		if (self.detalhes and self.detalhes == barra.show and not foundSpellDetail) then
			self:MontaDetalhes (self.detalhes, barra)
			foundSpellDetail = true
		end
	end

	--TOP CURADOS
	local healedTargets = {}
	tabela = self.targets
	for target_name, amount in pairs(tabela) do
		tinsert(healedTargets, {target_name, amount, amount / total*100})
	end
	_table_sort(healedTargets, _detalhes.Sort2)

	gump:JI_AtualizaContainerAlvos(#healedTargets)
	local topHealingDone = max(healedTargets[1] and healedTargets[1][2] or 0, 0.0001)

	for index, healDataTable in ipairs(healedTargets) do
		local barra = breakdownWindowFrame.barras2[index]

		if (not barra) then
			barra = gump:CriaNovaBarraInfo2(instancia, index)
			barra.textura:SetStatusBarColor(1, 1, 1, 1)
		end

		local healingDone = healDataTable[2]

		if (index == 1) then
			barra.textura:SetValue(100)
		else
			barra.textura:SetValue(healingDone / topHealingDone * 100)
		end

		local target_actor = instancia.showing(2, healDataTable[1])
		if (target_actor) then
			target_actor:SetClassIcon(barra.icone, instancia, target_actor.classe)
		else
			barra.icone:SetTexture([[Interface\AddOns\Details\images\classes_small_alpha]]) --CLASSE
			local texCoords = _detalhes.class_coords ["ENEMY"]
			barra.icone:SetTexCoord(_unpack(texCoords))
		end

		barra.lineText1:SetText(index .. ". " .. _detalhes:GetOnlyName(healDataTable[1]))
		barra.textura:SetStatusBarColor(1, 1, 1, 1)

		if (breakdownWindowFrame.sub_atributo == 2) then
			barra.lineText4:SetText(_detalhes:comma_value(_math_floor(healingDone/meu_tempo)) .." (" .. _cstr ("%.1f", healDataTable[3]) .. "%)")
		else
			barra.lineText4:SetText(SelectedToKFunction(_, healingDone) .. " (" .. _cstr ("%.1f", healDataTable[3]) .. "%)")
		end

		barra.minha_tabela = self
		barra.nome_inimigo = healDataTable[1]

		-- no lugar do spell id colocar o que?
		barra.spellid = healDataTable[5]
		barra:Show()
	end

end

function healingClass:MontaTooltipAlvos (thisLine, index, instancia)

	local inimigo = thisLine.nome_inimigo
	local container = self.spells._ActorTable
	local habilidades = {}
	local total
	local sub_atributo = breakdownWindowFrame.instancia.sub_atributo

	local targets_key = ""

	if (sub_atributo == 3) then --overheal
		total = self.totalover
		targets_key = "_overheal"
	else
		total = self.total
	end

	_detalhes:FormatCooltipForSpells()
	GameCooltip:SetOwner(thisLine, "bottom", "top", 4, -2)
	GameCooltip:SetOption("MinWidth", max(230, thisLine:GetWidth()*0.98))

	--add spells
	for spellid, tabela in pairs(container) do
		for target_name, amount in pairs(tabela ["targets" .. targets_key]) do
			if (target_name == inimigo) then
				local nome, _, icone = _GetSpellInfo(spellid)
				habilidades [#habilidades+1] = {nome, amount, icone}
			end
		end
	end

	--add pets
	local ActorPets = self.pets
	for _, PetName in ipairs(ActorPets) do
		local PetActor = instancia.showing (class_type, PetName)
		if (PetActor) then
			local PetSkillsContainer = PetActor.spells._ActorTable
			for _spellid, _skill in pairs(PetSkillsContainer) do

				for target_name, amount in pairs(_skill ["targets" .. targets_key]) do
					if (target_name == inimigo) then
						local nome, _, icone = _GetSpellInfo(_spellid)
						habilidades [#habilidades+1] = {nome, amount, icone}
					end
				end

			end
		end
	end

	_table_sort (habilidades, _detalhes.Sort2)

	--get time type
	local meu_tempo
	if (_detalhes.time_type == 1 or not self.grupo) then
		meu_tempo = self:Tempo()
	elseif (_detalhes.time_type == 2 or _detalhes.time_type == 3) then
		meu_tempo = breakdownWindowFrame.instancia.showing:GetCombatTime()
	end

	local is_hps = breakdownWindowFrame.instancia.sub_atributo == 2

	if (is_hps) then
		--GameTooltip:AddLine(index..". "..inimigo)
		--GameTooltip:AddLine(Loc ["STRING_HEALING_HPS_FROM"] .. ":")
		--GameTooltip:AddLine(" ")
		_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_HEALING_HPS_FROM"] .. ":", {1, 0.9, 0.0, 1}, 1, _detalhes.tooltip_spell_icon.file, unpack(_detalhes.tooltip_spell_icon.coords))
		_detalhes:AddTooltipHeaderStatusbar (1, 1, 1, 1)
	else
		--GameTooltip:AddLine(index..". "..inimigo)
		--GameTooltip:AddLine(Loc ["STRING_HEALING_FROM"] .. ":")
		--GameTooltip:AddLine(" ")
		_detalhes:AddTooltipSpellHeaderText (Loc ["STRING_HEALING_FROM"] .. ":", {1, 0.9, 0.0, 1}, 1, _detalhes.tooltip_spell_icon.file, unpack(_detalhes.tooltip_spell_icon.coords))
		_detalhes:AddTooltipHeaderStatusbar (1, 1, 1, 1)
	end

	local icon_size = _detalhes.tooltip.icon_size
	local icon_border = _detalhes.tooltip.icon_border_texcoord
	local topSpellHeal = habilidades[1] and habilidades[1][2]

	if (topSpellHeal) then
		for index, tabela in ipairs(habilidades) do
			if (tabela [2] < 1) then
				break
			end

			local spellName, spellIcon = tabela[1], tabela [3]

			if (is_hps) then
				GameCooltip:AddLine(spellName, _detalhes:comma_value (_math_floor(tabela[2]/meu_tempo)).." (".. _cstr ("%.1f", tabela[2]/total*100).."%)")
			else
				GameCooltip:AddLine(spellName, SelectedToKFunction (_, tabela[2]).." (".. _cstr ("%.1f", tabela[2]/total*100).."%)")
			end

			GameCooltip:AddIcon (spellIcon, nil, nil, icon_size.W + 4, icon_size.H + 4, icon_border.L, icon_border.R, icon_border.T, icon_border.B)
			_detalhes:AddTooltipBackgroundStatusbar (false, tabela[2] / topSpellHeal * 100)
		end
	end

	GameCooltip:Show()

	return true

end

function healingClass:MontaDetalhes (spellid, barra)
	--bifurga��es
	if (breakdownWindowFrame.sub_atributo == 1 or breakdownWindowFrame.sub_atributo == 2 or breakdownWindowFrame.sub_atributo == 3) then
		return self:MontaDetalhesHealingDone (spellid, barra)
	elseif (breakdownWindowFrame.sub_atributo == 4) then
		healingClass:MontaDetalhesHealingTaken (spellid, barra)
	end
end

function healingClass:MontaDetalhesHealingTaken (nome, barra)

	local barras = breakdownWindowFrame.barras3
	local instancia = breakdownWindowFrame.instancia

	local tabela_do_combate = breakdownWindowFrame.instancia.showing
	local showing = tabela_do_combate [class_type] --o que esta sendo mostrado -> [1] - dano [2] - cura --pega o container com ._NameIndexTable ._ActorTable

	local este_curandeiro = showing._ActorTable[showing._NameIndexTable[nome]]
	local conteudo = este_curandeiro.spells._ActorTable --pairs[] com os IDs das magias

	local actor = breakdownWindowFrame.jogador.nome

	local total = este_curandeiro.targets [actor]

	local minhas_magias = {}

	for spellid, tabela in pairs(conteudo) do --da foreach em cada spellid do container
		if (tabela.targets [actor]) then
			local spell_nome, _, icone = _GetSpellInfo(spellid)
			tinsert(minhas_magias, {spellid, tabela.targets [actor], tabela.targets [actor] / total*100, spell_nome, icone})
		end
	end

	_table_sort (minhas_magias, _detalhes.Sort2)

	local max_ = minhas_magias[1] and minhas_magias[1][2] or 0 --dano que a primeiro magia vez

	local lastIndex = 1
	local barra
	for index, tabela in ipairs(minhas_magias) do
		lastIndex = index
		barra = barras [index]

		if (not barra) then --se a barra n�o existir, criar ela ent�o
			barra = gump:CriaNovaBarraInfo3 (instancia, index)
			barra.textura:SetStatusBarColor(1, 1, 1, 1) --isso aqui � a parte da sele��o e descele��o
		end

		barra.show = tabela[1]

		if (index == 1) then
			barra.textura:SetValue(100)
		else
			barra.textura:SetValue(tabela[2]/max_*100) --muito mais rapido...
		end

		barra.lineText1:SetText(index..instancia.divisores.colocacao..tabela[4]) --seta o texto da esqueda
		barra.lineText4:SetText(_detalhes:comma_value (tabela[2]) .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[3]) .."%".. instancia.divisores.fecha)

		barra.icone:SetTexture(tabela[5])

		barra:Show() --mostra a barra

		if (index == 15) then
			break
		end
	end

	for i = lastIndex+1, #barras do
		barras[i]:Hide()
	end

end

local absorbed_table = {c = {1, 1, 1, 0.4}, p = 0}
local overhealing_table = {c = {0.5, 0.1, 0.1, 0.4}, p = 0}
local anti_heal_table = {c = {0.5, 0.1, 0.1, 0.4}, p = 0}
local normal_table = {c = {1, 1, 1, 0.4}, p = 0}
local critical_table = {c = {1, 1, 1, 0.4}, p = 0}

local data_table = {}
local t1, t2, t3, t4 = {}, {}, {}, {}

function healingClass:MontaDetalhesHealingDone (spellid, barra) --deprecated with the new breakdown window

	local esta_magia
	if (barra.other_actor) then
		esta_magia = barra.other_actor.spells._ActorTable [spellid]
	else
		esta_magia = self.spells._ActorTable [spellid]
	end

	if (not esta_magia) then
		return
	end

	--icone direito superior
	local spellName, _, icone = _GetSpellInfo(spellid)
	breakdownWindowFrame.spell_icone:SetTexture(icone)

	local total = self.total

	local overheal = esta_magia.overheal
	local meu_total = esta_magia.total + overheal

	local meu_tempo
	if (_detalhes.time_type == 1 or not self.grupo) then
		meu_tempo = self:Tempo()
	elseif (_detalhes.time_type == 2 or _detalhes.time_type == 3) then
		meu_tempo = breakdownWindowFrame.instancia.showing:GetCombatTime()
	end

	local total_hits = esta_magia.counter
	local index = 1
	local data = data_table

	Details:Destroy(t1)
	Details:Destroy(t2)
	Details:Destroy(t3)
	Details:Destroy(t4)
	Details:Destroy(data)

	if (esta_magia.total > 0) then

	--GERAL
		local media = esta_magia.total/total_hits

		local this_hps = nil
		if (esta_magia.counter > esta_magia.c_amt) then
			this_hps = Loc ["STRING_HPS"] .. ": " .. _detalhes:comma_value (esta_magia.total/meu_tempo)
		else
			this_hps = Loc ["STRING_HPS"] .. ": " .. Loc ["STRING_SEE_BELOW"]
		end

		local heal_string
		if (esta_magia.is_shield) then
			heal_string = Loc ["STRING_SHIELD_HEAL"]
		else
			heal_string = Loc ["STRING_HEAL"]
		end

		local hits_string = "" .. total_hits
		local cast_string = Loc ["STRING_CAST"] .. ": "

		local misc_actor = breakdownWindowFrame.instancia.showing (4, self:name())
		if (misc_actor) then
			local buff_uptime = misc_actor.buff_uptime_spells and misc_actor.buff_uptime_spells._ActorTable [spellid] and misc_actor.buff_uptime_spells._ActorTable [spellid].uptime
			if (buff_uptime) then
				hits_string = hits_string .. "  |cFFDDDD44(" .. _math_floor(buff_uptime / breakdownWindowFrame.instancia.showing:GetCombatTime() * 100) .. "% uptime)|r"
			end

			local amountOfCasts = breakdownWindowFrame.instancia.showing:GetSpellCastAmount(self:Name(), spellName)
			if (not amountOfCasts) then
				amountOfCasts = "(|cFFFFFF00?|r)"
			end
			cast_string = cast_string .. amountOfCasts
		end

		gump:SetaDetalheInfoTexto( index, 100,
			--Loc ["STRING_GERAL"],
			cast_string,
			heal_string .. ": " .. _detalhes:ToK (esta_magia.total),
			"", --Loc ["STRING_PERCENTAGE"] .. ": " .. _cstr ("%.1f", esta_magia.total/total*100) .. "%",
			Loc ["STRING_AVERAGE"] .. ": " .. _detalhes:comma_value (media),
			this_hps,
			Loc ["STRING_HITS"] .. ": " .. hits_string)

	--NORMAL
		local normal_hits = esta_magia.n_amt
		if (normal_hits > 0) then
			local normal_curado = esta_magia.n_total
			local media_normal = normal_curado/normal_hits
			media_normal = max(media_normal, 0.000001)

			local T = (meu_tempo*normal_curado)/esta_magia.total
			local P = media/media_normal*100
			T = P*T/100

			data[#data+1] = t1

			if (esta_magia.is_shield) then
				t1[3] = Loc ["STRING_ABSORBED"]
				normal_table.p = esta_magia.total / (esta_magia.total+esta_magia.overheal) * 100
			else
				t1[3] = heal_string
				normal_table.p = normal_hits/total_hits*100
			end

			t1[1] = esta_magia.n_amt
			t1[2] = normal_table

			t1[4] = Loc ["STRING_MINIMUM_SHORT"] .. ": " .. _detalhes:comma_value (esta_magia.n_min)
			t1[5] = Loc ["STRING_MAXIMUM_SHORT"] .. ": " .. _detalhes:comma_value (esta_magia.n_max)
			t1[6] = Loc ["STRING_AVERAGE"] .. ": " .. _detalhes:comma_value (media_normal)
			t1[7] = Loc ["STRING_HPS"] .. ": " .. _detalhes:comma_value (normal_curado / max(T, 0.001))
			t1[8] = normal_hits .. " / ".. _cstr ("%.1f", normal_hits / max(total_hits, 0.001) * 100) .. "%"

		end

	--CRITICO
		if (esta_magia.c_amt > 0) then
			local media_critico = esta_magia.c_total/esta_magia.c_amt
			local T = (meu_tempo*esta_magia.c_total)/esta_magia.total
			local P = media/max(media_critico, 0.0001)*100
			T = P*T/100
			local crit_hps = esta_magia.c_total/T
			if (not crit_hps) then
				crit_hps = 0
			end

			data[#data+1] = t2
			critical_table.p = esta_magia.c_amt/total_hits*100

			t2[1] = esta_magia.c_amt
			t2[2] = critical_table
			t2[3] = Loc ["STRING_HEAL_CRIT"]
			t2[4] = Loc ["STRING_MINIMUM_SHORT"] .. ": " .. _detalhes:comma_value (esta_magia.c_min)
			t2[5] = Loc ["STRING_MAXIMUM_SHORT"] .. ": " .. _detalhes:comma_value (esta_magia.c_max)
			t2[6] = Loc ["STRING_AVERAGE"] .. ": " .. _detalhes:comma_value (media_critico)
			t2[7] = Loc ["STRING_HPS"] .. ": " .. _detalhes:comma_value (crit_hps)
			t2[8] = esta_magia.c_amt .. " [|cFFC0C0C0".. _cstr ("%.1f", esta_magia.c_amt / max(total_hits, 0.001) * 100) .. "%|r]"

		end
	end

	_table_sort (data, _detalhes.Sort1)

--	for i = #data+1, 2 do --para o antiheal aparecer na penultima barra
--		data[i] = nil
--	end

	--anti heal
		if (esta_magia.anti_heal and esta_magia.anti_heal > 0) then
			local porcentagem_anti_heal = esta_magia.anti_heal / meu_total * 100
			data[3] = t3

			anti_heal_table.p = porcentagem_anti_heal

			t3[1] = esta_magia.anti_heal
			t3[2] = anti_heal_table
			t3[3] = "Anti Heal"

			t3[4] = ""
			t3[5] = ""
			t3[6] = ""
			t3[7] = ""
			t3[8] = _detalhes:comma_value (esta_magia.anti_heal) .. " / " .. _cstr ("%.1f", porcentagem_anti_heal) .. "%"

		--empowered
		elseif (esta_magia.e_total and esta_magia.e_heal) then
			local empowerLevelSum = esta_magia.e_total --total sum of empower levels
			local empowerAmount = esta_magia.e_amt --amount of casts with empower
			local empowerAmountPerLevel = esta_magia.e_lvl --{[1] = 4; [2] = 9; [3] = 15}
			local empowerHealPerLevel = esta_magia.e_heal --{[1] = 54548745, [2] = 74548745}

			data[3] = t3

			local level1AverageHeal = "0"
			local level2AverageHeal = "0"
			local level3AverageHeal = "0"
			local level4AverageHeal = "0"
			local level5AverageHeal = "0"

			if (empowerHealPerLevel[1]) then
				level1AverageHeal = Details:ToK(empowerHealPerLevel[1] / empowerAmountPerLevel[1])
			end
			if (empowerHealPerLevel[2]) then
				level2AverageHeal = Details:ToK(empowerHealPerLevel[2] / empowerAmountPerLevel[2])
			end
			if (empowerHealPerLevel[3]) then
				level3AverageHeal = Details:ToK(empowerHealPerLevel[3] / empowerAmountPerLevel[3])
			end
			if (empowerHealPerLevel[4]) then
				level4AverageHeal = Details:ToK(empowerHealPerLevel[4] / empowerAmountPerLevel[4])
			end
			if (empowerHealPerLevel[5]) then
				level5AverageHeal = Details:ToK(empowerHealPerLevel[5] / empowerAmountPerLevel[5])
			end

			t3[1] = 0
			t3[2] = {p = 100, c = {0.282353, 0.239216, 0.545098, 0.6}}
			t3[3] = "Spell Empower Average Level: " .. format("%.2f", empowerLevelSum / empowerAmount)
			t3[4] = ""
			t3[5] = ""
			t3[6] = ""
			t3[10] = ""
			t3[11] = ""

			if (level1AverageHeal ~= "0") then
				t3[4] = "Level 1 Average: " .. level1AverageHeal .. " (" .. (empowerAmountPerLevel[1] or 0) .. ")"
			end

			if (level2AverageHeal ~= "0") then
				t3[6] = "Level 2 Average: " .. level2AverageHeal .. " (" .. (empowerAmountPerLevel[2] or 0) .. ")"
			end

			if (level3AverageHeal ~= "0") then
				t3[11] = "Level 3 Average: " .. level3AverageHeal .. " (" .. (empowerAmountPerLevel[3] or 0) .. ")"
			end

			if (level4AverageHeal ~= "0") then
				t3[10] = "Level 4 Average: " .. level4AverageHeal .. " (" .. (empowerAmountPerLevel[4] or 0) .. ")"
			end

			if (level5AverageHeal ~= "0") then
				t3[5] = "Level 5 Average: " .. level5AverageHeal .. " (" .. (empowerAmountPerLevel[5] or 0) .. ")"
			end
		end

--	for i = #data+1, 3 do --para o overheal aparecer na ultima barra
--		data[i] = nil
--	end

	--overhealing
		if (overheal > 0) then
			local porcentagem_overheal = overheal/meu_total*100
			data[4] = t4

			overhealing_table.p = porcentagem_overheal

			t4[1] = overheal
			t4[2] = overhealing_table

			if (esta_magia.is_shield) then
				t4[3] = Loc ["STRING_SHIELD_OVERHEAL"]
			else
				t4[3] = Loc ["STRING_OVERHEAL"]
			end

			t4[4] = ""
			t4[5] = ""
			t4[6] = ""
			t4[7] = ""
			t4[8] = _detalhes:comma_value (overheal) .. " / " .. _cstr ("%.1f", porcentagem_overheal) .. "%"
		end

	for index = 1, 4 do
		local tabela = data[index]
		if (not tabela) then
			gump:HidaDetalheInfo (index+1)
		else
			gump:SetaDetalheInfoTexto(index+1, tabela[2], tabela[3], tabela[4], tabela[5], tabela[6], tabela[7], tabela[8])
		end
	end

end

--controla se o dps do jogador esta travado ou destravado
function healingClass:GetOrChangeActivityStatus (iniciar)
	if (iniciar == nil) then
		return self.iniciar_hps --retorna se o dps esta aberto ou fechado para este jogador
	elseif (iniciar) then
		self.iniciar_hps = true
		Details222.TimeMachine.AddActor(self)
	else
		self.iniciar_hps = false
		Details222.TimeMachine.RemoveActor(self)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--core functions

	--atualize a funcao de abreviacao
		function healingClass:UpdateSelectedToKFunction()
			SelectedToKFunction = ToKFunctions [_detalhes.ps_abbreviation]
			FormatTooltipNumber = ToKFunctions [_detalhes.tooltip.abbreviation]
			TooltipMaximizedMethod = _detalhes.tooltip.maximize_method
			headerColor = _detalhes.tooltip.header_text_color
		end

	--subtract total from a combat table
		function healingClass:subtract_total (combat_table)
			combat_table.totals [class_type] = combat_table.totals [class_type] - self.total
			if (self.grupo) then
				combat_table.totals_grupo [class_type] = combat_table.totals_grupo [class_type] - self.total
			end
		end
		function healingClass:add_total (combat_table)
			combat_table.totals [class_type] = combat_table.totals [class_type] + self.total
			if (self.grupo) then
				combat_table.totals_grupo [class_type] = combat_table.totals_grupo [class_type] + self.total
			end
		end

	---sum the passed actor into a combat, if the combat isn't passed, it will use the overall combat
	---the function returns the actor that was created of found in the combat passed
	---@param actorObject actor
	---@param bRefreshActor boolean|nil
	---@param combatObject combat|nil
	---@return actor
	function healingClass:AddToCombat(actorObject, bRefreshActor, combatObject)
		--check if there's a custom combat, if not just use the overall container
		combatObject = combatObject or _detalhes.tabela_overall --same as Details:GetCombat(DETAILS_SEGMENTID_OVERALL)

		--check if the combatObject has an actor with the same name, if not, just create one new
		local actorContainer = combatObject[DETAILS_ATTRIBUTE_HEAL] --same as combatObject:GetContainer(DETAILS_ATTRIBUTE_HEAL)
		local overallActor = actorContainer._ActorTable[actorContainer._NameIndexTable[actorObject.nome]] --same as actorContainer:GetActor(actorObject:Name())

		if (not overallActor) then
			overallActor = actorContainer:GetOrCreateActor(actorObject.serial, actorObject.nome, actorObject.flag_original, true)
			overallActor.classe = actorObject.classe
			overallActor:SetSpecId(actorObject.spec)
			overallActor.pvp = actorObject.pvp
			overallActor.isTank = actorObject.isTank
			overallActor.boss = actorObject.boss
			overallActor.start_time = time() - 3
			overallActor.end_time = time()
		end

		overallActor.displayName = actorObject.displayName or actorObject.nome
		overallActor.boss_fight_component = actorObject.boss_fight_component or overallActor.boss_fight_component
		overallActor.fight_component = actorObject.fight_component or overallActor.fight_component
		overallActor.grupo = actorObject.grupo or overallActor.grupo

		--check if need to restore meta tables and indexes for this actor
		if (bRefreshActor) then
			--this call will reenable the metatable, __index and set the metatable on the .spells container
			Details.refresh:r_atributo_heal(actorObject)
		end

		--elapsed time
		local endTime = actorObject.end_time
		if (not actorObject.end_time) then
			endTime = time()
		end

		local tempo = endTime - actorObject.start_time
		overallActor.start_time = overallActor.start_time - tempo

		--pets (add unique pet names)
		for _, petName in ipairs(actorObject.pets) do
			DetailsFramework.table.addunique(overallActor.pets, petName)
		end

		---@cast actorObject actorheal

		--total healing done and total overheal
		overallActor.total = overallActor.total + actorObject.total
		overallActor.totalover = overallActor.totalover + actorObject.totalover

		--healing done by shields
		overallActor.totalabsorb = overallActor.totalabsorb + actorObject.totalabsorb

		--enemy healing done
		overallActor.heal_enemy_amt = overallActor.heal_enemy_amt + actorObject.heal_enemy_amt

		--heal denied
		overallActor.totaldenied = overallActor.totaldenied + actorObject.totaldenied

		--healing done without pets
		overallActor.total_without_pet = overallActor.total_without_pet + actorObject.total_without_pet
		overallActor.totalover_without_pet = overallActor.totalover_without_pet + actorObject.totalover_without_pet

		--healing taken
		overallActor.healing_taken = overallActor.healing_taken + actorObject.healing_taken

		--total no combate overall (captura de dados)
		combatObject.totals[2] = combatObject.totals[2] + actorObject.total
		if (actorObject.grupo) then --same as Details:IsGroupPlayer()
			combatObject.totals_grupo[2] = combatObject.totals_grupo[2] + actorObject.total
		end

		--copy healing taken from
		for healerName, _ in pairs(actorObject.healing_from) do
			overallActor.healing_from[healerName] = true
		end

		--copy enemy healing
		for spellId, amount in pairs(actorObject.heal_enemy) do
			overallActor.heal_enemy[spellId] = (overallActor.heal_enemy[spellId] or 0) + amount
		end

		--copy target tables
		for targetName, amount in pairs(actorObject.targets) do
			overallActor.targets[targetName] = (overallActor.targets[targetName] or 0) + amount
		end

		for targetName, amount in pairs(actorObject.targets_overheal) do
			overallActor.targets_overheal[targetName] = (overallActor.targets_overheal[targetName] or 0) + amount
		end

		for targetName, amount in pairs(actorObject.targets_absorbs) do
			overallActor.targets_absorbs[targetName] = (overallActor.targets_absorbs[targetName] or 0) + amount
		end

		---@type spellcontainer
		local overallSpellsContainer = overallActor.spells --same as overallActor:GetSpellContainer("spell")

		--copy spell table
		for spellId, spellTable in pairs(actorObject.spells._ActorTable) do --same as overallSpellsContainer:GetRawSpellTable()
			--var name has 'overall' but this function accepts any combat table
			local overallSpellTable = overallSpellsContainer:GetOrCreateSpell(spellId, true)

			--sum spell targets
			for targetName, amount in pairs(spellTable.targets) do
				overallSpellTable.targets[targetName] = (overallSpellTable.targets[targetName] or 0) + amount
			end

			for targetName, amount in pairs(spellTable.targets_overheal) do
				overallSpellTable.targets_overheal[targetName] = (overallSpellTable.targets_overheal[targetName] or 0) + amount
			end

			for targetName, amount in pairs(spellTable.targets_absorbs) do
				overallSpellTable.targets_absorbs[targetName] = (overallSpellTable.targets_absorbs[targetName] or 0) + amount
			end

			--copy heal denied if it exists
			if (spellTable.heal_denied) then
				overallSpellTable.heal_denied = overallSpellTable.heal_denied or {}
				overallSpellTable.heal_denied_healers = overallSpellTable.heal_denied_healers or {}
				--copy
				for spellID, amount in pairs(spellTable.heal_denied) do
					overallSpellTable.heal_denied[spellID] = (overallSpellTable.heal_denied[spellID] or 0) + amount
				end
				for healerName, amount in pairs(spellTable.heal_denied_healers) do
					overallSpellTable.heal_denied_healers[healerName] = (overallSpellTable.heal_denied_healers[healerName] or 0) + amount
				end
			end

			overallSpellTable.spellschool = spellTable.spellschool

			--sum all values of the spelltable which can be summed
			for key, value in pairs(spellTable) do
				if (type(value) == "number") then
					if (key ~= "id" and key ~= "spellschool") then
						if (not overallSpellTable[key]) then
							overallSpellTable[key] = 0
						end

						if (key == "n_min" or key == "c_min") then
							if (overallSpellTable[key] > value) then
								overallSpellTable[key] = value
							end
						elseif (key == "n_max" or key == "c_max") then
							if (overallSpellTable[key] < value) then
								overallSpellTable[key] = value
							end
						else
							overallSpellTable[key] = overallSpellTable[key] + value
						end
					end

				--empowered spells
				elseif(key == "e_heal" or key == "e_lvl") then
					if (not overallSpellTable[key]) then
						overallSpellTable[key] = {}
					end
					for empowermentLevel, empowermentValue in pairs(spellTable[key]) do
						overallSpellTable[key][empowermentLevel] = empowermentValue
					end
				end
			end
		end

		return overallActor
	end

healingClass.__add = function(tabela1, tabela2)
	--tempo decorrido
		local tempo = (tabela2.end_time or time()) - tabela2.start_time
		tabela1.start_time = tabela1.start_time - tempo

	--total de cura
		tabela1.total = tabela1.total + tabela2.total
	--total de overheal
		tabela1.totalover = tabela1.totalover + tabela2.totalover
	--total de absorbs
		tabela1.totalabsorb = tabela1.totalabsorb + tabela2.totalabsorb
	--total de cura feita em inimigos
		tabela1.heal_enemy_amt = tabela1.heal_enemy_amt + tabela2.heal_enemy_amt
	--total de cura negada
		tabela1.totaldenied = tabela1.totaldenied + tabela2.totaldenied

	--total sem pets
		tabela1.total_without_pet = tabela1.total_without_pet + tabela2.total_without_pet
		tabela1.totalover_without_pet = tabela1.totalover_without_pet + tabela2.totalover_without_pet
	--total de cura recebida
		tabela1.healing_taken = tabela1.healing_taken + tabela2.healing_taken

	--soma o healing_from
		for nome, _ in pairs(tabela2.healing_from) do
			tabela1.healing_from [nome] = true
		end

	--somar o heal_enemy
		for spellid, amount in pairs(tabela2.heal_enemy) do
			if (tabela1.heal_enemy [spellid]) then
				tabela1.heal_enemy [spellid] = tabela1.heal_enemy [spellid] + amount
			else
				tabela1.heal_enemy [spellid] = amount
			end
		end

	--somar o container de alvos
		for target_name, amount in pairs(tabela2.targets) do
			tabela1.targets[target_name] = (tabela1.targets[target_name] or 0) + amount
		end
		for target_name, amount in pairs(tabela2.targets_overheal) do
			tabela1.targets_overheal[target_name] = (tabela1.targets_overheal[target_name] or 0) + amount
		end
		for target_name, amount in pairs(tabela2.targets_absorbs) do
			tabela1.targets_absorbs[target_name] = (tabela1.targets_absorbs[target_name] or 0) + amount
		end

	--soma o container de habilidades
		for spellid, habilidade in pairs(tabela2.spells._ActorTable) do
			--pega a habilidade no primeiro ator
			local habilidade_tabela1 = tabela1.spells:PegaHabilidade (spellid, true, "SPELL_HEAL", false)
			--soma os alvos
			for target_name, amount in pairs(habilidade.targets) do
				habilidade_tabela1.targets = (habilidade_tabela1.targets[target_name] or 0) + amount
			end
			for target_name, amount in pairs(habilidade.targets_overheal) do
				habilidade_tabela1.targets_overheal = (habilidade_tabela1.targets_overheal[target_name] or 0) + amount
			end
			for target_name, amount in pairs(habilidade.targets_absorbs) do
				habilidade_tabela1.targets_absorbs = (habilidade_tabela1.targets_absorbs[target_name] or 0) + amount
			end

			--copia o container de heal negado se ele existir
			if (habilidade.heal_denied) then
				habilidade_tabela1.heal_denied = habilidade_tabela1.heal_denied or {}
				habilidade_tabela1.heal_denied_healers = habilidade_tabela1.heal_denied_healers or {}
				--copia
				for spellID, amount in pairs(habilidade.heal_denied) do
					habilidade_tabela1.heal_denied[spellID] = (habilidade_tabela1.heal_denied[spellID] or 0) + amount
				end
				for healerName, amount in pairs(habilidade.heal_denied_healers) do
					habilidade_tabela1.heal_denied_healers[healerName] = (habilidade_tabela1.heal_denied_healers[healerName] or 0) + amount
				end
			end

			--soma os valores da habilidade
			for key, value in pairs(habilidade) do
				if (type(value) == "number") then
					if (key ~= "id") then
						if (not habilidade_tabela1 [key]) then
							habilidade_tabela1 [key] = 0
						end
						if (key == "n_min" or key == "c_min") then
							if (habilidade_tabela1 [key] > value) then
								habilidade_tabela1 [key] = value
							end
						elseif (key == "n_max" or key == "c_max") then
							if (habilidade_tabela1 [key] < value) then
								habilidade_tabela1 [key] = value
							end
						else
							habilidade_tabela1 [key] = habilidade_tabela1 [key] + value
						end
					end
				elseif(key == "e_heal" or key == "e_lvl") then
					if (not habilidade_tabela1[key]) then
						habilidade_tabela1[key] = {}
					end
					for empowermentLevel, empowermentValue in pairs(habilidade[key]) do 
						habilidade_tabela1[key][empowermentLevel] = habilidade_tabela1[key][empowermentValue] or 0 + empowermentValue
					end
				end
			end
		end

	return tabela1
end

healingClass.__sub = function(tabela1, tabela2)

	--tempo decorrido
		local tempo = (tabela2.end_time or time()) - tabela2.start_time
		tabela1.start_time = tabela1.start_time + tempo

	--total de cura
		tabela1.total = tabela1.total - tabela2.total
	--total de overheal
		tabela1.totalover = tabela1.totalover - tabela2.totalover
	--total de absorbs
		tabela1.totalabsorb = tabela1.totalabsorb - tabela2.totalabsorb
	--total de cura feita em inimigos
		tabela1.heal_enemy_amt = tabela1.heal_enemy_amt - tabela2.heal_enemy_amt
	--total de cura negada
		tabela1.totaldenied = tabela1.totaldenied - tabela2.totaldenied

	--total sem pets
		tabela1.total_without_pet = tabela1.total_without_pet - tabela2.total_without_pet
		tabela1.totalover_without_pet = tabela1.totalover_without_pet - tabela2.totalover_without_pet
	--total de cura recebida
		tabela1.healing_taken = tabela1.healing_taken - tabela2.healing_taken

	--reduz o heal_enemy
		for spellid, amount in pairs(tabela2.heal_enemy) do
			if (tabela1.heal_enemy [spellid]) then
				tabela1.heal_enemy [spellid] = tabela1.heal_enemy [spellid] - amount
			else
				tabela1.heal_enemy [spellid] = amount
			end
		end

	--reduz o container de alvos
		for target_name, amount in pairs(tabela2.targets) do
			if (tabela1.targets [target_name]) then
				tabela1.targets [target_name] = tabela1.targets [target_name] - amount
			end
		end
		for target_name, amount in pairs(tabela2.targets_overheal) do
			if (tabela1.targets_overheal [target_name]) then
				tabela1.targets_overheal [target_name] = tabela1.targets_overheal [target_name] - amount
			end
		end
		for target_name, amount in pairs(tabela2.targets_absorbs) do
			if (tabela1.targets_absorbs [target_name]) then
				tabela1.targets_absorbs [target_name] = tabela1.targets_absorbs [target_name] - amount
			end
		end

	--reduz o container de habilidades
		for spellid, habilidade in pairs(tabela2.spells._ActorTable) do
			--pega a habilidade no primeiro ator
			local habilidade_tabela1 = tabela1.spells:PegaHabilidade (spellid, true, "SPELL_HEAL", false)
			--alvos
			for target_name, amount in pairs(habilidade.targets) do
				if (habilidade_tabela1.targets [target_name]) then
					habilidade_tabela1.targets [target_name] = habilidade_tabela1.targets [target_name] - amount
				end
			end
			for target_name, amount in pairs(habilidade.targets_overheal) do
				if (habilidade_tabela1.targets_overheal [target_name]) then
					habilidade_tabela1.targets_overheal [target_name] = habilidade_tabela1.targets_overheal [target_name] - amount
				end
			end
			for target_name, amount in pairs(habilidade.targets_absorbs) do
				if (habilidade_tabela1.targets_absorbs [target_name]) then
					habilidade_tabela1.targets_absorbs [target_name] = habilidade_tabela1.targets_absorbs [target_name] - amount
				end
			end

			--copia o container de heal negado se ele existir
			if (habilidade.heal_denied) then
				habilidade_tabela1.heal_denied = habilidade_tabela1.heal_denied or {}
				habilidade_tabela1.heal_denied_healers = habilidade_tabela1.heal_denied_healers or {}
				--copia
				for spellID, amount in pairs(habilidade.heal_denied) do
					habilidade_tabela1.heal_denied [spellID] = (habilidade_tabela1.heal_denied [spellID] or 0) - amount
				end
				for healerName, amount in pairs(habilidade.heal_denied_healers) do
					habilidade_tabela1.heal_denied_healers [healerName] = (habilidade_tabela1.heal_denied_healers [healerName] or 0) - amount
				end
			end

			--soma os valores da habilidade
			for key, value in pairs(habilidade) do
				if (type(value) == "number") then
					if (key ~= "id") then
						if (not habilidade_tabela1 [key]) then
							habilidade_tabela1 [key] = 0
						end
						if (key == "n_min" or key == "c_min") then
							if (habilidade_tabela1 [key] > value) then
								habilidade_tabela1 [key] = value
							end
						elseif (key == "n_max" or key == "c_max") then
							if (habilidade_tabela1 [key] < value) then
								habilidade_tabela1 [key] = value
							end
						else
							habilidade_tabela1 [key] = habilidade_tabela1 [key] - value
						end
					end
				end
			end
		end

	return tabela1
end

function Details.refresh:r_atributo_heal(thisActor)
	detailsFramework:Mixin(thisActor, Details222.Mixins.ActorMixin)

	setmetatable(thisActor, healingClass)
	thisActor.__index = healingClass

	Details.refresh:r_container_habilidades(thisActor.spells)
end

function Details.clear:c_atributo_heal (este_jogador)
	este_jogador.__index = nil
	este_jogador.links = nil
	este_jogador.minha_barra = nil

	Details.clear:c_container_habilidades (este_jogador.spells)
end
