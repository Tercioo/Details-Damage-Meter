--File Revision: 2
--Last Modification: 12/09/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.
	-- 12/09/2013: Fixed some problems with garbage collector.

	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = 		_G._detalhes
	local _tempo = time()
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

	local _table_insert = table.insert --lua local
	local _ipairs = ipairs --lua local
	local _pairs = pairs --lua local
	local _time = time --lua local
	local timeMachine = _detalhes.timeMachine --details local

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants
	local _tempo = _time()
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core

	timeMachine.ligada = false

	function timeMachine:Core()

		_tempo = _time()
		_detalhes._tempo = _tempo
		_detalhes:UpdateGears()

		for tipo, tabela in _pairs (self.tabelas) do
			for nome, jogador in _ipairs (tabela) do
				if (jogador) then
					--print (jogador) --> jogador é a referência da tabela classe_damage
					
					local ultima_acao = jogador:UltimaAcao()+3
					if (ultima_acao > _tempo) then --> okey o jogador esta dando dps
						if (jogador.on_hold) then --> o dps estava pausado, retornar a ativa
							jogador:HoldOn (false)
						end
					else
						if (not jogador.on_hold) then --> não ta pausado, precisa por em pausa
							--> verifica se esta castando alguma coisa que leve + que 3 segundos
							jogador:HoldOn (true)
						end
					end
				end
			end
		end
	end

	function timeMachine:Ligar()
		self.atualizador = self:ScheduleRepeatingTimer ("Core", 1)
		self.ligada = true
		self.tabelas = {{}, {}} --> 1 dano 2 cura
		
		local danos = _detalhes.tabela_vigente[1]._ActorTable
		for _, jogador in _ipairs (danos) do
			if (jogador.dps_started) then
				jogador:RegistrarNaTimeMachine()
			end
		end
	end

	function timeMachine:Desligar()
		self.ligada = false
		self.tabelas = nil
		if (self.atualizador) then
			self:CancelTimer (self.atualizador)
			self.atualizador = nil
		end
	end

	function timeMachine:Reiniciar()
		table.wipe (self.tabelas[1])
		table.wipe (self.tabelas[2])
		self.tabelas = {{}, {}} --> 1 dano 2 cura
	end

	function _detalhes:DesregistrarNaTimeMachine()
		if (not timeMachine.ligada) then
			return
		end
		
		local timeMachineContainer = timeMachine.tabelas [self.tipo]
		local actorTimeMachineID = self.timeMachine
		
		if (timeMachineContainer [actorTimeMachineID] == self) then
			self:TerminarTempo()
			self.timeMachine = nil
			timeMachineContainer [actorTimeMachineID] = false
		end
	end

	function _detalhes:RegistrarNaTimeMachine()
		if (not timeMachine.ligada) then
			return
		end
		
		local esta_tabela = timeMachine.tabelas [self.tipo]
		_table_insert (esta_tabela, self)
		self.timeMachine = #esta_tabela
	end 

	function _detalhes:ManutencaoTimeMachine()
		for tipo, tabela in _ipairs (timeMachine.tabelas) do
			local t = {}
			local removed = 0
			for index, jogador in _ipairs (tabela) do
				if (jogador) then
					t [#t+1] = jogador
					jogador.timeMachine = #t
				else
					removed = removed + 1
				end
			end
			
			timeMachine.tabelas [tipo] = t
			
			if (_detalhes.debug) then
				_detalhes:Msg ("timemachine r"..removed.."| e"..#t.."| t"..tipo)
			end
		end
	end

	function _detalhes:Tempo()
		if (self.end_time) then --> o tempo do jogador esta trancado
			return self.end_time - self.start_time
		elseif (self.on_hold) then --> o tempo esta em pausa
			return self.delay - self.start_time
		else
			return _tempo - self.start_time
		end
	end

	function _detalhes:IniciarTempo (tempo, shadow)

	-- inicia o tempo no objeto atual
	--------------------------------------------------------------------------------
		
		if (self.start_time > 0) then
			print ("DEBUG: "..self.name.." ja tinha start_time...")
		else
			self.start_time = tempo
		end

	-- inicia o tempo no shadow do objeto
	--------------------------------------------------------------------------------	
		-- eu nao sei se a shadow esta iniciando agora sou esta apenas reabrindo
		-- tbm nao sei se a shadow esta reabrindo normalmente ou se esta reabrindo devido a combate menor de 4 segundos
		
		-- verificar se a shadow esta com TEMPO FINALIZADO
		-- SE ESTIVER significa que a shadow esta sendo reaberta
		
		if (shadow.end_time) then
			-- reabrir o tempo da shadow
			-- eu tenho o tempo da abertura do combate atual, e o inicio e fim do tempo da shadow
			
			-- tempo do inicio da shadow = tempo de abertura ATUAL menos tempo de combate da shadow
			local subs = shadow.end_time - shadow.start_time
			shadow.start_time = tempo - subs
			shadow.end_time = nil -- o tempo foi aberto retirando o end_time
			
		else -- pela minha logica se nao tiver end_time significa que precisa apenas gravar o tempo de inicio
			-- a shadow foi recém criada e esta abrindo o tempo pela primeira vez
			if (shadow.start_time == 0) then --> ja esta em um combate
				shadow.start_time = tempo
			end
		end
	end

	function _detalhes:TerminarTempo (subs)
		if (self.end_time) then
			return
		end
		subs = subs or 0
		if (self.on_hold) then
			self.end_time = self.delay - subs -- isso ta certo? por que self.delay carrega o tempo quando o jogador parou o dps
			self.on_hold = false
			self.delay = nil
		else
			self.end_time = _tempo - subs
		end
		if (self.shadow) then
			return self.shadow:TerminarTempo (subs)
		end
	end

	--> diz se o dps deste jogador esta em pausa
	function _detalhes:HoldOn (pausa)
		if (pausa == nil) then 
			return self.on_hold --retorna se o dps esta aberto ou fechado para este jogador
		elseif (pausa) then --> true
			self.delay = _tempo
			self.on_hold = true
		else --> false
			self.start_time = self.start_time + (_tempo-self.delay)
			self.on_hold = false
		end
	end

	--controla quando foi a ultima vez que este jogador deu dano
	function _detalhes:UltimaAcao (tempo)
		if (not tempo) then
			return self.last_event
		else
			self.last_event = tempo
		end
	end

	function _detalhes:PrintTimeMachineIndexes()
		print ("timemachine damage", #timeMachine.tabelas [1])
		print ("timemachine heal", #timeMachine.tabelas [2])
	end