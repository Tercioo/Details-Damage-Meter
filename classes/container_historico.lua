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
				
					--> limpeza
					jogador.last_events_table =  nil
					
				end
			else
				break
			end
		end
	end

	--> chama a função que irá atualizar as instâncias com segmentos no histórico
	_detalhes:InstanciaCallFunction (_detalhes.AtualizaSegmentos_AfterCombat, self)
	
	--> verifica se precisa apagar a última tabela do histórico
	if (#self.tabelas > _detalhes.segments_amount) then
		
		-- BETA subtração do combate overall
		_detalhes.tabela_overall = _detalhes.tabela_overall - self.tabelas [#self.tabelas]
		_detalhes.tabela_overall.start_time = _detalhes.tabela_overall.start_time + (self.tabelas[#self.tabelas].end_time-self.tabelas[#self.tabelas].start_time)
		--print (#self.tabelas)
		
		local amt_mortes =  #self.tabelas[#self.tabelas].last_events_tables --> quantas mortes teve nessa luta
		if (amt_mortes > 0) then
			for i = #_detalhes.tabela_overall.last_events_tables, #_detalhes.tabela_overall.last_events_tables-amt_mortes, -1 do 
				_table_remove (_detalhes.tabela_overall.last_events_tables, #_detalhes.tabela_overall.last_events_tables)
			end
		end
		
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
