--[[ Esta classe irá abrigar todo a e_energy ganha de uma habilidade
Parents:
	addon -> combate atual -> e_energy-> container de jogadores -> esta classe

]]

--lua locals
local _cstr = string.format
local _math_floor = math.floor
local _table_sort = table.sort
local _table_insert = table.insert
local _setmetatable = setmetatable
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

local alvo_da_habilidade = 	_detalhes.alvo_da_habilidade
local container_habilidades = 	_detalhes.container_habilidades
local container_combatentes = _detalhes.container_combatentes
local container_pets =		_detalhes.container_pets
local atributo_energy =		_detalhes.atributo_energy
local habilidade_energy = 	_detalhes.habilidade_energy

--local container_damage_target = _detalhes.container_type.CONTAINER_DAMAGETARGET_CLASS
local container_playernpc = _detalhes.container_type.CONTAINER_PLAYERNPC
local container_energy = _detalhes.container_type.CONTAINER_ENERGY_CLASS
local container_energy_target = _detalhes.container_type.CONTAINER_ENERGYTARGET_CLASS
--local container_friendlyfire = _detalhes.container_type.CONTAINER_FRIENDLYFIRE

--local modo_ALONE = _detalhes.modos.alone
local modo_GROUP = _detalhes.modos.group
local modo_ALL = _detalhes.modos.all

local class_type = _detalhes.atributos.e_energy

local DATA_TYPE_START = _detalhes._detalhes_props.DATA_TYPE_START
local DATA_TYPE_END = _detalhes._detalhes_props.DATA_TYPE_END

local DFLAG_player = _detalhes.flags.player
local DFLAG_group = _detalhes.flags.in_group
local DFLAG_player_group = _detalhes.flags.player_in_group

local div_abre = _detalhes.divisores.abre
local div_fecha = _detalhes.divisores.fecha
local div_lugar = _detalhes.divisores.colocacao

local info = _detalhes.janela_info
local keyName


function atributo_energy:NovaTabela (serial, nome, link)

	--> constructor
	local _new_energyActor = {
	
		last_event = 0,
		tipo = class_type, --> atributo 3 = e_energy
		
		mana = 0,
		e_rage = 0,
		e_energy = 0,
		runepower = 0,
		focus = 0,
		holypower = 0,

		mana_r = 0,
		e_rage_r = 0,
		e_energy_r = 0,
		runepower_r = 0,
		focus_r = 0,
		holypower_r = 0,
		
		mana_from = {},
		e_rage_from = {},
		e_energy_from = {},
		runepower_from = {},
		focus_from = {},
		holypower_from = {},
		
		last_value = nil, --> ultimo valor que este jogador teve, salvo quando a barra dele é atualizada

		pets = {},
		
		--container armazenará os seriais dos alvos que o player aplicou dano
		targets = container_combatentes:NovoContainer (container_energy_target),
		
		--container armazenará os IDs das habilidades usadas por este jogador
		spell_tables = container_habilidades:NovoContainer (container_energy),
	}
	
	_setmetatable (_new_energyActor, atributo_energy)
	
	if (link) then
		_new_energyActor.targets.shadow = link.targets
		_new_energyActor.spell_tables.shadow = link.spell_tables
	end
	
	return _new_energyActor
end

function atributo_energy:RefreshWindow (instancia, tabela_do_combate, forcar, exportar)

	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable

	if (#showing._ActorTable < 1) then --> não há barras para mostrar
		return _detalhes:EsconderBarrasNaoUsadas (instancia, showing) 
	end
	
	local total = 0 --> total iniciado como ZERO
	instancia.top = 0
	
	local sub_atributo = instancia.sub_atributo --> o que esta sendo mostrado nesta instância
	local conteudo = showing._ActorTable
	local amount = #conteudo
	local modo = instancia.modo
	
	if (exportar) then
		if (_type (exportar) == "boolean") then 		
			if (sub_atributo == 1) then --> MANA RECUPERADA
				keyName = "mana"
			elseif (sub_atributo == 2) then --> e_rage GANHA
				keyName = "e_rage"
			elseif (sub_atributo == 3) then --> ENERGIA GANHA
				keyName = "e_energy"
			elseif (sub_atributo == 4) then --> RUNEPOWER GANHO
				keyName = "runepower"
			end
		else
			keyName = exportar.key
			modo = exportar.modo		
		end
		
	elseif (instancia.atributo == 5) then --> custom
		keyName = "custom"
		total = tabela_do_combate.totals [instancia.customName]
		
	else
		if (sub_atributo == 1) then --> MANA RECUPERADA
			keyName = "mana"
		elseif (sub_atributo == 2) then --> e_rage GANHA
			keyName = "e_rage"
		elseif (sub_atributo == 3) then --> ENERGIA GANHA
			keyName = "e_energy"
		elseif (sub_atributo == 4) then --> RUNEPOWER GANHO
			keyName = "runepower"
		end
	end
	
	if (instancia.atributo == 5) then --> custom
		--> faz o sort da categoria e retorna o amount corrigido
		amount = _detalhes:ContainerSort (conteudo, amount, keyName)
		
		--> grava o total
		instancia.top = conteudo[1][keyName]
	
	elseif (modo == modo_ALL) then --> mostrando ALL
	
		--> faz o sort da categoria
		_table_sort (conteudo, function (a, b) return a[keyName] > b[keyName] end)
		
		--> não mostrar resultados com zero
		for i = amount, 1, -1 do --> de trás pra frente
			if (conteudo[i][keyName] < 1) then
				amount = amount-1
			else
				break
			end
		end
		
		total = tabela_do_combate.totals [class_type] [keyName] --> pega o total de dano já aplicado
		
		instancia.top = conteudo[1] [keyName]
			
	elseif (modo == modo_GROUP) then --> mostrando GROUP
		
		_table_sort (conteudo, function (a, b)
				if (a.grupo and b.grupo) then
					return a[keyName] > b[keyName]
				elseif (a.grupo and not b.grupo) then
					return true
				elseif (not a.grupo and b.grupo) then
					return false
				else
					return a[keyName] > b[keyName]
				end
			end)
		
		for index, player in _ipairs (conteudo) do
			if (_bit_band (player.flag, DFLAG_player_group) >= 0x101) then --> é um player e esta em grupo
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

	showing:remapear()

	if (exportar) then 
		return total, keyName, instancia.top
	end
	
	if (amount < 1) then --> não há barras para mostrar
		instancia:EsconderScrollBar()
		return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
	end

	instancia:AtualizarScrollBar (amount)

	local qual_barra = 1
	local barras_container = instancia.barras

	for i = instancia.barraS[1], instancia.barraS[2], 1 do --> vai atualizar só o range que esta sendo mostrado
		conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar) --> instância, index, total, valor da 1º barra
		qual_barra = qual_barra+1
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

function atributo_energy:Custom (_customName, _combat, sub_atributo, spell, alvo)
	local _Skill = self.spell_tables._ActorTable [tonumber (spell)]
	if (_Skill) then
		local spellName = _GetSpellInfo (tonumber (spell))
		local SkillTargets = _Skill.targets._ActorTable
		
		for _, TargetActor in _ipairs (SkillTargets) do 
			local TargetActorSelf = _combat (class_type, TargetActor.nome)
			TargetActorSelf.custom = TargetActor.total + TargetActorSelf.custom
			_combat.totals [_customName] = _combat.totals [_customName] + TargetActor.total
		end
	end
end

function atributo_energy:AtualizaBarra (instancia, barras_container, qual_barra, lugar, total, sub_atributo, forcar)

	local esta_barra = instancia.barras[qual_barra] --> pega a referência da barra na janela
	
	if (not esta_barra) then
		print ("DEBUG: problema com <instancia.esta_barra> "..qual_barra.." "..lugar)
		return
	end
	
	local tabela_anterior = esta_barra.minha_tabela
	
	esta_barra.minha_tabela = self
	esta_barra.colocacao = lugar
	
	self.minha_barra = esta_barra
	self.colocacao = lugar

	local esta_e_energy_total = self [keyName] --> total de dano que este jogador deu
	local porcentagem = esta_e_energy_total / total * 100
	local esta_porcentagem = _math_floor ((esta_e_energy_total/instancia.top) * 100)

	esta_barra.texto_direita:SetText (_detalhes:ToK (esta_e_energy_total) .. " " .. div_abre .. _cstr ("%.1f", porcentagem).."%" .. div_fecha) --seta o texto da direita
	
	if (esta_barra.mouse_over and not instancia.baseframe.isMoving) then --> precisa atualizar o tooltip
		gump:UpdateTooltip (qual_barra, esta_barra, instancia)
	end

	return self:RefreshBarra2 (esta_barra, instancia, tabela_anterior, forcar, esta_porcentagem, qual_barra, barras_container)
end



--------------------------------------------- // TOOLTIPS // ---------------------------------------------
function atributo_energy:KeyNames (sub_atributo)
	if (sub_atributo == 1) then --> MANA RECUPERADA
		return "mana", "mana_from"
	elseif (sub_atributo == 2) then --> e_rage GANHA
		return "e_rage", "e_rage_from"
	elseif (sub_atributo == 3) then --> ENERGIA GANHA
		return "e_energy", "e_energy_from"
	elseif (sub_atributo == 4) then --> RUNEPOWER GANHO
		return "runepower", "runepower_from"
	end
end

function atributo_energy:Fontes_e_Habilidades (recebido_from, showing, keyName, habilidade_alvo)

	local habilidades = {}
	local fontes = {}
	local spells_alvo = {}
	local max = 0
	
	for nome, _ in _pairs (recebido_from) do
		local esta_fonte = showing._ActorTable [showing._NameIndexTable [nome]]
		if (esta_fonte) then
		
			local alvos = esta_fonte.targets
			local _habilidades = esta_fonte.spell_tables
			
			local este_alvo = alvos._ActorTable [alvos._NameIndexTable[self.nome]]
			if (este_alvo) then
				fontes [#fontes+1] = {nome, este_alvo [keyName], esta_fonte.classe} --> mostra QUEM deu regen, a QUANTIDADE e a CLASSE
				--print (nome, este_alvo [keyName], esta_fonte.classe)
			end
			
			for spellid, habilidade in _pairs (_habilidades._ActorTable) do 
				local alvos = habilidade.targets
				local este_alvo = alvos._ActorTable [alvos._NameIndexTable[self.nome]]
				if (este_alvo) then
					if (not habilidades [spellid]) then
						habilidades [spellid] = 0 --> mostra A SPELL e a quantidade que ela deu regen
					end
					habilidades [spellid] = habilidades [spellid] + este_alvo [keyName]
					if (habilidades [spellid] > max) then
						max = habilidades [spellid]
					end
					if (habilidade_alvo and habilidade_alvo == spellid) then
						spells_alvo [#spells_alvo + 1] = {nome, este_alvo [keyName], esta_fonte.classe}
					elseif (habilidade_alvo == true) then
						--print (nome, nome, este_alvo [keyName], spellid)
						spells_alvo [#spells_alvo + 1] = {nome, este_alvo [keyName], spellid}
					end
				end
			end
		end
	end

	local sorted_table = {}
	for spellid, amt in _pairs (habilidades) do 
		local nome, _, icone = _GetSpellInfo (spellid)
		sorted_table [#sorted_table+1] = {spellid, amt, amt/max*100, nome, icone}
	end
	_table_sort (sorted_table, function (a, b) return a[2] > b[2] end)
	
	_table_sort (fontes, function (a, b) return a[2] > b[2] end)
	
	if (habilidade_alvo) then
		_table_sort (spells_alvo, function (a, b) return a[2] > b[2] end)
	end
	
	return fontes, sorted_table, spells_alvo
end


---------> TOOLTIPS BIFURCAÇÃO
function atributo_energy:ToolTip (instancia, numero, barra)
	--> seria possivel aqui colocar o icone da classe dele?
	--GameCooltip:AddLine (barra.colocacao..". "..self.nome)
	if (instancia.sub_atributo <= 4) then
		return self:ToolTipRegenRecebido (instancia, numero, barra)
	end
end
--> tooltip locals
local r, g, b
local headerColor = "yellow"
local barAlha = .6

function atributo_energy:ToolTipRegenRecebido (instancia, numero, barra)
	
	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack (_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack (_detalhes.class_colors [self.classe])
	end	
	
	local tabela_do_combate = instancia.showing
	local showing = tabela_do_combate [class_type] 
	
	local keyName, keyName_from = atributo_energy:KeyNames (instancia.sub_atributo)
	
	local total_regenerado = self [keyName]
	local recebido_from = self [keyName_from]
	
	local fontes, habilidades = self:Fontes_e_Habilidades (recebido_from, showing, keyName)

-----------------------------------------------------------------	
	GameCooltip:AddLine (Loc ["STRING_SPELLS"], nil, nil, headerColor, nil, 12) --> localiza-me
	GameCooltip:AddIcon ([[Interface\HELPFRAME\ReportLagIcon-Spells]], 1, 1, 14, 14, 0.21875, 0.78125, 0.21875, 0.78125)
	GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)	
	
	local max = #habilidades
	if (max > 3) then
		max = 3
	end

	for i = 1, max do
		local nome_magia, _, icone_magia = _GetSpellInfo (habilidades[i][1])
		GameCooltip:AddLine (nome_magia..": ", _detalhes:comma_value (habilidades[i][2]).." (".._cstr("%.1f", (habilidades[i][2]/total_regenerado) * 100).."%)")
		GameCooltip:AddIcon (icone_magia)
		GameCooltip:AddStatusBar (100, 1, .1, .1, .1, .3)
	end
	
-----------------------------------------------------------------
	GameCooltip:AddLine (Loc ["STRING_PLAYERS"], nil, nil, headerColor, nil, 12) --> localiza-me
	GameCooltip:AddIcon ([[Interface\HELPFRAME\HelpIcon-HotIssues]], 1, 1, 14, 14, 0.21875, 0.78125, 0.21875, 0.78125)
	GameCooltip:AddStatusBar (100, 1, r, g, b, barAlha)	
	
	max = #fontes
	if (max > 3) then
		max = 3
	end
	
	for i = 1, max do
		GameCooltip:AddLine (fontes[i][1]..": ", _detalhes:comma_value (fontes[i][2]).." (".._cstr("%.1f", (fontes[i][2]/total_regenerado) * 100).."%)")
		GameCooltip:AddStatusBar (100, 1, .1, .1, .1, .3)
		
		local classe = fontes[i][3]
		if (not classe) then
			classe = "UNKNOW"
		end
		if (classe == "UNKNOW") then
			GameCooltip:AddIcon ("Interface\\LFGFRAME\\LFGROLE_BW", nil, nil, 14, 14, .25, .5, 0, 1)
		else
			GameCooltip:AddIcon ("Interface\\AddOns\\Details\\images\\classes_small", nil, nil, 14, 14, _unpack (_detalhes.class_coords [classe]))
		end
		
	end
	
	return true
end

--------------------------------------------- // JANELA DETALHES // ---------------------------------------------

---------> DETALHES BIFURCAÇÃO
function atributo_energy:MontaInfo()
	if (info.sub_atributo <= 4) then --> damage done & dps
		return self:MontaInfoRegenRecebido()
	end
end

---------> DETALHES bloco da direita BIFURCAÇÃO
function atributo_energy:MontaDetalhes (spellid, barra)
	if (info.sub_atributo <= 4) then
		return self:MontaDetalhesRegenRecebido (spellid, barra)
	end
end

function atributo_energy:MontaInfoRegenRecebido()

	local barras = info.barras1
	local barras2 = info.barras2
	local barras3 = info.barras3
	
	local instancia = info.instancia

	local keyName, keyName_from = atributo_energy:KeyNames (instancia.sub_atributo)
	
	local tabela_do_combate = instancia.showing
	local showing = tabela_do_combate [class_type] 
	
	local total_regenerado = self [keyName]
	local recebido_from = self [keyName_from]
	
	if (not recebido_from) then
		return
	end
	
	local fontes, habilidades = self:Fontes_e_Habilidades (recebido_from, showing, keyName)
	
	local amt = #habilidades
	
	if (amt < 1) then --> caso houve apenas friendly fire
		return true
	end
	
	gump:JI_AtualizaContainerBarras (amt)
	local max_ = habilidades [1][2]
	
	for index, tabela in _ipairs (habilidades) do
		
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
		barra:Show()

		if (self.detalhes and self.detalhes == barra.show) then
			self:MontaDetalhes (self.detalhes, barra)
		end
		
	end
	

	local amt_fontes = #fontes
	gump:JI_AtualizaContainerAlvos (amt_fontes)
	
	local max_fontes = fontes[1][2]
	
	local barra
	for index, tabela in _ipairs (fontes) do
	
		barra = info.barras2 [index]
		
		if (not barra) then
			barra = gump:CriaNovaBarraInfo2 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1)
		end
		
		if (index == 1) then
			barra.textura:SetValue (100)
		else
			barra.textura:SetValue (tabela[2]/max_fontes*100)
		end
		
		barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[1]) --seta o texto da esqueda
		barra.texto_direita:SetText (_detalhes:comma_value (tabela[2]) .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[2]/total_regenerado * 100) .. instancia.divisores.fecha) --seta o texto da direita
		
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

		barra:Show()
	end	

end

function atributo_energy:MontaDetalhesRegenRecebido (nome, barra)
	for _, barra in _ipairs (info.barras3) do 
		barra:Hide()
	end
	
	local barras = info.barras3
	local instancia = info.instancia

	local tabela_do_combate = info.instancia.showing
	local showing = tabela_do_combate [class_type]
	
	local keyName, keyName_from = atributo_energy:KeyNames (instancia.sub_atributo)
	local recebido_from = self [keyName_from]
	local total_regenerado = self [keyName]
	
	local _, _, from = self:Fontes_e_Habilidades (recebido_from, showing, keyName, nome)
	
	if (not from [1] or not from [1][2]) then
		return
	end
	
	local max_ = from [1][2]
	
	local barra
	for index, tabela in _ipairs (from) do
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

		barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[1]) --seta o texto da esqueda
		barra.texto_direita:SetText (_detalhes:comma_value (tabela[2]) .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[2] /total_regenerado *100) .."%".. instancia.divisores.fecha) --seta o texto da direita
		
		barra.textura:SetStatusBarColor (_unpack (_detalhes.class_colors [tabela[3]]))
		barra.icone:SetTexture ("Interface\\AddOns\\Details\\images\\classes_small")
		
		barra.icone:SetTexCoord (_unpack (_detalhes.class_coords [tabela[3]]))

		barra:Show() --> mostra a barra
		
		if (index == 15) then 
			break
		end
	end
end

function atributo_energy:MontaTooltipAlvos (esta_barra, index)
	local instancia = info.instancia
	local tabela_do_combate = instancia.showing
	local showing = tabela_do_combate [class_type] 
	
	local keyName, keyName_from = atributo_energy:KeyNames (instancia.sub_atributo)
	
	local total_regenerado = self [keyName]
	local recebido_from = self [keyName_from]
	
	local _, _, spells_alvo = self:Fontes_e_Habilidades (recebido_from, showing, keyName, true)

-----------------------------------------------------------------	
	GameTooltip:AddLine (Loc ["STRING_SPELLS"]..":")
	for _, tabela in _ipairs (spells_alvo) do
		if (tabela[1] == esta_barra.nome_inimigo) then
			local nome_magia, _, icone_magia = _GetSpellInfo (tabela[3])
			GameTooltip:AddDoubleLine (nome_magia..": ", _detalhes:comma_value (tabela[2]).." (".._cstr("%.1f", (tabela[2]/total_regenerado) * 100).."%)", 1, 1, 1, 1, 1, 1)
			GameTooltip:AddTexture (icone_magia)
		end
	end

	return true
end


--controla se o dps do jogador esta travado ou destravado
function atributo_energy:Iniciar (iniciar)
	return false --retorna se o dps esta aberto ou fechado para este jogador
end

function atributo_energy:ColetarLixo()
	return _detalhes:ColetarLixo (class_type)
end

local function ReconstroiMapa (tabela)
	local mapa = {}
	for i = 1, #tabela._ActorTable do
		mapa [tabela._ActorTable[i].nome] = i
	end
	tabela._NameIndexTable = mapa
end

function _detalhes.refresh:r_atributo_energy (este_jogador, shadow)
	_setmetatable (este_jogador, _detalhes.atributo_energy)
	este_jogador.__index = _detalhes.atributo_energy
	
	if (shadow ~= -1) then
		este_jogador.shadow = shadow
		_detalhes.refresh:r_container_combatentes (este_jogador.targets, shadow.targets)
		_detalhes.refresh:r_container_habilidades (este_jogador.spell_tables, shadow.spell_tables)
	else
		_detalhes.refresh:r_container_combatentes (este_jogador.targets, -1)
		_detalhes.refresh:r_container_habilidades (este_jogador.spell_tables, -1)
	end
end

function _detalhes.clear:c_atributo_energy (este_jogador)
	este_jogador.__index = {}
	este_jogador.shadow = nil
	este_jogador.links = nil
	este_jogador.minha_barra = nil
	
	_detalhes.clear:c_container_combatentes (este_jogador.targets)
	_detalhes.clear:c_container_habilidades (este_jogador.spell_tables)
end

atributo_energy.__add = function (shadow, tabela2)

	shadow.mana = shadow.mana + tabela2.mana
	shadow.e_rage = shadow.e_rage + tabela2.e_rage
	shadow.e_energy = shadow.e_energy + tabela2.e_energy
	shadow.runepower = shadow.runepower + tabela2.runepower
	shadow.focus = shadow.focus + tabela2.focus
	shadow.holypower = shadow.holypower + tabela2.holypower

	_detalhes.tabela_overall.totals[3]["mana"] = _detalhes.tabela_overall.totals[3]["mana"] + tabela2.mana
	_detalhes.tabela_overall.totals[3]["e_rage"] = _detalhes.tabela_overall.totals[3]["e_rage"] + tabela2.e_rage
	_detalhes.tabela_overall.totals[3]["e_energy"] = _detalhes.tabela_overall.totals[3]["e_energy"] + tabela2.e_energy
	_detalhes.tabela_overall.totals[3]["runepower"] = _detalhes.tabela_overall.totals[3]["runepower"] + tabela2.runepower
	
	if (tabela2.grupo) then
		_detalhes.tabela_overall.totals_grupo[3]["mana"] = _detalhes.tabela_overall.totals_grupo[3]["mana"] + tabela2.mana
		_detalhes.tabela_overall.totals_grupo[3]["e_rage"] = _detalhes.tabela_overall.totals_grupo[3]["e_rage"] + tabela2.e_rage
		_detalhes.tabela_overall.totals_grupo[3]["e_energy"] = _detalhes.tabela_overall.totals_grupo[3]["e_energy"] + tabela2.e_energy
		_detalhes.tabela_overall.totals_grupo[3]["runepower"] = _detalhes.tabela_overall.totals_grupo[3]["runepower"] + tabela2.runepower
	end
	
	shadow.mana_r = shadow.mana_r + tabela2.mana_r
	shadow.e_rage_r = shadow.e_rage_r + tabela2.e_rage_r
	shadow.e_energy_r = shadow.e_energy_r + tabela2.e_energy_r
	shadow.runepower_r = shadow.runepower_r + tabela2.runepower_r
	shadow.focus_r = shadow.focus_r + tabela2.focus_r
	shadow.holypower_r = shadow.holypower_r + tabela2.holypower_r

	for index, alvo in _ipairs (tabela2.targets._ActorTable) do 
		local alvo_shadow = shadow.targets:PegarCombatente (alvo.serial, alvo.nome, _, true)
		alvo_shadow.total = alvo_shadow.total + alvo.total
	end
	
	--> copia o container de habilidades
	for spellid, habilidade in _pairs (tabela2.spell_tables._ActorTable) do 
		local habilidade_shadow = shadow.spell_tables:PegaHabilidade (spellid, true, nil, true)
		
		for index, alvo in _ipairs (habilidade.targets._ActorTable) do 
			local alvo_shadow = habilidade_shadow.targets:PegarCombatente (alvo.serial, alvo.nome, _, true)
			alvo_shadow.total = alvo_shadow.total + alvo.total
		end
		
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
	end	
	
	return shadow
end

atributo_energy.__sub = function (tabela1, tabela2)

	tabela1.mana = tabela1.mana - tabela2.mana
	tabela1.e_rage = tabela1.e_rage - tabela2.e_rage
	tabela1.e_energy = tabela1.e_energy - tabela2.e_energy
	tabela1.runepower = tabela1.runepower - tabela2.runepower
	tabela1.focus = tabela1.focus - tabela2.focus
	tabela1.holypower = tabela1.holypower - tabela2.holypower

	tabela1.mana_r = tabela1.mana_r - tabela2.mana_r
	tabela1.e_rage_r = tabela1.e_rage_r - tabela2.e_rage_r
	tabela1.e_energy_r = tabela1.e_energy_r - tabela2.e_energy_r
	tabela1.runepower_r = tabela1.runepower_r - tabela2.runepower_r
	tabela1.focus_r = tabela1.focus_r - tabela2.focus_r
	tabela1.holypower_r = tabela1.holypower_r - tabela2.holypower_r

	return tabela1
end
