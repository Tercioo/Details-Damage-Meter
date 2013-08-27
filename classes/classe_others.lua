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
local _math_abs = math.abs
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
local atributo_misc =		_detalhes.atributo_misc
local habilidade_misc = 	_detalhes.habilidade_misc

--local container_damage_target = _detalhes.container_type.CONTAINER_DAMAGETARGET_CLASS
local container_playernpc = _detalhes.container_type.CONTAINER_PLAYERNPC
local container_misc = _detalhes.container_type.CONTAINER_MISC_CLASS
local container_misc_target = _detalhes.container_type.CONTAINER_ENERGYTARGET_CLASS
--local container_friendlyfire = _detalhes.container_type.CONTAINER_FRIENDLYFIRE

--local modo_ALONE = _detalhes.modos.alone
local modo_GROUP = _detalhes.modos.group
local modo_ALL = _detalhes.modos.all

local class_type = _detalhes.atributos.misc

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

function atributo_misc:NovaTabela (serial, nome, link)

	local _new_miscActor = {
		last_event = 0,
		tipo = class_type, --> atributo 4 = misc
		pets = {} --> pets? okey pets
	}
	_setmetatable (_new_miscActor, atributo_misc)
	
	return _new_miscActor
end

function _detalhes:ToolTipDead (instancia, morte, esta_barra)
	
	local eventos = morte [1]
	local hora_da_morte = morte [2]
	local hp_max = morte [5]
	
	local linhas = {}
	
	local battleress = false
	
	local GameCooltip = GameCooltip
	
	GameCooltip:Reset()
	GameCooltip:SetType ("tooltipbar")
	GameCooltip:SetOwner (esta_barra)

	
	for index, evento in _ipairs (eventos) do 
	
		local hp = _math_floor (evento[5]/hp_max*100)
		if (hp > 100) then 
			hp = 100
		end
		
		if (evento [1]) then --> DANO
			--print ("DANO|"..evento [4]-hora_da_morte.."|"..evento [2].."|"..evento [3]) --> {true, spellid, amount, _tempo}
			local nome_magia, _, icone_magia = _GetSpellInfo (evento [2])
			
			if (evento[3]) then 
				local amt_golpes = evento[7]
				if (amt_golpes)  then
					amt_golpes = "(x"..amt_golpes..") "
				else
					amt_golpes = ""
				end
				
				--> [1] left text [2] right text [3] main 1 or sub 2 [...] color
				GameCooltip:AddLine ("".._cstr ("%.1f", evento[4] - hora_da_morte) .."s "..amt_golpes..nome_magia.." ("..evento[6]..")", "-".._detalhes:ToK (evento[3]).." (".. hp .."%)", 1, "white", "white")
				--> [1] icon [2] main 1 or sub 2 [3] left or right [4,5] width height [...] texcoord
				GameCooltip:AddIcon (icone_magia)
				--> [1] value [2] main 1 or sub 2 [...] color [4] glow
				GameCooltip:AddStatusBar (hp, 1, "red", true)
			
			elseif (not battleress) then --> battle ress
				GameCooltip:AddLine ("+".._cstr ("%.1f", evento[4] - hora_da_morte) .."s "..nome_magia.." ("..evento[6]..")", "", 1, "white")
				GameCooltip:AddIcon ("Interface\\Glues\\CharacterSelect\\Glues-AddOn-Icons", 1, 1, nil, nil, .75, 1, 0, 1)
				GameCooltip:AddStatusBar (100, 1, "silver", false)
				battleress = true
				
			end
		else
			local nome_magia, _, icone_magia = _GetSpellInfo (evento [2])
			GameCooltip:AddLine ("".._cstr ("%.1f", evento[4] - hora_da_morte) .."s "..nome_magia.." ("..evento[6]..")", "+".._detalhes:ToK (evento[3]).." (".. hp .."%)", 1, "white", "white")
			GameCooltip:AddIcon (icone_magia, 1, 1)
			GameCooltip:AddStatusBar (hp, 1, "green", true)
		end
	end
	
	--GameCooltip:AddLine (" ", " ", 1, "white", "white")
	GameCooltip:AddLine (Loc ["STRING_REPORT_LEFTCLICK"], nil, 1, "white")
	GameCooltip:AddIcon ([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 1, 1, 12, 16, 0.015625, 0.13671875, 0.4375, 0.59765625)

	if (battleress) then
		--_table_insert (linhas, 2, {{"Interface\\AddOns\\Details\\images\\small_icons", .75, 1, 0, 1}, morte [6] .. " Morreu", "-- -- -- ", 100, {75/255, 75/255, 75/255, 1}, {noglow = true}}) --> localize-me
		GameCooltip:AddSpecial ("line", 2, nil, morte [6] .. " Morreu", "-- -- -- ", 1, "white")
		GameCooltip:AddSpecial ("icon", 2, nil, "Interface\\AddOns\\Details\\images\\small_icons", 1, 1, nil, nil, .75, 1, 0, 1)
		GameCooltip:AddSpecial ("statusbar", 2, nil, 100, 1, "darkgray", false)
	else
		GameCooltip:AddSpecial ("line", 1, nil, morte [6] .. " Morreu", "-- -- -- ", 1, "white")
		GameCooltip:AddSpecial ("icon", 1, nil, "Interface\\AddOns\\Details\\images\\small_icons", 1, 1, nil, nil, .75, 1, 0, 1)
		GameCooltip:AddSpecial ("statusbar", 1, nil, 100, 1, "darkgray", false)
		--_table_insert (linhas, 1, {{, .75, 1, 0, 1}, , 100, {75/255, 75/255, 75/255, 1}, {noglow = true}}) --> localize-me
	end

	GameCooltip:SetOption ("StatusBarHeightMod", -6)
	GameCooltip:SetOption ("FixedWidth", 300)
	GameCooltip:SetOption ("TextSize", 9.5)
	GameCooltip:ShowCooltip()
	
	--_detalhes.popup:ShowMe (esta_barra, "tooltip_bars", linhas, 300, 16, 9) --> [1] ancora [2] tipo do painel [3] texto/linhas [4] largura [5] tamanho do icone e altura da barra [6] tamanho da fonte
	
end

local function RefreshBarraMorte (morte, barra, instancia)
	atributo_misc:DeadAtualizarBarra (morte, morte.minha_barra, barra.colocacao, instancia)
end

function atributo_misc:ReportSingleDeadLine (morte, instancia)

	local barra = instancia.barras [morte.minha_barra]

	local reportar = {"Detalhes da morte de " .. morte [3] .. " " .. barra.texto_esquerdo:GetText()} --> localize-me
	for i = 1, GameCooltip:GetNumLines() do 
		local texto_left, texto_right = GameCooltip:GetText (i)
		
		if (texto_left and texto_right) then 
			texto_left = texto_left:gsub (("|T(.*)|t "), "")
			reportar [#reportar+1] = ""..texto_left.." "..texto_right..""
		end
	end

	return _detalhes:Reportar (reportar, {_no_current = true, _no_inverse = true, _custom = true})
end

function atributo_misc:DeadAtualizarBarra (morte, qual_barra, colocacao, instancia)

	morte ["dead"] = true --> temporario (testes)
	local esta_barra = instancia.barras[qual_barra] --> pega a referência da barra na janela
	
	if (not esta_barra) then
		print ("DEBUG: problema com <instancia.esta_barra> "..qual_barra.." "..lugar)
		return
	end
	
	local tabela_anterior = esta_barra.minha_tabela
	
	esta_barra.minha_tabela = morte
	
	morte.nome = morte [3] --> evita dar erro ao redimencionar a janela
	morte.minha_barra = qual_barra
	esta_barra.colocacao = colocacao
	
	if (not _getmetatable (morte)) then 
		_setmetatable (morte, {__call = RefreshBarraMorte}) 
		morte._custom = true
	end

	esta_barra.texto_esquerdo:SetText (colocacao .. ". " .. morte [3]:gsub (("%-.*"), ""))
	esta_barra.texto_direita:SetText (morte [6])
	
	esta_barra.statusbar:SetValue (100)
	if (esta_barra.hidden or esta_barra.fading_in or esta_barra.faded) then
		gump:Fade (esta_barra, "out")
	end
	esta_barra.textura:SetVertexColor (_unpack (_detalhes.class_colors [morte[4]]))
	esta_barra.icone_classe:SetTexture ("Interface\\AddOns\\Details\\images\\classes_small")
	esta_barra.icone_classe:SetTexCoord (_unpack (CLASS_ICON_TCOORDS [morte[4]]))
	
	if (esta_barra.mouse_over and not instancia.baseframe.isMoving) then --> precisa atualizar o tooltip
		gump:UpdateTooltip (qual_barra, esta_barra, instancia)
	end

	--return self:RefreshBarra2 (esta_barra, instancia, tabela_anterior, forcar, esta_porcentagem)
end

function atributo_misc:RefreshWindow (instancia, tabela_do_combate, forcar, exportar)
	
	--print ("refresh misc...")
	
	local total = 0 --> total iniciado como ZERO
	
	local showing = tabela_do_combate [class_type] --> o que esta sendo mostrado -> [1] - dano [2] - cura --> pega o container com ._NameIndexTable ._ActorTable
 
	if (#showing._ActorTable < 1) then --> não há barras para mostrar
		if (forcar) then
			_detalhes:EsconderBarrasNaoUsadas (instancia, showing)
		end
		return
	end
	
	--print ("refresh misc... 2")
	
	instancia.top = 0
	
	local sub_atributo = instancia.sub_atributo --> o que esta sendo mostrado nesta instância
	local conteudo = showing._ActorTable
	local amount = #conteudo
	local modo = instancia.modo
	
	if (exportar) then
		if (_type (exportar) == "boolean") then 		
			if (sub_atributo == 1) then --> CC BREAKS
				keyName = "cc_break"
			elseif (sub_atributo == 2) then --> RESS
				keyName = "ress"
			elseif (sub_atributo == 3) then --> INTERRUPT
				keyName = "interrupt"
			elseif (sub_atributo == 4) then --> DISPELLS
				keyName = "dispell"
			elseif (sub_atributo == 5) then --> DEATHS
				keyName = "dead"
			end
		else
			keyName = exportar.key
			modo = exportar.modo
		end
		
	elseif (instancia.atributo == 5) then --> custom
		keyName = "custom"
		total = tabela_do_combate.totals [instancia.customName]		
		
	else	
		
		--> pega qual a sub key que será usada
		if (sub_atributo == 1) then --> CC BREAKS
			keyName = "cc_break"
		elseif (sub_atributo == 2) then --> RESS
			keyName = "ress"
		elseif (sub_atributo == 3) then --> INTERRUPT
			keyName = "interrupt"
		elseif (sub_atributo == 4) then --> DISPELLS
			keyName = "dispell"
		elseif (sub_atributo == 5) then --> DEATHS
			keyName = "dead"
		end
	
	end
	
	if (keyName == "dead") then 
		local mortes = tabela_do_combate.last_events_tables
		--> não precisa reordenar, uma vez que sempre vai da na ordem do último a morrer até o primeiro
		-- _table_sort (mortes, function (m1, m2) return m1[2] < m2[2] end) -- [1] = tabela com a morte [2] = tempo [3] = nome do jogador
		instancia.top = 1
		total = #mortes
		
		if (exportar) then 
			return mortes
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
			atributo_misc:DeadAtualizarBarra (mortes[i], qual_barra, i, instancia)
			--conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName, true) --> instância, index, total, valor da 1º barra
			qual_barra = qual_barra+1
		end
		
		return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
		
	else
	
		if (instancia.atributo == 5) then --> custom
			--> faz o sort da categoria e retorna o amount corrigido
			amount = _detalhes:ContainerSort (conteudo, amount, keyName)
			
			--> grava o total
			instancia.top = conteudo[1][keyName]
	
		elseif (modo == modo_ALL) then --> mostrando ALL
		
			--> faz o sort da categoria
			_table_sort (conteudo, function (a, b) 
			
				if (a[keyName] and b[keyName]) then
					return a[keyName] > b[keyName] 
				elseif (a[keyName] and not b[keyName]) then
					return true
				else
					return false
				end
				
			end)
			
			--> não mostrar resultados com zero
			for i = amount, 1, -1 do --> de trás pra frente
				if (not conteudo[i][keyName]) then
					amount = amount-i
					break
				end
			end

			total = tabela_do_combate.totals [class_type] [keyName]
			
			--> grava o total
			instancia.top = conteudo[1][keyName]
		
		elseif (modo == modo_GROUP) then --> mostrando GROUP
		
			--> faz o sort da categoria
			_table_sort (conteudo, function (a, b) 
			
				if (a.grupo and b.grupo) then
					if (a[keyName] and b[keyName]) then
						return a[keyName] > b[keyName] 
					elseif (a[keyName] and not b[keyName]) then
						return true
					else
						return false
					end
				elseif (a.grupo and not b.grupo) then
					return true
				elseif (not a.grupo and b.grupo) then
					return false
				else
					if (a[keyName] and b[keyName]) then
						return a[keyName] > b[keyName] 
					elseif (a[keyName] and not b[keyName]) then
						return true
					else
						return false
					end
				end
			end)
		
			for index, player in _ipairs (conteudo) do
				if (_bit_band (player.flag, DFLAG_player_group) >= 0x101) then --> é um player e esta em grupo
					if (not player[keyName] or player[keyName] < 1) then --> dano menor que 1, interromper o loop
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

	--> refaz o mapa do container
	showing:remapear()

	if (exportar) then 
		return total, keyName, instancia.top
	end

	if (amount < 1) then --> não há barras para mostrar
		instancia:EsconderScrollBar() --> precisaria esconder a scroll bar
		return _detalhes:EndRefresh (instancia, total, tabela_do_combate, showing) --> retorna a tabela que precisa ganhar o refresh
	end

	--estra mostrando ALL então posso seguir o padrão correto? primeiro, atualiza a scroll bar...
	instancia:AtualizarScrollBar (amount)
	
	--depois faz a atualização normal dele através dos iterators
	local qual_barra = 1
	local barras_container = instancia.barras
	
	for i = instancia.barraS[1], instancia.barraS[2], 1 do --> vai atualizar só o range que esta sendo mostrado
		conteudo[i]:AtualizaBarra (instancia, barras_container, qual_barra, i, total, sub_atributo, forcar, keyName) --> instância, index, total, valor da 1º barra
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

--self = esta classe de dano

function atributo_misc:Custom (_customName, _combat, sub_atributo, spell, alvo)
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

function atributo_misc:AtualizaBarra (instancia, barras_container, qual_barra, lugar, total, sub_atributo, forcar, keyName, is_dead)

	--print (self.ress)

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
	
	local meu_total = self [keyName] --> total de dano que este jogador deu
	if (not meu_total) then
		return
	end
	local porcentagem = meu_total / total * 100
	local esta_porcentagem = _math_floor ((meu_total/instancia.top) * 100)

	esta_barra.texto_direita:SetText (meu_total .." ".. div_abre .. _cstr ("%.1f", porcentagem).."%" .. div_fecha) --seta o texto da direita
	
	if (esta_barra.mouse_over and not instancia.baseframe.isMoving) then --> precisa atualizar o tooltip
		gump:UpdateTooltip (qual_barra, esta_barra, instancia)
	end

	return self:RefreshBarra2 (esta_barra, instancia, tabela_anterior, forcar, esta_porcentagem, qual_barra, barras_container)
end



--------------------------------------------- // TOOLTIPS // ---------------------------------------------


---------> TOOLTIPS BIFURCAÇÃO
function atributo_misc:ToolTip (instancia, numero, barra)
	--> seria possivel aqui colocar o icone da classe dele?
	GameTooltip:ClearLines()
	GameTooltip:AddLine (barra.colocacao..". "..self.nome)
	
	if (instancia.sub_atributo == 3) then --> interrupt
		return self:ToolTipInterrupt (instancia, numero, barra)
	elseif (instancia.sub_atributo == 1) then --> cc_break
		return self:ToolTipCC (instancia, numero, barra)
	elseif (instancia.sub_atributo == 2) then --> ress 
		return self:ToolTipRess (instancia, numero, barra)
	elseif (instancia.sub_atributo == 4) then --> dispell
		return self:ToolTipDispell (instancia, numero, barra)
	elseif (instancia.sub_atributo == 5) then --> mortes
		return self:ToolTipDead (instancia, numero, barra)
	end
end
--> tooltip locals
local r, g, b
local headerColor = "yellow"
local barAlha = .6


function atributo_misc:ToolTipDead (instancia, numero, barra)
	
	local last_dead = self.dead_log [#self.dead_log]

end

function atributo_misc:ToolTipCC (instancia, numero, barra)

	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack (_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack (_detalhes.class_colors [self.classe])
	end	

	local meu_total = self ["cc_break"]
	local habilidades = self.cc_break_spell_tables._ActorTable
	
--> habilidade usada para dispelar
	local meus_cc_breaks = {}
	for _spellid, _tabela in _pairs (habilidades) do
		meus_cc_breaks [#meus_cc_breaks+1] = {_spellid, _tabela.cc_break}
	end
	_table_sort (meus_cc_breaks, function(a, b) return a[2] > b[2] end)
	
	GameTooltip:AddLine (Loc ["STRING_SPELLS"]..":") 
	if (#meus_cc_breaks > 0) then
		for i = 1, _math_min (3, #meus_cc_breaks) do
			local esta_habilidade = meus_cc_breaks[i]
			local nome_magia, _, icone_magia = _GetSpellInfo (esta_habilidade[1])
			GameCooltip:AddLine (nome_magia..": ", esta_habilidade[2].." (".._cstr("%.1f", esta_habilidade[2]/meu_total*100).."%)")
			GameCooltip:AddIcon (icone_magia, nil, nil, 14, 14)
		end
	else
		GameTooltip:AddLine (Loc ["STRING_NO_SPELL"])
	end
	
--> quais habilidades foram dispaladas
	local buffs_dispelados = {}
	for _spellid, amt in _pairs (self.cc_break_oque) do
		buffs_dispelados [#buffs_dispelados+1] = {_spellid, amt}
	end
	_table_sort (buffs_dispelados, function(a, b) return a[2] > b[2] end)
	
	GameTooltip:AddLine (Loc ["STRING_CCBROKE"] .. ":") 
	if (#buffs_dispelados > 0) then
		for i = 1, _math_min (3, #buffs_dispelados) do
			local esta_habilidade = buffs_dispelados[i]
			local nome_magia, _, icone_magia = _GetSpellInfo (esta_habilidade[1])
			GameCooltip:AddLine (nome_magia..": ", esta_habilidade[2].." (".._cstr("%.1f", esta_habilidade[2]/meu_total*100).."%)")
			GameCooltip:AddIcon (icone_magia, nil, nil, 14, 14)
		end
	end
	
	return true
end

function atributo_misc:ToolTipDispell (instancia, numero, barra)

	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack (_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack (_detalhes.class_colors [self.classe])
	end	

	local meu_total = self ["dispell"]
	local habilidades = self.dispell_spell_tables._ActorTable
	
--> habilidade usada para dispelar
	local meus_dispells = {}
	for _spellid, _tabela in _pairs (habilidades) do
		meus_dispells [#meus_dispells+1] = {_spellid, _tabela.dispell}
	end
	_table_sort (meus_dispells, function(a, b) return a[2] > b[2] end)
	
	GameTooltip:AddLine (Loc ["STRING_SPELLS"]..":") 
	if (#meus_dispells > 0) then
		for i = 1, _math_min (3, #meus_dispells) do
			local esta_habilidade = meus_dispells[i]
			local nome_magia, _, icone_magia = _GetSpellInfo (esta_habilidade[1])
			GameCooltip:AddLine (nome_magia..": ", esta_habilidade[2].." (".._cstr("%.1f", esta_habilidade[2]/meu_total*100).."%)")
			GameCooltip:AddIcon (icone_magia, nil, nil, 14, 14)
		end
	else
		GameTooltip:AddLine (Loc ["STRING_NO_SPELL"])
	end
	
--> quais habilidades foram dispaladas
	local buffs_dispelados = {}
	for _spellid, amt in _pairs (self.dispell_oque) do
		buffs_dispelados [#buffs_dispelados+1] = {_spellid, amt}
	end
	_table_sort (buffs_dispelados, function(a, b) return a[2] > b[2] end)
	
	GameTooltip:AddLine (Loc ["STRING_DISPELLED"] .. ":") 
	if (#buffs_dispelados > 0) then
		for i = 1, _math_min (3, #buffs_dispelados) do
			local esta_habilidade = buffs_dispelados[i]
			local nome_magia, _, icone_magia = _GetSpellInfo (esta_habilidade[1])
			GameCooltip:AddLine (nome_magia..": ", esta_habilidade[2].." (".._cstr("%.1f", esta_habilidade[2]/meu_total*100).."%)")
			GameCooltip:AddIcon (icone_magia, nil, nil, 14, 14)
		end
	end
	
	return true
end

function atributo_misc:ToolTipRess (instancia, numero, barra)

	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack (_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack (_detalhes.class_colors [self.classe])
	end	

	local meu_total = self ["ress"]
	local minha_tabela = self.ress_spell_tables._ActorTable
	
--> habilidade usada para interromper
	local meus_ress = {}
	
	for _spellid, _tabela in _pairs (minha_tabela) do
		meus_ress [#meus_ress+1] = {_spellid, _tabela.ress}
	end
	_table_sort (meus_ress, function(a, b) return a[2] > b[2] end)
	
	GameTooltip:AddLine (Loc ["STRING_SPELLS"]..":") 
	if (#meus_ress > 0) then
		for i = 1, _math_min (3, #meus_ress) do
			local esta_habilidade = meus_ress[i]
			local nome_magia, _, icone_magia = _GetSpellInfo (esta_habilidade[1])
			GameCooltip:AddLine (nome_magia..": ", esta_habilidade[2].." (".._cstr("%.1f", esta_habilidade[2]/meu_total*100).."%)")
			GameCooltip:AddIcon (icone_magia, nil, nil, 14, 14)
		end
	else
		GameTooltip:AddLine (Loc ["STRING_NO_SPELL"]) 
	end

--> quem foi que o cara reviveu
	local meus_alvos = self.ress_targets._ActorTable
	local alvos = {}
	
	for _, _tabela in _ipairs (meus_alvos) do
		alvos [#alvos+1] = {_tabela.nome, _tabela.total}
	end
	_table_sort (alvos, function(a, b) return a[2] > b[2] end)
	
	GameTooltip:AddLine (Loc ["STRING_TARGETS"]..":")
	if (#alvos > 0) then
		for i = 1, _math_min (3, #alvos) do
			GameCooltip:AddLine (alvos[i][1]..": ", alvos[i][2])
			GameCooltip:AddIcon ("Interface\\Icons\\PALADIN_HOLY", nil, nil, 14, 14)
		end
	end
	
	return true

end

function atributo_misc:ToolTipInterrupt (instancia, numero, barra)

	local owner = self.owner
	if (owner and owner.classe) then
		r, g, b = unpack (_detalhes.class_colors [owner.classe])
	else
		r, g, b = unpack (_detalhes.class_colors [self.classe])
	end	

	local meu_total = self ["interrupt"]
	local minha_tabela = self.interrupt_spell_tables._ActorTable
	
--> habilidade usada para interromper
	local meus_interrupts = {}
	
	for _spellid, _tabela in _pairs (minha_tabela) do
		meus_interrupts [#meus_interrupts+1] = {_spellid, _tabela.counter}
	end
	_table_sort (meus_interrupts, function(a, b) return a[2] > b[2] end)
	
	GameTooltip:AddLine (Loc ["STRING_SPELLS"]..":")
	if (#meus_interrupts > 0) then
		for i = 1, _math_min (3, #meus_interrupts) do
			local esta_habilidade = meus_interrupts[i]
			local nome_magia, _, icone_magia = _GetSpellInfo (esta_habilidade[1])
			GameCooltip:AddLine (nome_magia..": ", esta_habilidade[2].." (".._cstr("%.1f", esta_habilidade[2]/meu_total*100).."%)")
			GameCooltip:AddIcon (icone_magia, nil, nil, 14, 14)
		end
	else
		GameTooltip:AddLine (Loc ["STRING_NO_SPELL"])
	end
	
--> quais habilidades foram interrompidas
	local habilidades_interrompidas = {}
	
	for _spellid, amt in _pairs (self.interrompeu_oque) do
		habilidades_interrompidas [#habilidades_interrompidas+1] = {_spellid, amt}
	end
	_table_sort (habilidades_interrompidas, function(a, b) return a[2] > b[2] end)
	
	GameTooltip:AddLine (Loc ["STRING_SPELL_INTERRUPTED"] .. ":")
	if (#habilidades_interrompidas > 0) then
		for i = 1, _math_min (3, #habilidades_interrompidas) do
			local esta_habilidade = habilidades_interrompidas[i]
			local nome_magia, _, icone_magia = _GetSpellInfo (esta_habilidade[1])
			GameCooltip:AddLine (nome_magia..": ", esta_habilidade[2].." (".._cstr("%.1f", esta_habilidade[2]/meu_total*100).."%)")
			GameCooltip:AddIcon (icone_magia, nil, nil, 14, 14)
		end
	end
	
	return true
end


--------------------------------------------- // JANELA DETALHES // ---------------------------------------------


---------> DETALHES BIFURCAÇÃO
function atributo_misc:MontaInfo()
	if (info.sub_atributo == 3) then --> interrupt
		return self:MontaInfoInterrupt()
	end
end

---------> DETALHES bloco da direita BIFURCAÇÃO
function atributo_misc:MontaDetalhes (spellid, barra)
	if (info.sub_atributo == 3) then --> interrupt
		return self:MontaDetalhesInterrupt (spellid, barra)
	end
end

------ Interrupt
function atributo_misc:MontaInfoInterrupt()

--[[
--> quais habilidades foram interrompidas
	local habilidades_interrompidas = {}
	
	for _spellid, amt in _pairs (self.interrompeu_oque) do
		habilidades_interrompidas [#habilidades_interrompidas+1] = {_spellid, amt}
	end
	_table_sort (habilidades_interrompidas, function(a, b) return a[2] > b[2] end)
	
	GameTooltip:AddLine ("Habilidades Interrompidas:") 
	if (#habilidades_interrompidas > 0) then
		for i = 1, _math_min (3, #habilidades_interrompidas) do
			local esta_habilidade = habilidades_interrompidas[i]
			local nome_magia, _, icone_magia = _GetSpellInfo (esta_habilidade[1])
			GameTooltip:AddDoubleLine (nome_magia..": ", esta_habilidade[2].." (".._cstr("%.1f", esta_habilidade[2]/meu_total*100).."%)", 1, 1, 1, 1, 1, 1)
			GameTooltip:AddTexture (icone_magia)
		end
	end
--]]

	local meu_total = self ["interrupt"]
	local minha_tabela = self.interrupt_spell_tables._ActorTable

	local barras = info.barras1
	local instancia = info.instancia
	
	local meus_interrupts = {}

	for _spellid, _tabela in _pairs (minha_tabela) do --> da foreach em cada spellid do container
		local nome, _, icone = _GetSpellInfo (_spellid)
		_table_insert (meus_interrupts, {_spellid, _tabela.counter, _tabela.counter/meu_total*100, nome, icone})
	end

	_table_sort (meus_interrupts, function(a, b) return a[2] > b[2] end)

	local amt = #meus_interrupts
	gump:JI_AtualizaContainerBarras (amt)

	local max_ = meus_interrupts [1][2] --> dano que a primeiro magia vez

	local barra
	for index, tabela in _ipairs (meus_interrupts) do

		barra = barras [index]

		if (not barra) then --> se a barra não existir, criar ela então
			barra = gump:CriaNovaBarraInfo1 (instancia, index)
			
			barra.textura:SetStatusBarColor (1, 1, 1, 1) --> isso aqui é a parte da seleção e desceleção
			barra.on_focus = false --> isso aqui é a parte da seleção e desceleção
		end

		--> isso aqui é tudo da seleção e desceleção das barras
		
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
		barra.texto_direita:SetText (tabela[2] .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[3]) .."%".. instancia.divisores.fecha) --seta o texto da direita
		
		barra.icone:SetTexture (tabela[5])

		barra.minha_tabela = self --> grava o jogador na barrinho... é estranho pq todas as barras vão ter o mesmo valor do jogador
		barra.show = tabela[1] --> grava o spellid na barra
		barra:Show() --> mostra a barra

		-- jogador . detalhes ?? 
		if (self.detalhes and self.detalhes == barra.show) then
			self:MontaDetalhes (self.detalhes, barra) --> poderia deixar isso pro final e montar uma tail call??
		end
	end
	
	
	
	--[
	--> Alvos do interrupt
	local meus_alvos = {}
	for _, tabela in _pairs (self.interrupt_targets._ActorTable) do
		meus_alvos [#meus_alvos+1] = {tabela.nome, tabela.total}
	end
	_table_sort (meus_alvos, function(a, b) return a[2] > b[2] end)
	
	local amt_alvos = #meus_alvos
	if (amt_alvos < 1) then
		return
	end
	gump:JI_AtualizaContainerAlvos (amt_alvos)
	
	local max_alvos = meus_alvos[1][2]
	
	local barra
	for index, tabela in _ipairs (meus_alvos) do
	
		barra = info.barras2 [index]
		
		if (not barra) then
			barra = gump:CriaNovaBarraInfo2 (instancia, index)
			barra.textura:SetStatusBarColor (1, 1, 1, 1)
		end
		
		if (index == 1) then
			barra.textura:SetValue (100)
		else
			barra.textura:SetValue (tabela[2]/max_alvos*100)
		end

		barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..tabela[1]) --seta o texto da esqueda
		barra.texto_direita:SetText (tabela[2] .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[2]/meu_total*100) .. instancia.divisores.fecha) --seta o texto da direita
		
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
		
		--gump:TextoBarraOnInfo2 (index, , )
		-- o que mostrar no local do ícone?
		--barra.icone:SetTexture (tabela[4][3])
		
		barra.minha_tabela = self --> grava o jogador na tabela
		barra.nome_inimigo = tabela [1] --> salva o nome do inimigo na barra --> isso é necessário?
		
		-- no lugar do spell id colocar o que?
		--barra.spellid = tabela[5]
		barra:Show()
		
		--if (self.detalhes and self.detalhes == barra.spellid) then
		--	self:MontaDetalhes (self.detalhes, barra)
		--end
	end
	--]]

end


------ Detalhe Info Interrupt
function atributo_misc:MontaDetalhesInterrupt (spellid, barra)

	for _, barra in _ipairs (info.barras3) do 
		barra:Hide()
	end

	local esta_magia = self.interrupt_spell_tables._ActorTable [spellid]
	if (not esta_magia) then
		return
	end
	
	--> icone direito superior
	local nome, _, icone = _GetSpellInfo (spellid)
	local infospell = {nome, nil, icone}

	_detalhes.janela_info.spell_icone:SetTexture (infospell[3])

	local total = self.interrupt
	local meu_total = esta_magia.counter
	
	local index = 1
	
	local data = {}	
	
	local barras = info.barras3
	local instancia = info.instancia
	
	local habilidades_alvos = {}
	for spellid, amt in pairs (esta_magia.interrompeu_oque) do 
		habilidades_alvos [#habilidades_alvos+1] = {spellid, amt}
	end
	_table_sort (habilidades_alvos, function(a, b) return a[2] > b[2] end)
	local max_ = habilidades_alvos[1][2]
	
	local barra
	for index, tabela in _ipairs (habilidades_alvos) do
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
		
		local nome, _, icone = _GetSpellInfo (tabela[1])

		barra.texto_esquerdo:SetText (index..instancia.divisores.colocacao..nome) --seta o texto da esqueda
		barra.texto_direita:SetText (tabela[2] .." ".. instancia.divisores.abre .._cstr("%.1f", tabela[2]/total*100) .."%".. instancia.divisores.fecha) --seta o texto da direita
		
		barra.icone:SetTexture (icone)

		barra:Show() --> mostra a barra
		
		if (index == 15) then 
			break
		end
	end
	
end


function atributo_misc:MontaTooltipAlvos (esta_barra, index)
	
	local inimigo = esta_barra.nome_inimigo
	
	local container
	if (info.instancia.sub_atributo == 3) then --interrupt
		container = self.interrupt_spell_tables._ActorTable
	end
	
	local habilidades = {}
	local total = self.interrupt
	
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
	GameTooltip:AddLine (Loc ["STRING_SPELL_INTERRUPTED"] .. ":") 
	GameTooltip:AddLine (" ")
	
	for index, tabela in _ipairs (habilidades) do
		local nome, rank, icone = _GetSpellInfo (tabela[1])
		if (index < 8) then
			GameTooltip:AddDoubleLine (index..". |T"..icone..":0|t "..nome, tabela[2].." (".._cstr("%.1f", tabela[2]/total*100).."%)", 1, 1, 1, 1, 1, 1)
			--GameTooltip:AddTexture (icone)
		else
			GameTooltip:AddDoubleLine (index..". "..nome, tabela[2].." (".._cstr("%.1f", tabela[2]/total*100).."%)", .65, .65, .65, .65, .65, .65)
		end
	end
	
	return true
	--GameTooltip:AddDoubleLine (meus_danos[i][4][1]..": ", meus_danos[i][2].." (".._cstr("%.1f", meus_danos[i][3]).."%)", 1, 1, 1, 1, 1, 1)
	
end


--if (esta_magia.counter == esta_magia.c_amt) then --> só teve critico
--	gump:SetaDetalheInfoTexto (1, nil, nil, nil, nil, nil, "DPS: "..crit_dps)
--end

--controla se o dps do jogador esta travado ou destravado
function atributo_misc:Iniciar (iniciar)
	return false --retorna se o dps esta aberto ou fechado para este jogador
end

function atributo_misc:ColetarLixo()
	return _detalhes:ColetarLixo (class_type)
end

local function ReconstroiMapa (tabela)
	local mapa = {}
	for i = 1, #tabela._ActorTable do
		mapa [tabela._ActorTable[i].nome] = i
	end
	tabela._NameIndexTable = mapa
end

function _detalhes.refresh:r_atributo_misc (este_jogador, shadow)
	_setmetatable (este_jogador, _detalhes.atributo_misc)
	este_jogador.__index = _detalhes.atributo_misc
	
	if (shadow ~= -1) then
		este_jogador.shadow = shadow
		
		--> refresh interrupts
		if (este_jogador.interrupt_targets) then
			_detalhes.refresh:r_container_combatentes (este_jogador.interrupt_targets, shadow.interrupt_targets)
			_detalhes.refresh:r_container_habilidades (este_jogador.interrupt_spell_tables, shadow.interrupt_spell_tables)
		end
		
		--> refresh ressers
		if (este_jogador.ress_targets) then
			_detalhes.refresh:r_container_combatentes (este_jogador.ress_targets, shadow.ress_targets)
			_detalhes.refresh:r_container_habilidades (este_jogador.ress_spell_tables, shadow.ress_spell_tables)
		end
		
		--> refresh dispells
		if (este_jogador.dispell_targets) then
			_detalhes.refresh:r_container_combatentes (este_jogador.dispell_targets, shadow.dispell_targets)
			_detalhes.refresh:r_container_habilidades (este_jogador.dispell_spell_tables, shadow.dispell_spell_tables)
		end
		
		--> refresh cc_breaks
		if (este_jogador.cc_break_targets) then
			_detalhes.refresh:r_container_combatentes (este_jogador.cc_break_targets, shadow.cc_break_targets)
			_detalhes.refresh:r_container_habilidades (este_jogador.cc_break_spell_tables, shadow.cc_break_spell_tables)
		end
	else
	
		--> refresh interrupts
		if (este_jogador.interrupt_targets) then
			_detalhes.refresh:r_container_combatentes (este_jogador.interrupt_targets, -1)
			_detalhes.refresh:r_container_habilidades (este_jogador.interrupt_spell_tables, -1)
		end
		
		--> refresh ressers
		if (este_jogador.ress_targets) then
			_detalhes.refresh:r_container_combatentes (este_jogador.ress_targets, -1)
			_detalhes.refresh:r_container_habilidades (este_jogador.ress_spell_tables, -1)
		end
		
		--> refresh dispells
		if (este_jogador.dispell_targets) then
			_detalhes.refresh:r_container_combatentes (este_jogador.dispell_targets, -1)
			_detalhes.refresh:r_container_habilidades (este_jogador.dispell_spell_tables, -1)
		end

		--> refresh cc_breaks
		if (este_jogador.cc_break_targets) then
			_detalhes.refresh:r_container_combatentes (este_jogador.cc_break_targets, -1)
			_detalhes.refresh:r_container_habilidades (este_jogador.cc_break_spell_tables, -1)
		end		
	end
end

function _detalhes.clear:c_atributo_misc (este_jogador)

	este_jogador.__index = {}
	este_jogador.shadow = nil
	este_jogador.links = nil
	este_jogador.minha_barra = nil
	
	if (este_jogador.interrupt_targets) then
		_detalhes.clear:c_container_combatentes (este_jogador.interrupt_targets)
		_detalhes.clear:c_container_habilidades (este_jogador.interrupt_spell_tables)
	end
	
	if (este_jogador.ress_targets) then
		_detalhes.clear:c_container_combatentes (este_jogador.ress_targets)
		_detalhes.clear:c_container_habilidades (este_jogador.ress_spell_tables)
	end
	
	if (este_jogador.cc_break_targets) then
		_detalhes.clear:c_container_combatentes (este_jogador.cc_break_targets)
		_detalhes.clear:c_container_habilidades (este_jogador.cc_break_spell_tables)
	end
	
	if (este_jogador.dispell_targets) then
		_detalhes.clear:c_container_combatentes (este_jogador.dispell_targets)
		_detalhes.clear:c_container_habilidades (este_jogador.dispell_spell_tables)
	end
	
end

atributo_misc.__add = function (shadow, tabela2)

	if (tabela2.interrupt) then
	
		shadow.interrupt = shadow.interrupt + tabela2.interrupt
		_detalhes.tabela_overall.totals[4]["interrupt"] = _detalhes.tabela_overall.totals[4]["interrupt"] + tabela2.interrupt
		
		if (tabela2.grupo) then
			_detalhes.tabela_overall.totals_grupo[4]["interrupt"] = _detalhes.tabela_overall.totals_grupo[4]["interrupt"] + tabela2.interrupt
		end
		
		for index, alvo in _ipairs (tabela2.interrupt_targets._ActorTable) do 
			local alvo_shadow = shadow.interrupt_targets:PegarCombatente (alvo.serial, alvo.nome, alvo.flag_original, true)
			alvo_shadow.total = alvo_shadow.total + alvo.total
		end
		
		for spellid, habilidade in _pairs (tabela2.interrupt_spell_tables._ActorTable) do 
			local habilidade_shadow = shadow.interrupt_spell_tables:PegaHabilidade (spellid, true, nil, true)
			
			habilidade_shadow.interrompeu_oque = {}
			for _spellid, amount in _pairs (habilidade.interrompeu_oque) do
				habilidade_shadow.interrompeu_oque [_spellid] = amount
			end
			
			for index, alvo in _ipairs (habilidade.targets._ActorTable) do 
				local alvo_shadow = habilidade_shadow.targets:PegarCombatente (alvo.serial, alvo.nome, alvo.flag_original, true)
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

		for spellid, amount in _pairs (tabela2.interrompeu_oque) do 
			if (not shadow.interrompeu_oque [spellid]) then 
				shadow.interrompeu_oque [spellid] = 0
			end
			shadow.interrompeu_oque [spellid] = shadow.interrompeu_oque [spellid] + amount
		end
		
	end
	
	if (tabela2.ress) then
	
		shadow.ress = shadow.ress + tabela2.ress
		_detalhes.tabela_overall.totals[4]["ress"] = _detalhes.tabela_overall.totals[4]["ress"] + tabela2.ress
		
		if (tabela2.grupo) then
			_detalhes.tabela_overall.totals_grupo[4]["ress"] = _detalhes.tabela_overall.totals_grupo[4]["ress"] + tabela2.ress
		end
		
		for index, alvo in _ipairs (tabela2.ress_targets._ActorTable) do 
			local alvo_shadow = shadow.ress_targets:PegarCombatente (alvo.serial, alvo.nome, alvo.flag_original, true)
			alvo_shadow.total = alvo_shadow.total + alvo.total
		end
		
		for spellid, habilidade in _pairs (tabela2.ress_spell_tables._ActorTable) do 
			local habilidade_shadow = shadow.ress_spell_tables:PegaHabilidade (spellid, true, nil, true)
			
			for index, alvo in _ipairs (habilidade.targets._ActorTable) do 
				local alvo_shadow = habilidade_shadow.targets:PegarCombatente (alvo.serial, alvo.nome, alvo.flag_original, true)
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
		
	end
	
	if (tabela2.dispell) then
	
		shadow.dispell = shadow.dispell + tabela2.dispell
		_detalhes.tabela_overall.totals[4]["dispell"] = _detalhes.tabela_overall.totals[4]["dispell"] + tabela2.dispell
		
		if (tabela2.grupo) then
			_detalhes.tabela_overall.totals_grupo[4]["dispell"] = _detalhes.tabela_overall.totals_grupo[4]["dispell"] + tabela2.dispell
		end
		
		for index, alvo in _ipairs (tabela2.dispell_targets._ActorTable) do 
			local alvo_shadow = shadow.dispell_targets:PegarCombatente (alvo.serial, alvo.nome, alvo.flag_original, true)
			alvo_shadow.total = alvo_shadow.total + alvo.total
		end
		
		for spellid, habilidade in _pairs (tabela2.dispell_spell_tables._ActorTable) do 
			local habilidade_shadow = shadow.dispell_spell_tables:PegaHabilidade (spellid, true, nil, true)
			
			habilidade_shadow.dispell_oque = {}

			if (habilidade.dispell_oque) then
				for _spellid, amount in _pairs (habilidade.dispell_oque) do
					habilidade_shadow.dispell_oque [_spellid] = amount
				end
			end
			
			for index, alvo in _ipairs (habilidade.targets._ActorTable) do 
				local alvo_shadow = habilidade_shadow.targets:PegarCombatente (alvo.serial, alvo.nome, alvo.flag_original, true)
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
		
		for spellid, amount in _pairs (tabela2.dispell_oque) do 
			if (not shadow.dispell_oque [spellid]) then 
				shadow.dispell_oque [spellid] = 0
			end
			shadow.dispell_oque [spellid] = shadow.dispell_oque [spellid] + amount
		end
		
	end
	
	if (tabela2.cc_break) then
	
		shadow.cc_break = shadow.cc_break + tabela2.cc_break
		_detalhes.tabela_overall.totals[4]["cc_break"] = _detalhes.tabela_overall.totals[4]["cc_break"] + tabela2.cc_break
		
		if (tabela2.grupo) then
			_detalhes.tabela_overall.totals_grupo[4]["cc_break"] = _detalhes.tabela_overall.totals_grupo[4]["cc_break"] + tabela2.cc_break
		end
		
		for index, alvo in _ipairs (tabela2.cc_break_targets._ActorTable) do 
			local alvo_shadow = shadow.cc_break_targets:PegarCombatente (alvo.serial, alvo.nome, alvo.flag_original, true)
			alvo_shadow.total = alvo_shadow.total + alvo.total
		end
		
		for spellid, habilidade in _pairs (tabela2.cc_break_spell_tables._ActorTable) do 
			local habilidade_shadow = shadow.cc_break_spell_tables:PegaHabilidade (spellid, true, nil, true)
			
			habilidade_shadow.cc_break_oque = {}
			for _spellid, amount in _pairs (habilidade.cc_break_oque) do
				habilidade_shadow.cc_break_oque [_spellid] = amount
			end
			
			for index, alvo in _ipairs (habilidade.targets._ActorTable) do 
				local alvo_shadow = habilidade_shadow.targets:PegarCombatente (alvo.serial, alvo.nome, alvo.flag_original, true)
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

		for spellid, amount in _pairs (tabela2.cc_break_oque) do 
			if (not shadow.cc_break_oque [spellid]) then 
				shadow.cc_break_oque [spellid] = 0
			end
			shadow.cc_break_oque [spellid] = shadow.cc_break_oque [spellid] + amount
		end
	end
	
	return shadow
end

atributo_misc.__sub = function (tabela1, tabela2)

	if (tabela1.interrupt and tabela2.interrupt) then
		tabela1.interrupt = tabela1.interrupt - tabela2.interrupt
		
		--> reduz o interrompeu_oque
		for spellid, amt in _pairs (tabela2.interrompeu_oque) do
			tabela1.interrompeu_oque [spellid] = tabela1.interrompeu_oque [spellid] - amt
		end
	end
	
	if (tabela1.ress and tabela2.ress) then
		tabela1.ress = tabela1.ress - tabela2.ress
	end
	
	if (tabela1.dispell and tabela2.dispell) then
		tabela1.dispell = tabela1.dispell - tabela2.dispell
	end
	
	if (tabela1.cc_break and tabela2.cc_break) then
		tabela1.cc_break = tabela1.cc_break - tabela2.cc_break
	end
	
	return tabela1
end
