--lua api
local _table_remove = table.remove
local _table_insert = table.insert
local _setmetatable = setmetatable
local _table_wipe = table.wipe

local _detalhes = 		_G._detalhes
local gump = 			_detalhes.gump

local combate =			_detalhes.combate
local historico = 			_detalhes.historico
local barra_total =		_detalhes.barra_total
local container_pets =		_detalhes.container_pets
local timeMachine =		_detalhes.timeMachine

function historico:NovoHistorico()
	local esta_tabela = {tabelas = {}}
	_setmetatable (esta_tabela, historico)
	return esta_tabela
end

--> sai do combate, chamou adicionar a tabela ao histórico
function historico:adicionar (tabela)

	local tamanho = #self.tabelas
	
	--> verifica se precisa dar UnFreeze()
	if (tamanho < _detalhes.segments_amount) then --> vai preencher um novo index vazio
		local ultima_tabela = self.tabelas[tamanho]
		if (not ultima_tabela) then --> não ha tabelas no historico, esta será a #1
			--> pega a tabela do combate atual
			ultima_tabela = tabela
		end
		_detalhes:InstanciaCallFunction (_detalhes.CheckFreeze, tamanho+1, ultima_tabela)
	end

	--> adiciona no index #1
	_table_insert (self.tabelas, 1, tabela)
	
	if (self.tabelas[2]) then
	
		--> fazer limpeza na tabela

		for index, container in ipairs (self.tabelas[2]) do
			if (index < 3) then
				for _, jogador in ipairs (container._ActorTable) do 
				
					--> remover a tabela de last events
					jogador.last_events_table =  nil
					
					--> verifica se ele ainda esta registrado na time machine
					if (jogador.timeMachine) then
						jogador:DesregistrarNaTimeMachine()
					end
					
				end
			else
				break
			end
		end
		
		if (self.tabelas[3]) then
			if (self.tabelas[3].is_trash and self.tabelas[2].is_trash) then
				--> tabela 2 deve ser deletada e somada a tabela 1
				if (_detalhes.debug) then
					detalhes:Msg ("(debug) concatenating two trash segments.")
				end
				
				self.tabelas[2] = self.tabelas[2] + self.tabelas[3]
				self.tabelas[2].is_trash = true
				
				--> remover
				_table_remove (self.tabelas, 3)
				_detalhes:SendEvent ("DETAILS_DATA_SEGMENTREMOVED", nil, nil)
			end
			
			--> debug
			--self.tabelas[2] = self.tabelas[2] + self.tabelas[3]
			--_table_remove (self.tabelas, 3)
		end
		
	end

	--> chama a função que irá atualizar as instâncias com segmentos no histórico
	_detalhes:InstanciaCallFunction (_detalhes.AtualizaSegmentos_AfterCombat, self)
	
	--> verifica se precisa apagar a última tabela do histórico
	if (#self.tabelas > _detalhes.segments_amount) then
		
		local combat_removed = self.tabelas [#self.tabelas]
	
		--> diminuir quantidades no overall
		_detalhes.tabela_overall = _detalhes.tabela_overall - combat_removed
		_detalhes.tabela_overall.start_time = _detalhes.tabela_overall.start_time + (combat_removed.end_time-combat_removed.start_time)
		
		local amt_mortes =  #combat_removed.last_events_tables --> quantas mortes teve nessa luta
		if (amt_mortes > 0) then
			for i = #_detalhes.tabela_overall.last_events_tables, #_detalhes.tabela_overall.last_events_tables-amt_mortes, -1 do 
				_table_remove (_detalhes.tabela_overall.last_events_tables, #_detalhes.tabela_overall.last_events_tables)
			end
		end
		
		--> verificar novamente a time machine
		for _, jogador in ipairs (combat_removed [1]._ActorTable) do --> damage
			if (jogador.timeMachine) then
				jogador:DesregistrarNaTimeMachine()
			end
		end
		for _, jogador in ipairs (combat_removed [2]._ActorTable) do --> heal
			if (jogador.timeMachine) then
				jogador:DesregistrarNaTimeMachine()
			end
		end
		
		--> remover
		_table_remove (self.tabelas, #self.tabelas)
		_detalhes:SendEvent ("DETAILS_DATA_SEGMENTREMOVED", nil, nil)
		
	end
	
	_detalhes:InstanciaCallFunction (_detalhes.AtualizarJanela)
end

--> verifica se tem alguma instancia congelada mostrando o segmento recém liberado
function _detalhes:CheckFreeze (instancia, index_liberado, tabela)
	if (instancia.freezed) then --> esta congelada
		if (instancia.segmento == index_liberado) then
			instancia.showing = tabela
			instancia:UnFreeze()
		end
	end
end

function historico:resetar()

	if (_detalhes.bosswindow) then
		_detalhes.bosswindow:Reset()
	end
	
	if (_detalhes.tabela_vigente.verifica_combate) then --> finaliza a checagem se esta ou não no combate
		_detalhes:CancelTimer (_detalhes.tabela_vigente.verifica_combate)
	end
	
	--> fecha a janela de informações do jogador
	_detalhes:FechaJanelaInfo()
	
	-- novo container de historico
	_detalhes.tabela_historico = historico:NovoHistorico() --joga fora a tabela antiga e cria uma nova
	--novo container para armazenar pets
	_detalhes.tabela_pets = _detalhes.container_pets:NovoContainer()
	_detalhes.container_pets:BuscarPets()
	-- nova tabela do overall e current
	_detalhes.tabela_overall = combate:NovaTabela() --joga fora a tabela antiga e cria uma nova
	-- cria nova tabela do combate atual
	_detalhes.tabela_vigente = combate:NovaTabela (_, _detalhes.tabela_overall)
	
	--marca o addon como fora de combate
	_detalhes.in_combat = false
	--zera o contador de combates
	_detalhes:NumeroCombate (0)
	
	--> limpa o cache de magias
	_detalhes:ClearSpellCache()
	
	--> limpa a tabela de escudos
	_table_wipe (_detalhes.escudos)
	
	--> reinicia a time machine
	timeMachine:Reiniciar()

	_detalhes:InstanciaCallFunction (_detalhes.AtualizaSegmentos) -- atualiza o instancia.showing para as novas tabelas criadas
	_detalhes:InstanciaCallFunction (_detalhes.AtualizaSoloMode_AfertReset) -- verifica se precisa zerar as tabela da janela solo mode
	_detalhes:InstanciaCallFunction (_detalhes.ResetaGump) --_detalhes:ResetaGump ("de todas as instancias")
	_detalhes:InstanciaCallFunction (gump.Fade, "in", nil, "barras")
	
	_detalhes:AtualizaGumpPrincipal (-1) --atualiza todas as instancias
	
	_detalhes:UpdateParserGears()
	
	_detalhes:SendEvent ("DETAILS_DATA_RESET", nil, nil)
end

function _detalhes.refresh:r_historico (este_historico)
	_setmetatable (este_historico, historico)
	--este_historico.__index = historico
end
