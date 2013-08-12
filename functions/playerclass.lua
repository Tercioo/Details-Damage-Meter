--[[ detect actor class ]]

do 

	local _detalhes	= 	_G._detalhes
	
	local _pairs = pairs
	local _ipairs = ipairs
	local _UnitClass = UnitClass
	local _select = select

	-- try get the class from actor name
	function _detalhes:GetClass (name)
		local _, class = _UnitClass (name)
		
		if (not class) then
			for _, container in _ipairs (_detalhes.tabela_overall) do
				local index = container._NameIndexTable [name]
				if (index) then
					local actor = container._ActorTable [index]
					if (actor.classe ~= "UNGROUPPLAYER") then
						return actor.classe, _detalhes:unpacks (_detalhes.class_coords [actor.classe] or {0.75, 1, 0.75, 1}, _detalhes.class_colors [actor.classe])
					end
				end
			end
		else
			return class, _detalhes:unpacks (_detalhes.class_coords [class] or {0.75, 1, 0.75, 1}, _detalhes.class_colors [class])
		end
	end
	
	function _detalhes:GuessClass (t)
	
		local Actor, container, tries = t[1], t[2], t[3]
		
		if (not Actor) then
			return false
		end
		
		if (Actor.spell_tables) then --> correcao pros containers misc, precisa pegar os diferentes tipos de containers de  lá
			for spellid, _ in _pairs (Actor.spell_tables._ActorTable) do 
				local class = _detalhes.ClassSpellList [spellid]
				if (class) then
					Actor.classe = class
					Actor.shadow.classe = class
					Actor.guessing_class = nil
					
					if (container) then
						container.need_refresh = true
						container.shadow.need_refresh = true
					end
					
					if (Actor.minha_barra) then
						Actor.minha_barra.minha_tabela = nil
					end
				
					return class
				end
			end
		end

		local class = _detalhes:GetClass (Actor.nome)
		if (class) then
			Actor.classe = class
			Actor.shadow.classe = class
			Actor.need_refresh = true
			Actor.shadow.need_refresh = true
			Actor.guessing_class = nil
			
			if (container) then
				container.need_refresh = true
				container.shadow.need_refresh = true
			end
			
			if (Actor.minha_barra) then
				Actor.minha_barra.minha_tabela = nil
			end
			
			return class
		end
		
		if (tries and tries < 10) then 
			_detalhes:ScheduleTimer ("GuessClass", 2, {Actor, container, tries+1})
		end
		
		return false
	end

end
